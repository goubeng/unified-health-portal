# 本轮发现

## 2026-09-24 数据源与权限续查

- 当前可见业务路由均经 HTTP API 读取 `DATABASE` Repository；登录交互、外部账号核验与入口跳转仍按要求模拟。权限目录是代码字典，监控/接入状态为数据库里的本地演示配置，未联通第三方。
- 已识别数据源例外：切换用户列表过滤掉 LOCAL admin；管理首页异常数读取旧快照日志而非 `audit_event`；隐藏兼容资源 `identityMappings` 将状态硬编码 BOUND。
- 当前真实库较前一轮发生新变动：`MOCK_APP_3`、`MOCK_APP_24` 被设为 GOV-only、版本 2；`MOCK_ADMIN` 角色为 `ROLE_CONTENT`，不能再假设其有超级权限。用户已明确允许把 APP_3/24 适用范围恢复为原 Mock 的双端，但其它用户角色数据不能未经核对覆盖。
- 阶段初审：P4 有历史人工页面验收，但当前 DB 模式问题未清；P5 有 CRUD/迁移证据，尚缺最新多身份业务链路 Gate。不得把历史 PASS 或 `.project/project.yaml` 标签直接当作当前完成证明。
- 复查结论：上述 LOCAL admin 列表漏项、管理首页物理审计计数和隐藏身份映射硬编码均已修复。内容管理员的实际失败原因是管理页跨权限预加载应用目录，非公告权限丢失；逐资源按权限加载后，数据库 `ROLE_CONTENT` 用户已在浏览器进入公告管理且没有原“当前身份没有该权限范围”错误。
- 复查结论：旧待办/消息与授权冲突经全库备份后精确归档，USER_1 12/12 应用动作与原 Mock 一致；第三方 126 接入中 125 条旧占位受控恢复演示四态，1 条已有成功维护记录保留。物理接入表的 UNCONFIGURED 是真实未接通语义，运行态 `DEMO_FIXTURE` 是本地演示语义，二者不可混称。
- 浏览器监控页的进一步操作被平台用量审核阻断，未执行；数据库和服务层监控/入口状态一致性已验证，但不能把它补写成浏览器验收。P4/P5 Gate 的剩余页面与业务闭环证据仍待补齐。

## 2026-09-23 演示状态与性能排查中

- 只读比对发现当前数据库回读的 42 个应用均缺少 `accessMode/accountBindingMode/postGrantMode/accountOpeningMode/mockScenario`，当前 `createSeed()` 的 42 个应用均有；原 006 迁移从较旧的 `P4RUN_STATE` 补 `runtime_payload`，而旧快照没有这些新演示场景字段。这会使各应用访问/账号处理场景退回默认值。
- 授权相关记录并非全无：访问申请 7 条（含过期、撤回、驳回、通过、待审核）、授权 2 条、账号开通申请 3 条；映射 40 条（BOUND 32、FAILED 4、CONFLICT 4）。因此需修补应用场景配置，不能重建或覆盖已有授权状态。
- 本机经过 4010 代理实测 health 和匿名 session 各约 2.0 秒。当前 API 每个请求都完整读取数据库，PortalPage 首页一次发起多个读请求且 API 以队列串行处理，延迟叠加；具体修复方案仍在核对。
- 当前缺口主要是演示数据迁移遗漏，而非申请/授权表结构不足：应用场景配置可只补既有 `application.runtime_payload` 的缺失键；7/2/3 条申请/授权/开通申请和 40 条映射保留原有状态，不应重新初始化。
- 登录页的本地模拟管理员目标 `MOCK_LOCAL_ADMIN` 不在现库 4 个用户中；这不是密码认证问题，需单独补本地演示身份及关联，否则该入口始终被 API 视为不存在。
- 首屏性能修复采用进程内 1 秒只读快照，写请求强制读新状态并使快照失效；这能消除同页多次请求的重复加载，但冷读取仍要执行 6 次 Docker/psql，跨进程外部修改最多有 1 秒可见延迟。
- 补齐 42 应用场景后再按当前用户读业务状态，发现旧映射仍与 `createSeed()` 演示预期不同：公众用户 15 个应用的 DB `BOUND7/UNBOUND3/CONFLICT1/FAILED1/DIRECT2/REQUEST_PENDING1`，种子为 `BOUND5/UNBOUND5/CONFLICT1/FAILED1/DIRECT2/REQUEST_PENDING1`。APP_2–6/11/12 等关键场景有绑定/可进入与预期不一致，正在追溯映射来源；不能仅以场景字段 42/42 完整宣布所有授权状态恢复。
- 用户明确选定以原 Mock 场景为准。逐项查明 `MOCK_USER_1` 共 12 个应用动作不同：APP2–6、11、12 要从旧 BOUND 调回未绑定/失败/冲突；APP24、25、26、28、33 要恢复 BOUND。旧记录同时关联 scope、待办、消息与异常；已追加备份并执行仅增加归档结构的 010，尚未动这些业务记录。
- 进一步并行化 PostgreSQL 规范域读回后，真实冷读从约 2.1 秒降至 1.1–1.2 秒，同页 6 个读取整批约 1.1 秒；缓存命中的应用读取约 15 毫秒。未改变数据库写入或权限判定。

## 2026-09-23 最终本地持久化边界

- 默认本地启动已接入数据库；`dev:mock` 才是显式隔离演示模式。应用/申请/授权的 HTTP 写入和进程外 Repository 回读已验证，删除级联与测试数据清理也已验证。
- 组织、字典、角色等尚在逐实体 JSONB 兼容表，不应宣称完成最终关系模型。登录仍是模拟会话；上下游仅有接口契约，未作真实联调。

## 2026-09-23 续接持久化边界

- 006–008 分别补齐应用目录、待办消息、申请授权的业务表字段与读写链。009 对尚无专用表的门户本地对象使用逐条 JSONB 实体表，并保留顺序和稳定标识；它能保证演示数据跨进程保存，但不等于完成这些对象的最终关系模型。
- 应用删除采用软删除，保留历史记录的外键；页面集合会移除相关待办、消息、申请，Repository 在同一提交事务内清理这些关联记录。该级联需真实库写测确认。
- 登录仍为模拟会话。PUSH、SSO 及上游账号核验没有实际外部系统联调。
- 006–009 已在真实库按序执行两次且幂等：应用/分类 42/6、待办/消息/收件人 44/40/40 与迁移前一致，三个申请类表为 0；迁移未改变 `P4RUN_STATE.version=188` 或历史公告 9（活动 8、软删 1）/阅读回执 6。
- 修正后的 009 只标记旧快照中实际存在的资源，避免缺省域被错误声明为空；快照存在的 8 域共迁入 219 个逐实体记录。缺省域由独立 bootstrap 仅追加 createSeed 演示数据，最终 organizations/dictTypes/dictItems/mappingVerificationEvents 为 3/6/22/0，第二次执行无新增。
- 最终兼容实体表有 12 域、250 条记录，`(resource,runtime_id)` 无重复；实体域外键采用 `ON DELETE CASCADE`。这证明迁移与初始化结构正确，但尚不能替代其它业务的 HTTP 写入、进程重启读回和删除语义验收。
- 008 执行时三类申请在旧快照中没有可迁数据，因此最初空表是已核对的数据边界，不是迁移遗漏；表结构已有 runtime/request 唯一约束和 9 个业务外键。为保证页面有可演示样本，后续通过显式 `--seed-empty-requests` 门禁在“快照数组为空且物理表为空”时补入 7 条访问申请、2 条访问授权、3 条账号开通申请。
- 三类申请补种后的 runtime ID/request_no 均无重复，用户、应用及处理人关联无外键孤儿；第二次运行无新增。该显式参数用于修复空样本演示边界，不会对已有申请业务数据执行覆盖。
- 并行数据库 CRUD 记录测试曾将 `P4RUN_STATE.version` 推进至 192，并把三个原本缺省的快照键落为空数组；补种任务识别到前提变化后先停止确认，再使用显式门禁执行。补种本身未修改兼容快照，version 全程保持 192。

## 2026-09-23

- 项目已有 PostgreSQL/NocoDB 设计、32 表迁移与历史读回证据，但当前前端仍存在 Mock Provider；必须以当前源码和当前数据库实际结构重新核验，不能沿用旧阶段结论。
- 登录页按用户要求继续采用模拟方式，不纳入数据库用户认证改造。
- 通知公告是本轮首要 CRUD 闭环；上下游系统不做真实联调，只保留稳定接口边界与可演示状态。
- 公告 DTO 依赖 `publishMode/scheduledPublishAt/submitted*/withdrawn*/lastEdited*/attachments`，而旧 `announcement` 表和 `mirrorSql()` 只保存基础字段；`announcementReads` 和 `announcementTrash` 更只存在 JSON 快照中。
- 公告规范化持久化必须同时处理运行态 `MOCK_*` 与库内 `P4FIX_*` ID 的双向稳定映射，否则数据库重启回读后会破坏页面 ID、用户外键和乐观版本。
- 第一阶段采用 `announcement.runtime_id`/`announcement_attachment.runtime_id` 保留页面 DTO ID，物理主键仍沿用旧 `P4FIX_*` 口径；读回时显式恢复运行态 ID。
- 公告删除改为 `announcement.deleted_at/deleted_by/delete_reason` 软删除，因此活动公告与回收档案可从同一规范表重启恢复；附件随归档公告保留，已读回执在删除时按现有 Service 语义清理。
- 只读盘点已确认旧版物理删除后，`P4RUN_STATE.announcementTrash` 仍有1条历史归档，但规范化 `announcement` 无对应软删除行；005 必须在切换规范表读源前补入该记录，否则首次加载会丢失历史回收档案。
- 005 对 legacy `announcementTrash` 采用“仅补缺失行”策略：物理ID或 `runtime_id` 任一已存在就跳过，并以无目标 `ON CONFLICT DO NOTHING` 兜底，避免历史快照覆盖数据库的更新版本。
- 当前附件 DTO 沿用 JSON 对象/data URL，真实物理列 `announcement_attachment.attachment` 为 text；可满足本地演示与 CRUD 闭环，但不是生产文件存储方案。后续对位 NocoDB/对象存储时需保留当前 DTO 而替换附件内容载体。
- 默认 `npm run dev` 使用内存 Repository；只有 `npm run api:db` 才进入数据库模式，验收必须明确区分。
- 数据库模式仍保留 `P4RUN_STATE` 作为兼容快照和全局乐观版本；公告域由规范公告/附件/阅读回执表覆盖，006–009 又将应用、消息、待办、申请及剩余本地域切换为对应业务表或逐实体兼容表。
- 005 已补齐公告定时发布、提交/撤回/最后编辑、软删除、附件 runtime ID 和用户已读回执，旧镜像丢字段问题在公告第一阶段已收口。
- 公告状态最稳语义：持久化 DRAFT/PUBLISHED/WITHDRAWN，SCHEDULED 与 EXPIRED 保持派生，避免两套状态源。

## 2026-09-23 当前真实数据库只读盘点

- 本次仅通过现有 Repository 同源入口 `docker exec -i -u postgres postgres14 psql -U admin -d nocodb_data` 执行 `SELECT` 元数据与聚合查询；未执行 Migration、Seed、DDL 或 DML。
- 当前数据库为 `nocodb_data`，连接用户 `admin`，PostgreSQL `14.20 (Debian 14.20-1.pgdg13+1)`；schema `pb3gir75kkooyea` 存在，包含 32 张基础表。
- 001 效果可识别为 32 张基线业务表；003 的 `p3_%` 约束共 199 项。002 文件中的原始索引名 `uq_mapping_bound_account` 不存在，但库内存在等价的部分唯一索引 `p3i_application_user_mapping_fab186218987(application_id, external_user_id) WHERE status='BOUND'`，后续迁移判断必须按语义而非仅按原始名称。
- 004 效果已可识别：`sso_config.enabled/remark`、`push_integration_config.enabled/remark` 均存在，`todo_item.priority` 注释为 legacy compatibility 字段。
- 公告聚合当前行数：`announcement=8`、`announcement_org_scope=2`、`announcement_attachment=0`；公告状态为 DRAFT 3、PUBLISHED 4、WITHDRAWN 1，8 条公告 ID 全部为 `P4FIX_%`。
- 当前公告三张表仍只有 P3 基础列及 NocoDB 物理辅助列，尚无 `publish_mode/scheduled_publish_at/submitted*/withdrawn*/last_edited*`；附件物理列 `attachment` 当前为 text，迁移前不能只按 Git 中的 jsonb 声明推断真实类型。
- `system_config.id='P4RUN_STATE'` 存在，`version=180`、状态 CONFIGURED、value 为 JSON object，最近更新时间为 `2026-09-20 09:40:21.778078+00`。
- `P4RUN_STATE` 内仍保存 apps 42、todos 44、messages 40、announcements 8、announcementReads 6、announcementTrash 1 等运行态数组，证明数据库模式仍以整包 JSON 承载核心业务状态。
- 32 表合计存在 467 条 `P4FIX_%` 记录，分布于 23 张表；主要包括 push_integration_config 84、sso_config 42、application 42、todo_item 44、message 40、message_recipient 40、application_user_mapping 40 等。数据库迁移与真实 CRUD 验收前必须先备份并分类这些演示镜像数据，不能直接视为生产基线或直接清空。

## 2026-09-23 005 迁移后事实

- 005 已在 `nocodb_data.pb3gir75kkooyea` 成功执行两次，第二次重复执行未产生重复公告、附件或阅读回执，迁移具备当前数据集下的幂等证据。
- 公告规范表现有活动 8 行、软删除归档 1 行；9 条记录的 `runtime_id` 均非空且唯一，旧 `MOCK_*` 页面标识与 `P4FIX_*` 物理标识已建立稳定对应。
- 唯一历史删除草稿已从 `P4RUN_STATE.announcementTrash` 补入规范表，且快照本身 version/updated_at 未改变；这证明迁移只读取兼容快照并写公告域，没有回写整包运行状态。
- 公告附件仍为 0，阅读回执已从快照导入 6 条。附件真实物理列仍为 text，当前迁移因无附件没有触发 JSON 附件载体兼容验证；后续第一次真实附件 CRUD 必须单独做写入和回读验收。
- 迁移前 5 表 custom-format 备份已保存于 `database/backups/unified-health-portal-pre005-20260923-091354.dump` 并通过归档目录校验；恢复属于破坏性操作，本轮未执行。

## 2026-09-23 真实 API CRUD 与清理结论

- DATABASE 健康检查、管理员模拟登录、HTTP 创建草稿和列表读取均成功；草稿 runtime ID 为 `MOCK_cb1b1812-1e69-4b00-9e33-22a74864bf22`、初始 version 1。
- API 进程停止并重启后仍能读回同一 ID、标题与正文，证明公告规范表已成为可跨进程恢复的数据来源，而非只依赖 Node 进程内状态。
- 后续执行者已确认 API 编辑+SQL 回读、API 删除+活动不可见/软删可查完成；由于步骤 4/5 详细响应体未留存，只能确认业务与数据库结果，不能补写具体 HTTP 状态码或完整响应字段。
- 测试清理前 `P4RUN_STATE.version=187`，存在物理测试公告 1、关联审计 3、JSON 删除归档 1；精确清理后 version 188，测试 ID/标题在公告、附件、回执、审计及两个 JSON 数组中均为 0。
- 清理没有影响历史数据：公告仍为 9 条（活动 8、软删除 1），阅读回执仍为 6 条；4011 已无监听进程。
- 因接续复核时目标已经清理完毕，本次没有重复执行 DELETE；这避免了在目标不存在时扩大清理范围。
- 当前阶段已覆盖通知公告第一阶段真实 API CRUD，以及应用、消息、待办、申请和剩余本地域的真实数据库迁移/初始化。其它业务仍需补真实 API 写入、进程重启读回和删除语义验收；上下游真实对接继续只保留接口边界。
