import { applicationCatalog, platforms } from './catalog.js';

// P4 fixtures only: NORMAL/BOUND and audit outcomes exercise local UI states.
// These are not evidence of live verification, service access or delivery.
// All names are fictional; no credentials or personal contact information.
export const actors = [
 {id:'MOCK_USER_1',name:'林晓',account:'linxiao',kind:'USER',userType:'CITIZEN',orgName:'公众服务',orgKey:'PUBLIC',scopes:[],roleIds:[],roleName:'普通用户',department:'个人服务',jobTitle:'办事人员',identitySource:'闽政通'},
 {id:'MOCK_USER_2',name:'陈宁',account:'chenning',kind:'USER',userType:'GOV',orgName:'卫生健康业务处',orgKey:'HEALTH',scopes:[],roleIds:[],roleName:'普通用户',department:'业务协同科',jobTitle:'业务经办',identitySource:'闽政务'},
 {id:'MOCK_ADMIN',name:'周明',account:'zhouming',kind:'ADMIN',userType:'GOV',orgName:'门户运行保障中心',orgKey:'PORTAL',scopes:['super','application','integration','announcement','audit','identity'],roleIds:['ROLE_SUPER'],roleName:'门户超级管理员',department:'运行保障科',jobTitle:'系统管理',identitySource:'闽政务'},
 {id:'MOCK_EDITOR',name:'郑颖',account:'zhengying',kind:'ADMIN',userType:'GOV',orgName:'门户运行保障中心',orgKey:'PORTAL',scopes:['announcement'],roleIds:['ROLE_CONTENT'],roleName:'内容管理员',scopeDescription:'公告权限',department:'信息发布科',jobTitle:'信息编辑',identitySource:'闽政务'},
 {id:'MOCK_LOCAL_ADMIN',name:'门户管理员',account:'admin01',kind:'ADMIN',userType:'LOCAL',orgName:'门户运行保障中心',orgKey:'PORTAL',scopes:['super','application','integration','announcement','audit','identity'],roleIds:['ROLE_SUPER'],roleName:'门户超级管理员',department:'运行保障科',jobTitle:'系统管理',identitySource:'门户本地'}
].map(actor => ({...actor,status:'NORMAL',mobile:'未提供',email:'未提供'}));

export function createSeed(now = new Date('2026-09-18T00:00:00.000Z')) {
 const epoch = new Date(now).getTime();
 if (!Number.isFinite(epoch)) throw new TypeError('Invalid fixture date');
 const at = hours => new Date(epoch + hours * 3600000).toISOString();
 const row = (id, values) => ({id,version:1,createdAt:at(-48),updatedAt:at(-1),...values});
 const categories = ['公众服务','政务协同','行业监管','培训考试','卫生监督','疾病防控'].map((name,i) => row('MOCK_CAT_'+(i+1), {name,code:['PUBLIC','GOV','REGULATION','TRAINING','SUPERVISION','PREVENTION'][i],status:'ENABLED',sortOrder:i}));
 const roles = [
  row('ROLE_SUPER',{roleCode:'PORTAL_SUPER_ADMIN',roleName:'门户超级管理员',description:'负责门户系统自身的用户、角色、应用、集成、内容、审计等管理，不授予子系统业务权限。',scopes:['super','application','integration','announcement','audit','identity'],status:'ENABLED',builtIn:true}),
  row('ROLE_APP',{roleCode:'PORTAL_APP_ADMIN',roleName:'应用管理员',description:'维护门户应用目录、分类及应用接入信息。',scopes:['application'],status:'ENABLED',builtIn:true}),
  row('ROLE_CONTENT',{roleCode:'PORTAL_CONTENT_ADMIN',roleName:'内容管理员',description:'维护通知公告等门户内容。',scopes:['announcement'],status:'ENABLED',builtIn:true}),
  row('ROLE_INTEGRATION',{roleCode:'PORTAL_INTEGRATION_ADMIN',roleName:'集成管理员',description:'查看SSO、TODO、MESSAGE等接入运行状态、异常与监控信息。',scopes:['integration'],status:'ENABLED',builtIn:true}),
  row('ROLE_IDENTITY',{roleCode:'PORTAL_IDENTITY_ADMIN',roleName:'身份映射管理员',description:'维护统一身份索引与子系统账号映射。',scopes:['identity'],status:'ENABLED',builtIn:true}),
  row('ROLE_AUDIT',{roleCode:'PORTAL_AUDITOR',roleName:'审计员',description:'查看门户登录、访问、操作、接口及异常日志。',scopes:['audit'],status:'ENABLED',builtIn:true})
 ];
 const apps = applicationCatalog.map(entry => {
  const n=entry.sourceNo;
  const ci=n<=2?0:n<=17?1:n<=23?2:n<=28?3:n<=33?2:n<=38?4:5;
  return row('MOCK_APP_'+n,{...entry,code:'WJ_APP_'+String(n).padStart(2,'0'),category:categories[ci].name,categoryId:categories[ci].id,
   userType:n<=6||[11,12,13,17,24,25,26,28,33].includes(n)?'BOTH':'GOV',
   status:n===43?'DISABLED':'ENABLED',runtimeStatus:n===43?'DISABLED':n===38?'ABNORMAL':n===40?'UNCONFIGURED':'NORMAL',
   url:'https://p4.invalid/app/'+n,sortOrder:n,connectionStatus:'UNCONFIGURED',integrationNote:'服务地址与接入参数待配置'});
 });
 const available = actor => apps.filter(app => app.status==='ENABLED' && app.runtimeStatus==='NORMAL' && (app.userType==='BOTH'||app.userType===actor.userType));
 const mappings = actors.flatMap(actor => [...available(actor).slice(0,8),apps.find(a=>a.sourceNo===26),apps.find(a=>a.sourceNo===28)].map((app,i) => row('MOCK_MAP_'+actor.id+'_'+app.sourceNo,{
  userId:actor.id,userName:actor.name,appId:app.id,appName:app.name,externalAccount:actor.account+'_'+String(app.sourceNo).padStart(2,'0'),
  externalUserId:'P4_SUBJECT_'+actor.id+'_'+app.sourceNo,status:i<8?'BOUND':i===8?'FAILED':'CONFLICT',bindingMethod:'ADMIN',
  boundAt:i<8?at(-24):null,conflictReason:i===8?'账号核验未通过，待补充关联资料':i===9?'身份资料不一致，待人工核查':null
 })));
 const actions=['核对服务申请资料','补充业务登记信息','确认服务安排','查看材料核验意见','核对信息更新内容','确认事项办理进度','完善服务联系说明','查看后续办理要求','资料核验已完成','业务申请已撤回','办理期限已结束'];
 const todos=actors.flatMap((actor,ai)=>actions.map((title,i)=>{
  const app=available(actor)[i%8],status=i<8?'PENDING':['COMPLETED','WITHDRAWN','EXPIRED'][i-8];
  return row('MOCK_TODO_'+ai+'_'+i,{userId:actor.id,appId:app.id,appName:app.name,sourceTodoId:'P4_TODO_'+ai+'_'+i,title,
   summary:app.name+'：'+title+'。请在来源系统查看业务详情。',businessType:'服务事项',status,priority:['HIGH','MEDIUM','LOW'][i%3],
   createdAt:at(-i-2),dueAt:at(i<3?-i-1:i*4),terminalAt:i<8?null:at(-1),sourceRevision:i<8?1:2,url:app.url});
 }));
 const messageTitles=['服务申请已受理','资料核验进度通知','办理期限提醒','服务安排更新','账号关联结果通知','业务信息变更提醒','材料补正通知','办理意见已反馈','门户维护安排','信息安全提醒'];
 const messages=actors.flatMap((actor,ai)=>messageTitles.map((title,i)=>{
  const app=available(actor)[i%8],portal=i>=8;
  return row('MOCK_MSG_'+ai+'_'+i,{userId:actor.id,appId:portal?null:app.id,appName:portal?'统一门户':app.name,
   sourceMessageId:'P4_MSG_'+ai+'_'+i,title,content:title+'。请查看相关事项详情并按办理要求完成后续操作。',
   sourceKind:portal?'PORTAL':'APPLICATION',messageType:portal?'SYSTEM':i===2?'TODO_REMINDER':'BUSINESS',
   status:i<8?'UNREAD':'READ',readAt:i<8?null:at(-1),createdAt:at(-i-1),url:portal?null:app.url});
 }));
 const announcementRows=[
  ['关于门户服务使用安排的通知','请通过应用中心查看服务入口，业务办理要求以来源系统说明为准。','ALL','PUBLISHED'],
  ['关于完善应用接入资料的通知','请整理应用目录、责任分工与接口字段，提交接入资料核验。','GOV','DRAFT'],
  ['公众服务事项办理指引','请在办事前核对材料清单，关注待办与消息中的办理要求。','CITIZEN','PUBLISHED'],
  ['卫生健康统计报送安排','请核对本期统计报表，并在规定期限内完成报送。','GOV','PUBLISHED'],
  // ORG is reserved for P6; retain organization drafts for admin-only inspection.
  ['运行保障值班安排','请核对值班分工，及时记录运行问题与处理情况。','ORG','DRAFT'],
  ['信息发布审核工作安排','发布前须核对内容、发布范围与有效期。','ORG','DRAFT'],
  ['原维护时段安排撤回通知','原维护时段安排已撤回，后续安排另行通知。','ALL','WITHDRAWN'],
  ['个人信息保护提示','请妥善保管账号，勿向他人提供验证码或身份核验资料。','ALL','PUBLISHED']
 ];
 const announcements=announcementRows.map(([title,content,scope,status],i)=>row('MOCK_ANN_'+(i+1),{
  title,content,type:i===7?'提示':'通知',scope,status,orgKey:scope==='ORG'?'PORTAL':null,orgName:scope==='ORG'?'门户运行保障中心':null,
  identitySource:scope==='ORG'?'闽政务':null,visibility:scope==='ORG'?'ADMIN_ONLY':'SCOPE',publisherId:status==='DRAFT'?null:actors[3].id,
  publishedAt:status==='DRAFT'?null:at(-24-i),effectiveStart:status==='DRAFT'?null:at(-24-i),effectiveEnd:null,attachments:[]
 }));
 const settingRows=[
  ['retention.message_days','消息留存周期（天）',90,'day'],['retention.todo_terminal_days','终态待办留存周期（天）',180,'day'],
  ['retention.log_days','日志留存周期（天）',180,'day'],['auth.session_ttl_seconds','会话有效期（秒）',null,'second'],
  ['integration.timeout_ms','接口超时（毫秒）',5000,'millisecond'],['integration.max_retries','接口重试上限',3,'count'],
  ['monitor.failure_threshold','连续失败告警阈值',5,'count']
 ];
 const settings=settingRows.map(([code,name,value,unit],i)=>row('MOCK_CONFIG_'+i,{code,name,value,unit,status:value===null?'UNCONFIGURED':'CONFIGURED'}));
 const integrations=apps.flatMap((app,i)=>['SSO','TODO','MESSAGE'].map((kind,k)=>row('MOCK_INT_'+app.id+kind,{
  appId:app.id,appName:app.name,name:app.name+' · '+kind,kind,mode:kind==='SSO'?'SSO':'PUSH',
  status:app.status==='DISABLED'?'DISABLED':['UNCONFIGURED','NORMAL','ABNORMAL','DISABLED'][(i+k)%4],
  connectionStatus:'UNCONFIGURED',remark:'接入参数待业务系统确认',lastCheckedAt:at(-k-1)
 })));
 const logNames=['身份登录','访问权限核验','应用访问','公告维护','数据接收','接入异常'];
 const logs=['login','auth','access','operation','api','error'].flatMap((kind,k)=>actors.map((actor,i)=>row('MOCK_LOG_'+kind+'_'+i,{
  kind,name:logNames[k],actor:actor.name,userId:actor.id,appId:apps[i].id,appName:apps[i].name,
  status:kind==='error'?'FAILURE':kind==='auth'&&i===3?'DENIED':'SUCCESS',
  description:kind==='error'?'接入参数未配置，需核对接口资料':logNames[k]+'记录',createdAt:at(-k*4-i),requestId:'P4_REQUEST_'+k+'_'+i
 })));
 const visits=actors.flatMap(actor=>available(actor).slice(0,4).map((app,i)=>({userId:actor.id,appId:app.id,at:at(-i-1)})));
 return {schemaVersion:3,users:structuredClone(actors),roles,apps,platforms:structuredClone(platforms),categories,mappings,
  todos,messages,announcements,announcementReads:[],settings,integrations,logs,visits,receipts:[]};
}
