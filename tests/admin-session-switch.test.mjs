import test from 'node:test';
import assert from 'node:assert/strict';
import {Readable} from 'node:stream';
import {createPortalApi} from '../server/api.mjs';
import {createMemoryRepository} from '../server/repository.mjs';
import {can,shouldLoadAppCatalog,switchTarget} from '../src/config/pages.js';
import {createSeed} from '../src/mock/seed.js';
import {canSwitchUser} from '../src/services/runtime.js';

test('会话切换列出可登录的本地 admin，授权外部用户后可读取管理端',async()=>{
 const api=createPortalApi({repository:createMemoryRepository()});
 let cookie='';
 const request=async(path,payload,expectedStatus=200)=>{
  const req=Readable.from(payload===undefined?[]:[JSON.stringify(payload)]);
  Object.assign(req,{url:'/api/portal/'+path,method:payload===undefined?'GET':'POST',headers:{host:'localhost:4011',cookie,origin:'http://localhost:4010'}});
  let status,result;const headers={};
  const res={setHeader(key,value){headers[key]=value;},writeHead(value){status=value;this.headersSent=true;},end(value){result=JSON.parse(value);}};
  await api.handle(req,res);
  if(headers['Set-Cookie'])cookie=headers['Set-Cookie'].split(';')[0];
  assert.equal(status,expectedStatus,JSON.stringify(result));
  return result;
 };

 const initial=(await request('session')).data;
 assert(initial.users.some(user=>user.id==='MOCK_LOCAL_ADMIN'&&user.account==='admin'));
 assert(canSwitchUser(initial.users.find(user=>user.id==='MOCK_LOCAL_ADMIN')));
 const local=(await request('session',{userId:'MOCK_LOCAL_ADMIN'})).data;
 assert.equal(local.adminAccess,true);
 assert(local.permissions.includes('system:super'));
 assert.equal((await request('read?resource=adminHome')).ok,true);
 const localActor={...local.adminUser,adminAccess:local.adminAccess,permissions:local.permissions};
 assert.equal(switchTarget({path:'/portal/home',fullPath:'/portal/home',meta:{scope:null}},localActor),'/admin/home');

 const assigned=await request('command',{action:'createExternalPortalAdmin',payload:{accessUserId:'MOCK_USER_1',enabled:true,roleIds:['ROLE_ADMIN']}});
 assert.equal(assigned.ok,true);
 const external=(await request('session',{userId:'MOCK_USER_1'})).data;
 assert.equal(external.adminAccess,true);
 assert(external.roles.some(role=>role.id==='ROLE_ADMIN'));
 assert(external.permissions.includes('application:view'));
 assert.equal((await request('read?resource=adminHome')).ok,true);
 assert.equal((await request('read?resource=adminApps')).ok,true);
 const externalActor={...external.adminUser,adminAccess:external.adminAccess,permissions:external.permissions};
 assert.equal(switchTarget({path:'/portal/home',fullPath:'/portal/home',meta:{scope:null}},externalActor),'/admin/home');
 assert.equal(switchTarget({path:'/admin/home',fullPath:'/admin/home',meta:{scope:'any'}},{id:'MOCK_USER_2',enabled:true,kind:'USER'}),'/portal/home');
});

test('停用用户保留在切换清单但不能模拟登录',async()=>{
 const seed=createSeed();
 seed.users.push({...seed.users[0],id:'MOCK_DISABLED',account:'disabled',status:'DISABLED',enabled:false});
 const api=createPortalApi({repository:createMemoryRepository(seed)});
 const read=Readable.from([]);
 Object.assign(read,{url:'/api/portal/session',method:'GET',headers:{host:'localhost:4011'}});
 let session;const readRes={setHeader(){},writeHead(){this.headersSent=true;},end(value){session=JSON.parse(value).data;}};
 await api.handle(read,readRes);
 const disabled=session.users.find(user=>user.id==='MOCK_DISABLED');
 assert(disabled);
 assert.equal(canSwitchUser(disabled),false);
 const login=Readable.from([JSON.stringify({userId:'MOCK_DISABLED'})]);
 Object.assign(login,{url:'/api/portal/session',method:'POST',headers:{host:'localhost:4011',origin:'http://localhost:4010'}});
 let status,response;const loginRes={setHeader(){},writeHead(value){status=value;this.headersSent=true;},end(value){response=JSON.parse(value);}};
 await api.handle(login,loginRes);
 assert.equal(status,403);
 assert.equal(response.error.code,'FORBIDDEN');
});

test('内容管理员可进入公告，不会因无应用目录权限触发跨模块拒绝',async()=>{
 const seed=createSeed(),editor=seed.users.find(user=>user.id==='MOCK_EDITOR');
 seed.roles.push({...seed.roles[1],id:'ROLE_CONTENT',roleCode:'PORTAL_CONTENT_ADMIN',roleName:'内容管理员',permissions:['announcement:view','announcement:edit','announcement:publish']});
 editor.roleIds=['ROLE_CONTENT'];editor.permissions=['announcement:view','announcement:edit','announcement:publish'];
 const api=createPortalApi({repository:createMemoryRepository(seed)});
 const req=Readable.from([JSON.stringify({userId:'MOCK_EDITOR'})]);
 Object.assign(req,{url:'/api/portal/session',method:'POST',headers:{host:'localhost:4011',origin:'http://localhost:4010'}});
 let session,cookie;const res={setHeader(key,value){if(key==='Set-Cookie')cookie=value.split(';')[0];},writeHead(){this.headersSent=true;},end(value){session=JSON.parse(value).data;}};
 await api.handle(req,res);
 const actor={...session.adminUser,adminAccess:session.adminAccess,permissions:session.permissions};
 assert.equal(can(actor,'announcement:view'),true);
 assert.equal(can(actor,'application:view'),false);
 assert.equal(shouldLoadAppCatalog(true,actor),false);
 const read=Readable.from([]);
 Object.assign(read,{url:'/api/portal/read?resource=adminAnnouncements',method:'GET',headers:{host:'localhost:4011',cookie}});
 let response;const readRes={setHeader(){},writeHead(){this.headersSent=true;},end(value){response=JSON.parse(value);}};
 await api.handle(read,readRes);
 assert.equal(response.ok,true);
});

test('预置本地超级管理员无法被停用或移除超级角色',async()=>{
 const api=createPortalApi({repository:createMemoryRepository()});
 let cookie='';
 const request=async(path,payload,expectedStatus=200)=>{
  const req=Readable.from([JSON.stringify(payload)]);
  Object.assign(req,{url:'/api/portal/'+path,method:'POST',headers:{host:'localhost:4011',cookie,origin:'http://localhost:4010'}});
  let status,result;const headers={};
  const res={setHeader(key,value){headers[key]=value;},writeHead(value){status=value;this.headersSent=true;},end(value){result=JSON.parse(value);}};
  await api.handle(req,res);
  if(headers['Set-Cookie'])cookie=headers['Set-Cookie'].split(';')[0];
  assert.equal(status,expectedStatus,JSON.stringify(result));
  return result;
 };
 await request('session',{userId:'MOCK_LOCAL_ADMIN'});
 const users=await request('command',{action:'savePortalUser',payload:{id:'MOCK_ADMIN',enabled:true,roleIds:['ROLE_SUPER']}},200);
 assert.equal(users.ok,true,'第二个有效超级管理员存在时也必须保护预置账号');
 const disabled=await request('command',{action:'setPortalUserStatus',payload:{id:'MOCK_LOCAL_ADMIN',enabled:false}},409);
 assert.equal(disabled.error.code,'INVALID_TRANSITION');
 const demoted=await request('command',{action:'savePortalUser',payload:{id:'MOCK_LOCAL_ADMIN',enabled:true,roleIds:['ROLE_ADMIN']}},409);
 assert.equal(demoted.error.code,'INVALID_TRANSITION');
});
