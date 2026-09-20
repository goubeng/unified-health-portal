# 00 · 项目类型 Router

任何项目开始前先判断项目类型，不直接进入 Coding。

## 一、六个入口问题

| 问题 | 选项 |
|---|---|
| 1. 是否已有可运行源码？ | 是 / 否 |
| 2. 本次目标是新建还是修改？ | 新建 / 迭代 |
| 3. 是否存在大量真实 CRUD？ | 是 / 否 |
| 4. 是否以大屏、图表、地图、综合态势展示为主？ | 是 / 否 |
| 5. 是否为了方案、汇报、验收快速演示？ | 是 / 否 |
| 6. 是否同时包含业务后台和驾驶舱？ | 是 / 否 |

## 二、分流规则

### A 新建业务系统

满足：

- 没有现成业务系统，或需要新建一套独立系统；
- 真实 CRUD 是核心；
- 通常需要 PG + NocoDB。

进入：`01-SOP/01_NEW_PROJECT.md`

### B 已有系统迭代

满足：

- 已有可运行代码；
- 本次是修改、增加功能、修复问题、统一样式、调整字段或流程。

进入：`01-SOP/02_ITERATION.md`

### C 快速演示原型

满足：

- 重点是短时间形成可运行、可操作、可汇报的系统；
- 部分业务可以真实 CRUD，部分数据可以 Mock；
- 不追求生产级完整后端。

进入：`01-SOP/03_RAPID_PROTOTYPE.md`

### D 大屏 / 驾驶舱

满足：

- 主要是指标、地图、趋势、排名、告警、资源态势；
- 数据以 Mock / 聚合数据为主。

进入：`01-SOP/04_DASHBOARD.md`

### E 混合型系统

满足：

- 同时存在真实管理后台、CRUD、驾驶舱或综合态势。

进入：`01-SOP/05_HYBRID.md`

## 三、Router 输出

必须生成或更新：

- `.project/PROJECT_PROFILE.md`
- `.project/project.yaml`
- `.project/SCOPE.md`

并明确：

- project_type
- current_stage
- data_strategy
- enabled_common_modules
- base_project
- delivery_level
