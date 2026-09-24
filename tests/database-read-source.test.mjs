import test from 'node:test';
import assert from 'node:assert/strict';
import {Readable} from 'node:stream';
import {createPortalApi} from '../server/api.mjs';
import {createMemoryRepository,mirrorSql} from '../server/repository.mjs';
import {createPortalService} from '../src/services/portal.js';
import {createSeed} from '../src/mock/seed.js';

test('兼容身份映射列表依据用户的真实映射状态，不硬编码已关联',async()=>{
 const state=createSeed(),admin=state.users.find(user=>user.id==='MOCK_ADMIN');
 state.mappings=[
  {id:'BOUND',userId:'MOCK_USER_1',status:'BOUND'},
  {id:'FAILED',userId:'MOCK_USER_1',status:'FAILED'},
  {id:'REVIEW',userId:'MOCK_USER_2',status:'REVIEWING'}
 ];
 const service=createPortalService({kind:'mock',read:()=>structuredClone(state)},()=>admin);
 const list=(await service.read('identityMappings')).data;
 assert.equal(list.find(row=>row.id==='MOCK_USER_1').status,'FAILED');
 assert.equal(list.find(row=>row.id==='MOCK_USER_2').status,'REVIEWING');
 assert(list.some(row=>row.status==='UNBOUND'));
});

test('管理首页异常数与物理审计行一致，处理动作以物理行和版本为准',async()=>{
 const backing=createMemoryRepository(),record=await backing.load();
 record.state.logs=[];
 const physicalErrors=[{id:'DB_ERROR_1',version:3,kind:'error',status:'FAILURE',resolutionStatus:'OPEN',details:{},createdAt:'2026-09-24T00:00:00.000Z'}];
 let state=record.state,version=record.version,cookie='';
 const repository={mode:'DATABASE',async load(){return {state:structuredClone(state),version};},
  async logs(kind){return kind==='error'?structuredClone(physicalErrors):[];},
  async openErrorCount(){return physicalErrors.filter(row=>row.resolutionStatus==='OPEN').length;},
  async commit(before,after,expectedVersion){
   assert.equal(expectedVersion,version);
   const resolved=after.logs.find(row=>row.id==='DB_ERROR_1');
   if(resolved?.resolutionStatus==='RESOLVED')Object.assign(physicalErrors[0],resolved);
   state=structuredClone(after);version++;
  }};
 const api=createPortalApi({repository});
 const request=async(path,payload)=>{
  const req=Readable.from(payload===undefined?[]:[JSON.stringify(payload)]);
  Object.assign(req,{url:'/api/portal/'+path,method:payload===undefined?'GET':'POST',headers:{host:'localhost:4011',origin:'http://localhost:4010',cookie}});
  let result;const headers={};
  const res={setHeader(key,value){headers[key]=value;},writeHead(){this.headersSent=true;},end(value){result=JSON.parse(value);}};
  await api.handle(req,res);if(headers['Set-Cookie'])cookie=headers['Set-Cookie'].split(';')[0];return result;
 };
 assert.equal((await request('session',{userId:'MOCK_ADMIN'})).ok,true);
 assert.equal((await request('read?resource=adminHome')).data.openErrorCount,1);
 const row=(await request('read?resource=logs:error')).data[0];
 assert.equal(row.version,3);
 const resolved=await request('command',{action:'resolveLogError',payload:{id:row.id,version:row.version,resolutionNote:'已核查'}});
 assert.equal(resolved.ok,true,JSON.stringify(resolved));
 assert.equal(physicalErrors[0].resolutionStatus,'RESOLVED');
 assert.equal((await request('read?resource=adminHome')).data.openErrorCount,0);
});

test('异常处理数据库镜像只更新目标审计行并校验旧版本',()=>{
 const before={logs:[{id:'DB_ERROR_1',kind:'error',version:3,resolutionStatus:'OPEN'}]};
 const after={logs:[{id:'DB_ERROR_1',kind:'error',version:4,resolutionStatus:'RESOLVED',resolutionNote:'已核查',resolvedAt:'2026-09-24T00:00:00.000Z',resolvedBy:'MOCK_ADMIN'}]};
 const sql=mirrorSql(before,after);
 assert.match(sql,/UPDATE "pb3gir75kkooyea"\."audit_event" SET resolution_status='RESOLVED'/);
 assert.match(sql,/id='DB_ERROR_1' AND kind='ERROR' AND version=3/);
 assert.match(sql,/LOG_VERSION_CONFLICT/);
});
