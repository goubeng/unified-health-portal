// V20260921-01 frontend authorization contract.
// resource:action permissions are authoritative. "scopes" is retained only as a temporary
// compatibility vocabulary for older Mock records/actions and must not be persisted by the target API.
export const rolePermissionGroups=[
 {key:'application',menu:'应用管理',description:'应用目录、入口资格与接入配置',pages:[
  {name:'应用列表',actions:[['application:view','查看'],['application:edit','新增/编辑'],['application:enable','启停']]},
  {name:'应用访问申请',actions:[['application:review','审核申请']]},
  {name:'接入配置',actions:[['integration:view','查看'],['integration:edit','维护'],['integration:test','连接检测']]}
 ]},
 {key:'identity',menu:'身份与子系统映射',description:'账号映射、审核与冲突处理',pages:[
  {name:'身份与子系统映射',actions:[['identity:view','查看'],['identity:review','审核/处理'],['identity:unbind','解绑']]}
 ]},
 {key:'announcement',menu:'工作台',description:'门户通知公告维护',pages:[
  {name:'通知公告管理',actions:[['announcement:view','查看'],['announcement:edit','新增/编辑'],['announcement:publish','发布/撤回']]}
 ]},
 {key:'system',menu:'系统管理',description:'管理用户、组织与字典维护',pages:[
  {name:'用户管理',actions:[['admin-user:view','查看'],['admin-user:enable','启停']]},
  {name:'组织管理',actions:[['organization:view','查看'],['organization:edit','维护']]},
  {name:'字典管理',actions:[['dictionary:view','查看'],['dictionary:edit','维护']]}
 ]},
 {key:'monitor',menu:'运行监控',description:'SSO / TODO / MESSAGE 接入运行',pages:[
  {name:'运行监控',actions:[['monitor:view','查看'],['monitor:check','重新检测']]}
 ]},
 {key:'audit',menu:'日志审计',description:'登录、访问、操作、接口与异常日志',pages:[
  {name:'日志审计',actions:[['audit:view','查看'],['audit:resolve','异常处理']]}
 ]},
 {key:'super',menu:'超级管理',description:'高风险门户能力，仅超级管理员',pages:[
  {name:'角色管理',actions:[['role:view','查看'],['role:edit','新增/权限配置']]},
  {name:'管理员授权',actions:[['admin-user:create','新增管理账号'],['admin-user:assign-role','角色授权'],['admin-user:reset-password','重置/解锁本地账号']]},
  {name:'关键配置',actions:[['settings:view','查看'],['settings:edit','维护'],['system:super','超级管理']]}
 ]}
];

export const permissions=Object.fromEntries(
 rolePermissionGroups.flatMap(group=>group.pages.flatMap(page=>page.actions.map(([code,label])=>[code,`${page.name}：${label}`])))
);

// Deprecated compatibility labels. New UI/DTO code should use "permissions".
export const scopes={super:'超级管理权限',system:'系统管理权限',application:'应用管理权限',integration:'集成管理权限',announcement:'公告管理权限',audit:'审计权限',identity:'身份映射权限'};
export const legacyScopePermissions={
 super:['system:super'],
 system:['admin-user:view','organization:view','dictionary:view'],
 application:['application:view'],
 integration:['integration:view','monitor:view'],
 announcement:['announcement:view'],
 audit:['audit:view'],
 identity:['identity:view']
};
export const permissionsFromScopes=input=>[...new Set((input||[]).flatMap(scope=>legacyScopePermissions[scope]||[]))];
export const scopesFromPermissions=input=>Object.keys(legacyScopePermissions).filter(scope=>legacyScopePermissions[scope].some(code=>(input||[]).includes(code)));

const p=(id,path,title,group,resource,permission=null)=>({id,path,title,group,resource,permission,scope:permission});
export const pages=[
 p('PG-001','/login','统一登录','登录','login'),p('PG-002','/auth/result','认证结果','登录','auth'),
 p('PG-101','/portal/home','首页','个人事务','home'),{...p('PG-102','/portal/apps/mine','应用中心','应用中心','mine'),hidden:true},p('PG-103','/portal/apps/all','应用中心','应用中心','apps'),
 p('PG-104','/portal/todos','待办任务','个人事务','todos'),p('PG-109','/portal/applications','我的申请','个人事务','myApplicationRequests'),p('PG-105','/portal/messages','我的消息','个人事务','messages'),p('PG-106','/portal/announcements','通知公告','个人事务','announcements'),p('PG-107','/portal/announcements/:id','公告详情','个人事务','announcementDetail'),p('PG-108','/portal/profile','个人中心','个人事务','profile'),

 p('PG-201','/admin/home','管理首页','工作台','adminHome','any'),
 p('PG-220','/admin/announcements','通知公告管理','工作台','announcements','announcement:view'),p('PG-235','/admin/announcements/:id','公告详情','工作台','announcementDetail','announcement:view'),
 p('PG-202','/admin/apps','应用列表','应用管理','apps','application:view'),p('PG-231','/admin/application-requests','应用访问申请','应用管理','applicationRequests','application:review'),p('PG-234','/admin/account-opening-requests','子系统账号开通申请','应用管理','accountOpeningRequests','application:review'),{...p('PG-203','/admin/app-categories','系统分类','应用管理','categories','application:view'),hidden:true},

 p('PG-228','/admin/users','用户管理','系统管理','users','admin-user:view'),p('PG-209','/admin/roles','角色管理','系统管理','roles','role:view'),{...p('PG-210','/admin/permissions','门户权限配置','系统管理','permissions','role:view'),hidden:true},p('PG-229','/admin/organizations','组织管理','系统管理','organizations','organization:view'),p('PG-230','/admin/dictionaries','字典管理','系统管理','dictionaries','dictionary:view'),
 p('PG-205','/admin/identities','身份与子系统映射','系统管理','identityOverview','identity:view'),
 ...[['PG-206','/admin/identity-mappings'],['PG-207','/admin/account-mappings'],['PG-208','/admin/mapping-exceptions']].map(([id,path])=>({...p(id,path,'身份与子系统映射','系统管理','identityOverview','identity:view'),hidden:true})),
 p('PG-221','/admin/settings','配置管理','系统管理','settings','settings:view'),p('PG-222','/admin/monitor','运行监控','应用管理','monitor','monitor:view'),
 ...[['223','login','登录/认证日志'],['224','access','应用访问日志'],['225','operation','门户操作日志'],['226','api','接口调用日志'],['227','error','异常日志']].map(([id,kind,title])=>p('PG-'+id,'/admin/logs/'+kind,title,'日志审计','logs:'+kind,'audit:view'))
];

export const labels={ENABLED:'启用',DISABLED:'停用',NORMAL:'正常',ABNORMAL:'异常',UNCONFIGURED:'未配置',CONFIGURED:'已配置',REQUEST_REQUIRED:'未申请',REQUEST_PENDING:'审核中',REQUEST_REJECTED:'已驳回',DIRECT:'直接访问',BIND:'账号关联',REQUEST:'申请使用',NONE:'不开放',NOT_APPLICABLE:'不适用',APP_DISABLED:'应用停用',UNBOUND:'未关联',VERIFYING:'验证中',REVIEWING:'待审核',BOUND:'已关联',CONFLICT:'关联冲突',FAILED:'失败',PENDING:'待处理',PROCESSING:'处理中',APPLICATION_ACCESS:'应用访问申请',ACCOUNT_OPENING:'账号开通申请',IMMEDIATE:'立即发布',APPROVED:'已通过',REJECTED:'已驳回',COMPLETED:'已处理',WITHDRAWN:'已撤回',EXPIRED:'已过期',UNREAD:'未读',READ:'已读',DRAFT:'草稿',SCHEDULED:'定时发布',PUBLISHED:'已发布',SUCCESS:'成功',FAILURE:'失败',DENIED:'拒绝',OPEN:'待处理',RESOLVED:'已处理',CITIZEN:'公众用户',GOV:'政务用户',LOCAL:'本地管理账号',EXTERNAL:'外部身份',PORTAL_ADMIN_USER:'门户管理用户',ACCESS_USER:'门户访问用户',MINZHENGTONG:'闽政通',MINZHENGWU:'闽政务',PORTAL_LOCAL:'门户本地',PASSWORD:'账号密码',QR:'扫码登录',SMS:'手机号登录',SWITCH:'演示切换',BOTH:'公众及政务',ALL:'全部用户',ORG:'指定组织',PORTAL:'门户',APPLICATION:'子系统',HIGH:'高',MEDIUM:'中',LOW:'低',AUTO:'自动关联',SELF:'自助关联',REVIEW:'审核关联',ADMIN:'管理员关联',TRUSTED_ID:'可信唯一标识',NAME_PHONE:'姓名+手机号',ACCOUNT:'原系统账号',SUBSYSTEM_OTP:'子系统手机号验证码',SUBSYSTEM_CREDENTIAL:'原系统账号验证',UPSTREAM_REAUTH:'上层身份重新认证',SYSTEM:'系统消息',BUSINESS:'业务消息',TODO_REMINDER:'待办提醒'};

const actorEnabled=actor=>actor?.enabled!==false&&actor?.enabled!=='DISABLED'&&actor?.status!=='DISABLED'&&(actor?.adminStatus||'NORMAL')!=='DISABLED';
const isAdminActor=actor=>Boolean(actor?.adminAccess??actor?.adminSubject??actor?.kind==='ADMIN');
export const actorPermissions=actor=>{
 if(!actor)return [];
 if(Array.isArray(actor.permissions))return actor.permissions;
 return permissionsFromScopes(actor.scopes||[]);
};
export const can=(actor,requirement)=>{
 if(!actor||!actorEnabled(actor))return false;
 if(!requirement)return true;
 if(requirement==='any')return isAdminActor(actor);
 if(!isAdminActor(actor))return false;
 const granted=actorPermissions(actor);
 if(granted.includes('system:super'))return true;
 if(requirement.includes(':'))return granted.includes(requirement);
 const compatible=legacyScopePermissions[requirement]||[];
 return compatible.some(code=>granted.includes(code));
};
export const shouldLoadAppCatalog=(isAdmin,actor)=>!isAdmin||can(actor,'application:view');
export const switchTarget=(route,actor)=>{
 if(can(actor,'any'))return route.path?.startsWith('/admin')&&can(actor,route.meta.scope)?route.fullPath:'/admin/home';
 return route.path?.startsWith('/portal')&&can(actor,route.meta.scope)?route.fullPath:'/portal/home';
};
