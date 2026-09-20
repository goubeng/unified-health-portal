# Mock 与 Service Layer 规范

## 目标

页面不感知数据究竟来自 NocoDB 还是 Mock。

```text
View
 ↓
Service
 ↓
Provider
 ├─ NocoDB
 ├─ Mock
 └─ Future API
```

## Service 建议统一暴露

业务 CRUD：

```text
getList
getDetail
create
update
remove
```

大屏：

```text
getOverview
getTrend
getRanking
getMapData
getAlerts
```

## Mock 目录

```text
src/mock/
├─ dashboard/
├─ security/
├─ energy/
└─ resources/
```

禁止：

- 页面直接散落数字；
- 多个页面复制同一组 Mock；
- Mock 字段与未来 API 完全不同而无映射。
