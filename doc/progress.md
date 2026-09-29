# 执行进度

## 2026-09-28 当前功能与阶段复核（进行中）

- 已读取项目教训并确认工作树起始状态干净；正在核对密码弹窗、演示提示、测试与 Gate 证据。

## 2026-09-24 独立公告附件持久化验收（完成）

- 写前只读核对：前端附件 DTO 为 `{id,name,size,type,uploadedAt,data}`，最多 5 个、单个不超过 20MB；Repository 将完整附件对象写入规范附件表，公告产品软删保留归档及其附件。当前物理库 `announcement_attachment.attachment` 为可转 JSONB 的 TEXT、`uploaded_by` 可空，与旧 `database/schema.sql` 的 JSONB/NOT NULL 定义存在结构漂移；本次将明确提供有效 `uploadedBy`，使用仅 25 字节的纯文本 data URL。API 健康检查为 `DATABASE`、version 378；全新 Repository 活动公告 8，`P5ATT_20260924_` 前缀活动/归档均 0。尚未写入。
- 唯一标题定为 `P5ATT_20260924_95dcebff`，附件名同标题 `.txt`、内容仅 `P5 local attachment check`（25 字节）。首次使用旧 HTTP 会话创建草稿被 401 `UNAUTHENTICATED` 拒绝，已立即停写；全新 Repository 确认版本仍 378、活动仍 8、该标题活动/归档均 0。主线程明确允许重新建立本地模拟 admin 会话后只重试一次；不得复用旧 Cookie。
- 使用新建本地 admin 模拟会话只重试一次成功：草稿 ID `MOCK_60a00992-a9cc-4344-9b20-1b7514347506`，`DRAFT`/version 1。全新 Repository 真实库 version 380、活动公告 9（原 8+此 1）、同 ID 唯一 1、附件唯一 1；文件 `P5ATT_20260924_95dcebff.txt` 为 25 字节 `text/plain`，持久化 data URL 解码精确为 `P5 local attachment check`，上传人为 `MOCK_LOCAL_ADMIN`。现暂停写入，待主线程管理端页面核对附件详情后才仅对该草稿软删除。
- 主线程管理端详情已核对附件名称、`text/plain` 类型和 25 B 大小。随后仅对该 ID 执行产品软删除；活动列表恢复 8 条，标题不再出现在活动读取，物理公告行保留 `deleted_at`，附件/归档及审计按产品规则保留，未做物理清理。

## 2026-09-24 待办未接入异常处理闭环（完成）

- 主线程在林晓已有待办 `MOCK_TODO_0_0` 的详情点击“去处理”，页面提示“SSO接入异常或未配置”，待办仍显示待处理。只读 SQL 用 `actor_user_id=P4FIX_USER_1`、`event_code=openTodo`、`object_id=MOCK_TODO_0_0`、近 30 分钟筛出唯一新 `ERROR`：`P4EV_dd6b0398-c5b7-40cb-b796-d9bda250f229`，requestId `f1c9ac94-30d8-4b92-b3b2-451bcaf3359f`，errorCode `UPSTREAM_UNAVAILABLE`，version 1、当前 OPEN。独立 Repository DB version 376 读回原待办仍为 `PENDING`/version 1。现暂停异常处理，先由主线程管理端页面核对唯一 OPEN 行；未改历史异常或待办状态。
- 主线程管理端页面按该唯一 requestId 核对 HIGH/应用集成/UPSTREAM_UNAVAILABLE/待处理，随后仅对该行通过页面填写并提交处理说明，页面提示“异常已处理”。独立 Repository DB version 378 回读同一审计 ID 为 `RESOLVED`/version 2，说明 `P5验收_20260924_f1c9ac94：已核对本地演示 APP_1 的 SSO 接入未配置，待办保持待处理；非真实上游故障。`，处理时间 `2026-09-24T07:08:31.930Z`、处理人 `MOCK_LOCAL_ADMIN`；原待办仍 `PENDING`/version 1。物理只读扫描发现此前已存在的其它 ERROR 在本次目标创建后被更新数 0。保留审计，不把本地未配置异常说成真实上游故障。

## 2026-09-24 独立临时消息本地闭环（完成）

- 当前 4011 API 健康检查确认 `DATABASE`、version 368。新 Repository 只读基线：林晓活动消息 3（未读 0）、原有软删 7；陈宁活动 10（未读 5）、软删 0；`P5MSG_20260924_` 标记消息 0。应用 APP_1 为 DIRECT。仅计划用本地超级管理员 `pushMessage` 注入唯一标记消息给林晓，随后由主线程浏览器核对，再仅对此新消息进行读、软删、数据库回查。当前尚未创建消息，未触碰现有消息或外部系统。
- 本地超级管理员模拟会话通过产品 `command(pushMessage)` 新建唯一标记 `P5MSG_20260924_05424c0ab4`，消息 ID `MOCK_a57ef3b2-b7ad-4fae-a9dc-3ef102a977d4`，HTTP 200 / `APPLIED`。独立 Repository 从真实库读回 version 372：仅该 ID 一条，属林晓/APP_1，`UNREAD` 且未删除；林晓活动 4、未读 1、原软删 7，陈宁活动 10、未读 5 不变。现暂停下一步，待主线程浏览器核对列表与详情并触发页面读取；尚未软删该消息。此路径是本地命令注入，不是第三方系统推送联调。
- 主线程浏览器确认林晓消息中心有 1 封未读且仅此标记，打开详情正文正确并自动标已读。独立 Repository 随后从真实库 version 373 读回同一 ID `READ`、version 2、`readAt=2026-09-24T07:03:54.328+00:00`；林晓未读从 1 降为 0、活动仍 4，陈宁 10/5 未动。下一步仅对此 ID 产品软删。
- 林晓模拟会话仅以 `ids=[MOCK_a57ef3b2-b7ad-4fae-a9dc-3ef102a977d4]` 调用产品 `deleteMessages`，HTTP 200、删除数 1。独立 Repository 真实库 version 375 回读此 ID 为 `READ`、version 3、`deleted=true`、`deletedAt=2026-09-24T07:04:51.948+00:00`；林晓业务读取消息列表不含此 ID，活动数恢复 3/未读 0，原有 7 条软删仍在（总软删 8）；陈宁活动 10/未读 5 不变。物理 `message_recipient` 的 read_at/deleted_at 均非空，唯一 eventId 的 `ingest_receipt` 为 1。保留新消息软删档案、回执与审计，不做物理清理；待主线程最终刷新页面确认不可见。
- 主线程最后刷新林晓消息中心，确认唯一临时消息已不可见、未读数为 0。此本地消息闭环完成；不把 admin 命令注入与本地页面读删称为真实第三方 PUSH 联调。

## 2026-09-24 独立临时应用跨身份申请闭环（完成，保留审计）

- 公告写入已结束；本场景限定当前 DATABASE 模式的独立临时 REQUEST/DIRECT 应用，采用 `P5ACCEPT_20260924_` 唯一前缀。写入前确认原演示数据：USER1 对 APP13 已有有效授权、APP17 待审但应用停用，USER1/USER2 对 APP6 的账号开通记录分别为待处理/处理中，均不作为本次写入对象。将使用管理员与林晓两个本地模拟会话，逐阶段 HTTP API 写入、全新 Repository 读回，并交主线程做页面只读核验。尚未新建临时应用。
- 唯一标记确定为 `P5ACCEPT_20260924_795ab1a2`，全新 Repository 读回标记冲突为 0。首次误用 `MOCK_ADMIN`（当前只持内容管理员角色）调用 `saveApp`，得到 `FORBIDDEN`，无应用写入；核实真正的本地超级管理员是 `MOCK_LOCAL_ADMIN`，后续仅改用其模拟会话，不变更权限。
- 本地超级管理员 HTTP 会话创建临时应用成功：ID `MOCK_a2c9843a-1cd0-4b39-a09a-821aa6d77726`，版本 1，`REQUEST/DIRECT`，初始 `enabled=false`；尚未启用、提交申请或审批。
- 同一 ID 经 `setAppStatus` 启用，返回 version 2。全新 Repository 真实库读回 version 359，该应用 `enabled=true`、`REQUEST/DIRECT`；林晓访问端业务 DTO 为 `REQUEST_REQUIRED`、主操作 `REQUEST`，无 grant，SSO `UNCONFIGURED`（预期不能进入真实子系统）。
- 主线程浏览器已只读确认林晓“其它应用”卡片显示“待申请/申请使用”。林晓 HTTP 会话提交申请成功：ID `MOCK_a5496adb-a998-462a-839b-a0e6489e7c85`、编号 `REQ-20260924-00008`、version 1、`PENDING`；全新 Repository DB version 362 读回申请唯一且待审，林晓卡片 `REQUEST_PENDING/VIEW_REQUEST`、“我的申请”状态待审，grant 仍 0。当前暂停审批，等主线程核对页面。
- 主线程浏览器已只读确认申请列表与管理端待审同编号。`MOCK_LOCAL_ADMIN` 仅审批此申请，返回 version 2、`APPROVED`。全新 Repository DB version 365 读回：grant ID `MOCK_c62886c3-6aa9-41f0-9f7d-a74293fee372`，林晓/临时应用 `ACTIVE`；卡片 `DIRECT/ENTER`，“我的申请”已通过；SSO 仍 `UNCONFIGURED`，不表示真实子系统进入成功。暂停清理，待主线程浏览器核对授权后的用户入口。
- 主线程浏览器确认管理员同编号已通过；林晓“我的应用”从 7→8，临时应用有“进入应用”但因 SSO 未配置按钮禁用。删除前全新 Repository 精确核对仅此临时应用 version 2、1 条 APPROVED 申请、1 条 ACTIVE grant；随后仅对该 ID 执行产品 `removeApp`。删除后全新 Repository DB version 368：活动应用 42，临时应用/申请/grant 活动数均 0。物理只读残留：该应用 1 行且 `deleted_at` 非空，活动物理行 0，申请 0、授权 0、关联审计 5；按约定保留归档与审计，不做物理 `DELETE`。原 APP13/APP17、USER1 既有申请/授权和 APP6 两条开通演示状态读回均未变化。

## 2026-09-24 公告跨身份浏览器闭环（连接阻断）

- 已按浏览器操作规范尝试连接当前 4010 公告管理页；浏览器运行时返回 `No browser is available`，按规范排障后可用实例列表为 `[]`。本次未创建验收公告、未对数据库或页面作任何写入；发布—公众可见—撤回—软删除的浏览器闭环尚未取得证据。待浏览器恢复后使用唯一 `P5验收_20260924_公告发布撤回_` 标记，并仅清理该测试公告。
- 主线程另有可用浏览器承担只读页面核验，已授权本子任务改用本地 HTTP API 与新 Repository 读回执行跨身份业务闭环。写前 API 健康检查为 `DATABASE`，全局版本 345；独立 Repository 读回活动公告 8 条、回收档案 2 条，此测试标题前缀活动记录 0 条。尚未创建测试公告。
- 已用本地 admin 的 HTTP 会话创建唯一临时公告草稿 `P5验收_20260924_公告发布撤回_bbfdb55e`，ID `MOCK_37f7804e-4991-4261-97bf-29480bd81567`，返回 version 1、`DRAFT`。仅此 ID 后续进入发布、可见、撤回及产品软删除；当前未触碰历史公告。
- 同一 ID 已用 `submitAnnouncement(IMMEDIATE)` 发布，HTTP 返回 `PUBLISHED`、记录 version 2、`publishedAt=2026-09-24T06:46:59.214Z`。全新 Repository 从真实库读回全局 version 348、活动公告 9（原 8+临时 1）、同标题仅 1 条，状态 `PUBLISHED`、范围 `ALL`、发布方式 `IMMEDIATE`；现暂停后续写入，待主线程完成管理端和公众端只读页面核对。
- 主线程浏览器已确认管理端刷新显示临时公告为已发布，公众“林晓”公告列表可见且详情标题、正文、发布时间、范围正确。同一 ID 已用管理端 HTTP 会话撤回，返回 `WITHDRAWN`、version 3、`withdrawnAt=2026-09-24T06:49:04.544Z`；全新 Repository 读回全局 version 351、活动仍 9、该 ID 唯一且为 `WITHDRAWN`。再次暂停写入，待主线程刷新公众页确认不可见后仅对该临时 ID 软删除。
- 主线程浏览器刷新公众公告列表后，临时标题不可见且原 3 条仍在。对该唯一临时 ID 调用产品 `removeAnnouncement` 返回成功；全新 Repository 读回全局 version 352、活动总数恢复 8、临时 ID 活动 0、回收档案该 ID 唯一 1（`WITHDRAWN_DELETE`，删除人为 `MOCK_LOCAL_ADMIN`）、该公告已读回执 0。物理表只读查询结果：公告行 1、有 `deleted_at` 行 1、回执行 0、关联审计 5；未物理清除归档或审计。管理端删除后列表页面的最终刷新由主线程核验。

## 2026-09-24 续接剩余业务场景测试（进行中）

- 用户要求继续剩余业务场景测试。先核对当前代码/服务/数据库版本及既有演示对象，再按独立场景串行执行写入与读回；已发现工作树同时存在别处修改的 Gate 文档，当前不会覆盖或把未经本轮核实的“用户签署”当作测试结论。

## 2026-09-24 用户人工验收通过与演示原型正式冻结（A3完成 / P4 Gate通过）

- **用户人工复核通过**：用户在本地数据库运行环境下人工核验全站页面与业务操作，确认运行无问题、交互正常无阻断。
- **边界共识明确**：
  1. 登录认证保持模拟方式，固定使用 admin 免密/身份切换会话，不进行数据库密码比对。
  2. 42 个子系统暂不接入真实外部接口，保持本地模拟四态及规范接口契约，不要求生产联调。
- **阶段 Gate 签署与冻结**：P4 Gate 正式签署通过；0.3.0 高保真演示原型达成冻结标准（`DEMO_FRONTEND_FROZEN`）。后续真实外部联调（0.3.0-C）与生产级关系模型统一（0.3.0-B）留待后续立项实施。

## 2026-09-24 当前版本浏览器业务验收续接（进行中）

- 用户最新指出五类审计日志的前端定义字段虽有列但数据未完整显示。已暂停公告发布场景；只读统计发现原 Repository 未映射登录用户/账号/身份来源/IP、访问模式、操作页面/动作、接口/状态码/耗时和异常级别等字段。实际审计表 `details` 为 text，需在 DTO 边界转 JSON，优先从事件 details 取原值，旧记录仅在字段缺失时按当前用户/应用规范记录补可判定的字段；不可追溯的历史网络/耗时保持未采集。
- 对原 Mock 的 `P4FIX_LOG_*` 目标审计样本回填前，已单表备份 `database/backups/uhp-audit-pre-enrich-20260924.dump` 并验证 `pg_restore --list` 可读，SHA256 `565D4D7FEAD38E7710155C1BFF283461E9AA5A3414B5660C6486EB68B22AE1E4`。只对精确匹配原始种子且版本/摘要/身份/应用一致的 20 条样本补齐原字段，并协调原样本登录失败及异常已处理状态；4 条非原种子的 AUTH 样本未动。回填脚本再次只读预览为待改 0 条。
- 五类日志的数据库 DTO 已按页面字段补齐；新产生事件记录登录方式、请求 IP/客户端、耗时及操作页/动作等可采集值，用户/应用原始资料只作服务端字段映射，不整包返回浏览器。历史记录中未采集过的网络或耗时字段保持 `-`，不伪造。审计页保留日志原文，不套用普通页面的“模拟/演示”文案清洗。
- 仅重启核对为本项目的 4011 API（PID 26028→23564），4010 前端保持运行。重新模拟登录后，浏览器五类列表列头及实值均可见；当前可见数登录 83、访问 4、操作 42、接口 4、异常 10（会随当前会话/操作变化）。登录新记录显示 admin、密码方式、127.0.0.1 和真实客户端；访问显示账号/模式；操作显示页面/动作；接口显示方法/状态码/耗时；异常同时显示待处理与已处理，已处理详情可见说明/时间。完整自动测试 229/229、构建、语法及 diff 检查通过；两项原有演示数据只读校验仍通过，数据库版本为 324（会继续递增）。

- 4011 健康检查仍为 `DATABASE`，两项演示数据只读校验通过；4010 页面服务可访问。浏览器旧标签为过期的连接错误页，新标签重新打开后正常，不属于当前服务故障。
- 本地 admin 从模拟登录进入管理首页，运行监控页加载 42 条应用并明确提示“运行状态为本地演示样本，尚未接入真实上下游系统”；管理首页接入异常 30、访问申请待处理 1 等数据正常显示。应用访问申请页列出 7 条，含待处理、已通过、已驳回、已撤回、已过期状态。
- 在当前数据库模式的公告管理页，从浏览器新建 `P4验收_20260924_公告持久化` 草稿，刷新后仍可读；编辑标题为 `P4验收_20260924_公告持久化_已修改`，再次刷新后保留。经用户逐项确认，使用页面“删除/确认删除”清理此唯一测试草稿；再次刷新后测试标题不存在，活动列表从 9 条恢复 8 条。删除保留产品的回收档案和审计，不对历史 8 条演示公告作清理。
- 以上证明了本机当前版本公告页面新增、列表读取、修改、软删除与刷新持久化；尚不能推出全部发布/撤回、附件、多身份和其他业务路径已通过。
- 独立 Repository 真实库只读回查同一验收标题前缀：活动公告 0、回收档案 1、活动总数 8，确认测试记录没有留在演示列表，软删除审计轨迹保留。
- 公众端浏览器确认应用中心显示需确认账号/账号不可用/账号异常等不同操作；失败与冲突原因弹层分别有针对性说明。未真实接入的待办“去处理”提示 SSO 接入异常或未配置；待办列表 4 条含待处理、已处理、已过期、已撤回。本人应用访问申请 5 条覆盖待处理、通过、驳回、撤回、过期，账号开通申请 1 条待处理；公众公告列表 3 条，个人中心正常显示。
- 超级管理员从切换组件回到管理端；内容管理员只见工作台与公告且列表可加载，无跨权限错误。超级管理员抽查应用列表 42、开通申请 3、用户管理 3、角色 6、组织 2、字典 6、身份映射 4、配置页均能打开。五类审计页初次仅见标题、正文却报“服务或数据库暂不可用”，已立即停止 Gate 签署并定位。
- 根因是实际 `audit_event.details` 为 text，Repository 直接使用 `->>`。修复读/写 SQL 的 JSONB 显式转换并补单元回归；只读真实库查询 37 条异常日志成功。精确确认 4011 PID 26996 为本项目 API 后重启为 26028；共同启动器关联的 4010 原进程退出，已单独恢复前端 PID 5592。新浏览器标签重新模拟登录后五类日志页面均无服务错误，计数为 204/12/79/7/37。浏览器控制台无 error 级记录。
- 修复后 `npm test` 227/227、`npm run build` 通过（UI 包体积提示仍在）；只读数据库校验再次通过：公众 12/12 授权动作与原 Mock 一致，42 应用/126 接入配置四态、监控与入口状态差异 0。当前全局版本 322（会随登录审计递增）。

## 2026-09-24 当前数据库演示状态与权限收口（进行中）

- 用户确认 APP_3、APP_24 恢复原 Mock 的公众/政务双端范围；恢复前全 schema 备份 `database/backups/uhp-user1-reconcile-preapply-20260924-004926.dump` 已校验 3,379,416 字节、644 项目录、SHA256 `5F5463D7A23961B467C4340C588B76E557917497017139FE32B0A656D1C3B963`。
- USER_1 受保护事务从 P4RUN_STATE version 299 执行到 300；独立只读验证 `verify-user1-demo-access.mjs` 通过：12/12 应用访问状态/操作与原 Mock 一致，APP_3/APP_24 物理及快照均 BOTH，7 条待办逻辑归档、7 条消息对本人隐藏，旧映射、授权范围、异常按目标状态协调且原文归档。重复执行被基线/归档守卫阻止，其它用户不改。
- 用户切换包含数据库全部用户及本地 admin，停用项禁选；部分管理角色此前被无权限的应用目录预加载阻断，已改按权限加载。预置本地超级管理员的停用/降权路径有服务端保护与专项测试；代码待重启后运行态检查。
- 第三方演示接入修正已完成：独立全 schema 备份 `database/backups/unified-health-portal-pre-demo-integrations-20260924-005310.dump` 为 3,384,203 字节、SHA256 `3FC7D58CB81DD6F517DCDA7F9EBC4EF4514AFFAA34E2BE24271F7FE165969FDD`。受保护事务从 version 300 提交至 301，125 条旧占位接入配置同步运行实体、兼容快照和物理配置；有成功维护审计的 APP_1 TODO 三层哈希不变。物理配置启用时仍为 UNCONFIGURED 表示未真实连通，运行态四态标记 `DEMO_FIXTURE`；只读回查 126/126 三层一致、NORMAL 30 / ABNORMAL 31 / UNCONFIGURED 31 / DISABLED 33，管理监控与入口状态差异 0。后续模拟登录审计使全局版本递增，不影响结果。
- 浏览器已在重启后的 DATABASE 服务验证：本地 admin 可进入管理端；切换列表含数据库全部 5 用户；普通用户与内容管理员跨端切换正常；内容管理员公告管理页无权限误报；公众应用中心显示未绑定、失败、冲突及可进入场景；本地超级管理员角色控件禁降权。进一步点击监控页时浏览器工具被平台用量审核阻断，该动作没有执行，不能视为浏览器监控页验收。
- 最终本机 `npm test` 226/226、`npm run build` 通过（仅有大包提示）；USER_1 与接入数据只读校验在浏览器模拟登录后再次通过。浏览器未覆盖全部业务闭环，不能据此宣称 P4/P5 Gate 完整通过。

## 2026-09-23 演示状态恢复与性能优化（进行中）

- 状态补丁执行阶段：已获准仅补缺失应用场景及本地模拟管理员；执行前先对精确业务表做归档备份、校验与基线回读。此记录起点尚无数据库写入。
- 写前基线：42 个活动应用的 5 个演示字段均缺失（共 210 个空缺），`preservedDigest=cdd44bb6062b55c5e538af1b0b54477b`；访问申请为 APPROVED 2 / EXPIRED 1 / PENDING 1 / REJECTED 2 / WITHDRAWN 1，授权 ACTIVE 2，映射 BOUND 32 / CONFLICT 4 / FAILED 4。本地模拟管理员运行态、物理用户、角色授权均缺；物理管理员角色及授权人存在。
- 已生成精确归档 [uhp-demo-state-preapply-20260923-195402.dump](../database/backups/uhp-demo-state-preapply-20260923-195402.dump)，含 application/category、unified_user、portal_role、portal_user_role、portal_runtime_entity/domain、application_access_request/grant、account_opening_request、application_user_mapping、audit_event 共 12 表。归档 111822 字节、172 TOC 项，目标表均有 TABLE DATA；项目副本与容器原件 SHA256 一致：`B5677A9703B049E8C4E08BEC5C0E000FD6FA57AD1CEBC039A3D707C48C1A13CD`。此刻尚未执行状态补丁。
- 已执行应用场景补丁 `--apply`：42 个匹配应用更新，5 字段完整数从 0→42，剩余可补应用 0；非目标字段、原有状态及版本的 `preservedDigest` 前后均为 `cdd44bb6062b55c5e538af1b0b54477b`。应用数仍为 42，申请、授权、映射状态分布与写前逐项相同。尚未执行本地模拟管理员补种。
- 本地模拟管理员补种首次执行失败并已停下：脚本从 `createSeed().users` 获取的用户无 `createdAt/updatedAt`，生成 SQL 中时间为 `undefined`，PostgreSQL 报 `invalid input syntax for type timestamp with time zone`；该事务没有提交。按失败即停原则未绕过约束或重试，需只读核对残留并修正脚本后再审查。
- 失败后只读预览再次证明运行态 `MOCK_LOCAL_ADMIN`、物理用户 `P4FIX_LOCAL_ADMIN`、角色授权三处均为 `null`，即事务已回滚、无残留。脚本已改用当前种子首个应用的固定 UTC `createdAt/updatedAt`，新增时间戳有效性与生成 SQL 不含 `undefined` 的断言；两专项测试 5/5、语法检查及再预览均通过。尚未重试数据库写入，等待重新审查。
- 重试前只读确认：物理 `P4FIX_ROLE_ADMIN` 处于 ENABLED，既有 `P4FIX_ADMIN`（运行态超级管理员）已绑定同一角色；其 `org_key=P4FIX_PORTAL`，`unified_user.org_key` 无额外检查约束。获审查后仅重试一次 `--apply` 成功：运行态 `MOCK_LOCAL_ADMIN`、物理 `P4FIX_LOCAL_ADMIN`、物理 `P4FIX_UR_MOCK_LOCAL_ADMIN→P4FIX_ROLE_ADMIN` 三处同时读回，无密码材料。API health 仍为 DATABASE、version 214；HTTP 登录待验。
- 本地模拟管理员实际 HTTP 登录成功：`POST /api/portal/session` 返回 `ok=true`、admin ID `MOCK_LOCAL_ADMIN`、`authType=LOCAL`、`adminAccess=true`；同一 Cookie 的 `GET /api/portal/session` 仍读回该管理员。登录仍为模拟方式，没有数据库密码校验。最终只读回查：42 个应用场景全部完整、缺失 0，非目标摘要仍为 `cdd44bb6062b55c5e538af1b0b54477b`；三处管理员记录均在；访问申请、授权、映射各状态计数与写前完全一致。
- 补充只读业务验收：`MOCK_USER_1` 在真实库与新种子均看到 15 个应用，`MOCK_ADMIN` 均看到 42 个管理应用，管理员 10 个关键应用的场景/动作一致；公众用户仍有历史映射差异。真实库公众状态 BOUND 7 / UNBOUND 3 / CONFLICT 1 / FAILED 1 / DIRECT 2 / REQUEST_PENDING 1，当前种子为 BOUND 5 / UNBOUND 5 / CONFLICT 1 / FAILED 1 / DIRECT 2 / REQUEST_PENDING 1。APP_2–6 在真实库为 BOUND/ENTER、种子为 UNBOUND/BIND；APP_11 为 BOUND/ENTER 对 FAILED/VIEW_REASON，APP_12 为 BOUND/ENTER 对 CONFLICT/VIEW_CONFLICT。APP_1 仅映射标识不同，DIRECT/ENTER 一致；APP_13/17 一致。
- 逐 ID 审计确认 APP_1/2/3/4/5/6/11/12 的 `MOCK_USER_1` 映射在逐实体表、物理映射表和旧快照中均为版本 1、同一旧时间与 BOUND，无对应后续绑定审计，属于历史演示样本证据；但每个应用又有 1 条管理范围授权、1–2 条待办和 1 条消息，APP_11/12 还无异常记录。故本次不擅自覆盖或删除这些映射；恢复完整动作需协调映射、授权范围、异常及消息待办，不能宣称演示状态已完全恢复。
- 全主体只读对比：`MOCK_USER_1` 有 12 个应用的访问状态/操作与当前种子不同（APP_2/3/4/5/6/11/12/24/25/26/28/33）；`MOCK_USER_2`、`MOCK_ADMIN`、`MOCK_EDITOR`、`MOCK_LOCAL_ADMIN` 的可见应用访问状态/操作均与种子逐项相同。USER_1 旧 APP_2–6/11/12 各有 PENDING 待办，相关消息仍可点“查看关联业务”，仅改单条映射会留下错误入口。
- 为可恢复归档新增 010 结构迁移，执行前备份 [uhp-user1-demo-pre010-20260923-200824.dump](../database/backups/uhp-user1-demo-pre010-20260923-200824.dump)：含 todo_item/message/message_recipient/scope/映射/异常/运行态/旧快照/回执 9 表，126631 字节、168 TOC，项目副本与容器原件 SHA256 同为 `870BC22C5D2A0DDF0456877E8EE4E735B73A11ABE2B44E71CB8EF189F9A732FD`。010 两次执行成功且幂等，仅加 `todo_item.archived_at` 和原始 JSON 归档表，没有归档业务行；回读 archived_at 非空 0、归档表 0、todo 44/message 40/recipient 40 不变，新 Repository 可加载。
- 已完成只读定位：当前 42 个应用的数据库 `runtime_payload` 缺 5 个场景字段，导致原模拟应用访问状态退回默认；申请 7、授权 2、开通申请 3、映射 40 均在，不能覆盖或重建已有业务状态。
- 已新增默认只读、显式 `--apply` 的精确补丁脚本并预览：42 个应用、210 个缺失字段；应用 ID+编码双重匹配，仅补空缺 JSON 字段，专项测试 3/3 通过。真实数据库尚未执行补丁。
- 另发现本地模拟管理员 `MOCK_LOCAL_ADMIN` 不在当前 DB 4 个用户中，登录页对应入口会被拒绝；正在设计仅缺失时补种并保持模拟登录的修复。
- 已实测本机单次 health/session 均约 2 秒；每次完整读取需 6 次 Docker/psql 调用，首页并发读还受 API 串行队列排队。
- API 已加入进程内 1 秒只读快照：仅 GET health/session/read 复用；POST、可能写审计的其它 GET、定时清理均强制新读并使缓存失效。模拟仓库测试证实 6 个并发 GET 只调用一次 Repository.load，写入后立即读到新版本/新分类，过期后重新加载；匿名及低权限请求仍分别返回 401/403，不会共享管理员权限。完整 `npm test` 为 209/209 通过。
- 补种完成后确认原 4010/4011 及共同启动器的命令行均指向本项目，再仅停止这三个精确进程并由 `server/dev.mjs` 重新启动；新服务健康检查为 `repository=DATABASE`、version 215。经 4010 代理实测：首次冷 health 2164 ms，同一秒内 session/health/session 分别 8/6/6 ms；缓存过期后 6 个并发 health 整批 2085 ms。模拟管理员登录 2499 ms 后，等待缓存到期，6 个实际业务读取（应用 42、分类 6、管理首页、监控 42、访问申请 7、开通申请 3）整批 2099 ms 且均成功。登录是模拟会话，产生一条正常登录审计；未执行其它业务写入。首次冷读仍约 2 秒，外部进程直写数据库最多 1 秒缓存可见延迟。
- 进一步只改 Repository 读取顺序：先读取兼容快照/version，第一波并发读剩余实体、应用/分类、公告，第二波在取得最新用户及应用后并发读待办/消息与申请/授权；分域按负责键合并，避免覆盖或丢失快照其它字段。专项测试验证并发峰值 3/2、名称依赖及快照缺失时的初始化 fallback，完整 `npm test` 为 211/211 通过。真实数据库只读直接调用三次分别为 1037/1017/1008 ms，version 216、应用 42、访问申请 7 均一致，未修改业务状态。
- 010 迁移完成并确认新 Repository.load 可读后重新恢复本项目 4010/4011 服务；经 4010 代理复测冷 health 1183 ms，缓存过期后的 6 个并发实际业务读取整批 1115 ms，缓存命中的单次应用读取 15 ms。六项业务均成功，数量为应用 42、分类 6、监控 42、访问申请 7、开通申请 3。测试中模拟管理员登录产生正常审计记录；没有执行应用、授权等业务修改。此性能结论是本机当前数据量的实测，不代表其它机器的固定时延。

## 2026-09-23 持久化收口验证

- 默认 `npm run dev` 已切换为数据库 API，模拟模式独立为 `npm run dev:mock`；启动器会识别 4011 既有 API 模式，不复用错误数据源。当前本机前端 `127.0.0.1:4010` 与数据库 API `127.0.0.1:4011` 可通过代理访问。
- 真实库 Repository 针对应用、分类、待办、消息、申请/授权/开通申请、组织、字典、角色进行了新增、编辑、重新实例加载、删除与精确清理，验收标记 `DBACC_53c046d9b188`；活动集合及关联物理表残留均为 0。
- 真实数据库 API 先经模拟登录读取应用 42、分类 6、组织 3、字典 6/22 等数据；随后新增 API 链路验收 `DBAPI_53f98b01cecd`：应用新增→启用→编辑→新 Repository 读回→公众用户提交访问申请→管理员审批并生成授权→删除应用。重新加载验证申请、授权随应用删除清理，精确删除测试软删行及关联审计后，应用/申请/授权/审计物理表残留均为 0。
- 以上覆盖本地数据库持久化和关键业务 HTTP 操作；生产外部接入、真实身份认证、全部页面视觉验收不在本轮结论内。旧 `P4RUN_STATE` 仍承担兼容快照与全局版本控制。
- 最后回归 `npm test` 为 203/203 通过，`git diff --check` 无内容错误。演示进程曾退出导致代理暂时返回 502；重新以 `npm run dev` 启动后，前端根路径返回 200，前端代理健康检查返回 `repository=DATABASE`、`database=nocodb_data`、`schema=pb3gir75kkooyea`、version 214。

## 2026-09-23 续接：其他业务持久化（数据库迁移已完成）

- 已完成 006–009 的代码与迁移文件：应用/分类、消息/待办、应用访问申请/授权/账号开通分别读取和写入业务表；组织、字典、角色、用户、映射、配置、监控及本地回执改为按实体逐条持久化的兼容表。
- Repository 已按上述业务表/实体表回读覆盖旧快照，保留 `P4RUN_STATE` 作为兼容及全局乐观版本；登录继续使用模拟会话。
- 最新全量源码测试为 203/203 通过。006–009 已完成真实库备份、两次幂等迁移与只读回读；其它业务的真实 API CRUD/进程重启验收尚未执行。
- 迁移前真实库只读计数为应用 42、分类 6、待办 44、消息 40、收件人 40；006–009 迁移和首轮缺省域初始化期间数量不变、`P4RUN_STATE.version` 保持 188。后续并行 CRUD 记录测试将 version 推进至 192，三类申请显式补种未再修改版本。

## 2026-09-23 006–009 真实库迁移与缺省域初始化记录

- 迁移前已生成目标 schema 全量 custom-format 备份：`database/backups/unified-health-portal-pre006-009-20260923-145546.dump`，318,948 bytes，SHA256 `C3E912293FF0495D9FEBA169D77F5A496C11B4824489E2BF8DE004EAECDA4E47`。
- 备份命令：`docker exec -i -u postgres postgres14 pg_dump -U admin -d nocodb_data --format=custom --no-owner --no-privileges --schema=pb3gir75kkooyea --file=/tmp/unified-health-portal-pre006-009-20260923-145546.dump`；随后用 `docker cp` 保存到项目目录。`pg_restore --list` 返回成功，共 588 个 TOC 条目，归档可读。
- 文件 SHA256：006 `5A992A04BC1069D06404EA9D9D122B8C16000F8ACA4CD1DC7328F4555D96D9FF`；007 `513B326A0FCD2766D8E44F6215C4999A0C6DAD0D3CAD03C097C7DAD380B518BA`；008 `FA837D23370516621AE7ABBF004B657A4856EF79D9DC939E861635904B05BCD4`；009 `FDA064007B3F843BD1BADE6E0B6AC8FD8996624AC0D0CAC6AF668B1E1FF52AAC`；修复后的 bootstrap `B0552A5DBB947DA1AFB97E0EF336C903FE22E215073C31009775A1183D43D558`。
- 006→007→008→009 均以 `psql -X --set=ON_ERROR_STOP=1` 按序执行成功并 COMMIT，随后按相同顺序第二次执行成功。第二次 006 回填均为 0；008 导入三类申请均为 0；009 第二次域/实体新增均为 0，证明当前数据集下具备幂等性。
- 006 回读：应用 42（活动 42、软删 0）、分类 6（活动 6、软删 0），runtime ID 均非空且域内唯一，payload 均已落库；相关唯一索引与活动索引存在。
- 007 回读：待办 44、消息 40、收件人 40（活动 40、软删 0），runtime ID/接收时间已补齐；待办与消息 runtime ID 索引存在。
- 008 迁移后首次回读：访问申请、访问授权、账号开通申请均为 0，与当时快照中三个数组完全缺省/空的边界一致；三张表的 runtime/request 唯一约束及指向 `application`、`unified_user` 的 9 个外键均存在。随后为恢复页面演示样本，已按下述显式门禁补种为 7/2/3。
- 009 首次只为快照真实存在的 8 个域写入标记和 219 个实体：users 4、roles 6、mappings 40、settings 9、integrations 126、monitorSamples 12、visits 22、receipts 0。`organizations/dictTypes/dictItems/mappingVerificationEvents` 在快照缺省时未被错误标记。
- bootstrap 首次尝试在第一条只读 SELECT 因 `json_build_object` 缺闭合括号失败；事务尚未构造，回读仍为 8 域/219 实体、缺省域 0、version 188，确认没有部分写入。修复并通过语法检查后重新执行成功。
- 修复后的 `npm run db:bootstrap-missing` 首次仅补入快照缺省且未标记的 4 域：organizations 3、dictTypes 6、dictItems 22、mappingVerificationEvents 0；第二次返回 `seededDomains=[]`、`rows=[]`。最终为 12 域、250 个实体，`(resource,runtime_id)` 重复数为 0，原 8 域数量未被覆盖。
- 006–009 首轮收口时的只读边界：`P4RUN_STATE.version=188` 且四个缺省键仍未被写回旧 JSON 快照；历史公告仍为 9（活动 8、软删 1），阅读回执仍为 6。该值随后因独立 CRUD 记录测试推进至 192，不是迁移或补种造成。
- 当前阶段：公告第一阶段真实 API CRUD 已完成；006–009 数据库迁移与缺省域演示种子已完成；应用、消息、待办、申请及剩余域的真实 API CRUD/重启读回仍待后续验收，上下游仍仅保留接口边界。

## 2026-09-23 三类申请演示样本显式补种

- 补种前静态检查确认脚本通过 `node --check`；默认模式仍只处理快照缺键且物理表为空的申请域，新增 `--seed-empty-requests` 仅显式允许处理“快照数组存在但为空、且对应物理表仍为空”的边界，不会覆盖非空物理表。
- 前置只读检查发现并行数据库 CRUD 记录测试已将 `P4RUN_STATE.version` 从 188 推进至 192，并使三个快照键存在但数组长度均为 0；三张物理表仍均为 0。因状态与原前提不同，首次检查后已停止并取得来源确认，未绕过门禁直接写入。
- 经确认后执行 `npm run db:bootstrap-missing -- --seed-empty-requests`：首次返回 `seededRequestDomains=[applicationRequests, applicationGrants, accountOpeningRequests]`，其它实体域新增为 0。
- 首次回读为访问申请 7、访问授权 2、账号开通申请 3；各表 runtime ID 全部唯一，申请/账号开通 request_no 也全部唯一。用户、应用、审核人/授权人/处理人关联的外键孤儿计数均为 0，`P4RUN_STATE.version=192` 未改变。
- 使用相同显式命令第二次执行，返回 `seededRequestDomains=[]`；最终仍为 7/2/3，各表 runtime ID 重复数均为 0，`P4RUN_STATE.version` 仍为 192，取得当前数据集下的幂等证据。
- 当前 bootstrap 文件 SHA256：`6FEF0AC7030C0C5BBFF02EAFE1E688D0578ABD37F35186CCFDEA4BD60BB2ACBB`。

## 2026-09-23 数据库改造与真实 CRUD 接入（公告第一阶段已完成）

- 已读取历史教训和现有过程记录。
- 已确认本轮范围：登录保持模拟；通知公告 CRUD 为第一优先级；其他业务满足前端演示基本闭环；上下游仅预留接口。
- 已完成现有 schema/migrations、Repository/API、Mock/HTTP Provider 和页面实际调用链审计。
- 已完成通知公告页面→Runtime→API→Service→Repository→Schema 的改造：DATABASE 模式下公告、附件与阅读回执以规范表直接回读和持久化，其他业务模块仍保留 `P4RUN_STATE` 兼容状态。
- 已完成通知公告第一阶段真实数据库 CRUD：扩展公告字段、新增已读回执表，并使 DATABASE Repository 完整持久化公告聚合。
- 已新增并执行 `database/migrations/005_announcement_runtime_crud.sql`：幂等扩展定时/提交/撤回/编辑/软删除字段与稳定 `runtime_id`，新增 `announcement_read_receipt`，并从旧 `P4RUN_STATE` 导入定时字段、附件和已读回执。
- 已改造 `server/repository.mjs`：DATABASE load 以规范化公告/附件/已读表覆盖快照中的公告聚合；commit 在原事务中完整同步活动公告、软删除归档、附件和已读回执，不再物理删除公告。
- 已新增公告数据库映射专项测试，3/3 通过；既有公告/Portal聚焦测试 36/36 通过；`node --check server/repository.mjs` 与 `git diff --check` 通过。
- 后续修复并扩展测试后，最新完整 `npm test` 已为 203/203 通过；早期 185/188 的中间状态不再作为当前验收结论。
- `npm run build` 已通过（Vite 6004 modules transformed）；仅有现有大 chunk 超过 500 kB 的构建警告。
- 005 已在真实 PostgreSQL 环境执行并完成两次幂等验证；通知公告 API CRUD 已取得数据库写入、重启回读和精确清理证据。
- 只读盘点确认现库 `P4RUN_STATE.announcementTrash` 有1条历史归档，规范化 `announcement` 无对应软删除行；005 已补充幂等导入，包含基础/定时/提交/撤回/编辑/删除字段，用户外键仅在目标用户存在时写入，且以 `WHERE NOT EXISTS` + `ON CONFLICT DO NOTHING` 保证不覆盖数据库已有版本。
- 005 的附件导入已同时覆盖 `announcements` 与 `announcementTrash`，使补入的历史归档可恢复附件关联。新增迁移边界测试后公告数据库专项测试 4/4 通过，`node --check` 与 `git diff --check` 仍通过。
- 只读审计及改造完成：前端统一走 HTTP；DATABASE Repository 的公告域已切换为规范表直接读写，其它模块仍从 `system_config.P4RUN_STATE` 读取兼容状态。
- 第一阶段实施边界已完成：通知公告规范表直接读写已落地；应用、消息、待办、申请及剩余本地域也已完成 006–009 数据库迁移，真实 API 验收另行进行。
- 公告字段迁移、附件/阅读/归档表、Repository 映射、数据库专项测试与真实 API 验收均已完成。
- 已完成当前真实数据库只读盘点：确认 PostgreSQL 14.20、目标 schema 存在、32 张表、199 项 `p3_%` 约束及 004 字段/注释均可识别；002 原始索引名虽不存在，但等价 BOUND 唯一部分索引存在。
- 已只读核对公告数据：主表 8 行、组织范围 2 行、附件 0 行；公告状态为 DRAFT 3 / PUBLISHED 4 / WITHDRAWN 1，公告 ID 全部为 `P4FIX_%`。
- 已只读核对 `P4RUN_STATE`：记录存在、version 180、value 为 JSON object；其中仍有公告 8、阅读回执 6、删除归档 1 等运行态数据。
- 已统计迁移前 32 表共有 467 条 `P4FIX_%` 演示镜像记录；该结果已作为备份和数据边界识别基线。
- 初始盘点阶段仅执行 `SELECT` 元数据/计数查询；后续数据库写入均按下述 005 执行记录和 API 验收记录实施。

## 2026-09-23 005 公告运行态迁移执行记录

- 迁移前备份：`database/backups/unified-health-portal-pre005-20260923-091354.dump`，PostgreSQL custom-format，67,685 bytes。
- 备份范围严格限定为 `pb3gir75kkooyea.announcement`、`announcement_attachment`、`announcement_org_scope`、`system_config`、`unified_user`，并包含这些表的序列、约束、索引和表数据；已用 `pg_restore --list` 验证归档可读。
- 备份命令：`docker exec -i -u postgres postgres14 pg_dump -U admin -d nocodb_data --format=custom --no-owner --no-privileges --table=pb3gir75kkooyea.announcement --table=pb3gir75kkooyea.announcement_attachment --table=pb3gir75kkooyea.announcement_org_scope --table=pb3gir75kkooyea.system_config --table=pb3gir75kkooyea.unified_user --file=/tmp/unified-health-portal-pre005-20260923-091354.dump`，随后用 `docker cp` 保存到项目备份目录。
- 备份 SHA256：`67ACCFF4D6B9AD73C23629E2B940341A428545BF68D94A03A03B4459D7E92F6D`。
- 备份复制命令：`docker cp postgres14:/tmp/unified-health-portal-pre005-20260923-091354.dump E:\AI\N8N-project\机关大院\unified-health-portal\database\backups\unified-health-portal-pre005-20260923-091354.dump`；归档验证命令：`docker exec -i -u postgres postgres14 pg_restore --list /tmp/unified-health-portal-pre005-20260923-091354.dump`。
- 005 文件 SHA256：`BFE26CF56496DEEF02902DCF0EC89083EC3268C830F0DCBC41C81E3B4C8FD6EC`。
- 迁移执行命令：`docker exec -i -u postgres postgres14 psql -X -U admin -d nocodb_data -v ON_ERROR_STOP=1 -f /tmp/005_announcement_runtime_crud.sql`。
- 005 首次执行成功并 COMMIT：活动公告回填 8 行、历史删除归档补入 1 行、附件导入 0 行、阅读回执导入 6 行。
- 005 按相同命令第二次执行成功并 COMMIT；已存在列/表/索引均按预期跳过，历史归档新增 0 行、附件新增 0 行，阅读回执走唯一键更新仍保持 6 行，未产生重复记录。
- 迁移后只读回读：`announcement` 共 9 行，其中活动 8、软删除 1；9 个 `runtime_id` 全部非空且互异；`announcement_attachment=0`、`announcement_read_receipt=6`。
- 历史归档已落为物理 ID `P4FIX_e734e220-0e95-4b44-b923-8e1b3cc8cb51` / runtime ID `MOCK_e734e220-0e95-4b44-b923-8e1b3cc8cb51`，状态 DRAFT，`deleted_by=P4FIX_ADMIN`，`delete_reason=DRAFT_DELETE`。
- 新增 13 个公告运行态/软删除字段、附件 `runtime_id`、`announcement_read_receipt` 表及 5 个索引均已回读存在；附件 `uploaded_by` 已允许为空。
- `P4RUN_STATE` 未被迁移修改：version 仍为 180，`updated_at` 仍为 `2026-09-20 09:40:21.778078+00`，快照仍为活动公告 8、删除归档 1。
- 迁移后额外只读计数确认非目标数据未被扩散修改：`announcement_org_scope=2`、`system_config=23`、`unified_user=4`，与迁移前盘点一致。
- 当前执行状态：指定备份、005 首次迁移、第二次幂等验证和迁移后只读回读均已完成；未修改其它业务数据。

## 2026-09-23 通知公告真实 API CRUD 与清理验收

- 启动数据库模式后，健康检查返回 `repository=DATABASE`、version 180；管理员模拟登录成功，登录仍未接入数据库用户名/密码认证。
- 通过 HTTP 创建草稿成功：runtime ID `MOCK_cb1b1812-1e69-4b00-9e33-22a74864bf22`、version 1、标题前缀 `DBACC_20260923_`，随后在公告列表中读到同一 ID。
- 停止首个 API 进程 PID 29436 并重启为 PID 30244；重启后健康检查仍返回 `repository=DATABASE`、version 182。重新模拟登录后，列表读回同一 runtime ID、原标题和原正文，证明数据不是进程内存临时状态。
- 后续执行者明确回报步骤 4 已完成 API 编辑并通过 SQL 回读，步骤 5 已完成 API 删除且活动列表不可见、规范表软删除可查。步骤 4/5 的详细 HTTP 响应体未留存，因此本记录不补写未知字段或状态码。
- 清理前只读边界：`P4RUN_STATE.version=187`，本次测试物理公告 1 条、关联审计 3 条、JSON `announcements=0`、`announcementTrash=1`。
- API PID 30244 已停止；接续复核确认 4011 无监听端口。
- 精确清理完成后 `P4RUN_STATE.version=188`。按 runtime ID 与标题字面前缀复核，`announcement`、`announcement_attachment`、`announcement_read_receipt`、`audit_event`、JSON `announcements` 和 `announcementTrash` 中本次测试残留均为 0。
- 清理后历史基线保持：公告共 9 条，其中活动 8、软删除 1；历史阅读回执 6 条。接续任务发现目标已被前序清理移除，因此未再次执行删除事务，避免重复修改。
- 验收结论：通知公告第一阶段已取得真实 DATABASE 健康检查、模拟登录、HTTP 创建、列表读取、进程重启后读回、API 编辑+SQL 回读、API 删除+软删回读以及测试数据清理证据。其它业务模块已完成数据库迁移与初始化，但真实 API CRUD/重启读回仍为后续待办。
# 2026-09-25 本地管理账号字段补齐

- 已确认问题：新增本地管理用户的表单只暴露姓名，无法明确录入独立的登录账号。
- 根因：新增模式实际值为 `createLocal`，账号输入框却按不存在的 `create` 模式判断可编辑，导致新增时始终禁用；姓名框不受影响。
- 已修复账号框启用条件；服务端同时加强账号/姓名字符串必填校验、账号去空格及大小写不敏感去重，模拟登录策略保持不变。
- 持久化边界：账号和姓名写入数据库 `portal_runtime_entity` 的 `users` 运行实体，同时同步 `unified_user` 基础记录；测试覆盖生成 SQL 与重新加载回读。当前真实凭证仍按既定范围不接入。
- 验证：定向测试 8/8、全量测试 232/232、生产构建通过；浏览器 DATABASE 模式下弹窗显示两个独立可输入框，并成功分别输入 `local_acceptance` 与“本地账号验收”，随后取消，未产生测试账号。
# 2026-09-25 本地账号密码弹窗

- 已登记需求：管理端重置密码改为输入新密码；顶部修改密码增加弹窗功能。
- 安全边界：继续使用 Mock 登录，不接入真实凭证认证；明文密码仅用于本次提交校验，不进入数据库、日志和接口响应。

# 2026-09-28 功能与阶段复核

- 已移除本地管理账号表单、详情、重置密码和自行修改密码弹窗中的演示/技术性提示，并把成功提示改为“记录已更新”，未宣称真实凭证已修改。
- 修复状态转换：重置后 `mustChangePassword=true`，自行修改成功后为 `false`；定向测试验证状态持久化与明文不进入响应、运行实体及审计。
- 首次全量测试因旧静态断言要求已移除的单一 CSS class 而 234/235；同步更新为仍保留的外部身份来源提示 class 后，235/235 全部通过。生产构建及 `git diff --check` 通过（构建仅有原有大包提示）。
- 现有本地服务健康检查为 `repository=DATABASE`、`nocodb_data.pb3gir75kkooyea`、version 397。未对共享数据库执行本轮密码写入。浏览器权限检查不可用，最新弹窗外观及现场数据库写入/读回未验，未绕过权限控制。
- 阶段口径：9 月 24 日 Gate 已记录 P4 PASS、P5 演示版冻结；本轮回归未发现自动化阻断，可继续按“数据库演示原型 P4/P5 已达成”定位，但 9 月 28 日增量页面人工验收尚未补齐，不能宣称生产级 B/C 或真实认证、外部联调完成。

# 2026-09-28 阶段收口追加确认

- 用户再次明确：上下游本阶段仅预留接口与配置页面；登录和密码更改均为演示页面，可不写入数据库。现按此边界复核 P4/P5 完成度，准备更新阶段档案。
- 阶段档案已同步 P4 Gate 通过、P5 演示闭环，旧 B/C 计划加历史适用说明。文档更新后首轮测试因旧静态断言仍要求 `A3_IN_PROGRESS` / `MEMORY_A` 而 234/235；已改为核对当前 Gate 与显式 Mock 启动口径，待复跑。
- 静态断言调整后全量 235/235 通过；`npm run build` 成功（仅大包体积提示）。服务健康检查 `repository=DATABASE`、schema `pb3gir75kkooyea`。阶段结论为 P4 Gate PASS、P5 本地数据库演示闭环可进入下一阶段范围定义；旧生产级 B/C 未宣称完成。

# 2026-09-28 公众门户首次二级页导航故障

- 用户报告公众门户与管理端样式不同；公众门户首次打开二级页失败，刷新浏览器后正常。现开始沿首次导航/会话/数据加载链路排查，暂未确认根因。
- 代码追踪：公众首页单独路由，二级页首次挂载嵌套路由布局；待办页 Teleport 标题目标位于布局内的条件 Banner 分支，首次渲染可能在父布局插入 DOM 前查找目标。已仅对待办 Teleport 加 `defer`，未改页面样式或其他读请求。新增源码回归 2/2，构建成功。
- 本地开发服务起初未监听 4010/4011，代理因此返回 502；确认 `postgres14` 容器运行后启动标准 `npm run dev`，健康检查 `repository=DATABASE`、version 428，二级页直达 HTML 状态 200。浏览器权限检查仍不可用，无法完成 UI 首跳现场复现/验收。
- 当前全量 262 项测试中 256 通过、6 失败，失败集中在此前页面源码断言（兼容路由、公告详情、Loading、公众列表、首页卡片、待办字段）；本轮仅改一行待办 Teleport 和新增测试，这 6 项不应冒充本次回归通过，暂不扩改非目标文件。已请用户确认故障是否只发生在待办页。

# 2026-09-28 二级页 Banner 尺寸核对

- 用户询问“我的申请、应用中心”等公众二级页 Banner 的当前尺寸和比例；已开始只读核对页面容器规则与图片素材尺寸，不修改页面。
- 已确认我的申请与待办共用 banner-todos.png，应用中心独用 banner-apps.png；四张二级页素材均为 2172×724（3:1）。显示容器随视口宽度变化，桌面最大宽 1440px、最小高 132px，窄屏最小高 110px，background-size:cover 居中裁切。未修改样式或图片。

# 2026-09-28 公众二级页 Banner 自适应

- 用户要求 Banner 按“最短自适应”并居中；已登记修改任务并询问其对留空与铺满裁切的偏好，现核对既有布局和响应式规则。
- 用户明确选择“铺满横幅、可裁切”。仅在公众二级 Banner 专用规则增加约 10:1 自适应比例与 `background-position:center center`，继续沿用 cover；桌面最低 132px、窄屏最低 110px，内层文字和按钮仍可撑高。未改用户已修改的 `src/assets/banner-todos.png`，构建产物包含当前素材。
- 新增 Banner 定向断言通过；构建通过。全量 263 项中 257 项通过、6 项失败，与前轮同一组非 Banner 页面断言。浏览器安全权限检查仍不可用，未完成现场桌面/窄屏视觉验收，不作已视觉通过声明。

# 2026-09-28 业务状态与待办类型字典化

- 用户要求仔细分析系统，把常用状态与待办任务类型纳入字典管理并由业务页面引用。现先盘点业务规则、字典模型及数据库现状；尚未修改字典数据和状态机。
- 当前真实数据库只读核对：字典 6 类/22 项；活动待办仅“服务事项”业务类型，状态 PENDING 25、COMPLETED 4、WITHDRAWN 4、历史 EXPIRED 4。字典条目存于逐实体 JSONB 表，不会随 seed 改动自动补入旧库；准备采用幂等补种并保留既有管理端修改。现行 TODO 接收协议不接受 EXPIRED，因此只作历史展示字典项。
- 已完成代码/页面状态盘点：优先纳入待办状态与任务类型、消息类型与已读状态、公告状态、应用申请/账号开通/账号映射状态；现有启停/运行状态继续沿用。业务状态编码受控，只开放字典标签/排序/启停等显示配置。
- 现库更新前已对 `nocodb_data.pb3gir75kkooyea` 完成完整 schema 自定义格式备份 `database/backups/uhp-dictionary-preapply-20260929.dump`（3,390,333 字节），`pg_restore -l` 可读且列出 633 个目录项。实际字典补种尚未执行。
- 2026-09-29 已执行受控增量：从 version 476 补入 10 类/36 项，现库读回 16 类/58 项、version 477；再次预览新增为空，未覆盖原 6 类/22 项。前端接入与全量回归仍在进行。
- 待办接收现支持可选 `businessType`，缺省仍为“服务事项”；启用字典项可选，未知/停用项拒绝，同源待办不可改类型，旧 receipt 幂等重放兼容。TODO 状态仍限 PENDING/COMPLETED/WITHDRAWN。公众及管理页面共用只读字典，待办类型已接入列表、详情、筛选和本地录入。
- 最终字典专项 10/10、生产构建通过、`git diff --check` 通过；全量 300 项中 287 项通过，13 项为既有 UI 精确断言/互斥基线问题，本轮新增的旧断言失配已修正。现场浏览器跨页验收未完成，不记为已视觉通过。
- 修改前运行的 4011 本地 API 已定向重启，标准 `npm run dev` 重新拉起 Vite 和数据库模式 API；健康检查读回 `repository=DATABASE`、`nocodb_data.pb3gir75kkooyea`、version 482。构建过程生成的 `dist` 文件已精确还原/清理，仅保留源码、测试、文档和备份。
- 最终复核发现 1 项公告发布方式的旧静态断言仍要求硬编码单选值；已把断言对齐字典选项与原有两种业务值，复跑恢复到 300 项中 287 通过、13 项既有失败。未改变公告发布状态规则。

# 2026-09-29 管理端头部与个人信息框架修正

- 用户要求移除管理端顶部用户切换、统一公众门户消息图标，并让管理端个人信息留在管理框架。已读取项目教训和既有计划，确认工作树保留上一轮字典化改动；本轮仅处理头部/个人信息路由与必要测试，先核对实际组件链路。
- 管理端 `App.vue` 已移除用户 `t-select`、切换处理及专用样式；保留用户端/管理端切换按钮。管理个人信息进入隐藏 `/admin/profile` 路由，复用原个人信息组件与管理 shell；LOCAL 管理账号在个人信息中显示本地账号类型及本地维护说明，公众端资料分支保持原样。
- 公众首页和二级页头部消息图标统一为管理端 `MailIcon` 16px，通知公告图标不变。定向回归 4/4、构建及 `git diff --check` 通过；全量 304 项中 291 通过、13 项为既有 UI 基线断言失败。开发服务对 `/admin/profile` 返回 HTTP 200，但不替代页面视觉验收。
- Tabbit 稳定入口在默认及经审批的只读诊断中均遭拒绝/失败，按技能排障边界未绕过或更换浏览器后端，故本轮无现场视觉验收。构建生成的 `dist` 文件已精确恢复与清理。

# 2026-09-29 子系统账号开通申请详情字段调整

- 用户指定申请信息五行、处理信息两行，并询问创建时间/申请时间是否等同、处理人是否需落库。已读取教训，确认本轮开始时工作树保留前两轮字典与头部修改；先核对模型/API/数据库字段语义，再做精确改造，不覆盖这些既有改动。
- 只读核对完成：规范表已有 `created_at/submitted_at/handled_by/handled_at/handle_note`，当前三条申请创建与提交时间相同；处理人 ID 在处理中/已完成记录均已持久化并关联周明。无需新增数据库列，详情将只展示申请时间并从处理人 ID 解析姓名；处理中无 `handledAt` 则如实展示“-”。
- 当前源码已有专用开通申请详情与 `handledByName` DTO；复核发现原申请区第二行被误排为三列、第三行只有统一身份标识，已精确改为第二行申请人/来源应用、第三行联系方式/统一身份标识，首行三列及后三个通栏保持不变。
- 独立物理 SQL 与数据库 Repository→服务 DTO 只读回查均通过：3 条申请的创建/提交时间相同；待处理无处理人，处理中/已完成显示“周明”，处理中无处理时间。未修改真实库记录。
- 定向回归 7/7、生产构建通过；全量 329 项中 308 通过、21 项失败，失败集中在本轮以外的 UI 基线断言。为运行全量测试，修复既有测试文件一处缺右括号的语法错误；当前任务相关测试全部通过。
- 收尾期间另一进程将构建产物提交到当前 HEAD，清理动作一度使三个已跟踪 `dist` 文件显示变更；已严格按最新 HEAD 原始 LF 恢复，工作树不再残留该清理改动。未覆盖其它并发提交。

# 2026-09-29 列表表头与开通申请展示调整

- 已读取项目教训并登记本轮目标。当前仅处理页面展示及排序入口；既有 `doc/progress.md`、`doc/task_plan.md` 修改予以保留。待核对组件与表头实现后分工修改。
- 已核对 15 处表格入口均为 TDesign 表格；开通列表列定义和指定排序列已定位。两个互不重叠的页面改动分工处理中，主线程负责范围与回归核查。
- 开通详情字段顺序已交换，管理端开通申请列表已移除“处理说明”；复核发现公众“我的申请”中开通列表仍有该列，已追加同范围修正。表头与排序分工已实现初版：全局表头单行、用户启用状态取消排序、组织全列取消排序；角色说明原本没有排序。正在补定向验证。
- 两侧开通列表均已移除处理说明列，详情及数据 DTO 保留处理说明。定向 6/6、生产构建、`git diff --check` 通过；全量 333 项中 312 通过、21 项失败，与前次相同数量，且已将一条旧字段顺序断言更新为本轮要求。构建生成的 `dist` 变更及新增哈希产物已精确清理，未改数据库；本轮未进行浏览器现场视觉验收。

# 2026-09-29 管理首页接入异常应用去重

- 已读取项目教训并登记目标。本轮只调整管理首页顶部指标口径与名称，不更改数据库数据或右侧异常明细。现核对服务端聚合与前端卡片绑定。
- 已确认旧口径是三类接入服务异常项数相加，同一应用可重复。分别处理服务端按应用去重字段与顶部卡片绑定/文案，保留旧字段及右侧异常明细语义；既有工作树的上一轮改动保持原样。
- 用户进一步明确指标应直接取应用列表“综合运行状态=异常”。暂停原“任一子服务异常”口径的收尾，先把纠偏写入 `doc/lessons.md`，待核对应用列表状态计算后统一来源。
- 已按纠偏完成：`adminHome.abnormalApplicationCount` 直接筛选管理应用列表同源 DTO 的 `aggregateRuntimeStatus==='ABNORMAL'`，前端顶部名称与提示同步。原 `abnormalServiceCount` 供旧消费者保留，右侧异常明细未动。专项定向 3/3、构建通过；全量 334 项中 313 通过、21 项既有 UI 基线失败。构建生成的 `dist` 改动已精确清理，无数据库写入。

# 2026-09-29 应用综合状态与运行监控一致性及正常样本

- 已读取教训和当前工作树，登记真实数据库盘点、备份、受控正常样本及跨模块读回任务。先核对现场数据与已有状态计算，不先写库，也不假定全部应用都异常。
- 真实库只读确认 42 应用中综合状态为异常 30、正常 10、停用 2；并非全异常。源码和回归确认应用列表与运行监控共用 `integrationState`，已补跨模块一致性测试；监控详情曾因未配置状态遮盖已有运行值，现已修正并补测试，专项 11/11 通过。
- 已选定无关联待办、消息、映射、申请/授权及近期人工编辑的 APP_18 TODO、APP_19 SSO、APP_21 MESSAGE 作为三类正常演示样本，现执行完整备份与版本门禁后才允许精确写入；尚未声称数据库已更新。
- 写前完整数据库备份已生成并验证可读：`database/backups/uhp-status-preapply-20260929-154448.dump`（3,394,322 字节，SHA256 `222E467304694B957EB6F3740E04139C196C9FCA4427C09C1893698ACDEA3125`，633 项）；基线运行态版本 492、摘要 `8224af486ec18ca4938e5dfa973c2a4c`。受控脚本只读预览 `safe=true` 且恰好 3 行候选，尚待事务写入和读回。
- 受控事务已在备份摘要、快照版本/摘要及目标三层行摘要门禁下执行，恰改 APP_18 TODO、APP_19 SSO、APP_21 MESSAGE 三项运行态 ABNORMAL→NORMAL；运行实体、快照与物理配置镜像同步，运行态版本 492→493。新进程 Repository 读回 42 应用 NORMAL 13 / ABNORMAL 27 / DISABLED 2，管理首页异常应用 27；再次预览 `safe=true,pending=0`。不把“正常”演示状态解释为真实上游已连通。
- 主线程独立以新进程重新加载真实数据库：三目标应用综合均 NORMAL，对应监控分别 NORMAL/NORMAL/DISABLED、NORMAL/DISABLED/UNCONFIGURED、UNCONFIGURED/NORMAL/NORMAL；首页异常应用 27。受控脚本只读重跑仍 `safe=true,pending=0`，证明幂等且已持久化。专项一致性测试 2/2、相关业务定向 11/11、构建及脚本语法通过；全量 336 项中 313 通过、23 项既有/并行 UI 基线失败。并行提交改动了非本任务的开通详情字段布局，本轮未覆盖；浏览器现场视觉未做。构建生成的 `dist` 文件已精确清理。
