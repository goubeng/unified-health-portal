import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

const read=path=>fs.readFileSync(path,'utf8');

test('V20260921-01 uses resource action permissions as frontend authority',()=>{
  const pages=read('src/config/pages.js');
  const roles=read('src/components/portal/RoleManagement.vue');
  const seed=read('src/mock/seed.js');
  const service=read('src/services/portal.js');

  assert(pages.includes('rolePermissionGroups'));
  for(const code of ['application:view','admin-user:assign-role','announcement:publish','integration:test','monitor:check']){
    assert(pages.includes(code),'缺少权限码 '+code);
  }
  assert(roles.includes('selectedPermissions'));
  assert(roles.includes("permissions:[...(form.permissions||[])]"));
  assert(!seed.includes('scopes:'),'新Mock Seed不得继续写scopes');
  assert(!service.includes('scopesFromPermissions'),'Service不得把permissions反写回scopes');
  assert(!service.includes('user.scopes='),'用户授权不得写scopes');
});

test('LOCAL is admin auth type and not an access user type',()=>{
  const seed=read('src/mock/seed.js');
  const users=read('src/components/portal/UserManagement.vue');
  const mappings=read('src/components/portal/IdentityMappings.vue');
  assert(seed.includes("authType:'LOCAL'"));
  assert(!seed.includes("userType:'LOCAL'"));
  assert(!users.includes("userType==='LOCAL'"));
  assert(!users.includes("userType:'LOCAL'"));
  assert(users.includes("authType:'LOCAL'"));
  assert(mappings.includes("{value:'CITIZEN',label:'公众用户'}"));
  assert(mappings.includes("{value:'GOV',label:'政务用户'}"));
});

test('applications and integrations consume canonical enablement and status DTOs',()=>{
  const cards=read('src/components/portal/AppCards.vue');
  const access=read('src/components/portal/AccessConfigDetail.vue');
  const monitor=read('src/components/portal/MonitorManagement.vue');
  const page=read('src/views/PortalPage.vue');
  assert(cards.includes('app.enabled===false'));
  assert(!cards.includes('app.status'));
  assert(page.includes("fieldMap={apps:['name','code','category','userType','accessMode','aggregateRuntimeStatus','enabled']"));
  for(const source of [access,monitor]){
    assert(source.includes('configStatus'));
    assert(source.includes('runtimeStatus'));
    assert(source.includes('enabled'));
    assert(!source.includes('configurationStatus'));
    assert(!source.includes('connectionStatus'));
  }
});

test('todo and message received time is frozen as receivedAt',()=>{
  const todo=read('src/components/portal/TodoCenter.vue');
  const todoDetail=read('src/components/portal/TodoDetailContent.vue');
  const message=read('src/components/portal/MessageCenter.vue');
  const record=read('src/components/portal/RecordDetail.vue');
  const seed=read('src/mock/seed.js');

  assert(todo.includes("colKey:'createdAt'")===false);
  assert(todo.includes("colKey:'receivedAt'"));
  assert(!todo.includes('receivedAt||'));
  assert(todoDetail.includes('date(record.receivedAt)'));
  assert(!todoDetail.includes('date(record.createdAt)'));
  assert(message.includes("colKey:'receivedAt'"));
  assert(!message.includes('receivedAt||'));
  assert(record.includes('{{date(record.receivedAt)}}'));
  assert(seed.includes('receivedAt:at(-i-2)'));
  assert(seed.includes('receivedAt:at(-i-1)'));
});

test('session DTO is split before B stage',()=>{
  const runtime=read('src/services/runtime.js');
  const api=read('server/api.mjs');
  for(const field of ['accessSubject','adminUser','adminAccess','roles','permissions','authType','identitySource']){
    assert(runtime.includes(field),'runtime session缺少 '+field);
    assert(api.includes(field),'api session缺少 '+field);
  }
  assert(runtime.includes('actorFromSession'));
  assert(!api.includes('   actor,\n   accessSubject:'));
});

test('demo closeout documents use V20260921-01 and do not claim production integration completion',()=>{
  const plan=read('docs/02-开发/03-计划/0.3.0分阶段改造执行计划.md');
  const baseline=read('.project/BASELINE.md');
  assert(plan.includes('V20260921-01'));
  assert(plan.includes('A3_FIX_AND_FREEZE_IN_PROGRESS / TEST_RERUN_PENDING'));
  assert(plan.includes('MANUAL_PASS'));
  assert(plan.includes('DEMO_FRONTEND_FROZEN'));
  assert(plan.includes('OUT_OF_CURRENT_DEMO_SCOPE'));
  assert(baseline.includes('P4_GATE_PASS / P5_DEMO_SCOPE_PASS'));
  assert(baseline.includes('MANUAL_PASS'));
  assert(baseline.includes('npm run dev:mock'));
  assert(baseline.includes('生产级数据库改造和真实联调不属于当前原型验收范围'));
  assert(!baseline.includes('生产级数据库改造和真实联调已完成'));
});
