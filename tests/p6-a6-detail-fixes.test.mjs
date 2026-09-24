import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

const read=path=>fs.readFileSync(path,'utf8');

test('source application dropdowns are searchable',()=>{
  const todo=read('src/components/portal/TodoCenter.vue');
  const message=read('src/components/portal/MessageCenter.vue');
  const page=read('src/views/PortalPage.vue');
  assert(todo.includes('v-model="appName" clearable filterable'));
  assert(message.includes('v-model="sourceFilter" clearable filterable'));
  assert(page.includes(':filterable="filter.searchable===true"'));
  assert(page.includes("searchable:key==='appName'"));
  assert(page.includes("filterDef('appName','来源应用','请选择来源应用'"));
});

test('application request list uses requested widths',()=>{
  const page=read('src/views/PortalPage.vue');
  for(const token of ["if(key==='userName')return 110","if(key==='status')return 100","if(key==='appName')return 320","if(key==='reason')return 320"]){
    assert(page.includes(token),token);
  }
  assert(page.includes("applicationRequests:{appName:'来源应用'}"));
});

test('connection configuration uses standard dialog footer',()=>{
  const page=read('src/views/PortalPage.vue');
  const detail=read('src/components/portal/AccessConfigDetail.vue');
  assert(page.includes('ref="accessConfigRef"'));
  assert(page.includes('accessConfigRef?.saveActive()'));
  assert(!page.includes('width="1180px" :footer="false"'));
  assert(!detail.includes('class="access-config-footer"'));
  assert(detail.includes('defineExpose({saveActive:()=>save(activeKind.value)})'));
});

test('API log result column is before HTTP method',()=>{
  const source=read('src/components/portal/LogManagement.vue');
  const api=source.split("if(props.kind==='api')return [")[1]?.split('];')[0]||'';
  assert(api.indexOf('commonStatus')>=0);
  assert(api.indexOf('commonStatus')<api.indexOf("column('httpMethod'"));
});

test('account opening request examples cover main statuses',()=>{
  const seed=read('src/mock/seed.js');
  for(const token of ["MOCK_OPEN_PENDING","status:'PENDING'","MOCK_OPEN_PROCESSING","status:'PROCESSING'","MOCK_OPEN_COMPLETED","status:'COMPLETED'"]){
    assert(seed.includes(token),token);
  }
});

test('application card icon aligns with application name top',()=>{
  const css=read('src/styles/core.css');
  assert(css.includes('.portal-app-card{align-items:flex-start!important}'));
});

test('admin home mapping exception and announcement shortcuts are routable',()=>{
  const page=read('src/views/PortalPage.vue');
  const announcement=read('src/components/portal/AnnouncementManagement.vue');
  assert(page.includes("/admin/identities?mapping=exception"));
  assert(page.includes("route.query.mapping==='exception'"));
  assert(page.includes("query:{action:'create'}"));
  assert(announcement.includes("if(value==='create'&&!formVisible.value)openCreate()"));
  assert(announcement.includes("if(visible||route.query.action!=='create')return"));
});

test('downloaded contract is explicitly local-integration only',()=>{
  const contract=read('src/config/integration-contract.js');
  const runtime=read('src/services/runtime.js');
  assert(contract.includes("purpose:'LOCAL_INTEGRATION_TEST'"));
  assert(contract.includes('productionReady:false'));
  assert(contract.includes('/api/integration/v1'));
  assert(runtime.includes('卫健XC统一门户_A阶段本地联调_OpenAPI.json'));
});
