# SSO 接入规范

## 1. 目标

用户从门户点击“进入”或待办“去处理”后，以可信、短时、一次性的方式进入目标子系统。门户只完成身份衔接，子系统继续负责本系统账号和业务权限。

## 2. 推荐模式

首期优先采用一次性 Ticket：

```text
门户校验访问资格
→ 生成一次性 ticket
→ 浏览器跳转子系统
→ 子系统服务端向门户校验 ticket
→ 获取最小身份/映射信息
→ 子系统建立本地 Session
```

禁止把姓名、手机号、角色等可信身份信息直接拼在 URL 中。

## 3. Ticket

要求：
- 高随机性；
- 1～5 分钟短时有效（可配置）；
- 首次成功校验后立即 CONSUMED；
- 普通日志不得记录完整 Ticket。

## 4. 目标接口

门户内部：
- `POST /api/apps/{appId}/sso`
- `POST /api/todos/{todoId}/open`

子系统服务端校验：
- `POST /api/integration/v1/sso/ticket/verify`

## 5. 进入前校验

顺序建议：
1. 应用适用用户；
2. 应用启用；
3. SSO 已配置且启用；
4. 若应用需要账号映射，则 USER_APP_MAPPING=BOUND/MAPPED；
5. 子系统账号状态可用；
6. 生成 Ticket。

## 6. 典型错误

- SSO_NOT_CONFIGURED；
- SSO_DISABLED；
- SSO_TICKET_INVALID；
- SSO_TICKET_EXPIRED；
- SSO_TICKET_ALREADY_USED；
- SSO_MAPPING_REQUIRED；
- SUBSYSTEM_ACCOUNT_DISABLED。

## 7. 权限边界

Ticket 只证明门户身份与映射结果，不授予子系统业务角色。子系统必须独立执行本地权限判断。
