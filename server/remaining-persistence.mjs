import {createHash} from 'node:crypto';

export const remainingResources=[
 'users','roles','organizations','dictTypes','dictItems','mappings','settings',
 'integrations','monitorSamples','mappingVerificationEvents','visits','receipts'
];

const schema='"pb3gir75kkooyea"';
const literal=value=>"'"+String(value).replaceAll("'","''")+"'";
const hash=value=>createHash('md5').update(value).digest('hex');
const recordId=(resource,item)=>{
 if(resource==='visits')return hash(`${item.userId||''}|${item.appId||''}|${item.at||''}`);
 if(resource==='receipts')return hash(`${item.appId||''}|${item.kind||'MESSAGE'}|${item.eventId||''}`);
 return String(item.id);
};

export async function loadRemainingState(query,state){
 const raw=await query(`SELECT coalesce(json_agg(row_to_json(t)),'[]'::json) FROM (
  SELECT d.resource,coalesce(json_agg(e.payload ORDER BY e.position,e.runtime_id) FILTER (WHERE e.runtime_id IS NOT NULL),'[]'::json) AS items
  FROM ${schema}."portal_runtime_entity_domain" d
  LEFT JOIN ${schema}."portal_runtime_entity" e ON e.resource=d.resource
  GROUP BY d.resource
 ) t;`);
 const entries=JSON.parse(raw||'[]'),next={...state};
 for(const {resource,items} of entries)if(remainingResources.includes(resource))next[resource]=items;
 return next;
}

export function remainingMirrorSql(before,after){
 const statements=[];
 for(const resource of remainingResources){
  const oldItems=before[resource]||[],newItems=after[resource]||[];
  const previous=new Map(oldItems.map((item,index)=>[recordId(resource,item),{item,index}]));
  const current=new Map(newItems.map((item,index)=>[recordId(resource,item),{item,index}]));
  if(previous.size===current.size&&[...current].every(([id,{item,index}])=>previous.get(id)?.index===index&&JSON.stringify(previous.get(id)?.item)===JSON.stringify(item)))continue;
  statements.push(`INSERT INTO ${schema}."portal_runtime_entity_domain"(resource) VALUES (${literal(resource)}) ON CONFLICT DO NOTHING;`);
  for(const [id,{item,index}] of current)if(previous.get(id)?.index!==index||JSON.stringify(previous.get(id)?.item)!==JSON.stringify(item))statements.push(
   `INSERT INTO ${schema}."portal_runtime_entity"(resource,runtime_id,position,payload,updated_at) VALUES (${literal(resource)},${literal(id)},${index},${literal(JSON.stringify(item))}::jsonb,now()) ON CONFLICT (resource,runtime_id) DO UPDATE SET position=excluded.position,payload=excluded.payload,updated_at=excluded.updated_at;`
  );
  for(const id of previous.keys())if(!current.has(id))statements.push(
   `DELETE FROM ${schema}."portal_runtime_entity" WHERE resource=${literal(resource)} AND runtime_id=${literal(id)};`
  );
 }
 return statements.join('\n');
}
