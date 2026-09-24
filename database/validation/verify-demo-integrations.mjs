// Read-only post-reconciliation checks for local demo status consistency.
import {createRepository} from '../../server/repository.mjs';
import {createPortalService} from '../../src/services/portal.js';

const {state,version}=await createRepository().load();
const provider={kind:'mock',read:()=>structuredClone(state)};
const admin=createPortalService(provider,()=>state.users.find(user=>user.id==='MOCK_LOCAL_ADMIN'));
const citizen=createPortalService(provider,()=>state.users.find(user=>user.id==='MOCK_USER_1'));
const adminApps=(await admin.read('adminApps')).data;
const monitors=(await admin.read('monitor')).data;
const profiles=(await admin.read('access')).data;
const citizenApps=(await citizen.read('apps')).data;
const byApp=rows=>new Map(rows.map(row=>[row.appId||row.id,row]));
const monitorByApp=byApp(monitors),profileByApp=byApp(profiles);
const differences=[];
for(const app of adminApps){
 const monitor=monitorByApp.get(app.id),profile=profileByApp.get(app.id);
 if(!monitor||!profile||app.ssoRuntimeStatus!==monitor.ssoStatus||profile.ssoStatus!==monitor.ssoStatus||profile.todoStatus!==monitor.todoStatus||profile.messageStatus!==monitor.messageStatus)differences.push(app.id);
}
const statuses=Object.fromEntries(['NORMAL','ABNORMAL','UNCONFIGURED','DISABLED'].map(status=>[status,state.integrations.filter(row=>row.runtimeStatus===status).length]));
const result={version,applications:adminApps.length,integrations:state.integrations.length,monitors:monitors.length,profiles:profiles.length,statuses,monitorEntranceDifferences:differences,citizenEnterOptions:citizenApps.filter(app=>app.primaryAction==='ENTER'&&app.ssoRuntimeStatus==='NORMAL').length,protectedTodo:state.integrations.find(row=>row.id==='MOCK_INT_MOCK_APP_1TODO')};
console.log(JSON.stringify({...result,protectedTodo:{id:result.protectedTodo?.id,version:result.protectedTodo?.version,enabled:result.protectedTodo?.enabled,runtimeStatus:result.protectedTodo?.runtimeStatus}},null,2));
if(version<301||adminApps.length!==42||state.integrations.length!==126||monitors.length!==42||profiles.length!==42||differences.length||statuses.NORMAL!==30||statuses.ABNORMAL!==31||statuses.UNCONFIGURED!==31||statuses.DISABLED!==33||result.citizenEnterOptions<1||result.protectedTodo?.version!==2||result.protectedTodo?.enabled!=='DISABLED')process.exitCode=1;
