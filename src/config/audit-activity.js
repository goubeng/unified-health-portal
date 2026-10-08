export const auditActionNames={
 createExternalPortalAdmin:'授权外部用户管理资格',createLocalPortalUser:'新建本地管理账号',setPortalUserStatus:'变更管理用户启用状态',resetLocalPassword:'重置本地管理账号密码',unlockLocalUser:'解除本地管理账号锁定',savePortalUser:'维护门户管理用户',
 saveOrganization:'维护组织',removeOrganization:'删除组织',saveDictionaryType:'维护字典类型',saveDictionaryItem:'维护字典项',removeDictionaryItem:'删除字典项',saveSystemRole:'维护系统角色',
 markAnnouncementRead:'阅读公告',saveApp:'维护应用信息',removeApp:'删除应用',setAppStatus:'变更应用启用状态',saveCategory:'维护系统分类',removeCategory:'删除分类',
 markRead:'阅读消息',markMessagesRead:'批量阅读消息',markAllMessagesRead:'全部消息已读',deleteMessages:'删除消息',enterApp:'访问应用',openTodo:'打开待办',
 discoverApplicationAccountCandidates:'查找子系统候选账号',startApplicationAccountBinding:'自动关联子系统账号',sendSubsystemBindingOtp:'发送账号关联验证码',verifyBindingOtp:'验证账号关联验证码',verifyBindingBySubsystemCredential:'验证原系统账号',verifyBindingByUpstreamReauth:'重新认证身份',
 submitAccountOpeningRequest:'提交子系统账号开通申请',completeMockAccountOpeningRequest:'完成Mock账号开通申请',approveBindingReview:'通过账号关联审核',rejectBindingReview:'驳回账号关联审核',resolveLogError:'处理异常日志',
 submitApplicationRequest:'提交应用访问申请',withdrawApplicationRequest:'撤回应用访问申请',approveApplicationRequest:'通过应用访问申请',rejectApplicationRequest:'驳回应用访问申请',bind:'关联子系统账号',unbind:'解除账号关联',resolveMapping:'处理映射冲突',
 saveAnnouncement:'保存公告',submitAnnouncement:'提交公告发布',publish:'发布公告',withdraw:'撤回公告',removeAnnouncement:'删除公告',saveConfig:'维护参数',createAccessProfile:'新增应用接入',saveIntegration:'维护接入配置',pushTodo:'接收待办',pushMessage:'接收消息',
 LOGIN:'登录',LOGOUT:'退出登录',SWITCH_USER:'切换用户',DOWNLOAD_CONTRACT:'下载接口契约',PUSH_REJECTED:'拒绝接入推送',ANNOUNCEMENT_RETENTION:'清理过期公告',
 P4FIX_login:'登录',P4FIX_auth:'权限核验',IDENTITY_ACCEPTED:'身份核验'
};

export const auditActionPages={
 createExternalPortalAdmin:['系统管理','用户管理'],createLocalPortalUser:['系统管理','用户管理'],setPortalUserStatus:['系统管理','用户管理'],resetLocalPassword:['系统管理','用户管理'],unlockLocalUser:['系统管理','用户管理'],savePortalUser:['系统管理','用户管理'],
 saveSystemRole:['系统管理','角色管理'],saveOrganization:['系统管理','组织管理'],removeOrganization:['系统管理','组织管理'],saveDictionaryType:['系统管理','字典管理'],saveDictionaryItem:['系统管理','字典管理'],removeDictionaryItem:['系统管理','字典管理'],
 saveApp:['应用管理','应用列表'],removeApp:['应用管理','应用列表'],setAppStatus:['应用管理','应用列表'],createAccessProfile:['应用管理','应用列表'],saveIntegration:['应用管理','应用列表'],
 submitApplicationRequest:['应用中心','应用访问申请'],withdrawApplicationRequest:['应用中心','我的申请'],approveApplicationRequest:['应用管理','应用访问申请'],rejectApplicationRequest:['应用管理','应用访问申请'],
 submitAccountOpeningRequest:['应用中心','子系统账号开通申请'],completeMockAccountOpeningRequest:['应用管理','子系统账号开通申请'],
 approveBindingReview:['身份与映射','身份与子系统映射'],rejectBindingReview:['身份与映射','身份与子系统映射'],unbind:['身份与映射','身份与子系统映射'],resolveMapping:['身份与映射','关联冲突处理'],
 saveAnnouncement:['工作台','通知公告管理'],submitAnnouncement:['工作台','通知公告管理'],publish:['工作台','通知公告管理'],withdraw:['工作台','通知公告管理'],removeAnnouncement:['工作台','通知公告管理'],
 resolveLogError:['日志审计','异常日志'],saveConfig:['系统管理','配置管理']
};
