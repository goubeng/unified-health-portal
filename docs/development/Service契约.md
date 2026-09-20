# Service契约（V1.0目标）

> 当前P4服务仅实现其中一部分。本契约是下一阶段目标。

## 用户与角色
readUsers、updatePortalUser、readRoles、saveRole、saveRolePermissions、assignUserRoles。不得修改上层身份主数据。

## 组织
readOrganizationTree、saveOrganization、setOrganizationStatus。

## 应用访问申请
submitApplicationRequest、withdrawApplicationRequest、readMyApplicationRequests、readApplicationRequests、approveApplicationRequest、rejectApplicationRequest、readApplicationGrant。

## 应用
readApps、saveApp、setAppStatus、saveConnectionConfig、enterApp。enterApp必须检查应用启用、适用身份、access_mode、有效授权/映射及SSO条件。

## 公告
saveAnnouncementDraft、submitAnnouncement、cancelScheduledAnnouncement、editPublishedAnnouncement、withdrawAnnouncement、deleteAnnouncement、previewAnnouncement、markAnnouncementRead。
后台任务：publishScheduledAnnouncements、expireAnnouncements。

## 字典
readDictionaryTypes、readDictionaryItems、saveDictionaryType、saveDictionaryItem、setDictionaryStatus。system_locked对象禁止非法增删枚举。

## 日志
统一写入recordAuditEvent。日志读取必须按kind生成专用DTO，而不是前端直接展示通用字段。

## 运行监控
readMonitorProfiles返回应用 + SSO/TODO/MESSAGE三个服务状态。详情返回每服务status、lastSuccessAt、lastFailureAt、failureCount、responseTimeMs、lastError。不返回无必要综合status供详情重复展示。

## 错误码
沿用 VALIDATION_ERROR、FORBIDDEN、NOT_FOUND、VERSION_CONFLICT、INVALID_TRANSITION、UNAUTHENTICATED、UPSTREAM_UNAVAILABLE、IDEMPOTENCY_CONFLICT。
新增建议：DUPLICATE_APPLICATION_REQUEST、APPLICATION_GRANT_REQUIRED、ORGANIZATION_CYCLE、DICTIONARY_LOCKED。
