// Read-only proof after the scoped USER_1 demo reconciliation.
import assert from 'node:assert/strict';
import {createSeed} from '../../src/mock/seed.js';
import {createRepository,sqlQuery} from '../../server/repository.mjs';
import {createPortalService} from '../../src/services/portal.js';
import {targetAppIds,archiveTodoIds,archiveMessageIds} from './reconcile-user1-demo-access.mjs';

const schema='"pb3gir75kkooyea"';
const quote=value=>`'${value.replaceAll("'","''")}'`;
const values=ids=>ids.map(quote).join(',');
const physical=id=>'P4FIX_'+id.replace(/^MOCK_/,'');
const mapId=n=>`MOCK_MAP_MOCK_USER_1_${n}`;
const expectedMappings=new Map([[11,'FAILED'],[12,'CONFLICT'],[24,'BOUND'],[25,'BOUND'],[26,'BOUND'],[28,'BOUND'],[33,'BOUND']]);

const {state,version}=await createRepository().load();
const seed=createSeed();
const actor=state.users.find(user=>user.id==='MOCK_USER_1');
const seedActor=seed.users.find(user=>user.id==='MOCK_USER_1');
assert.ok(actor&&seedActor);
const readApps=async(source,user)=>{
 const result=await createPortalService({kind:'mock',read:()=>source},()=>user).read('apps');
 assert.equal(result.ok,true);
 return new Map(result.data.map(app=>[app.id,app]));
};
const actual=await readApps(state,actor),expected=await readApps(seed,seedActor);
const access=targetAppIds.map(id=>({id,actual:[actual.get(id)?.accessState,actual.get(id)?.primaryAction],expected:[expected.get(id)?.accessState,expected.get(id)?.primaryAction]}));
for(const row of access)assert.deepEqual(row.actual,row.expected,`访问状态未恢复: ${row.id}`);
for(const id of ['MOCK_APP_3','MOCK_APP_24'])assert.equal(state.apps.find(app=>app.id===id)?.userType,'BOTH');
for(const n of [2,3,4,5,6])assert.equal(state.mappings.some(row=>row.id===mapId(n)),false);
for(const [n,status] of expectedMappings)assert.equal(state.mappings.find(row=>row.id===mapId(n))?.status,status);
for(const id of archiveTodoIds)assert.equal(state.todos.some(row=>row.id===id),false);
for(const id of archiveMessageIds)assert.equal(state.messages.find(row=>row.id===id)?.deleted,true);

const detail=JSON.parse(await sqlQuery(`SELECT json_build_object(
 'applications',(SELECT json_agg(json_build_object('id',runtime_id,'userType',user_type,'payloadType',runtime_payload->>'userType','version',version)) FROM ${schema}."application" WHERE runtime_id IN ('MOCK_APP_3','MOCK_APP_24')),
 'snapshotApps',(SELECT json_agg(json_build_object('id',item->>'id','userType',item->>'userType','version',item->>'version')) FROM ${schema}."system_config" c CROSS JOIN LATERAL jsonb_array_elements(c.value::jsonb->'apps') item WHERE c.id='P4RUN_STATE' AND item->>'id' IN ('MOCK_APP_3','MOCK_APP_24')),
 'snapshotRemovedMappings',(SELECT count(*) FROM ${schema}."system_config" c CROSS JOIN LATERAL jsonb_array_elements(c.value::jsonb->'mappings') item WHERE c.id='P4RUN_STATE' AND item->>'id' IN (${values([2,3,4,5,6].map(mapId))})),
 'physicalRemovedMappings',(SELECT count(*) FROM ${schema}."application_user_mapping" WHERE id IN (${values([2,3,4,5,6].map(n=>physical(mapId(n))))})),
 'runtimeRemovedMappings',(SELECT count(*) FROM ${schema}."portal_runtime_entity" WHERE resource='mappings' AND runtime_id IN (${values([2,3,4,5,6].map(mapId))})),
 'physicalMappings',(SELECT json_agg(json_build_object('id',id,'status',status)) FROM ${schema}."application_user_mapping" WHERE id IN (${values([...expectedMappings.keys()].map(n=>physical(mapId(n))))})),
 'scopes',(SELECT json_agg(json_build_object('id',id,'app',application_id)) FROM ${schema}."portal_user_application_scope" WHERE user_id='P4FIX_USER_1' AND application_id IN (${values(targetAppIds.map(physical))})),
 'exceptions',(SELECT json_agg(json_build_object('id',id,'status',resolution_status,'type',exception_type)) FROM ${schema}."mapping_exception" WHERE mapping_id IN (${values([11,12,26,28].map(n=>physical(mapId(n))))})),
 'archivedTodos',(SELECT count(*) FROM ${schema}."todo_item" WHERE runtime_id IN (${values(archiveTodoIds)}) AND archived_at IS NOT NULL),
 'hiddenMessages',(SELECT count(*) FROM ${schema}."message_recipient" r JOIN ${schema}."message" m ON m.id=r.message_id WHERE m.runtime_id IN (${values(archiveMessageIds)}) AND r.user_id='P4FIX_USER_1' AND r.deleted_at IS NOT NULL),
 'archiveCounts',(SELECT json_object_agg(resource,n) FROM (SELECT resource,count(*) n FROM ${schema}."portal_demo_restore_archive" WHERE archive_key LIKE 'USER1_DEMO_RESTORE_%' GROUP BY resource) x)
);`));
for(const rows of [detail.applications,detail.snapshotApps]){
 assert.equal(rows.length,2);
 for(const row of rows){assert.equal(row.userType,'BOTH');assert.equal(Number(row.version),3);if('payloadType' in row)assert.equal(row.payloadType,'BOTH');}
}
assert.equal(Number(detail.snapshotRemovedMappings),0);
assert.equal(Number(detail.physicalRemovedMappings),0);
assert.equal(Number(detail.runtimeRemovedMappings),0);
assert.deepEqual(new Map(detail.physicalMappings.map(row=>[row.id,row.status])),new Map([...expectedMappings].map(([n,status])=>[physical(mapId(n)),status])));
assert.equal(detail.scopes.length,5);
assert.equal(detail.exceptions.length,4);
assert.deepEqual(new Map(detail.exceptions.map(row=>[row.id,row.status])),new Map([[11,'OPEN'],[12,'OPEN'],[26,'RESOLVED'],[28,'RESOLVED']].map(([n,status])=>[`P4FIX_EXCEPTION_${mapId(n)}`,status])));
assert.equal(Number(detail.archivedTodos),7);
assert.equal(Number(detail.hiddenMessages),7);
assert.deepEqual(detail.archiveCounts,{application:2,exception:2,mapping:9,message:7,scope:7,todo:7});
console.log(JSON.stringify({verified:true,version,access,detail}));
