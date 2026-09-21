# MESSAGE 接入规范

## 1. 原则

MESSAGE 用于统一告知；TODO 用于需要用户处理的业务。是否同一业务同时产生 TODO 与 MESSAGE 由具体业务规则决定。

## 2. PUSH

目标接口：
- `POST /api/integration/v1/messages`

门户本期不主动轮询子系统。

## 3. 最小字段

- requestId/eventId；
- appCode；
- sourceMessageId；
- receivers；
- title；
- content；
- businessType/messageType；
- actionPath（可选）；
- sentAt。

## 4. 数据模型

消息正文与收件人状态分离：

```text
MESSAGE
  → MESSAGE_RECIPIENT (N)
```

每个收件人独立维护 UNREAD/READ 和用户级逻辑删除。

## 5. 唯一与幂等

- requestId/eventId：请求级幂等；
- appCode + sourceMessageId：业务级去重。

已成功投递的消息正文原则上不由子系统原地修改；重大修正建议发送新消息并建立业务关联。

## 6. 已读与删除

已读状态由门户维护，子系统不负责。用户删除仅设置收件人级 deleted，不物理删除消息本体。

## 7. 业务跳转

存在 actionPath 时，点击查看应通过门户 SSO 能力生成合法跳转，不能把 Mock URL 直接视为正式入口。
