// Surgical, guarded update for three untouched demonstration integration states.
// Preview is read-only; --apply requires a verified full-schema backup.
import {readFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {fileURLToPath} from 'node:url';
import {resolve} from 'node:path';
import {sqlQuery} from '../../server/repository.mjs';

const schema='"pb3gir75kkooyea"';
const entity=`${schema}."portal_runtime_entity"`;
const snapshot=`${schema}."system_config"`;
const targets=[
 {appId:'MOCK_APP_18',kind:'TODO',id:'MOCK_INT_MOCK_APP_18TODO',physicalId:'P4FIX_PUSH_MOCK_APP_18_TODO'},
 {appId:'MOCK_APP_19',kind:'SSO',id:'MOCK_INT_MOCK_APP_19SSO',physicalId:'P4FIX_SSO_MOCK_APP_19'},
 {appId:'MOCK_APP_21',kind:'MESSAGE',id:'MOCK_INT_MOCK_APP_21MESSAGE',physicalId:'P4FIX_PUSH_MOCK_APP_21_MESSAGE'}
];
const literal=value=>`'${String(value).replaceAll("'","''")}'`;
const targetIds=targets.map(row=>literal(row.id)).join(',');
const physicalIds=targets.map(row=>literal(row.physicalId)).join(',');

export const previewSql=`SELECT json_build_object(
 'version',(SELECT version FROM ${snapshot} WHERE id='P4RUN_STATE'),
 'snapshotHash',(SELECT md5(value::jsonb::text) FROM ${snapshot} WHERE id='P4RUN_STATE'),
 'entities',(SELECT coalesce(json_agg(json_build_object('id',runtime_id,'hash',md5(payload::text),'payload',payload)),'[]'::json) FROM ${entity} WHERE resource='integrations' AND runtime_id IN (${targetIds})),
 'snapshotRows',(SELECT coalesce(json_agg(json_build_object('id',item->>'id','hash',md5(item::text),'payload',item)),'[]'::json) FROM ${snapshot} c CROSS JOIN LATERAL jsonb_array_elements(c.value::jsonb->'integrations') item WHERE c.id='P4RUN_STATE' AND item->>'id' IN (${targetIds})),
 'physical',(SELECT coalesce(json_agg(json_build_object('id',id,'hash',md5(data::text),'row',data)),'[]'::json) FROM (SELECT id,to_jsonb(p) data FROM ${schema}."sso_config" p WHERE id IN (${physicalIds}) UNION ALL SELECT id,to_jsonb(p) data FROM ${schema}."push_integration_config" p WHERE id IN (${physicalIds})) t),
 'apps',(SELECT coalesce(json_agg(json_build_object('id',runtime_id,'status',status,'version',version,'updatedAt',updated_at)),'[]'::json) FROM ${schema}."application" WHERE runtime_id IN ('MOCK_APP_18','MOCK_APP_19','MOCK_APP_21') AND deleted_at IS NULL),
 'edits',(SELECT count(*) FROM ${schema}."audit_event" WHERE event_code IN ('saveIntegration','createAccessProfile') AND result='SUCCESS' AND object_id IN (${targetIds})),
 'dependencies',(SELECT json_build_object('todos',(SELECT count(*) FROM ${schema}."todo_item" WHERE application_id IN ('P4FIX_APP_18','P4FIX_APP_19','P4FIX_APP_21')),'messages',(SELECT count(*) FROM ${schema}."message" WHERE application_id IN ('P4FIX_APP_18','P4FIX_APP_19','P4FIX_APP_21')),'mappings',(SELECT count(*) FROM ${schema}."application_user_mapping" WHERE application_id IN ('P4FIX_APP_18','P4FIX_APP_19','P4FIX_APP_21')),'requests',(SELECT count(*) FROM ${schema}."application_access_request" WHERE application_id IN ('P4FIX_APP_18','P4FIX_APP_19','P4FIX_APP_21')),'grants',(SELECT count(*) FROM ${schema}."application_access_grant" WHERE application_id IN ('P4FIX_APP_18','P4FIX_APP_19','P4FIX_APP_21'))))
);`;

const indexed=rows=>new Map(rows.map(row=>[row.id,row]));
export function validate(input){
 const issues=[],entities=indexed(input.entities||[]),saved=indexed(input.snapshotRows||[]),physical=indexed(input.physical||[]);
 if(!Number.isSafeInteger(input.version)||input.version<1||!input.snapshotHash)issues.push('运行态版本或摘要缺失');
 if(entities.size!==3||saved.size!==3||physical.size!==3||(input.apps||[]).length!==3)issues.push('目标三层行数量不完整');
 if(Number(input.edits)!==0)issues.push('目标存在成功人工编辑审计');
 if(Object.values(input.dependencies||{}).some(count=>Number(count)!==0))issues.push('目标应用存在业务依赖');
 if((input.apps||[]).some(row=>row.status!=='ENABLED'||Number(row.version)!==1))issues.push('目标应用已编辑或停用');
 let changed=0;
 for(const target of targets){
  const live=entities.get(target.id),row=live?.payload,old=saved.get(target.id),mirror=physical.get(target.physicalId);
  if(!row||!old||!mirror){issues.push(`目标缺失：${target.id}`);continue;}
  if(live.hash!==old.hash||JSON.stringify(row)!==JSON.stringify(old.payload))issues.push(`运行实体与快照不一致：${target.id}`);
  if(row.id!==target.id||row.appId!==target.appId||row.kind!==target.kind||row.statusSource!=='DEMO_FIXTURE'||row.enabled!=='ENABLED'||row.configStatus!=='CONFIGURED')issues.push(`目标不是受控演示配置：${target.id}`);
  if(mirror.row.application_id!==`P4FIX_${target.appId.slice(5)}`||mirror.row.enabled!=='ENABLED'||mirror.row.status!=='UNCONFIGURED'||Number(mirror.row.version)!==Number(row.version))issues.push(`物理配置镜像不匹配：${target.id}`);
  if(row.runtimeStatus==='ABNORMAL'&&Number(row.version)===2)changed++;
  else if(row.runtimeStatus==='NORMAL'&&Number(row.version)===3){}
  else issues.push(`目标运行态或版本不符合幂等门禁：${target.id}`);
 }
 if(changed!==0&&changed!==3)issues.push('部分目标已更新，拒绝混合重跑');
 return {safe:issues.length===0,issues,changed,version:input.version,snapshotHash:input.snapshotHash,entities,saved,physical};
}

export function applySql(plan){
 if(!plan.safe||plan.changed!==3)throw new Error('只允许完整的三目标预览生成写入事务');
 const records=targets.map(target=>({id:target.id,kind:target.kind,entityHash:plan.entities.get(target.id).hash,snapshotHash:plan.saved.get(target.id).hash,physicalId:target.physicalId,physicalHash:plan.physical.get(target.physicalId).hash}));
 const stamp=`to_char(now() AT TIME ZONE 'utc','YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')`;
 return `BEGIN;
SELECT pg_advisory_xact_lock(38013800);
CREATE TEMP TABLE normal_demo_targets ON COMMIT DROP AS SELECT * FROM jsonb_to_recordset(${literal(JSON.stringify(records))}::jsonb) AS x(id text,kind text,"entityHash" text,"snapshotHash" text,"physicalId" text,"physicalHash" text);
DO $$ DECLARE changed integer; BEGIN
 IF NOT EXISTS(SELECT 1 FROM ${snapshot} WHERE id='P4RUN_STATE' AND version=${plan.version} AND md5(value::jsonb::text)=${literal(plan.snapshotHash)} FOR UPDATE) THEN RAISE EXCEPTION 'STALE_RUNTIME_SNAPSHOT'; END IF;
 IF EXISTS(SELECT 1 FROM ${schema}."audit_event" WHERE event_code IN ('saveIntegration','createAccessProfile') AND result='SUCCESS' AND object_id IN (${targetIds})) THEN RAISE EXCEPTION 'INTEGRATION_EDITED'; END IF;
 IF (SELECT count(*) FROM ${entity} e JOIN normal_demo_targets p ON e.resource='integrations' AND e.runtime_id=p.id AND md5(e.payload::text)=p."entityHash" AND e.payload->>'runtimeStatus'='ABNORMAL' AND (e.payload->>'version')::int=2)<>3 THEN RAISE EXCEPTION 'STALE_INTEGRATION_ENTITIES'; END IF;
 IF (SELECT count(*) FROM ${snapshot} c CROSS JOIN LATERAL jsonb_array_elements(c.value::jsonb->'integrations') item JOIN normal_demo_targets p ON item->>'id'=p.id AND md5(item::text)=p."snapshotHash" WHERE c.id='P4RUN_STATE')<>3 THEN RAISE EXCEPTION 'STALE_SNAPSHOT_ROWS'; END IF;
 IF (SELECT count(*) FROM ${schema}."sso_config" m JOIN normal_demo_targets p ON m.id=p."physicalId" AND md5(to_jsonb(m)::text)=p."physicalHash" WHERE p.kind='SSO')<>1 THEN RAISE EXCEPTION 'STALE_SSO_MIRROR'; END IF;
 IF (SELECT count(*) FROM ${schema}."push_integration_config" m JOIN normal_demo_targets p ON m.id=p."physicalId" AND md5(to_jsonb(m)::text)=p."physicalHash" WHERE p.kind<>'SSO')<>2 THEN RAISE EXCEPTION 'STALE_PUSH_MIRROR'; END IF;
 UPDATE ${entity} e SET payload=e.payload||jsonb_build_object('runtimeStatus','NORMAL','version',3,'updatedAt',${stamp}),updated_at=now() FROM normal_demo_targets p WHERE e.resource='integrations' AND e.runtime_id=p.id AND md5(e.payload::text)=p."entityHash";
 GET DIAGNOSTICS changed=ROW_COUNT; IF changed<>3 THEN RAISE EXCEPTION 'ENTITY_WRITE_COUNT'; END IF;
 UPDATE ${schema}."sso_config" m SET version=version+1,updated_at=now() FROM normal_demo_targets p WHERE p.kind='SSO' AND m.id=p."physicalId" AND md5(to_jsonb(m)::text)=p."physicalHash";
 GET DIAGNOSTICS changed=ROW_COUNT; IF changed<>1 THEN RAISE EXCEPTION 'SSO_WRITE_COUNT'; END IF;
 UPDATE ${schema}."push_integration_config" m SET version=version+1,updated_at=now() FROM normal_demo_targets p WHERE p.kind<>'SSO' AND m.id=p."physicalId" AND md5(to_jsonb(m)::text)=p."physicalHash";
 GET DIAGNOSTICS changed=ROW_COUNT; IF changed<>2 THEN RAISE EXCEPTION 'PUSH_WRITE_COUNT'; END IF;
 UPDATE ${snapshot} c SET value=jsonb_set(c.value::jsonb,'{integrations}',(SELECT jsonb_agg(CASE WHEN p.id IS NULL THEN item ELSE item||jsonb_build_object('runtimeStatus','NORMAL','version',3,'updatedAt',${stamp}) END ORDER BY ord) FROM jsonb_array_elements(c.value::jsonb->'integrations') WITH ORDINALITY AS items(item,ord) LEFT JOIN normal_demo_targets p ON p.id=item->>'id'))::text,version=version+1,updated_at=now() WHERE c.id='P4RUN_STATE' AND c.version=${plan.version};
 GET DIAGNOSTICS changed=ROW_COUNT; IF changed<>1 THEN RAISE EXCEPTION 'SNAPSHOT_WRITE_COUNT'; END IF;
END $$;
COMMIT;`;
}

if(process.argv[1]&&fileURLToPath(import.meta.url)===resolve(process.argv[1])){
 const input=JSON.parse(await sqlQuery(previewSql));
 const plan=validate(input);
 console.log(JSON.stringify({mode:'preview',safe:plan.safe,issues:plan.issues,version:plan.version,snapshotHash:plan.snapshotHash,pending:plan.changed,targets:targets.map(row=>({appId:row.appId,kind:row.kind,id:row.id}))},null,2));
 if(process.argv.includes('--apply')){
  if(!plan.safe)throw new Error('安全预览不通过，禁止写入');
  if(plan.changed===0){console.log(JSON.stringify({mode:'apply',updated:0,reason:'三项目标已是正常状态'}));process.exit(0);}
  const backup=process.argv.find(arg=>arg.startsWith('--backup-file='))?.slice(14);
  const expected=process.argv.find(arg=>arg.startsWith('--backup-sha256='))?.slice(16)?.toUpperCase();
  if(!backup||!expected)throw new Error('必须提供完整 schema 备份路径及 SHA256');
  const actual=createHash('sha256').update(readFileSync(resolve(backup))).digest('hex').toUpperCase();
  if(actual!==expected)throw new Error('备份 SHA256 不匹配，拒绝写入');
  await sqlQuery(applySql(plan));
  const after=validate(JSON.parse(await sqlQuery(previewSql)));
  if(!after.safe||after.changed!==0||after.version!==plan.version+1)throw new Error('事务已提交，但写后读回未满足三层门禁');
  console.log(JSON.stringify({mode:'apply',updated:3,version:after.version,backup:resolve(backup)}));
 }
}
