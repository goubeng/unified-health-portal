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

test('移动端首页原来的“全部应用”已替换为“我的申请”链接', () => {
  const homeVue = read('src/mobile/MobileHome.vue');

  // 我的应用标题旁操作按钮应为我的申请，并跳转到 /m/applications
  assert.match(homeVue, /class="mobile-home-my-requests-link"[^>]*@click="go\('\/m\/applications'\)"/);
  assert.doesNotMatch(homeVue, /<FileIcon class="my-requests-icon"/);
  assert.doesNotMatch(homeVue, /  FileIcon,/);
  assert.match(homeVue, /<ChevronRightIcon class="my-requests-arrow"/);
  const homeCss = read('src/mobile/mobile-home-refresh.css');
  assert.match(homeCss, /\.mobile-home-section--first \.mobile-home-section-head > \.mobile-home-my-requests-link\s*\{/);
  assert.match(homeCss, /background:\s*#edf4ff/);
  assert.match(homeCss, /border:\s*1px solid #c9dcff/);
  assert.match(homeCss, /color:\s*var\(--home-brand\)/);
  assert.match(homeCss, /\.my-requests-arrow\s*\{[^}]*width:\s*9px/);
  assert.match(homeCss, /height:\s*30px/);
  assert.match(homeCss, /min-height:\s*30px/);
  assert.doesNotMatch(homeCss, /\.my-requests-icon/);
  assert.doesNotMatch(homeVue, /<button type="button" @click="go\('\/m\/apps'\)">全部应用<\/button>/);
});

test('移动端首页我的应用和待办事项标题去掉了前导蓝色竖线', () => {
  const refreshCss = read('src/mobile/mobile-home-refresh.css');

  // 验证 h2 没有 padding-left: 13px，且不存在 h2::before 蓝色竖线定义
  assert.doesNotMatch(refreshCss, /\.mobile-home-section-head h2::before/);
  assert.doesNotMatch(refreshCss, /\.mobile-home-section-head h2\s*\{[^}]*padding-left:\s*13px/);
});
