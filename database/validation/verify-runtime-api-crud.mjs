import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {createServer,request} from 'node:http';
import {createPortalApi} from '../../server/api.mjs';
import {createRepository,dbId,sqlQuery} from '../../server/repository.mjs';

const marker=`DBAPI_${randomUUID().replaceAll('-','').slice(0,12)}`;
const code=marker.toLowerCase();
const repository=createRepository();
const server=createServer(createPortalApi({repository}).handle);
await new Promise((resolve,reject)=>server.once('error',reject).listen(0,'127.0.0.1',resolve));
const call=(path,{method='GET',body,cookie}={})=>new Promise((resolve,reject)=>{
 const payload=body?JSON.stringify(body):null;
 const req=request({hostname:'127.0.0.1',port:server.address().port,path:`/api/portal${path}`,method,
  headers:{host:'127.0.0.1:4011',...(cookie?{cookie}:{}),...(payload?{'content-type':'application/json','content-length':Buffer.byteLength(payload)}:{})}},res=>{
  let text='';res.on('data',chunk=>text+=chunk);res.on('end',()=>resolve({status:res.statusCode,headers:res.headers,body:JSON.parse(text)}));
 });
 req.on('error',reject);req.end(payload||undefined);
});
const ok=async(path,options)=>{
 const response=await call(path,options);
 assert.equal(response.body.ok,true,`${path}: ${response.body.error?.message||response.status}`);
 return response;
};
const login=async userId=>{
 const response=await ok('/session',{method:'POST',body:{userId}});
 return response.headers['set-cookie']?.[0]?.split(';')[0];
};
const command=(cookie,action,payload)=>ok('/command',{method:'POST',cookie,body:{action,payload}}).then(response=>response.body.data);
const read=(cookie,resource)=>ok(`/read?resource=${resource}`,{cookie}).then(response=>response.body.data);
let app=null,applicationRequest=null,removed=false;
try{
 const health=(await ok('/health')).body.data;
 assert.equal(health.repository,'DATABASE');
 const admin=await login('MOCK_ADMIN'),citizen=await login('MOCK_USER_1');
 assert.ok(admin&&citizen);
 const categories=await read(admin,'categories');
 app=await command(admin,'saveApp',{name:`${marker} 应用`,code,category:categories[0].name,url:'https://example.invalid/db-api-acceptance',
  userType:'BOTH',accessMode:'REQUEST',postGrantMode:'DIRECT',accountBindingMode:'NONE',accountOpeningMode:'NONE'});
 assert.ok(app.id);
 app=await command(admin,'setAppStatus',{id:app.id,version:app.version,enabled:true});
 app=await command(admin,'saveApp',{...app,name:`${marker} 已编辑`});
 const reloaded=await createRepository().load();
 assert.equal(reloaded.state.apps.find(row=>row.id===app.id)?.name,`${marker} 已编辑`);
 applicationRequest=await command(citizen,'submitApplicationRequest',{appId:app.id,reason:'数据库 API 持久化验收'});
 assert.equal((await createRepository().load()).state.applicationRequests.find(row=>row.id===applicationRequest.id)?.status,'PENDING');
 applicationRequest=await command(admin,'approveApplicationRequest',{id:applicationRequest.id,version:applicationRequest.version});
 const approved=await createRepository().load();
 assert.equal(approved.state.applicationRequests.find(row=>row.id===applicationRequest.id)?.status,'APPROVED');
 assert.ok(approved.state.applicationGrants.some(row=>row.appId===app.id&&row.userId==='MOCK_USER_1'&&row.status==='ACTIVE'));
 assert.ok((await read(admin,'adminApps')).some(row=>row.id===app.id));
 await command(admin,'removeApp',{id:app.id,version:app.version});removed=true;
 const after=await createRepository().load();
 assert.ok(!after.state.apps.some(row=>row.id===app.id));
 assert.ok(!after.state.applicationRequests.some(row=>row.id===applicationRequest.id));
 assert.ok(!after.state.applicationGrants.some(row=>row.appId===app.id));
 console.log(JSON.stringify({marker,apiCrud:true,databaseReload:true,requestApproved:true,appRemoved:true}));
}finally{
 try{
  if(app){
   if(!removed){
    const current=await repository.load(),next=structuredClone(current.state);
    next.apps=next.apps.filter(row=>row.id!==app.id);
    for(const key of ['applicationRequests','applicationGrants','accountOpeningRequests','integrations','mappings','monitorSamples','todos','messages','visits','receipts'])next[key]=(next[key]||[]).filter(row=>row.appId!==app.id);
    await repository.commit(current.state,next,current.version,null);
   }
   const physical=dbId(app.id),runtime=app.id,requestId=applicationRequest?.id;
   await sqlQuery(`BEGIN;
    DELETE FROM "pb3gir75kkooyea"."audit_event" WHERE application_id='${physical}' OR object_id IN ('${runtime}'${requestId?`, '${requestId}'`:''});
    DELETE FROM "pb3gir75kkooyea"."application" WHERE id='${physical}' AND deleted_at IS NOT NULL;
    COMMIT;`);
   const residual=JSON.parse(await sqlQuery(`SELECT json_build_object(
    'application',(SELECT count(*) FROM "pb3gir75kkooyea"."application" WHERE id='${physical}'),
    'requests',(SELECT count(*) FROM "pb3gir75kkooyea"."application_access_request" WHERE application_id='${physical}'),
    'grants',(SELECT count(*) FROM "pb3gir75kkooyea"."application_access_grant" WHERE application_id='${physical}'),
    'audit',(SELECT count(*) FROM "pb3gir75kkooyea"."audit_event" WHERE application_id='${physical}' OR object_id='${runtime}')
   )`));
   assert.ok(Object.values(residual).every(value=>Number(value)===0),JSON.stringify(residual));
   console.log(JSON.stringify({marker,cleaned:true,residual}));
  }
 }finally{await new Promise((resolve,reject)=>server.close(error=>error?reject(error):resolve()));}
}
