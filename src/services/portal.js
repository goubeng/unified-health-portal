import {can,scopes} from '../config/pages.js';
import {actors} from '../mock/seed.js';
import {rules} from '../config/rules.js';
import {integrationFields,terminalStatuses} from '../config/integration-contract.js';
const canonical=value=>JSON.stringify(Object.fromEntries(Object.entries(value).sort(([a],[b])=>a.localeCompare(b))));
const fail=(code,message)=>{throw Object.assign(new Error(message),{code});};
const own=(x,a)=>x.userId===a.id;
const appRequiresBinding=app=>app?.accessMode==='BIND'||(app?.accessMode==='REQUEST'&&app?.postGrantMode==='BIND');
const identitySourceName=user=>user?.userType==='GOV'?'闽政务':user?.userType==='LOCAL'?'门户本地':'闽政通';
const visible=(x,a)=>x.status==='PUBLISHED'&&(!x.effectiveStart||Date.parse(x.effectiveStart)<=Date.now())&&(!x.effectiveEnd||Date.parse(x.effectiveEnd)>Date.now())&&(x.scope==='ALL'||x.scope===a.userType);
const checkUrl=url=>{try{const u=new URL(url);if(!['https:','http:'].includes(u.protocol))throw Error();return u;}catch{fail('VALIDATION_ERROR','请输入有效的 HTTP/HTTPS 地址');}};
export function createPortalService(provider,getActor){
 const wrap=fn=>async(...args)=>{try{const selected=getActor();if(!selected)fail('UNAUTHENTICATED','请先登录');const actor=provider.kind==='mock'?(provider.read().users||actors).find(x=>x.id===selected.id):selected;if(!actor||actor.status==='DISABLED')fail('FORBIDDEN','当前用户已停用或不存在，请联系门户管理员');return {ok:true,data:await fn(actor,...args),requestId:crypto.randomUUID()};}catch(e){return {ok:false,error:{code:e.code||'ERROR',message:e.message,retryable:false},requestId:crypto.randomUUID()};}};
 const auth=(a,s)=>{if(!can(a,s))fail('FORBIDDEN','当前身份没有该权限范围');};
 const requireRow=(list,id,version)=>{const row=list.find(x=>x.id===id);if(!row)fail('NOT_FOUND','记录不存在');if(version!==undefined&&row.version!==version)fail('VERSION_CONFLICT','记录已更新，请刷新后重试');return row;};
 const requestFor=(d,a,appId)=>[...(d.applicationRequests||[])].filter(x=>x.userId===a.id&&x.appId===appId).sort((x,y)=>(Date.parse(y.submittedAt||y.createdAt)||0)-(Date.parse(x.submittedAt||x.createdAt)||0))[0]||null;
 const grantFor=(d,a,appId)=>(d.applicationGrants||[]).find(x=>x.userId===a.id&&x.appId===appId&&x.status==='ACTIVE')||null;
 const decorate=(d,a)=>d.apps.map(app=>{
  const applicable=a.userType!=='LOCAL'&&(app.userType==='BOTH'||app.userType===a.userType);
  const mapping=d.mappings.find(m=>m.appId===app.id&&own(m,a)&&m.status!=='UNBOUND')||null;
  const request=requestFor(d,a,app.id),grant=grantFor(d,a,app.id);
  const accessMode=app.accessMode||'BIND';
  const requiresBinding=appRequiresBinding(app)&&Boolean(accessMode!=='REQUEST'||grant);
  let accessState='UNBOUND';
  if(!applicable)accessState='NOT_APPLICABLE';
  else if(app.status!=='ENABLED')accessState='APP_DISABLED';
  else if(accessMode==='REQUEST'&&!grant){
   accessState=request?.status==='PENDING'?'REQUEST_PENDING':request?.status==='REJECTED'?'REQUEST_REJECTED':'REQUEST_REQUIRED';
  }else if(requiresBinding)accessState=mapping?.status||'UNBOUND';
  else accessState='DIRECT';
  const primaryAction=({
   DIRECT:'ENTER',BOUND:'ENTER',UNBOUND:'BIND',VERIFYING:'CONTINUE_BIND',REVIEWING:'VIEW_BINDING',
   FAILED:'BIND',CONFLICT:'VIEW_CONFLICT',REQUEST_REQUIRED:'REQUEST',REQUEST_REJECTED:'REQUEST',REQUEST_PENDING:'VIEW_REQUEST'
  })[accessState]||'VIEW';
  return {...app,applicable,mappingStatus:mapping?.status||'UNBOUND',mappingId:mapping?.id||null,externalAccountStatus:mapping?.externalAccountStatus||null,
   requestStatus:request?.status||null,requestId:request?.id||null,grantStatus:grant?.status||null,accessState,primaryAction};
 });
 const accountApps=(d,a)=>{
  const ids=new Set();
  d.mappings.filter(x=>own(x,a)&&x.status!=='UNBOUND').forEach(x=>ids.add(x.appId));
  d.todos.filter(x=>own(x,a)).forEach(x=>ids.add(x.appId));
  d.messages.filter(x=>own(x,a)&&x.appId).forEach(x=>ids.add(x.appId));
  d.visits.filter(x=>x.userId===a.id).forEach(x=>ids.add(x.appId));
  return decorate(d,a).filter(x=>x.status==='ENABLED'&&x.applicable&&(ids.has(x.id)||['DIRECT','BOUND'].includes(x.accessState)));
 };
 const roleNames=(d,user)=>(user.roleIds||[]).map(id=>(d.roles||[]).find(role=>role.id===id)?.roleName).filter(Boolean);
 const scopesFromRoles=(d,ids)=>[...new Set((ids||[]).flatMap(id=>(d.roles||[]).find(role=>role.id===id&&role.status==='ENABLED')?.scopes||[]))];
 const decorateUser=(d,user)=>({...user,identitySource:identitySourceName(user),roleNames:roleNames(d,user),roleLabels:roleNames(d,user).join('、')||'无管理角色'});
 const syncUserRoleScopes=(d,user)=>{const requested=scopesFromRoles(d,user.roleIds||[]);user.scopes=requested;user.kind=requested.length?'ADMIN':'USER';user.roleName=roleNames(d,user)[0]||'普通用户';return user;};
 const monitorStatus=(app,item)=>{
  if(app.status==='DISABLED')return 'DISABLED';
  if(!item)return 'UNCONFIGURED';
  if(['UNCONFIGURED','DISABLED','NORMAL','ABNORMAL'].includes(item.status))return item.status;
  return 'UNCONFIGURED';
 };
 const monitorProfiles=d=>{
  const groups=new Map();
  for(const item of d.integrations||[]){
   if(!groups.has(item.appId))groups.set(item.appId,{});
   groups.get(item.appId)[item.kind]=item;
  }
  return d.apps.map(app=>{
   const kinds=groups.get(app.id)||{};
   const measured=kind=>(d.monitorSamples||[]).find(x=>x.appId===app.id&&x.kind===kind)||kinds[kind]||null;
   const sso=measured('SSO'),todo=measured('TODO'),message=measured('MESSAGE');
   const times=[sso?.lastCheckedAt,todo?.lastCheckedAt,message?.lastCheckedAt,sso?.updatedAt,todo?.updatedAt,message?.updatedAt].filter(Boolean).sort();
   return {id:'MONITOR_'+app.id,appId:app.id,appName:app.name,appCode:app.code,
    ssoStatus:monitorStatus(app,sso),todoStatus:monitorStatus(app,todo),messageStatus:monitorStatus(app,message),
    lastCheckedAt:times.at(-1)||null,dataSource:'FIXTURE',status:[sso,todo,message].some(x=>x?.status==='ABNORMAL')?'ABNORMAL':[sso,todo,message].every(x=>x?.status==='NORMAL')?'NORMAL':'UNCONFIGURED',remark:'运行场景数据，不执行外部探测'};
  });
 };
 const accessProfiles=d=>{
  const groups=new Map();
  for(const item of d.integrations||[]){
   if(!groups.has(item.appId))groups.set(item.appId,{});
   groups.get(item.appId)[item.kind]=item;
  }
  return d.apps.filter(app=>groups.has(app.id)).map(app=>{
   const kinds=groups.get(app.id),sso=kinds.SSO||null,todo=kinds.TODO||null,message=kinds.MESSAGE||null;
   const times=[sso?.updatedAt,todo?.updatedAt,message?.updatedAt,sso?.createdAt,todo?.createdAt,message?.createdAt].filter(Boolean).sort();
   return {id:app.id,appId:app.id,appName:app.name,appCode:app.code,updatedAt:times.at(-1)||app.updatedAt||app.createdAt,
    ssoStatus:sso?.status||'UNCONFIGURED',ssoRemark:sso?.remark||'未配置',todoStatus:todo?.status||'UNCONFIGURED',todoRemark:todo?.remark||'未配置',messageStatus:message?.status||'UNCONFIGURED',messageRemark:message?.remark||'未配置',
    integrations:{SSO:sso,TODO:todo,MESSAGE:message}};
  });
 };
 return {
  read:wrap((a,resource)=>{
   if(provider.kind!=='mock')fail('CAPABILITY_UNAVAILABLE','真实服务尚未配置');
   const d=provider.read(),allApps=decorate(d,a),userApps=accountApps(d,a);
   if(resource==='apps')return allApps.filter(x=>x.applicable&&x.status==='ENABLED');
   if(resource==='adminApps'){if(a.kind!=='ADMIN')fail('FORBIDDEN','仅门户管理端可读取全量应用目录');return allApps;}
   if(resource==='mine')return userApps.filter(x=>['DIRECT','BOUND'].includes(x.accessState));
   if(resource==='todos'||resource==='messages')return d[resource].filter(x=>own(x,a));
   if(resource==='announcements')return d.announcements.filter(x=>visible(x,a)).map(x=>({...x,readStatus:(d.announcementReads||[]).some(r=>r.announcementId===x.id&&own(r,a))?'READ':'UNREAD'}));
   if(resource==='adminAnnouncements'){auth(a,'announcement');return d.announcements;}
   if(resource==='profile')return decorateUser(d,a);
   if(resource==='myApplicationRequests'){
    const access=(d.applicationRequests||[]).filter(x=>own(x,a)).map(x=>{const app=d.apps.find(item=>item.id===x.appId);return {...x,requestType:'APPLICATION_ACCESS',appName:app?.name||x.appName,accessMode:app?.accessMode||'REQUEST',postGrantMode:app?.postGrantMode||'DIRECT'};});
    const opening=(d.accountOpeningRequests||[]).filter(x=>own(x,a)).map(x=>({...x,requestType:'ACCOUNT_OPENING',appName:d.apps.find(app=>app.id===x.appId)?.name||x.appName}));
    return [...access,...opening].sort((x,y)=>(Date.parse(y.submittedAt)||0)-(Date.parse(x.submittedAt)||0));
   }
   if(resource==='home')return {appCount:userApps.length,todoCount:d.todos.filter(x=>own(x,a)&&x.status==='PENDING').length,unreadCount:d.messages.filter(x=>own(x,a)&&x.status==='UNREAD').length,announcementCount:d.announcements.filter(x=>visible(x,a)).length,unreadAnnouncementCount:d.announcements.filter(x=>visible(x,a)&&!(d.announcementReads||[]).some(r=>r.announcementId===x.id&&own(r,a))).length};
   const permissions={categories:'application',access:'application',applicationRequests:'application',accountOpeningRequests:'application',identityOverview:'identity',identities:'identity',identityMappings:'identity',mappings:'identity',exceptions:'identity',roles:'super',permissions:'super',sso:'integration',todoIntegration:'integration',messageIntegration:'integration',external:'integration',settings:'super',monitor:'integration',adminHome:'any',users:'system',organizations:'system',dictionaries:'system'};
   auth(a,resource.startsWith('logs:')?'audit':permissions[resource]||'super');
   if(resource.startsWith('logs:'))return d.logs.filter(x=>x.kind===resource.split(':')[1]);
   if(resource==='applicationRequests')return (d.applicationRequests||[]).map(x=>({...x,appName:d.apps.find(app=>app.id===x.appId)?.name||x.appName,userName:(d.users||actors).find(user=>user.id===x.userId)?.name||x.userName})).sort((x,y)=>(Date.parse(y.submittedAt)||0)-(Date.parse(x.submittedAt)||0));
   if(resource==='accountOpeningRequests')return (d.accountOpeningRequests||[]).map(x=>({...x,appName:d.apps.find(app=>app.id===x.appId)?.name||x.appName,userName:(d.users||actors).find(user=>user.id===x.userId)?.name||x.userName})).sort((x,y)=>(Date.parse(y.submittedAt)||0)-(Date.parse(x.submittedAt)||0));
   if(['categories','settings','mappings','organizations'].includes(resource))return d[resource];
   if(resource==='dictionaries')return {types:d.dictTypes||[],items:d.dictItems||[]};
   if(resource==='users'||resource==='identities')return (d.users||actors).map(user=>decorateUser(d,user));
   if(resource==='identityOverview')return d.users.map(user=>{
    const mappings=d.mappings.filter(m=>m.userId===user.id).map(m=>({...m,appName:d.apps.find(app=>app.id===m.appId)?.name||m.appName,todoCount:d.todos.filter(t=>t.userId===user.id&&t.appId===m.appId).length,messageCount:d.messages.filter(t=>t.userId===user.id&&t.appId===m.appId).length}));
    return {...decorateUser(d,user),user:{...decorateUser(d,user),source:identitySourceName(user)},source:identitySourceName(user),mappings,boundCount:mappings.filter(m=>m.status==='BOUND').length,reviewCount:mappings.filter(m=>m.status==='REVIEWING').length,exceptionCount:mappings.filter(m=>['FAILED','CONFLICT'].includes(m.status)).length};
   });
   if(resource==='identityMappings')return (d.users||actors).map(x=>({id:x.id,name:x.name,source:identitySourceName(x),status:'BOUND'}));
   if(resource==='exceptions')return d.mappings.filter(x=>x.status==='CONFLICT'||x.status==='FAILED');
   if(resource==='roles')return (d.roles||[]).map(role=>({...role,userCount:(d.users||[]).filter(user=>(user.roleIds||[]).includes(role.id)).length,scopeLabels:(role.scopes||[]).map(s=>scopes[s]||s).join('、')||'无门户管理权限'}));
   if(resource==='permissions')return Object.entries(scopes).map(([code,name])=>({id:code,code,name,description:'用于控制卫健统一门户内部页面与操作权限；不授予任何子系统业务权限。',status:'ENABLED'}));
   if(resource==='external')return [];
   if(resource==='adminHome')return {appCount:d.apps.length,enabledCount:d.apps.filter(x=>x.status==='ENABLED').length,exceptionCount:d.mappings.filter(x=>['CONFLICT','FAILED'].includes(x.status)).length,integrationCount:d.integrations.filter(x=>x.status==='NORMAL').length,pendingAccessCount:(d.applicationRequests||[]).filter(x=>x.status==='PENDING').length};
   if(resource==='monitor')return monitorProfiles(d);
   if(resource==='access')return accessProfiles(d);
   const kind={sso:'SSO',todoIntegration:'TODO',messageIntegration:'MESSAGE'}[resource];
   return kind?d.integrations.filter(x=>x.kind===kind):[];
  }),
  command:wrap((a,action,p={})=>{
   if(provider.kind!=='mock')fail('CAPABILITY_UNAVAILABLE','真实服务尚未配置');
   return provider.transact(d=>{
    const now=new Date().toISOString(),id=()=> 'MOCK_'+crypto.randomUUID();
    const stamp=x=>Object.assign(x,{version:(x.version||0)+1,updatedAt:now});
    const ensureMapping=(app,externalAccount,values={})=>{
     let mapping=d.mappings.find(m=>m.userId===a.id&&m.appId===app.id);
     if(!mapping){mapping={id:id(),version:0,createdAt:now,userId:a.id,userName:a.name,appId:app.id,appName:app.name,boundAt:null};d.mappings.push(mapping);}
     Object.assign(mapping,{externalAccount,externalUserId:values.externalUserId||mapping.externalUserId||'DEMO_SUBJECT_'+a.id+'_'+app.sourceNo,...values});
     return stamp(mapping);
    };
    let result=null;
    const scopesByAction={removeAnnouncement:'announcement',saveRules:'super',createLocalPortalUser:'super',savePortalUser:'super',resetLocalPassword:'super',unlockLocalUser:'super',setPortalUserStatus:'system',saveSystemRole:'super',saveOrganization:'system',removeOrganization:'super',saveDictionaryType:'system',saveDictionaryItem:'system',saveApp:'application',setAppStatus:'application',saveCategory:'application',removeCategory:'application',saveAnnouncement:'announcement',publish:'announcement',withdraw:'announcement',saveConfig:'super',saveIntegration:'application',createAccessProfile:'application',approveApplicationRequest:'application',rejectApplicationRequest:'application',completeMockAccountOpeningRequest:'application',approveBindingReview:'identity',rejectBindingReview:'identity',unbind:'identity',resolveMapping:'identity',pushTodo:'integration',pushMessage:'integration'};
    if(scopesByAction[action])auth(a,scopesByAction[action]);
    if(action==='removeAnnouncement'){
     const x=requireRow(d.announcements,p.id,p.version);if(x.status!=='DRAFT')fail('INVALID_TRANSITION','仅草稿公告可以删除');
     d.announcementTrash??=[];d.announcementTrash.push({...x,deletedAt:now,deletedBy:a.id,deleteReason:'DRAFT_DELETE'});d.announcements=d.announcements.filter(x=>x.id!==p.id);d.announcementReads=(d.announcementReads||[]).filter(x=>x.announcementId!==p.id);result={id:p.id};
    }else if(action==='saveRules'){
     if(!Array.isArray(p.items)||p.items.length!==rules.length||new Set(p.items.map(x=>x.code)).size!==rules.length)fail('VALIDATION_ERROR','请提交完整规则配置');
     for(const item of p.items){const rule=rules.find(x=>x.code===item.code);if(!rule||!Number.isSafeInteger(item.value)||item.value<rule.min||item.value>rule.max)fail('VALIDATION_ERROR',`${rule?.name||item.code}超出允许范围`);const x=requireRow(d.settings,item.id,item.version);if(x.code!==item.code)fail('VALIDATION_ERROR','规则标识不匹配');x.value=item.value;x.status='CONFIGURED';stamp(x);}result=d.settings;
    }else if(action==='createLocalPortalUser'){
     if(!p.account?.trim()||!p.name?.trim())fail('VALIDATION_ERROR','登录账号与姓名为必填');
     if((d.users||[]).some(user=>String(user.account).toLowerCase()===p.account.trim().toLowerCase()))fail('VALIDATION_ERROR','登录账号已存在');
     const roleIds=Array.isArray(p.roleIds)?[...new Set(p.roleIds)]:[];
     if(roleIds.some(roleId=>!(d.roles||[]).some(role=>role.id===roleId&&role.status==='ENABLED')))fail('VALIDATION_ERROR','请选择有效门户角色');
     const x={id:id(),version:1,createdAt:now,updatedAt:now,account:p.account.trim(),name:p.name.trim(),kind:'USER',userType:'LOCAL',identitySource:'门户本地',
      orgName:p.orgName?.trim()||'',orgKey:p.orgKey||'',mobile:p.mobile?.trim()||'未提供',email:p.email?.trim()||'未提供',department:p.department?.trim()||'',jobTitle:p.jobTitle?.trim()||'',
      scopes:[],roleIds,status:'NORMAL',firstLoginAt:null,lastLoginAt:null,lockedUntil:null,mustChangePassword:true,credentialStatus:'MOCK_PENDING'};
     syncUserRoleScopes(d,x);d.users.push(x);result=decorateUser(d,x);
    }else if(action==='setPortalUserStatus'){
     const x=requireRow(d.users,p.id,p.version);if(!['NORMAL','DISABLED'].includes(p.status))fail('VALIDATION_ERROR','启用状态无效');
     if(x.id===a.id&&p.status==='DISABLED')fail('INVALID_TRANSITION','不能停用当前登录账号');
     const isSuper=(x.roleIds||[]).includes('ROLE_SUPER');
     if(isSuper&&p.status==='DISABLED'){
      const activeSupers=(d.users||[]).filter(user=>user.id!==x.id&&user.status!=='DISABLED'&&(user.roleIds||[]).includes('ROLE_SUPER'));
      if(!activeSupers.length)fail('INVALID_TRANSITION','不能停用最后一个有效门户超级管理员');
     }
     x.status=p.status;result=stamp(x);
    }else if(action==='resetLocalPassword'){
     const x=requireRow(d.users,p.id,p.version);if(x.userType!=='LOCAL')fail('INVALID_TRANSITION','外部身份用户密码由闽政通/闽政务管理');
     x.mustChangePassword=true;x.passwordResetAt=now;x.credentialStatus='MOCK_RESET';result=stamp(x);
    }else if(action==='unlockLocalUser'){
     const x=requireRow(d.users,p.id,p.version);if(x.userType!=='LOCAL')fail('INVALID_TRANSITION','仅门户本地账号支持门户解锁');
     x.lockedUntil=null;x.failedLoginCount=0;result=stamp(x);
    }else if(action==='savePortalUser'){
     const x=requireRow(d.users,p.id,p.version),roleIds=Array.isArray(p.roleIds)?[...new Set(p.roleIds)]:x.roleIds||[];
     if(!['NORMAL','DISABLED'].includes(p.status)||roleIds.some(roleId=>!(d.roles||[]).some(role=>role.id===roleId&&role.status==='ENABLED')))fail('VALIDATION_ERROR','请选择有效的启用状态与门户角色');
     const requested=scopesFromRoles(d,roleIds),removesSuper=(x.roleIds||[]).includes('ROLE_SUPER')&&!roleIds.includes('ROLE_SUPER');
     if(x.id===a.id&&(p.status==='DISABLED'||!requested.includes('super')))fail('INVALID_TRANSITION','不能停用当前账号或移除自身超级管理权限');
     if(removesSuper||p.status==='DISABLED'){
      const activeSupers=(d.users||[]).filter(user=>user.id!==x.id&&user.status!=='DISABLED'&&(user.roleIds||[]).includes('ROLE_SUPER'));
      if((x.roleIds||[]).includes('ROLE_SUPER')&&!activeSupers.length)fail('INVALID_TRANSITION','不能移除或停用最后一个有效门户超级管理员');
     }
     const editable={status:p.status,roleIds};
     if(x.userType==='LOCAL')Object.assign(editable,{name:p.name?.trim()||x.name,orgName:p.orgName?.trim()||'',orgKey:p.orgKey||'',mobile:p.mobile?.trim()||'未提供',email:p.email?.trim()||'未提供',department:p.department?.trim()||'',jobTitle:p.jobTitle?.trim()||''});
     Object.assign(x,editable);syncUserRoleScopes(d,x);result=stamp(x);
    }else if(action==='saveOrganization'){
     if(!p.code?.trim()||!p.name?.trim())fail('VALIDATION_ERROR','组织编码与组织名称为必填');
     if((d.organizations||[]).some(org=>org.code===p.code.trim()&&org.id!==p.id))fail('VALIDATION_ERROR','组织编码已存在');
     if(!['ENABLED','DISABLED'].includes(p.status))fail('VALIDATION_ERROR','请选择有效启用状态');
     const parent=p.parentId?(d.organizations||[]).find(org=>org.id===p.parentId):null;
     if(p.parentId&&!parent)fail('VALIDATION_ERROR','上级组织不存在');
     const x=p.id?requireRow(d.organizations,p.id,p.version):{id:id(),version:0,createdAt:now};
     Object.assign(x,{code:p.code.trim(),name:p.name.trim(),type:p.type||'OTHER',parentId:p.parentId||null,parentName:parent?.name||null,
      path:parent?parent.path+' / '+p.name.trim():p.name.trim(),source:p.source||'PORTAL_LOCAL',status:p.status,sortOrder:Number(p.sortOrder)||0,remark:p.remark?.trim()||''});
     stamp(x);if(!p.id)d.organizations.push(x);result=x;
    }else if(action==='removeOrganization'){
     const x=requireRow(d.organizations||[],p.id,p.version);
     if((d.organizations||[]).some(org=>org.parentId===x.id))fail('INVALID_TRANSITION','存在下级组织，不能删除');
     if((d.users||[]).some(user=>user.orgName===x.name))fail('INVALID_TRANSITION','组织仍被用户引用，不能删除');
     d.organizations=d.organizations.filter(org=>org.id!==x.id);result={id:x.id};
    }else if(action==='saveDictionaryType'){
     if(!p.code?.trim()||!p.name?.trim())fail('VALIDATION_ERROR','字典编码与名称为必填');
     if((d.dictTypes||[]).some(type=>type.code===p.code.trim()&&type.id!==p.id))fail('VALIDATION_ERROR','字典编码已存在');
     const current=p.id?requireRow(d.dictTypes,p.id,p.version):null;
     if(current?.systemLocked&&(p.code!==current.code||p.systemLocked===false))fail('INVALID_TRANSITION','系统受控字典不允许修改编码或解除锁定');
     const x=current||{id:id(),version:0,createdAt:now,systemLocked:false};
     Object.assign(x,{code:p.code.trim(),name:p.name.trim(),description:p.description?.trim()||'',status:p.status||'ENABLED',sortOrder:Number(p.sortOrder)||0});
     stamp(x);if(!current)d.dictTypes.push(x);result=x;
    }else if(action==='saveDictionaryItem'){
     if(!p.typeCode?.trim()||!p.label?.trim()||!p.value?.trim())fail('VALIDATION_ERROR','字典类型、标签和值为必填');
     const type=(d.dictTypes||[]).find(item=>item.code===p.typeCode);if(!type)fail('VALIDATION_ERROR','字典类型不存在');
     if((d.dictItems||[]).some(item=>item.typeCode===p.typeCode&&item.value===p.value.trim()&&item.id!==p.id))fail('VALIDATION_ERROR','同一字典类型下值不能重复');
     const current=p.id?requireRow(d.dictItems,p.id,p.version):null;
     if(type.systemLocked&&!current)fail('INVALID_TRANSITION','系统受控字典不能新增代码未支持的值');
     if(current?.systemLocked&&p.value!==current.value)fail('INVALID_TRANSITION','系统受控字典值不可修改');
     const x=current||{id:id(),version:0,createdAt:now,systemLocked:Boolean(type.systemLocked)};
     Object.assign(x,{typeCode:p.typeCode,label:p.label.trim(),value:p.value.trim(),sortOrder:Number(p.sortOrder)||0,status:p.status||'ENABLED',remark:p.remark?.trim()||''});
     stamp(x);if(!current)d.dictItems.push(x);
     if(p.typeCode==='application_category'){
      let category=(d.categories||[]).find(item=>item.code===x.value);
      if(!category){category={id:'MOCK_CAT_'+crypto.randomUUID(),version:1,createdAt:now};d.categories.push(category);}
      Object.assign(category,{name:x.label,code:x.value,status:x.status,sortOrder:x.sortOrder,updatedAt:now});
      d.apps.filter(app=>app.categoryId===category.id||app.category===current?.label).forEach(app=>{app.category=x.label;app.categoryId=category.id;stamp(app);});
     }
     result=x;
    }else if(action==='saveSystemRole'){
     if(!p.roleName?.trim()||!p.roleCode?.trim())fail('VALIDATION_ERROR','角色名称与角色编码为必填');
     const requested=Array.isArray(p.scopes)?[...new Set(p.scopes)]:[];
     if(requested.some(s=>!Object.hasOwn(scopes,s))||!['ENABLED','DISABLED'].includes(p.status))fail('VALIDATION_ERROR','请选择有效的门户权限范围与启用状态');
     if((d.roles||[]).some(role=>role.roleCode===p.roleCode.trim()&&role.id!==p.id))fail('VALIDATION_ERROR','角色编码已存在');
     if(p.id==='ROLE_SUPER'&&(!requested.includes('super')||p.status==='DISABLED'))fail('INVALID_TRANSITION','门户超级管理员角色必须保持启用并保留超级管理权限');
     const x=p.id?requireRow(d.roles,p.id,p.version):{id:id(),version:0,createdAt:now,builtIn:false};
     Object.assign(x,{roleName:p.roleName.trim(),roleCode:p.roleCode.trim(),description:p.description||'',scopes:requested,status:p.status});stamp(x);if(!p.id)d.roles.push(x);
     (d.users||[]).forEach(user=>{if((user.roleIds||[]).includes(x.id)){syncUserRoleScopes(d,user);stamp(user);}});
     const current=(d.users||[]).find(user=>user.id===a.id);if(current&&!current.scopes.includes('super'))fail('INVALID_TRANSITION','本次角色修改会移除当前账号超级管理权限，请先调整用户角色');
     result=x;
    }else if(action==='discoverApplicationAccountCandidates'){
     const app=requireRow(d.apps,p.appId);if(app.status!=='ENABLED')fail('INVALID_TRANSITION','应用已停用，暂不能关联');
     if(app.userType!=='BOTH'&&app.userType!==a.userType)fail('FORBIDDEN','应用不适用于当前身份');
     if(app.accessMode==='REQUEST'&&!grantFor(d,a,app.id))fail('APPLICATION_GRANT_REQUIRED','请先完成应用访问申请');
     const requiresBinding=appRequiresBinding(app);if(!requiresBinding)fail('INVALID_TRANSITION','该应用无需账号关联');
     const existing=d.mappings.find(m=>m.userId===a.id&&m.appId===app.id&&m.status==='BOUND');if(existing)return {state:'BOUND',candidates:[],mapping:existing};
     const scenario=app.mockScenario||'BOUND_EXISTING';
     const openingCompleted=(d.accountOpeningRequests||[]).some(x=>x.userId===a.id&&x.appId===app.id&&x.status==='COMPLETED');
     if(scenario==='NO_ACCOUNT'&&!openingCompleted)return {state:'NO_ACCOUNT',candidates:[],accountOpeningMode:app.accountOpeningMode||'REQUEST',message:'未找到与当前身份匹配的有效子系统账号'};
     const effectiveScenario=scenario==='NO_ACCOUNT'&&openingCompleted?'OTP_BIND':scenario;
     const account=p.externalAccount?.trim()||(effectiveScenario==='CREDENTIAL_BIND'?'demo01':effectiveScenario==='CONFLICT'?'conflict01':openingCompleted?'opened_'+a.account:a.account+'_'+String(app.sourceNo).padStart(2,'0'));
     const candidate={externalUserId:'DEMO_SUBJECT_'+a.id+'_'+app.sourceNo,externalAccount:account,name:a.name,maskedPhone:'138****1234',orgName:a.orgName,
      accountStatus:effectiveScenario==='ACCOUNT_DISABLED'?'DISABLED':'ACTIVE',highPrivilege:effectiveScenario==='REVIEW_BIND',conflict:effectiveScenario==='CONFLICT',
      verificationMethods:effectiveScenario==='AUTO_BIND'?['TRUSTED_ID']:effectiveScenario==='CREDENTIAL_BIND'?['SUBSYSTEM_CREDENTIAL']:['SUBSYSTEM_OTP','UPSTREAM_REAUTH']};
     return {state:candidate.accountStatus==='DISABLED'?'ACCOUNT_DISABLED':candidate.conflict?'CONFLICT':'CANDIDATE_FOUND',candidates:[candidate],accountOpeningMode:app.accountOpeningMode||'NONE'};
    }else if(action==='startApplicationAccountBinding'){
     const app=requireRow(d.apps,p.appId);if(app.mockScenario!=='AUTO_BIND')fail('INVALID_TRANSITION','该应用不支持可信标识自动关联');
     if(!p.externalAccount?.trim())fail('VALIDATION_ERROR','缺少候选账号');
     result=ensureMapping(app,p.externalAccount.trim(),{status:'BOUND',bindingMethod:'AUTO',matchMethod:'TRUSTED_ID',verificationMethod:'TRUSTED_ID',verificationStatus:'PASSED',externalAccountStatus:'ACTIVE',riskLevel:'NORMAL',verifiedAt:now,boundAt:now,conflictReason:null});
    }else if(action==='sendSubsystemBindingOtp'){
     const app=requireRow(d.apps,p.appId);if(!p.externalAccount?.trim())fail('VALIDATION_ERROR','缺少候选账号');
     if(app.mockScenario==='ACCOUNT_DISABLED')fail('ACCOUNT_DISABLED','子系统账号已停用，请联系目标系统管理员');
     ensureMapping(app,p.externalAccount.trim(),{status:'VERIFYING',bindingMethod:app.accountBindingMode||'SELF',matchMethod:'NAME_PHONE',verificationMethod:'SUBSYSTEM_OTP',verificationStatus:'PENDING',externalAccountStatus:'ACTIVE',riskLevel:app.mockScenario==='REVIEW_BIND'?'HIGH':'NORMAL',verifiedAt:null,boundAt:null,conflictReason:null});
     result={maskedPhone:'138****1234',demoCode:'123456',expiresIn:60,message:'演示环境未发送真实短信，请使用验证码123456'};
    }else if(action==='verifyBindingOtp'){
     const app=requireRow(d.apps,p.appId);if(String(p.code||'')!=='123456')fail('OTP_INVALID','验证码错误，演示环境请输入123456');
     if(!p.externalAccount?.trim())fail('VALIDATION_ERROR','缺少候选账号');
     const status=app.mockScenario==='REVIEW_BIND'?'REVIEWING':app.mockScenario==='CONFLICT'?'CONFLICT':'BOUND';
     result=ensureMapping(app,p.externalAccount.trim(),{status,bindingMethod:app.accountBindingMode||'SELF',matchMethod:'NAME_PHONE',verificationMethod:'SUBSYSTEM_OTP',verificationStatus:'PASSED',externalAccountStatus:'ACTIVE',
      riskLevel:app.mockScenario==='REVIEW_BIND'?'HIGH':'NORMAL',verifiedAt:now,boundAt:status==='BOUND'?now:null,conflictReason:status==='CONFLICT'?'该账号已绑定其他统一用户，需管理员处理':null});
    }else if(action==='verifyBindingBySubsystemCredential'){
     const app=requireRow(d.apps,p.appId);if(app.mockScenario!=='CREDENTIAL_BIND')fail('INVALID_TRANSITION','该应用未配置原系统账号验证');
     if(p.externalAccount!=='demo01'||p.password!=='123456')fail('INVALID_CREDENTIALS','原系统账号或密码验证失败，演示账号为 demo01 / 123456');
     result=ensureMapping(app,p.externalAccount,{status:'BOUND',bindingMethod:'SELF',matchMethod:'ACCOUNT',verificationMethod:'SUBSYSTEM_CREDENTIAL',verificationStatus:'PASSED',externalAccountStatus:'ACTIVE',riskLevel:'NORMAL',verifiedAt:now,boundAt:now,conflictReason:null});
    }else if(action==='verifyBindingByUpstreamReauth'){
     const app=requireRow(d.apps,p.appId);if(!p.externalAccount?.trim())fail('VALIDATION_ERROR','缺少候选账号');
     const status=app.mockScenario==='REVIEW_BIND'?'REVIEWING':'BOUND';
     result=ensureMapping(app,p.externalAccount.trim(),{status,bindingMethod:app.accountBindingMode||'SELF',matchMethod:'NAME_PHONE',verificationMethod:'UPSTREAM_REAUTH',verificationStatus:'PASSED',externalAccountStatus:'ACTIVE',riskLevel:status==='REVIEWING'?'HIGH':'NORMAL',verifiedAt:now,boundAt:status==='BOUND'?now:null,conflictReason:null});
    }else if(action==='submitAccountOpeningRequest'){
     const app=requireRow(d.apps,p.appId);if(app.accountOpeningMode!=='REQUEST')fail('INVALID_TRANSITION','该应用未开放门户账号开通申请入口');
     d.accountOpeningRequests??=[];if(d.accountOpeningRequests.some(x=>x.userId===a.id&&x.appId===app.id&&['PENDING','PROCESSING'].includes(x.status)))fail('DUPLICATE_ACCOUNT_OPENING_REQUEST','已有账号开通申请正在处理中');
     if(!p.reason?.trim())fail('VALIDATION_ERROR','请填写开通申请原因');
     const seq=String(d.accountOpeningRequests.length+1).padStart(5,'0'),day=now.slice(0,10).replaceAll('-','');
     const x={id:id(),version:1,createdAt:now,updatedAt:now,requestNo:'OPEN-'+day+'-'+seq,userId:a.id,userName:a.name,appId:app.id,appName:app.name,reason:p.reason.trim(),
      contact:p.contact?.trim()||'',remark:p.remark?.trim()||'',status:'PENDING',submittedAt:now,handledBy:null,handledAt:null,handleNote:null};
     d.accountOpeningRequests.push(x);result=x;
    }else if(action==='completeMockAccountOpeningRequest'){
     const x=requireRow(d.accountOpeningRequests||[],p.id,p.version);if(!['PENDING','PROCESSING'].includes(x.status))fail('INVALID_TRANSITION','当前开通申请已结束');
     x.status='COMPLETED';x.handledBy=a.id;x.handledAt=now;x.handleNote=p.handleNote?.trim()||'Mock演示：子系统账号已开通，可返回用户端继续关联';result=stamp(x);
    }else if(action==='approveBindingReview'||action==='rejectBindingReview'){
     const x=requireRow(d.mappings,p.id,p.version);if(x.status!=='REVIEWING')fail('INVALID_TRANSITION','仅待审核映射可以处理');
     if(action==='rejectBindingReview'&&!p.reviewNote?.trim())fail('VALIDATION_ERROR','请填写驳回原因');
     x.status=action==='approveBindingReview'?'BOUND':'FAILED';x.reviewedBy=a.id;x.reviewedAt=now;x.reviewNote=p.reviewNote?.trim()||'审核通过';
     if(x.status==='BOUND'){x.boundAt=now;x.conflictReason=null;}else x.conflictReason=x.reviewNote;result=stamp(x);
    }else if(action==='submitApplicationRequest'){
     const app=requireRow(d.apps,p.appId);if(app.status!=='ENABLED')fail('INVALID_TRANSITION','应用已停用，暂不能申请');
     if(app.userType!=='BOTH'&&app.userType!==a.userType)fail('FORBIDDEN','应用不适用于当前身份');
     if(app.accessMode!=='REQUEST')fail('INVALID_TRANSITION','该应用无需提交访问申请');
     if(grantFor(d,a,app.id))fail('INVALID_TRANSITION','当前用户已拥有应用入口资格');
     d.applicationRequests??=[];
     if(d.applicationRequests.some(x=>x.userId===a.id&&x.appId===app.id&&x.status==='PENDING'))fail('DUPLICATE_APPLICATION_REQUEST','已有待审核申请，请勿重复提交');
     if(!p.reason?.trim())fail('VALIDATION_ERROR','请填写申请原因');
     const seq=String(d.applicationRequests.length+1).padStart(5,'0'),day=now.slice(0,10).replaceAll('-','');
     const x={id:id(),version:1,createdAt:now,updatedAt:now,requestNo:'REQ-'+day+'-'+seq,userId:a.id,userName:a.name,appId:app.id,appName:app.name,
      reason:p.reason.trim(),contact:p.contact?.trim()||'',remark:p.remark?.trim()||'',status:'PENDING',submittedAt:now,reviewedBy:null,reviewedAt:null,reviewNote:null};
     d.applicationRequests.push(x);result=x;
    }else if(action==='withdrawApplicationRequest'){
     const x=requireRow(d.applicationRequests||[],p.id,p.version);if(!own(x,a))fail('NOT_FOUND','申请不存在');if(x.status!=='PENDING')fail('INVALID_TRANSITION','仅待审核申请可以撤回');
     x.status='WITHDRAWN';x.withdrawnAt=now;result=stamp(x);
    }else if(action==='approveApplicationRequest'||action==='rejectApplicationRequest'){
     const x=requireRow(d.applicationRequests||[],p.id,p.version);if(x.status!=='PENDING')fail('INVALID_TRANSITION','仅待审核申请可以处理');
     if(action==='rejectApplicationRequest'&&!p.reviewNote?.trim())fail('VALIDATION_ERROR','请填写驳回原因');
     x.status=action==='approveApplicationRequest'?'APPROVED':'REJECTED';x.reviewedBy=a.id;x.reviewedAt=now;x.reviewNote=p.reviewNote?.trim()||'审核通过';stamp(x);
     if(action==='approveApplicationRequest'){
      d.applicationGrants??=[];
      let grant=d.applicationGrants.find(g=>g.userId===x.userId&&g.appId===x.appId&&g.status==='ACTIVE');
      if(!grant){grant={id:id(),version:1,createdAt:now,updatedAt:now,userId:x.userId,appId:x.appId,status:'ACTIVE',grantedBy:a.id,grantedAt:now,expiresAt:null};d.applicationGrants.push(grant);}
     }
     result=x;
    }else if(action==='markAnnouncementRead'){
     const x=requireRow(d.announcements,p.id);if(!visible(x,a))fail('NOT_FOUND','公告不存在或不在可见范围');
     d.announcementReads??=[];let receipt=d.announcementReads.find(r=>r.announcementId===x.id&&own(r,a));
     if(!receipt){receipt={announcementId:x.id,userId:a.id,readAt:now};d.announcementReads.push(receipt);}result=receipt;
    }else if(action==='saveApp'){
     if(!p.name?.trim()||!p.code?.trim())fail('VALIDATION_ERROR','应用名称与编码为必填');checkUrl(p.url);
     if(!['CITIZEN','GOV','BOTH'].includes(p.userType))fail('VALIDATION_ERROR','请选择适用用户类型');
     if(!['DIRECT','BIND','REQUEST'].includes(p.accessMode))fail('VALIDATION_ERROR','请选择有效访问模式');
     if(p.accessMode==='BIND'&&!['AUTO','SELF','REVIEW','ADMIN'].includes(p.accountBindingMode))fail('VALIDATION_ERROR','请选择有效账号关联方式');
     if(p.accessMode==='REQUEST'&&!['DIRECT','BIND'].includes(p.postGrantMode))fail('VALIDATION_ERROR','请选择申请通过后的访问方式');
     if(p.accessMode==='REQUEST'&&p.postGrantMode==='BIND'&&!['AUTO','SELF','REVIEW','ADMIN'].includes(p.accountBindingMode))fail('VALIDATION_ERROR','请选择有效账号关联方式');
     if(d.apps.some(x=>x.code===p.code.trim()&&x.id!==p.id))fail('VALIDATION_ERROR','应用编码已存在');
     const x=p.id?requireRow(d.apps,p.id,p.version):{id:id(),version:0,createdAt:now,status:'DISABLED',runtimeStatus:'UNCONFIGURED'};
     Object.assign(x,{name:p.name.trim(),code:p.code.trim(),category:p.category||'未分类',description:p.description||'',url:p.url,userType:p.userType,
      accessMode:p.accessMode,postGrantMode:p.accessMode==='REQUEST'?p.postGrantMode:'DIRECT',accountBindingMode:p.accessMode==='DIRECT'?'NONE':p.accountBindingMode,
      accountOpeningMode:p.accountOpeningMode||'NONE',sortOrder:Number(p.sortOrder)||0});stamp(x);if(!p.id)d.apps.push(x);result=x;
    }else if(action==='setAppStatus'){const x=requireRow(d.apps,p.id,p.version);if(!['ENABLED','DISABLED'].includes(p.status))fail('VALIDATION_ERROR','启用状态无效');x.status=p.status;result=stamp(x);
    }else if(action==='saveCategory'){
     if(!p.name?.trim()||!p.code?.trim())fail('VALIDATION_ERROR','名称与编码为必填');if(d.categories.some(x=>(x.code===p.code||x.name===p.name)&&x.id!==p.id))fail('VALIDATION_ERROR','分类名称或编码重复');
     const x=p.id?requireRow(d.categories,p.id,p.version):{id:id(),version:0,createdAt:now};const oldName=x.name;Object.assign(x,{name:p.name.trim(),code:p.code.trim(),status:'ENABLED',sortOrder:Number(p.sortOrder)||0});stamp(x);if(!p.id)d.categories.push(x);if(oldName&&oldName!==x.name)d.apps.filter(app=>app.category===oldName).forEach(app=>{app.category=x.name;stamp(app);});result=x;
    }else if(action==='removeCategory'){const x=requireRow(d.categories,p.id,p.version);if(d.apps.some(app=>app.category===x.name))fail('INVALID_TRANSITION','分类仍被应用使用，不能删除');d.categories=d.categories.filter(x=>x.id!==p.id);result={id:p.id};
    }else if(action==='markRead'){const x=requireRow(d.messages,p.id);if(!own(x,a))fail('NOT_FOUND','消息不存在');if(x.status==='UNREAD'){x.status='READ';x.readAt=now;stamp(x);}result=x;
    }else if(action==='markMessagesRead'){
     const ids=[...new Set(Array.isArray(p.ids)?p.ids:[])];if(!ids.length)fail('VALIDATION_ERROR','请选择需要标记的消息');
     const targets=ids.map(id=>requireRow(d.messages,id));if(targets.some(x=>!own(x,a)))fail('NOT_FOUND','消息不存在');let count=0;for(const x of targets)if(x.status==='UNREAD'){x.status='READ';x.readAt=now;stamp(x);count++;}result={count};
    }else if(action==='markAllMessagesRead'){
     let count=0;for(const x of d.messages.filter(x=>own(x,a)&&x.status==='UNREAD')){x.status='READ';x.readAt=now;stamp(x);count++;}result={count};
    }else if(action==='deleteMessages'){
     const ids=[...new Set(Array.isArray(p.ids)?p.ids:[])];if(!ids.length)fail('VALIDATION_ERROR','请选择需要删除的消息');
     const targets=ids.map(id=>requireRow(d.messages,id));if(targets.some(x=>!own(x,a)))fail('NOT_FOUND','消息不存在');const selected=new Set(ids);d.messageTrash??=[];d.messageTrash.push(...targets.map(x=>({...x,deletedAt:now,deletedBy:a.id})));d.messages=d.messages.filter(x=>!selected.has(x.id));result={count:ids.length};
    }else if(action==='enterApp'){
     const app=requireRow(d.apps,p.id);if(app.status!=='ENABLED')fail('INVALID_TRANSITION','应用已停用');if(app.runtimeStatus!=='NORMAL')fail('UPSTREAM_UNAVAILABLE','应用接入异常或未配置');
     if(app.userType!=='BOTH'&&app.userType!==a.userType)fail('FORBIDDEN','应用不适用于当前身份');
     if(app.accessMode==='REQUEST'&&!grantFor(d,a,app.id))fail('APPLICATION_GRANT_REQUIRED','请先提交应用访问申请并等待审核通过');
     const requiresBinding=appRequiresBinding(app);
     if(requiresBinding&&!d.mappings.some(x=>x.appId===app.id&&own(x,a)&&x.status==='BOUND'))fail('ACCOUNT_BINDING_REQUIRED','请先完成子系统账号关联');
     checkUrl(app.url);d.visits.push({userId:a.id,appId:app.id,at:now});result={url:app.url,mode:'MOCK',message:'Mock访问校验已通过。当前未连接真实子系统，正式SSO将在联调阶段接入。'};
    }else if(action==='openTodo'){
     const todo=requireRow(d.todos,p.id);if(!own(todo,a))fail('NOT_FOUND','待办不存在');if(todo.status!=='PENDING')fail('INVALID_TRANSITION','该待办已终结');
     const app=requireRow(d.apps,todo.appId);if(app.status!=='ENABLED')fail('INVALID_TRANSITION','应用已停用');if(app.runtimeStatus!=='NORMAL')fail('UPSTREAM_UNAVAILABLE','应用接入异常或未配置');
     if(app.accessMode==='REQUEST'&&!grantFor(d,a,app.id))fail('APPLICATION_GRANT_REQUIRED','当前用户尚未获得该应用入口资格');
     if(appRequiresBinding(app)&&!d.mappings.some(x=>x.appId===app.id&&own(x,a)&&x.status==='BOUND'))fail('IDENTITY_UNRESOLVED','接收用户尚未关联该子系统');
     checkUrl(app.url);d.visits.push({userId:a.id,appId:app.id,at:now});result={url:app.url,mode:'MOCK',message:'Mock待办跳转校验已通过。真实子系统连接尚未开放。'};
    }else if(action==='bind'){
     const app=requireRow(d.apps,p.appId);if(app.status!=='ENABLED')fail('INVALID_TRANSITION','应用已停用，暂不能关联');if(app.userType!=='BOTH'&&app.userType!==a.userType)fail('FORBIDDEN','应用不适用于当前身份');if(!p.externalAccount?.trim())fail('VALIDATION_ERROR','请输入已有子系统账号');
     let x=d.mappings.find(m=>m.userId===a.id&&m.appId===p.appId);if(x?.status==='BOUND')fail('INVALID_TRANSITION','已有关联，请由具备身份映射权限的管理员处理');
     const collision=d.mappings.some(m=>m.appId===p.appId&&m.externalAccount===p.externalAccount.trim()&&m.userId!==a.id&&m.status==='BOUND');
     if(!x){x={id:id(),version:0,createdAt:now,userId:a.id,appId:p.appId,appName:app.name};d.mappings.push(x);}x.externalAccount=p.externalAccount.trim();x.status=collision?'CONFLICT':(p.outcome||'BOUND');if(!['BOUND','FAILED','CONFLICT'].includes(x.status))fail('VALIDATION_ERROR','账号核验结果无效');result=stamp(x);
    }else if(action==='unbind'){const x=requireRow(d.mappings,p.id,p.version);if(x.status!=='BOUND')fail('INVALID_TRANSITION','仅已关联记录可解绑');x.status='UNBOUND';result=stamp(x);
    }else if(action==='resolveMapping'){const x=requireRow(d.mappings,p.id,p.version);if(x.status!=='CONFLICT')fail('INVALID_TRANSITION','仅冲突记录可确认');if(!p.reason?.trim())fail('VALIDATION_ERROR','请输入核验证据说明');if(d.mappings.some(m=>m.id!==x.id&&m.appId===x.appId&&m.externalAccount===x.externalAccount&&m.status==='BOUND'))fail('INVALID_TRANSITION','外部账号仍被其他身份占用');x.status='BOUND';result=stamp(x);
    }else if(action==='saveAnnouncement'){
     if(!p.title?.trim()||!p.content?.trim())fail('VALIDATION_ERROR','标题和正文不能为空');if(!['ALL','CITIZEN','GOV'].includes(p.scope))fail('VALIDATION_ERROR','组织范围需真实组织键，当前暂不可选择');
     if(p.effectiveEnd&&Date.parse(p.effectiveEnd)<=Date.parse(p.effectiveStart||now))fail('VALIDATION_ERROR','结束时间必须晚于开始时间');
     const x=p.id?requireRow(d.announcements,p.id,p.version):{id:id(),version:0,createdAt:now,status:'DRAFT',publishedAt:null};if(x.status!=='DRAFT')fail('INVALID_TRANSITION','仅草稿可编辑');
     Object.assign(x,{title:p.title.trim(),content:p.content.trim(),type:p.type||'通知',scope:p.scope,effectiveStart:p.effectiveStart||null,effectiveEnd:p.effectiveEnd||null,attachments:p.attachments||[]});stamp(x);if(!p.id)d.announcements.push(x);result=x;
    }else if(action==='publish'||action==='withdraw'){
     const x=requireRow(d.announcements,p.id,p.version);const from=action==='publish'?'DRAFT':'PUBLISHED';if(x.status!==from)fail('INVALID_TRANSITION','当前状态不允许此操作');
     if(action==='publish'&&x.effectiveEnd&&Date.parse(x.effectiveEnd)<=Date.now())fail('VALIDATION_ERROR','公告有效期已结束');x.status=action==='publish'?'PUBLISHED':'WITHDRAWN';if(action==='publish'){x.publishedAt=now;x.publisherId=a.id;}result=stamp(x);
    }else if(action==='saveConfig'){const x=requireRow(d.settings,p.id,p.version);if(!Number.isSafeInteger(Number(p.value))||Number(p.value)<=0)fail('VALIDATION_ERROR','请输入正整数，未配置值不视为零');x.value=Number(p.value);x.status='CONFIGURED';result=stamp(x);
    }else if(action==='createAccessProfile'){
     const app=requireRow(d.apps,p.appId);
     d.integrations??=[];
     for(const kind of ['SSO','TODO','MESSAGE'].filter(kind=>!d.integrations.some(x=>x.appId===app.id&&x.kind===kind)))d.integrations.push({id:id(),version:1,createdAt:now,updatedAt:now,appId:app.id,appName:app.name,name:app.name+' · '+kind,kind,mode:kind==='SSO'?'SSO':'PUSH',enabled:'DISABLED',status:'UNCONFIGURED',connectionStatus:'UNCONFIGURED',remark:'尚未配置'});
     result=accessProfiles(d).find(item=>item.appId===app.id);
    }else if(action==='saveIntegration'){
     const x=requireRow(d.integrations,p.id,p.version);
     if(!['ENABLED','DISABLED'].includes(p.enabled))fail('VALIDATION_ERROR','请选择接入启用状态');
     if(x.kind==='SSO'){
      if(!['OIDC','SAML2','CUSTOM'].includes(p.protocol))fail('VALIDATION_ERROR','请选择SSO协议');
      for(const key of ['authorizeUrl','tokenUrl','callbackUrl'])if(p[key])checkUrl(p[key]);
      if(p.enabled==='ENABLED'&&(!p.clientId?.trim()||!p.authorizeUrl||!p.callbackUrl))fail('VALIDATION_ERROR','启用SSO需填写Client ID、授权地址及回调地址');
     }else if(p.mode!=='PUSH')fail('VALIDATION_ERROR','待办与消息仅支持PUSH接入');
     if(p.credentialRef&&!/^PORTAL_[A-Z0-9_]{1,80}$/.test(p.credentialRef))fail('VALIDATION_ERROR','凭据引用须为PORTAL_开头的服务端环境变量名，不能填写密钥');
     if(p.enabled==='ENABLED'&&x.kind!=='SSO'&&!p.credentialRef)fail('VALIDATION_ERROR','启用接入需配置服务端凭据引用');
     let mapping;try{mapping=typeof p.fieldMapping==='string'?JSON.parse(p.fieldMapping||'{}'):p.fieldMapping||{};}catch{fail('VALIDATION_ERROR','字段映射必须为JSON对象');}
     if(!mapping||Array.isArray(mapping)||typeof mapping!=='object'||Object.entries(mapping).some(([k,v])=>!['userId','title','content','sourceTodoId','sourceMessageId','eventId','sourceRevision','status'].includes(k)||typeof v!=='string'||!/^\w+$/.test(v)||['__proto__','constructor','prototype'].includes(v)))fail('VALIDATION_ERROR','字段映射只支持协议字段到来源字段名称');
     const allowed=integrationFields[x.kind]||[];
     if(x.kind!=='SSO'&&Object.keys(mapping).some(key=>!allowed.includes(key)))fail('VALIDATION_ERROR','字段不属于当前接入类型');
     if(new Set(allowed.map(key=>mapping[key]||key)).size!==allowed.length)fail('VALIDATION_ERROR','不同标准字段不能映射到同一来源字段');
     let valueMapping;try{valueMapping=typeof p.valueMapping==='string'?JSON.parse(p.valueMapping||'{}'):p.valueMapping||{};}catch{fail('VALIDATION_ERROR','状态映射必须为JSON对象');}
     if(!valueMapping||Array.isArray(valueMapping)||typeof valueMapping!=='object'||Object.keys(valueMapping).some(key=>key!=='status')||(valueMapping.status&&(x.kind!=='TODO'||Array.isArray(valueMapping.status)||typeof valueMapping.status!=='object'||Object.values(valueMapping.status).some(v=>!terminalStatuses.includes(v)))))fail('VALIDATION_ERROR','只支持TODO状态映射到标准待办状态');
     if(x.kind==='SSO'&&p.enabled==='ENABLED'&&p.protocol==='OIDC'&&!p.tokenUrl)fail('VALIDATION_ERROR','OIDC启用时需填写令牌地址');
     const selected={valueMapping,targetKeyKind:'UNIFIED_USER_ID',enabled:p.enabled,protocol:p.protocol||'PUSH',mode:x.kind==='SSO'?'SSO':'PUSH',credentialRef:p.credentialRef||'',clientId:p.clientId||'',authorizeUrl:p.authorizeUrl||'',tokenUrl:p.tokenUrl||'',callbackUrl:p.callbackUrl||'',fieldMapping:mapping,remark:p.remark||''};
     Object.assign(x,selected,{status:p.enabled==='DISABLED'?'DISABLED':'UNCONFIGURED',configurationStatus:'CONFIGURED',connectionStatus:'UNCONFIGURED'});result=stamp(x);
    }else if(action==='pushTodo'){
     const targetApp=requireRow(d.apps,p.appId);if(!(d.users||actors).some(x=>x.id===p.userId))fail('IDENTITY_UNRESOLVED','接收身份无法解析');if(!p.sourceTodoId?.trim()||!p.eventId?.trim()||!p.title?.trim()||!Number.isSafeInteger(p.sourceRevision)||p.sourceRevision<1)fail('VALIDATION_ERROR','事件ID、源事项ID、标题及正整数版本必填');
     const payload=canonical(Object.fromEntries(['appId',...integrationFields.TODO].map(key=>[key,p[key]]))),receipt=d.receipts.find(x=>x.appId===p.appId&&x.eventId===p.eventId&&(x.kind||'TODO')==='TODO');if(receipt){if(canonical(JSON.parse(receipt.payload))!==canonical(JSON.parse(payload)))fail('IDEMPOTENCY_CONFLICT','相同事件ID载荷不同');return receipt.result;}
     if(appRequiresBinding(targetApp)&&!d.mappings.some(m=>m.appId===p.appId&&m.userId===p.userId&&m.status==='BOUND'))fail('IDENTITY_UNRESOLVED','接收用户尚未关联该子系统');
     let x=d.todos.find(x=>x.appId===p.appId&&x.sourceTodoId===p.sourceTodoId);if(x){if(x.userId!==p.userId)fail('INVALID_TRANSITION','不能变更接收人');if(p.sourceRevision<=x.sourceRevision)fail('STALE_EVENT','事件版本未递增');if(x.status!=='PENDING'||!['COMPLETED','WITHDRAWN','EXPIRED'].includes(p.status))fail('INVALID_TRANSITION','不允许终态回退或非法迁移');x.status=p.status;x.sourceRevision=p.sourceRevision;stamp(x);}else{if(p.status!=='PENDING')fail('INVALID_TRANSITION','首次推送须为待处理');const app=requireRow(d.apps,p.appId);x={id:id(),version:1,createdAt:now,updatedAt:now,...p,appName:app.name,summary:'来源系统推送',priority:'MEDIUM',url:app.url};d.todos.push(x);}result={entityId:x.id,disposition:'APPLIED',sourceRevision:x.sourceRevision};d.receipts.push({kind:'TODO',appId:p.appId,eventId:p.eventId,payload,result});
    }else if(action==='pushMessage'){
     const app=requireRow(d.apps,p.appId);if(!(d.users||actors).some(x=>x.id===p.userId))fail('IDENTITY_UNRESOLVED','接收身份无法解析');
     if(!p.sourceMessageId?.trim()||!p.eventId?.trim()||!p.title?.trim()||!p.content?.trim())fail('VALIDATION_ERROR','源消息ID、事件ID、消息标题及内容必填');
     const payload=canonical({appId:p.appId,userId:p.userId,sourceMessageId:p.sourceMessageId,eventId:p.eventId,title:p.title,content:p.content});
     const receipt=d.receipts.find(x=>x.appId===p.appId&&x.eventId===p.eventId&&(x.kind||'MESSAGE')==='MESSAGE');
     if(receipt){if(canonical(JSON.parse(receipt.payload))!==canonical(JSON.parse(payload)))fail('IDEMPOTENCY_CONFLICT','相同事件ID载荷不同');return receipt.result;}
     if(appRequiresBinding(app)&&!d.mappings.some(m=>m.appId===p.appId&&m.userId===p.userId&&m.status==='BOUND'))fail('IDENTITY_UNRESOLVED','接收用户尚未关联该子系统');
     const existing=d.messages.find(x=>x.appId===p.appId&&x.sourceMessageId===p.sourceMessageId&&x.userId===p.userId);
     if(existing)fail('IDEMPOTENCY_CONFLICT','该来源消息已存在，请用原事件ID重试');
     const x={id:id(),version:1,createdAt:now,updatedAt:now,appId:p.appId,sourceMessageId:p.sourceMessageId,userId:p.userId,title:p.title.trim(),content:p.content.trim(),appName:app.name,sourceKind:'APPLICATION',status:'UNREAD',readAt:null};d.messages.push(x);result={entityId:x.id,disposition:'APPLIED'};d.receipts.push({appId:p.appId,eventId:p.eventId,payload,result});
    }else fail('CAPABILITY_UNAVAILABLE','该动作尚未开放');
    const actionNames={createLocalPortalUser:'新建门户本地用户',setPortalUserStatus:'变更用户启用状态',resetLocalPassword:'重置本地用户密码',unlockLocalUser:'解除本地用户锁定',savePortalUser:'维护系统用户',saveOrganization:'维护组织',removeOrganization:'删除组织',saveDictionaryType:'维护字典类型',saveDictionaryItem:'维护字典项',saveSystemRole:'维护系统角色',markAnnouncementRead:'阅读公告',saveApp:'维护应用信息',setAppStatus:'变更应用启用状态',saveCategory:'维护系统分类',removeCategory:'删除分类',markRead:'阅读消息',markMessagesRead:'批量阅读消息',markAllMessagesRead:'全部消息已读',deleteMessages:'删除消息',enterApp:'访问应用',openTodo:'打开待办',discoverApplicationAccountCandidates:'查找子系统候选账号',startApplicationAccountBinding:'自动关联子系统账号',sendSubsystemBindingOtp:'发送账号关联验证码',verifyBindingOtp:'验证账号关联验证码',verifyBindingBySubsystemCredential:'验证原系统账号',verifyBindingByUpstreamReauth:'重新认证身份',submitAccountOpeningRequest:'提交子系统账号开通申请',completeMockAccountOpeningRequest:'完成Mock账号开通申请',approveBindingReview:'通过账号关联审核',rejectBindingReview:'驳回账号关联审核',submitApplicationRequest:'提交应用访问申请',withdrawApplicationRequest:'撤回应用访问申请',approveApplicationRequest:'通过应用访问申请',rejectApplicationRequest:'驳回应用访问申请',bind:'关联子系统账号',unbind:'解除账号关联',resolveMapping:'处理映射冲突',saveAnnouncement:'保存公告',publish:'发布公告',withdraw:'撤回公告',saveConfig:'维护参数',createAccessProfile:'新增应用接入',saveIntegration:'维护接入配置',pushTodo:'接收待办',pushMessage:'接收消息'};
    d.logs.unshift({id:id(),name:actionNames[action]||action,kind:['enterApp','openTodo'].includes(action)?'access':action.startsWith('push')?'api':'operation',actor:a.name,status:'SUCCESS',createdAt:now,description:p.reason||'操作已记录'});return result;
   });
  })
 };
}
