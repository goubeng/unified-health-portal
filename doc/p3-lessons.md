# 本任务教训与更正

2026-09-17：待办EXPIRED仅由子系统PUSH确认；due_at只产生逾期提示，不能由门户终结源业务。用户再次明确PostgreSQL14目标，首版SQLite参考不适合作为目标Schema，立即替换，且不保留为正式部署方案。

2026-09-17：用户纠正阶段判定：外部 stageContext.js 的 P2 Gate 为设计可开发，运行 Demo 属于 P4。已只读核实外部文件；不得用缺运行 Demo 判定 P2 未完成，也不因此宣称 P2 已验收。

P3 必需提供 database/schema.sql、database/seed.sql；SQL 是可执行参考与隔离验证载体，不能替代 NocoDB 原生元数据建表，更不能将外部数据库绑定到指定 base。P6 完整权限、履历、消息矩阵不在本次交付范围。

2026-09-17：过程文件必须置于 doc/。本任务三个过程文件已按追加授权迁移至 doc/p3-{lessons,progress,findings}.md，不占用主线程 doc/progress.md、doc/findings.md。SQL目标修正为 PostgreSQL 14；目标版本不是现网验证事实。必要唯一性、关联和行内业务约束必须保留在SQL，不能仅以Service检查替代。
