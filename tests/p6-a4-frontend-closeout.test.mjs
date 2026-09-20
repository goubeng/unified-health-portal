import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

test('PG-002认证结果页覆盖七类目标状态',()=>{
  const source=fs.readFileSync('src/views/AuthResult.vue','utf8');
  for(const state of ['SUCCESS','FAILURE','DISABLED','LOCKED','NO_PERMISSION','UPSTREAM_ERROR','SESSION_ERROR']){
    assert(source.includes(state),'缺少认证结果状态 '+state);
  }
  for(const title of ['认证成功','认证失败','账号已停用','账号已锁定','无管理权限','外部认证异常','会话建立失败']){
    assert(source.includes(title),'缺少认证结果文案 '+title);
  }
  assert(source.includes("route.query.status||route.query.result"));
  assert(source.includes("MINZHENGTONG:'闽政通'"));
  assert(source.includes("MINZHENGWU:'闽政务'"));
  assert(source.includes("PORTAL_LOCAL:'门户本地'"));
});

test('PG-002认证结果动作区支持进入门户返回用户端和重新登录',()=>{
  const source=fs.readFileSync('src/views/AuthResult.vue','utf8');
  assert(source.includes("return actor.value?'进入门户':'返回登录'"));
  assert(source.includes("return '进入用户端'"));
  assert(source.includes("'重新登录'"));
  assert(source.includes("router.replace('/portal/home')"));
  assert(source.includes("router.replace('/login')"));
});

test('PG-104待办任务使用独立TodoCenter',()=>{
  const page=fs.readFileSync('src/views/PortalPage.vue','utf8');
  const source=fs.readFileSync('src/components/portal/TodoCenter.vue','utf8');
  assert(page.includes("import TodoCenter from '../components/portal/TodoCenter.vue'"));
  assert(page.includes("<TodoCenter v-else-if=\"resource==='todos'\" :rows=\"rows\"/>"));
  assert(source.includes('label="待办标题"'));
  assert(source.includes('label="来源应用"'));
  assert(source.includes('label="优先级"'));
  assert(source.includes('label="状态"'));
});

test('PG-104待办列表字段完整并支持标题查看详情',()=>{
  const source=fs.readFileSync('src/components/portal/TodoCenter.vue','utf8');
  for(const title of ['待办标题','来源应用','业务类型','优先级','状态','接收时间','截止时间','操作']){
    assert(source.includes("title:'"+title+"'"),'缺少待办列表字段 '+title);
  }
  assert(source.includes('@click="openDetail(row)"'));
  assert(source.includes('header="待办详情"'));
  assert(source.includes('源待办ID'));
  assert(source.includes('来源版本'));
  assert(source.includes('待办说明'));
});

test('PG-104仅待处理状态显示去处理并复用openTodo校验',()=>{
  const source=fs.readFileSync('src/components/portal/TodoCenter.vue','utf8');
  assert(source.includes("v-if=\"row.status==='PENDING'\""));
  assert(source.includes("command('openTodo',{id:row.id})"));
  assert(source.includes("confirmBtn:'知道了'"));
  assert(source.includes('onConfirm:()=>dialog.hide()'));
  assert(source.includes('<template #footer>'));
});

test('PG-104展示逾期状态但不修改来源待办状态',()=>{
  const source=fs.readFileSync('src/components/portal/TodoCenter.vue','utf8');
  assert(source.includes("row.status==='PENDING'&&row.dueAt&&Date.parse(row.dueAt)<Date.now()"));
  assert(source.includes('>已逾期</t-tag>'));
  assert(!source.includes("row.status='EXPIRED'"));
});
