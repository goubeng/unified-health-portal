import test from 'node:test';
import assert from 'node:assert/strict';
import {createMockProvider} from '../src/providers/mock.js';
import {createPortalService} from '../src/services/portal.js';
import {actors} from '../src/mock/seed.js';
import {loadMonitorHistory,monitorHistoryMirrorSql} from '../server/monitor-history-persistence.mjs';

test('接入检测按有效状态变更记录异常和恢复，同态检测不重复',async()=>{
 const provider=createMockProvider();
 provider.transact(state=>{
  const app=state.apps[0],config=state.integrations.find(row=>row.appId===app.id&&row.kind==='SSO');
  app.enabled=true;Object.assign(config,{enabled:'ENABLED',configStatus:'CONFIGURED',runtimeStatus:'NORMAL',updatedAt:new Date(Date.now()-1000).toISOString()});
  state.monitorSamples=(state.monitorSamples||[]).filter(row=>row.appId!==app.id||row.kind!=='SSO');
  state.monitorHistory=[];
 });
 const appId=provider.read().apps[0].id,service=createPortalService(provider,()=>actors[2]);
 assert.equal((await service.command('recordMonitorObservation',{appId,kind:'SSO',status:'ABNORMAL',reason:''})).error.code,'VALIDATION_ERROR');
 assert.equal((await service.command('recordMonitorObservation',{appId,kind:'SSO',status:'ABNORMAL',reason:'上游接口超时'})).ok,true);
 assert.equal((await service.command('recordMonitorObservation',{appId,kind:'SSO',status:'ABNORMAL',reason:'仍超时'})).ok,true);
 let history=(await service.read('monitorHistory')).data.filter(row=>row.appId===appId);
 assert.equal(history.length,1);assert.deepEqual([history[0].fromStatus,history[0].toStatus,history[0].reason],['NORMAL','ABNORMAL','上游接口超时']);
 assert.equal((await service.command('recordMonitorObservation',{appId,kind:'SSO',status:'NORMAL',reason:'接口响应恢复'})).ok,true);
 history=(await service.read('monitorHistory')).data.filter(row=>row.appId===appId);
 assert.equal(history.length,2);assert.equal(history.find(row=>row.toStatus==='NORMAL').fromStatus,'ABNORMAL');
 const monitor=(await service.read('monitor')).data.find(row=>row.appId===appId).services.SSO;
 assert.equal(monitor.status,'NORMAL');assert(monitor.lastFailureAt);assert(monitor.lastSuccessAt);
 assert.equal(provider.read().monitorSamples.find(row=>row.appId===appId&&row.kind==='SSO').lastError,null);
});

test('未配置、已停用接入与无监控权限的身份不能录入或读取历史',async()=>{
 const provider=createMockProvider(),appId=provider.read().apps[0].id;
 provider.transact(state=>{const config=state.integrations.find(row=>row.appId===appId&&row.kind==='SSO');config.configStatus='UNCONFIGURED';config.enabled='ENABLED';});
 const admin=createPortalService(provider,()=>actors[2]);
 assert.equal((await admin.command('recordMonitorObservation',{appId,kind:'SSO',status:'NORMAL'})).error.code,'INVALID_TRANSITION');
 const citizen=createPortalService(provider,()=>actors[0]);
 assert.equal((await citizen.read('monitorHistory')).error.code,'FORBIDDEN');
 assert.equal((await citizen.command('recordMonitorObservation',{appId,kind:'SSO',status:'NORMAL'})).error.code,'FORBIDDEN');
});

test('历史物理表映射可重读，镜像仅插入新增事件',async()=>{
 const row={id:'MOCK_H1',appId:'MOCK_APP_4',kind:'SSO',fromStatus:'ABNORMAL',toStatus:'NORMAL',occurredAt:'2026-09-30T01:00:00.000Z',reason:'接口恢复',source:'MONITOR_OBSERVATION'};
 const sql=monitorHistoryMirrorSql({monitorHistory:[]},{monitorHistory:[row]});
 assert.match(sql,/P4FIX_H1/);assert.match(sql,/P4FIX_APP_4/);assert.equal(monitorHistoryMirrorSql({monitorHistory:[row]},{monitorHistory:[row]}),'');
 const loaded=await loadMonitorHistory(async()=>JSON.stringify([{id:'P4FIX_H1',application_id:'P4FIX_APP_4',service_type:'SSO',from_status:'ABNORMAL',to_status:'NORMAL',occurred_at:row.occurredAt,reason:row.reason,source:row.source}]));
 assert.deepEqual(loaded.map(({appName,...item})=>item),[row]);
});
