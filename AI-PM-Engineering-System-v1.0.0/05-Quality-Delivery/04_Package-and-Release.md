# P9 · 发布包规范

## Full Package

```text
project-full-vX.Y.Z.zip
```

包含当前完整源码和必要运行文件。

## Patch Package

```text
project-patch-vX.Y.Z.zip
```

建议：

```text
patch/
├─ files/
├─ database/
├─ PATCH-README.md
└─ CHANGELOG.md
```

## Database Package

```text
database/
├─ schema.sql
├─ seed.sql
├─ migrations/
└─ DB-VERSION.md
```

## Documents Package

只放 P7 复核后的最终文档。

## Release Manifest

必须记录：

- project_version
- baseline_id
- base_project_version
- database_version
- build_date
- full/patch/deploy 包名称
- 主要变更
- 验证结果
