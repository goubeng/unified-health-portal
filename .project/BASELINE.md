# 当前设计标识与冻结状态

- 当前目标设计标识：V20260920-03
- 当前代码版本：0.2.0（P4 Mock可运行基线）
- 下一阶段目标：0.3.0（分阶段执行中）
- 日期：2026-09-20
- 状态：Draft / 0.3.0-A Frontend Mock IN_PROGRESS
- Release Candidate：尚未生成

## 当前身份基线

- MINZHENGTONG → CITIZEN / 公众用户
- MINZHENGWU → GOV / 政务用户
- PORTAL_LOCAL → LOCAL / 门户本地用户

## 当前角色基线

默认只预置SUPER_ADMIN和PORTAL_ADMIN，保留MENU/PAGE/ACTION RBAC扩展能力。

## 当前事实

- P3数据库历史验收事实保持不变；
- P4 Mock代码仍未实现V20260920-03全部目标；
- LOCAL本地凭证、应用申请、组织、字典、公告新状态机、真实RBAC等仍待Migration和代码；
- 系统分类最终迁入字典管理。

## 当前权威文档

1. `docs/README.md`
2. `docs/01-需求/02-当前基线/统一门户系统需求规格说明书_V1.0.md`
3. `docs/01-需求/02-当前基线/细化需求/角色清单.md`
4. `docs/01-需求/02-当前基线/细化需求/功能清单.md`
5. `docs/02-开发/03-计划/下一阶段整改需求说明_V1.1.md`
6. `docs/02-开发/01-设计/`

历史需求、P1/P3阶段基线和Review只用于追溯。

## 0.3.0 分阶段执行

- 0.3.0-A：前端Mock原型改造，当前IN_PROGRESS；**禁止数据库写入/迁移**。
- 0.3.0-B：数据库改造，NOT_STARTED；仅明确进入B后允许访问本地PostgreSQL/NocoDB。
- 0.3.0-C：真实Provider与外部系统联调，NOT_STARTED。
- 执行依据：`docs/02-开发/03-计划/0.3.0分阶段改造执行计划.md`。
- 当前进度：`docs/02-开发/04-过程记录/0.3.0-A前端改造进度.md`。

