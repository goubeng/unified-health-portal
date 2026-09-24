# 执行进度

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
