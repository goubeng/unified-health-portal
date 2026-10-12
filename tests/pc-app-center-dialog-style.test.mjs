import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

const read = path => fs.readFileSync(path, 'utf8');

test('PC应用中心：应用详情仅在应用中心上下文启用1080px宽度与28px正文留白', () => {
  const detail = read('src/components/portal/RecordDetail.vue');
  const page = read('src/views/PortalPage.vue');
  const css = read('src/styles/core.css');
  assert.match(detail, /'portal-pc-app-detail-dialog':appCenter&&kind==='apps'/);
  assert.match(detail, /kind==='apps'&&appCenter\?'min\(1080px, calc\(100vw - 48px\)\)'/);
  assert.match(page, /<RecordDetail[^>]*:app-center="isAppCenter"/);
  assert.match(css, /\.portal-record-detail-dialog\.portal-pc-app-detail-dialog \.t-dialog__body\s*\{[^}]*padding:\s*20px 28px 28px/);
  assert.match(css, /\.portal-record-detail-dialog\.portal-pc-app-detail-dialog \.t-dialog__header/);
});

test('PC应用中心：申请使用弹窗加宽860px，仅对申请场景生效', () => {
  const page = read('src/views/PortalPage.vue');
  const css = read('src/styles/core.css');
  assert.match(page, /'portal-pc-app-request-dialog':isAppCenter&&formAction==='submitApplicationRequest'/);
  assert.match(page, /isAppCenter&&formAction==='submitApplicationRequest'\?'min\(860px, calc\(100vw - 48px\)\)'/);
  assert.match(css, /\.portal-pc-app-request-dialog \.t-dialog__body\s*\{[^}]*padding:\s*20px 28px 28px/);
  assert.match(css, /\.portal-pc-app-request-dialog \.t-dialog__footer\s*\{[^}]*padding:\s*12px 28px 20px/);
});

test('PC应用中心：账号关联弹窗加宽560px，原有420px基线及移动端组件不变', () => {
  const page = read('src/views/PortalPage.vue');
  const binding = read('src/components/portal/AccountBindingWizard.vue');
  const mobile = read('src/mobile/MobileAccountBindingModal.vue');
  const css = read('src/styles/core.css');
  assert.match(page, /<AccountBindingWizard[^>]*:app-center="isAppCenter"/);
  assert.match(binding, /APP_CENTER_DIALOG_MAX_WIDTH = 'min\(calc\(100vw - 48px\), 560px\)'/);
  assert.match(binding, /const DIALOG_MAX_WIDTH = 'min\(calc\(100vw - 24px\), 420px\)'/);
  assert.match(binding, /'account-binding-dialog--app-center':appCenter/);
  assert.match(binding, /\.account-binding-dialog\.account-binding-dialog--app-center \.t-dialog__body\s*\{[^}]*padding:\s*12px 28px 28px/);
  assert.doesNotMatch(mobile, /portal-pc-app-|account-binding-dialog--app-center/);
  assert.doesNotMatch(css, /\.mobile-apps-my-requests-link|\.mobile-binding-overlay/);
});
