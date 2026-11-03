import test from 'node:test';
import assert from 'node:assert/strict';
import {createMockProvider} from '../src/providers/mock.js';
import {createPortalService} from '../src/services/portal.js';
import {createSeed} from '../src/mock/seed.js';

test('本地门户管理员可查看应用目录但不能进入、申请或关联',async()=>{
 const provider=createMockProvider();
 const actor=provider.read().users.find(user=>user.id==='MOCK_LOCAL_ADMIN');
 const service=createPortalService(provider,()=>actor);
 const catalog=await service.read('apps');
 assert.equal(catalog.ok,true);
 assert.equal(catalog.data.length,41);
 assert(catalog.data.every(app=>app.enabled&&app.applicable===false&&app.primaryAction==='VIEW'));
 assert.equal((await service.read('adminApps')).data.length,42);
 assert.equal((await service.command('enterApp',{id:'MOCK_APP_1'})).error?.code,'FORBIDDEN');
 assert.equal((await service.command('submitApplicationRequest',{appId:'MOCK_APP_13',reason:'查看权限'})).error?.code,'FORBIDDEN');
 assert.equal((await service.command('bind',{appId:'MOCK_APP_2',externalAccount:'x'})).error?.code,'FORBIDDEN');
});

test('公众身份仍按适用范围读取，无应用查看权限的管理身份不获得目录',async()=>{
 const provider=createMockProvider();
 const citizen=provider.read().users.find(user=>user.id==='MOCK_USER_1');
 const citizenApps=await createPortalService(provider,()=>citizen).read('apps');
 const expected=createSeed().apps.filter(app=>app.enabled&&['BOTH','CITIZEN'].includes(app.userType));
 assert.equal(citizenApps.data.length,expected.length);
 assert(citizenApps.data.every(app=>app.applicable));
 provider.transact(state=>{
  const local=state.users.find(user=>user.id==='MOCK_LOCAL_ADMIN');
  local.permissions=[];
  local.roleIds=[];
 });
 const local=provider.read().users.find(user=>user.id==='MOCK_LOCAL_ADMIN');
 const service=createPortalService(provider,()=>local);
 assert.equal((await service.read('apps')).data.length,0);
 assert.equal((await service.read('adminApps')).error?.code,'FORBIDDEN');
});
