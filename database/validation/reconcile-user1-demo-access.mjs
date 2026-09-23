// Scoped, reversible reconciliation of the original USER_1 demo access states.
// Default is read-only. --apply is reserved for review after a fresh backup.
import {fileURLToPath} from 'node:url';
import {resolve} from 'node:path';
import {createSeed} from '../../src/mock/seed.js';
import {createRepository,sqlQuery} from '../../server/repository.mjs';
import {createPortalService} from '../../src/services/portal.js';

const s='"pb3gir75kkooyea"';
const lit=value=>value==null?'NULL':`'${String(value).replaceAll("'","''")}'`;
const json=value=>`${lit(JSON.stringify(value))}::jsonb`;
const physical=id=>'P4FIX_'+id.replace(/^MOCK_/,'');
const targetNumbers=[2,3,4,5,6,11,12,24,25,26,28,33];
const oldNumbers=[2,3,4,5,6,11,12,26,28];
const removedNumbers=[2,3,4,5,6];
const downgradedNumbers=[11,12];
const upgradedNumbers=[26,28];
const addedNumbers=[24,25,33];
const oldStatuses={2:'BOUND',3:'BOUND',4:'BOUND',5:'BOUND',6:'BOUND',11:'BOUND',12:'BOUND',26:'FAILED',28:'CONFLICT'};
const appId=n=>`MOCK_APP_${n}`;
const mapId=n=>`MOCK_MAP_MOCK_USER_1_${n}`;
const scopeId=n=>`P4FIX_SCOPE_${mapId(n)}`;
const exceptionId=n=>`P4FIX_EXCEPTION_${mapId(n)}`;
const todoIds=[1,2,3,4,5,6,7].map(n=>`MOCK_TODO_0_${n}`);
const messageIds=[1,2,3,4,5,6,7].map(n=>`MOCK_MSG_0_${n}`);
const archiveKey=(resource,id)=>`USER1_DEMO_RESTORE_${resource}_${id}`;
const list=items=>items.map(lit).join(',');

export const targetAppIds=targetNumbers.map(appId);
export const archiveTodoIds=todoIds;
export const archiveMessageIds=messageIds;

export const buildReadSql=()=>`SELECT json_build_object(
 'runtimeMappings',(SELECT coalesce(json_agg(json_build_object('id',runtime_id,'hash',md5(payload::text),'payload',payload)),'[]'::json) FROM ${s}."portal_runtime_entity" WHERE resource='mappings' AND runtime_id IN (${list(targetNumbers.map(mapId))})),
 'physicalMappings',(SELECT coalesce(json_agg(json_build_object('id',id,'hash',md5(to_jsonb(m)::text),'row',to_jsonb(m))),'[]'::json) FROM ${s}."application_user_mapping" m WHERE user_id='P4FIX_USER_1' AND application_id IN (${list(targetNumbers.map(n=>physical(appId(n))))})),
 'snapshotMappings',(SELECT coalesce(json_agg(json_build_object('id',item->>'id','hash',md5(item::text),'payload',item)),'[]'::json) FROM ${s}."system_config" c CROSS JOIN LATERAL jsonb_array_elements(coalesce(c.value::jsonb->'mappings','[]'::jsonb)) item WHERE c.id='P4RUN_STATE' AND item->>'id' IN (${list(oldNumbers.map(mapId))})),
 'scopes',(SELECT coalesce(json_agg(json_build_object('id',id,'hash',md5(to_jsonb(r)::text),'row',to_jsonb(r))),'[]'::json) FROM ${s}."portal_user_application_scope" r WHERE user_id='P4FIX_USER_1' AND application_id IN (${list(targetNumbers.map(n=>physical(appId(n))))})),
 'exceptions',(SELECT coalesce(json_agg(json_build_object('id',id,'hash',md5(to_jsonb(e)::text),'row',to_jsonb(e))),'[]'::json) FROM ${s}."mapping_exception" e WHERE mapping_id IN (${list(targetNumbers.map(n=>physical(mapId(n))))})),
 'todos',(SELECT coalesce(json_agg(json_build_object('id',id,'hash',md5(to_jsonb(t)::text),'row',to_jsonb(t))),'[]'::json) FROM ${s}."todo_item" t WHERE target_user_id='P4FIX_USER_1' AND application_id IN (${list(downgradedNumbers.concat(removedNumbers).map(n=>physical(appId(n))))})),
 'messages',(SELECT coalesce(json_agg(json_build_object('id',m.id,'hash',md5(to_jsonb(m)::text||to_jsonb(r)::text),'message',to_jsonb(m),'recipient',to_jsonb(r))),'[]'::json) FROM ${s}."message" m JOIN ${s}."message_recipient" r ON r.message_id=m.id WHERE r.user_id='P4FIX_USER_1' AND m.application_id IN (${list(downgradedNumbers.concat(removedNumbers).map(n=>physical(appId(n))))})),
 'mappingAudit',(SELECT count(*) FROM ${s}."audit_event" a WHERE a.event_code IN ('bind','unbind','resolveMapping','startApplicationAccountBinding','verifyBindingOtp','verifyBindingBySubsystemCredential','verifyBindingByUpstreamReauth','approveBindingReview','rejectBindingReview') AND (a.object_id IN (${list(oldNumbers.map(mapId))}) OR (a.actor_user_id='P4FIX_USER_1' AND a.application_id IN (${list(targetNumbers.map(n=>physical(appId(n))))})))),
 'existingArchives',(SELECT count(*) FROM ${s}."portal_demo_restore_archive" WHERE archive_key LIKE 'USER1_DEMO_RESTORE_%')
);`;

const byId=rows=>new Map(rows.map(row=>[row.id,row]));
const serviceApps=async(state)=>{
 const actor=state.users.find(user=>user.id==='MOCK_USER_1');
 const response=await createPortalService({kind:'mock',read:()=>state},()=>actor).read('apps');
 if(!response.ok)throw new Error(response.error.message);
 return byId(response.data);
};

export async function buildPlan(dbState,seedState,physicalState){
 const issues=[],runtime=byId(physicalState.runtimeMappings),current=byId(physicalState.physicalMappings),snapshot=byId(physicalState.snapshotMappings),scopes=byId(physicalState.scopes),exceptions=byId(physicalState.exceptions);
 for(const n of oldNumbers){
  const id=mapId(n),r=runtime.get(id),p=current.get(physical(id)),h=snapshot.get(id),expected=oldStatuses[n];
  if(!r||!p||!h||r.hash!==h.hash||r.payload.status!==expected||Number(r.payload.version)!==1||p.row.status!==expected||Number(p.row.version)!==1||p.row.user_id!=='P4FIX_USER_1'||p.row.application_id!==physical(appId(n)))issues.push(`映射基线不一致: ${id}`);
  const scope=scopes.get(scopeId(n));
  if(expected==='BOUND'&&(!scope||Number(scope.row.version)!==1))issues.push(`原授权范围缺失/变更: ${id}`);
  if(expected!=='BOUND'&&scope)issues.push(`异常映射意外存在授权范围: ${id}`);
 }
 for(const n of addedNumbers)if(runtime.has(mapId(n))||current.has(physical(mapId(n)))||scopes.has(scopeId(n)))issues.push(`新增映射目标非空: ${mapId(n)}`);
 for(const n of downgradedNumbers)if(exceptions.has(exceptionId(n)))issues.push(`待建异常已存在: ${mapId(n)}`);
 for(const n of upgradedNumbers)if(exceptions.get(exceptionId(n))?.row.resolution_status!=='OPEN')issues.push(`原异常不是 OPEN: ${mapId(n)}`);
 const pending=physicalState.todos.filter(row=>row.row.status==='PENDING'&&row.row.archived_at==null),visible=physicalState.messages.filter(row=>row.recipient.deleted_at==null);
 if(pending.length!==7||new Set(pending.map(row=>row.row.runtime_id)).size!==7||pending.some(row=>!todoIds.includes(row.row.runtime_id)))issues.push('待归档 PENDING 待办不等于精确 7 ID');
 if(visible.length!==7||new Set(visible.map(row=>row.message.runtime_id)).size!==7||visible.some(row=>!messageIds.includes(row.message.runtime_id)))issues.push('待归档可见消息不等于精确 7 ID');
 if(Number(physicalState.mappingAudit)!==0)issues.push('目标映射有后续操作审计');
 if(Number(physicalState.existingArchives)!==0)issues.push('该修复批次已有归档，拒绝重复执行');
 const dbApps=await serviceApps(dbState),seedApps=await serviceApps(seedState),accessDiff=targetAppIds.map(id=>({
  appId:id,before:[dbApps.get(id)?.accessState,dbApps.get(id)?.primaryAction],expected:[seedApps.get(id)?.accessState,seedApps.get(id)?.primaryAction]
 }));
 const simulated=structuredClone(dbState);
 simulated.mappings=simulated.mappings.filter(row=>row.userId!=='MOCK_USER_1').concat(seedState.mappings.filter(row=>row.userId==='MOCK_USER_1'&&targetAppIds.includes(row.appId)),dbState.mappings.filter(row=>row.userId==='MOCK_USER_1'&&!targetAppIds.includes(row.appId)));
 const predicted=await serviceApps(simulated);
 for(const row of accessDiff)if(JSON.stringify([predicted.get(row.appId)?.accessState,predicted.get(row.appId)?.primaryAction])!==JSON.stringify(row.expected))issues.push(`预测访问状态不等于 seed: ${row.appId}`);
 return {safe:issues.length===0,issues,accessDiff,archiveTodos:pending.map(row=>row.row.runtime_id),archiveMessages:visible.map(row=>row.message.runtime_id),physical:physicalState};
}

const guard=(table,id,hash,extra='')=>`IF NOT EXISTS(SELECT 1 FROM ${s}."${table}" row WHERE row.id=${lit(id)} AND md5(to_jsonb(row)::text)=${lit(hash)} ${extra}) THEN RAISE EXCEPTION 'Stale ${table}: ${id}'; END IF;`;
const archive=(resource,id,select)=>`INSERT INTO ${s}."portal_demo_restore_archive"(archive_key,resource,runtime_id,original_payload,reason) ${select};`;
const stamp=`to_char(now() AT TIME ZONE 'utc','YYYY-MM-DD"T"HH24:MI:SS.MS"Z"')`;

export function buildTransactionSql(plan,seedState=createSeed()){
 if(!plan.safe)throw new Error('预览存在阻碍，不生成写入 SQL: '+plan.issues.join('; '));
 const p=plan.physical,runtime=byId(p.runtimeMappings),mapping=byId(p.physicalMappings),snapshot=byId(p.snapshotMappings),scopes=byId(p.scopes),exceptions=byId(p.exceptions),todos=byId(p.todos),messages=byId(p.messages);
 const checks=[],changes=[];
 for(const n of oldNumbers){const id=mapId(n),pid=physical(id);checks.push(guard('application_user_mapping',pid,mapping.get(pid).hash));checks.push(`IF NOT EXISTS(SELECT 1 FROM ${s}."portal_runtime_entity" WHERE resource='mappings' AND runtime_id=${lit(id)} AND md5(payload::text)=${lit(runtime.get(id).hash)}) THEN RAISE EXCEPTION 'Stale runtime mapping: ${id}'; END IF;`);checks.push(`IF NOT EXISTS(SELECT 1 FROM ${s}."system_config" c CROSS JOIN LATERAL jsonb_array_elements(c.value::jsonb->'mappings') item WHERE c.id='P4RUN_STATE' AND item->>'id'=${lit(id)} AND md5(item::text)=${lit(snapshot.get(id).hash)}) THEN RAISE EXCEPTION 'Stale snapshot mapping: ${id}'; END IF;`);}
 for(const n of [...removedNumbers,...downgradedNumbers])checks.push(guard('portal_user_application_scope',scopeId(n),scopes.get(scopeId(n)).hash));
 for(const n of upgradedNumbers)checks.push(guard('mapping_exception',exceptionId(n),exceptions.get(exceptionId(n)).hash));
 for(const id of todoIds)checks.push(guard('todo_item',physical(id),todos.get(physical(id)).hash));
 for(const id of messageIds){const row=messages.get(physical(id));checks.push(`IF NOT EXISTS(SELECT 1 FROM ${s}."message" m JOIN ${s}."message_recipient" r ON r.message_id=m.id WHERE m.id=${lit(physical(id))} AND r.user_id='P4FIX_USER_1' AND md5(to_jsonb(m)::text||to_jsonb(r)::text)=${lit(row.hash)}) THEN RAISE EXCEPTION 'Stale message: ${id}'; END IF;`);}
 checks.push(`IF EXISTS(SELECT 1 FROM ${s}."audit_event" a WHERE a.event_code IN ('bind','unbind','resolveMapping','startApplicationAccountBinding','verifyBindingOtp','verifyBindingBySubsystemCredential','verifyBindingByUpstreamReauth','approveBindingReview','rejectBindingReview') AND (a.object_id IN (${list(oldNumbers.map(mapId))}) OR (a.actor_user_id='P4FIX_USER_1' AND a.application_id IN (${list(targetNumbers.map(n=>physical(appId(n))))}))) ) THEN RAISE EXCEPTION 'Mapping audit changed'; END IF;`);
 checks.push(`IF EXISTS(SELECT 1 FROM ${s}."portal_demo_restore_archive" WHERE archive_key LIKE 'USER1_DEMO_RESTORE_%') THEN RAISE EXCEPTION 'Archive already exists'; END IF;`);
 for(const n of addedNumbers)checks.push(`IF EXISTS(SELECT 1 FROM ${s}."application_user_mapping" WHERE user_id='P4FIX_USER_1' AND application_id=${lit(physical(appId(n)))}) OR EXISTS(SELECT 1 FROM ${s}."portal_runtime_entity" WHERE resource='mappings' AND runtime_id=${lit(mapId(n))}) THEN RAISE EXCEPTION 'Added mapping already exists: ${n}'; END IF;`);
 changes.push(...todoIds.map(id=>archive('todo',id,`SELECT ${lit(archiveKey('todo',id))},'todo',${lit(id)},jsonb_build_object('todo',to_jsonb(t)),'Restore original demo access' FROM ${s}."todo_item" t WHERE t.id=${lit(physical(id))}`)));
 changes.push(`UPDATE ${s}."todo_item" SET archived_at=now(),updated_at=now(),version=version+1 WHERE id IN (${list(todoIds.map(physical))});`);
 for(const id of messageIds){changes.push(archive('message',id,`SELECT ${lit(archiveKey('message',id))},'message',${lit(id)},jsonb_build_object('message',to_jsonb(m),'recipient',to_jsonb(r)),'Restore original demo access' FROM ${s}."message" m JOIN ${s}."message_recipient" r ON r.message_id=m.id WHERE m.id=${lit(physical(id))} AND r.user_id='P4FIX_USER_1'`));}
 changes.push(`UPDATE ${s}."message_recipient" SET deleted_at=now(),updated_at=now(),version=version+1 WHERE user_id='P4FIX_USER_1' AND message_id IN (${list(messageIds.map(physical))});`);
 for(const n of oldNumbers){const id=mapId(n);changes.push(archive('mapping',id,`SELECT ${lit(archiveKey('mapping',id))},'mapping',${lit(id)},jsonb_build_object('runtime',e.payload,'physical',to_jsonb(m)),'Restore original demo access' FROM ${s}."portal_runtime_entity" e JOIN ${s}."application_user_mapping" m ON m.id=${lit(physical(id))} WHERE e.resource='mappings' AND e.runtime_id=${lit(id)}`));}
 for(const n of [...removedNumbers,...downgradedNumbers]){const id=scopeId(n);changes.push(archive('scope',id,`SELECT ${lit(archiveKey('scope',id))},'scope',${lit(id)},jsonb_build_object('scope',to_jsonb(r)),'Restore original demo access' FROM ${s}."portal_user_application_scope" r WHERE r.id=${lit(id)}`));changes.push(`DELETE FROM ${s}."portal_user_application_scope" WHERE id=${lit(id)};`);}
 for(const n of removedNumbers){changes.push(`DELETE FROM ${s}."portal_runtime_entity" WHERE resource='mappings' AND runtime_id=${lit(mapId(n))};`);changes.push(`UPDATE ${s}."application_user_mapping" SET status='UNBOUND',active_account_key=NULL,unbound_at=now(),updated_at=now(),version=version+1 WHERE id=${lit(physical(mapId(n)))};`);}
 for(const n of [...downgradedNumbers,...upgradedNumbers]){const target=seedState.mappings.find(row=>row.id===mapId(n));if(!target)throw new Error('Seed mapping missing: '+n);const bound=target.status==='BOUND';changes.push(`UPDATE ${s}."portal_runtime_entity" SET payload=payload||jsonb_build_object('status',${lit(target.status)},'externalAccountStatus',${lit(target.externalAccountStatus)},'conflictReason',${lit(target.conflictReason)},'boundAt',${lit(target.boundAt)},'version',2,'updatedAt',${stamp}),updated_at=now() WHERE resource='mappings' AND runtime_id=${lit(mapId(n))};`);changes.push(`UPDATE ${s}."application_user_mapping" SET status=${lit(target.status)},active_account_key=${bound?'jsonb_build_array(application_id,external_user_id)::text':'NULL'},bound_at=${lit(target.boundAt)},conflict_reason=${lit(target.conflictReason)},updated_at=now(),version=version+1 WHERE id=${lit(physical(mapId(n)))};`);}
 for(const n of addedNumbers){const row=seedState.mappings.find(item=>item.id===mapId(n));if(!row)throw new Error('Seed mapping missing: '+n);changes.push(`INSERT INTO ${s}."portal_runtime_entity"(resource,runtime_id,position,payload) SELECT 'mappings',${lit(row.id)},coalesce(max(position),-1)+1,${json(row)} FROM ${s}."portal_runtime_entity" WHERE resource='mappings';`);changes.push(`INSERT INTO ${s}."application_user_mapping"(id,created_at,updated_at,version,user_id,application_id,external_user_id,external_account,binding_method,status,active_account_key,bound_at) VALUES (${lit(physical(row.id))},${lit(row.createdAt)},${lit(row.updatedAt)},1,'P4FIX_USER_1',${lit(physical(row.appId))},${lit(physical(row.externalUserId))},${lit(row.externalAccount)},${lit(row.bindingMethod)},'BOUND',${lit(JSON.stringify([physical(row.appId),physical(row.externalUserId)]))},${lit(row.boundAt)});`);}
 for(const n of [...addedNumbers,...upgradedNumbers])changes.push(`INSERT INTO ${s}."portal_user_application_scope"(id,created_at,updated_at,version,user_id,application_id) VALUES (${lit(scopeId(n))},now(),now(),1,'P4FIX_USER_1',${lit(physical(appId(n)))});`);
 for(const n of upgradedNumbers){const id=exceptionId(n);changes.push(archive('exception',id,`SELECT ${lit(archiveKey('exception',id))},'exception',${lit(id)},jsonb_build_object('exception',to_jsonb(e)),'Restore original demo access' FROM ${s}."mapping_exception" e WHERE e.id=${lit(id)}`));changes.push(`UPDATE ${s}."mapping_exception" SET resolution_status='RESOLVED',resolved_by='P4FIX_ADMIN',resolved_at=now(),resolution_note='本地演示场景恢复，旧异常原文已归档',updated_at=now(),version=version+1 WHERE id=${lit(id)};`);}
 for(const n of downgradedNumbers){const row=seedState.mappings.find(item=>item.id===mapId(n));changes.push(`INSERT INTO ${s}."mapping_exception"(id,created_at,updated_at,version,mapping_id,exception_type,summary,resolution_status) VALUES (${lit(exceptionId(n))},now(),now(),1,${lit(physical(mapId(n)))},${lit(row.status)},${lit(row.conflictReason)},'OPEN');`);}
 return `BEGIN; SET LOCAL lock_timeout='5s'; SELECT pg_advisory_xact_lock(38013800); DO $$ BEGIN ${checks.join('\n')} END $$; ${changes.join('\n')} COMMIT;`;
}

if(process.argv[1]&&fileURLToPath(import.meta.url)===resolve(process.argv[1])){
 const db=(await createRepository().load()).state,seed=createSeed(),physicalState=JSON.parse(await sqlQuery(buildReadSql()));
 const plan=await buildPlan(db,seed,physicalState);
 console.log(JSON.stringify({mode:process.argv.includes('--apply')?'apply':'preview',safe:plan.safe,issues:plan.issues,accessDiff:plan.accessDiff,archiveTodos:plan.archiveTodos,archiveMessages:plan.archiveMessages}));
 if(process.argv.includes('--apply')){
  if(!plan.safe)throw new Error('业务基线不匹配，未执行写入');
  await sqlQuery(buildTransactionSql(plan,seed));
  console.log(JSON.stringify({applied:true}));
 }
}
