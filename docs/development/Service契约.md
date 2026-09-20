# Service契约（V1.0目标）

> 基线：V20260920-03。

## 1. 身份与登录

外部：

- consumeMinZhengTongAuth → CITIZEN
- consumeMinZhengWuAuth → GOV

本地：

- authenticateLocalUser
- changeLocalPassword
- resetLocalPassword
- unlockLocalCredential

登录成功统一进入：
- upsertUnifiedIdentity
- createPortalSession
- recordAuditEvent

authenticateLocalUser必须校验：
- identitySource=PORTAL_LOCAL
- userType=LOCAL
- 用户启用
- 未锁定
- 密码Hash
- 有效管理角色

## 2. 用户管理

- readUsers
- readUserDetail
- updatePortalUser
- createLocalUser
- updateLocalUser
- setUserStatus
- resetLocalUserPassword
- assignUserRoles

updatePortalUser不得修改外部权威身份属性。

## 3. 角色与权限

- readRoles
- saveRole
- setRoleStatus
- saveRolePermissions
- readRoleUsers

默认角色：
- SUPER_ADMIN
- PORTAL_ADMIN

首期主要权限类型：
- MENU
- PAGE
- ACTION

## 4. 组织

- readOrganizationTree
- saveOrganization
- setOrganizationStatus
- syncOrganizationIndex

## 5. 应用访问

- submitApplicationRequest
- withdrawApplicationRequest
- readMyApplicationRequests
- readApplicationRequests
- approveApplicationRequest
- rejectApplicationRequest
- readApplicationGrant
- enterApp

LOCAL首期默认不进入普通应用访问流程，但服务端不应通过硬编码角色实现此规则，应依据产品入口/适用用户配置。

## 6. 公告

- saveAnnouncementDraft
- submitAnnouncement
- cancelScheduledAnnouncement
- editPublishedAnnouncement
- withdrawAnnouncement
- deleteAnnouncement
- previewAnnouncement
- publishScheduledAnnouncements
- expireAnnouncements

## 7. 字典

- readDictionaryTypes
- readDictionaryItems
- saveDictionaryType
- saveDictionaryItem
- setDictionaryStatus

## 8. 审计

recordAuditEvent。

本地登录必须写：
- userType=LOCAL
- identitySource=PORTAL_LOCAL
- loginMethod=PASSWORD

不得写密码、验证码、Token、password_hash。

## 9. 运行监控

readMonitorProfiles只返回真实服务状态：
- SSO
- TODO
- MESSAGE

详情不再返回用于展示的冗余综合status。

## 10. 建议错误码

- LOCAL_ACCOUNT_DISABLED
- LOCAL_ACCOUNT_LOCKED
- INVALID_CREDENTIALS
- PASSWORD_CHANGE_REQUIRED
- ADMIN_ROLE_REQUIRED
- LAST_SUPER_ADMIN_PROTECTED
- DUPLICATE_APPLICATION_REQUEST
- APPLICATION_GRANT_REQUIRED
- DICTIONARY_LOCKED
