import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

const read = file => fs.readFileSync(file, 'utf8');

test('mobile loading states render a circular indicator above their loading text', () => {
  const loading = read('src/mobile/MobileLoading.vue');
  assert.match(loading, /class="mobile-loading-ring"/);
  assert.match(loading, /class="mobile-loading-label"/);
  assert.ok(loading.indexOf('class="mobile-loading-ring"') < loading.indexOf('class="mobile-loading-label"'));
  assert.match(loading, /@keyframes mobile-loading-rotate/);
  assert.match(loading, /role="status"/);
  for (const file of ['MobileHome.vue', 'MobileApps.vue', 'MobileTodos.vue', 'MobileMessages.vue', 'MobileApplications.vue', 'MobileAnnouncements.vue']) {
    const component = read('src/mobile/' + file);
    assert.match(component, /import MobileLoading from '\.\/MobileLoading\.vue'/, file);
    assert.match(component, /<MobileLoading message="正在加载/, file);
  }
});

test('mobile messages return to a single inbox list without announcements tab', () => {
  const shell = read('src/mobile/MobileShell.vue');
  const messages = read('src/mobile/MobileMessages.vue');
  const routes = read('src/mobile/routes.ts');
  const notices = read('src/mobile/MobileAnnouncements.vue');
  assert.match(shell, /label: '消息中心'/);
  assert.match(messages, /<h1>消息中心<\/h1>/);
  assert.match(routes, /mobileMeta\('消息中心','messages'\)/);
  assert.doesNotMatch(messages, /mobile-message-tabs|MobileAnnouncements|通知公告<\/button>/);
  assert.match(messages, /openFilterDrawer/);
  assert.match(messages, /quickFilterUnread/);
  assert.doesNotMatch(notices, /props\.embedded/);
});

test('mobile messages filter checkbox options render a top-left corner badge with visible checkmark', () => {
  const messages = read('src/mobile/MobileMessages.vue');
  const css = read('src/mobile/mobile-messages.css');
  assert.match(messages, /class="filter-checked-corner"/);
  assert.match(messages, /stroke="#ffffff"/);
  assert.match(messages, /stroke-linecap="round"/);
  assert.match(css, /\.filter-checked-corner\s*\{[^}]*top:\s*0/);
  assert.match(css, /\.filter-checked-corner\s*\{[^}]*left:\s*0/);
  assert.match(css, /\.filter-option-btn\.active\s*\{[^}]*border-color:\s*#0052d9/);
});

