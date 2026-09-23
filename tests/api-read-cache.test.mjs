import test from 'node:test';
import assert from 'node:assert/strict';
import {Readable} from 'node:stream';
import {createPortalApi} from '../server/api.mjs';
import {createMemoryRepository} from '../server/repository.mjs';

test('并发 GET 共用短期快照，写入后立即失效，过期后重新回读',async()=>{
 const backing=createMemoryRepository();let loads=0,cookie='';
 const repository={
  mode:'DATABASE',database:'test',schema:'test',
  async load(){loads++;return backing.load();},
  async commit(...args){return backing.commit(...args);},
  async logs(...args){return backing.logs(...args)}
 };
 const api=createPortalApi({repository});
 const request=async(path,payload,expectedStatus=200)=>{
  const req=Readable.from(payload===undefined?[]:[JSON.stringify(payload)]);
  Object.assign(req,{url:'/api/portal/'+path,method:payload===undefined?'GET':'POST',headers:{host:'localhost:4011',cookie,origin:'http://localhost:4010'}});
  let status,result;const headers={};
  const res={setHeader(key,value){headers[key]=value;},writeHead(value){status=value;this.headersSent=true;},end(value){result=JSON.parse(value);}};
  await api.handle(req,res);
  if(headers['Set-Cookie'])cookie=headers['Set-Cookie'].split(';')[0];
  assert.equal(status,expectedStatus,JSON.stringify(result));
  return result.data;
 };
 const initial=await Promise.all(Array.from({length:6},()=>request('health')));
 assert.equal(loads,1);
 assert(initial.every(item=>item.version===1));
 await request('read?resource=adminApps',undefined,401);
 assert.equal(loads,1,'匿名失败请求也不得绕过会话校验或重复全量加载');
 assert.equal((await request('session')).adminAccess,false);
 await request('session',{userId:'MOCK_ADMIN'});
 assert.equal(loads,2,'POST 登录必须重新读取仓库');
 const afterLogin=await request('health');
 assert.equal(afterLogin.version,2);
 assert.equal(loads,3,'提交后 GET 不能复用旧版本');
 const beforeCategories=await request('read?resource=categories');
 assert.equal(loads,3);
 const created=await request('command',{action:'saveCategory',payload:{name:'缓存测试分类',code:'CACHE_TEST',sortOrder:99}});
 assert(created.id);
 assert.equal(loads,4,'POST 命令必须重新读取仓库');
 const afterCategories=await request('read?resource=categories');
 assert(afterCategories.some(item=>item.id===created.id));
 assert.equal(afterCategories.length,beforeCategories.length+1);
 assert.equal(loads,5,'业务写入后 GET 应读取新快照');
 await new Promise(resolve=>setTimeout(resolve,1100));
 await request('health');
 assert.equal(loads,6,'短期快照到期后应重新读取仓库');
 await request('logout',{});
 await request('read?resource=adminApps',undefined,401);
 await request('session',{userId:'MOCK_USER_1'});
 await request('read?resource=adminApps',undefined,403);
 assert((await request('read?resource=apps')).length>0,'普通用户仍可读取自己的应用目录');
});
