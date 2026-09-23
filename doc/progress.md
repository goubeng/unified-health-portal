# 执行进度

## 2026-09-23 数据库改造与真实 CRUD 接入（进行中）

- 已读取历史教训和现有过程记录。
- 已确认本轮范围：登录保持模拟；通知公告 CRUD 为第一优先级；其他业务满足前端演示基本闭环；上下游仅预留接口。
- 正在核查现有 schema/migrations、Repository/API、Mock/HTTP Provider 和页面实际调用链。
- 尚未执行数据库写入，不宣称任何真实 CRUD 已通过。
- 已完成通知公告页面→Runtime→API→Service→Repository→Schema 的调用链审计：当前 DATABASE 模式仍以 `P4RUN_STATE` JSON 为读取真相源，规范化公告表仅为不完整镜像。
- 正在实施通知公告第一阶段真实数据库 CRUD：扩展公告字段、新增已读回执表，并使 DATABASE Repository 直接回读和完整持久化公告聚合。
- 已新增 `database/migrations/005_announcement_runtime_crud.sql`：幂等扩展定时/提交/撤回/编辑/软删除字段与稳定 `runtime_id`，新增 `announcement_read_receipt`，并从旧 `P4RUN_STATE` 导入定时字段、附件和已读回执。迁移文件尚未对真实数据库执行。
- 已改造 `server/repository.mjs`：DATABASE load 以规范化公告/附件/已读表覆盖快照中的公告聚合；commit 在原事务中完整同步活动公告、软删除归档、附件和已读回执，不再物理删除公告。
- 已新增公告数据库映射专项测试，3/3 通过；既有公告/Portal聚焦测试 36/36 通过；`node --check server/repository.mjs` 与 `git diff --check` 通过。
- 完整 `npm test` 为 185/188 通过；3 项失败为本轮改动外的既有 UI 间距断言和 REQUEST/REQUEST+BIND 接入状态期望不一致，本子任务未改动相关文件。
- `npm run build` 已通过（Vite 6004 modules transformed）；仅有现有大 chunk 超过 500 kB 的构建警告。
- 未执行真实 Migration、未写入真实数据库，因此仍不宣称数据库 CRUD 已环境验收。
- 只读盘点确认现库 `P4RUN_STATE.announcementTrash` 有1条历史归档，规范化 `announcement` 无对应软删除行；005 已补充幂等导入，包含基础/定时/提交/撤回/编辑/删除字段，用户外键仅在目标用户存在时写入，且以 `WHERE NOT EXISTS` + `ON CONFLICT DO NOTHING` 保证不覆盖数据库已有版本。
- 005 的附件导入已同时覆盖 `announcements` 与 `announcementTrash`，使补入的历史归档可恢复附件关联。新增迁移边界测试后公告数据库专项测试 4/4 通过，`node --check` 与 `git diff --check` 仍通过。
- 只读审计完成：前端已统一走 HTTP，但 DATABASE Repository 仍从 `system_config.P4RUN_STATE` 读取整包状态，规范表只是部分镜像。
- 已确定第一阶段实施边界：通知公告切换为规范表直接读写；其他模块暂保留兼容状态，后续按应用/消息/待办/申请顺序迁移。
- 正在实施公告字段迁移、附件/阅读/归档表、Repository 映射与数据库集成测试。
- 已完成当前真实数据库只读盘点：确认 PostgreSQL 14.20、目标 schema 存在、32 张表、199 项 `p3_%` 约束及 004 字段/注释均可识别；002 原始索引名虽不存在，但等价 BOUND 唯一部分索引存在。
- 已只读核对公告数据：主表 8 行、组织范围 2 行、附件 0 行；公告状态为 DRAFT 3 / PUBLISHED 4 / WITHDRAWN 1，公告 ID 全部为 `P4FIX_%`。
- 已只读核对 `P4RUN_STATE`：记录存在、version 180、value 为 JSON object；其中仍有公告 8、阅读回执 6、删除归档 1 等运行态数据。
- 已统计 32 表共有 467 条 `P4FIX_%` 演示镜像记录；下一步迁移必须先备份、识别演示/保留数据边界，再进行任何结构或数据写入。
- 本次盘点仅执行 `SELECT` 元数据/计数查询；数据库写入、Migration、Seed、DDL、DML 均为 0。

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
