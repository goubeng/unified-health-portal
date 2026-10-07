# TODO 接入规范

> **实施边界（2026-10-01）：**下述 `/api/integration/v1/*` 为正式目标路径。当前仅有本地演示接收器 `POST /api/portal/ingest/{appId}/todos`，以配置的服务端凭据引用进行 Bearer 校验；最小入参实际为 `eventId`、`sourceTodoId`、`userId`、`status`、`title`，`businessType` 可选。目标协议的 `appCode`、`receiverIdentity`、`actionPath`、`sourceUpdatedAt` 等字段不能当作现行 API 必填项，也未完成真实子系统联调。

## 1. 原则

子系统是待办业务状态的权威来源，门户只保存统一展示投影。门户“去处理”不改变待办状态。

## 2. PUSH

目标接口：
- `POST /api/integration/v1/todos`
- `POST /api/integration/v1/todos/status`

子系统主动推送，门户本期不轮询。

## 3. 最小字段

- requestId/eventId；
- appCode；
- sourceTodoId；
- receiverIdentity；
- title；
- businessType（可选）；
- description/summary；
- actionPath；
- status；
- sourceUpdatedAt。

不要求 priority、dueAt、逾期、sourceRevision、terminalAt。

## 4. 状态

首期统一：
- PENDING：待处理；
- COMPLETED：已处理；
- WITHDRAWN：已撤回/失效。

PENDING 可进入终态；终态原则上不回退。若来源系统需要纠错，必须走明确的纠错机制并审计。

## 5. 唯一与幂等

- `application + eventId`：接收请求幂等；
- `application + sourceTodoId`：识别同一来源待办。

重复 PUSH 不得产生重复业务记录。

## 6. 接收人

不能仅用姓名匹配。无法定位用户时返回明确错误，不允许静默丢弃。

## 7. 去处理

门户根据应用、账号映射和 actionPath 生成 SSO 跳转。点击“去处理”只记录访问，不执行 COMPLETED。
