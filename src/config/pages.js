export const scopes={super:'超级管理权限',application:'应用管理权限',integration:'集成管理权限',announcement:'公告管理权限',audit:'审计权限',identity:'身份映射权限'};
const p=(id,path,title,group,resource,scope=null)=>({id,path,title,group,resource,scope});
export const pages=[
 p('PG-001','/login','统一登录','登录','login'),p('PG-002','/auth/result','认证结果','登录','auth'),
 p('PG-101','/portal/home','首页','个人事务','home'),{...p('PG-102','/portal/apps/mine','应用中心','应用中心','mine'),hidden:true},p('PG-103','/portal/apps/all','应用中心','应用中心','apps'),
 p('PG-104','/portal/todos','待办任务','个人事务','todos'),p('PG-109','/portal/applications','我的申请','个人事务','myApplicationRequests'),p('PG-105','/portal/messages','消息中心','个人事务','messages'),p('PG-106','/portal/announcements','通知公告','个人事务','announcements'),p('PG-107','/portal/announcements/:id','公告详情','个人事务','announcementDetail'),p('PG-108','/portal/profile','个人中心','个人事务','profile'),

 p('PG-201','/admin/home','管理首页','工作台','adminHome','any'),
 // 通知公告管理归入管理首页所在工作台分组，不再单独显示“内容管理”一级菜单。
 p('PG-220','/admin/announcements','通知公告管理','工作台','announcements','announcement'),p('PG-229','/admin/announcements/:id','公告详情','工作台','announcementDetail','announcement'),
 p('PG-202','/admin/apps','应用列表','应用管理','apps','application'),p('PG-231','/admin/application-requests','应用访问申请','应用管理','applicationRequests','application'),p('PG-234','/admin/account-opening-requests','子系统账号开通申请','应用管理','accountOpeningRequests','application'),{...p('PG-203','/admin/app-categories','系统分类','应用管理','categories','application'),hidden:true},

 // 门户只维护自身访问权限，不替代子系统业务授权。
 p('PG-228','/admin/users','用户管理','系统管理','users','any'),p('PG-209','/admin/roles','角色管理','系统管理','roles','super'),{...p('PG-210','/admin/permissions','门户权限配置','系统管理','permissions','super'),hidden:true},p('PG-229','/admin/organizations','组织管理','系统管理','organizations','any'),p('PG-230','/admin/dictionaries','字典管理','系统管理','dictionaries','any'),
 // 身份与子系统映射归入“系统管理”，不再单独显示“身份与映射”一级菜单。
 p('PG-205','/admin/identities','身份与子系统映射','系统管理','identityOverview','identity'),
 ...[['PG-206','/admin/identity-mappings'],['PG-207','/admin/account-mappings'],['PG-208','/admin/mapping-exceptions']].map(([id,path])=>({...p(id,path,'身份与子系统映射','系统管理','identityOverview','identity'),hidden:true})),
 p('PG-221','/admin/settings','配置管理','系统管理','settings','super'),p('PG-222','/admin/monitor','运行监控','应用管理','monitor','integration'),
 ...[['223','login','登录/认证日志'],['224','access','应用访问日志'],['225','operation','门户操作日志'],['226','api','接口调用日志'],['227','error','异常日志']].map(([id,kind,title])=>p('PG-'+id,'/admin/logs/'+kind,title,'日志审计','logs:'+kind,'audit'))
];
export const labels={ENABLED:'启用',DISABLED:'停用',NORMAL:'正常',ABNORMAL:'异常',UNCONFIGURED:'未配置',CONFIGURED:'已配置',REQUEST_REQUIRED:'未申请',REQUEST_PENDING:'审核中',REQUEST_REJECTED:'已驳回',DIRECT:'直接访问',BIND:'账号关联',REQUEST:'申请使用',NONE:'不开放',NOT_APPLICABLE:'不适用',APP_DISABLED:'应用停用',UNBOUND:'未关联',VERIFYING:'验证中',REVIEWING:'待审核',BOUND:'已关联',CONFLICT:'关联冲突',FAILED:'失败',PENDING:'待处理',PROCESSING:'处理中',APPLICATION_ACCESS:'应用访问申请',ACCOUNT_OPENING:'账号开通申请',APPROVED:'已通过',REJECTED:'已驳回',COMPLETED:'已处理',WITHDRAWN:'已撤回',EXPIRED:'已过期',UNREAD:'未读',READ:'已读',DRAFT:'草稿',PUBLISHED:'已发布',SUCCESS:'成功',FAILURE:'失败',DENIED:'拒绝',OPEN:'待处理',RESOLVED:'已处理',CITIZEN:'公众用户',GOV:'政务用户',LOCAL:'门户本地用户',BOTH:'公众及政务',ALL:'全部用户',ORG:'指定组织',PORTAL:'门户',APPLICATION:'子系统',HIGH:'高',MEDIUM:'中',LOW:'低',AUTO:'自动关联',SELF:'自助关联',REVIEW:'审核关联',ADMIN:'管理员关联',TRUSTED_ID:'可信唯一标识',NAME_PHONE:'姓名+手机号',ACCOUNT:'原系统账号',SUBSYSTEM_OTP:'子系统手机号验证码',SUBSYSTEM_CREDENTIAL:'原系统账号验证',UPSTREAM_REAUTH:'上层身份重新认证',SYSTEM:'系统消息',BUSINESS:'业务消息',TODO_REMINDER:'待办提醒'};
export const can=(actor,scope)=>!!actor&&actor.status!=='DISABLED'&&(!scope||(actor.kind==='ADMIN'&&(scope==='any'||actor.scopes.includes('super')||actor.scopes.includes(scope))));
