import { applicationCatalog, platforms } from './catalog.js';

// P4 fixtures only: NORMAL/BOUND and audit outcomes exercise local UI states.
// These are not evidence of live verification, service access or delivery.
// All names are fictional; no credentials or personal contact information.
const SUPER_PERMISSIONS=[
 'application:view','application:edit','application:enable','application:review',
 'integration:view','integration:edit','integration:test',
 'identity:view','identity:review','identity:unbind',
 'announcement:view','announcement:edit','announcement:publish',
 'admin-user:view','admin-user:enable','admin-user:create','admin-user:assign-role','admin-user:reset-password',
 'organization:view','organization:edit','dictionary:view','dictionary:edit',
 'monitor:view','monitor:check','audit:view','audit:resolve',
 'role:view','role:edit','settings:view','settings:edit','system:super'
];
const PORTAL_ADMIN_PERMISSIONS=[
 'application:view','application:edit','application:enable','application:review',
 'integration:view','integration:edit','integration:test',
 'identity:view','identity:review','identity:unbind',
 'announcement:view','announcement:edit','announcement:publish',
 'admin-user:view','admin-user:enable',
 'organization:view','organization:edit','dictionary:view','dictionary:edit',
 'monitor:view','monitor:check','audit:view','audit:resolve'
];

export const actors = [
 {id:'MOCK_USER_1',name:'林晓',account:'linxiao',kind:'USER',userType:'CITIZEN',orgName:'',orgKey:'',permissions:[],scopes:[],roleIds:[],roleName:'普通用户',department:'',jobTitle:'',identitySource:'闽政通'},
 {id:'MOCK_USER_2',name:'陈宁',account:'chenning',kind:'USER',userType:'GOV',orgName:'卫生健康业务处',orgKey:'HEALTH',permissions:[],scopes:[],roleIds:[],roleName:'普通用户',department:'业务协同科',jobTitle:'业务经办',identitySource:'闽政务'},
 {id:'MOCK_ADMIN',name:'周明',account:'zhouming',kind:'ADMIN',adminSubject:true,adminAccess:true,authType:'EXTERNAL',userType:'GOV',orgName:'门户运行保障中心',orgKey:'PORTAL',permissions:[...SUPER_PERMISSIONS],scopes:['super','system','application','integration','announcement','audit','identity'],roleIds:['ROLE_SUPER'],roleName:'门户超级管理员',department:'运行保障科',jobTitle:'系统管理',identitySource:'闽政务'},
 {id:'MOCK_EDITOR',name:'郑颖',account:'zhengying',kind:'ADMIN',adminSubject:true,adminAccess:true,authType:'EXTERNAL',userType:'GOV',orgName:'门户运行保障中心',orgKey:'PORTAL',permissions:[...PORTAL_ADMIN_PERMISSIONS],scopes:['system','application','integration','announcement','audit','identity'],roleIds:['ROLE_ADMIN'],roleName:'门户管理员',department:'信息发布科',jobTitle:'信息编辑',identitySource:'闽政务'},
 {id:'MOCK_LOCAL_ADMIN',name:'门户管理员',account:'admin01',kind:'ADMIN',adminSubject:true,adminAccess:true,authType:'LOCAL',orgName:'门户运行保障中心',orgKey:'PORTAL',permissions:[...SUPER_PERMISSIONS],scopes:['super','system','application','integration','announcement','audit','identity'],roleIds:['ROLE_SUPER'],roleName:'门户超级管理员',department:'运行保障科',jobTitle:'系统管理',identitySource:'门户本地'}
].map(actor => ({...actor,enabled:true,status:'NORMAL',adminStatus:actor.kind==='ADMIN'?'NORMAL':null,mobile:'未提供',email:'未提供'}));

export function createSeed(now = new Date('2026-09-18T00:00:00.000Z')) {
 const epoch = new Date(now).getTime();
 if (!Number.isFinite(epoch)) throw new TypeError('Invalid fixture date');
 const at = hours => new Date(epoch + hours * 3600000).toISOString();
 const row = (id, values) => ({id,version:1,createdAt:at(-48),updatedAt:at(-1),...values});
 const categories = ['公众服务','政务协同','行业监管','培训考试','卫生监督','疾病防控'].map((name,i) => row('MOCK_CAT_'+(i+1), {name,code:['PUBLIC','GOV','REGULATION','TRAINING','SUPERVISION','PREVENTION'][i],status:'ENABLED',sortOrder:i}));
 const organizations = [
  row('MOCK_ORG_PORTAL',{code:'ORG_PORTAL',name:'门户运行保障中心',type:'PORTAL_UNIT',parentId:null,parentName:null,path:'门户运行保障中心',source:'PORTAL_LOCAL',status:'ENABLED',sortOrder:1,remark:'门户本地维护组织'}),
  row('MOCK_ORG_HEALTH',{code:'ORG_HEALTH',name:'卫生健康业务处',type:'GOV_DEPARTMENT',parentId:null,parentName:null,path:'卫生健康业务处',source:'MINZHENGWU',status:'ENABLED',sortOrder:2,remark:'政务组织索引'}),
  row('MOCK_ORG_PUBLISH',{code:'ORG_PUBLISH',name:'信息发布科',type:'GOV_DEPARTMENT',parentId:'MOCK_ORG_PORTAL',parentName:'门户运行保障中心',path:'门户运行保障中心 / 信息发布科',source:'PORTAL_LOCAL',status:'ENABLED',sortOrder:3,remark:'公告与信息发布维护'})
 ];
 const dictTypes=[
  row('MOCK_DICT_TYPE_APP_CATEGORY',{code:'application_category',name:'应用系统分类',description:'应用目录使用的业务分类',status:'ENABLED',sortOrder:1,systemLocked:false}),
  row('MOCK_DICT_TYPE_ANN_TYPE',{code:'announcement_type',name:'公告类型',description:'通知公告业务类型',status:'ENABLED',sortOrder:2,systemLocked:false}),
  row('MOCK_DICT_TYPE_ORG_TYPE',{code:'organization_type',name:'组织类型',description:'门户组织索引类型',status:'ENABLED',sortOrder:3,systemLocked:false}),
  row('MOCK_DICT_TYPE_ENABLE',{code:'enable_status',name:'启用状态',description:'系统受控状态字典',status:'ENABLED',sortOrder:90,systemLocked:true}),
  row('MOCK_DICT_TYPE_RUNTIME',{code:'runtime_status',name:'运行状态',description:'系统受控运行状态',status:'ENABLED',sortOrder:91,systemLocked:true}),
  row('MOCK_DICT_TYPE_PROTOCOL',{code:'integration_protocol',name:'接入协议',description:'代码已支持的接入协议',status:'ENABLED',sortOrder:92,systemLocked:true})
 ];
 const dictItems=[
  ...categories.map((item,index)=>row('MOCK_DICT_APP_'+item.code,{typeCode:'application_category',label:item.name,value:item.code,sortOrder:index+1,status:item.status,remark:'应用分类',systemLocked:false})),
  ...['通知','提示','工作安排'].map((label,index)=>row('MOCK_DICT_ANN_'+index,{typeCode:'announcement_type',label,value:['NOTICE','TIP','WORK'][index],sortOrder:index+1,status:'ENABLED',remark:'',systemLocked:false})),
  ...[['PORTAL_UNIT','门户单位'],['GOV_DEPARTMENT','政务部门'],['OTHER','其他组织']].map(([value,label],index)=>row('MOCK_DICT_ORG_'+index,{typeCode:'organization_type',label,value,sortOrder:index+1,status:'ENABLED',remark:'',systemLocked:false})),
  ...[['ENABLED','启用'],['DISABLED','停用']].map(([value,label],index)=>row('MOCK_DICT_ENABLE_'+index,{typeCode:'enable_status',label,value,sortOrder:index+1,status:'ENABLED',remark:'系统受控',systemLocked:true})),
  ...[['NORMAL','正常'],['ABNORMAL','异常'],['UNCONFIGURED','未配置'],['DISABLED','停用']].map(([value,label],index)=>row('MOCK_DICT_RUNTIME_'+index,{typeCode:'runtime_status',label,value,sortOrder:index+1,status:'ENABLED',remark:'系统受控',systemLocked:true})),
  ...[['OIDC','OIDC'],['SAML2','SAML2'],['CUSTOM','CUSTOM'],['PUSH','PUSH']].map(([value,label],index)=>row('MOCK_DICT_PROTOCOL_'+index,{typeCode:'integration_protocol',label,value,sortOrder:index+1,status:'ENABLED',remark:'仅展示代码已支持协议',systemLocked:true}))
 ];
 const roles = [
  row('ROLE_SUPER',{roleCode:'SUPER_ADMIN',roleName:'门户超级管理员',description:'拥有全部门户管理权限及高风险管理能力，不授予子系统业务权限。',permissions:[...SUPER_PERMISSIONS],scopes:['super','system','application','integration','announcement','audit','identity'],status:'ENABLED',builtIn:true}),
  row('ROLE_ADMIN',{roleCode:'PORTAL_ADMIN',roleName:'门户管理员',description:'负责应用、公告、映射、监控、日志等日常门户维护，不授予子系统业务权限。',permissions:[...PORTAL_ADMIN_PERMISSIONS],scopes:['system','application','integration','announcement','audit','identity'],status:'ENABLED',builtIn:true})
 ];
 const apps = applicationCatalog.map(entry => {
  const n=entry.sourceNo;
  const ci=n<=2?0:n<=17?1:n<=23?2:n<=28?3:n<=33?2:n<=38?4:5;
  const accessMode=n===1?'DIRECT':[13,17].includes(n)?'REQUEST':'BIND';
  const accountBindingMode=n===2?'AUTO':n===5?'REVIEW':[3,4,6,11,12,17].includes(n)?'SELF':'ADMIN';
  const mockScenario=({1:'DIRECT',2:'AUTO_BIND',3:'OTP_BIND',4:'CREDENTIAL_BIND',5:'REVIEW_BIND',6:'NO_ACCOUNT',11:'ACCOUNT_DISABLED',12:'CONFLICT',13:'REQUEST_DIRECT',17:'REQUEST_BIND'})[n]||'BOUND_EXISTING';
  return row('MOCK_APP_'+n,{...entry,code:'WJ_APP_'+String(n).padStart(2,'0'),category:categories[ci].name,categoryId:categories[ci].id,
   userType:n<=6||[11,12,13,17,24,25,26,28,33].includes(n)?'BOTH':'GOV',
   accessMode,accountBindingMode,postGrantMode:n===17?'BIND':'DIRECT',accountOpeningMode:n===6?'REQUEST':'NONE',mockScenario,
   enabled:n!==43,status:n===43?'DISABLED':'ENABLED',
   url:'https://p4.invalid/app/'+n,sortOrder:n,integrationNote:'服务地址与接入参数待配置'});
 });
 const businessActors=actors.filter(actor=>['CITIZEN','GOV'].includes(actor.userType));
 const available = actor => apps.filter(app => app.enabled!==false && (app.userType==='BOTH'||app.userType===actor.userType));
 const mappings = businessActors.flatMap(actor => {
  if(actor.id==='MOCK_USER_1'){
   const bound=available(actor).filter(app=>app.sourceNo>=14&&!['REQUEST'].includes(app.accessMode)).slice(0,8).map(app=>row('MOCK_MAP_'+actor.id+'_'+app.sourceNo,{
    userId:actor.id,userName:actor.name,appId:app.id,appName:app.name,externalAccount:actor.account+'_'+String(app.sourceNo).padStart(2,'0'),
    externalUserId:'P4_SUBJECT_'+actor.id+'_'+app.sourceNo,status:'BOUND',bindingMethod:'ADMIN',externalAccountStatus:'ACTIVE',boundAt:at(-24),conflictReason:null
   }));
   const scenario=[
    [11,'FAILED','SELF','DISABLED','子系统账号已停用，请联系目标系统管理员'],
    [12,'CONFLICT','SELF','ACTIVE','该子系统账号已绑定其他统一用户，等待管理员处理']
   ].map(([sourceNo,status,bindingMethod,externalAccountStatus,conflictReason])=>{
    const app=apps.find(a=>a.sourceNo===sourceNo);
    return row('MOCK_MAP_'+actor.id+'_'+sourceNo,{userId:actor.id,userName:actor.name,appId:app.id,appName:app.name,
     externalAccount:actor.account+'_'+String(sourceNo).padStart(2,'0'),externalUserId:'P4_SUBJECT_'+actor.id+'_'+sourceNo,
     status,bindingMethod,externalAccountStatus,boundAt:null,conflictReason,riskLevel:sourceNo===5?'HIGH':'NORMAL'});
   });
   return [...bound,...scenario];
  }
  return [...available(actor).slice(0,8),apps.find(a=>a.sourceNo===26),apps.find(a=>a.sourceNo===28)].filter(Boolean).map((app,i) => row('MOCK_MAP_'+actor.id+'_'+app.sourceNo,{
   userId:actor.id,userName:actor.name,appId:app.id,appName:app.name,externalAccount:actor.account+'_'+String(app.sourceNo).padStart(2,'0'),
   externalUserId:'P4_SUBJECT_'+actor.id+'_'+app.sourceNo,status:i<8?'BOUND':i===8?'FAILED':'CONFLICT',bindingMethod:'ADMIN',externalAccountStatus:'ACTIVE',
   boundAt:i<8?at(-24):null,conflictReason:i===8?'账号核验未通过，待补充关联资料':i===9?'身份资料不一致，待人工核查':null
  }));
 });
 const accessibleBusinessApps=actor=>{const bound=new Set(mappings.filter(m=>m.userId===actor.id&&m.status==='BOUND').map(m=>m.appId));const rows=available(actor).filter(app=>app.accessMode==='DIRECT'||bound.has(app.id));return rows.length?rows:available(actor).slice(0,1);};
 const actions=['核对服务申请资料','补充业务登记信息','确认服务安排','查看材料核验意见','核对信息更新内容','确认事项办理进度','完善服务联系说明','查看后续办理要求','资料核验已完成','业务申请已撤回'];
 const todos=businessActors.flatMap((actor,ai)=>actions.map((title,i)=>{
  const pool=accessibleBusinessApps(actor),app=pool[i%pool.length],status=i<8?'PENDING':i===8?'COMPLETED':'WITHDRAWN';
  return row('MOCK_TODO_'+ai+'_'+i,{userId:actor.id,appId:app.id,appName:app.name,sourceTodoId:'P4_TODO_'+ai+'_'+i,title,
   summary:app.name+'：'+title+'。请在来源系统查看业务详情。',businessType:'服务事项',status,receivedAt:at(-i-2),sourceCreatedAt:at(-i-3),sourceUpdatedAt:at(-i-2),url:app.url});
 }));
 const messageTitles=['服务申请已受理','资料核验进度通知','办理期限提醒','服务安排更新','账号关联结果通知','业务信息变更提醒','材料补正通知','办理意见已反馈','门户维护安排','信息安全提醒'];
 const messages=businessActors.flatMap((actor,ai)=>messageTitles.map((title,i)=>{
  const pool=accessibleBusinessApps(actor),app=pool[i%pool.length],portal=i>=8;
  return row('MOCK_MSG_'+ai+'_'+i,{userId:actor.id,appId:portal?null:app.id,appName:portal?'统一门户':app.name,
   sourceMessageId:'P4_MSG_'+ai+'_'+i,title,content:title+'。请查看相关事项详情并按办理要求完成后续操作。',
   sourceKind:portal?'PORTAL':'APPLICATION',messageType:portal?'SYSTEM':i===2?'TODO_REMINDER':'BUSINESS',
   status:i<8?'UNREAD':'READ',readAt:i<8?null:at(-1),deleted:false,deletedAt:null,receivedAt:at(-i-1),url:portal?null:app.url});
 }));
 const announcementRows=[
  ['关于门户服务使用安排的通知','请通过应用中心查看服务入口，业务办理要求以来源系统说明为准。','ALL','PUBLISHED','IMMEDIATE',null,null],
  ['关于完善应用接入资料的通知','请整理应用目录、责任分工与接口字段，提交接入资料核验。','GOV','DRAFT',null,null,null],
  ['公众服务事项办理指引','请在办事前核对材料清单，关注待办与消息中的办理要求。','CITIZEN','PUBLISHED','IMMEDIATE',null,null],
  ['卫生健康统计报送安排','请核对本期统计报表，并在规定期限内完成报送。','GOV','DRAFT','SCHEDULED',at(720),null],
  ['运行保障值班安排','请核对值班分工，及时记录运行问题与处理情况。','GOV','DRAFT',null,null,null],
  ['信息发布审核工作安排','发布前须核对内容、发布范围与有效期。','ALL','DRAFT',null,null,null],
  ['原维护时段安排撤回通知','原维护时段安排已撤回，后续安排另行通知。','ALL','WITHDRAWN','IMMEDIATE',null,null],
  ['个人信息保护提示','请妥善保管账号，勿向他人提供验证码或身份核验资料。','ALL','PUBLISHED','IMMEDIATE',null,at(-1)]
 ];
 const announcements=announcementRows.map(([title,content,scope,status,publishMode,scheduledPublishAt,effectiveEnd],i)=>{const pendingDraft=status==='DRAFT'&&publishMode!=='SCHEDULED';return row('MOCK_ANN_'+(i+1),{
  title,content,type:i===7?'提示':'通知',scope,status,publishMode,scheduledPublishAt,effectiveEnd,submittedAt:pendingDraft?null:at(-30-i),submittedBy:pendingDraft?null:actors[3].id,
  publisherId:pendingDraft?null:actors[3].id,publishedAt:status==='PUBLISHED'?at(-24-i):null,withdrawnAt:status==='WITHDRAWN'?at(-6):null,attachments:[]
 });});
 const settingRows=[
  ['retention.message_days','消息留存周期（天）',90,'day'],['retention.todo_terminal_days','终态待办留存周期（天）',180,'day'],
  ['retention.log_days','日志留存周期（天）',180,'day'],['auth.session_ttl_seconds','会话有效期（秒）',null,'second'],
  ['integration.timeout_ms','接口超时（毫秒）',5000,'millisecond'],['integration.max_retries','接口重试上限',3,'count'],
  ['monitor.failure_threshold','连续失败告警阈值',5,'count']
 ];
 const settings=settingRows.map(([code,name,value,unit],i)=>row('MOCK_CONFIG_'+i,{code,name,value,unit,status:value===null?'UNCONFIGURED':'CONFIGURED'}));
 const integrations=apps.flatMap((app,i)=>['SSO','TODO','MESSAGE'].map((kind,k)=>row('MOCK_INT_'+app.id+kind,{
  appId:app.id,appName:app.name,name:app.name+' · '+kind,kind,mode:kind==='SSO'?'SSO':'PUSH',
  runtimeStatus:app.enabled===false?'DISABLED':['UNCONFIGURED','NORMAL','ABNORMAL','DISABLED'][(i+k)%4],
  configStatus:(i+k)%4===0?'UNCONFIGURED':'CONFIGURED',
  enabled:app.enabled===false||(i+k)%4===3?'DISABLED':'ENABLED',
  remark:'接入参数待业务系统确认',lastCheckedAt:at(-k-1)
 })));
 const identityCode=actor=>actor.authType==='LOCAL'?'PORTAL_LOCAL':actor.userType==='GOV'?'MINZHENGWU':'MINZHENGTONG';
 const logs=['login','access','operation','api','error'].flatMap((kind,k)=>actors.map((actor,i)=>{
  const app=apps[i],failed=kind==='login'&&i===3,errorOpen=kind==='error'&&i%2===0;
  const common={kind,actor:actor.name,userId:actor.id,userName:actor.name,account:actor.account,userType:actor.userType,actorType:actor.kind==='ADMIN'?'PORTAL_ADMIN_USER':'ACCESS_USER',authType:actor.authType||'EXTERNAL',identitySource:identityCode(actor),
   appId:app.id,appName:app.name,status:kind==='error'?'FAILURE':failed?'FAILURE':'SUCCESS',createdAt:at(-k*4-i),requestId:'P4_REQUEST_'+k+'_'+i,ip:'127.0.0.1',client:'Chrome / Windows'};
  if(kind==='login')return row('MOCK_LOG_login_'+i,{...common,name:'身份登录',loginSource:'统一登录',loginMethod:actor.authType==='LOCAL'?'PASSWORD':'QR',failureReason:failed?'上层认证超时':null,description:failed?'登录认证失败':'登录成功'});
  if(kind==='access')return row('MOCK_LOG_access_'+i,{...common,name:'应用访问',accessMethod:'门户入口',accessMode:app.accessMode,description:'访问应用 '+app.name});
  if(kind==='operation')return row('MOCK_LOG_operation_'+i,{...common,name:'门户操作',moduleName:i%2?'系统管理':'应用管理',pageName:i%2?'用户管理':'应用列表',actionName:i%2?'维护用户':'维护应用',objectType:i%2?'USER':'APPLICATION',objectId:i%2?actor.id:app.id,description:'门户管理操作记录'});
  if(kind==='api')return row('MOCK_LOG_api_'+i,{...common,name:'接口调用',interfaceName:i%2?'/api/portal/ingest/todos':'/api/portal/ingest/messages',httpMethod:'POST',statusCode:i===4?500:200,durationMs:80+i*35,errorMessage:i===4?'模拟接口响应异常':null,description:'接口调用记录'});
  return row('MOCK_LOG_error_'+i,{...common,name:'接入异常',severity:i%2?'MEDIUM':'HIGH',moduleName:i%2?'运行监控':'身份映射',errorCode:i%2?'UPSTREAM_TIMEOUT':'ACCOUNT_MAPPING_CONFLICT',
   errorMessage:i%2?'上游服务响应超时':'子系统账号关联冲突',resolutionStatus:errorOpen?'OPEN':'RESOLVED',resolutionNote:errorOpen?'':'已完成Mock核查',resolvedAt:errorOpen?null:at(-1),resolvedBy:errorOpen?null:actors[2].id,description:i%2?'上游服务响应超时':'子系统账号关联冲突'});
 }));
 const visits=businessActors.flatMap(actor=>available(actor).slice(0,4).map((app,i)=>({userId:actor.id,appId:app.id,at:at(-i-1)})));
 const requestApp13=apps.find(x=>x.id==='MOCK_APP_13'),requestApp17=apps.find(x=>x.id==='MOCK_APP_17');
 const applicationRequests=[
  row('MOCK_REQ_CITIZEN_EXPIRED',{createdAt:at(-50),updatedAt:at(-44),requestNo:'REQ-20260915-00001',userId:'MOCK_USER_1',userName:'林晓',appId:requestApp13.id,appName:requestApp13.name,reason:'历史申请：未在有效期内完成后续处理',status:'EXPIRED',submittedAt:at(-50),expiredAt:at(-44),reviewedBy:null,reviewedAt:null,reviewNote:'申请已失效，可重新发起申请'}),
  row('MOCK_REQ_CITIZEN_WITHDRAWN',{createdAt:at(-38),updatedAt:at(-35),requestNo:'REQ-20260916-00001',userId:'MOCK_USER_1',userName:'林晓',appId:requestApp13.id,appName:requestApp13.name,reason:'历史申请：业务使用需要',status:'WITHDRAWN',submittedAt:at(-38),withdrawnAt:at(-35),reviewedBy:null,reviewedAt:null,reviewNote:'用户主动撤回'}),
  row('MOCK_REQ_CITIZEN_REJECTED',{createdAt:at(-30),updatedAt:at(-27),requestNo:'REQ-20260916-00002',userId:'MOCK_USER_1',userName:'林晓',appId:requestApp13.id,appName:requestApp13.name,reason:'历史申请：业务使用需要',status:'REJECTED',submittedAt:at(-30),reviewedBy:'MOCK_ADMIN',reviewedAt:at(-27),reviewNote:'资料不完整，请补充后重新申请'}),
  row('MOCK_REQ_CITIZEN_APPROVED',{createdAt:at(-18),updatedAt:at(-16),requestNo:'REQ-20260917-00001',userId:'MOCK_USER_1',userName:'林晓',appId:requestApp13.id,appName:requestApp13.name,reason:'申请访问公众业务应用',status:'APPROVED',submittedAt:at(-18),reviewedBy:'MOCK_ADMIN',reviewedAt:at(-16),reviewNote:'审核通过，可直接进入应用'}),
  row('MOCK_REQ_CITIZEN_PENDING',{createdAt:at(-8),updatedAt:at(-8),requestNo:'REQ-20260918-00001',userId:'MOCK_USER_1',userName:'林晓',appId:requestApp17.id,appName:requestApp17.name,reason:'申请访问需要账号确认的业务应用',status:'PENDING',submittedAt:at(-8),reviewedBy:null,reviewedAt:null,reviewNote:null}),
  row('MOCK_REQ_GOV_REJECTED',{createdAt:at(-7),updatedAt:at(-6),requestNo:'REQ-20260918-00002',userId:'MOCK_USER_2',userName:'陈宁',appId:requestApp13.id,appName:requestApp13.name,reason:'申请业务使用权限',status:'REJECTED',submittedAt:at(-7),reviewedBy:'MOCK_ADMIN',reviewedAt:at(-6),reviewNote:'资料不完整，可查看原因后重新申请'}),
  row('MOCK_REQ_GOV_APPROVED_BIND',{createdAt:at(-14),updatedAt:at(-12),requestNo:'REQ-20260917-00002',userId:'MOCK_USER_2',userName:'陈宁',appId:requestApp17.id,appName:requestApp17.name,reason:'申请业务使用权限并确认历史账号',status:'APPROVED',submittedAt:at(-14),reviewedBy:'MOCK_ADMIN',reviewedAt:at(-12),reviewNote:'审核通过，请继续完成账号确认'})
 ];
 const applicationGrants=[
  row('MOCK_GRANT_CITIZEN_APP13',{userId:'MOCK_USER_1',appId:requestApp13.id,status:'ACTIVE',grantedBy:'MOCK_ADMIN',grantedAt:at(-16),expiresAt:null}),
  row('MOCK_GRANT_GOV_APP17',{userId:'MOCK_USER_2',appId:requestApp17.id,status:'ACTIVE',grantedBy:'MOCK_ADMIN',grantedAt:at(-12),expiresAt:null})
 ];
 const accountOpeningRequests=[];
 const mappingVerificationEvents=[];
 const users=structuredClone(actors).map((user,index)=>({...user,firstLoginAt:at(-240+index*8),lastLoginAt:at(-index-1),lockedUntil:null,mustChangePassword:user.authType==='LOCAL'?false:null}));
 return {schemaVersion:6,users,roles,apps,platforms:structuredClone(platforms),categories,organizations,dictTypes,dictItems,mappings,
  applicationRequests,applicationGrants,accountOpeningRequests,mappingVerificationEvents,
  todos,messages,announcements,announcementReads:[],settings,integrations,logs,visits,receipts:[]};
}