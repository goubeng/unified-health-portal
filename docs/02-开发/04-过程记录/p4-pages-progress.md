# P4业务页面整改

## 目标及边界
- 已读取 lessons.md、progress.md、task_plan.md。
- 写入仅限 PortalPage.vue、core.css、新增 components/portal/* 和本独立过程文档；不改服务、路由、数据库，不操作浏览器。
- 当前无可用子agent工具，本任务在现有工作区按组件拆解执行，不创建新任务或分支。

## 进度
- 已读取 office‑house 消息、个人中心、用户详情的模板及局部样式；采用信件式消息、侧栏个人资料、带边框双列网格详情。
- 已核查 read/command 契约：保留现有 API；用户维护和公告已读接主线程新增动作，不修改服务。
- 已新增展示工具、紧凑应用卡、个人中心及详情组件，正在替换主页面。
- 当前目录无 Git 仓库，无法使用 git diff；以文件范围核对、源码编译、构建及既有测试验证。
- 主页面已替换：首页无统计/banner，近5条待办/公告/消息，合并应用中心，即时灰底查询、首字段链接、分页连续序号。
- 已接主线程新契约：availableUsers、readStatus、unreadAnnouncementCount、markAnnouncementRead、savePortalUser；用户表单身份只读，提交仅id/version/status/scopes。
- 完整目录展示并依据applicable禁关联/进入；应用访问只弹服务反馈，不执行外部地址跳转。
- 正在静态编译、构建及既有规则验证；API仍为本地Mock实现，不据UI文案声称真实认证或系统接通。

## 验证
- 待执行静态检查及构建；浏览器与数据库验收不在本任务范围。
