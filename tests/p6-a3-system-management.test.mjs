import test from 'node:test';
import assert from 'node:assert/strict';
import {createMockProvider} from '../src/providers/mock.js';
import {createPortalService} from '../src/services/portal.js';
import {actors} from '../src/mock/seed.js';

function setup(index=2){
  let actor=actors[index];
  const provider=createMockProvider();
  const service=createPortalService(provider,()=>actor);
  return {
    provider,service,switchActor:i=>{actor=actors[i];},
    read:async resource=>{const result=await service.read(resource);assert.equal(result.ok,true,JSON.stringify(result));return result.data;},
    run:async(action,payload)=>{const result=await service.command(action,payload);assert.equal(result.ok,true,JSON.stringify(result));return result.data;}
  };
}

test('门户管理员可读用户组织字典目录但不能执行超级管理员本地账号操作',async()=>{
  const h=setup(3);
  assert((await h.read('users')).length>=5);
  assert((await h.read('organizations')).length>=3);
  const dictionaries=await h.read('dictionaries');
  assert(dictionaries.types.some(x=>x.code==='application_category'));
  assert(dictionaries.items.some(x=>x.typeCode==='integration_protocol'));

  const local=(await h.read('users')).find(x=>x.userType==='LOCAL');
  const stop=await h.service.command('setPortalUserStatus',{id:local.id,version:local.version,status:'DISABLED'});
  assert.equal(stop.error?.code,'FORBIDDEN');

  const create=await h.service.command('createLocalPortalUser',{account:'local02',name:'本地维护员'});
  assert.equal(create.error?.code,'FORBIDDEN');
});

test('超级管理员可创建本地用户且不返回密码或密码Hash',async()=>{
  const h=setup(2);
  const created=await h.run('createLocalPortalUser',{
    account:'local02',name:'本地维护员',orgName:'门户运行保障中心',mobile:'13800000000',email:'local02@example.invalid',roleIds:['ROLE_ADMIN']
  });
  assert.equal(created.userType,'LOCAL');
  assert.equal(created.identitySource,'门户本地');
  assert.equal(created.roleLabels,'门户管理员');
  assert.equal(created.mustChangePassword,true);
  assert(!Object.hasOwn(created,'password'));
  assert(!Object.hasOwn(created,'passwordHash'));
  assert(!Object.hasOwn(created,'password_hash'));

  const row=(await h.read('users')).find(x=>x.id===created.id);
  assert(row);
  assert.equal(row.kind,'ADMIN');
});

test('外部用户编辑只改变门户状态角色，不修改上游身份主数据',async()=>{
  const h=setup(2);
  const user=(await h.read('users')).find(x=>x.id==='MOCK_USER_1');
  const saved=await h.run('savePortalUser',{
    id:user.id,version:user.version,status:'NORMAL',roleIds:['ROLE_ADMIN'],
    name:'篡改姓名',orgName:'篡改组织',mobile:'10086',email:'bad@example.invalid'
  });
  assert.equal(saved.name,user.name);
  assert.equal(saved.orgName,user.orgName);
  assert.equal(saved.mobile,user.mobile);
  assert.equal(saved.email,user.email);
  assert(saved.roleIds.includes('ROLE_ADMIN'));
});

test('组织管理区分闽政务只读主数据与门户本地可维护组织',async()=>{
  const h=setup(3);
  const rows=await h.read('organizations');
  const upstream=rows.find(x=>x.source==='MINZHENGWU');
  const denied=await h.service.command('saveOrganization',{...upstream,name:'试图修改上游组织'});
  assert.equal(denied.error?.code,'INVALID_TRANSITION');

  const created=await h.run('saveOrganization',{code:'ORG_LOCAL_TEST',name:'本地测试组织',type:'OTHER',status:'ENABLED',source:'PORTAL_LOCAL',remark:'Mock'});
  assert.equal(created.source,'PORTAL_LOCAL');
  assert.equal(created.path,'本地测试组织');
});

test('系统受控字典不能新增未知协议，但允许维护已支持项显示信息',async()=>{
  const h=setup(3);
  const dict=await h.read('dictionaries');
  const protocol=dict.types.find(x=>x.code==='integration_protocol');
  assert.equal(protocol.systemLocked,true);

  const denied=await h.service.command('saveDictionaryItem',{typeCode:'integration_protocol',label:'未知协议',value:'UNKNOWN',status:'ENABLED'});
  assert.equal(denied.error?.code,'INVALID_TRANSITION');

  const oidc=dict.items.find(x=>x.typeCode==='integration_protocol'&&x.value==='OIDC');
  const saved=await h.run('saveDictionaryItem',{...oidc,label:'OIDC 2.0',sortOrder:oidc.sortOrder,status:'ENABLED'});
  assert.equal(saved.value,'OIDC');
  assert.equal(saved.label,'OIDC 2.0');
});

test('应用系统分类字典项保存后同步应用分类目录',async()=>{
  const h=setup(3);
  const dict=await h.read('dictionaries');
  const item=dict.items.find(x=>x.typeCode==='application_category'&&x.value==='PUBLIC');
  await h.run('saveDictionaryItem',{...item,label:'公众健康服务',status:'ENABLED'});
  const categories=await h.read('categories');
  assert.equal(categories.find(x=>x.code==='PUBLIC').name,'公众健康服务');
});

test('角色页只预置两个内置角色，super权限不能授予其它角色',async()=>{
  const h=setup(2);
  const roles=await h.read('roles');
  const builtIn=roles.filter(x=>x.builtIn);
  assert.deepEqual(builtIn.map(x=>x.roleCode).sort(),['PORTAL_ADMIN','SUPER_ADMIN']);

  const admin=roles.find(x=>x.roleCode==='PORTAL_ADMIN');
  const denied=await h.service.command('saveSystemRole',{...admin,scopes:[...(admin.scopes||[]),'super']});
  assert.equal(denied.error?.code,'INVALID_TRANSITION');
});
