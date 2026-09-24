import {createHash} from 'node:crypto';

const schema='pb3gir75kkooyea';
const table=name=>`"${schema}"."${name}"`;
const literal=value=>value==null?'NULL':`'${String(typeof value==='object'?JSON.stringify(value):value).replaceAll("'","''")}'`;
const physical=id=>id?'P4FIX_'+String(id).replace(/^MOCK_/,'').replace(/^P4FIX_/,''):null;
const runtime=id=>id?String(id).startsWith('P4FIX_')?'MOCK_'+String(id).slice(6):String(id):null;
const source=id=>String(id||'').replace(/^P4FIX_/,'');
const parse=value=>typeof value==='string'?JSON.parse(value):value;
const upsert=(name,row,conflictCols=['id'])=>{
 const keys=Object.keys(row),cols=keys.map(key=>`"${key}"`).join(','),values=keys.map(key=>literal(row[key])).join(',');
 const updates=keys.filter(key=>!['id','created_at',...conflictCols].includes(key)).map(key=>`"${key}"=EXCLUDED."${key}"`).join(',');
 return `INSERT INTO ${table(name)} (${cols}) VALUES (${values}) ON CONFLICT (${conflictCols.map(key=>`"${key}"`).join(',')}) DO UPDATE SET ${updates};`;
};
const base=row=>({id:physical(row.id),created_at:row.createdAt||new Date().toISOString(),updated_at:row.updatedAt||new Date().toISOString(),version:row.version||1});
const recipientId=row=>'P4FIX_RECIPIENT_'+String(row.id).replace(/^MOCK_/,'').replace(/^P4FIX_/,'');

export async function loadMessageTodoState(query,state){
 const raw=await query(`SELECT json_build_object(
  'todos',coalesce((SELECT json_agg(t ORDER BY t.created_at,t.id) FROM ${table('todo_item')} t WHERE t.archived_at IS NULL),'[]'::json),
  'messages',coalesce((SELECT json_agg(json_build_object('message',m,'recipient',r) ORDER BY m.created_at,m.id,r.id) FROM ${table('message')} m JOIN ${table('message_recipient')} r ON r.message_id=m.id),'[]'::json)
 );`);
 const data=parse(raw)||{},appNames=new Map((state.apps||[]).map(app=>[app.id,app.name]));
 const todos=(data.todos||[]).map(row=>({
  id:row.runtime_id||runtime(row.id),version:Number(row.version)||1,createdAt:row.created_at,updatedAt:row.updated_at,
  receivedAt:row.received_at||row.created_at,sourceCreatedAt:row.source_created_at,sourceUpdatedAt:row.source_updated_at,
  appId:runtime(row.application_id),appName:appNames.get(runtime(row.application_id))||'',sourceTodoId:source(row.source_todo_id),
  userId:runtime(row.target_user_id),title:row.title,summary:row.summary||'',businessType:row.business_type||'',status:row.status,url:row.business_url
 }));
 const messages=(data.messages||[]).map(({message:row,recipient})=>({
  id:row.runtime_id||runtime(row.id),version:Number(recipient.version)||1,createdAt:row.created_at,updatedAt:recipient.updated_at,
  receivedAt:recipient.received_at||row.received_at||recipient.created_at,
  appId:runtime(row.application_id),appName:appNames.get(runtime(row.application_id))||'',sourceKind:row.source_kind,
  sourceMessageId:source(row.source_message_id),messageType:row.message_type,title:row.title,content:row.content,url:row.business_url,
  userId:runtime(recipient.user_id),status:recipient.read_status,readAt:recipient.read_at,
  deleted:Boolean(recipient.deleted_at),deletedAt:recipient.deleted_at||null
 }));
 return {...state,todos,messages};
}

export function messageTodoMirrorSql(before,after){
 const oldTodos=new Map((before.todos||[]).map(row=>[row.id,JSON.stringify(row)]));
 const oldMessages=new Map((before.messages||[]).map(row=>[row.id,JSON.stringify(row)]));
 const statements=[];
 for(const row of after.todos||[]){
  if(oldTodos.get(row.id)===JSON.stringify(row))continue;
  statements.push(upsert('todo_item',{...base(row),runtime_id:row.id,application_id:physical(row.appId),source_todo_id:physical(row.sourceTodoId),
   target_user_id:physical(row.userId),title:row.title,business_type:row.businessType||null,summary:row.summary||'',status:row.status,
   priority:'MEDIUM',source_created_at:row.sourceCreatedAt||row.createdAt,source_updated_at:row.sourceUpdatedAt||row.updatedAt,
   source_revision:1,due_at:null,terminal_at:row.status==='PENDING'?null:row.updatedAt,business_url:row.url,
   received_at:row.receivedAt||row.createdAt}));
 }
 for(const row of after.messages||[]){
  if(oldMessages.get(row.id)===JSON.stringify(row))continue;
  statements.push(upsert('message',{...base(row),runtime_id:row.id,application_id:physical(row.appId),source_kind:row.appId?'APPLICATION':'PORTAL',
   source_key:physical(row.appId)||'PORTAL',source_message_id:physical(row.sourceMessageId||row.id),message_type:row.messageType||'BUSINESS',
   title:row.title,content:row.content,business_url:row.url||null,source_created_at:row.sourceCreatedAt||row.createdAt,received_at:row.receivedAt||row.createdAt}));
  statements.push(upsert('message_recipient',{...base({...row,id:recipientId(row)}),message_id:physical(row.id),user_id:physical(row.userId),
   read_status:row.status,read_at:row.status==='READ'?row.readAt||row.updatedAt:null,received_at:row.receivedAt||row.createdAt,
   deleted_at:row.deleted?row.deletedAt||row.updatedAt:null},['message_id','user_id']));
 }
 for(const row of before.todos||[])if(!(after.todos||[]).some(next=>next.id===row.id))statements.push(`DELETE FROM ${table('todo_item')} WHERE id=${literal(physical(row.id))};`);
 for(const row of before.messages||[])if(!(after.messages||[]).some(next=>next.id===row.id)){
  statements.push(`DELETE FROM ${table('message_recipient')} WHERE message_id=${literal(physical(row.id))} AND user_id=${literal(physical(row.userId))};`);
  statements.push(`DELETE FROM ${table('message')} WHERE id=${literal(physical(row.id))} AND NOT EXISTS(SELECT 1 FROM ${table('message_recipient')} WHERE message_id=${literal(physical(row.id))});`);
 }
 return statements.join('\n');
}
