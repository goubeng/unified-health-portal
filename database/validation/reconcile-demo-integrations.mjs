// Reconcile only untouched legacy integration fixtures. Default mode is read-only.
import {fileURLToPath} from 'node:url';
import {resolve} from 'node:path';
import {readFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {createSeed} from '../../src/mock/seed.js';
import {sqlQuery} from '../../server/repository.mjs';

const schema='"pb3gir75kkooyea"';
const entity=`${schema}."portal_runtime_entity"`;
const literal=value=>`'${String(value).replaceAll("'","''")}'`;
const legacyCreatedAt='2026-09-16T00:00:00.000Z';
const legacyUpdatedAt='2026-09-17T23:00:00.000Z';
const protectedId='MOCK_INT_MOCK_APP_1TODO';
const fields=['enabled','runtimeStatus','configStatus'];
const physicalId=fixture=>fixture.kind==='SSO'?`P4FIX_SSO_${fixture.appId}`:`P4FIX_PUSH_${fixture.appId}_${fixture.kind}`;

export const integrationFixtures=createSeed().integrations.map(item=>({
 id:item.id,appId:item.appId,kind:item.kind,
 patch:Object.fromEntries(fields.map(field=>[field,item[field]]))
}));

export function buildIntegrationReadSql(){return `SELECT json_build_object(
 'snapshotVersion',(SELECT version FROM ${schema}."system_config" WHERE id='P4RUN_STATE'),
 'activeApps',(SELECT count(*) FROM ${schema}."application" WHERE deleted_at IS NULL AND runtime_id LIKE 'MOCK_APP_%'),
 'rows',(SELECT coalesce(json_agg(json_build_object('id',runtime_id,'hash',md5(payload::text),'payload',payload) ORDER BY runtime_id),'[]'::json) FROM ${entity} WHERE resource='integrations'),
 'snapshotRows',(SELECT coalesce(json_agg(json_build_object('id',item->>'id','hash',md5(item::text),'payload',item) ORDER BY ord),'[]'::json) FROM ${schema}."system_config" c CROSS JOIN LATERAL jsonb_array_elements(coalesce(c.value::jsonb->'integrations','[]'::jsonb)) WITH ORDINALITY AS items(item,ord) WHERE c.id='P4RUN_STATE'),
 'physicalRows',(SELECT coalesce(json_agg(json_build_object('id',id,'hash',md5(data::text),'row',data) ORDER BY id),'[]'::json) FROM (
  SELECT id,to_jsonb(row) AS data FROM ${schema}."sso_config" row WHERE id LIKE 'P4FIX_%'
  UNION ALL SELECT id,to_jsonb(row) AS data FROM ${schema}."push_integration_config" row WHERE id LIKE 'P4FIX_%'
 ) physical),
 'successfulEdits',(SELECT coalesce(json_agg(json_build_object('objectId',object_id,'appId',application_id) ORDER BY created_at),'[]'::json) FROM ${schema}."audit_event" WHERE event_code IN ('saveIntegration','createAccessProfile') AND result='SUCCESS'),
 'physicalDigest',(SELECT md5(coalesce(string_agg(source||':'||id||':'||data,'|' ORDER BY source,id),'')) FROM (
  SELECT 'SSO' AS source,id,to_jsonb(row)::text AS data FROM ${schema}."sso_config" row WHERE id LIKE 'P4FIX_%'
  UNION ALL SELECT 'PUSH' AS source,id,to_jsonb(row)::text AS data FROM ${schema}."push_integration_config" row WHERE id LIKE 'P4FIX_%'
 ) t)
);`}

const byId=rows=>new Map(rows.map(row=>[row.id,row]));
export function buildIntegrationPlan(input){
 const issues=[],fixtures=byId(integrationFixtures),current=byId(input.rows||[]),snapshot=byId(input.snapshotRows||[]),physical=byId(input.physicalRows||[]),edits=new Set((input.successfulEdits||[]).map(row=>row.objectId));
 if(Number(input.activeApps)!==42)issues.push('活动演示应用不等于 42');
 if(!Number.isSafeInteger(Number(input.snapshotVersion))||Number(input.snapshotVersion)<1)issues.push('兼容快照版本缺失');
 if(fixtures.size!==126||current.size!==126||(input.rows||[]).length!==126)issues.push('接入配置不是唯一的 42×3 完整集合');
 if(snapshot.size!==126||(input.snapshotRows||[]).length!==126)issues.push('兼容快照接入配置不是唯一的 42×3 完整集合');
 if(physical.size!==126||(input.physicalRows||[]).length!==126)issues.push('物理接入配置不是唯一的 42×3 完整集合');
 if(!input.physicalDigest)issues.push('物理接入镜像校验摘要缺失');
 const candidates=[],alreadyApplied=[],protectedRows=[];
 for(const fixture of integrationFixtures){
  const row=current.get(fixture.id),payload=row?.payload,saved=snapshot.get(fixture.id),physicalRow=physical.get(physicalId(fixture));
  if(!row||!payload||payload.id!==fixture.id||payload.appId!==fixture.appId||payload.kind!==fixture.kind){issues.push(`接入键不一致: ${fixture.id}`);continue;}
  if(!saved||saved.hash!==row.hash)issues.push(`兼容快照与运行实体不一致: ${fixture.id}`);
  if(!physicalRow||physicalRow.row.application_id!==`P4FIX_${fixture.appId.replace(/^MOCK_/,'')}`||(fixture.kind!=='SSO'&&physicalRow.row.kind!==fixture.kind))issues.push(`物理接入配置不匹配: ${fixture.id}`);
  if(fixture.id===protectedId){
   if(Number(payload.version)!==2||!edits.has(fixture.id))issues.push(`已编辑接入配置保护证据不一致: ${fixture.id}`);
   protectedRows.push({id:fixture.id,hash:row.hash,snapshotHash:saved?.hash,physicalId:physicalId(fixture),physicalHash:physicalRow?.hash,reason:'成功编辑记录，保持原样'});continue;
  }
  if(edits.has(fixture.id)){issues.push(`其他成功编辑记录不可覆盖: ${fixture.id}`);continue;}
  if(payload.statusSource==='DEMO_FIXTURE'){
   const expectedPhysicalStatus=fixture.patch.enabled==='DISABLED'?'DISABLED':'UNCONFIGURED';
   if(Number(payload.version)!==2||fields.some(field=>payload[field]!==fixture.patch[field])||physicalRow?.row.enabled!==fixture.patch.enabled||physicalRow?.row.status!==expectedPhysicalStatus||Number(physicalRow?.row.version)!==2)issues.push(`已迁移接入配置回读不一致: ${fixture.id}`);
   alreadyApplied.push(fixture.id);continue;
  }
  if(Number(payload.version)!==1||payload.createdAt!==legacyCreatedAt||payload.updatedAt!==legacyUpdatedAt||payload.enabled!=='DISABLED'||payload.runtimeStatus!=null||payload.configStatus!=null||payload.statusSource!=null){
   issues.push(`不是未触碰的旧占位配置: ${fixture.id}`);continue;
  }
  if(!physicalRow||physicalRow.row.enabled!=='DISABLED'||Number(physicalRow.row.version)!==1||!['UNCONFIGURED','DISABLED'].includes(physicalRow.row.status))issues.push(`物理接入配置不是旧占位: ${fixture.id}`);
  if(!row.hash||!saved?.hash||!physicalRow?.hash)issues.push(`接入行摘要缺失: ${fixture.id}`);
  candidates.push({...fixture,hash:row.hash,snapshotHash:saved?.hash,physicalId:physicalId(fixture),physicalHash:physicalRow?.hash,beforeEnabled:payload.enabled});
 }
 if(!((candidates.length===125&&alreadyApplied.length===0)||(candidates.length===0&&alreadyApplied.length===125))||protectedRows.length!==1)issues.push(`预期迁移前 125 / 迁移后 125，实际待迁移 ${candidates.length} / 已迁移 ${alreadyApplied.length} / 保护 ${protectedRows.length}`);
 return {safe:issues.length===0,issues,snapshotVersion:Number(input.snapshotVersion),physicalDigest:input.physicalDigest,candidates,alreadyApplied,protectedRows};
}

export function buildIntegrationApplySql(plan){
 if(!plan.safe||plan.candidates.length!==125||plan.protectedRows.length!==1)throw new Error('只允许由安全预览生成接入配置事务');
 const fixtureSql=literal(JSON.stringify(plan.candidates.map(row=>({id:row.id,hash:row.hash,snapshot_hash:row.snapshotHash,physical_id:row.physicalId,physical_hash:row.physicalHash,kind:row.kind,patch:{...row.patch,statusSource:'DEMO_FIXTURE'}}))));
 const protectedRow=plan.protectedRows[0],stamp=`to_char(now() AT TIME ZONE 'utc','YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')`;
 return `BEGIN;
SELECT pg_advisory_xact_lock(38013800);
CREATE TEMP TABLE demo_integration_plan ON COMMIT DROP AS SELECT * FROM jsonb_to_recordset(${fixtureSql}::jsonb) AS f(id text,hash text,snapshot_hash text,physical_id text,physical_hash text,kind text,patch jsonb);
DO $$ DECLARE changed integer; BEGIN
 IF (SELECT version FROM ${schema}."system_config" WHERE id='P4RUN_STATE') IS DISTINCT FROM ${plan.snapshotVersion} THEN RAISE EXCEPTION 'STALE_RUNTIME_SNAPSHOT'; END IF;
 IF EXISTS(SELECT 1 FROM ${schema}."audit_event" WHERE event_code IN ('saveIntegration','createAccessProfile') AND result='SUCCESS' AND object_id IN (SELECT id FROM demo_integration_plan)) THEN RAISE EXCEPTION 'INTEGRATION_EDITED'; END IF;
 IF (SELECT count(*) FROM ${entity} e JOIN demo_integration_plan f ON e.resource='integrations' AND e.runtime_id=f.id AND md5(e.payload::text)=f.hash) <> 125 THEN RAISE EXCEPTION 'STALE_INTEGRATION_ROWS'; END IF;
 IF (SELECT count(*) FROM ${schema}."system_config" c CROSS JOIN LATERAL jsonb_array_elements(c.value::jsonb->'integrations') item JOIN demo_integration_plan f ON item->>'id'=f.id AND md5(item::text)=f.snapshot_hash WHERE c.id='P4RUN_STATE') <> 125 THEN RAISE EXCEPTION 'STALE_SNAPSHOT_INTEGRATIONS'; END IF;
 IF (SELECT count(*) FROM ${schema}."sso_config" p JOIN demo_integration_plan f ON p.id=f.physical_id AND md5(to_jsonb(p)::text)=f.physical_hash WHERE f.kind='SSO') <> (SELECT count(*) FROM demo_integration_plan WHERE kind='SSO') THEN RAISE EXCEPTION 'STALE_SSO_CONFIG'; END IF;
 IF (SELECT count(*) FROM ${schema}."push_integration_config" p JOIN demo_integration_plan f ON p.id=f.physical_id AND md5(to_jsonb(p)::text)=f.physical_hash WHERE f.kind IN ('TODO','MESSAGE')) <> (SELECT count(*) FROM demo_integration_plan WHERE kind IN ('TODO','MESSAGE')) THEN RAISE EXCEPTION 'STALE_PUSH_CONFIG'; END IF;
 IF NOT EXISTS(SELECT 1 FROM ${entity} e WHERE e.resource='integrations' AND e.runtime_id=${literal(protectedRow.id)} AND md5(e.payload::text)=${literal(protectedRow.hash)}) THEN RAISE EXCEPTION 'PROTECTED_RUNTIME_CHANGED'; END IF;
 IF NOT EXISTS(SELECT 1 FROM ${schema}."system_config" c CROSS JOIN LATERAL jsonb_array_elements(c.value::jsonb->'integrations') item WHERE c.id='P4RUN_STATE' AND item->>'id'=${literal(protectedRow.id)} AND md5(item::text)=${literal(protectedRow.snapshotHash)}) THEN RAISE EXCEPTION 'PROTECTED_SNAPSHOT_CHANGED'; END IF;
 IF NOT EXISTS(SELECT 1 FROM ${schema}."push_integration_config" p WHERE p.id=${literal(protectedRow.physicalId)} AND md5(to_jsonb(p)::text)=${literal(protectedRow.physicalHash)}) THEN RAISE EXCEPTION 'PROTECTED_PHYSICAL_CHANGED'; END IF;
 UPDATE ${entity} e SET payload=e.payload||f.patch||jsonb_build_object('version',2,'updatedAt',${stamp}),updated_at=now() FROM demo_integration_plan f WHERE e.resource='integrations' AND e.runtime_id=f.id AND md5(e.payload::text)=f.hash;
 GET DIAGNOSTICS changed=ROW_COUNT; IF changed<>125 THEN RAISE EXCEPTION 'RUNTIME_UPDATE_COUNT'; END IF;
 UPDATE ${schema}."sso_config" p SET enabled=f.patch->>'enabled',status=CASE WHEN f.patch->>'enabled'='DISABLED' THEN 'DISABLED' ELSE 'UNCONFIGURED' END,version=version+1,updated_at=now() FROM demo_integration_plan f WHERE f.kind='SSO' AND p.id=f.physical_id AND md5(to_jsonb(p)::text)=f.physical_hash;
 GET DIAGNOSTICS changed=ROW_COUNT; IF changed<>(SELECT count(*) FROM demo_integration_plan WHERE kind='SSO') THEN RAISE EXCEPTION 'SSO_UPDATE_COUNT'; END IF;
 UPDATE ${schema}."push_integration_config" p SET enabled=f.patch->>'enabled',status=CASE WHEN f.patch->>'enabled'='DISABLED' THEN 'DISABLED' ELSE 'UNCONFIGURED' END,version=version+1,updated_at=now() FROM demo_integration_plan f WHERE f.kind IN ('TODO','MESSAGE') AND p.id=f.physical_id AND md5(to_jsonb(p)::text)=f.physical_hash;
 GET DIAGNOSTICS changed=ROW_COUNT; IF changed<>(SELECT count(*) FROM demo_integration_plan WHERE kind IN ('TODO','MESSAGE')) THEN RAISE EXCEPTION 'PUSH_UPDATE_COUNT'; END IF;
 UPDATE ${schema}."system_config" c SET value=jsonb_set(c.value::jsonb,'{integrations}',(SELECT jsonb_agg(CASE WHEN f.id IS NULL THEN item ELSE item||f.patch||jsonb_build_object('version',2,'updatedAt',${stamp}) END ORDER BY ord) FROM jsonb_array_elements(c.value::jsonb->'integrations') WITH ORDINALITY AS items(item,ord) LEFT JOIN demo_integration_plan f ON f.id=item->>'id'))::text,version=version+1,updated_at=now() WHERE c.id='P4RUN_STATE' AND c.version=${plan.snapshotVersion};
 GET DIAGNOSTICS changed=ROW_COUNT; IF changed<>1 THEN RAISE EXCEPTION 'SNAPSHOT_UPDATE_COUNT'; END IF;
END $$;
SELECT json_build_object('snapshotVersion',(SELECT version FROM ${schema}."system_config" WHERE id='P4RUN_STATE'),'patched',(SELECT count(*) FROM ${entity} WHERE resource='integrations' AND payload->>'statusSource'='DEMO_FIXTURE'));
COMMIT;`;
}

if(process.argv[1]&&fileURLToPath(import.meta.url)===resolve(process.argv[1])){
 const input=JSON.parse(await sqlQuery(buildIntegrationReadSql()));
 const plan=buildIntegrationPlan(input);
 console.log(JSON.stringify({mode:'preview',safe:plan.safe,issues:plan.issues,snapshotVersion:plan.snapshotVersion,activeApps:input.activeApps,integrationRows:input.rows.length,patchable:plan.candidates.length,alreadyApplied:plan.alreadyApplied.length,protected:plan.protectedRows,targetStates:Object.fromEntries(['NORMAL','ABNORMAL','UNCONFIGURED','DISABLED'].map(status=>[status,plan.candidates.filter(row=>row.patch.runtimeStatus===status).length])),currentStates:Object.fromEntries(['NORMAL','ABNORMAL','UNCONFIGURED','DISABLED'].map(status=>[status,input.rows.filter(row=>row.payload.runtimeStatus===status).length]))},null,2));
 if(process.argv.includes('--apply')){
  if(plan.safe&&plan.alreadyApplied.length===125){console.log(JSON.stringify({mode:'apply',updated:0,reason:'125 条已迁移且三层回读一致'}));process.exit(0);}
  const backupPath=process.argv.find(arg=>arg.startsWith('--backup-file='))?.slice(14);
  const expectedHash=process.argv.find(arg=>arg.startsWith('--backup-sha256='))?.slice(16)?.toUpperCase();
  if(!plan.safe||!backupPath||!expectedHash)throw new Error('执行前须安全预览及指定已验证备份路径和 SHA256');
  const actualHash=createHash('sha256').update(readFileSync(resolve(backupPath))).digest('hex').toUpperCase();
  if(actualHash!==expectedHash)throw new Error('备份 SHA256 不一致，拒绝执行');
  console.log(JSON.stringify({mode:'apply',result:await sqlQuery(buildIntegrationApplySql(plan))}));
 }
}
