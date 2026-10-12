import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

const read = path => fs.readFileSync(path, 'utf8');

test('PC应用中心：应用详情采用960px直角弹窗，正文只由TDesign外层控制20px留白', () => {
  const detail = read('src/components/portal/RecordDetail.vue');
  const page = read('src/views/PortalPage.vue');
  const css = read('src/styles/core.css');
  assert.match(detail, /'portal-pc-app-detail-dialog':appCenter&&kind==='apps'/);
  assert.match(detail, /kind==='apps'&&appCenter\?'min\(960px, calc\(100vw - 48px\)\)'/);
  assert.match(page, /<RecordDetail[^>]*:app-center="isAppCenter"/);
  assert.match(css, /\.portal-record-detail-dialog\.portal-pc-app-detail-dialog,\s*\.portal-pc-app-request-dialog\s*\{[^}]*border-radius:\s*0/);
  assert.match(css, /\.portal-record-detail-dialog\.portal-pc-app-detail-dialog \.t-dialog__body,\s*\.portal-pc-app-request-dialog \.t-dialog__body\s*\{[^}]*padding:\s*8px 20px 20px/);
  assert.match(css, /\.portal-record-detail-dialog\.portal-pc-app-detail-dialog \.portal-generic-detail\s*\{[^}]*padding:\s*0/);
});

test('PC应用中心：申请使用弹窗760px，统一紧凑的头部、正文、提示和底部间距', () => {
  const page = read('src/views/PortalPage.vue');
  const css = read('src/styles/core.css');
  assert.match(page, /'portal-pc-app-request-dialog':isAppCenter&&formAction==='submitApplicationRequest'/);
  assert.match(page, /isAppCenter&&formAction==='submitApplicationRequest'\?'min\(760px, calc\(100vw - 48px\)\)'/);
  assert.match(css, /\.portal-pc-app-request-dialog \.t-dialog__footer\s*\{[^}]*padding:\s*12px 20px 18px/);
  assert.match(css, /\.portal-pc-app-request-dialog \.inline-note\s*\{[^}]*padding:\s*10px 12px/);
  assert.match(css, /\.portal-pc-app-request-dialog \.form-grid\s*\{[^}]*gap:\s*12px 16px/);
});

test('PC应用中心：账号关联弹窗720px、单层内边距及直角，APP端样式不受影响', () => {
  const page = read('src/views/PortalPage.vue');
  const binding = read('src/components/portal/AccountBindingWizard.vue');
  const mobile = read('src/mobile/MobileAccountBindingModal.vue');
  const css = read('src/styles/core.css');
  assert.match(page, /<AccountBindingWizard[^>]*:app-center="isAppCenter"/);
  assert.match(binding, /APP_CENTER_DIALOG_MAX_WIDTH = 'min\(calc\(100vw - 48px\), 720px\)'/);
  assert.match(binding, /const DIALOG_MAX_WIDTH = 'min\(calc\(100vw - 24px\), 420px\)'/);
  assert.match(binding, /'account-binding-dialog--app-center':appCenter/);
  assert.match(binding, /\.account-binding-dialog\.t-dialog,\s*body \.account-binding-dialog \.t-dialog\s*\{[^}]*border-radius:\s*0/);
  assert.match(binding, /\.account-binding-dialog\.account-binding-dialog--app-center \.t-dialog__body\s*\{[^}]*padding:\s*0\s*!important/);
  assert.match(binding, /\.account-binding-dialog\.account-binding-dialog--app-center\.t-dialog__wrap \.t-dialog,[\s\S]*?padding:\s*24px 28px\s*!important/);
  assert.match(binding, /\.account-binding-dialog\.account-binding-dialog--app-center \.t-dialog__header\s*\{[^}]*padding:\s*0(?:\s*!important|\s+28px\s+0\s+0)?/);
  assert.match(binding, /@media \(max-width:\s*720px\)\s*\{[\s\S]*?padding:\s*18px\s*!important/);
  assert.doesNotMatch(mobile, /portal-pc-app-|account-binding-dialog--app-center/);
  assert.doesNotMatch(css, /\.mobile-apps-my-requests-link|\.mobile-binding-overlay/);
});
