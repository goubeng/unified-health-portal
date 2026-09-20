# SOP-D · 大屏 / 驾驶舱

## 1. 先设计指标，不先画图表

每个指标必须说明：

- 指标名称
- 业务含义
- 展示方式
- 单位
- 数据来源
- 时间范围
- 是否实时
- 是否支持穿透

## 2. 数据统一管理

禁止在 `.vue` 中散落：

```js
const count = 28
```

推荐：

```text
src/mock/dashboard/
src/services/dashboard/
```

页面只调用 Service。

## 3. Mock Schema

按领域拆分：

```text
overview
trend
ranking
map
alarm
resource
```

结构尽量接近未来 API 响应。

## 4. 页面建设

```text
框架布局
→ 指标卡
→ 趋势/排行
→ 地图
→ 告警/动态
→ 联动
→ 穿透
→ 自适应与主题
```

## 5. 最终交付

必须交付：

- 指标口径
- Mock 数据说明
- 数据结构
- 页面穿透关系
- 后续 API 替换说明
