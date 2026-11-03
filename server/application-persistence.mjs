import {createHash} from 'node:crypto';

const schema='pb3gir75kkooyea';
const table=name=>`"${schema}"."${name}"`;
const dbId=id=>id?'P4FIX_'+String(id).replace(/^MOCK_/,''):null;
const runtimeId=id=>id?(String(id).startsWith('P4FIX_')?'MOCK_'+String(id).slice(6):String(id)):null;
const literal=value=>value==null?'NULL':"'"+String(typeof value==='object'?JSON.stringify(value):value).replaceAll("'","''")+"'";
const parsed=value=>{if(value==null||typeof value==='object')return value;try{return JSON.parse(value);}catch{return null;}};
const normalizedCode=code=>String(code||'').replace(/^P4FIX_/,'');
const base=row=>({id:dbId(row.id),created_at:row.createdAt||new Date().toISOString(),updated_at:row.updatedAt||new Date().toISOString(),version:row.version||1});
const upsert=(name,row)=>{const keys=Object.keys(row);return `INSERT INTO ${table(name)} (${keys.map(key=>`"${key}"`).join(',')}) VALUES (${keys.map(key=>literal(row[key])).join(',')}) ON CONFLICT (id) DO UPDATE SET ${keys.filter(key=>!['id','created_at'].includes(key)).map(key=>`"${key}"=EXCLUDED."${key}"`).join(',')};`;};
const archivedCode=id=>'ARCHIVED_'+createHash('sha256').update(id).digest('hex').slice(0,32);

export async function loadApplicationState(query,state){
 const raw=await query(`SELECT json_build_object(
  'categories',coalesce((SELECT json_agg(c ORDER BY c.sort_order,c.id) FROM ${table('application_category')} c WHERE c.runtime_id IS NOT NULL AND c.deleted_at IS NULL),'[]'::json),
  'apps',coalesce((SELECT json_agg(a ORDER BY a.sort_order,a.id) FROM (
    SELECT app.*,subsystem.name AS platform_name,subsystem.source_no AS platform_no
    FROM ${table('application')} app
    LEFT JOIN ${table('application_subsystem')} subsystem ON subsystem.id=app.platform_id
    WHERE app.runtime_id IS NOT NULL AND app.deleted_at IS NULL
  ) a),'[]'::json)
 );`);
 const data=parsed(raw)||{},categoryById=new Map();
 const categories=(data.categories||[]).map(row=>{
  const legacy=parsed(row.runtime_payload)||state.categories?.find(item=>item.id===(row.runtime_id||runtimeId(row.id)))||{};
  const item={...legacy,id:row.runtime_id||runtimeId(row.id),createdAt:row.created_at,updatedAt:row.updated_at,version:Number(row.version)||1,
   code:normalizedCode(row.code),name:row.name,sortOrder:Number(row.sort_order)||0,status:row.status,icon:row.icon??legacy.icon,remark:row.remark??legacy.remark};
  categoryById.set(row.id,item);return item;
 });
 const apps=(data.apps||[]).map(row=>{
  const legacy=parsed(row.runtime_payload)||state.apps?.find(item=>item.id===(row.runtime_id||runtimeId(row.id)))||{};
  const category=categoryById.get(row.category_id);
  const platformId=Object.hasOwn(row,'platform_id')?row.platform_id:legacy.platformId??null;
  return {...legacy,id:row.runtime_id||runtimeId(row.id),createdAt:row.created_at,updatedAt:row.updated_at,version:Number(row.version)||1,
   code:normalizedCode(row.code),name:row.name,categoryId:category?.id||null,category:category?.name||legacy.category||'未分类',
   userType:row.user_type,url:row.application_url,description:row.description||'',sortOrder:Number(row.sort_order)||0,
   status:row.status,enabled:row.status==='ENABLED',networkZone:row.network_zone??legacy.networkZone,
   platformId,
   platformName:platformId?(row.platform_name??legacy.platformName??null):null,
   platformNo:platformId?(Number(row.platform_no)||legacy.platformNo||null):null,
   logoUrl:row.logo_url??legacy.logoUrl,contactName:row.contact_name??legacy.contactName,
   technicalContact:row.technical_contact??legacy.technicalContact,
   runtimeStatus:row.runtime_status,allowedOrigins:parsed(row.allowed_origins)||[],bindingMethods:parsed(row.binding_methods)||[]};
 });
 return {...state,categories,apps};
}

export function applicationMirrorSql(before,after){
 const statements=[],oldCategories=new Map((before.categories||[]).map(row=>[row.id,JSON.stringify(row)]));
 for(const row of after.categories||[]){
  if(oldCategories.get(row.id)===JSON.stringify(row))continue;
  statements.push(upsert('application_category',{...base(row),runtime_id:row.id,runtime_payload:row,deleted_at:null,
   code:'P4FIX_'+row.code,name:row.name,icon:row.icon||null,sort_order:Number(row.sortOrder)||0,status:row.status||'ENABLED',remark:row.remark||null}));
 }
 const oldApps=new Map((before.apps||[]).map(row=>[row.id,JSON.stringify(row)]));
 for(const row of after.apps||[]){
  if(oldApps.get(row.id)===JSON.stringify(row))continue;
  const category=(after.categories||[]).find(item=>item.id===row.categoryId||item.name===row.category);
  statements.push(upsert('application',{...base(row),runtime_id:row.id,runtime_payload:row,deleted_at:null,
   code:'P4FIX_'+row.code,name:row.name,category_id:dbId(category?.id),platform_id:row.platformId||null,network_zone:row.networkZone||null,
   user_type:row.userType,application_url:row.url,logo_url:row.logoUrl||null,description:row.description||'',
   contact_name:row.contactName||null,technical_contact:row.technicalContact||null,sort_order:Number(row.sortOrder)||0,
   status:row.enabled===false?'DISABLED':'ENABLED',runtime_status:row.connectionStatus==='CONNECTED'?(row.runtimeStatus||'UNCONFIGURED'):'UNCONFIGURED',
   allowed_origins:row.allowedOrigins||[],binding_methods:row.bindingMethods||['SELF','ADMIN']}));
 }
 const currentApps=new Set((after.apps||[]).map(row=>row.id));
 for(const row of before.apps||[]){
  if(currentApps.has(row.id))continue;
  statements.push(`UPDATE ${table('application')} SET deleted_at=now(),updated_at=now(),status='DISABLED',runtime_status='DISABLED',category_id=NULL,code=${literal(archivedCode(row.id))} WHERE id=${literal(dbId(row.id))} AND deleted_at IS NULL;`);
 }
 const currentCategories=new Set((after.categories||[]).map(row=>row.id));
 for(const row of before.categories||[]){
  if(currentCategories.has(row.id))continue;
  statements.push(`UPDATE ${table('application_category')} SET deleted_at=now(),updated_at=now(),status='DISABLED',code=${literal(archivedCode(row.id))} WHERE id=${literal(dbId(row.id))} AND deleted_at IS NULL;`);
 }
 return statements.join('\n');
}
