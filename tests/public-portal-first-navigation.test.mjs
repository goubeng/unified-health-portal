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
