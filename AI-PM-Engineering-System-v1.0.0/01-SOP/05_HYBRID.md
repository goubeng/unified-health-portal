# SOP-E · 混合型系统

适用于“管理后台 + 真实 CRUD + 驾驶舱/统计”的系统。

## 核心思想

不要强迫所有模块使用同一种数据方式。

### 业务域

```text
Vue → Service → NocoDB/API → PostgreSQL
```

### 展示域

```text
Vue → Service → Mock Provider / Aggregation API
```

## 建议拆分

- System：用户、组织、角色、字典、消息
- Business：核心业务表和流程
- Analytics：统计口径与聚合服务
- Dashboard：驾驶舱展示

P5 核心闭环优先保障 Business；Dashboard 可以并行，但不反过来阻塞业务。
