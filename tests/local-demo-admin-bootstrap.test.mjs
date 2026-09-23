import test from 'node:test';
import assert from 'node:assert/strict';
import {localDemoAdmin,demoAdminTimestamps,buildLocalAdminReadSql,buildLocalAdminPatchSql} from '../database/validation/bootstrap-local-demo-admin.mjs';

test('仅使用模拟本地管理员身份，不写入真实密码材料',()=>{
 assert.equal(localDemoAdmin.id,'MOCK_LOCAL_ADMIN');
 assert.equal(localDemoAdmin.authType,'LOCAL');
 assert.equal(localDemoAdmin.account,'admin');
 assert.equal(localDemoAdmin.roleIds.includes('ROLE_SUPER'),true);
 assert.equal(Object.keys(localDemoAdmin).some(key=>/^(password|secret|credential)/i.test(key)),false);
 assert.match(demoAdminTimestamps.createdAt,/^\d{4}-\d\d-\d\dT/);
 assert.match(demoAdminTimestamps.updatedAt,/^\d{4}-\d\d-\d\dT/);
});

test('预览只读，补种精确匹配用户、身份索引和已有管理员角色',()=>{
 const read=buildLocalAdminReadSql(),patch=buildLocalAdminPatchSql();
 assert.doesNotMatch(read,/\bINSERT\b|\bUPDATE\b|\bDELETE\b/);
 for(const target of ['portal_runtime_entity','unified_user','portal_user_role'])assert.match(patch,new RegExp(`INSERT INTO .*${target}`));
 assert.match(patch,/P4FIX_LOCAL_ADMIN/);
 assert.match(patch,/P4FIX_ROLE_ADMIN/);
 assert.match(patch,/P4FIX_ADMIN/);
 assert.match(patch,/ON CONFLICT \(id\) DO NOTHING/);
 assert.match(patch,/ON CONFLICT \(resource,runtime_id\) DO NOTHING/);
 assert.match(patch,/ON CONFLICT DO NOTHING/);
 assert.doesNotMatch(patch,/\bUPDATE\b|\bDELETE\b|password_hash|password_digest/);
 assert.doesNotMatch(patch,/undefined|VALUES \([^)]*'null'/i);
 assert.equal(patch.includes(demoAdminTimestamps.createdAt),true);
 assert.equal(patch.includes(demoAdminTimestamps.updatedAt),true);
});
