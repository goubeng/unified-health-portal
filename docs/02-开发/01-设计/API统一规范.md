# API 统一规范

> **目标规范与现状区分（2026-10-01）：**以下 `/api/integration/v1/*` 路径、`code/message/traceId` 响应封装及生产鉴权要求是正式接口目标，不能直接用于当前本地服务。现行服务以 `/api/portal/*` 为入口，响应主要使用 `ok/data/error/requestId`；TODO/MESSAGE 本地接收器位于 `/api/portal/ingest/{appId}/...`。以 `server/api.mjs` 与 `src/config/integration-contract.js` 的实际路由和 OpenAPI 为演示环境联调用契约。

## 1. 基础约定

- JSON API；
- 业务字段使用 camelCase；
- 数据库字段可使用 snake_case；
- 时间统一使用 ISO 8601，例如 `2026-09-21T07:00:00+08:00`；
- Boolean 使用 true/false；
- 枚举使用稳定英文编码，中文仅用于展示；
- 外部接入接口从 `/api/integration/v1/` 起做版本化。

## 2. 响应

成功：
```json
{"code":"0","message":"success","data":{},"traceId":"..."}
```

分页：
```json
{"code":"0","message":"success","data":{"items":[],"page":1,"pageSize":20,"total":0},"traceId":"..."}
```

失败：
```json
{"code":"AUTH_PERMISSION_DENIED","message":"无当前操作权限","details":null,"traceId":"..."}
```

## 3. HTTP 状态

| HTTP | 语义 |
|---|---|
| 200/201/204 | 成功 |
| 400 | 参数错误 |
| 401 | 未认证/会话失效 |
| 403 | 已认证但无权限 |
| 404 | 资源不存在 |
| 409 | 状态或版本冲突 |
| 422 | 业务校验失败 |
| 429 | 请求过多 |
| 500 | 内部错误 |
| 502/503 | 外部依赖失败/暂不可用 |

## 4. 查询与分页

统一参数：
- keyword；
- page（默认1）；
- pageSize（默认20，建议最大100）；
- sortBy；
- sortOrder=asc|desc；
- startTime/endTime；
- status；
- enabled。

## 5. 错误码分域

- AUTH_*；
- ADMIN_USER_*；
- APPLICATION_*；
- INTEGRATION_*；
- TODO_*；
- MESSAGE_*；
- MAPPING_*；
- ANNOUNCEMENT_*。

前端只能依赖 `code` 做业务分支，不得解析 message 文本。

## 6. Trace 与幂等

所有请求生成 Trace ID，响应头建议使用 `X-Trace-Id`。

关键写操作和外部 PUSH 支持 `X-Request-Id`。TODO、MESSAGE、回调、映射申请、定时发布必须考虑幂等。

## 7. 并发控制

管理配置类对象建议带 `version`。更新时版本不一致返回 409，避免管理员并发覆盖。

## 8. 鉴权分层

- 用户端：Portal Session/Token；
- 管理端：Portal Session + portal_admin_user + permission；
- 外部接入：AppKey/AppSecret + timestamp + nonce + signature。

三类凭证不得混用。

## 9. 敏感信息

不得在响应和普通日志中输出：
- 明文密码；
- 短信验证码；
- AppSecret；
- 私钥；
- 完整 Token；
- 不必要的完整身份证号/手机号。

Secret 创建/重置后原则上只展示一次。

## 10. 文件

附件独立上传，业务对象保存 fileId，不在 JSON 中存 Base64。上传需校验大小、扩展名、MIME，并保留安全扫描扩展点。

## 11. OpenAPI

后端实现阶段必须维护 OpenAPI 3.x。本文档定义约束，OpenAPI 描述实际接口。
