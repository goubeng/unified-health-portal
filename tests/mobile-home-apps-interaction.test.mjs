import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

const read = file => fs.readFileSync(file, 'utf8');

test('移动端首页我的应用支持直接展示全部应用并按8个分页横向划动', () => {
  const homeVue = read('src/mobile/MobileHome.vue');
  const homeDetailCss = read('src/mobile/mobile-home-detail.css');

  // 1. 全部应用横向划动容器及分页指示点
  assert.match(homeVue, /class="mobile-home-apps-scroll-wrap"/);
  assert.match(homeVue, /class="mobile-home-apps-dots"/);
  assert.match(homeVue, /class="mobile-home-app-page"/);
  assert.match(homeVue, /const APP_PAGE_SIZE = 8;/);
  assert.match(homeVue, /appPages = computed/);
  assert.match(homeVue, /handleAppScroll/);

  // 2. 样式中支持平滑横向滚动与 snap
  assert.match(homeDetailCss, /\.mobile-home-apps-scroll-wrap\s*\{[^}]*scroll-snap-type:\s*x mandatory/);
  assert.match(homeDetailCss, /\.mobile-home-apps-scroll-wrap\s*\{[^}]*overflow-x:\s*auto/);
  assert.match(homeDetailCss, /\.mobile-home-app-page\s*\{[^}]*flex:\s*0 0 100%/);
  assert.match(homeDetailCss, /\.mobile-home-apps-dot\.active/);
});

test('移动端首页我的应用区域并排显示我的申请和全部应用入口', () => {
  const homeVue = read('src/mobile/MobileHome.vue');

  // 我的应用标题旁操作按钮应为我的申请，并跳转到 /m/applications
  assert.match(homeVue, /class="mobile-home-my-requests-link"[^>]*@click="go\('\/m\/applications'\)"/);
  assert.match(homeVue, /<FileIcon class="my-requests-icon"/);
  assert.match(homeVue, /<span class="mobile-home-actions-divider" aria-hidden="true"><\/span>/);
  const homeCss = read('src/mobile/mobile-home-refresh.css');
  assert.match(homeCss, /\.mobile-home-section--first \.mobile-home-section-actions \.mobile-home-my-requests-link\s*\{/);
  assert.match(homeCss, /\.mobile-home-section-head > button,\s*\.mobile-home-section--first \.mobile-home-section-actions \.mobile-home-all-apps-link\s*\{/);
  assert.match(homeCss, /background:\s*#edf4ff/);
  assert.match(homeCss, /border:\s*1px solid #c9dcff/);
  assert.match(homeCss, /color:\s*var\(--home-brand\)/);
  assert.match(homeCss, /\.my-requests-icon\s*\{[^}]*width:\s*11px/);
  assert.match(homeCss, /\.mobile-home-actions-divider\s*\{[^}]*width:\s*1px/);
  assert.match(homeCss, /height:\s*30px/);
  assert.match(homeCss, /min-height:\s*30px/);
  assert.doesNotMatch(homeVue, /class="my-requests-arrow"/);
  assert.match(homeVue, /class="mobile-home-section-actions"/);
  assert.match(homeVue, /class="mobile-home-all-apps-link"[^>]*@click="go\('\/m\/apps'\)">全部应用<\/button>/);
  const actions = homeVue.split('class="mobile-home-section-actions"')[1]?.split('</div>')[0] || '';
  assert.ok(actions.indexOf('mobile-home-my-requests-link') < actions.indexOf('mobile-home-all-apps-link'));
  assert.match(homeVue, /<button type="button" @click="go\('\/m\/todos'\)">查看全部<\/button>/);
  assert.match(homeVue, /todoId=\$\{encodeURIComponent\(item.id\)\}/);
});

test('移动端首页我的应用和待办事项标题去掉了前导蓝色竖线', () => {
  const refreshCss = read('src/mobile/mobile-home-refresh.css');

  // 验证 h2 没有 padding-left: 13px，且不存在 h2::before 蓝色竖线定义
  assert.doesNotMatch(refreshCss, /\.mobile-home-section-head h2::before/);
  assert.doesNotMatch(refreshCss, /\.mobile-home-section-head h2\s*\{[^}]*padding-left:\s*13px/);
});

test('移动端首页应用访问弹窗遮罩覆盖底部导航，不受首页层叠上下文限制', () => {
  const home = read('src/mobile/MobileHome.vue');
  const homeDetails = read('src/mobile/mobile-home-detail.css');
  const homeBase = read('src/mobile/mobile-home-base.css');
  const shell = read('src/mobile/MobileShell.vue');
  const mobileCss = read('src/mobile/mobile.css');
  // 首页保留isolation卡片背景与视觉层级，应用提示弹窗应Teleport到导航同层的外部容器。
  assert.match(homeDetails, /\.mobile-home\s*\{[^}]*isolation:\s*isolate/);
  assert.match(home, /<Teleport to="\.mobile-shell">\s*<div\s+v-if="noticeModal\.visible"\s+class="mobile-notice-overlay"/);
  assert.match(home, /<\/div>\s*<\/Teleport>\s*<\/div>\s*<\/template>/);
  assert.match(homeBase, /\.mobile-notice-overlay\s*\{[^}]*z-index:\s*3100/);
  assert.match(mobileCss, /\.mobile-shell__navigation\s*\{[^}]*z-index:\s*20/);
  assert.match(shell, /<div class="mobile-shell"/);
  assert.match(home, /@click\.self="noticeModal\.visible = false"/);
  assert.match(home, /@click="noticeModal\.visible = false"/);
});
