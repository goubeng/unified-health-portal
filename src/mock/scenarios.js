// Explicit fixture data, never a health probe or evidence of a real external call.
export function addMonitorScenarios(state){
 state.monitorSamples??=[];
 const states=['UNCONFIGURED','NORMAL','ABNORMAL','DISABLED'];
 state.apps.filter(app=>app.status==='ENABLED').slice(0,4).forEach((app,index)=>{
  ['SSO','TODO','MESSAGE'].forEach((kind,offset)=>{
   const id=`SCENARIO_MONITOR_${app.id}_${kind}`;
   if(state.monitorSamples.some(x=>x.appId===app.id&&x.kind===kind))return;
   state.monitorSamples.push({id,version:1,appId:app.id,kind,status:states[(index+offset)%states.length],lastCheckedAt:'2026-09-19T01:00:00.000Z',responseTimeMs:states[(index+offset)%4]==='NORMAL'?126:null,dataSource:'FIXTURE'});
  });
 });
 return state;
}
export const auditScenarios=[
 ['LOGIN','SESSION_OPEN','SUCCESS','建立门户会话'],['LOGIN','SESSION_EXPIRED','FAILURE','会话已过期'],
 ['AUTH','IDENTITY_ACCEPTED','SUCCESS','闽政通身份已识别'],['AUTH','SCOPE_DENIED','DENIED','闽政务专属应用访问被拒绝'],
 ['ACCESS','APP_ENTRY','SUCCESS','应用入口请求已受理'],['ACCESS','APP_DISABLED','FAILURE','应用已停用，未发起访问'],
 ['OPERATION','CONFIG_SAVED','SUCCESS','接入参数保存'],['OPERATION','VERSION_CONFLICT','FAILURE','配置版本冲突，未覆盖修改'],
 ['API','PUSH_APPLIED','SUCCESS','接收待办事件'],['API','PUSH_DUPLICATE','SUCCESS','重复事件返回原处理结果'],
 ['API','INVALID_CREDENTIAL','DENIED','接入凭据不匹配'],['ERROR','UPSTREAM_TIMEOUT','FAILURE','来源连接超时']
];
