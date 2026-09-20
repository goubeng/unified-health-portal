# Service契约（V1.0目标）

> 基线：V20260920-02。当前P4服务只实现其中一部分。

## 1. 身份来源

门户认证适配层必须明确两个来源：

- 闽政通 → CITIZEN / 公众用户
- 闽政务 → GOV / 政务用户

服务端不得通过角色或后台编辑修改该来源映射。

建议能力：

- resolveIdentitySource
- consumeIdentityCallback
- upsertUnifiedIdentity
- createPortalSession

## 2. 用户与角色

- readUsers
- updatePortalUser
- readRoles
- saveRole
- saveRolePermissions
- assignUserRoles

updatePortalUser只允许修改门户状态、门户组织索引和门户角色，不得修改闽政通/闽政务身份来源、公众/政务用户类别及权威身份资料。

角色服务只处理门户权限，不接受子系统业务角色。

## 3. 组织

- readOrganizationTree
- saveOrganization
- setOrganizationStatus
- syncOrganizationIndex

政务组织优先从闽政务建立索引；公众用户组织允许为空。

## 4. 应用访问申请

- submitApplicationRequest
- withdrawApplicationRequest
- readMyApplicationRequests
- readApplicationRequests
- approveApplicationRequest
- rejectApplicationRequest
- readApplicationGrant

审核结果只产生门户入口资格。

## 5. 应用入口

- readApps
- saveApp
- setAppStatus
- saveConnectionConfig
- enterApp

enterApp依次检查：

1. 门户Session和用户状态；
2. 应用启用状态；
3. 用户类别与应用适用范围；
4. DIRECT/BIND/REQUEST访问模式；
5. 必要的入口授权；
6. 必要的子系统账号映射；
7. SSO/跳转条件。

进入子系统后，子系统继续自行校验业务权限。

## 6. 公告

- saveAnnouncementDraft
- submitAnnouncement
- cancelScheduledAnnouncement
- editPublishedAnnouncement
- withdrawAnnouncement
- deleteAnnouncement
- previewAnnouncement
- markAnnouncementRead
- publishScheduledAnnouncements
- expireAnnouncements

## 7. 字典

- readDictionaryTypes
- readDictionaryItems
- saveDictionaryType
- saveDictionaryItem
- setDictionaryStatus

应用系统分类最终从字典读取。

system_locked对象禁止非法增删状态和协议。

## 8. 日志

统一写入recordAuditEvent。

登录审计必须写入：

- userType
- identitySource
- loginSource
- loginMethod

操作审计必须写入：

- module
- page
- action
- objectType/objectId
- result
- summary

读取日志按kind生成专用DTO。

## 9. 运行监控

readMonitorProfiles返回应用及SSO/TODO/MESSAGE三个服务状态。

详情返回每服务status、lastSuccessAt、lastFailureAt、failureCount、responseTimeMs、lastError。

不返回无必要的综合status供详情重复展示。
