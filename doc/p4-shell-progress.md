# P4 界面壳与登录整改

- 已读取 doc/lessons.md、doc/progress.md、doc/task_plan.md；主线程已登记21项，本文件仅记录分派的界面壳与登录范围。
- 目标：参考 office-house 用户浮窗与TD图标，整改顶栏、菜单、登录和受控用户切换。
- 修改范围：src/App.vue、src/views/Login.vue、src/views/AuthResult.vue、src/styles/layout.css，以及允许新增的账号/登录组件。
- 当前会话未提供子 agent 工具，作为主线程已分派任务直接执行，不创建新任务替代子 agent。
- 已核对真实参考路径 office‑house（目录名为不换行连字符），只读 MainLayout.vue；当前项目无 .git，不能执行 git diff 验证。
- 已完成页面壳与登录修改：去面包屑/底部参考文案、TD菜单图标、端类型标题、消息图标小角标、摘要浮窗/个人中心/退出、动态用户下拉、公众默认登录/两种认证入口。
- 接收主线程接口更新：改用 runtime availableUsers，保留动态用户集合、停用过滤与 login 拒绝停用语义；PG102 仅隐藏菜单，PG103 使用主线程标题，users 使用 TD 用户图标。
- 技术边界：扫码采用 TD 二维码图标及我已扫码/确认/刷新本地步骤，不是可供闽政通/闽政务扫描的认证二维码；短信仅本地倒计时，不发送请求，不验证真实号码和验证码。两种身份标签均按任务要求默认登录 MOCK_USER_1，管理账号与其它账号从顶栏切换。
- 受控用户切换只调用现有 runtime login，保留 can 权限判断与无权限路由回退；此能力不是生产身份认证/提权机制，真实接入须由主线程后续处理。
- 不操作数据库、参考源码或 Browser；不修改其它任务过程文件。

## 验证结果

- npm run build：通过（5977 modules，27.61秒）；保留现有 UI chunk 大于500kB提示。构建命令正常刷新 dist 产物，未手动编辑产物。
- npm test：12项中11项通过，1项页面清单断言失败；实际新增PG228，原断言仍固定32页。由主线程同步产品清单/测试，本分派不改非目标文件。
- Node 无浏览器交互逻辑检查：公众默认值、滑动前阻止手机号登录、滑动完成、验证码本地60秒倒计时、MOCK_USER_1登录与路由、重置清理均通过；动态用户选项/隐藏PG102/users TD图标/无面包屑及底部节点静态检查通过。
- Browser 未调用；消息角标实际裁剪、响应式布局和浮窗点击未做浏览器验收，不将构建等同于视觉验收。
- 交付源码：src/App.vue、src/views/Login.vue、src/views/AuthResult.vue、src/styles/layout.css；未新增组件，未修改runtime/config/业务页面/数据库或参考源码。
