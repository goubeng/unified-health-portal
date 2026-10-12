import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

const read = path => fs.readFileSync(path, 'utf8');

test('移动端全部应用页头统计位于标题下方，右侧显示我的申请图标按钮', () => {
  const vue = read('src/mobile/MobileApps.vue');
  const css = read('src/mobile/mobile-apps.css');
  const titleRow = vue.split('<div class="mobile-apps-title-row">')[1]?.split('<div class="mobile-apps-search-wrap">')[0] || '';
  assert.match(titleRow, /<div class="mobile-apps-title-group">\s*<h1>全部应用<\/h1>\s*<div class="mobile-apps-title-stats"/);
  assert.match(titleRow, /共 <strong>\{\{ apps\.length \}\}<\/strong> 个/);
  assert.match(titleRow, /已关联 <strong>\{\{ totalBoundCount \}\}<\/strong> 个/);
  assert.match(titleRow, /class="mobile-apps-my-requests-link"[\s\S]*?@click="router\.push\('\/m\/applications'\)"/);
  assert.match(titleRow, /<FileIcon class="mobile-apps-my-requests-icon"/);
  assert.match(titleRow, /<span>我的申请<\/span>/);
  assert.match(css, /\.mobile-apps-title-group\s*\{[^}]*flex-direction:\s*column/);
  assert.match(css, /\.mobile-apps-my-requests-icon\s*\{[^}]*width:\s*12px/);
  assert.match(css, /\.mobile-apps-my-requests-link\s*\{[^}]*min-height:\s*32px/);
});

test('全部应用搜索与分类交互保留原有功能', () => {
  const vue = read('src/mobile/MobileApps.vue');
  assert.match(vue, /v-model="keyword"/);
  assert.match(vue, /v-for="item in displayCategories"/);
  assert.match(vue, /@click="selectCategory\(item\)"/);
  assert.match(vue, /function isAppBound\(app: App\)/);
  assert.match(vue, /router\.push\('\/m\/applications'\)/);
});
