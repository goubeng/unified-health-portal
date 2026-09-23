import assert from 'node:assert/strict';
import {createServer,request} from 'node:http';
import {createPortalApi} from '../../server/api.mjs';
import {createRepository} from '../../server/repository.mjs';

const server=createServer(createPortalApi({repository:createRepository()}).handle);
await new Promise((resolve,reject)=>server.once('error',reject).listen(0,'127.0.0.1',resolve));
const call=(path,{method='GET',body,cookie}={})=>new Promise((resolve,reject)=>{
 const payload=body?JSON.stringify(body):null;
 const req=request({hostname:'127.0.0.1',port:server.address().port,path:`/api/portal${path}`,method,
  headers:{host:'127.0.0.1:4011',...(cookie?{cookie}:{}),...(payload?{'content-type':'application/json','content-length':Buffer.byteLength(payload)}:{})}},res=>{
  let text='';res.on('data',chunk=>text+=chunk);res.on('end',()=>resolve({status:res.statusCode,headers:res.headers,body:JSON.parse(text)}));
 });
 req.on('error',reject);req.end(payload||undefined);
});
try{
 const health=(await call('/health')).body;
 assert.equal(health.data?.repository,'DATABASE',JSON.stringify(health));
 const loginResponse=await call('/session',{method:'POST',body:{userId:'MOCK_ADMIN'}});
 const login=loginResponse.body;
 assert.equal(login.ok,true,JSON.stringify(login));
 const cookie=loginResponse.headers['set-cookie']?.[0]?.split(';')[0];
 assert.ok(cookie);
 const counts={};
 for(const resource of ['adminApps','categories','todos','messages','applicationRequests','accountOpeningRequests','organizations','dictionaries','roles','settings']){
  const response=await call(`/read?resource=${resource}`,{cookie}),result=response.body;
  assert.equal(result.ok,true,`${resource}: ${result.error?.message||response.status}`);
  counts[resource]=Array.isArray(result.data)?result.data.length:{types:result.data.types.length,items:result.data.items.length};
 }
 assert.equal(counts.adminApps,42);
 assert.equal(counts.categories,6);
 assert.equal(counts.organizations,3);
 assert.deepEqual(counts.dictionaries,{types:6,items:22});
 console.log(JSON.stringify({repository:health.data.repository,version:health.data.version,counts}));
}finally{
 await new Promise((resolve,reject)=>server.close(error=>error?reject(error):resolve()));
}
