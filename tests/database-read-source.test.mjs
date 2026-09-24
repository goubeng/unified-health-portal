import test from 'node:test';
import assert from 'node:assert/strict';
import {Readable} from 'node:stream';
import {createPortalApi} from '../server/api.mjs';
import {auditLogDto,createMemoryRepository,createRepository,makeEvent,mirrorSql} from '../server/repository.mjs';
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
 assert.match(sql,/coalesce\(nullif\(details,''\),'\{\}'\)::jsonb/);
 assert.match(sql,/::jsonb\)::text/);
});

test('审计读取兼容当前数据库的 text 型 details 列',async()=>{
 const repository=createRepository(async sql=>{
  assert.match(sql,/a\.details::jsonb AS details/);
  assert.match(sql,/a\.actor_kind AS "actorKind"/);
  assert.match(sql,/a\.object_type AS "objectType"/);
  return '[]';
 });
 assert.deepEqual(await repository.logs('error'),[]);
});

test('五类物理审计事件映射前端字段且缺失信息不伪造',()=>{
 const base={name:'saveAnnouncement',actor:'门户管理员',actorKind:'USER',status:'SUCCESS',description:'保存公告',details:{actorAccount:'admin',identitySource:'PORTAL_LOCAL',loginMethod:'PASSWORD',ip:'127.0.0.1',client:'Browser'}};
 const operation=auditLogDto({...base,kind:'operation',objectType:'announcement'});
 assert.equal(operation.userName,'门户管理员');assert.equal(operation.account,'admin');assert.equal(operation.moduleName,'工作台');assert.equal(operation.pageName,'通知公告管理');assert.equal(operation.actionName,'保存公告');assert.equal(operation.objectType,'announcement');
 const login=auditLogDto({...base,kind:'login'});
 assert.equal(login.authType,'LOCAL');assert.equal(login.actorType,'PORTAL_ADMIN_USER');assert.equal(login.loginSource,'门户本地');assert.equal(login.loginMethod,'PASSWORD');assert.equal(login.ip,'127.0.0.1');
 const auth=auditLogDto({...base,kind:'auth',status:'DENIED',description:'权限不足',details:{}});
 assert.equal(auth.loginSource,'权限核验');assert.equal(auth.loginMethod,null);assert.equal(auth.failureReason,'权限不足');
 const access=auditLogDto({...base,kind:'access',details:{actorName:'林晓',actorAccount:'linxiao',accessMode:'BIND'}});
 assert.equal(access.userName,'林晓');assert.equal(access.account,'linxiao');assert.equal(access.accessMode,'BIND');
 const api=auditLogDto({...base,kind:'api',name:'pushTodo',details:{interfaceName:'/api/portal/ingest/todos',httpMethod:'POST',statusCode:200,durationMs:73}});
 assert.equal(api.interfaceName,'/api/portal/ingest/todos');assert.equal(api.statusCode,200);assert.equal(api.durationMs,73);
 const error=auditLogDto({...base,kind:'error',status:'FAILURE',description:'上游超时',details:{errorCode:'UPSTREAM_TIMEOUT',severity:'HIGH',resolutionNote:'已处理'}});
 assert.equal(error.errorCode,'UPSTREAM_TIMEOUT');assert.equal(error.severity,'HIGH');assert.equal(error.errorMessage,'上游超时');assert.equal(error.resolutionNote,'已处理');
 assert.equal(auditLogDto({...base,kind:'api',details:{}}).durationMs,null);
 const protectedDto=auditLogDto({...base,kind:'login',actorProfile:{account:'admin',secret:'not-for-browser'},appProfile:{accessMode:'BIND',secret:'not-for-browser'}});
 assert.equal(protectedDto.account,'admin');assert.equal(protectedDto.accessMode,'BIND');assert.equal('actorProfile' in protectedDto,false);assert.equal('appProfile' in protectedDto,false);
});

test('新物理审计事件保留操作页、身份与实际请求元数据',()=>{
 const state=createSeed(),actor=state.users.find(x=>x.id==='MOCK_LOCAL_ADMIN');
 const event=makeEvent({actor,action:'saveAnnouncement',state,result:{ok:true},sourceLog:{moduleName:'工作台',pageName:'通知公告管理',actionName:'保存公告'},requestMeta:{ip:'127.0.0.1',client:'Test Browser',durationMs:42}});
 assert.equal(event.details.authType,'LOCAL');assert.equal(event.details.actorType,'PORTAL_ADMIN_USER');assert.equal(event.details.pageName,'通知公告管理');assert.equal(event.details.ip,'127.0.0.1');assert.equal(event.details.durationMs,42);
 const sms=makeEvent({actor:state.users.find(x=>x.id==='MOCK_USER_1'),action:'LOGIN',payload:{loginMethod:'SMS'},state,result:{ok:true},kind:'LOGIN'});
 assert.equal(sms.details.loginMethod,'SMS');
 const failure=makeEvent({actor,action:'saveAnnouncement',state,result:{ok:false,error:{code:'FAILED',message:'处理失败'}}});
 assert.equal(failure.details.severity,'HIGH');assert.equal(failure.details.errorMessage,'处理失败');
});
