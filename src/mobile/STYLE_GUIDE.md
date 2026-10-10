# 移动端样式管理规范

## 样式文件职责

- `mobile.css`：全局品牌蓝 `#0052d9`、字体与字重变量、TDesign公共样式及底部导航，由 `MobileShell.vue` 引入。
- 页面独立 CSS：通过 `<style scoped src="./mobile-xxx.css"></style>` 加载，保留 Vue scoped 选择器作用域，不影响管理端。
- 首页依加载顺序保留 `mobile-home-base.css` → `mobile-home-refresh.css` → `mobile-home-detail.css`，优先在最终层修改具体视觉细节，避免覆盖既有验收结果。
- `CategoryAppIcon.vue` / `NavIcon.vue` 中的 SVG 内部样式仍留在图标组件；公告轮播等数据驱动 `:style` 不属于静态样式，予以保留。

## 文字字重

| 用途 | 字重 | CSS变量 |
| --- | --- | --- |
| 正文、说明、次要信息 | 400 | `--mobile-font-weight-normal` |
| 按钮、链接、辅助标题 | 500 | `--mobile-font-weight-medium` |
| 页面标题、模块标题、关键业务标题、选中Tab | 600 | `--mobile-font-weight-semibold` |
| Banner重点标题、需要强调的数字 | 700 | `--mobile-font-weight-bold` |

不新增字重800/900，页面标题通常600，品牌重点和数字可使用700。字体使用系统中文字体栈，保持小屏阅读清晰。

## 页面 CSS 映射

| 页面 | 文件 |
| --- | --- |
| 首页 | `mobile-home-base.css` / `mobile-home-refresh.css` / `mobile-home-detail.css` |
| 全部应用 | `mobile-apps.css` |
| 消息中心 | `mobile-messages.css` |
| 通知公告 | `mobile-announcements.css` |
| 我的申请 | `mobile-applications.css` |
| 待办事项 | `mobile-todos.css` |
| 个人中心 | `mobile-profile.css` |
| 应用账号关联弹窗 | `mobile-account-binding-modal.css` |

优先复用公共变量，不要再在Vue组件末尾添加大段内联CSS。校验命令：`npm run check:mobile`、`npm run build`；主要检查320、375、390、430、480px及公告滚动、详情和弹窗。
