# 标准 CRUD 能力

统一页面能力：

- 查询
- 重置
- 列表
- 分页
- 新增
- 编辑
- 详情
- 删除/停用
- 状态切换
- 导出（按需）

推荐将通用逻辑沉淀到：

```text
components/
composables/
services/
styles/
```

已有母版中存在的能力优先复用，不重复实现。
