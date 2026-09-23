# 本轮发现

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
- 当前附件沿用 JSONB 保存页面 data URL，可满足本地演示与 CRUD 闭环，但不是生产文件存储方案；后续对位 NocoDB/对象存储时需保留当前 DTO 而替换附件内容载体。
- 默认 `npm run dev` 使用内存 Repository；只有 `npm run api:db` 才进入数据库模式，验收必须明确区分。
- 数据库模式当前从 `P4RUN_STATE` JSON 快照加载，提交后仅镜像部分规范表；除审计日志外，尚未以规范业务表作为读取真相源。
- 公告 DTO 比现表多定时发布、提交/撤回/最后编辑、附件、用户已读和删除归档信息；现有镜像会丢失这些字段。
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
