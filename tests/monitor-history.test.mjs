import test from 'node:test';
import assert from 'node:assert/strict';
import {createMockProvider} from '../src/providers/mock.js';
import {createPortalService} from '../src/services/portal.js';
import {actors} from '../src/mock/seed.js';
import {loadMonitorHistory,monitorHistoryMirrorSql} from '../server/monitor-history-persistence.mjs';

test('应用启停导致的接入状态变化记入历史，同态操作不重复记录',async()=>{
 const provider=createMockProvider();
 provider.transact(state=>{
  const app=state.apps[0],config=state.integrations.find(row=>row.appId===app.id&&row.kind==='SSO');
  app.enabled=true;
  Object.assign(config,{enabled:'ENABLED',configStatus:'CONFIGURED',runtimeStatus:'NORMAL',updatedAt:new Date(Date.now()-1000).toISOString()});
  state.monitorSamples=(state.monitorSamples||[]).filter(row=>row.appId!==app.id||row.kind!=='SSO');
  state.monitorHistory=[];
 });
 const appId=provider.read().apps[0].id,service=createPortalService(provider,()=>actors[2]);
 const setEnabled=async enabled=>{
  const app=provider.read().apps.find(row=>row.id===appId);
  const changed=await service.command('setAppStatus',{id:app.id,version:app.version,enabled});
  assert.equal(changed.ok,true,JSON.stringify(changed));
 };
 await setEnabled(false);
 let history=(await service.read('monitorHistory')).data.filter(row=>row.appId===appId&&row.kind==='SSO');
 assert.equal(history.length,1);
 assert.deepEqual([history[0].fromStatus,history[0].toStatus],['NORMAL','DISABLED']);
 await setEnabled(false);
 history=(await service.read('monitorHistory')).data.filter(row=>row.appId===appId&&row.kind==='SSO');
 assert.equal(history.length,1);
 await setEnabled(true);
 history=(await service.read('monitorHistory')).data.filter(row=>row.appId===appId&&row.kind==='SSO');
 assert.equal(history.length,2);
 assert.equal(history.find(row=>row.toStatus==='NORMAL').fromStatus,'DISABLED');
});

test('人工录入命令已停用，历史读取继续受监控查看权限控制',async()=>{
 const provider=createMockProvider(),appId=provider.read().apps[0].id;
 const admin=createPortalService(provider,()=>actors[2]);
 assert.equal((await admin.command('recordMonitorObservation',{appId,kind:'SSO',status:'NORMAL'})).error.code,'CAPABILITY_UNAVAILABLE');
 const citizen=createPortalService(provider,()=>actors[0]);
 assert.equal((await citizen.read('monitorHistory')).error.code,'FORBIDDEN');
});

test('历史物理表映射可重读，镜像仅插入新增事件',async()=>{
 const row={id:'MOCK_H1',appId:'MOCK_APP_4',kind:'SSO',fromStatus:'ABNORMAL',toStatus:'NORMAL',occurredAt:'2026-09-30T01:00:00.000Z',reason:'接口恢复',source:'MONITOR_OBSERVATION'};
 const sql=monitorHistoryMirrorSql({monitorHistory:[]},{monitorHistory:[row]});
 assert.match(sql,/P4FIX_H1/);assert.match(sql,/P4FIX_APP_4/);assert.equal(monitorHistoryMirrorSql({monitorHistory:[row]},{monitorHistory:[row]}),'');
 const loaded=await loadMonitorHistory(async()=>JSON.stringify([{id:'P4FIX_H1',application_id:'P4FIX_APP_4',service_type:'SSO',from_status:'ABNORMAL',to_status:'NORMAL',occurred_at:row.occurredAt,reason:row.reason,source:row.source}]));
 assert.deepEqual(loaded.map(({appName,...item})=>item),[row]);
});
