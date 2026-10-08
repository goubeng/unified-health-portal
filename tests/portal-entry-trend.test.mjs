import test from 'node:test';
import assert from 'node:assert/strict';
import {Readable} from 'node:stream';
import {createSeed} from '../src/mock/seed.js';
import {createPortalService} from '../src/services/portal.js';
import {createPortalApi} from '../server/api.mjs';
import {createMemoryRepository} from '../server/repository.mjs';

test('成功首次进入门户计一次；切换、退出、应用访问和认证失败不增加访问量',async()=>{
 const state=createSeed(),now=new Date().toISOString();
 state.logs=[
  {kind:'access',name:'enterApp',status:'SUCCESS',createdAt:now},
  {kind:'login',name:'LOGIN',status:'FAILURE',createdAt:now},
  {kind:'auth',name:'IDENTITY_ACCEPTED',status:'SUCCESS',createdAt:now}
 ];
 const repository=createMemoryRepository(state),api=createPortalApi({repository});
 let cookie='';
 const post=async(path,payload={})=>{
  const req=Readable.from([JSON.stringify(payload)]),headers={};
  Object.assign(req,{url:`/api/portal/${path}`,method:'POST',headers:{host:'localhost:4011',origin:'http://localhost:4010',cookie}});
  let response;
  const res={setHeader(key,value){headers[key]=value;},writeHead(){},end(value){response=JSON.parse(value);}};
  await api.handle(req,res);
  if(headers['Set-Cookie'])cookie=headers['Set-Cookie'].split(';')[0];
  return response;
 };
 assert.equal((await post('session',{userId:'MOCK_LOCAL_ADMIN'})).ok,true);
 assert.equal((await post('session',{userId:'MOCK_USER_1'})).ok,true);
 assert.equal((await post('logout')).ok,true);
 const {state:record}=await repository.load();
 const admin=record.users.find(user=>user.id==='MOCK_LOCAL_ADMIN');
 const service=createPortalService({kind:'mock',read:()=>structuredClone(record)},()=>admin);
 const home=(await service.read('adminHome')).data;
 const trend=(await service.read('auditTrends')).data;
 assert.equal(home.todayAccessCount,1);
 assert.equal(trend.access.at(-1).count,home.todayAccessCount);
 assert.deepEqual(record.logs.filter(log=>log.kind==='login').map(log=>log.name).sort(),['LOGIN','LOGIN','LOGOUT','SWITCH_USER']);
});
