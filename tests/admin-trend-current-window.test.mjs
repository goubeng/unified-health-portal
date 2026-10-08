import test from 'node:test';
import assert from 'node:assert/strict';
import {Readable} from 'node:stream';
import {createSeed} from '../src/mock/seed.js';
import {createPortalService} from '../src/services/portal.js';
import {chinaDayKey,chinaDayWindow} from '../src/utils/chinaCalendar.mjs';
import {createPortalApi} from '../server/api.mjs';
import {createRepository} from '../server/repository.mjs';

test('Mock 门户入站趋势以北京时间今天截止，旧日志和应用访问不会固定或虚增横轴',async()=>{
 const state=createSeed(),admin=state.users.find(user=>user.id==='MOCK_ADMIN');
 state.logs=[
  {kind:'access',createdAt:'2026-09-28T04:00:00.000Z'},
  {kind:'api',createdAt:'2026-09-28T04:00:00.000Z'},
  {kind:'access',createdAt:new Date().toISOString()},
  {kind:'login',name:'LOGIN',status:'SUCCESS',createdAt:new Date().toISOString()},
  {kind:'login',name:'SWITCH_USER',status:'SUCCESS',createdAt:new Date().toISOString()}
 ];
 const service=createPortalService({kind:'mock',read:()=>structuredClone(state)},()=>admin);
 const trend=(await service.read('auditTrends')).data;
 const today=chinaDayKey(new Date());
 assert.equal(trend.access.length,30);
 assert.equal(trend.access.at(-1).date,today);
 assert.equal(trend.access.at(-1).count,1);
 assert.equal(trend.api.at(-1).count,0);
});

test('数据库趋势按物理审计事件和北京时间分组，不受日志列表 1000 条上限影响',async()=>{
 let sql='';
 const repository=createRepository(async statement=>{sql=statement;return JSON.stringify([{day:'2026-10-08',access:1200,api:4,login:2}]);});
 assert.deepEqual(await repository.auditDayCounts('2026-10-07T16:00:00.000Z','2026-10-08T08:00:00.000Z'),[{day:'2026-10-08',access:1200,api:4,login:2}]);
 assert.match(sql,/FROM "pb3gir75kkooyea"\."audit_event"/);
 assert.match(sql,/created_at AT TIME ZONE 'Asia\/Shanghai'/);
 assert.match(sql,/kind='LOGIN' AND event_code='LOGIN' AND result='SUCCESS'/);
 assert.match(sql,/kind IN \('API','LOGIN'\)/);
 assert.match(sql,/created_at >= '2026-10-07T16:00:00\.000Z'::timestamptz/);
 assert.match(sql,/created_at < '2026-10-08T08:00:00\.000Z'::timestamptz/);
 assert.doesNotMatch(sql,/LIMIT 1000/);
});

test('数据库首页今日 KPI 与趋势图取同一物理审计聚合',async()=>{
 const state=createSeed();state.logs=[];
 const today=chinaDayKey(new Date()),yesterday=chinaDayWindow(2)[0].key;
 const calls=[];
 const repository={mode:'DATABASE',async load(){return {state:structuredClone(state),version:1};},
  async commit(){},async openErrorCount(){return 0;},
  async auditDayCounts(startAt,endAt){calls.push({startAt,endAt});return [{day:yesterday,access:3,api:5,login:1},{day:today,access:7,api:11,login:2}];}
 };
 const api=createPortalApi({repository});let cookie='';
 const request=async(path,payload)=>{
  const req=Readable.from(payload===undefined?[]:[JSON.stringify(payload)]);
  Object.assign(req,{url:'/api/portal/'+path,method:payload===undefined?'GET':'POST',headers:{host:'localhost:4011',origin:'http://localhost:4010',cookie}});
  let result;const headers={};
  const res={setHeader(key,value){headers[key]=value;},writeHead(){this.headersSent=true;},end(value){result=JSON.parse(value);}};
  await api.handle(req,res);if(headers['Set-Cookie'])cookie=headers['Set-Cookie'].split(';')[0];return result;
 };
 assert.equal((await request('session',{userId:'MOCK_ADMIN'})).ok,true);
 const home=(await request('read?resource=adminHome')).data;
 const trend=(await request('read?resource=auditTrends')).data;
 assert.equal(home.todayAccessCount,7);
 assert.equal(home.todayApiCallCount,11);
 assert.equal(home.todayLoginCount,2);
 assert.equal(trend.access.at(-1).date,today);
 assert.equal(trend.access.at(-1).count,home.todayAccessCount);
 assert.equal(trend.api.at(-1).count,home.todayApiCallCount);
 assert.equal(trend.access.at(-2).count,3);
 assert.equal(trend.api.at(-2).count,5);
 assert.equal(calls.length,2);
});
