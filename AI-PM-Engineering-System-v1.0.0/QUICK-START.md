# 快速使用指南

## 场景 1：来了一个全新系统

1. 复制 `templates/.project/` 到项目根目录。
2. 让 AI 执行 `00_Project-Router.md`。
3. 确认 `project.yaml`。
4. 走 `01_NEW_PROJECT.md`。
5. 每完成一个阶段，检查 Stage Gate。
6. P7 之前不要生成最终交付文档。
7. P7 通过后冻结基线，再 P8/P9。

## 场景 2：已有系统改 3 个问题

1. 不跑新建 SOP。
2. 进入 `02_ITERATION.md`。
3. AI 先扫描现有实现和关联范围。
4. 修改后更新项目 CHANGELOG。
5. 有结构变化则同步 Migration。
6. 输出 Patch；需要时再输出 Full。

## 场景 3：做驾驶舱

1. 进入 `04_DASHBOARD.md`。
2. 先形成指标口径。
3. Mock 统一放 `src/mock`。
4. 页面经 Service 获取数据。
5. 最终交付 Mock Schema 与 API 替换说明。

## 场景 4：业务后台 + 驾驶舱

走 `05_HYBRID.md`，业务用 DB，大屏允许 Mock/Derived。

## 每次你觉得体系有问题

修改本工程体系时：

1. 先在根 `CHANGELOG.md` 记录；
2. 判断是 PATCH / MINOR / MAJOR；
3. 新版本重新打包；
4. 不直接覆盖旧版本包；
5. 在实际项目中逐步验证后再升级为默认规则。
