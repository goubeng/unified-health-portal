# 数据库现状与 0.3.0-B 交接

> 2026-09-23 更新：下文为 0.3.0-A 历史交接记录，不再描述当前启动和数据库状态。现已在目标 schema 执行 005–009 迁移；`npm run dev` 默认连接数据库，`npm run dev:mock` 才使用内存模式。当前迁移、备份及读写验收详见 [`../doc/progress.md`](../doc/progress.md)，运行说明见 [`../README.md`](../README.md)。历史章节保留供追溯，请勿依照其中“不执行 Migration”的 A 阶段约束操作当前环境。

> 当前目标设计：V20260920-03  
> 当前阶段：0.3.0-A 前端 Mock 收口  
> 当前规则：**本阶段不修改PostgreSQL/NocoDB，不执行Migration；P3数据库只作为历史验收基线。**

## 1. 当前数据库事实

目标环境：

- PostgreSQL 14；
- NocoDB base：`pb3gir75kkooyea`；
- NocoDB source：`bojz43pok1w9vqa`；
- source类型：本地原生PG；
- 不关联其它项目数据库；
- 不使用外部数据源替代本项目原生表。

P3历史实施已经完成并保留为事实：

- 原生创建32张表；
- 356个业务字段；
- 12项UNCONFIGURED配置；
- 无Link/Lookup；
- 实际PostgreSQL 14.20；
- 已执行`003_native_constraints.sql`；
- 199项约束及支持索引已验证；
- 13类非法写入反例、有效写入与事务回滚验证通过；
- P3测试残留为0。

对应证据：

- `docs/02-开发/02-评审/P3建表与验证记录.md`
- `docs/02-开发/02-评审/P3整体验收.md`
- `doc/nocodb-readback.json`

上述内容是**P3历史数据库验收结果**，不表示数据库已经按V20260920-03最新需求完成升级。

## 2. 当前数据库源码文件定位

| 文件 | 当前定位 |
|---|---|
| `schema.sql` | P3空库初始化历史基线 |
| `migrations/001_initial.sql` | P3初始Migration，与历史schema对应 |
| `migrations/002_bound_account_unique.sql` | 历史补充Migration；原生库最终规则已由003覆盖 |
| `migrations/003_native_constraints.sql` | 已在P3目标原生库执行并验收 |
| `seed.sql` | P3的12项UNCONFIGURED配置历史Seed |
| `fixtures/p4-fixtures.sql` | P4隔离演示/验证样本 |
| `validation/*` | P3/P4设计、约束、fixture验证工具 |

**禁止为了“看起来最新”而直接修改001/002/003的历史事实。**

V20260920-03的数据库变化应从新的0.3.0-B Migration开始。

## 3. A阶段数据库边界

当前标准启动：

```bash
npm run api
```

健康检查应返回：

```text
repository=MEMORY_A
phase=0.3.0-A
```

A阶段：

- 不执行 `npm run api:db`；
- 不执行DDL；
- 不执行Migration；
- 不同步NocoDB结构；
- 不清理旧字段；
- 不删除历史短信表；
- 不写入真实认证凭证；
- 不把Mock/fixture运行结果当成真实数据库联调结果。

## 4. 0.3.0-B 统一数据库清理待办

进入B阶段后，先做“P3实际结构 → V20260920-03目标结构”的完整差异检查，再生成新Migration。

### 4.1 用户与本地身份

确认并落地：

- `unified_user`支持CITIZEN / GOV / LOCAL；
- identity_source支持MINZHENGTONG / MINZHENGWU / PORTAL_LOCAL；
- 当前允许为空的组织字段不再强制非空；
- 门户启用状态、首次登录、最近登录等当前目标字段；
- 新增`portal_local_credential`；
- password_hash仅服务端使用；
- 初始管理员密码不得写入Git或固定Seed；
- LOCAL密码、失败次数、锁定、重置必须进入安全审计。

### 4.2 角色与权限

目标：

- 默认Seed仅SUPER_ADMIN / PORTAL_ADMIN；
- MENU / PAGE / ACTION RBAC继续保留；
- 两默认角色首期按ALL_PORTAL；
- 历史细分管理员角色如数据库存在，必须通过Migration/数据迁移规则处理，不直接手工删除。

### 4.3 组织与字典

目标：

- 门户组织作为组织索引和LOCAL组织维护能力；
- GOV组织权威来源仍为闽政务；
- CITIZEN不强制组织；
- 补齐统一字典结构；
- 应用分类、公告类型、组织类型迁入统一字典；
- 旧`application_category`迁移期间保持兼容，数据迁移完成后再决定退役。

### 4.4 应用访问与账号映射

数据库目标需支持：

- application.access_mode：DIRECT / BIND / REQUEST；
- application_access_request；
- application_access_grant；
- application_user_mapping最新绑定状态和验证字段；
- UNBOUND / VERIFYING / REVIEWING / BOUND / FAILED / CONFLICT；
- match_method；
- verification_method；
- verification_status；
- risk_level；
- external_account_status；
- reviewed_by / reviewed_at；
- verified_at；
- conflict_reason；
- application_id + external_user_id有效BOUND唯一约束。

密码、OTP、Token不得进入映射表、验证证据、日志或审计详情。

### 4.5 todo_item字段收敛

最新需求确认门户待办不承接来源系统内部SLA、优先级、版本控制和独立终态时间。

0.3.0-B删除：

- `priority`；
- `source_revision`；
- `due_at`；
- `terminal_at`。

TODO状态由历史：

```text
PENDING / COMPLETED / WITHDRAWN / EXPIRED
```

收敛为：

```text
PENDING / COMPLETED / WITHDRAWN
```

并同步：

- 删除依赖`terminal_at`的CHECK；
- 不再计算逾期；
- 不再接收截止时间；
- 不再要求来源版本；
- 保留`application_id + source_todo_id`识别来源事项；
- 事件幂等继续使用`application_id + kind + event_id`；
- 如终态留存需要时间依据，使用状态更新后的`updated_at`。

当前`schema.sql`、001/002/003和P3已验收数据库仍保持原样，直到B阶段真正执行新Migration。

### 4.6 公告

目标补齐/复核：

- SCHEDULED；
- publish_mode；
- scheduled_publish_at；
- submitted_at / submitted_by（如最终实现继续需要）；
- effective_end为空表示永久有效；
- 当前撤回、失效、删除与留存策略所需字段。

### 4.7 审计

目标至少支持：

- userType；
- identitySource；
- loginSource；
- loginMethod；
- module；
- page；
- action；
- application；
- requestId；
- errorCode；
- ip；
- client。

异常日志如采用结构化处置字段，再补：

- resolved_by；
- resolved_at；
- resolution_note。

### 4.8 历史短信及上层公共服务预留

P3结构中存在`sms_*`相关表和`sms.*`配置，但当前产品口径已经调整为：

> 二维码、验证码、短信等公共服务优先复用上层平台，门户不重复建设独立短信平台或费用统计。

B阶段统一复核：

- `sms_channel`；
- `sms_template`；
- `sms_application`及其它`sms_*`表；
- `sms.max_retries`等配置；
- `auth.qr_ttl_seconds`；
- `auth.otp_ttl_seconds`。

处理要求：

1. 有正式上层接口方案后再确定保留、改造或删除；
2. 不恢复短信费用统计；
3. 不建立独立“短信管理员”默认角色；
4. A阶段不提前删表或删配置；
5. 删除动作必须进入正式Migration并有数据影响分析。

## 5. DATABASE Provider的过渡状态

当前`server/repository.mjs`已经具备DATABASE模式，但仍保留：

```text
system_config.id = P4RUN_STATE
```

作为整体运行状态JSON快照，并通过`mirrorSql()`向部分业务表同步数据。

因此它仍属于P4/B阶段过渡实现，不应作为最终生产数据架构。

0.3.0-B/C目标：

```text
PostgreSQL业务表
        ↓
   Repository
        ↓
     Service
        ↓
       API
```

正式Provider应直接围绕业务表、事务和约束工作，不再以P4RUN_STATE整包JSON作为业务真相源。

## 6. B阶段执行顺序

建议顺序：

1. 备份/导出当前目标base/source/schema元数据与必要数据；
2. 读取P3当前实际结构，不只依据Git中的schema.sql；
3. 形成“当前字段 / 目标字段 / 动作 / 数据迁移 / 风险 / 回滚”的差异表；
4. 生成新的0.3.0-B Migration；
5. 在隔离环境验证；
6. 执行结构Migration；
7. 执行必要的数据迁移与Seed收敛；
8. 执行约束、反例、事务、幂等验证；
9. 回读NocoDB/PG实际结构；
10. 切换或改造Repository；
11. 执行完整自动测试；
12. 形成B阶段验收记录。

## 7. 每次数据库操作必须记录

至少记录：

- 日期；
- 执行者/环境；
- database/base/source/schema；
- Migration文件；
- Migration SHA256；
- 操作前快照；
- 实际执行SQL；
- 执行结果；
- 数据迁移结果；
- 结构回读；
- 约束验证；
- 回滚/恢复方法；
- 对应Git Commit。

未真正执行时只能标记：

> **数据库改造：未执行 / 待0.3.0-B统一处理**

## 8. 当前状态

截至2026-09-21：

- P3数据库历史验收：已完成；
- V20260920-03数据库差异设计：已有；
- 0.3.0-B Migration：未生成/未执行；
- 当前P3旧字段：保留；
- PostgreSQL/NocoDB清理：未执行；
- DATABASE正式Repository：未完成；
- 真实身份/SSO/TODO/MESSAGE联调：未开始。

因此后续任何文档不得把“数据库目标设计已明确”写成“最新数据库结构已完成”。
