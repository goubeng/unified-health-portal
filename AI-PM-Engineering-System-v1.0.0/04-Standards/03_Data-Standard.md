# 数据规范

## 数据来源分类

- `database`：真实持久化业务数据
- `mock`：展示/演示数据
- `derived`：由已有数据计算得到
- `external`：未来外部接口

每个页面/指标需要标明数据来源。

## 数据库文件建议

```text
database/
├─ schema/
├─ seed/
├─ migrations/
└─ README.md
```

## 数据库版本

任何结构变更必须：

1. 新增 migration；
2. CHANGELOG 标注；
3. 不只修改本机数据库而不保留脚本；
4. 发布包明确数据库版本。
