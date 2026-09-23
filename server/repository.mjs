import {spawn} from 'node:child_process';
import {randomUUID,createHash} from 'node:crypto';
import {createSeed} from '../src/mock/seed.js';
import {ensureRules} from '../src/config/rules.js';
import {loadApplicationState,applicationMirrorSql} from './application-persistence.mjs';
import {loadMessageTodoState,messageTodoMirrorSql} from './message-todo-persistence.mjs';
import {loadRequestState,requestMirrorSql} from './request-persistence.mjs';
import {loadRemainingState,remainingMirrorSql} from './remaining-persistence.mjs';

export const schema='pb3gir75kkooyea';
export const dbId=id=>id?'P4FIX_'+String(id).replace(/^MOCK_/,''):null;
export const runtimeId=id=>id?(String(id).startsWith('P4FIX_')?'MOCK_'+String(id).slice(6):String(id)):null;
const lit=v=>v==null?'NULL':"'"+String(typeof v==='object'?JSON.stringify(v):v).replaceAll("'","''")+"'";
const ident=v=>'"'+v.replaceAll('"','""')+'"';
const table=n=>`${ident(schema)}.${ident(n)}`;
export function sqlQuery(sql){
 return new Promise((resolve,reject)=>{
  const child=spawn('docker',['exec','-i','-u','postgres','postgres14','psql','-X','-q','-A','-t','-U','admin','-d','nocodb_data','-v','ON_ERROR_STOP=1'],{windowsHide:true,stdio:['pipe','pipe','pipe']});
  let out='',err='';const timer=setTimeout(()=>child.kill(),20000);
  child.stdout.on('data',x=>out+=x);child.stderr.on('data',x=>err+=x);
  child.on('error',e=>{clearTimeout(timer);reject(e);});child.on('close',code=>{clearTimeout(timer);code===0?resolve(out.trim()):reject(new Error('数据库操作失败：'+err.slice(-800)));});
  child.stdin.on('error',()=>{});child.stdin.end("SET standard_conforming_strings=on;\n"+sql);
 });
}
const upsert=(name,row)=>{const keys=Object.keys(row);return `INSERT INTO ${table(name)} (${keys.map(ident).join(',')}) VALUES (${keys.map(k=>lit(row[k])).join(',')}) ON CONFLICT (id) DO UPDATE SET ${keys.filter(k=>k!=='id'&&k!=='created_at').map(k=>`${ident(k)}=EXCLUDED.${ident(k)}`).join(',')};`;};
const base=x=>({id:dbId(x.id),created_at:x.createdAt||new Date().toISOString(),updated_at:x.updatedAt||new Date().toISOString(),version:x.version||1});
const json=value=>{if(value==null||typeof value==='object')return value;try{return JSON.parse(value);}catch{return null;}};
const announcementRows=state=>{
 const rows=new Map();
 for(const row of state.announcements||[])rows.set(row.id,{...row,deletedAt:null,deletedBy:null,deleteReason:null});
 for(const row of state.announcementTrash||[])rows.set(row.id,row);
 return [...rows.values()];
};
const readReceiptId=row=>'ANN_READ_'+createHash('sha256').update(`${row.announcementId}|${row.userId}`).digest('hex');

export async function loadAnnouncementState(query,state){
 const raw=await query(`SELECT json_build_object(
  'announcements',coalesce((SELECT json_agg(a ORDER BY a.created_at,a.id) FROM ${table('announcement')} a),'[]'::json),
  'attachments',coalesce((SELECT json_agg(x ORDER BY x.announcement_id,x.sort_order,x.id) FROM ${table('announcement_attachment')} x),'[]'::json),
  'reads',coalesce((SELECT json_agg(r ORDER BY r.read_at,r.id) FROM ${table('announcement_read_receipt')} r),'[]'::json)
 );`);
 const data=json(raw)||{},physicalToRuntime=new Map(),attachments=new Map();
 for(const row of data.announcements||[])physicalToRuntime.set(row.id,row.runtime_id||runtimeId(row.id));
 for(const row of data.attachments||[]){
  const announcementId=physicalToRuntime.get(row.announcement_id)||runtimeId(row.announcement_id),payload=json(row.attachment)||{},item={...payload,
   id:row.runtime_id||runtimeId(row.id),name:row.file_name,size:Number(row.size_bytes)||0,type:row.mime_type||'',uploadedAt:payload.uploadedAt||row.created_at};
  if(!attachments.has(announcementId))attachments.set(announcementId,[]);attachments.get(announcementId).push(item);
 }
 const active=[],trash=[];
 for(const row of data.announcements||[]){
  const id=row.runtime_id||runtimeId(row.id),item={id,createdAt:row.created_at,updatedAt:row.updated_at,version:Number(row.version)||1,
   title:row.title,type:row.announcement_type,content:row.content,scope:row.scope,status:row.status,effectiveStart:row.effective_start||null,effectiveEnd:row.effective_end||null,
   publisherId:runtimeId(row.publisher_id),publishedAt:row.published_at||null,publishMode:row.publish_mode||null,scheduledPublishAt:row.scheduled_publish_at||null,
   submittedAt:row.submitted_at||null,submittedBy:runtimeId(row.submitted_by),withdrawnAt:row.withdrawn_at||null,withdrawnBy:runtimeId(row.withdrawn_by),withdrawReason:row.withdrawn_reason||'',
   lastEditedAt:row.last_edited_at||null,lastEditedBy:runtimeId(row.last_edited_by),attachments:attachments.get(id)||[]};
  if(row.deleted_at)trash.push({...item,deletedAt:row.deleted_at,deletedBy:row.deleted_by==='SYSTEM'?'SYSTEM':runtimeId(row.deleted_by),deleteReason:row.delete_reason||''});
  else active.push(item);
 }
 return {...state,announcements:active,announcementTrash:trash,announcementReads:(data.reads||[]).map(row=>({announcementId:physicalToRuntime.get(row.announcement_id)||runtimeId(row.announcement_id),userId:runtimeId(row.user_id),readAt:row.read_at}))};
}

export function announcementMirrorSql(before,after){
 const statements=[],rows=announcementRows(after),now=new Date().toISOString();
 for(const x of rows){
  statements.push(upsert('announcement',{...base(x),runtime_id:x.id,title:x.title,announcement_type:x.type||'通知',content:x.content,scope:x.scope,status:x.status,
   effective_start:x.effectiveStart||null,effective_end:x.effectiveEnd||null,publisher_id:dbId(x.publisherId),published_at:x.publishedAt||(x.status==='PUBLISHED'?x.scheduledPublishAt:null)||null,
   publish_mode:x.publishMode||null,scheduled_publish_at:x.scheduledPublishAt||null,submitted_at:x.submittedAt||null,submitted_by:dbId(x.submittedBy),
   withdrawn_at:x.withdrawnAt||null,withdrawn_by:dbId(x.withdrawnBy),withdrawn_reason:x.withdrawReason||null,last_edited_at:x.lastEditedAt||null,last_edited_by:dbId(x.lastEditedBy),
   deleted_at:x.deletedAt||null,deleted_by:x.deletedBy==='SYSTEM'?'SYSTEM':dbId(x.deletedBy),delete_reason:x.deleteReason||null}));
  const announcementId=lit(dbId(x.id));statements.push(`DELETE FROM ${table('announcement_attachment')} WHERE announcement_id=${announcementId};`);
  for(const [index,file] of (x.attachments||[]).entries())statements.push(upsert('announcement_attachment',{...base({id:file.id,createdAt:file.uploadedAt||x.createdAt,updatedAt:x.updatedAt,version:file.version||1}),runtime_id:file.id,
   announcement_id:dbId(x.id),file_name:file.name||'附件',size_bytes:Number(file.size)||0,mime_type:file.type||'application/octet-stream',attachment:file,uploaded_by:dbId(file.uploadedBy||x.lastEditedBy||x.submittedBy||x.publisherId),sort_order:index}));
 }
 statements.push(`DELETE FROM ${table('announcement_read_receipt')};`);
 for(const receipt of after.announcementReads||[])statements.push(upsert('announcement_read_receipt',{...base({id:readReceiptId(receipt),createdAt:receipt.readAt||now,updatedAt:receipt.readAt||now,version:1}),announcement_id:dbId(receipt.announcementId),user_id:dbId(receipt.userId),read_at:receipt.readAt||now}));
 return statements.join('\n');
}
export function mirrorSql(before,after){
 const statements=[];
 const changed=(key,fn)=>{const old=new Map((before[key]||[]).map(x=>[x.id,JSON.stringify(x)]));for(const row of after[key]||[])if(old.get(row.id)!==JSON.stringify(row))statements.push(fn(row));};
 changed('users',x=>upsert('unified_user',{...base(x),display_name:x.name,org_key:x.orgKey||null,org_name:x.orgName||null,status:x.status}));
 changed('mappings',x=>{const subject=dbId(x.externalUserId||'ACCOUNT_'+x.externalAccount),app=dbId(x.appId);return upsert('application_user_mapping',{...base(x),user_id:dbId(x.userId),application_id:app,external_user_id:subject,external_account:x.externalAccount,binding_method:x.bindingMethod||'SELF',status:x.status,active_account_key:x.status==='BOUND'?JSON.stringify([app,subject]):null,bound_at:x.status==='BOUND'?x.boundAt||x.updatedAt:null,unbound_at:x.status==='UNBOUND'?x.updatedAt:null,conflict_reason:x.conflictReason||null});});
 changed('monitorSamples',x=>upsert('monitor_status',{...base(x),target_key:dbId(x.appId),service_type:x.kind,status:x.status,last_success_at:x.status==='NORMAL'?x.lastCheckedAt:null,last_failure_at:x.status==='ABNORMAL'?x.lastCheckedAt:null,failure_count:x.status==='ABNORMAL'?1:0,response_time_ms:x.responseTimeMs||null,last_error:x.status==='ABNORMAL'?'接口响应超时（场景样本）':null}));
 changed('settings',x=>upsert('system_config',{...base(x),code:'P4FIX_'+x.code,value:x.value,unit:x.unit||'count',status:x.value==null?'UNCONFIGURED':'CONFIGURED',description:x.name||x.code}));
 changed('integrations',x=>x.kind==='SSO'?upsert('sso_config',{...base({...x,id:'SSO_'+x.appId}),application_id:dbId(x.appId),enabled:x.enabled||'DISABLED',remark:x.remark||'',protocol:x.protocol||'UNCONFIGURED',client_id:x.clientId||null,secret_ref:x.credentialRef||null,endpoints:{authorizeUrl:x.authorizeUrl||'',tokenUrl:x.tokenUrl||'',callbackUrl:x.callbackUrl||''},status:x.status==='DISABLED'?'DISABLED':'UNCONFIGURED'}):upsert('push_integration_config',{...base({...x,id:'PUSH_'+x.appId+'_'+x.kind}),application_id:dbId(x.appId),kind:x.kind,enabled:x.enabled||'DISABLED',remark:x.remark||'',mode:'PUSH',credential_ref:x.credentialRef||null,field_mapping:x.fieldMapping||{},value_mapping:x.valueMapping||{},target_key_kind:'UNIFIED_USER_ID',status:x.status==='DISABLED'?'DISABLED':'UNCONFIGURED'}));
 const receiptKey=x=>[x.appId,x.kind|| (JSON.parse(x.payload).sourceTodoId?'TODO':'MESSAGE'),x.eventId].join('|');
 const previousReceipts=new Set((before.receipts||[]).map(receiptKey));
 for(const x of after.receipts||[])if(!previousReceipts.has(receiptKey(x))){const key=receiptKey(x);statements.push(upsert('ingest_receipt',{...base({id:'RECEIPT_'+createHash('sha256').update(key).digest('hex'),version:1}),application_id:dbId(x.appId),kind:x.kind||(JSON.parse(x.payload).sourceTodoId?'TODO':'MESSAGE'),event_id:x.eventId,payload_hash:createHash('sha256').update(x.payload).digest('hex'),status:'APPLIED',result:x.result,applied_at:new Date().toISOString()}));}
 statements.push(remainingMirrorSql(before,after));
 statements.push(applicationMirrorSql(before,after));
 statements.push(messageTodoMirrorSql(before,after));
 statements.push(requestMirrorSql(before,after));
 statements.push(announcementMirrorSql(before,after));
 return statements.filter(Boolean).join('\n');
}
export function makeEvent({actor,action,payload={},state,result,kind}){
 const todo=action==='openTodo'?state.todos.find(x=>x.id===payload.id):null;
 const related=[...(state.integrations||[]),...(state.mappings||[]),...(state.messages||[])].find(x=>x.id===payload.id);
 const appId=payload.appId||todo?.appId||related?.appId||(['enterApp','saveApp','setAppStatus'].includes(action)?payload.id||result?.data?.id:null);
 const eventKind=kind||(result?.ok===false?'ERROR':['enterApp','openTodo'].includes(action)?'ACCESS':action.startsWith('push')?'API':'OPERATION');
 const identitySource=actor?.authType==='LOCAL'?'PORTAL_LOCAL':actor?.userType==='GOV'?'MINZHENGWU':actor?.userType==='CITIZEN'?'MINZHENGTONG':null;
 return {id:'P4EV_'+randomUUID(),at:new Date().toISOString(),kind:eventKind,action,actorId:actor?.id||null,actorKind:actor?'USER':'SYSTEM',appId:state.apps.some(x=>x.id===appId)?appId:null,objectId:payload.id||result?.data?.entityId||result?.data?.id||null,result:result?.ok===false?(result.error?.code==='FORBIDDEN'?'DENIED':'FAILURE'):'SUCCESS',summary:result?.ok===false?result.error.message:action,requestId:result?.requestId||randomUUID(),details:{actorName:actor?.name||'系统任务',actorAccount:actor?.account||null,userType:actor?.userType||null,identitySource,loginMethod:actor?.authType==='LOCAL'?'PASSWORD':'QR',errorCode:result?.error?.code||null,applicationName:state.apps.find(x=>x.id===appId)?.name||null,accessMode:state.apps.find(x=>x.id===appId)?.accessMode||null,objectType:action==='openTodo'?'todo':appId?'application':action.includes('Announcement')?'announcement':'portal',previousActor:payload.previousActor||null,objectIds:payload.ids||[],accessOutcome:['enterApp','openTodo'].includes(action)?'ENTRY_REQUEST_ONLY':null}};
}

export function createMemoryRepository(initialState=createSeed()){
 let current=ensureRules(structuredClone(initialState)),version=1;
 const eventLog=event=>{
  const kind=String(event.kind||'OPERATION').toLowerCase(),details=event.details||{};
  const base={id:event.id,version:1,kind,name:event.action||'操作记录',actor:details.actorName||'系统任务',userId:event.actorId||null,userName:details.actorName||null,
   account:details.actorAccount||null,userType:details.userType||null,identitySource:details.identitySource||null,appId:event.appId||null,appName:details.applicationName||null,
   status:event.result||'SUCCESS',description:event.summary||event.action||'操作已记录',createdAt:event.at,requestId:event.requestId,ip:'127.0.0.1',client:'Chrome / Windows',details};
  if(kind==='login')Object.assign(base,{loginSource:'统一登录',loginMethod:details.loginMethod||'QR',failureReason:event.result==='SUCCESS'?null:event.summary});
  if(kind==='error')Object.assign(base,{severity:'HIGH',moduleName:details.applicationName?'应用集成':'统一门户',errorCode:details.errorCode||'PORTAL_ERROR',errorMessage:event.summary||'服务异常',resolutionStatus:'OPEN',resolutionNote:'',resolvedAt:null,resolvedBy:null});
  if(kind==='api')Object.assign(base,{interfaceName:details.interfaceName||'PUSH接口',httpMethod:'POST',statusCode:event.result==='SUCCESS'?200:400,durationMs:null,errorMessage:event.result==='SUCCESS'?null:event.summary});
  if(kind==='access')Object.assign(base,{accessMethod:'门户入口',accessMode:details.accessMode||null});
  if(kind==='operation')Object.assign(base,{moduleName:details.moduleName||'统一门户',pageName:details.pageName||'系统操作',actionName:event.action||'操作记录',objectType:details.objectType||'PORTAL',objectId:event.objectId||null});
  return base;
 };
 return {
  mode:'MEMORY_A',database:null,schema:null,
  async load(){return {state:structuredClone(current),version};},
  async commit(before,after,expectedVersion,event){
   if(Number(expectedVersion)!==version)throw new Error('STATE_VERSION_CONFLICT');
   const next=structuredClone(after);
   const beforeLogs=JSON.stringify(before?.logs||[]),afterLogs=JSON.stringify(after?.logs||[]);
   if(event&&beforeLogs===afterLogs){next.logs??=[];next.logs.unshift(eventLog(event));}
   current=ensureRules(next);version+=1;
  },
  async logs(kind){return structuredClone((current.logs||[]).filter(x=>kind==='login'?['login','auth'].includes(String(x.kind||'').toLowerCase()):String(x.kind||'').toLowerCase()===String(kind||'').toLowerCase()).slice(0,1000));}
 };
}

export function createRepository(query=sqlQuery){
 return {
  mode:'DATABASE',database:'nocodb_data',schema,
   async load(){
    const raw=await query(`SELECT json_build_object('version',version,'state',value::jsonb) FROM ${table('system_config')} WHERE id='P4RUN_STATE';`);
    if(raw){const record=JSON.parse(raw);ensureRules(record.state);
     record.state=await loadRemainingState(query,record.state);
     record.state=await loadApplicationState(query,record.state);
     record.state=await loadMessageTodoState(query,record.state);
     record.state=await loadRequestState(query,record.state);
     record.state=await loadAnnouncementState(query,record.state);
     return record;}
   const state=ensureRules(createSeed());
   await query(`INSERT INTO ${table('system_config')}(id,created_at,updated_at,version,code,value,unit,status,description) VALUES ('P4RUN_STATE',now(),now(),1,'P4_RUNTIME_STATE_V1',${lit(state)},'json','CONFIGURED','P4 runtime isolated snapshot; not production identity') ON CONFLICT(id) DO NOTHING;`);
   return this.load();
  },
  async commit(before,after,version,event){
   const insert=event?`INSERT INTO ${table('audit_event')}(id,created_at,updated_at,version,kind,event_code,request_id,actor_user_id,actor_kind,application_id,object_type,object_id,result,summary,details) VALUES (${lit(event.id)},${lit(event.at)},${lit(event.at)},1,${lit(event.kind)},${lit(event.action)},${lit(event.requestId)},${lit(dbId(event.actorId))},${lit(event.actorKind)},${lit(dbId(event.appId))},${lit(event.details.objectType||'portal')},${lit(event.objectId)},${lit(event.result)},${lit(event.summary)},${lit(event.details)});`:'';
   await query(`BEGIN; SET LOCAL lock_timeout='5s'; SELECT pg_advisory_xact_lock(38013800); DO $$ BEGIN IF NOT EXISTS(SELECT 1 FROM ${table('system_config')} WHERE id='P4RUN_STATE' AND version=${Number(version)} FOR UPDATE) THEN RAISE EXCEPTION 'STATE_VERSION_CONFLICT'; END IF; END $$; ${mirrorSql(before,after)} ${insert} UPDATE ${table('system_config')} SET value=${lit(after)},version=version+1,updated_at=now() WHERE id='P4RUN_STATE'; COMMIT;`);
  },
  async logs(kind){const raw=await query(`SELECT coalesce(json_agg(r),'[]'::json) FROM (SELECT a.id,lower(a.kind) AS kind,a.event_code AS name,u.display_name AS actor,a.summary AS description,a.result AS status,a.created_at AS "createdAt",a.request_id AS "requestId",p.name AS "appName",a.application_id AS "appId",a.object_id AS "objectId",a.details::jsonb AS details FROM ${table('audit_event')} a LEFT JOIN ${table('unified_user')} u ON a.actor_user_id=u.id LEFT JOIN ${table('application')} p ON a.application_id=p.id WHERE ${kind==='login'?"a.kind IN ('LOGIN','AUTH')":`a.kind=${lit(kind.toUpperCase())}`} ORDER BY a.created_at DESC LIMIT 1000) r;`);return JSON.parse(raw);}
 };
}
