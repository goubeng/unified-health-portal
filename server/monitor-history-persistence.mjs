const table='"pb3gir75kkooyea"."monitor_status_history"';
const literal=value=>value==null?'NULL':"'"+String(value).replaceAll("'","''")+"'";
const dbId=id=>id?'P4FIX_'+String(id).replace(/^MOCK_/,''):null;
const runtimeId=id=>id?.startsWith('P4FIX_')?'MOCK_'+id.slice(6):id;

export async function loadMonitorHistory(query){
 const raw=await query(`SELECT coalesce(json_agg(r ORDER BY r.occurred_at DESC,r.id DESC),'[]'::json) FROM (SELECT id,application_id,service_type,from_status,to_status,occurred_at,reason,source FROM ${table}) r;`);
 return JSON.parse(raw||'[]').map(row=>({id:runtimeId(row.id),appId:runtimeId(row.application_id),kind:row.service_type,fromStatus:row.from_status,toStatus:row.to_status,occurredAt:row.occurred_at,reason:row.reason,source:row.source}));
}

export function monitorHistoryMirrorSql(before,after){
 const known=new Set((before.monitorHistory||[]).map(row=>row.id));
 return (after.monitorHistory||[]).filter(row=>!known.has(row.id)).map(row=>`INSERT INTO ${table}(id,application_id,service_type,from_status,to_status,occurred_at,reason,source) VALUES (${literal(dbId(row.id))},${literal(dbId(row.appId))},${literal(row.kind)},${literal(row.fromStatus)},${literal(row.toStatus)},${literal(row.occurredAt)},${literal(row.reason)},${literal(row.source)}) ON CONFLICT (id) DO NOTHING;`).join('\n');
}
