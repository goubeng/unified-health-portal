import {createRepository,makeEvent} from '../../server/repository.mjs';
import {createPortalService} from '../../src/services/portal.js';

const appId='MOCK_APP_18',kind='TODO',expectedName='福建省互联网医院监管平台';
const dependencies=['todos','messages','mappings','applicationRequests','applicationGrants','accountOpeningRequests','visits','receipts'];
const repository=createRepository();
const inspect=async()=>{
 const {state,version}=await repository.load(),app=state.apps.find(row=>row.id===appId),config=state.integrations.find(row=>row.appId===appId&&row.kind===kind);
 if(!app||app.name!==expectedName||!config)throw Error('目标应用或接入配置不符，停止');
 const actor=state.users.find(row=>row.id==='MOCK_LOCAL_ADMIN');
 if(!actor)throw Error('本地管理身份不存在，停止');
 const provider={kind:'mock',read:()=>structuredClone(state),transact(fn){const next=structuredClone(state);const value=fn(next);Object.assign(state,next);return structuredClone(value);}};
 const service=createPortalService(provider,()=>actor);
 const monitor=(await service.read('monitor')).data.find(row=>row.appId===appId)?.services?.[kind];
 const history=(state.monitorHistory||[]).filter(row=>row.appId===appId&&row.kind===kind);
 return {state,version,app,config,monitor,history,actor,service,provider,dependencies:Object.fromEntries(dependencies.map(key=>[key,(state[key]||[]).filter(row=>row.appId===appId).length]))};
};

const initial=await inspect();
const summary=x=>({version:x.version,appId,appName:x.app.name,kind,appEnabled:x.app.enabled,configEnabled:x.config.enabled,configStatus:x.config.configStatus,status:x.monitor.status,history:x.history.map(row=>({from:row.fromStatus,to:row.toStatus,reason:row.reason})),dependencies:x.dependencies});
console.log(JSON.stringify({phase:'preflight',...summary(initial)}));
if(!process.argv.includes('--apply'))process.exit(0);
if(Object.values(initial.dependencies).some(Boolean)||initial.app.enabled===false||initial.config.enabled!=='ENABLED'||initial.config.configStatus!=='CONFIGURED'||initial.monitor.status!=='NORMAL'||initial.history.length)throw Error('演示基线不安全，停止');

for(const [status,reason] of [['ABNORMAL','上游服务响应超时'],['NORMAL','复测成功，接口响应恢复']]){
 const before=await repository.load();let current=structuredClone(before.state);
 const provider={kind:'mock',read:()=>structuredClone(current),transact(fn){const next=structuredClone(current);const value=fn(next);current=next;return structuredClone(value);}};
 const actor=before.state.users.find(row=>row.id==='MOCK_LOCAL_ADMIN'),service=createPortalService(provider,()=>actor);
 const result=await service.command('recordMonitorObservation',{appId,kind,status,reason});
 if(!result.ok)throw Error(`检测结果录入失败：${result.error.code} ${result.error.message}`);
 const after=provider.read(),event=makeEvent({actor,action:'recordMonitorObservation',payload:{appId,kind,status,reason},state:after,result});
 await repository.commit(before.state,after,before.version,event);
 const verified=await inspect();
 if(verified.monitor.status!==status||verified.history[0]?.toStatus!==status)throw Error(`状态 ${status} 未从新仓储读回`);
 console.log(JSON.stringify({phase:'readback',...summary(verified)}));
}
