# 产品经理 AI Coding 工程体系

> 版本：v1.0.0  
> 核心技术基线：Vue 3 + Vite + TDesign Vue Next + PostgreSQL 14 + NocoDB  
> 适用目标：快速原型、动态 CRUD、演示系统、大屏驾驶舱、已有系统迭代、开发交接与演示环境部署

## 1. 这套体系解决什么问题

这不是一条固定的“从 0 到 1 SOP”，而是一套可长期复用、版本化维护的工程体系。

核心目标：

1. 不再反复向 AI 说明技术栈、UI 规范、数据方式、公共模块和交付要求。
2. 先识别项目类型，再走对应 SOP，不让新项目、迭代项目、大屏项目互相套用错误流程。
3. 所有阶段都有明确的：**输入 → AI 动作 → 输出 → 复核点 → 完成条件**。
4. 业务数据优先使用 PostgreSQL + NocoDB；大屏/演示指标允许 Mock，但统一管理，禁止散落硬编码。
5. 用户、组织、角色、字典、消息等公共模块按需接入，不要求业务未稳定时一次性做完。
6. 状态机、操作矩阵、消息通知、操作履历、权限、统计口径等形成正式“开发交接资产”。
7. 最终交付文档必须基于当前代码、数据库、配置和实际页面行为重新复核后生成，禁止仅依据旧文档“重新编写”。
8. 支持补丁包、全量包、数据库包、部署包、最终文档包的统一版本管理。

---

## 2. 第一次使用怎么开始

### 新项目

先执行：

```text
00-Governance/00_Project-Router.md
```

生成项目档案后，根据项目类型进入：

- `01-SOP/01_NEW_PROJECT.md`
- `01-SOP/02_ITERATION.md`
- `01-SOP/03_RAPID_PROTOTYPE.md`
- `01-SOP/04_DASHBOARD.md`
- `01-SOP/05_HYBRID.md`

### 已有系统迭代

不要重新跑完整新建流程。

直接：

```text
项目现状扫描
→ 影响分析
→ 最小修改
→ 关联检查
→ 回归复核
→ 补丁/全量包
→ CHANGELOG
```

### 大屏/驾驶舱

允许 Mock，但页面不能直接硬编码业务数据：

```text
View
  ↓
Service
  ↓
Mock Provider / API Provider
```

---

## 3. 整体生命周期

```text
P0 项目识别与初始化
 ↓
P1 需求与范围
 ↓
P2 产品与业务设计
 ↓
P3 数据与开发交接设计
 ↓
P4 快速 Coding
 ↓
P5 核心业务闭环
 ↓
P6 系统能力补全
 ↓
P7 一致性复核
 ↓
P7.5 基线冻结
 ↓
P8 最终文档生成
 ↓
P9 发布、打包与部署
```

详细定义见：

`00-Governance/01_Lifecycle-and-Stage-Gates.md`

---

## 4. 项目中建议固定保留的工程档案

```text
.project/
├─ PROJECT_PROFILE.md
├─ project.yaml
├─ SCOPE.md
├─ DECISIONS.md
├─ CHANGELOG.md
├─ BASELINE.md
└─ RELEASES.md
```

AI 每次开始工作优先读取这些文件，而不是重新询问已经确认的信息。

---

## 5. 最重要的原则

### 5.1 当前运行系统才是最终交付真相

最终交付阶段的信息优先级：

```text
1. 当前代码
2. 当前数据库 Schema / Seed / Migration
3. 当前配置与环境变量
4. 当前页面实际行为
5. 已确认的最终设计文档
6. 历史过程文档
```

### 5.2 文档不是一次生成后永远不变

文档分为：

- 过程文档：允许持续修改；
- 当前基线文档：当前版本有效；
- 最终交付文档：一致性复核通过后生成。

### 5.3 公共模块分“底座、预留、后补”

建议：

- 字典：较早接入；
- 用户/组织：有真实引用时接入；
- 角色权限：先基础角色，业务稳定后补完整矩阵；
- 消息通知：先保留消息中心与数据结构，业务稳定后补触发规则；
- 操作日志/审计：按验收或交付需要启用。

---

## 6. 推荐给 AI 的启动指令

```text
请按照本项目的 AI-PM Engineering System 执行。
先读取 .project/project.yaml、PROJECT_PROFILE.md、SCOPE.md、DECISIONS.md 和 CHANGELOG.md，
判断当前项目类型与所处阶段，不要重新询问已经确认的信息。
本次只执行当前阶段要求的工作，并按 Stage Gate 输出规定产物。
如修改影响状态机、操作矩阵、消息、履历、数据库或最终文档，请同步列出受影响资产。
完成后更新 CHANGELOG，并说明版本是否需要升级。
```

---

## 7. 本包目录

```text
00-Governance/        总入口、生命周期、版本、AI协作规则
01-SOP/               五类项目 SOP
02-Development-Handoff/ 开发交接设计资产规范
03-Common-Capabilities/ 公共模块、CRUD、Mock、Service
04-Standards/         技术、UI、数据、目录规范
05-Quality-Delivery/  一致性复核、测试、文档、打包
06-Deployment/        演示环境部署与安装包规范
templates/            新项目可直接复制使用的模板
```
