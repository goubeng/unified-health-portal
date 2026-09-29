import test from 'node:test';
import assert from 'node:assert/strict';
import {createMockProvider} from '../src/providers/mock.js';
import {createPortalService} from '../src/services/portal.js';
import {actors} from '../src/mock/seed.js';

const kinds=['SSO','TODO','MESSAGE'];
const aggregate=(enabled,statuses)=>!enabled?'DISABLED':statuses.includes('ABNORMAL')?'ABNORMAL':statuses.includes('NORMAL')?'NORMAL':statuses.every(status=>status==='DISABLED')?'DISABLED':'UNCONFIGURED';

test('应用综合运行状态、运行监控三态和首页异常应用数使用同一口径',async()=>{
 const provider=createMockProvider();
 const combinations=[
  {statuses:['NORMAL','NORMAL','UNCONFIGURED'],expected:'NORMAL'},
  {statuses:['NORMAL','ABNORMAL','DISABLED'],expected:'ABNORMAL'},
  {statuses:['UNCONFIGURED','UNCONFIGURED','UNCONFIGURED'],expected:'UNCONFIGURED'},
  {statuses:['DISABLED','DISABLED','DISABLED'],expected:'DISABLED'},
  {statuses:['ABNORMAL','NORMAL','NORMAL'],enabled:false,expected:'DISABLED'},
  {statuses:['DISABLED','UNCONFIGURED','DISABLED'],expected:'UNCONFIGURED'}
 ];
 provider.transact(state=>{
  assert(state.apps.length>=combinations.length);
  state.monitorSamples=[];
  state.apps.forEach((app,index)=>{app.enabled=combinations[index]?.enabled!==false;});
  state.integrations=state.apps.flatMap((app,index)=>kinds.map((kind,offset)=>({
   id:`CONSISTENCY_${app.id}_${kind}`,appId:app.id,kind,
   enabled:'ENABLED',configStatus:'CONFIGURED',
   runtimeStatus:combinations[index]?.statuses[offset]||'UNCONFIGURED'
  })));
 });
 const service=createPortalService(provider,()=>actors.find(actor=>actor.id==='MOCK_ADMIN'));
 const read=async resource=>{
  const result=await service.read(resource);
  assert.equal(result.ok,true,JSON.stringify(result));
  return result.data;
 };
 const [apps,monitors,home]=await Promise.all(['adminApps','monitor','adminHome'].map(read));
 const monitorByApp=new Map(monitors.map(row=>[row.appId,row]));
 assert.equal(monitors.length,apps.length);
 for(const [index,app] of apps.entries()){
  const monitor=monitorByApp.get(app.id);
  assert(monitor,`缺少 ${app.id} 的运行监控记录`);
  const statuses=kinds.map(kind=>monitor[`${kind.toLowerCase()}Status`]);
  assert.equal(app.aggregateRuntimeStatus,aggregate(app.enabled,statuses),app.id);
  if(index<combinations.length)assert.equal(app.aggregateRuntimeStatus,combinations[index].expected,app.id);
 }
 assert.equal(home.abnormalApplicationCount,apps.filter(app=>app.aggregateRuntimeStatus==='ABNORMAL').length);
 assert.equal(home.abnormalApplicationCount,1);
});
