import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

const read = file => fs.readFileSync(file, 'utf8');

test('移动端待办卡片与首页待办可打开PC字段一致的详情弹窗', () => {
  const todo = read('src/mobile/MobileTodos.vue');
  const pc = read('src/components/portal/TodoDetailContent.vue');
  const home = read('src/mobile/MobileHome.vue');
  const style = read('src/mobile/mobile-todos.css');
  for (const field of ['来源应用', '业务类型', '接收时间', '状态']) {
    assert.match(pc, new RegExp(field));
    assert.match(todo, new RegExp('<dt>' + field + '</dt>'));
  }
  assert.match(pc, /record\.summary/);
  assert.match(todo, /active\.summary/);
  assert.match(todo, /class="mobile-todo-detail-dialog"/);
  assert.match(todo, /role="dialog"/);
  assert.match(todo, /aria-modal="true"/);
  assert.match(todo, /<footer v-if="active\.status === 'PENDING'" class="mobile-todo-detail-footer">/);
  assert.match(todo, /<TMobileButton block theme="primary" class="mobile-todo-detail-process-btn" @click="process\(active\)">去处理<\/TMobileButton>/);
  assert.doesNotMatch(todo, /<TMobileButton[^>]*@click="closeDetail">关闭<\/TMobileButton>/);
  assert.match(todo, /aria-label="关闭待办详情" @click="closeDetail"/);
  assert.match(style, /\.mobile-todo-detail-process-btn\s*\{[^}]*height:\s*var\(--mobile-action-primary-height\)/);
  assert.match(style, /\.mobile-todo-detail-process-btn\s*\{[^}]*border-radius:\s*var\(--mobile-action-pill-radius\)/);
  assert.match(style, /\.mobile-todo-detail-overlay\s*\{[^}]*backdrop-filter:\s*blur\(2px\)/);
  assert.match(todo, /@click\.stop="process\(item\)"/);
  assert.match(todo, /useMobileDialog/);
  assert.match(todo, /function openDetail\(item: Todo\)/);
  assert.match(todo, /function closeDetail\(\)/);
  assert.match(home, /todoId=\$\{encodeURIComponent\(item\.id\)\}/);
  assert.match(todo, /route\.query\.todoId/);
  assert.match(style, /\.mobile-todo-detail-footer\s*\{/);
  assert.match(todo, /command\('openTodo', \{ id: item\.id \}\)/);
});

test('移动端我的页面移除申请入口，全部应用申请返回来源正确', () => {
  const profile = read('src/mobile/MobileProfile.vue');
  const apps = read('src/mobile/MobileApps.vue');
  const applications = read('src/mobile/MobileApplications.vue');
  assert.doesNotMatch(profile, /我的服务|mobile-profile-link/);
  assert.match(profile, /个人资料/);
  assert.match(profile, /退出登录/);
  assert.match(apps, /query: \{ from: 'apps' \}/);
  assert.match(applications, /route\.query\.from === 'apps'/);
  assert.match(applications, /\.\.\.returnOriginQuery\.value, tab: tab\.value/);
  assert.match(applications, /router\.push\(route\.query\.from === 'apps' \? '\/m\/apps' : '\/m\/profile'\)/);
});
