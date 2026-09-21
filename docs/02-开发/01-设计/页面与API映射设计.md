# 页面与 API 映射设计

> 适用基线：V20260921-01（目标设计）。本文件描述前端页面与后端能力的目标映射，不代表当前接口已实现。

## 1. 设计原则

- 用户端访问主体与管理端授权主体分离。
- 前端不得根据“政务用户/公众用户”自行推断管理权限。
- 运行状态、配置状态、启用状态分别建模。
- TODO/MESSAGE 的业务权威状态来自子系统，门户仅保存投影。
- 所有管理端写操作同时受“对象状态 + 门户权限”约束。

## 2. API 分区

| 分区 | 用途 |
|---|---|
| `/api/auth/*` | 登录、认证、会话、当前身份 |
| `/api/portal/*` | 用户端首页、个人信息 |
| `/api/todos/*` | 当前访问主体待办 |
| `/api/messages/*` | 当前访问主体消息 |
| `/api/announcements/*` | 用户端公告 |
| `/api/apps/*` | 用户端应用中心 |
| `/api/admin/*` | 管理端 |
| `/api/integration/v1/*` | 子系统接入 |

## 3. 登录端

| 功能 | 目标 API | 说明 |
|---|---|---|
| 创建扫码会话 | `POST /api/auth/qr-sessions` | 闽政通/闽政务 |
| 查询扫码状态 | `GET /api/auth/qr-sessions/{id}` | 待扫码/已扫码/成功/过期 |
| 手机号登录 | `POST /api/auth/mobile-login` | 认证能力由上层提供 |
| 本地管理账号登录 | `POST /api/auth/admin-local-login` | 仅门户管理账号 |
| 当前身份 | `GET /api/auth/me` | 返回访问主体及 adminAccess |
| 退出 | `POST /api/auth/logout` | 注销门户会话 |

`/api/auth/me` 至少返回：访问主体、身份来源、用户类别、是否有管理端访问权、门户管理用户ID（如有）、角色/权限摘要。

## 4. 用户端

| 页面/能力 | 目标 API | 主要数据 |
|---|---|---|
| 首页 | `GET /api/portal/home` | 待办/消息/公告/应用摘要 |
| 待办列表 | `GET /api/todos` | 标题、来源应用、业务类型、接收时间、状态 |
| 待办详情 | `GET /api/todos/{id}` | 待办说明及跳转信息 |
| 去处理 | `POST /api/todos/{id}/open` | 生成 SSO 跳转，不改业务状态 |
| 消息列表 | `GET /api/messages` | 用户级已读/删除状态 |
| 消息详情 | `GET /api/messages/{id}` | 正文、来源、业务跳转 |
| 标记已读 | `PATCH /api/messages/{id}/read` | 当前用户状态 |
| 批量已读 | `POST /api/messages/batch-read` | 当前用户状态 |
| 公告列表 | `GET /api/announcements` | 仅返回当前有效公告 |
| 应用中心 | `GET /api/apps` | 应用 + 当前用户访问能力 |
| 我的应用 | `GET /api/apps/my` | 已具备入口资格/映射 |
| 应用映射 | `GET /api/apps/{id}/mapping` | 当前访问主体映射 |
| 发起关联 | `POST /api/apps/{id}/mapping-requests` | 关联/开户注册流程 |
| 个人中心 | `GET /api/portal/profile` | 外部身份最小展示信息 |

## 5. 管理端

| 页面 | 目标 API | 说明 |
|---|---|---|
| 管理首页 | `GET /api/admin/dashboard` | 聚合指标与接入异常 |
| 用户管理 | `/api/admin/users` | 仅管理 `portal_admin_user` |
| 角色管理 | `/api/admin/roles` | 门户 RBAC |
| 应用列表 | `/api/admin/applications` | 应用自身启停 |
| 连接配置 | `/api/admin/applications/{id}/integrations` | SSO/TODO/MESSAGE 独立配置 |
| 运行监控 | `/api/admin/integrations/monitor` | 运行状态只读、可重新检测 |
| 身份与子系统映射 | `/api/admin/app-mappings` | 访问主体与子系统账号关系 |
| 公告管理 | `/api/admin/announcements` | 草稿/发布/撤回 |
| 日志审计 | `/api/admin/audit/*` | 登录、认证、操作、接口 |

## 6. Mock → 后端替换重点

| 当前能力 | 当前形态 | 正式目标 |
|---|---|---|
| 登录 | 模拟/本地流程 | 上层身份 + 门户会话 |
| 用户端首页 | Mock 聚合 | 后端聚合接口 |
| 待办 | Mock | TODO PUSH 投影 |
| 消息 | Mock | MESSAGE PUSH |
| 应用访问 | Mock 场景 | APPLICATION + MAPPING + SSO |
| 管理用户 | 统一用户模拟 | PORTAL_ADMIN_USER |
| 权限 | 前端控制为主 | 服务端 RBAC |
| 运行监控 | Mock | 集成状态与检测事件 |

## 7. 前端影响

现有页面结构不要求推翻。重点需要校正：

1. 用户管理只展示门户管理用户；
2. 身份与子系统映射只面向门户访问主体；
3. 应用启用状态与接入运行状态分离；
4. SSO/TODO/MESSAGE 分别配置、分别监控；
5. “去处理”不直接把待办改成已处理；
6. 管理端菜单、路由和按钮都需要权限守卫。
