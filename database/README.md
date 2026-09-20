# P3 数据库交接与初始化

目标PostgreSQL 14，正式部署必须在NocoDB base `pb3gir75kkooyea` 的本地原生source创建，不关联外部数据库。

状态分开记录：
- 主线程最新报告：已鉴权，base标题“卫健XC统一门户”，source `bojz43pok1w9vqa`，type=pg、is_local=true、is_schema_readonly=false、is_data_readonly=false，首次鉴权成功表列表为空。
- 此前HTTP401只是首次检查历史，已解除鉴权阻塞。
- 本文及JSON为设计，实际表ID、创建结果、约束安装和目标版本由主线程回读记录。这里未宣称建表成功。

## 文件与迁移

| 文件 | 用途 |
|---|---|
| schema.sql | PostgreSQL14全量初始结构，仅空schema |
| migrations/001_initial.sql | 同一初始迁移，与schema.sql字节相同；二选一，不能连续执行两遍 |
| migrations/002_bound_account_unique.sql | 旧结构补BOUND账号部分唯一索引；全新schema/001已包含，不能重复执行；原生库尚未执行 |
| seed.sql | 12个UNCONFIGURED配置键；ON CONFLICT(code) DO NOTHING，不覆盖现有配置 |
| ../docs/development/nocodb-schema.json | 冻结原生字段与约束计划；不是现网API请求体 |
| ../docs/development/nocodb-seed.json | 相同12条原生数据API种子设计 |
| ../docs/development/mock-schema.json | 输出DTO及Mock数据集映射的JSON Schema，非正式种子 |
| validation/verify-design.mjs | 无网络、无数据库写入的产物一致性检查 |

数据库基线v0.1.0，初始迁移001。今后结构修改新增002等迁移并同步字段文档，禁止直接重跑001覆盖已存在原生表。迁移记录由实施环境保留执行者、时间、SQL SHA256、目标base/source/物理schema和结果；不能只留下本机结构。

## PostgreSQL14隔离初始化（由有权限的实施者执行）

仅对已批准的空测试数据库；不要将该库关联到目标base。连接地址由实施环境PGHOST/PGPORT/PGDATABASE/PGUSER设置，认证走PGPASSFILE等安全机制，不把密码写入文档。

```powershell
psql -X -v ON_ERROR_STOP=1 -c "SHOW server_version;"
psql -X -v ON_ERROR_STOP=1 -f database/schema.sql
psql -X -v ON_ERROR_STOP=1 -f database/seed.sql
psql -X -v ON_ERROR_STOP=1 -f database/seed.sql
psql -X -v ON_ERROR_STOP=1 -c "SELECT count(*) FROM system_config;"
```

预期版本14.x；种子重复后仍12条（空初始库）。默认事务失败整体回滚；禁止把错误忽略继续。schema.sql不使用IF NOT EXISTS隐藏结构漂移。迁移方式改用001_initial.sql时不要再执行schema.sql。

## 原生NocoDB可复现创建顺序

1. 在指定入口确认base/source与上述身份一致，保存元数据快照；只用已鉴权会话/服务端token，不新建base或external source。
2. 按JSON tables数组顺序创建32个原生表。保留平台自身记录主键，另外创建业务id字段；每个业务id唯一且必填。数组顺序满足被引用表先创建。
3. 按fields逐列落地name、类型、required、default和enum。string→SingleLineText，长正文/摘要按实际长度选LongText，枚举→SingleSelect；datetime→DateTime且保留时区；integer→整数Number；json→可验证JSON文本或实际支持的JSON类型。announcement_attachment.attachment必须使用Attachment，上传后写返回对象数组。
4. references仅表达业务ID引用；本项目不建立Link/Lookup关联字段。DTO中的*_id表示目标业务id，不得填入平台自增nc_id；SQL外键是完整性约束设计，不代表关联其他库。
5. SQL约束不能因元数据API缺能力而省略。回读并核验业务id唯一/NOT NULL、FK、复合唯一、CHECK、索引和时间/JSON类型。必要时对该原生source的实际物理表执行经授权的约束迁移，先发现真实schema/table/column映射，再生成审查脚本；不能把这里的逻辑表名直接套到未知物理表。不得删除平台自带主键或操作NocoDB系统元数据。
6. 插入nocodb-seed.json中的12条配置，以code查询缺失后插入并由唯一约束兜底；冲突回读，绝不覆盖已有有效值。所有status=UNCONFIGURED、value=NULL，不装真实业务记录。
7. 导出实际tableId/columnId/recordId映射及约束证据交Provider。核对32表、356个业务字段（不含平台系统列）、12个配置键；不创建Link辅助列。
8. 在明确授权的隔离测试数据中验证重复源键拒绝、外键拒绝、状态CHECK拒绝、并发幂等及读隔离，再清理测试数据并回读。尚未执行的项必须标“未验证”。

界面显示枚举不能替代SQL CHECK，查重不能替代SQL UNIQUE。原生存储已确认为pg并不等于已证明其字段对应本设计PostgreSQL14类型、支持事务或约束已安装；这些是实施验收项。若原生字段能力与计划不兼容，报差异给主线程，不修改冻结计划继续猜测建表。

## 2026-09-18 实际实施更新（优先于前述初始状态）

已在指定本地source原生创建32表356业务字段，无Link/Lookup；12项未配置参数写入并重复执行确认无新增。实际表ID/字段ID与验证边界见 `../docs/review/P3建表与验证记录.md` 和 `../doc/nocodb-readback.json`。

后续验收已执行`003_native_constraints.sql`：实际PG14.20、固定schema `pb3gir75kkooyea`，199项约束及支持索引已安装；重复执行核对签名及实际定义通过。13类非法写入反例、有效写入和事务回滚验证通过，P3_TEST_残留0，12配置保留。最新结论见`../docs/review/P3整体验收.md`。

新增文件：`validation/generate-native-migration.mjs`输出003；`validation/native-acceptance.sql`执行事务隔离反例并回滚。原生表只执行003，不重跑001/002；002的部分唯一规则已包含在003中。`schema.sql`/001面向空schema的独立初始化尚未单独运行，不混称为已在目标库执行。

真实后端跨表事务、并发事件处理和现场联调尚未实现。NocoDB多个HTTP写请求不构成事务；后续服务端必须用原生PG连接和受控事务实现，不向前端暴露管理Token。
