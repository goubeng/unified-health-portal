import {spawn} from 'node:child_process';
import {randomUUID,createHash} from 'node:crypto';
import {createSeed} from '../src/mock/seed.js';
import {ensureRules} from '../src/config/rules.js';

export const schema='pb3gir75kkooyea';
export const dbId=id=>id?'P4FIX_'+String(id).replace(/^MOCK_/,''):null;
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
export function mirrorSql(before,after){
 const statements=[];
 const changed=(key,fn)=>{const old=new Map((before[key]||[]).map(x=>[x.id,JSON.stringify(x)]));for(const row of after[key]||[])if(old.get(row.id)!==JSON.stringify(row))statements.push(fn(row));};
 changed('categories',x=>upsert('application_category',{...base(x),code:'P4FIX_'+x.code,name:x.name,sort_order:x.sortOrder||0,status:x.status||'ENABLED'}));
 changed('users',x=>upsert('unified_user',{...base(x),display_name:x.name,org_key:x.orgKey||null,org_name:x.orgName||null,status:x.status}));
 changed('apps',x=>upsert('application',{...base(x),code:'P4FIX_'+x.code,name:x.name,category_id:dbId(after.categories.find(c=>c.name===x.category)?.id),user_type:x.userType,application_url:x.url,description:x.description||'',sort_order:x.sortOrder||0,status:x.status,runtime_status:x.connectionStatus==='CONNECTED'?x.runtimeStatus:'UNCONFIGURED',allowed_origins:[],binding_methods:['SELF','ADMIN']}));
 changed('mappings',x=>{const subject=dbId(x.externalUserId||'ACCOUNT_'+x.externalAccount),app=dbId(x.appId);return upsert('application_user_mapping',{...base(x),user_id:dbId(x.userId),application_id:app,external_user_id:subject,external_account:x.externalAccount,binding_method:x.bindingMethod||'SELF',status:x.status,active_account_key:x.status==='BOUND'?JSON.stringify([app,subject]):null,bound_at:x.status==='BOUND'?x.boundAt||x.updatedAt:null,unbound_at:x.status==='UNBOUND'?x.updatedAt:null,conflict_reason:x.conflictReason||null});});
 changed('monitorSamples',x=>upsert('monitor_status',{...base(x),target_key:dbId(x.appId),service_type:x.kind,status:x.status,last_success_at:x.status==='NORMAL'?x.lastCheckedAt:null,last_failure_at:x.status==='ABNORMAL'?x.lastCheckedAt:null,failure_count:x.status==='ABNORMAL'?1:0,response_time_ms:x.responseTimeMs||null,last_error:x.status==='ABNORMAL'?'接口响应超时（场景样本）':null}));
 changed('announcements',x=>upsert('announcement',{...base(x),title:x.title,announcement_type:x.type||'通知',content:x.content,scope:x.scope,status:x.status,effective_start:x.effectiveStart||null,effective_end:x.effectiveEnd||null,publisher_id:dbId(x.publisherId),published_at:x.publishedAt||null}));
 changed('todos',x=>upsert('todo_item',{...base(x),application_id:dbId(x.appId),source_todo_id:'P4FIX_'+x.sourceTodoId,target_user_id:dbId(x.userId),title:x.title,summary:x.summary||'',status:x.status,priority:x.priority||'MEDIUM',source_created_at:x.createdAt,source_updated_at:x.updatedAt,source_revision:x.sourceRevision,due_at:x.dueAt||null,terminal_at:x.status==='PENDING'?null:x.terminalAt||x.updatedAt,business_url:x.url}));
 changed('messages',x=>upsert('message',{...base(x),application_id:dbId(x.appId),source_kind:x.appId?'APPLICATION':'PORTAL',source_key:dbId(x.appId)||'PORTAL',source_message_id:'P4FIX_'+(x.sourceMessageId||x.id),message_type:x.messageType||'BUSINESS',title:x.title,content:x.content,business_url:x.url||null,source_created_at:x.createdAt})+upsert('message_recipient',{...base({...x,id:'RECIPIENT_'+x.id}),message_id:dbId(x.id),user_id:dbId(x.userId),read_status:x.status,read_at:x.readAt||null}));
 changed('settings',x=>upsert('system_config',{...base(x),code:'P4FIX_'+x.code,value:x.value,unit:x.unit||'count',status:x.value==null?'UNCONFIGURED':'CONFIGURED',description:x.name||x.code}));
 changed('integrations',x=>x.kind==='SSO'?upsert('sso_config',{...base({...x,id:'SSO_'+x.appId}),application_id:dbId(x.appId),enabled:x.enabled||'DISABLED',remark:x.remark||'',protocol:x.protocol||'UNCONFIGURED',client_id:x.clientId||null,secret_ref:x.credentialRef||null,endpoints:{authorizeUrl:x.authorizeUrl||'',tokenUrl:x.tokenUrl||'',callbackUrl:x.callbackUrl||''},status:x.status==='DISABLED'?'DISABLED':'UNCONFIGURED'}):upsert('push_integration_config',{...base({...x,id:'PUSH_'+x.appId+'_'+x.kind}),application_id:dbId(x.appId),kind:x.kind,enabled:x.enabled||'DISABLED',remark:x.remark||'',mode:'PUSH',credential_ref:x.credentialRef||null,field_mapping:x.fieldMapping||{},value_mapping:x.valueMapping||{},target_key_kind:'UNIFIED_USER_ID',status:x.status==='DISABLED'?'DISABLED':'UNCONFIGURED'}));
 const receiptKey=x=>[x.appId,x.kind|| (JSON.parse(x.payload).sourceTodoId?'TODO':'MESSAGE'),x.eventId].join('|');
 const previousReceipts=new Set((before.receipts||[]).map(receiptKey));
 for(const x of after.receipts||[])if(!previousReceipts.has(receiptKey(x))){const key=receiptKey(x);statements.push(upsert('ingest_receipt',{...base({id:'RECEIPT_'+createHash('sha256').update(key).digest('hex'),version:1}),application_id:dbId(x.appId),kind:x.kind||(JSON.parse(x.payload).sourceTodoId?'TODO':'MESSAGE'),event_id:x.eventId,payload_hash:createHash('sha256').update(x.payload).digest('hex'),status:'APPLIED',result:x.result,applied_at:new Date().toISOString()}));}
 for(const row of before.messages||[])if(!(after.messages||[]).some(x=>x.id===row.id)){const id=lit(dbId(row.id));statements.push(`DELETE FROM ${table('message_recipient')} WHERE message_id=${id} AND user_id=${lit(dbId(row.userId))};DELETE FROM ${table('message')} WHERE id=${id} AND NOT EXISTS(SELECT 1 FROM ${table('message_recipient')} WHERE message_id=${id});`);}
 for(const row of before.categories||[])if(!(after.categories||[]).some(x=>x.id===row.id))statements.push(`DELETE FROM ${table('application_category')} WHERE id=${lit(dbId(row.id))};`);
 for(const row of before.announcements||[])if(!(after.announcements||[]).some(x=>x.id===row.id)){
  const id=lit(dbId(row.id));statements.push(`DELETE FROM ${table('announcement_attachment')} WHERE announcement_id=${id};DELETE FROM ${table('announcement_org_scope')} WHERE announcement_id=${id};DELETE FROM ${table('announcement')} WHERE id=${id};`);
 }
 return statements.join('\n');
}
export function makeEvent({actor,action,payload={},state,result,kind}){
 const todo=action==='openTodo'?state.todos.find(x=>x.id===payload.id):null;
 const related=[...(state.integrations||[]),...(state.mappings||[]),...(state.messages||[])].find(x=>x.id===payload.id);
 const appId=payload.appId||todo?.appId||related?.appId||(['enterApp','saveApp','setAppStatus'].includes(action)?payload.id||result?.data?.id:null);
 return {id:'P4EV_'+randomUUID(),at:new Date().toISOString(),kind:kind||(result?.ok===false?'ERROR':['enterApp','openTodo'].includes(action)?'ACCESS':action.startsWith('push')?'API':'OPERATION'),action,actorId:actor?.id||null,actorKind:actor?'USER':'SYSTEM',appId:state.apps.some(x=>x.id===appId)?appId:null,objectId:payload.id||result?.data?.entityId||result?.data?.id||null,result:result?.ok===false?(result.error?.code==='FORBIDDEN'?'DENIED':'FAILURE'):'SUCCESS',summary:result?.ok===false?result.error.message:action,requestId:result?.requestId||randomUUID(),details:{actorName:actor?.name||'系统任务',applicationName:state.apps.find(x=>x.id===appId)?.name||null,objectType:action==='openTodo'?'todo':appId?'application':action.includes('Announcement')?'announcement':'portal',previousActor:payload.previousActor||null,objectIds:payload.ids||[],accessOutcome:['enterApp','openTodo'].includes(action)?'ENTRY_REQUEST_ONLY':null}};
}
export function createRepository(query=sqlQuery){
 return {
  async load(){
   const raw=await query(`SELECT json_build_object('version',version,'state',value::jsonb) FROM ${table('system_config')} WHERE id='P4RUN_STATE';`);
   if(raw){const record=JSON.parse(raw);ensureRules(record.state);return record;}
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
