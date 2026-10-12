import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {
 visitTrendPreset,validateVisitTrendRange,visitTrendBounds,visitTrendSeries,visitTrendFromLogs,apiTrendFromLogs
} from '../src/utils/portalVisitTrend.mjs';
import {createSeed} from '../src/mock/seed.js';
import {createPortalService} from '../src/services/portal.js';
import {createRepository} from '../server/repository.mjs';

test('本月、上月、近7天、近30天按北京时间跨月跨年并正确截止',()=>{
 const now=new Date('2027-01-01T02:00:00.000Z');
 assert.deepEqual(visitTrendPreset('thisMonth',now),['2027-01-01','2027-01-01']);
 assert.deepEqual(visitTrendPreset('lastMonth',now),['2026-12-01','2026-12-31']);
 assert.deepEqual(visitTrendPreset('7d',now),['2026-12-26','2027-01-01']);
 assert.deepEqual(visitTrendPreset('30d',now),['2026-12-03','2027-01-01']);
 assert.deepEqual(visitTrendBounds('2026-12-31','2027-01-01',now),{
  startAt:'2026-12-30T16:00:00.000Z',endAt:'2027-01-01T02:00:00.000Z'
 });
 assert.equal(visitTrendBounds('2026-12-01','2026-12-31',now).endAt,'2026-12-31T16:00:00.000Z');
});

test('自定义范围校验未来日期、逆序、超过366天和无效日期',()=>{
 const now=new Date('2026-10-12T08:00:00Z');
 assert.equal(validateVisitTrendRange('2026-10-01','2026-10-12',now).length,12);
 assert.throws(()=>validateVisitTrendRange('2026-10-13','2026-10-13',now),/今天/);
 assert.throws(()=>validateVisitTrendRange('2026-10-12','2026-10-01',now),/不能晚于/);
 assert.throws(()=>validateVisitTrendRange('2025-01-01','2026-10-12',now),/366/);
 assert.throws(()=>validateVisitTrendRange('2026-02-30','2026-03-01',now),/有效/);
});

test('只统计成功进入门户，不将退出、切换、认证失败、应用访问计入访问量',()=>{
 const now=new Date('2026-10-12T08:00:00Z');
 const logs=[
  {kind:'login',name:'LOGIN',status:'SUCCESS',createdAt:'2026-10-11T15:59:59Z'},
  {kind:'login',name:'LOGIN',status:'SUCCESS',createdAt:'2026-10-11T16:00:00Z'},
  {kind:'login',name:'LOGIN',status:'FAILURE',createdAt:'2026-10-11T16:00:00Z'},
  {kind:'login',name:'SWITCH_USER',status:'SUCCESS',createdAt:'2026-10-11T16:00:00Z'},
  {kind:'login',name:'LOGOUT',status:'SUCCESS',createdAt:'2026-10-11T16:00:00Z'},
  {kind:'auth',name:'IDENTITY_ACCEPTED',status:'SUCCESS',createdAt:'2026-10-11T16:00:00Z'},
  {kind:'access',name:'enterApp',status:'SUCCESS',createdAt:'2026-10-11T16:00:00Z'},
  {kind:'login',name:'LOGIN',status:'SUCCESS',createdAt:'2026-10-12T08:00:01Z'}
 ];
 const rows=visitTrendFromLogs('2026-10-11','2026-10-12',logs,now);
 assert.deepEqual(rows,[{date:'2026-10-11',count:1},{date:'2026-10-12',count:1}]);
 assert.deepEqual(visitTrendSeries('2026-10-11','2026-10-12',[{date:'2026-10-12',count:4}],now),[
  {date:'2026-10-11',count:0},{date:'2026-10-12',count:4}
 ]);
});

test('接口调用趋势按北京时间统计所有API请求，排除其他日志及未来数据',()=>{
 const now=new Date('2026-10-12T08:00:00Z');
 const rows=apiTrendFromLogs('2026-10-11','2026-10-12',[
  {kind:'API',name:'CALL',status:'SUCCESS',createdAt:'2026-10-11T15:59:59Z'},
  {kind:'api',name:'CALL',status:'FAILURE',createdAt:'2026-10-11T16:00:00Z'},
  {kind:'api',name:'CALL',status:'DENIED',createdAt:'2026-10-11T16:30:00Z'},
  {kind:'LOGIN',name:'LOGIN',status:'SUCCESS',createdAt:'2026-10-11T16:30:00Z'},
  {kind:'api',name:'CALL',status:'SUCCESS',createdAt:'2026-10-12T08:00:01Z'}
 ],now);
 assert.deepEqual(rows,[{date:'2026-10-11',count:1},{date:'2026-10-12',count:2}]);
 assert.deepEqual(visitTrendSeries('2026-10-11','2026-10-12',[
  {day:'2026-10-11',count:0},{day:'2026-10-12',count:1200}
 ],now),[{date:'2026-10-11',count:0},{date:'2026-10-12',count:1200}]);
});

test('按审计权限读取登录访问趋势，普通用户无权查看',async()=>{
 const state=createSeed();
 const admin=state.users.find(x=>x.id==='MOCK_ADMIN');
 const user=state.users.find(x=>x.id==='MOCK_USER_1');
 assert(admin&&user);
 const [startDate,endDate]=visitTrendPreset('7d');
 const service=createPortalService({kind:'mock',read:()=>structuredClone(state)},()=>admin);
 const unauthorized=createPortalService({kind:'mock',read:()=>structuredClone(state)},()=>user);
 for(const resourceName of ['auditVisitTrend','auditApiTrend']){
  const resource=`${resourceName}?startDate=${startDate}&endDate=${endDate}`;
  const result=await service.read(resource);
  assert.equal(result.ok,true,resource);
  assert.equal(result.data.length,7,resource);
  assert.equal((await unauthorized.read(resource)).ok,false,resource);
 }
});

test('数据库聚合复用审计物理表，不能被列表1000条截断',async()=>{
 let sql='';
 const repository=createRepository(async statement=>{sql=statement;return JSON.stringify([{day:'2026-10-12',access:1300,api:1,login:1300}]);});
 const counts=await repository.auditDayCounts('2026-10-11T16:00:00.000Z','2026-10-12T08:00:00.000Z');
 assert.equal(counts[0].access,1300);
 assert.match(sql,/FROM "pb3gir75kkooyea"."audit_event"/);
 assert.match(sql,/kind='LOGIN' AND event_code='LOGIN' AND result='SUCCESS'/);
 assert.doesNotMatch(sql,/LIMIT 1000/);
});

test('趋势卡片和登录日志查询项均只在登录日志页显示',()=>{
 const chart=readFileSync(new URL('../src/components/portal/LoginVisitTrend.vue',import.meta.url),'utf8');
 const logs=readFileSync(new URL('../src/components/portal/LogManagement.vue',import.meta.url),'utf8');
 const api=readFileSync(new URL('../server/api.mjs',import.meta.url),'utf8');
 for(const label of ['本月','上月','近7天','近30天','自定义'])assert(chart.includes(label),label);
 assert.match(chart,/const period=ref\('30d'\)/);
 assert.match(chart,/smooth:true/);
 assert.match(chart,/areaStyle:/);
 assert.match(chart,/color:isApi\.value\?'#7C3AED':'#0D9488'/);
 assert.match(chart,/areaStyle:\{color:isApi\.value\?'rgba\(124,58,237,\.14\)':'rgba\(13,148,136,\.16\)'\}/);
 assert.match(chart,/name:metricName\.value,type:'line'/);
 assert.match(chart,/const resourceName=computed\(\(\)=>isApi\.value\?'auditApiTrend':'auditVisitTrend'\)/);
 const homeChart=readFileSync(new URL('../src/components/portal/AdminTrendChart.vue',import.meta.url),'utf8');
 assert.match(homeChart,/const currentLineColor=computed\(\(\)=>metric\.value==='api'\?'#7C3AED':'#0D9488'\)/);
 assert.match(homeChart,/const currentAreaColor=computed\(\(\)=>metric\.value==='api'\?'rgba\(124,58,237,\.14\)':'rgba\(13,148,136,\.16\)'\)/);
 assert.match(homeChart,/lineStyle:\{width:2,color:currentLineColor\.value\}/);
 assert.match(homeChart,/itemStyle:\{color:currentLineColor\.value\}/);
 assert.match(homeChart,/areaStyle:\{color:currentAreaColor\.value\}/);
 assert.match(chart,/<t-date-range-picker/);
 assert.match(logs,/<LoginVisitTrend v-if="kind==='login'\|\|kind==='api'" :key="kind" :kind="kind"\/>/);
 for(const field of ['事件类型','身份来源','认证类型'])assert(logs.includes(`label="${field}"`));
 assert.match(logs,/eventType\.value='';identitySource\.value='';authType\.value=''/);
 assert.match(api,/repository\.auditDayCounts\(startAt,endAt\)/);
 assert.match(api,/resource\.startsWith\('auditVisitTrend\?'\)/);
 assert.match(api,/resource\.startsWith\('auditApiTrend\?'\)/);
 assert.match(api,/count:Number\(apiTrend\?item\.api:item\.access\)\|\|0/);
});

test('五类日志查询均对应实际列表字段，避免来源应用和结果条件重复',()=>{
 const logs=readFileSync(new URL('../src/components/portal/LogManagement.vue',import.meta.url),'utf8');
 assert.match(logs,/const showAppFilter=computed\(\(\)=>\['access','api'\]\.includes\(props\.kind\)\)/);
 assert.match(logs,/v-if="kind!=='error'".*登录结果/);
 assert.match(logs,/access:\['userName','account','requestId'\]/);
 assert.match(logs,/api:\['interfaceName','requestId','errorMessage'\]/);
 assert.match(logs,/operation:\['actor','moduleName','pageName','actionName','requestId'\]/);
 assert.match(logs,/error:\['errorCode','errorMessage','moduleName','requestId','resolutionNote'\]/);
 assert.match(logs,/access:'用户 \/ 账号 \/ 请求ID'/);
 assert.match(logs,/api:'接口 \/ 请求ID \/ 错误信息'/);
 assert.match(logs,/const eventOptions=computed/);
 assert.match(logs,/const identitySourceOptions=computed/);
 assert.match(logs,/const authTypeOptions=computed/);
 assert.match(logs,/\(!eventType\.value\|\|loginActionText\(row\)===eventType\.value\)/);
 assert.match(logs,/\(!identitySource\.value\|\|row\.identitySource===identitySource\.value\)/);
 assert.match(logs,/\(!authType\.value\|\|row\.authType===authType\.value\)/);
 assert.match(logs,/watch\(\[keyword,appName,status,resolutionStatus,eventType,identitySource,authType,pageSize\]/);
});

