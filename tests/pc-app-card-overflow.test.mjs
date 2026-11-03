import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';

const read=path=>readFileSync(path,'utf8');

test('全部应用卡片：名称与分类/归属标签单行省略，实际溢出才展示Tooltip',()=>{
  const cards=read('src/components/portal/AppCards.vue');
  const tooltip=read('src/components/portal/AppOverflowTooltip.vue');
  const css=read('src/styles/core.css');
  assert.match(cards, /<AppOverflowTooltip :content="text\(app\.name\)" kind="name">/);
  assert.match(cards, /<AppOverflowTooltip :content="text\(app\.category\)\|\|'未分类'" kind="category">/);
  assert.match(cards, /<AppOverflowTooltip v-if="app\.platformName"[^>]*kind="platform">/);
  assert.match(tooltip, /:disabled="!overflow \|\| !content"/);
  assert.match(tooltip, /target\.scrollWidth>target\.clientWidth\+1/);
  assert.match(tooltip, /new ResizeObserver\(syncOverflow\)/);
  assert.match(css, /\.portal-app-info \.portal-app-meta\{[^}]*flex-wrap:nowrap!important/);
  assert.match(cards, /<t-tag class="portal-app-platform" theme="default" variant="light" size="small" max-width="100%" :title="false">/);
  assert.match(css, /\.portal-app-overflow-tooltip--category\{[^}]*flex:0 0 auto/);
  assert.match(css, /\.portal-app-overflow-tooltip--platform\{[^}]*flex:0 1 auto/);
  assert.match(css, /\.portal-app-overflow-tooltip--platform \.portal-app-platform\.t-tag\{[^}]*width:auto/);
  assert.match(css, /\.portal-app-overflow-tooltip--platform \.portal-app-platform\.t-tag\{[^}]*padding:1px 8px!important/);
  assert.match(css, /\.portal-app-overflow-tooltip--platform \.portal-app-platform\.t-tag \.t-tag--text\{[^}]*min-width:0/);
  assert.match(css, /\.portal-app-overflow-tooltip--platform \.portal-app-platform\.t-tag \.t-tag--text\{[^}]*text-overflow:ellipsis/);
  assert.match(tooltip, /querySelector\('\[data-overflow-text\], \.portal-app-platform \.t-tag--text'\)/);
  assert.doesNotMatch(css, /\.t-tag__text/);
  assert.match(tooltip, /import PortalTooltip from '\.\/PortalTooltip\.vue';/);
  assert.match(css, /\.portal-app-platform\.t-tag\{[^}]*background:#f2f3f5!important;color:#667085!important/);
  assert.doesNotMatch(css, /\.portal-app-meta\.has-platform \.portal-app-overflow-tooltip--category\{max-width:48%\}/);
  assert.doesNotMatch(css, /\.portal-app-overflow-tooltip--platform\{[^}]*flex:1 1 0%/);
  assert.match(css, /\.portal-app-category-text\{[^}]*text-overflow:ellipsis/);
  assert.match(css, /\.portal-app-overflow-tooltip--platform \.portal-app-platform\.t-tag \.t-tag--text\{[^}]*text-overflow:ellipsis/);
});
