     if(d.apps.some(x=>x.code===p.code.trim()&&x.id!==p.id))fail('VALIDATION_ERROR','应用编码已存在');
     const x=p.id?requireRow(d.apps,p.id,p.version):{id:id(),version:0,createdAt:now,enabled:false,status:'DISABLED'};
     Object.assign(x,{name:p.name.trim(),code:p.code.trim(),category:p.category||'未分类',description:p.description||'',url:p.url,userType:p.userType,
      accessMode:p.accessMode,postGrantMode:p.accessMode==='REQUEST'?p.postGrantMode:'DIRECT',accountBindingMode:p.accessMode==='DIRECT'?'NONE':p.accountBindingMode,
      accountOpeningMode:p.accountOpeningMode||'NONE',sortOrder:Number(p.sortOrder)||0});stamp(x);if(!p.id)d.apps.push(x);result=x;
    }else if(action==='setAppStatus'){const x=requireRow(d.apps,p.id,p.version);if(typeof p.enabled!=='boolean')fail('VALIDATION_ERROR','启用状态无效');x.enabled=p.enabled;x.status=p.enabled?'ENABLED':'DISABLED';result=stamp(x);
    }else if(action==='saveCategory'){
     if(!p.name?.trim()||!p.code?.trim())fail('VALIDATION_ERROR','名称与编码为必填');if(d.categories.some(x=>(x.code===p.code||x.name===p.name)&&x.id!==p.id))fail('VALIDATION_ERROR','分类名称或编码重复');
     const x=p.id?requireRow(d.categories,p.id,p.version):{id:id(),version:0,createdAt:now};const oldName=x.name;Object.assign(x,{name:p.name.trim(),code:p.code.trim(),status:'ENABLED',sortOrder:Number(p.sortOrder)||0});stamp(x);if(!p.id)d.categories.push(x);if(oldName&&oldName!==x.name)d.apps.filter(app=>app.category===oldName).forEach(app=>{app.category=x.name;stamp(app);});result=x;
    }else if(action==='removeCategory'){const x=requireRow(d.categories,p.id,p.version);if(d.apps.some(app=>app.category===x.name))fail('INVALID_TRANSITION','分类仍被应用使用，不能删除');d.categories=d.categories.filter(x=>x.id!==p.id);result={id:p.id};
    }else if(action==='markRead'){const x=requireRow(d.messages,p.id);if(!own(x,a)||x.deleted)fail('NOT_FOUND','消息不存在');if(x.status==='UNREAD'){x.status='READ';x.readAt=now;stamp(x);}result=x;
    }else if(action==='markMessagesRead'){
     const ids=[...new Set(Array.isArray(p.ids)?p.ids:[])];if(!ids.length)fail('VALIDATION_ERROR','请选择需要标记的消息');
     const targets=ids.map(id=>requireRow(d.messages,id));if(targets.some(x=>!own(x,a)||x.deleted))fail('NOT_FOUND','消息不存在');let count=0;for(const x of targets)if(x.status==='UNREAD'){x.status='READ';x.readAt=now;stamp(x);count++;}result={count};
    }else if(action==='markAllMessagesRead'){
     let count=0;for(const x of d.messages.filter(x=>own(x,a)&&!x.deleted&&x.status==='UNREAD')){x.status='READ';x.readAt=now;stamp(x);count++;}result={count};
    }else if(action==='deleteMessages'){
     const ids=[...new Set(Array.isArray(p.ids)?p.ids:[])];if(!ids.length)fail('VALIDATION_ERROR','请选择需要删除的消息');
     const targets=ids.map(id=>requireRow(d.messages,id));if(targets.some(x=>!own(x,a)||x.deleted))fail('NOT_FOUND','消息不存在');for(const x of targets){x.deleted=true;x.deletedAt=now;stamp(x);}result={count:ids.length};
    }else if(action==='enterApp'){
     const app=requireRow(d.apps,p.id);if(!appEnabled(app))fail('INVALID_TRANSITION','应用已停用');const sso=(d.integrations||[]).find(item=>item.appId===app.id&&item.kind==='SSO');const ssoStatus=sso?.runtimeStatus||'UNCONFIGURED';if(ssoStatus!=='NORMAL')fail('UPSTREAM_UNAVAILABLE','SSO接入异常或未配置');
     if(app.userType!=='BOTH'&&app.userType!==a.userType)fail('FORBIDDEN','应用不适用于当前身份');
     if(app.accessMode==='REQUEST'&&!grantFor(d,a,app.id))fail('APPLICATION_GRANT_REQUIRED','请先提交应用访问申请并等待审核通过');
     const requiresBinding=appRequiresBinding(app);
     if(requiresBinding&&!d.mappings.some(x=>x.appId===app.id&&own(x,a)&&x.status==='BOUND'))fail('ACCOUNT_BINDING_REQUIRED','请先完成子系统账号关联');
     checkUrl(app.url);d.visits.push({userId:a.id,appId:app.id,at:now});result={url:app.url,mode:'MOCK',message:'Mock访问校验已通过。当前未连接真实子系统，正式SSO将在联调阶段接入。'};
    }else if(action==='openTodo'){
     const todo=requireRow(d.todos,p.id);if(!own(todo,a))fail('NOT_FOUND','待办不存在');if(todo.status!=='PENDING')fail('INVALID_TRANSITION','该待办已终结');
     const app=requireRow(d.apps,todo.appId);if(!appEnabled(app))fail('INVALID_TRANSITION','应用已停用');const sso=(d.integrations||[]).find(item=>item.appId===app.id&&item.kind==='SSO');const ssoStatus=sso?.runtimeStatus||'UNCONFIGURED';if(ssoStatus!=='NORMAL')fail('UPSTREAM_UNAVAILABLE','SSO接入异常或未配置');
     if(app.accessMode==='REQUEST'&&!grantFor(d,a,app.id))fail('APPLICATION_GRANT_REQUIRED','当前用户尚未获得该应用入口资格');
     if(appRequiresBinding(app)&&!d.mappings.some(x=>x.appId===app.id&&own(x,a)&&x.status==='BOUND'))fail('IDENTITY_UNRESOLVED','接收用户尚未关联该子系统');
     checkUrl(app.url);d.visits.push({userId:a.id,appId:app.id,at:now});result={url:app.url,mode:'MOCK',message:'Mock待办跳转校验已通过。真实子系统连接尚未开放。'};
    }else if(action==='bind'){
     const app=requireRow(d.apps,p.appId);if(!appEnabled(app))fail('INVALID_TRANSITION','应用已停用，暂不能关联');if(app.userType!=='BOTH'&&app.userType!==a.userType)fail('FORBIDDEN','应用不适用于当前身份');if(!p.externalAccount?.trim())fail('VALIDATION_ERROR','请输入已有子系统账号');
     let x=d.mappings.find(m=>m.userId===a.id&&m.appId===p.appId);if(x?.status==='BOUND')fail('INVALID_TRANSITION','已有关联，请由具备身份映射权限的管理员处理');
     const collision=d.mappings.some(m=>m.appId===p.appId&&m.externalAccount===p.externalAccount.trim()&&m.userId!==a.id&&m.status==='BOUND');
     if(!x){x={id:id(),version:0,createdAt:now,userId:a.id,appId:p.appId,appName:app.name};d.mappings.push(x);}x.externalAccount=p.externalAccount.trim();x.status=collision?'CONFLICT':(p.outcome||'BOUND');if(!['BOUND','FAILED','CONFLICT'].includes(x.status))fail('VALIDATION_ERROR','账号核验结果无效');result=stamp(x);
    }else if(action==='unbind'){const x=requireRow(d.mappings,p.id,p.version);if(x.status!=='BOUND')fail('INVALID_TRANSITION','仅已关联记录可解绑');x.status='UNBOUND';result=stamp(x);
    }else if(action==='resolveMapping'){const x=requireRow(d.mappings,p.id,p.version);if(x.status!=='CONFLICT')fail('INVALID_TRANSITION','仅冲突记录可确认');if(!p.reason?.trim())fail('VALIDATION_ERROR','请输入核验证据说明');if(d.mappings.some(m=>m.id!==x.id&&m.appId===x.appId&&m.externalAccount===x.externalAccount&&m.status==='BOUND'))fail('INVALID_TRANSITION','外部账号仍被其他身份占用');x.status='BOUND';result=stamp(x);
    }else if(action==='saveAnnouncement'){
     if(!p.title?.trim()||!p.content?.trim())fail('VALIDATION_ERROR','标题和正文不能为空');if(!['ALL','CITIZEN','GOV'].includes(p.scope))fail('VALIDATION_ERROR','当前公告发布范围仅支持全部/公众/政务');
     const x=p.id?requireRow(d.announcements,p.id,p.version):{id:id(),version:0,createdAt:now,status:'DRAFT',publishMode:null,submittedAt:null,submittedBy:null,publishedAt:null,scheduledPublishAt:null};
     const effectiveStatus=announcementDisplayStatus(x,Date.parse(now));if(effectiveStatus==='EXPIRED')fail('INVALID_TRANSITION','已过期公告不可编辑');
     if(effectiveStatus!=='WITHDRAWN'&&p.effectiveEnd&&Date.parse(p.effectiveEnd)<=Date.parse(now))fail('VALIDATION_ERROR','失效时间必须晚于当前时间');
     Object.assign(x,{title:p.title.trim(),content:p.content.trim(),type:p.type||'通知',scope:p.scope,effectiveEnd:p.effectiveEnd||null,attachments:p.attachments||[]});
     if(p.targetStatus==='DRAFT'){
      if(!['DRAFT','SCHEDULED','WITHDRAWN'].includes(effectiveStatus))fail('INVALID_TRANSITION','仅草稿、定时发布或已撤回公告可以保存为草稿');
      x.status='DRAFT';x.publishMode=null;x.scheduledPublishAt=null;x.publishedAt=null;x.submittedAt=null;x.submittedBy=null;
      x.withdrawnAt=null;x.withdrawnBy=null;x.withdrawReason='';
     }else if(effectiveStatus==='SCHEDULED'&&p.scheduledPublishAt!==undefined){
      if(!p.scheduledPublishAt||Date.parse(p.scheduledPublishAt)<=Date.parse(now))fail('VALIDATION_ERROR','定时发布时间必须晚于当前时间');