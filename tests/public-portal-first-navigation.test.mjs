import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';

const router=readFileSync(new URL('../src/router.js',import.meta.url),'utf8');
const page=readFileSync(new URL('../src/views/PortalPage.vue',import.meta.url),'utf8');

test('公众首页与嵌套二级页保留首跳路由入口（源码回归，非浏览器首跳验收）',()=>{
  assert.match(router,/\{path:'\/portal\/home',name:'PG-101',component:PortalHomePreview/);
  assert.match(router,/\{path:'\/portal',component:PortalPreviewLayout,[\s\S]*?children:\[/);
  for(const path of ['todos','messages','announcements','apps/all','applications']){
    assert.ok(router.includes(`{path:'${path}',`),`缺少公众二级页路由 ${path}`);
  }
});

test('待办标题 Teleport 延迟解析首次挂载的目标（源码回归，非浏览器首跳验收）',()=>{
  assert.match(page,/<Teleport\s+v-if="resource==='todos'"\s+defer\s+to="#page-header-extra">/);
});

test('PC端“我的消息”菜单紧随“我的申请”，消息路由保持兼容（源码回归）',()=>{
  const fs=readFileSync(new URL('../src/App.vue',import.meta.url),'utf8');
  const home=readFileSync(new URL('../src/views/PortalHomePreview.vue',import.meta.url),'utf8');
  const layout=readFileSync(new URL('../src/views/PortalPreviewLayout.vue',import.meta.url),'utf8');
  const pages=readFileSync(new URL('../src/config/pages.js',import.meta.url),'utf8');
  assert.match(pages,/\/portal\/messages','我的消息'/);
  assert.match(fs,/myApplicationRequests','messages','profile'/);
  for(const source of [home,layout]){
    const nav=source.split('<nav class="public-portal-nav"')[1]?.split('</nav>')[0]||'';
    const items=[...nav.matchAll(/<button\b[^>]*>([^<]*)<\/button>/g)].map(match=>match[1].trim());
    const indexApplications=items.indexOf('我的申请');
    const indexMessages=items.indexOf('我的消息');
    assert.ok(indexApplications>=0 && indexMessages===indexApplications+1,'我的消息菜单必须紧随我的申请');
    assert.match(source,/aria-label="我的消息"/);
  }
  assert.match(layout,/title:'我的消息'/);
  assert.match(layout,/breadcrumbParent=computed/);
  assert.match(home,/<\/span> 我的消息 <span class="feed-count">/);
  assert.match(fs,/router\.push\('\/portal\/messages'\)/);
});
