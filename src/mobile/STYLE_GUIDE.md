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

不新增字重800/900，页面标题通常600，品牌重点和数字可使用700。移动端可见文字的最小字号为 **12px**（包括来源系统、日期及数量徽标）。来源系统和接收时间的字体色统一为 **#9CB0C2**，通过 `mobile.css` 中的 `--mobile-list-card-source-color` 与 `--mobile-list-card-time-color` 控制。字体使用系统中文字体栈，保持小屏阅读清晰。

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

首页应用名称统一为12px、500字重、`#405471`，避免过深过粗。首页Banner保持原有PNG，医院主体通过CSS放大；窄屏响应式降低放大倍率，保留右侧画面与左侧文案。

## 二级页公共 UI 约束

- 页面内容保持原有菜单与业务，卡片统一通过 `mobile.css` 的 `--mobile-card-*` 和公共选择器控制背景、边框、圆角、阴影；页面 CSS 只写布局与状态差异。
- 操作按钮尺寸由公共变量控制：列表行内操作至少36px高、弹窗确认或提交至少44px高、图标操作区至少40×40px。按钮原有颜色、禁用态和事件不变。
- 主要页面包括待办、消息中心、全部应用、我的申请、通知公告、个人中心及相关弹窗。所有文字（包括二级页提示和来源/时间信息）最小12px；来源系统与接收时间统一 `#9CB0C2`。

## 首页视觉收尾与我的申请按钮

- 首页 Banner 保留原有医院 PNG、品牌蓝配色、主标题以及“公众门户”标识。顶部最小高度为154px（包含内边距），上下内边距14px/17px；使用cover背景和CSS定位控制建筑视角，不添加新文案或新图片。
- 我的应用保持38px SVG图标、12px/500应用名称。仅微调卡片图标与文字留白。
- 公告PNG保留，缩减原有渐隐遮罩对插画主体的影响，不增加新的分隔线。待办卡片轻微降低边框对比度。
- 首页底部波纹和导航栏过渡由CSS控制，避免新增素材。
- 我的申请卡片快捷操作与详情操作均为胶囊形，圆角使用公共 `--mobile-action-pill-radius`，可与待办和全部应用按钮复用，不修改状态、交互和文案。

## 首页Banner门户标识与应用卡片

- Banner保留原文案“卫健 XC · 便民服务”与“健康服务，一站直达”，把“公众门户”小标识独立放在Banner右上角；继续使用原医院背景图，仅调整CSS主视角的放大倍率，不改路由和业务。
- “我的应用”卡片保留现有淡色渐变背景、38px 分类SVG和交互效果，移除每个卡片的边框线；默认、窄屏和大屏统一无边框。

## 底部主导航统一布局

- 全移动端底部导航通过 `mobile.css` 维护，不在页面级 CSS 再定义不同高度。
- TDesign `TabBarItem` 高度为56px，上下外边距各8px，导航内容区合计72px（不含 `safe-area-inset-bottom`）；图标保持24px，图标与文字间距5px，文字字号12px。
- `mobile-shell__content` 与导航栏统一引用 `--mobile-nav-bar-height`，为滚动内容保留足够的底部空间。iOS安全区仍由TDesign的 `safe-area-inset-bottom` 控制。

## 首页 Banner 图片与文字层次微调

- Banner保留原医院PNG、主副标题、右上角“公众门户”与白色描边。Banner采用 `box-sizing: border-box`、154px最小高度和14px/17px上下内边距；主视角CSS放大倍率为1.32，350px及以下时为1.22，不拉伸图片。
- “公众门户”单独定位在Banner右上角，12px品牌蓝文字搭配半透明浅色胶囊，不再占据左侧副标题行。
- 主标题使用1.7px柔和白色描边与低强度白色文字阴影，辅助标题使用0.65px细白边；原文案、字号、字重和蓝色填充不变。

## 二级页蓝色头部三段式间距

- 待办事项、消息中心、全部应用的标题、辅助文字/操作栏与搜索框统一引用 `mobile.css` 中的 `--mobile-hero-padding-top: 14px`、`--mobile-hero-padding-bottom: 12px` 和 `--mobile-hero-row-gap: 6px`。
- 待办说明文字行高从30px收紧为26px；消息中心筛选栏取消额外2px上间距，未读提醒仍按原条件显示。
- 只收紧页头纵向留白，保留搜索框38px高度、页面标题字号、操作按钮最小36px、12px最小字号及原有路由和业务交互。
