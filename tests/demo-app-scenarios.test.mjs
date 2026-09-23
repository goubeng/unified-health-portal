import test from 'node:test';
import assert from 'node:assert/strict';
import {createSeed} from '../src/mock/seed.js';
import {scenarioFixtures,mergeMissingScenarioFields,buildScenarioReadSql,buildScenarioIntegritySql,buildScenarioPatchSql} from '../database/validation/restore-demo-app-scenarios.mjs';

test('演示应用场景补丁覆盖当前种子的全部应用和五个状态字段',()=>{
 const apps=createSeed().apps;
 assert.equal(scenarioFixtures.length,apps.length);
 assert.equal(new Set(scenarioFixtures.map(row=>row.runtime_id)).size,apps.length);
 for(const fixture of scenarioFixtures){
  const app=apps.find(row=>row.id===fixture.runtime_id);
  assert.equal(fixture.code,'P4FIX_'+app.code);
  assert.deepEqual(fixture.patch,Object.fromEntries(['accessMode','accountBindingMode','postGrantMode','accountOpeningMode','mockScenario'].map(key=>[key,app[key]])));
 }
});

test('仅补空缺字段，不覆盖现有授权、绑定和演示配置',()=>{
 const patch=scenarioFixtures.find(row=>row.runtime_id==='MOCK_APP_13').patch;
 const existing={accessMode:'BIND',accountBindingMode:null,postGrantMode:'',accountOpeningMode:'NONE',mockScenario:null,enabled:false,status:'DISABLED',custom:'保留'};
 const merged=mergeMissingScenarioFields(existing,patch);
 assert.equal(merged.accessMode,'BIND');
 assert.equal(merged.accountBindingMode,patch.accountBindingMode);
 assert.equal(merged.postGrantMode,patch.postGrantMode);
 assert.equal(merged.accountOpeningMode,'NONE');
 assert.equal(merged.mockScenario,patch.mockScenario);
 assert.equal(merged.enabled,false);
 assert.equal(merged.status,'DISABLED');
 assert.equal(merged.custom,'保留');
 assert.deepEqual(mergeMissingScenarioFields(merged,patch),merged);
});

test('数据库补丁仅更新匹配的未删除应用 runtime_payload，预览不写入',()=>{
 const preview=buildScenarioReadSql(),patch=buildScenarioPatchSql();
 assert.match(preview,/SELECT coalesce\(json_agg/);
 assert.doesNotMatch(preview,/\bUPDATE\b|\bINSERT\b|\bDELETE\b/);
 const integrity=buildScenarioIntegritySql();
 assert.match(integrity,/preservedDigest/);
 assert.doesNotMatch(integrity,/\bUPDATE\b|\bINSERT\b|\bDELETE\b/);
 assert.match(patch,/UPDATE "pb3gir75kkooyea"\."application" a SET runtime_payload=a\.runtime_payload\|\|candidate\.missing/);
 assert.match(patch,/a\.runtime_id=fixture\.runtime_id AND a\.code=fixture\.code/);
 assert.match(patch,/a\.deleted_at IS NULL/);
 assert.match(patch,/a\.runtime_payload->>entry\.key IS NULL OR btrim\(a\.runtime_payload->>entry\.key\)=''/);
 assert.doesNotMatch(patch,/SET status=|SET enabled=|UPDATE .*application_access_grant/);
});
