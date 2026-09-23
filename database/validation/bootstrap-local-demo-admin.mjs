import {fileURLToPath} from 'node:url';
import {resolve} from 'node:path';
import {createSeed} from '../../src/mock/seed.js';
import {sqlQuery} from '../../server/repository.mjs';

const schema='"pb3gir75kkooyea"';
const literal=value=>"'"+String(value).replaceAll("'","''")+"'";
const seed=createSeed();
export const localDemoAdmin=seed.users.find(user=>user.id==='MOCK_LOCAL_ADMIN');
export const demoAdminTimestamps={createdAt:seed.apps[0]?.createdAt,updatedAt:seed.apps[0]?.updatedAt};
if(!localDemoAdmin||localDemoAdmin.authType!=='LOCAL'||Object.keys(localDemoAdmin).some(key=>/^(password|secret|credential)/i.test(key)))throw new Error('本地演示管理员种子不安全');
if(Object.values(demoAdminTimestamps).some(value=>!/^\d{4}-\d\d-\d\dT\d\d:\d\d:\d\d\.\d{3}Z$/.test(value)))throw new Error('本地演示管理员时间戳无效');

export const buildLocalAdminReadSql=()=>`SELECT json_build_object(
 'runtimeUser',(SELECT payload FROM ${schema}."portal_runtime_entity" WHERE resource='users' AND runtime_id='MOCK_LOCAL_ADMIN'),
 'physicalUser',(SELECT json_build_object('id',id,'displayName',display_name,'status',status) FROM ${schema}."unified_user" WHERE id='P4FIX_LOCAL_ADMIN'),
 'roleAssignment',(SELECT json_build_object('id',id,'roleId',role_id) FROM ${schema}."portal_user_role" WHERE user_id='P4FIX_LOCAL_ADMIN' AND role_id='P4FIX_ROLE_ADMIN'),
 'superRolePresent',EXISTS(SELECT 1 FROM ${schema}."portal_role" WHERE id='P4FIX_ROLE_ADMIN' AND status='ENABLED'),
 'grantorPresent',EXISTS(SELECT 1 FROM ${schema}."unified_user" WHERE id='P4FIX_ADMIN')
);`;

export const buildLocalAdminPatchSql=()=>`BEGIN;
SELECT pg_advisory_xact_lock(38013800);
DO $$ BEGIN
 IF NOT EXISTS(SELECT 1 FROM ${schema}."portal_role" WHERE id='P4FIX_ROLE_ADMIN' AND status='ENABLED')
 OR NOT EXISTS(SELECT 1 FROM ${schema}."unified_user" WHERE id='P4FIX_ADMIN')
 OR NOT EXISTS(SELECT 1 FROM ${schema}."portal_runtime_entity_domain" WHERE resource='users')
 THEN RAISE EXCEPTION 'Local demo admin prerequisites missing'; END IF;
 IF EXISTS(SELECT 1 FROM ${schema}."portal_runtime_entity" WHERE resource='users' AND runtime_id='MOCK_LOCAL_ADMIN'
  AND payload->>'account' IS DISTINCT FROM 'admin')
 OR EXISTS(SELECT 1 FROM ${schema}."unified_user" WHERE id='P4FIX_LOCAL_ADMIN'
  AND display_name IS DISTINCT FROM ${literal(localDemoAdmin.name)})
 THEN RAISE EXCEPTION 'Local demo admin identity conflict'; END IF;
END $$;
INSERT INTO ${schema}."unified_user"(id,created_at,updated_at,version,display_name,org_key,org_name,status)
VALUES ('P4FIX_LOCAL_ADMIN',${literal(demoAdminTimestamps.createdAt)},${literal(demoAdminTimestamps.updatedAt)},1,
 ${literal(localDemoAdmin.name)},'P4FIX_PORTAL',${literal(localDemoAdmin.orgName)},'NORMAL')
ON CONFLICT (id) DO NOTHING;
INSERT INTO ${schema}."portal_runtime_entity"(resource,runtime_id,position,payload)
SELECT 'users','MOCK_LOCAL_ADMIN',coalesce(max(position),-1)+1,${literal(JSON.stringify(localDemoAdmin))}::jsonb
FROM ${schema}."portal_runtime_entity" WHERE resource='users'
ON CONFLICT (resource,runtime_id) DO NOTHING;
INSERT INTO ${schema}."portal_user_role"(id,created_at,updated_at,version,user_id,role_id,granted_by)
VALUES ('P4FIX_UR_MOCK_LOCAL_ADMIN',${literal(demoAdminTimestamps.createdAt)},${literal(demoAdminTimestamps.updatedAt)},1,
 'P4FIX_LOCAL_ADMIN','P4FIX_ROLE_ADMIN','P4FIX_ADMIN')
ON CONFLICT DO NOTHING;
${buildLocalAdminReadSql()}
COMMIT;`;

if(process.argv[1]&&fileURLToPath(import.meta.url)===resolve(process.argv[1])){
 const before=JSON.parse(await sqlQuery(buildLocalAdminReadSql()));
 console.log(JSON.stringify({mode:process.argv.includes('--apply')?'apply':'preview',before}));
 if(process.argv.includes('--apply')){
  const applied=JSON.parse(await sqlQuery(buildLocalAdminPatchSql()));
  console.log(JSON.stringify({after:applied,complete:Boolean(applied.runtimeUser&&applied.physicalUser&&applied.roleAssignment)}));
 }
}
