// Normalized persistence for the portal's local request and grant workflow.
const schema='pb3gir75kkooyea';
const table=name=>`"${schema}"."${name}"`;
const dbId=id=>id?'P4FIX_'+String(id).replace(/^(MOCK_|P4FIX_)/,''):null;
const runtimeId=id=>id?(String(id).startsWith('P4FIX_')?'MOCK_'+String(id).slice(6):String(id)):null;
const literal=value=>value==null?'NULL':"'"+String(value).replaceAll("'","''")+"'";
const columns=object=>Object.keys(object).map(key=>`"${key}"`).join(',');
const values=object=>Object.values(object).map(literal).join(',');
const upsert=(name,row)=>{
 const updates=Object.keys(row).filter(key=>!['id','created_at'].includes(key)).map(key=>`"${key}"=EXCLUDED."${key}"`).join(',');
 return `INSERT INTO ${table(name)} (${columns(row)}) VALUES (${values(row)}) ON CONFLICT (id) DO UPDATE SET ${updates};`;
};
const base=row=>({id:dbId(row.id),runtime_id:row.id,created_at:row.createdAt,updated_at:row.updatedAt,version:row.version||1});
const common=row=>({...base(row),user_id:dbId(row.userId),application_id:dbId(row.appId),reason:row.reason||'',contact:row.contact||'',remark:row.remark||'',status:row.status,submitted_at:row.submittedAt||row.createdAt});
const types=[
 {key:'applicationRequests',table:'application_access_request',map:row=>({...common(row),request_no:row.requestNo,reviewed_by:dbId(row.reviewedBy),reviewed_at:row.reviewedAt||null,review_note:row.reviewNote||null,withdrawn_at:row.withdrawnAt||null,expired_at:row.expiredAt||null})},
 {key:'applicationGrants',table:'application_access_grant',map:row=>({...base(row),user_id:dbId(row.userId),application_id:dbId(row.appId),status:row.status,granted_by:dbId(row.grantedBy),granted_at:row.grantedAt||null,expires_at:row.expiresAt||null})},
 {key:'accountOpeningRequests',table:'account_opening_request',map:row=>({...common(row),request_no:row.requestNo,handled_by:dbId(row.handledBy),handled_at:row.handledAt||null,handle_note:row.handleNote||null})}
];

export function requestMirrorSql(before,after){
 const statements=[];
 for(const type of types){
  const old=new Map((before[type.key]||[]).map(row=>[row.id,JSON.stringify(row)]));
  const next=after[type.key]||[];
  for(const row of next)if(old.get(row.id)!==JSON.stringify(row))statements.push(upsert(type.table,type.map(row)));
  const nextIds=new Set(next.map(row=>row.id));
  for(const row of before[type.key]||[])if(!nextIds.has(row.id))statements.push(`DELETE FROM ${table(type.table)} WHERE id=${literal(dbId(row.id))};`);
 }
 return statements.join('\n');
}

const parse=data=>typeof data==='string'?JSON.parse(data):data;
const date=value=>value||null;
const identity=row=>({id:row.runtime_id||runtimeId(row.id),createdAt:row.created_at,updatedAt:row.updated_at,version:Number(row.version)||1,userId:runtimeId(row.user_id),appId:runtimeId(row.application_id)});
const request=row=>({...identity(row),requestNo:row.request_no,reason:row.reason,contact:row.contact||'',remark:row.remark||'',status:row.status,submittedAt:row.submitted_at});

export async function loadRequestState(query,state){
 const raw=await query(`SELECT json_build_object(
  'applicationRequests',coalesce((SELECT json_agg(r ORDER BY r.submitted_at,r.id) FROM ${table('application_access_request')} r),'[]'::json),
  'applicationGrants',coalesce((SELECT json_agg(g ORDER BY g.created_at,g.id) FROM ${table('application_access_grant')} g),'[]'::json),
  'accountOpeningRequests',coalesce((SELECT json_agg(o ORDER BY o.submitted_at,o.id) FROM ${table('account_opening_request')} o),'[]'::json)
 );`);
 const data=parse(raw)||{},users=new Map((state.users||[]).map(row=>[row.id,row.name])),apps=new Map((state.apps||[]).map(row=>[row.id,row.name]));
 const named=row=>({...row,userName:users.get(row.userId)||'',appName:apps.get(row.appId)||''});
 return {...state,
  applicationRequests:(data.applicationRequests||[]).map(row=>named({...request(row),reviewedBy:runtimeId(row.reviewed_by),reviewedAt:date(row.reviewed_at),reviewNote:date(row.review_note),withdrawnAt:date(row.withdrawn_at),expiredAt:date(row.expired_at)})),
  applicationGrants:(data.applicationGrants||[]).map(row=>({...identity(row),status:row.status,grantedBy:runtimeId(row.granted_by),grantedAt:date(row.granted_at),expiresAt:date(row.expires_at)})),
  accountOpeningRequests:(data.accountOpeningRequests||[]).map(row=>named({...request(row),handledBy:runtimeId(row.handled_by),handledAt:date(row.handled_at),handleNote:date(row.handle_note)}))
 };
}
