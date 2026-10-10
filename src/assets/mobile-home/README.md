# 移动端首页 PNG 素材放置目录

本次仅提交 Vue/CSS 代码，不上传 PNG。请把之前下载的 **PNG 图标素材包** 解压，将下列五张文件直接放到本目录（文件名区分大小写）：

| 文件 | 用途 |
| --- | --- |
| `notice-megaphone.png` | 最新公告左侧蓝色扩音器插画 |
| `app-heart.png` | 公众服务 |
| `app-hospital.png` | 政务协同 |
| `app-training.png` | 培训考试 |
| `app-compliance.png` | 行业监管 |

- 推荐透明背景 PNG，保持文件原尺寸，无须裁剪。
- `src/mobile/MobileHome.vue` 使用 Vite 的 `import.meta.glob` 引入当前目录 PNG。
- **未上传 PNG 时：** 应用仍使用原有 `CategoryAppIcon` 分类 SVG，公告使用占位扩音器，`npm run build` 仍可运行。
- **上传 PNG 后：** 需要重新运行 `npm run dev:ui` 或 `npm run build`，以便资源被 Vite 识别；图片将替换对应图标。
- 类别不在上述四项中的应用继续使用现有分类 SVG，业务入口、公告轮播、待办数据与弹窗不变。
- 修改仅作用于移动端首页路由 `/m/home`，品牌主色 `#0052d9`。
