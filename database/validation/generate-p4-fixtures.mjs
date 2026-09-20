// Offline P4 fixture generator. Never opens a database connection.
// stdout is SQL for review; --check validates without producing SQL.
// Execution is reserved for the main task after review.
import fs from 'node:fs';
import { createHash } from 'node:crypto';
import { fileURLToPath } from 'node:url';
import { createSeed } from '../../src/mock/seed.js';

const schema = JSON.parse(fs.readFileSync(new URL('../../docs/development/nocodb-schema.json', import.meta.url), 'utf8'));
const namespace = 'pb3gir75kkooyea';
if (schema.baseId !== namespace) throw Error('Unexpected target schema');
const prefix = value => 'P4FIX_' + String(value).replace(/^MOCK_/, '');
const quote = value => '"' + value.replaceAll('"', '""') + '"';
const literal = value => value == null ? 'NULL' : "'" + String(value).replaceAll("'", "''") + "'";
const digest = value => createHash('sha256').update(value).digest('hex');
const skipped = ['login_request','portal_session','announcement_attachment','sms_channel','sms_template','sms_application','sms_application_template','sms_send_record','sms_send_attempt'];

export function buildFixtures(now = '2026-09-18T00:00:00.000Z') {
 const seed = createSeed(now), stamp = new Date(now).toISOString();
 const rows = Object.fromEntries(schema.tables.map(t => [t.name, []]));
 const add = (table, id, values) => rows[table].push({ id: prefix(id), created_at: stamp, updated_at: stamp, version: 1, ...values });
 for (const [kind,name] of [['CITIZEN','闽政通'],['GOV','闽政务']])
  add('identity_source','SOURCE_'+kind,{code:prefix('SOURCE_'+kind),name,kind,status:'DISABLED'});
 for (const u of seed.users) {
  add('unified_user',u.id,{display_name:u.name,org_key:prefix(u.orgKey),org_name:u.orgName,status:u.status});
  add('identity_mapping','IDENTITY_'+u.id,{user_id:prefix(u.id),source_id:prefix('SOURCE_'+u.userType),external_subject_id:prefix('SUBJECT_'+u.id),external_account:u.account,status:'BOUND',verified_at:null});
 }
 for (const c of seed.categories) add('application_category',c.id,{code:prefix(c.code),name:c.name,sort_order:c.sortOrder,status:c.status,remark:'P4 fixture'});
 for (const a of seed.apps) add('application',a.id,{
  code:prefix(a.code),name:a.name,category_id:prefix(a.categoryId),network_zone:a.networkZone,user_type:a.userType,
  application_url:a.url,description:a.description+' 原序号：'+a.sourceNo+'；整合平台'+a.platformNo+'：'+a.platformName,
  sort_order:a.sourceNo,status:a.status,runtime_status:a.status==='DISABLED'?'DISABLED':'UNCONFIGURED',allowed_origins:[],binding_methods:['ADMIN']
 });
 for (const m of seed.mappings) {
  const app=prefix(m.appId),subject=prefix(m.externalUserId),bound=m.status==='BOUND';
  add('application_user_mapping',m.id,{user_id:prefix(m.userId),application_id:app,external_user_id:subject,external_account:m.externalAccount,
   binding_method:m.bindingMethod,status:m.status,active_account_key:bound?JSON.stringify([app,subject]):null,
   bound_at:bound?m.boundAt:null,conflict_reason:m.conflictReason});
  if (!bound) add('mapping_exception','EXCEPTION_'+m.id,{mapping_id:prefix(m.id),exception_type:m.status,summary:m.conflictReason,resolution_status:'OPEN'});
 }
 const scopeNames={super:'超级管理权限',application:'应用管理权限',integration:'集成管理权限',announcement:'公告管理权限',audit:'审计权限',identity:'身份映射权限'};
 for (const [code,name] of Object.entries(scopeNames)) add('portal_permission','PERM_'+code,{code:prefix(code),name,kind:'ACTION'});
 const roles=[['USER','普通用户',[]],['ADMIN','门户管理员',Object.keys(scopeNames)],['EDITOR','门户管理员',['announcement']]];
 for (const [code,name,scopes] of roles) {
  add('portal_role','ROLE_'+code,{code:prefix(code),name,description:'P4 fixture；权限范围：'+(scopes.map(s=>scopeNames[s]).join('、')||'本人')+'；不授予来源系统业务权限',status:'ENABLED'});
  for (const scope of scopes) add('portal_role_permission','RP_'+code+'_'+scope,{role_id:prefix('ROLE_'+code),permission_id:prefix('PERM_'+scope),data_scope:'ALL_PORTAL'});
 }
 for (const u of seed.users) {
  const role=u.kind==='USER'?'USER':u.scopes.includes('super')?'ADMIN':'EDITOR';
  add('portal_user_role','UR_'+u.id,{user_id:prefix(u.id),role_id:prefix('ROLE_'+role),granted_by:prefix('MOCK_ADMIN')});
 }
 for (const m of seed.mappings.filter(m=>m.status==='BOUND')) add('portal_user_application_scope','SCOPE_'+m.id,{user_id:prefix(m.userId),application_id:prefix(m.appId)});
 // Persist real connection configuration as UNCONFIGURED. UI status fixtures never certify connectivity.
 for (const a of seed.apps) {
  const status=a.status==='DISABLED'?'DISABLED':'UNCONFIGURED';
  add('sso_config','SSO_'+a.id,{application_id:prefix(a.id),protocol:'UNCONFIGURED',endpoints:{},status});
  for (const kind of ['TODO','MESSAGE']) add('push_integration_config','PUSH_'+a.id+'_'+kind,{
   application_id:prefix(a.id),kind,mode:'PUSH',field_mapping:{},value_mapping:{},target_key_kind:'UNIFIED_USER_ID',status
  });
 }
 for (const t of seed.todos) add('todo_item',t.id,{
  application_id:prefix(t.appId),source_todo_id:prefix(t.sourceTodoId),target_user_id:prefix(t.userId),title:t.title,business_type:t.businessType,summary:t.summary,
  status:t.status,priority:t.priority,source_created_at:t.createdAt,source_updated_at:t.updatedAt,source_revision:t.sourceRevision,
  due_at:t.dueAt,terminal_at:t.terminalAt,business_url:t.url
 });
 for (const m of seed.messages) {
  const app=m.appId?prefix(m.appId):null;
  add('message',m.id,{application_id:app,source_kind:m.sourceKind,source_key:app||'PORTAL',source_message_id:prefix(m.sourceMessageId),
   message_type:m.messageType,title:m.title,content:m.content,business_url:m.url,source_created_at:m.createdAt});
  add('message_recipient','RECIPIENT_'+m.id,{message_id:prefix(m.id),user_id:prefix(m.userId),read_status:m.status,read_at:m.readAt});
 }
 for (const a of seed.announcements) {
  add('announcement',a.id,{title:a.title,announcement_type:a.type,content:a.content,scope:a.scope,status:a.status,
   effective_start:a.effectiveStart,effective_end:a.effectiveEnd,publisher_id:a.publisherId?prefix(a.publisherId):null,published_at:a.publishedAt});
  if (a.scope==='ORG') add('announcement_org_scope','ORG_'+a.id,{announcement_id:prefix(a.id),identity_source_code:prefix('SOURCE_GOV'),org_key:prefix(a.orgKey)});
 }
 for (const c of seed.settings) add('system_config',c.id,{code:prefix(c.code),value:c.value,unit:c.unit,status:c.status,description:'P4 fixture / '+c.name});
 for (const [i,status] of ['NORMAL','ABNORMAL','UNCONFIGURED','DISABLED'].entries()) add('monitor_status','MONITOR_'+i,{
  target_key:prefix('APP_'+(i+1)),service_type:['SSO','TODO','MESSAGE','IDENTITY'][i],status,
  last_success_at:status==='NORMAL'?stamp:null,last_failure_at:status==='ABNORMAL'?stamp:null,
  failure_count:status==='ABNORMAL'?2:0,response_time_ms:status==='NORMAL'?120:null,last_error:status==='ABNORMAL'?'P4 fixture：接入参数核验失败':null
 });
 for (const l of seed.logs) add('audit_event',l.id,{
  kind:l.kind.toUpperCase(),event_code:prefix(l.kind),request_id:prefix(l.requestId),actor_user_id:prefix(l.userId),
  actor_kind:'USER',application_id:prefix(l.appId),object_type:'P4_FIXTURE',object_id:prefix(l.appId),result:l.status,
  summary:l.description,details:{fixture:true,source:'P4 offline dataset'},resolution_status:l.kind==='error'?'OPEN':null
 });
 for (const [i,status] of ['RECEIVED','APPLIED','REJECTED'].entries()) {
  const payload={fixture:true,event:prefix('EVENT_'+i),application:prefix(seed.apps[i].id)};
  add('ingest_receipt','RECEIPT_'+i,{application_id:prefix(seed.apps[i].id),kind:i%2?'MESSAGE':'TODO',event_id:payload.event,
   payload_hash:digest(JSON.stringify(payload)),status,result:{fixture:true,disposition:status},applied_at:status==='APPLIED'?stamp:null});
 }
 validate(rows);
 return rows;
}

function validate(rows) {
 for (const t of schema.tables) {
  const fields=new Map(t.fields.map(f=>[f.name,f]));
  for (const r of rows[t.name]) {
   if (!r.id.startsWith('P4FIX_')) throw Error('Unscoped ID');
   for (const key of Object.keys(r)) if (!fields.has(key)) throw Error(t.name+'.'+key+' unknown field');
   for (const f of t.fields) {
    const v=r[f.name],values=f.enum?schema.enums[f.enum]:f.values;
    if (v==null) { if (f.required) throw Error(t.name+'.'+f.name+' required'); continue; }
    if (values&&!values.includes(v)) throw Error(t.name+'.'+f.name+' enum');
    if (f.type==='integer'&&(!Number.isSafeInteger(v)||(f.min!==undefined&&v<f.min))) throw Error('Invalid integer');
    if (f.type==='string'&&typeof v!=='string') throw Error('Invalid string');
    if (f.type==='datetime'&&!Number.isFinite(Date.parse(v))) throw Error('Invalid date');
    if (f.references&&!rows[f.references].some(x=>x.id===v)) throw Error('Missing fixture reference '+v);
   }
  }
  for (const keys of [['id'],...t.unique,...(t.partialUniqueIndexes||[]).filter(x=>x.where==="status = 'BOUND'").map(x=>x.fields)]) {
   const seen=new Set();
   for (const r of rows[t.name]) {
    if (keys.some(key=>r[key]==null)) continue;
    const key=JSON.stringify(keys.map(k=>r[k]));
    if (seen.has(key)) throw Error(t.name+' duplicate '+key);
    seen.add(key);
   }
  }
 }
 for (const r of rows.application_user_mapping) {
  const expected=r.status==='BOUND'?JSON.stringify([r.application_id,r.external_user_id]):null;
  if (r.active_account_key!==expected) throw Error('Invalid bound key');
 }
 for (const r of rows.todo_item) if ((r.status==='PENDING')!==(r.terminal_at===null)) throw Error('Invalid terminal timestamp');
 for (const r of rows.message) if (r.source_kind==='PORTAL' ? r.application_id!==null||r.source_key!=='PORTAL' : r.source_key!==r.application_id) throw Error('Invalid message source');
 for (const r of rows.message_recipient) if ((r.read_status==='UNREAD')!==(r.read_at===null)) throw Error('Invalid read timestamp');
 for (const r of rows.announcement) {
  if (r.status==='PUBLISHED'&&(!r.publisher_id||!r.published_at)) throw Error('Missing publisher');
  if (r.effective_start&&r.effective_end&&Date.parse(r.effective_end)<=Date.parse(r.effective_start)) throw Error('Invalid announcement window');
 }
 for (const r of rows.system_config) if ((r.status==='UNCONFIGURED')!==(r.value===null)) throw Error('Invalid config value');
 for (const r of rows.mapping_exception) if (!r.mapping_id&&!r.identity_mapping_id) throw Error('Missing exception parent');
}

export function generateSql(now) {
 const rows=buildFixtures(now);
 const lines=[
  '-- P4 offline fixture; not evidence of real authentication, connectivity, delivery or business activity.',
  '-- REVIEW ONLY. Run with psql -X -v ON_ERROR_STOP=1 -f p4-fixtures.sql after main-task approval.',
  '-- All IDs and business codes are P4FIX_ scoped. Existing rows are NEVER updated or deleted.',
  '-- SQL errors abort the transaction; connection close rolls it back. Never continue a failed transaction.',
  '-- No auth sessions, login tokens, SMS configuration/records, or fictitious uploaded attachments.',
  '-- Existing system_config keys remain untouched; fixture keys have a separate P4FIX_ namespace.',
  '-- Catalog contains 42 original applications and seven consolidation platforms (original #42 excluded).',
  '\\set ON_ERROR_STOP on',
  'BEGIN;',
  "SET LOCAL lock_timeout = '5s';",
  "SET LOCAL statement_timeout = '60s';",
  'SET LOCAL standard_conforming_strings = on;',
  'SET LOCAL search_path = "pb3gir75kkooyea", pg_catalog;'
 ];
 const done=new Set(),pending=schema.tables.filter(t=>rows[t.name].length);
 while (pending.length) {
  const index=pending.findIndex(t=>t.fields.filter(f=>f.references).every(f=>done.has(f.references)||!rows[f.references].length));
  if (index<0) throw Error('Cyclic fixture dependency');
  const [t]=pending.splice(index,1);
  lines.push('-- '+t.name+': '+rows[t.name].length+' fixtures');
  for (const r of rows[t.name]) {
   const fields=t.fields.filter(f=>Object.hasOwn(r,f.name));
   const values=fields.map(f=>f.type==='json'&&r[f.name]!=null?literal(JSON.stringify(r[f.name])):typeof r[f.name]==='number'?String(r[f.name]):literal(r[f.name]));
   lines.push('INSERT INTO '+quote(namespace)+'.'+quote(t.name)+' ('+fields.map(f=>quote(f.name)).join(', ')+') VALUES ('+values.join(', ')+') ON CONFLICT ("id") DO NOTHING;');
  }
  done.add(t.name);
 }
 lines.push('-- Skipped intentionally: '+skipped.join(', '), 'COMMIT;');
 return lines.join('\n')+'\n';
}
export function manifest(now) {
 const rows=buildFixtures(now);
 return {schema:namespace,prefix:'P4FIX_',now:new Date(now||'2026-09-18T00:00:00.000Z').toISOString(),
  counts:Object.fromEntries(Object.entries(rows).map(([k,v])=>[k,v.length])),
  total:Object.values(rows).reduce((n,items)=>n+items.length,0),skipped,
  safety:{databaseExecuted:false,existingConfigKeysUntouched:true,realConnectionsConfigured:false}};
}
export function generateReadback(now) {
 const {counts}=manifest(now);
 return '-- Read only: compare P4FIX_ rows with the reviewed manifest. No global counts assumed.\nBEGIN READ ONLY;\n'+
  Object.entries(counts).map(([table,count])=>'SELECT '+literal(table)+' AS table_name, '+count+' AS expected_count, count(*) AS actual_count, count(*) = '+count+' AS matches FROM '+quote(namespace)+'.'+quote(table)+" WHERE left(id, 6) = 'P4FIX_'").join('\nUNION ALL\n')+';\nCOMMIT;\n';
}
if (process.argv[1] && fileURLToPath(import.meta.url) === fs.realpathSync(process.argv[1])) {
 const now=process.argv.find(a=>a.startsWith('--now='))?.slice(6);
 const rows=buildFixtures(now);
 console.log(process.argv.includes('--check')||process.argv.includes('--counts')?JSON.stringify(manifest(now),null,2):process.argv.includes('--readback')?generateReadback(now):generateSql(now));
}
