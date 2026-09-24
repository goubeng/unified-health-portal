import test from 'node:test';
import assert from 'node:assert/strict';
import {integrationFixtures,buildIntegrationReadSql,buildIntegrationPlan,buildIntegrationApplySql} from '../database/validation/reconcile-demo-integrations.mjs';
import {createSeed} from '../src/mock/seed.js';
import {createPortalService} from '../src/services/portal.js';

const fixtureInput=()=>{
 const rows=integrationFixtures.map(fixture=>({
  id:fixture.id,hash:'HASH_'+fixture.id,payload:{id:fixture.id,appId:fixture.appId,kind:fixture.kind,version:fixture.id==='MOCK_INT_MOCK_APP_1TODO'?2:1,enabled:'DISABLED',createdAt:'2026-09-16T00:00:00.000Z',updatedAt:fixture.id==='MOCK_INT_MOCK_APP_1TODO'?'2026-09-18T14:50:14.759Z':'2026-09-17T23:00:00.000Z'}
 }));
 return {snapshotVersion:300,activeApps:42,physicalDigest:'DIGEST',successfulEdits:[{objectId:'MOCK_INT_MOCK_APP_1TODO'}],rows,
  snapshotRows:structuredClone(rows),physicalRows:integrationFixtures.map(fixture=>({id:fixture.kind==='SSO'?`P4FIX_SSO_${fixture.appId}`:`P4FIX_PUSH_${fixture.appId}_${fixture.kind}`,hash:'PHYS_'+fixture.id,row:{application_id:`P4FIX_${fixture.appId.replace(/^MOCK_/,'')}`,kind:fixture.kind,enabled:'DISABLED',version:fixture.id==='MOCK_INT_MOCK_APP_1TODO'?2:1,status:'UNCONFIGURED'}}))};
};

test('42 个应用每类接入恰有一条种子，安全计划精确保护已成功编辑记录',()=>{
 assert.equal(integrationFixtures.length,126);
 assert.equal(new Set(integrationFixtures.map(row=>row.id)).size,126);
 for(const kind of ['SSO','TODO','MESSAGE'])assert.equal(integrationFixtures.filter(row=>row.kind===kind).length,42);
 const plan=buildIntegrationPlan(fixtureInput());
 assert.equal(plan.safe,true,plan.issues.join('; '));
 assert.equal(plan.candidates.length,125);
 assert.deepEqual(plan.protectedRows.map(row=>row.id),['MOCK_INT_MOCK_APP_1TODO']);
});

test('预览纯 SELECT；事务按摘要、版本和成功编辑审计门禁，只更新目标运行态配置',()=>{
 const read=buildIntegrationReadSql();
 assert.doesNotMatch(read,/\bUPDATE\b|\bINSERT\b|\bDELETE\b/);
 const sql=buildIntegrationApplySql(buildIntegrationPlan(fixtureInput()));
 assert.match(sql,/STALE_RUNTIME_SNAPSHOT/);
 assert.match(sql,/INTEGRATION_EDITED/);
 assert.match(sql,/STALE_INTEGRATION_ROWS/);
 assert.match(sql,/md5\(e\.payload::text\)=f\.hash/);
 assert.match(sql,/statusSource/);
 assert.match(sql,/DEMO_FIXTURE/);
 assert.match(sql,/UPDATE "pb3gir75kkooyea"\."portal_runtime_entity" e/);
 assert.match(sql,/UPDATE "pb3gir75kkooyea"\."system_config" c/);
 assert.match(sql,/UPDATE "pb3gir75kkooyea"\."sso_config" p/);
 assert.match(sql,/UPDATE "pb3gir75kkooyea"\."push_integration_config" p/);
 assert.doesNotMatch(sql,/UPDATE "pb3gir75kkooyea"\."(application|application_user_mapping|todo_item|message)"/);
 assert.doesNotMatch(sql,/"id":"MOCK_INT_MOCK_APP_1TODO","hash"/);
});

test('任何新编辑、缺行或旧占位字段漂移都会使计划不可执行',()=>{
 const edited=fixtureInput();edited.successfulEdits.push({objectId:'MOCK_INT_MOCK_APP_2SSO'});
 assert.equal(buildIntegrationPlan(edited).safe,false);
 const drifted=fixtureInput();drifted.rows.find(row=>row.id==='MOCK_INT_MOCK_APP_2SSO').payload.enabled='ENABLED';
 const plan=buildIntegrationPlan(drifted);
 assert.equal(plan.safe,false);
 assert.throws(()=>buildIntegrationApplySql(plan));
 const missing=fixtureInput();missing.rows.pop();
 assert.equal(buildIntegrationPlan(missing).safe,false);
});

test('重复预览识别已迁移的 125 条而不再次生成写入事务',()=>{
 const input=fixtureInput();
 for(const fixture of integrationFixtures){
  if(fixture.id==='MOCK_INT_MOCK_APP_1TODO')continue;
  const row=input.rows.find(item=>item.id===fixture.id),saved=input.snapshotRows.find(item=>item.id===fixture.id),physical=input.physicalRows.find(item=>item.id===(fixture.kind==='SSO'?`P4FIX_SSO_${fixture.appId}`:`P4FIX_PUSH_${fixture.appId}_${fixture.kind}`));
  Object.assign(row.payload,fixture.patch,{statusSource:'DEMO_FIXTURE',version:2});
  Object.assign(saved.payload,row.payload);
  physical.row.enabled=fixture.patch.enabled;
  physical.row.status=fixture.patch.enabled==='DISABLED'?'DISABLED':'UNCONFIGURED';
  physical.row.version=2;
 }
 const plan=buildIntegrationPlan(input);
 assert.equal(plan.safe,true,plan.issues.join('; '));
 assert.equal(plan.candidates.length,0);
 assert.equal(plan.alreadyApplied.length,125);
 assert.throws(()=>buildIntegrationApplySql(plan));
});

test('监控与用户入口统一取较新的模拟状态，停用配置不会被历史正常采样覆盖',async()=>{
 const state=createSeed(),app=state.apps[0],sso=state.integrations.find(row=>row.appId===app.id&&row.kind==='SSO');
 sso.enabled='ENABLED';sso.configStatus='CONFIGURED';sso.runtimeStatus='ABNORMAL';sso.updatedAt='2026-09-24T00:00:00.000Z';
 state.monitorSamples=[{id:'OLD_SAMPLE',appId:app.id,kind:'SSO',status:'NORMAL',lastCheckedAt:'2026-09-19T00:00:00.000Z',dataSource:'FIXTURE'}];
 const provider={kind:'mock',read:()=>structuredClone(state),transact:fn=>fn(state)};
 const admin=createPortalService(provider,()=>state.users.find(row=>row.id==='MOCK_ADMIN'));
 const user=createPortalService(provider,()=>state.users.find(row=>row.id==='MOCK_USER_1'));
 const monitor=async()=>((await admin.read('monitor')).data.find(row=>row.appId===app.id));
 assert.equal((await monitor()).ssoStatus,'ABNORMAL');
 assert.equal((await user.read('apps')).data.find(row=>row.id===app.id).ssoRuntimeStatus,'ABNORMAL');
 assert.equal((await user.command('enterApp',{id:app.id})).error.code,'UPSTREAM_UNAVAILABLE');
 state.monitorSamples[0].lastCheckedAt='2026-09-25T00:00:00.000Z';
 assert.equal((await monitor()).ssoStatus,'NORMAL');
 assert.equal((await user.read('apps')).data.find(row=>row.id===app.id).ssoRuntimeStatus,'NORMAL');
 sso.enabled='DISABLED';
 assert.equal((await monitor()).ssoStatus,'DISABLED');
 assert.equal((await user.read('apps')).data.find(row=>row.id===app.id).ssoRuntimeStatus,'DISABLED');
});
