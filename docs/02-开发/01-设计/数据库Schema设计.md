# 数据库 Schema 设计（0.3.0-B 目标）

> 设计基线：V20260921-01  
> 性质：目标物理模型与迁移设计。当前 `database/schema.sql` 与 001～004 Migration 继续作为 P3 历史验收基线；本文件确认前不得直接覆盖历史数据库。

> **现行实现核对（2026-10-01）：**下文“当前物理结构结论”是 2026-09-21 的历史差异快照，不是现库盘点。当前数据库模式在该基线上继续执行 005～011 迁移；应用访问申请、授权和账号开通申请已有规范表（008），接入状态迁移历史已有 `monitor_status_history`（011）。`database/schema.sql` 不能单独代表已迁移数据库的最终结构。目标 `application_integration`、`integration_event`、独立 `portal_admin_user`/凭证模型仍不应宣称已实现；现有 SSO/PUSH 配置、监控快照、运行实体与规范表并存。以迁移文件和 Repository 映射核对实际落库，不按本目标设计直接删改历史表。

## 1. 当前物理结构结论

在 2026-09-21 设计时点，P3 已形成 32 张 PostgreSQL 原生表并完成当时阶段验收。0.3.0-B 的目标不是“重新建库”，而是在保留历史验收事实的前提下，把物理模型收敛到业务基线。此数量不是 2026-10-01 的现库表数。

设计时点结构与 V20260921-01 的主要差异（非 2026-10-01 现状清单）：

1. `portal_user_role` 仍直接给 `unified_user` 授管理角色；
2. `portal_session` 强制绑定 `unified_user + identity_mapping`，不能自然承载纯 LOCAL 管理账号；
3. `application.runtime_status` 与 SSO/TODO/MESSAGE 独立运行状态重复；
4. `sso_config`、`push_integration_config` 分散，缺少统一接入能力模型；
5. `todo_item` 仍存在 priority、due_at、source_revision、terminal_at、EXPIRED；
6. `message_recipient` 缺少用户级逻辑删除；
7. `announcement` 仍把 EXPIRED 等展示状态固化到主状态；
8. `audit_event.actor_user_id` 只能表达 unified_user；
9. 历史 `sms_*` 表与当前“短信由上层公共服务提供”的边界不一致；
10. 应用访问申请、入口授权、账号开通申请目前主要存在于 Mock，尚缺正式物理模型。

## 2. 目标关系

```text
identity_source
      │
identity_mapping
      │
unified_user（CITIZEN/GOV 门户访问主体）
  │
  ├─ application_user_mapping
  ├─ todo_item
  ├─ message_recipient
  ├─ application_access_request / grant
  │
  └─ 可选绑定
        ↓
portal_admin_user
  ├─ portal_admin_credential（LOCAL时）
  └─ portal_admin_user_role
        ↓
    portal_role
        ↓
portal_role_permission
        ↓
 portal_permission

application
  ├─ application_integration [SSO/TODO/MESSAGE]
  │      └─ integration_event
  ├─ application_access_request / grant
  ├─ application_user_mapping
  ├─ todo_item
  └─ message
```

## 3. 表级处理总表

| 表 | 动作 | 目标 |
|---|---|---|
| identity_source | 保留/小改 | 外部身份源 |
| unified_user | 保留/收敛 | 仅 CITIZEN/GOV 门户访问主体 |
| identity_mapping | 保留 | 外部身份映射 |
| login_request | 保留/调整 | 外部认证会话 |
| portal_session | 改造 | 支持访问主体、外部管理员、本地管理员 |
| portal_admin_user | 新增 | 独立管理端授权主体 |
| portal_admin_credential | 新增 | LOCAL 管理账号凭证 |
| portal_admin_user_role | 新增 | 管理用户角色关系 |
| portal_user_role | 迁移后退役 | 不再给 unified_user 授管理角色 |
| portal_user_application_scope | 首期退役/历史保留 | 首期不做复杂数据范围 |
| portal_role / portal_permission / portal_role_permission | 保留/收敛 | 正式 RBAC |
| application_category | 保留 | 应用分类 |
| application | 改造 | 目录信息与启停，不保存权威综合运行状态 |
| application_access_request | 新增 | REQUEST 模式申请 |
| application_access_grant | 新增 | 门户入口资格 |
| account_opening_request | 新增 | 子系统开户注册申请投影 |
| application_integration | 新增 | SSO/TODO/MESSAGE 统一管理壳 |
| sso_config | 迁移/退役 | 迁入统一接入模型或协议扩展 |
| push_integration_config | 迁移/退役 | TODO/MESSAGE 迁入统一接入模型 |
| integration_event | 新增 | 检测、异常、恢复、调用历史 |
| monitor_status | 收敛 | 当前状态由 application_integration 表达 |
| application_user_mapping | 改造 | REVIEWING、验证信息、子系统账号状态 |
| mapping_exception | 保留 | 冲突与异常处理 |
| mapping_verification_event | 建议新增 | 账号关联核验过程 |
| ingest_receipt | 保留/收敛 | TODO/MESSAGE 幂等，移除 SMS kind |
| todo_item | 改造 | 删除旧 SLA/版本字段及 EXPIRED |
| message | 保留 | 消息本体 |
| message_recipient | 改造 | 增加 deleted/deleted_at |
| announcement | 改造 | 主状态收敛，补发布方式/计划时间 |
| announcement_org_scope | 保留 | 指定组织范围 |
| announcement_attachment | 保留/改引用 | 上传者改为管理主体 |
| audit_event | 改造 | 支持 access/admin/application/system actor |
| system_config | 保留 | 门户参数 |
| sms_* | 退役/归档 | 不进入新核心 Schema |

## 4. portal_admin_user

建议字段：

| 字段 | 说明 |
|---|---|
| id | 主键 |
| account | 管理账号/展示账号 |
| name | 姓名 |
| auth_type | EXTERNAL / LOCAL |
| access_user_id | EXTERNAL 时绑定 unified_user；LOCAL 可空 |
| enabled | 管理端访问是否启用 |
| protected_flag | 系统受保护账号标记 |
| last_login_at | 最近管理端登录 |
| created_at / updated_at | 时间 |
| version | 乐观版本 |

约束：
- EXTERNAL 必须绑定有效 `access_user_id`；
- LOCAL 不创建 LOCAL `unified_user`；
- 同一访问主体原则上最多绑定一个有效门户管理用户；
- 停用管理用户只取消管理端资格，不影响其外部身份及普通用户端访问。

## 5. portal_admin_credential

仅 LOCAL 管理用户存在：

- id；
- admin_user_id（唯一 FK）；
- username（唯一）；
- password_hash；
- password_algorithm；
- must_change_password；
- failed_login_count；
- locked_until；
- password_updated_at；
- last_login_at；
- created_at / updated_at / version。

`password_hash` 永不得通过普通 API 返回。

## 6. portal_session

目标字段：
- id；
- access_user_id nullable；
- admin_user_id nullable；
- identity_mapping_id nullable；
- auth_type：EXTERNAL / LOCAL；
- token_hash；
- expires_at；
- revoked_at；
- created_at / updated_at / version。

约束：
- 至少存在 access_user_id 或 admin_user_id；
- LOCAL：admin_user_id 必填，access_user_id 可空；
- 外部普通用户：access_user_id 必填；
- 外部管理员：access_user_id 与 admin_user_id 可以同时存在；
- Session 不以角色/权限快照作为永久权威数据。

## 7. 管理端 RBAC

新增 `portal_admin_user_role`：

- admin_user_id；
- role_id；
- granted_by_admin_user_id；
- granted_at；
- expires_at；
- version。

唯一：`admin_user_id + role_id`。

`portal_user_role` 完成迁移后停止写入并最终退役。最后一个有效 SUPER_ADMIN 必须通过后端事务校验保护。

## 8. application 与 application_integration

`application` 只保存：
- code/name/category；
- user_type；
- application_url；
- logo/description/contact；
- sort_order；
- enabled；
- created_at/updated_at/version。

`application.runtime_status` 不再作为权威字段。需要综合运行状态时由接入能力派生。

`application_integration` 每应用每类型一条：
- application_id；
- integration_type：SSO/TODO/MESSAGE；
- connection_mode；
- config_status：UNCONFIGURED/CONFIGURED；
- enabled；
- runtime_status：UNCONFIGURED/DISABLED/NORMAL/ABNORMAL；
- config_json（仅非敏感扩展）；
- credential_ref；
- last_check_at；
- last_success_at；
- last_error_code / last_error_message；
- config_version；
- created_at / updated_at / version。

唯一：`application_id + integration_type`。

## 9. application_access_request / grant / account_opening_request

### application_access_request
保存 REQUEST 入口申请：
- request_no；
- application_id；
- user_id；
- reason；
- status：PENDING/APPROVED/REJECTED/WITHDRAWN/EXPIRED；
- submitted_at；
- reviewed_by_admin_user_id；
- reviewed_at；
- review_note；
- expires_at；
- version。

### application_access_grant
保存门户入口资格：
- application_id；
- user_id；
- status：ACTIVE/REVOKED/EXPIRED；
- granted_by_admin_user_id；
- granted_at；
- expires_at；
- version。

同一 application + user 同时最多一个 ACTIVE grant。

### account_opening_request
记录“由子系统决定开户”的门户申请投影，不代表门户直接创建子系统业务账号。

## 10. application_user_mapping

目标字段至少包括：
- unified_user_id；
- application_id；
- external_user_id；
- external_account；
- binding_method；
- status：UNBOUND/VERIFYING/REVIEWING/BOUND/FAILED/CONFLICT；
- external_account_status：ACTIVE/DISABLED/UNKNOWN；
- match_method；
- verification_method；
- verified_at；
- reviewed_by_admin_user_id；
- reviewed_at；
- bound_at / unbound_at；
- conflict_reason；
- version。

约束：
- user + application 一个当前映射槽位；
- application + external_user_id 同时最多一个有效 BOUND；
- 冲突不得自动覆盖。

## 11. integration_event

用于运行监控详情与异常追溯：

- integration_id；
- event_type：CHECK/CALL/FAILURE/RECOVERY/CONFIG_CHANGE；
- result；
- http_status；
- error_code/error_message；
- duration_ms；
- request_id；
- trace_id；
- occurred_at；
- created_at。

当前状态保存在 `application_integration`，历史过程保存在 `integration_event`。

## 12. todo_item

正式保留：
- application_id；
- source_todo_id；
- target_user_id；
- title；
- business_type；
- summary；
- status：PENDING/COMPLETED/WITHDRAWN；
- source_created_at；
- received_at；
- source_updated_at；
- business_url/action_path；
- created_at / updated_at / version。

正式删除：
- priority；
- due_at；
- source_revision；
- terminal_at；
- EXPIRED。

`application_id + source_todo_id` 唯一。

## 13. message / message_recipient

消息本体与收件人状态继续分离。

`message_recipient` 增加：
- deleted boolean default false；
- deleted_at timestamptz nullable。

用户删除消息只修改自己的 recipient，不物理删除 message，也不影响其他接收人。

## 14. announcement

持久化主状态：
- DRAFT；
- PUBLISHED；
- WITHDRAWN。

字段至少：
- title/type/content/scope；
- status；
- publish_mode：IMMEDIATE/SCHEDULED；
- scheduled_publish_at；
- published_at；
- effective_end；
- created_by_admin_user_id；
- updated_by_admin_user_id；
- withdrawn_at / withdrawn_by_admin_user_id；
- created_at / updated_at / version。

页面派生：
- SCHEDULED：DRAFT + publish_mode=SCHEDULED + future scheduled_publish_at；
- EXPIRED：PUBLISHED + effective_end < now。

页面仍可展示“定时发布/已过期”，但数据库不依赖额外永久主状态。

## 15. audit_event

目标 actor 支持：
- ACCESS_USER；
- PORTAL_ADMIN_USER；
- APPLICATION；
- SYSTEM。

建议字段：
- actor_kind；
- actor_access_user_id nullable；
- actor_admin_user_id nullable；
- actor_application_id nullable；
- request_id / trace_id；
- application_id（被操作应用）；
- object_type/object_id；
- result；
- summary；
- details jsonb；
- created_at。

通过 CHECK 保证 actor_kind 与对应 actor_id 组合合法。

## 16. SMS 历史结构

以下历史表不继续扩展：
- sms_channel；
- sms_template；
- sms_application；
- sms_application_template；
- sms_send_record；
- sms_send_attempt。

退役顺序：
1. 核实无正式业务依赖；
2. 标记只读/废弃；
3. 如有数据先导出备份；
4. 移除运行代码引用；
5. 最后单独 Migration 删除。

禁止在未经数据确认时直接 DROP。

## 17. Migration 拆分

不修改 001～004 历史 Migration，新增：

1. `005_admin_domain.sql`：portal_admin_user / credential / role relation，Session兼容；
2. `006_application_access.sql`：申请、授权、账号开通申请；
3. `007_integration_model.sql`：application_integration / integration_event 与旧配置迁移；
4. `008_business_projection_cleanup.sql`：mapping、TODO、MESSAGE、announcement；
5. `009_audit_actor_upgrade.sql`：审计主体增强；
6. `010_legacy_retirement.sql`：历史角色关系、旧integration/monitor/sms等在验证完成后退役。

每个 Migration 必须同时提供：前置检查、数据迁移、约束/索引、验证 SQL、恢复/回滚说明。

## 18. 0.3.0-B 验收

完成后必须满足：
- LOCAL 管理账号不再存在于 unified_user；
- 所有有效管理员均存在 portal_admin_user；
- 至少 1 个有效 SUPER_ADMIN；
- portal_user_role 不再被运行代码写入；
- TODO 无 priority/due_at/source_revision/terminal_at/EXPIRED 依赖；
- 消息删除不物理删除 message；
- 公告 SCHEDULED/EXPIRED 可由字段正确派生；
- 每应用 SSO/TODO/MESSAGE 最多各一条 integration；
- 运行监控状态不能由前端直接写 NORMAL；
- SMS 历史表无运行依赖后才允许退役；
- Migration 可在现有 P3 数据副本上重复演练并通过验证。
