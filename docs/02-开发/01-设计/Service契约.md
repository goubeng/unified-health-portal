# Service 契约（V1.0 目标）

> 目标设计：V20260921-01。当前前端 Mock 与历史 P3 数据库不代表本契约已实现。

## 1. 身份与会话

外部认证：
- consumeMinZhengTongAuth
- consumeMinZhengWuAuth
- upsertAccessSubject
- createPortalSession

管理授权：
- resolvePortalAdminUser
- loadAdminRoles
- loadAdminPermissions

本地管理账号：
- authenticateLocalAdmin
- changeLocalAdminPassword
- resetLocalAdminPassword
- unlockLocalAdminCredential

外部身份认证成功不自动获得管理权，必须存在有效 portal_admin_user。

## 2. 门户管理用户

- readAdminUsers
- readAdminUserDetail
- createAdminUser
- updateAdminUser
- setAdminUserEnabled
- bindAdminExternalIdentity
- unbindAdminExternalIdentity
- assignAdminRoles
- deleteAdminUser

外部身份绑定只保存门户授权关系，不修改闽政通/闽政务权威资料。

## 3. 角色与权限

- readRoles
- saveRole
- setRoleEnabled
- saveRolePermissions
- readRoleUsers

默认 Seed：
- SUPER_ADMIN
- PORTAL_ADMIN

所有高风险写操作必须服务端鉴权。最后一个有效超级管理员由服务端事务保护。

## 4. 应用与接入

- readApplications
- saveApplication
- setApplicationEnabled
- readApplicationIntegrations
- saveApplicationIntegration
- setIntegrationEnabled
- testIntegration
- readIntegrationMonitor

SSO/TODO/MESSAGE 必须分别建模。配置状态、启用状态、运行状态分离。

## 5. 子系统账号映射

- discoverApplicationAccountCandidates
- startApplicationAccountBinding
- verifyApplicationAccountBinding
- submitBindingReview
- approveBindingReview
- rejectBindingReview
- unbindApplicationAccount
- resolveMappingConflict
- readApplicationMappings

映射主体是访问用户，不是 portal_admin_user。姓名+手机号只能发现候选，不能直接 BOUND。

## 6. SSO

- createSsoTicket
- verifySsoTicket
- enterApplication
- openTodo

Ticket 短时、一次性、服务端验证。门户只衔接身份，子系统继续做业务权限判断。

## 7. TODO

接入：
- ingestTodo
- updateTodoStatus

查询：
- readMyTodos
- readTodoDetail

状态：PENDING / COMPLETED / WITHDRAWN。

规则：
1. application + eventId 幂等；
2. application + sourceTodoId 识别同一待办；
3. 门户“去处理”不修改业务状态；
4. 来源系统是权威状态源；
5. 不接收 priority/dueAt/逾期字段。

## 8. MESSAGE

- ingestMessage
- readMyMessages
- markMessageRead
- markMessagesRead
- deleteMessageForRecipient

消息本体与收件人已读/删除状态分离。

## 9. 公告

- saveAnnouncementDraft
- publishAnnouncement
- scheduleAnnouncement
- withdrawAnnouncement
- deleteAnnouncement
- previewAnnouncement
- publishScheduledAnnouncements

## 10. 审计与监控

- recordAuditEvent
- readAuditEvents
- recordIntegrationEvent
- recomputeIntegrationRuntimeStatus

运行状态不得由管理员直接 setNormal。

## 11. 建议错误码

- AUTH_REQUIRED
- AUTH_PERMISSION_DENIED
- ADMIN_USER_DISABLED
- LAST_SUPER_ADMIN_PROTECTED
- APPLICATION_DISABLED
- INTEGRATION_NOT_CONFIGURED
- INTEGRATION_DISABLED
- SSO_TICKET_EXPIRED
- SSO_MAPPING_REQUIRED
- TODO_RECEIVER_NOT_FOUND
- MAPPING_ALREADY_EXISTS
- MAPPING_CONFLICT
- ANNOUNCEMENT_STATUS_CONFLICT
