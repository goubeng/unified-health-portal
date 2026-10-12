# 本轮发现

## 2026-09-24 当前版本浏览器 Gate 与审计字段兼容

- 字段不全不是表格列缺失，而是 `audit_event` 物理记录只返回通用列，前端五类列表/详情要求的专用字段既未从 `details` 解出，也未由已知的用户/应用规范资料关联补齐。已在数据库 DTO 按 `details` 原值优先映射；仅 20 条与原 Mock 种子精确匹配的 `P4FIX_LOG_*` 样本经单表备份和版本/摘要守卫回填。其他历史记录中不可追溯的 IP、客户端、耗时仍为未采集，页面以 `-` 表示。
- 新事件写入实际请求 IP/客户端/耗时、模拟登录方式及业务操作页/动作；后台关联的用户和应用原始 JSON 不返回前端。浏览器在数据库模式逐页检查五类日志：登录、访问、操作、接口和异常的列与详情均有对应数据；错误样本覆盖待处理和已处理。`npm test` 229/229、构建及原有授权/接入场景只读校验通过。此项是本地演示日志的字段收口，不代表已接入真实上下游或历史缺失指标被恢复。
- 最新浏览器回归发现所有审计日志页曾显示通用“服务或数据库暂不可用”；原先仅查页面标题会漏掉正文加载失败。根因是当前 NocoDB 原生 `audit_event.details` 实际为 `text`，而数据库 Repository 对它直接使用 PostgreSQL `->>` JSON 运算符；真实库只读执行报 `operator does not exist: text ->> unknown`。管理首页异常数量查询不读取 details，所以没有暴露同一问题。
- Repository 已在读取审计明细时先显式转 `jsonb` 再提取字段，异常处理镜像也在实际 `text` 列上完成 JSON 合并后转回 text。此修复不修改数据库字段或现有审计记录。重启本项目 4011 API 后，五类日志页面均正常加载，异常日志 37 条；另四类分别为登录 204、访问 12、操作 79、接口 7 条。该计数会随模拟登录/操作审计继续变化。
- 前端 4010 由原共同启动器与 API 关联；重启 API 时原 Vite 进程随之退出，已分别启动本项目 4010 前端和 4011 DATABASE API，两个端口均恢复，旧浏览器连接错误页不能用于现行验证。
- 公告页面已完成草稿新增、刷新读回、编辑、刷新读回及经用户确认的删除清理；原 8 条活动公告仍在。公众应用失败/冲突、未配置待办、申请多态和管理员监控/权限页面已实测。尚未进行发布/撤回、附件、跨身份完整申请审批与消息操作的浏览器写入闭环，P4/P5 不因本轮局部通过而自动签署。

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
# 2026-09-28 当前功能与阶段复核

- 待核：密码维护功能与前次“去掉演示提示”的修改是否已经完整落地。
- 已发现：`src/App.vue` 和 `src/components/portal/UserManagement.vue` 中密码弹窗仍有“演示环境”警告，成功提示仍包含“演示/真实登录凭证未更新”；前次去提示要求未完成。
- 本轮已清理这些提示及本地账号表单/详情的同类说明；外部身份管理来源提示保留。此前 `changeLocalPassword` 没有解除 `mustChangePassword`，本轮已修复。
- 登录仍按用户确认的 Mock 策略运行；当前密码只校验填写，新密码不作为可登录凭证保存。因此本轮确认的是密码维护表单、业务状态和审计安全，不是实际凭证更新或认证安全。
- 现有 Gate 文档 `docs/02-开发/02-评审/当前P4-P5阶段Gate复核.md` 记载 9 月 24 日 P4 PASS / P5 演示版冻结；`docs/README.md:59`、`.project/project.yaml`、`.project/PROJECT_PROFILE.md` 与之不一致，属于阶段档案同步欠账，不能以任一标签代替证据。
- 9 月 28 日 235/235 自动化测试和构建通过、服务为 DATABASE 模式；本轮浏览器权限检查失败，尚无最新页面人工复核或现场密码状态写入/回读证据。历史公告 CRUD/刷新持久化、业务链路和数据库模式验收证据可沿用，但不能扩展解释为全部生产化。
- 用户补充边界后，密码维护状态入库回读不再是当前 Gate 条件；仍须确认其他业务真实数据库持久化、演示场景、接口和配置入口的现有证据。前条“密码状态现场写入/回读未验”仅是生产扩展证据缺口，不应误判为本阶段阻断。
- 只读源码复核：默认 `npm run dev` 使用 DATABASE API，显式 `dev:mock` 才走内存；SSO/TODO/MESSAGE 有配置页、契约和本地接收入口，但非真实联调。admin 切换、禁停用/去超级角色、五类日志映射、状态规则均有代码与测试；当前数据库样本逐项现场读回仍不能由静态测试代替。
- 9 月 28 日文档已把过时 A3/MEMORY_A 阶段标签与 P4/P5 Gate 对齐；旧 B/C 生产级目标保留为历史计划，不再阻塞本地演示版收口。阶段结果是可以进入下一阶段的范围定义，不等于旧 B/C 完成或已具备生产上线条件。

## 2026-09-28 公众门户首次二级页故障

- 待定位：首次进入失败而刷新后恢复，需分别核查二级页的客户端路由与首屏数据初始化；管理端样式差异可能是预期分端布局，不应未经证据直接统一样式。
- 公众首页 `/portal/home` 与二级页 `/portal/*` 使用不同组件层级。待办标题 Teleport 在 `PortalPage.vue` 首次渲染时指向布局条件渲染的 `#page-header-extra`；待办被纳入 Banner 后，该目标的首次挂载时序成为可复现的结构性风险，已使用 Vue 3.5 `defer` 延迟定位。
- `main.js` 在 mount 前完成 session 初始化，路由守卫不是明确根因。公众身份的 `can(application:view)` 为 false，不会读取 categories，故未改无关数据请求。若消息/公告/应用等其它二级页也失败，仍需首跳 URL、控制台或 API 响应才能定位，不能用待办修复覆盖全部症状。
- 运行入口曾未启动；HTTP 502 来源为本机代理，直连无监听。标准数据库模式启动后健康检查正常。浏览器安全权限检查失败，禁止绕过，现场首次导航仍未验证。

## 2026-09-28 二级页 Banner 尺寸

- 我的申请与待办任务使用 `banner-todos.png`，应用中心使用 `banner-apps.png`，消息中心与通知公告各有独立图片；四图均 2172×724px，素材比例 3:1。
- 页面 Banner 共用同一容器，桌面最大宽 1440px、最小高 132px，此时显示区域约 10.91:1；≤760px 最小高 110px。宽度随视口变化且内容可能撑高，因此页面显示比例不是固定 3:1。背景用 cover 和 center 48% 裁切。

## 2026-09-28 Banner 自适应修正

- 用户选择等比铺满并允许裁切。原 `cover` 已满足铺满，但 `center 48%` 不严格居中、容器仅有最小高度；本轮只对公众二级页专用规则加 `aspect-ratio:10 / 1`、`center center`，使用 grid 让内容区域随容器伸展。桌面最高宽 1440px 时目标高约 144px，窄屏和多行文字仍由原最小高度/内容决定。
- 用户已有未提交的 `banner-todos.png` 修改，本轮保留；未改其它图片或管理端。新增 CSS 回归通过、构建通过；既有 6 项非 Banner 静态断言失败未扩改。浏览器权限检查仍失败，故视觉效果尚不能宣称现场通过。

## 2026-09-28 业务状态与待办类型字典化

- 待核：字典现有类型/条目、读写路径和业务状态的来源。原则上业务编码与状态迁移保持稳定，字典只配置可展示文案、顺序及允许扩展的类型，避免管理员改文案导致流程失效。
- 2026-09-29 当前库只读核对：`portal_runtime_entity` 中 `dictTypes=6`、`dictItems=22`；活动待办 `business_type` 均为“服务事项”，状态分别为 PENDING 25、COMPLETED 4、WITHDRAWN 4、EXPIRED 4。`EXPIRED` 不在当前推送协议 `terminalStatuses` 中，需保留历史显示但不能因字典化开放新推送状态。
- 现有字典实体按 `portal_runtime_entity` 的 JSON payload 逐项持久化，旧库不会因修改 seed 自动增项；新增常用类型需要幂等补种及读回验证，不能覆盖管理员已有标签或删除历史条目。
- 当前选定 10 类新增目录：待办状态/任务类型、消息类型/阅读状态、应用申请/账号开通/账号关联状态、公告状态/适用范围/发布方式。`todo_status.EXPIRED` 与公告派生状态只作禁用的历史/展示项；可执行状态集继续由业务规则控制。现库独立 SQL 回查 `dictTypes=16`、`dictItems=58`，`EXPIRED|DISABLED`，再次增量预览为零新增。
- 待办任务类型原由 `pushTodo` 固定为“服务事项”，仅增加字典会形成无法演示其它类型的空配置。继续补可选类型输入、字典合法性校验和默认值兼容；不改变 TODO 现行三态规则。

## 2026-09-29 管理端头部与个人信息框架修正

- 待核：管理与公众头部是否共用组件；管理个人信息跳入公众布局是入口链接错误、路由 meta 错误还是页面组件按资源渲染错误。移除的仅是管理头部切换入口，不应删除管理权限或公众侧已有的演示切换能力。
- 已定位：管理工作台 `App.vue` 顶部直接渲染用户 `t-select`；用户菜单的 `openProfile()` 固定跳 `/portal/profile`。管理个人信息原本无 `/admin/profile` 路由，故落入公众布局；新增隐藏管理路由可复用 `PortalPage`/`PersonalProfile` 并保留管理 shell，不必改个人信息数据逻辑。
- 公众首页与二级页头部独立在 `PortalHomePreview.vue`、`PortalPreviewLayout.vue`，原使用通知铃图标；管理头部是 `MailIcon`。只统一这两处消息入口图标，保留通知公告的独立图标。
- LOCAL 管理账号的 `userType` 为空；仅增加管理路由时，个人信息组件会出现空身份标签及不适用的外部平台维护提示。已对 `authType==='LOCAL'` 分支显示“本地管理账号/账号类型”和本地维护说明，公众身份资料展示不变。
- 浏览器验收入口 Tabbit CLI 默认运行被系统拒绝，经审批的稳定启动器诊断仍失败；遵守技能排障边界，不读取私有端点或切换后端。当前证据限源码、测试和构建，不能宣称实际页面视觉验收。

## 2026-09-29 子系统账号开通申请详情字段调整

- 待核：`createdAt` 是否仅为记录创建技术时间，`submittedAt` 是否独立业务申请时间；处理人是否已有 `handledBy` 或审计事件引用，且数据库规范表是否真实存储。详情展示不能从当前登录用户臆造历史处理人。
- 已核对：新提交时服务在同一 `now` 写入 `createdAt` 和 `submittedAt`，当前库 3 条两者相等；前者是记录建立、后者是业务提交，语义独立，未来草稿/导入可不同。详情只展示用户要求的“申请时间”。
- 规范表 `account_opening_request` 已有 `handled_by`（引用 unified_user）、`handled_at`、`handle_note`，Repository 写入/读回均存在；无需新增物理列。当前库待处理的处理人为空，处理中及已完成处理人均可解析为“周明”。`handledAt` 仅在完成时写，处理中不应把更新时间冒充处理时间。
- 实际详情已按申请区三列、两列、两列、通栏、通栏及处理区两列、通栏布局；仅显示 `submittedAt` 而非技术创建时间，状态用 `account_opening_status` 字典标签。管理与公众入口均读取 `handledByName`，由稳定 `handledBy` ID 解析，未知处理人不臆造姓名。

## 2026-09-29 列表表头与开通申请展示调整

- 待核：开通详情字段顺序、列表列来源、表头全局样式，以及目标模块排序是列级配置还是公共组件行为。只改变 UI，不删除数据字段或排序能力以外的业务逻辑。
- 源码盘点：项目列表均使用 TDesign `t-table`（公众端列表也在内），已有全局 `.t-table th` 规则，可从表头范围统一控制不换行。开通列表列由 `PortalPage.vue` 的 `fieldMap.accountOpeningRequests` 配置；用户、角色、组织排序均由各自列的 `sorter` 控制。详情字段是独立配置，列表移除字段不影响详情持有的数据。
- 再核：公众“我的申请”内开通申请也使用独立 `MyApplications.vue` 的 `openingColumns`，含“处理说明”列；本轮统一从管理和公众两个开通申请列表移除，应用访问申请的“审核意见”不受影响。
- 已核：角色“角色说明”列原无 `sorter`，无需改动；组织管理表头排序入口与相关状态已整体移除，但保留组织树原本按 `sortOrder`/名称的稳定默认顺序。表头统一只约束 TDesign `th` 及内部标题元素 `white-space:nowrap`，正文单元格不受影响；公众卡片式列表没有表头。

## 2026-09-29 管理首页接入异常应用去重

- 初查：顶部卡片在 `PortalPage.vue` 绑定 `overview.abnormalServiceCount`，文案明确为 SSO/TODO/MESSAGE 三类异常接入项总数。用户要按应用去重并改名；需核对 `adminHome` 统计源后定义新字段或调整既有字段，避免误改右侧按审计异常行展示的列表。
- 服务现状：`src/services/portal.js` 的 `adminHome` 由 `monitorProfiles(d)` 得到各应用服务状态，`abnormalServiceCount` 把三种能力的异常个数直接相加。目标可新增 `abnormalApplicationCount`，按监控行中任一能力为 `ABNORMAL` 计算一次；保留原字段供可能的旧调用方使用。右侧异常列表和 `openErrorCount` 是另一条数据链，不在本轮变更范围。
- 用户纠偏后核对：管理端应用列表 `adminApps` 走 `allApps()`→`decorate(d,a)`，直接返回 `aggregateRuntimeStatus`；其规则是应用停用优先 `DISABLED`，否则三类状态存在 `ABNORMAL` 才为异常。尽管当前规则与“任一监控能力异常”通常等价，指标仍应直接复用列表 DTO 的综合状态，避免日后两套规则漂移。
- 已用 `allApps().filter(app=>app.aggregateRuntimeStatus==='ABNORMAL').length` 生成新指标，测试对照 `adminApps` 返回值：同一应用两项异常只计 1，另一异常应用再计 1，停用应用即使底层能力异常也不计入。原三类服务异常项数及日志异常行统计均未改。

## 2026-09-29 应用综合状态与运行监控一致性及正常样本

- 待核：真实数据库中各状态数量和应用/监控是否不一致；源码初查两处均引用 `integrationState(d,app,kind)`，但展示聚合和异常数据可能存在不同来源或优先级。必须以同一真实库快照读回确认，不以 Mock 推断现场。
- 只读现库版本 492：42 个活动应用，ABNORMAL 30 / NORMAL 10 / DISABLED 2。126 条集成运行实体与运行态快照 JSON 一致；12 条历史监控样本仅属 APP_1~4，采样于 9/19，早于配置更新 9/23，当前不覆盖配置。`application.runtime_status` 物理列并非综合状态来源，不可直接改该列来造正常场景。
- 两页面关系：管理应用列表 `decorate` 和运行监控 `monitorProfiles` 都调用同一个 `integrationState`；综合状态按停用优先、任一异常、任一正常、全停用、其余未配置的次序聚合。监控详情过去在 `configStatus` 未配置时把运行状态遮盖为“-”，即使列表有值；该显示缺陷已修复，配置状态仍独立展示。
- APP_18/19/21 目标接入分别为 TODO/SSO/MESSAGE，应用自身未人工编辑，目标集成版本 2 且为 DEMO_FIXTURE，相关业务记录与 9/20 后审计为空；其余状态和历史异常场景应保留。预计调整后三类综合分布为异常 27、正常 13、停用 2，须以真实写后读回为准。
- 实际写后读回符合预期：APP_18 三态 SSO/TODO/MESSAGE 为 NORMAL/NORMAL/DISABLED，APP_19 为 NORMAL/DISABLED/UNCONFIGURED，APP_21 为 UNCONFIGURED/NORMAL/NORMAL，三者应用综合均 NORMAL；总量 ABNORMAL 27 / NORMAL 13 / DISABLED 2。`sso_config`/`push_integration_config.status` 属配置态，保留 UNCONFIGURED，未用它冒充运行态或已联调。
- 三个应用名称读回分别为 APP_18“福建省互联网医院监管平台”、APP_19“省医改效果监测管理系统”、APP_21“福建省公立医院绩效考核系统”。

## 2026-09-29 应用详情启用状态与编辑字段

- 初查应用详情由 `RecordDetail.vue` 的 `appDetails` 和连接信息独立行渲染；应用编辑表单由 `PortalPage.vue` 的 `saveApp` 字段列表驱动。需核对数据字段是否为布尔 `enabled`、连接项是否为字符串 `enabled`，两者不能混用。
- 已核：应用列表 DTO 的 `enabled` 为布尔；连接信息行把接入配置 `ENABLED`/`DISABLED` 映射成“启用/停用/未配置”。详情 `DetailGrid` 支持具名插槽，可只对应用启用状态使用标签。编辑表单为三列，访问模式目前位于第二行第 2 列，紧接新增状态可落在同一行第 3 列。
- 关键保存链：`saveApp` 原先不读取 `p.enabled`，只有 `setAppStatus` 会写入；增加表单字段必须同步服务保存，并在启停状态变化时校验 `application:enable` 权限，防止通过编辑权限绕过独立启停授权。旧调用未传 enabled 时需兼容原有行为。
- 最终实现：新建表单默认停用，编辑从当前行带入布尔状态；仅启停有变化时服务要求 `application:enable`，并同步 `enabled` 与 `status`。详情连接项缺失时显示“未配置”标签；字典 `enable_status` 对启用/停用提供中文展示。服务测试证明编辑、权限拒绝、非法值及旧调用兼容，仓储映射原有测试覆盖 enabled 规范字段。

## 2026-09-29 编辑启停开关与综合运行状态说明

- 源码初查：`aggregateRuntimeStatus` 对启用应用按“三项任一 ABNORMAL→异常；否则任一 NORMAL→正常；全停用→停用；其余→未配置”聚合。截图中的接入配置状态/启用状态不是运行态，必须读回 APP_4 的 SSO/TODO/MESSAGE 有效运行状态，才能判断当前为何为正常；不先改聚合规则。
- 新进程真实库 v499 读回截图应用 WJ_APP_04/APP_4：应用启用且访问模式 BIND，SSO 实际 DISABLED、TODO 实际 UNCONFIGURED、MESSAGE 实际 NORMAL，因此按现规则显示综合 NORMAL。SSO 当前不可用却综合“正常”反映的是“有一项正常且无异常”的聚合规则，不代表该应用三项全正常或可成功进入；改变综合语义需另定必需能力规则。
- 编辑表单仅将启停字段从下拉改成布尔开关，保留 `application:enable` 禁用边界及已有保存逻辑；定向测试 3/3 与生产构建通过。既有详情静态断言因共用插槽条件更新而失配，与本轮开关无关；现场视觉未验收。

## 2026-09-30 接入异常与恢复日志现状核对

- 待核：`monitor_status` 是否仅存当前/最后成功失败，`audit_event` 是否为动作审计而非每次检测；管理端“日志审计”与运行监控详情是否能展示异常→恢复的逐次历史。
- 源码与现库只读核对：`monitor_status` 按 `(target_key,service_type)` 唯一，一项服务只留一条快照及最近成功/失败等字段；现库 13 条。运行监控页面展示当前状态和最近检测/成功/失败，不提供逐次历史。`audit_event` 现有 17 条 ERROR，其中 4 条旧演示事件（含 APP_4 的“上游服务响应超时”且人工处理标记 RESOLVED），其余为 `openTodo`/`enterApp`/`saveApp`/`setAppStatus` 等操作失败。RESOLVED 不等于服务恢复 NORMAL；没有自动写入 ABNORMAL→NORMAL 的状态迁移事件。

## 2026-09-30 接入状态历史实现核查

- 监控有效状态由配置启停、应用启停与较新的 `monitorSamples` 合成；只有 `monitor_status` 当前快照，不能用于逐次历史。现有 API 服务命令均不提供检测器写入 NORMAL/ABNORMAL 的入口，`saveIntegration` 只重置为 UNCONFIGURED；后续接口需将一次观测与状态迁移分开，重复相同状态不产生迁移。
- 采用独立追加型物理表保存应用/能力/前后状态/发生时间/原因/来源；读取按时间倒序，人工 `audit_event.resolution_status=RESOLVED` 与监控恢复完全隔离。迁移只建空表，不凭历史快照杜撰过往异常恢复。
- `recordMonitorObservation` 受 `monitor:check` 权限保护，只接受已启用应用上 `configStatus=CONFIGURED` 且接入项启用的 SSO/TODO/MESSAGE，检测结果仅 NORMAL/ABNORMAL；异常原因必填。重复同态刷新最近检测及成功/失败时间，但不会新增迁移历史；ABNORMAL→NORMAL 才是恢复事件。物理 `monitor_status` 保留上次成功/失败时刻，当前恢复后清空 `last_error`。
- 选定 APP_18 的 TODO（福建省互联网医院监管平台）作为历史演示样本：当前已配置、启用、NORMAL，待办/消息/映射/申请/授权/账号开通/访问/回执八类业务关系全为 0；不扰动有依赖的应用。记录两次真实状态迁移后恢复 NORMAL，历史保留供页面演示。

## 2026-09-30 必需能力综合状态

- `enterApp` 与 `openTodo` 对所有访问模式都要求 SSO 运行态 NORMAL，故 SSO 恒为必需；TODO/MESSAGE 仅在接入配置 `enabled=ENABLED` 时纳入必需能力。应用停用仍优先显示 DISABLED；必需项按 ABNORMAL、DISABLED、UNCONFIGURED 优先级判定，全部 NORMAL 才综合 NORMAL。
- 旧规则只要三项中任一 NORMAL 且无 ABNORMAL 就显示 NORMAL，导致 APP_4 的 SSO DISABLED、TODO UNCONFIGURED、MESSAGE NORMAL 被误判为 NORMAL。新规则将其显示为 DISABLED，不把停用能力伪装成异常。
## 2026-10-01 文档与代码一致性核查

- 默认 `npm run dev` 是 DATABASE，显式 `dev:mock` 才是内存数据；原 A/A3 Mock 启动和 005～010 待迁移的材料属于历史快照，若直接按其“当前”措辞执行会误判现行系统。
- 当前持久化并非完全规范化：005～011 覆盖部分业务表与接入历史；`portal_runtime_entity`、`P4RUN_STATE` 仍存在。独立 `portal_admin_user`/真实凭证、正式 `/api/integration/v1`、一次性 SSO Ticket 和自动健康检测属目标设计，不是已接通能力。
- 2026-10-01 复跑全量测试为 345 项中 316 通过、29 失败，生产构建通过；旧 P4/P5 的 231/231、235/235 及人工验收仅对应原日期。当前代码未做新的浏览器现场复验，不能延用旧“最新代码已冻结”结论。
- 运行监控页面仍有“本地演示样本”提示，与此前用户要求移除演示提示不完全一致；这是代码待修项，文档核查未擅改页面。详见 `docs/02-开发/02-评审/代码与文档一致性核查_20261001.md`。

## 2026-10-01 全目录补充核查

- `docs/` 原有 66 个文件，新增 `02-开发/04-过程记录/README.md` 后为 67 个；已按需求、设计、评审、计划、过程记录、交付和根索引逐文件列账。历史签收与未来规范不应改写为现行实现。
- 旧过程记录中的 6 个模糊入口已补历史边界，跨目录 6 个错误相对链接已修复。原始需求引用的 `图片和附件/image1.jpeg`、`图片和附件/image2.jpeg`、`图片和附件/image3.png` 在仓库内缺失，无法复原其内容。
- 文档更新只解决描述与代码证据的对应关系，不能替代尚未完成的真实 42 子系统资料、29 项失败测试及浏览器现场复验。
## 2026-10-08 管理首页趋势日期（修复前诊断）

- `src/components/portal/AdminTrendChart.vue` 的“近 7 天/30 天”按访问/API 两类传入日志中最新 `createdAt` 定结束日期；只有完全没有有效时间戳时才按今天。故无新日志时图停在历史末日，非当前自然日滚动窗口。
- 首页 `src/views/PortalPage.vue` 读取 `logs:access` 和 `logs:api`；DATABASE 模式 `server/api.mjs` 通过 `server/repository.mjs` 的 `audit_event` 查询提供记录，按 `created_at` 倒序且每类最多 1000 条。图表还缺跨北京时间午夜的主动重算；未使用的 `auditTrends` 服务分支有同类日期锚定问题。
- 首页“今日访问量/接口调用量”使用运行态 `d.logs` 计算，而趋势图在 DATABASE 模式下通过 `audit_event` 读取；两处来源不同，存在卡片与趋势口径不一致的风险。
- 修复前未能确认实时数据库最新记录：本地数据库服务不可达。当时确认须按北京时间今日滚动、补零并规避日志列表上限；实施结果见下节。

## 2026-10-08 滚动趋势修复结果

- 管理首页趋势改走 `auditTrends`，图表按北京时间今日（含今日）显示最近 7/30 个自然日，按日计数并补零；跨午夜触发首页重读。
- DATABASE 模式逐日统计直接聚合 `audit_event`，今日卡片也取同一聚合末日计数；原 `logs:*` 列表仍用于日志页面，但其 1000 条限制不影响首页趋势。
- 新增 6 项窗口及服务回归后，全量 351 项 322 通过、29 失败；失败数与上次相同，属于既存 UI/静态断言。构建通过，但实时数据库及浏览器现场未验证。

## 2026-10-08 登录记录与门户访问量

- 登录/切换/退出在 `server/api.mjs` 均记 `LOGIN`，日志页 `logs:login` 包含 `LOGIN` 与 `AUTH`；首页今日访问与趋势只聚合 `audit_event.kind='ACCESS'`。普通登录和打开门户首页没有 ACCESS 事件。
- ACCESS 是成功执行 `enterApp` 或 `openTodo` 的应用/待办入口审计；失败命令记 ERROR。现行“门户访问量”实际更接近应用入口成功访问次数，命名与用户对门户入站/页面浏览量的理解存在差异。
- 目前本机 API 4011 无监听且 Docker 数据库入口不可访问，无法断言物理库当天 ACCESS 真实条数。若改口径，不能直接把全部 LOGIN 行相加，因为它还包含身份切换与退出；应单独定义成功入站或页面浏览事件并与应用访问区分。
- 补充接口调用日志截图显示最近 1 条为 2026-09-24，另 4 条为 2026-09-18。2026-10-08 的近 7 天窗口为 10-02～10-08，这些行均不应计入；近 30 天应包含它们。使用现行 `normalizeChinaDayCounts` 对截图日期模拟，7 天空、30 天为 9-18=4、9-24=1；这不是实时数据库读回。

## 2026-10-09 公众端手机网页规划依据

- `src/router.js`、`src/config/pages.js` 已有公众端首页、待办、全部应用、消息中心和个人中心路由。
- `src/services/runtime.js` 提供统一会话、读取与命令入口；`src/services/portal.js` 处理公众应用范围及用户数据过滤。移动端需沿用现有规则。
- 当前依赖为桌面 `tdesign-vue-next`；窄屏布局仍有桌面侧栏，需新增移动壳与 `tdesign-mobile-vue` 组件。
- 现有登录为演示会话，外部系统接通状态和数据库持久化须分别验收；不能把手机网页展示当作正式登录已就绪。
- 用户已确定交付形态为手机网页；本期五栏包含消息中心的列表、未读状态及详情，已读、批量已读、删除和业务跳转沿用现有动作。系统推送、PWA 离线能力及安装包不属于本期范围。
- 手机网页正式对外开放仍依赖正式认证、域名和接口入口核验；这一边界不阻止先制作原型与接口契约。

## 2026-10-09 手机网页实现与验证边界

- 移动路由 `/m` 采用独立布局、五栏与两个二级页，页面调用现有 `/api/portal` 资源和命令，未新增数据表或改变管理端权限。
- 新增移动组件局部引入以免与桌面同名组件冲突；同一浏览器会话从移动路由返回桌面页后的样式仍需现场检查。
- 现有 4010/4011 服务占用端口且 API 为 DATABASE 模式；未借其写入真实业务数据。浏览器权限校验不可用，未完成手机视口截图和交互证据。
- 构建与移动端 TypeScript/ESLint 检查通过；全量测试 354 项中 29 项仍失败，当前新增的 App 布局静态测试失配已修复，失败数回到既有基线。
- `npm audit --omit=dev` 报告 4 项生产依赖告警（3 高、1 中），涉及现有 Vue/ECharts 及传递依赖 `source-map-js`；本次未调整这些非目标依赖，正式发布前需独立评估升级影响。
- 续查发现被驳回访问申请的 `primaryAction` 为 `VIEW_REQUEST`，原移动重新申请深链仅识别 `REQUEST`；已限定账号开通申请不显示该动作，并让被驳回访问申请打开申请表。消息筛选变化后已收敛选中 ID，删除时按当前可见项再次校验。
- 移动主布局宽度上限为 480px，小屏按可用宽度铺满；自绘底部弹层已补焦点管理、Esc、滚动锁定及待办安全区。浏览器权限校验仍不可用，尚无实际手机视口截图和键盘操作证据。桌面/移动 TDesign 的全局 `.t-*` 样式可能交叠，需恢复浏览器验收后检查。
## 2026-10-12 字典状态一致性检查

- `src/config/dictionary-catalog.js` 的系统状态有 `SCHEDULED`、`EXPIRED` 等停用项；状态机本身已有允许输入值的白名单，字典停用不应承担业务迁移限制。
- `src/services/portal.js` 保存受控字典时只锁编码和增删，不阻止停用或非法状态；管理页开关可直接操作。
- `reconcileBusinessDictionaries` 目前只补缺，持久库中旧“定时发布(展示)”标签不会随种子变更；公告页硬编码“定时发布”掩盖字典不一致。
- 手机端申请状态、待办筛选、消息类型/阅读筛选存在硬编码标签；消息筛选包含字典中不存在的 `SECURITY`，漏掉 `SYSTEM`、`TODO_REMINDER`。
- 字典当前作为 `portal_runtime_entity` 中的 JSONB 实体持久化，需针对现存记录精确纠正并读回，不能仅改种子即声称运行库一致。

