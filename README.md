# 卫健XC统一门户 · P4交互原型

当前代码版本 0.2.0，Vue3 + Vite + TDesign。P3历史验收已完成，P4核心Mock可运行；下一阶段目标设计为 V20260921-01，尚不是生产发布包。

## 文档入口

项目人工文档统一从 [docs/README.md](docs/README.md) 进入；当前唯一权威需求为 `docs/01-需求/02-当前基线/卫健统一门户系统需求规格说明书.md`。

文档已经按生命周期分为：

- `docs/01-需求/`：原始需求、唯一当前需求基线、细化辅助材料和接入资料；
- `docs/02-开发/`：开发设计、评审、下一阶段计划、过程记录；
- `docs/03-交付/`：仅用于最终冻结交付文档。

## 本地运行

Node.js 20.19+或22 LTS，首次执行 `npm ci`。保持两个终端运行：

1. `npm run api`：本地服务4011，**默认使用0.3.0-A纯内存Repository，不访问PostgreSQL/NocoDB**；
2. `npm run dev`：前端监听 `0.0.0.0:4010`；本机可访问 `http://127.0.0.1:4010`，同一局域网用户可访问 `http://<本机局域网IPv4>:4010`。

仅在明确进入0.3.0-B/C数据库阶段后，才允许执行：

```bash
npm run api:db
```

`api:db` 会连接当前项目既有本地PostgreSQL/NocoDB数据源，A阶段禁止使用。

健康检查 `/api/portal/health` 会返回 `repository=MEMORY_A` 或 `DATABASE`，用于确认当前运行模式。

## 局域网访问

当前本地开发网络策略：

- 前端：`0.0.0.0:4010`，允许同一局域网访问；
- API：`127.0.0.1:4011`，只允许本机直接访问；
- 浏览器所有 `/api/portal` 请求由 Vite 代理转发到本机 4011；
- API 仅接受来自 `4010` 的 localhost 或 RFC1918 私有 IPv4（`10.x`、`172.16-31.x`、`192.168.x`）页面 Origin。

在 Windows 上执行 `ipconfig` 获取本机 IPv4，例如 `192.168.1.100`，局域网其他设备访问：

```text
http://192.168.1.100:4010
```

如果无法访问，请确认 Windows 防火墙允许 TCP 4010 入站。无需对局域网开放 4011。

构建：`npm run build`；测试：`npm test`；P3静态校验：`npm run check:p3`。

## 当前实现边界

当前登录、SSO、子系统账号核验、PUSH外部联调仍以Mock/本地契约为主，不代表正式生产集成。

最新目标身份与授权模型为：

- 闽政通 → CITIZEN / 公众门户访问主体；
- 闽政务 → GOV / 政务门户访问主体；
- 门户管理用户由独立的 `portal_admin_user` 管理授权域承载；
- LOCAL 仅表示门户本地管理认证方式，不是第三类普通访问用户；
- 管理用户可通过 EXTERNAL 绑定现有访问主体，或使用 LOCAL 本地管理账号。

默认门户角色收敛为 SUPER_ADMIN 和 PORTAL_ADMIN；门户权限采用 `resource:action` 权限码，子系统业务角色和业务权限仍由各子系统负责。

0.3.0-A 前端 DTO 已按 V20260921-01 冻结：管理用户/访问主体分离、应用 `enabled`、接入 `configStatus/enabled/runtimeStatus`、TODO/消息 `receivedAt`、公告 `status + displayStatus` 及拆分 Session 模型已进入 Mock/Service。正式数据库表与 REST API 仍需在 0.3.0-B 实施。

## 历史验收

- [P4本轮整改验收](docs/02-开发/02-评审/P4本轮整改验收.md)
- [P3整体验收](docs/02-开发/02-评审/P3整体验收.md)

P4不等于生产联调或最终验收；P7/P7.5冻结、正式用户手册、测试交付、部署包等后续统一进入 `docs/03-交付/`。

## 本地原型运行

安装依赖后直接执行：

```bash
npm ci
npm run dev
```

`npm run dev` 会同时启动：

- 前端：http://127.0.0.1:4010
- 本地 Mock API：http://127.0.0.1:4011

无需再单独执行 `npm run api`。如4011上已经存在可用的本地 Mock API，开发启动器会直接复用。
