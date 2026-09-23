import {createSeed} from '../../src/mock/seed.js';
import {sqlQuery} from '../../server/repository.mjs';
import {remainingResources} from '../../server/remaining-persistence.mjs';
import {requestMirrorSql} from '../../server/request-persistence.mjs';

const schema='"pb3gir75kkooyea"';
const literal=value=>"'"+String(value).replaceAll("'","''")+"'";
const raw=await sqlQuery(`SELECT json_build_object(
 'snapshot',value::jsonb,
 'domains',(SELECT coalesce(json_agg(resource),'[]'::json) FROM ${schema}."portal_runtime_entity_domain"))
 FROM ${schema}."system_config" WHERE id='P4RUN_STATE';`);
if(!raw)throw new Error('P4RUN_STATE 不存在，无法识别缺省域');
const {snapshot,domains}=JSON.parse(raw),seed=createSeed(),existing=new Set(domains||[]);
const missing=remainingResources.filter(resource=>!Object.hasOwn(snapshot,resource)&&!existing.has(resource));
const statements=[];
for(const resource of missing){
 statements.push(`INSERT INTO ${schema}."portal_runtime_entity_domain"(resource) VALUES (${literal(resource)}) ON CONFLICT DO NOTHING;`);
 for(const [position,item] of (seed[resource]||[]).entries()){
  if(!item.id)continue;
  statements.push(`INSERT INTO ${schema}."portal_runtime_entity"(resource,runtime_id,position,payload)
   VALUES (${literal(resource)},${literal(item.id)},${position},${literal(JSON.stringify(item))}::jsonb)
   ON CONFLICT (resource,runtime_id) DO NOTHING;`);
 }
}
const requestCounts=JSON.parse(await sqlQuery(`SELECT json_build_object(
 'applicationRequests',(SELECT count(*) FROM ${schema}."application_access_request"),
 'applicationGrants',(SELECT count(*) FROM ${schema}."application_access_grant"),
 'accountOpeningRequests',(SELECT count(*) FROM ${schema}."account_opening_request"));`));
const requestKeys=['applicationRequests','applicationGrants','accountOpeningRequests'];
const seedEmptyRequests=process.argv.includes('--seed-empty-requests');
const missingRequests=requestKeys.filter(key=>Number(requestCounts[key])===0&&(
 !Object.hasOwn(snapshot,key)||(seedEmptyRequests&&Array.isArray(snapshot[key])&&snapshot[key].length===0)
));
const requestState=Object.fromEntries(requestKeys.map(key=>[key,missingRequests.includes(key)?seed[key]:[]]));
const requestSql=requestMirrorSql({},requestState);
if(requestSql)statements.push(requestSql);
if(statements.length)await sqlQuery(`BEGIN; SELECT pg_advisory_xact_lock(38013800); ${statements.join('\n')} COMMIT;`);
console.log(JSON.stringify({seededDomains:missing,rows:missing.map(resource=>({resource,count:(seed[resource]||[]).length})),seededRequestDomains:missingRequests}));
