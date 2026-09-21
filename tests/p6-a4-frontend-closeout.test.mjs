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
  assert(source.includes('label="状态"'));
});

test('PG-104与首页待办详情复用同一组件且元信息按两行两列显示',()=>{
  const center=fs.readFileSync('src/components/portal/TodoCenter.vue','utf8');
  const detail=fs.readFileSync('src/components/portal/TodoDetailContent.vue','utf8');
  const recordDetail=fs.readFileSync('src/components/portal/RecordDetail.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  for(const title of ['待办标题','来源应用','业务类型','状态','接收时间','操作']){
    assert(center.includes("title:'"+title+"'"),'缺少待办列表字段 '+title);
  }
  assert(center.includes('@click="openDetail(row)"'));
  assert(center.includes('header="待办详情"'));
  assert(center.includes('<TodoDetailContent :record="active"/>'));
  assert(recordDetail.includes('<TodoDetailContent v-if="kind===\'todos\'" :record="record"/>'));
  assert(recordDetail.includes("props.kind==='todos'?'待办详情'"));
  assert(detail.includes('class="todo-detail-article"'));
  assert(detail.includes('<h2>{{text(record.title)||\'-\'}}</h2>'));
  assert(detail.includes('<em>来源应用：</em>'));
  assert(detail.includes('<em>业务类型：</em>'));
  assert(detail.includes('<em>接收时间：</em>'));
  assert(detail.includes('<em>状态：</em>'));
  assert(detail.includes('<Icon name="app"/>'));
  assert(detail.includes('<Icon name="task"/>'));
  assert(detail.includes('<Icon name="time"/>'));
  assert(detail.includes('<Icon name="check-circle"/>'));
  assert(detail.includes('class="todo-detail-divider"'));
  assert(!detail.includes('待办说明'));
  assert(!detail.includes('源待办ID'));
  assert(css.includes('.todo-detail-meta-inline{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:12px 24px;align-items:center}'));
  assert(css.includes('.todo-detail-meta-inline>span{display:flex;align-items:center;gap:5px;min-width:0;white-space:nowrap}'));
  assert(css.includes('.todo-detail-meta-inline em{flex:none'));
});

test('PG-104仅待处理状态显示去处理并复用openTodo校验',()=>{
  const source=fs.readFileSync('src/components/portal/TodoCenter.vue','utf8');
  assert(source.includes("v-if=\"row.status==='PENDING'\""));
  assert(source.includes("command('openTodo',{id:row.id})"));
  assert(source.includes("confirmBtn:'知道了'"));
  assert(source.includes('onConfirm:()=>dialog.hide()'));
  assert(source.includes('<template #footer>'));
});

test('PG-104不展示优先级截止时间逾期来源版本和终态时间',()=>{
  const source=fs.readFileSync('src/components/portal/TodoCenter.vue','utf8');
  for(const text of ['优先级','截止时间','已逾期','来源版本','终态时间'])assert(!source.includes(text),text+' 不应出现在待办页面');
  assert(!source.includes('dueAt'));
  assert(!source.includes('sourceRevision'));
  assert(!source.includes('terminalAt'));
});


test('PG-002和PG-104文档状态已收口',()=>{
  const pageList=fs.readFileSync('docs/01-需求/02-当前基线/细化需求/页面清单.md','utf8');
  const pageSpec=fs.readFileSync('docs/01-需求/02-当前基线/细化需求/页面规格.md','utf8');
  const functionList=fs.readFileSync('docs/01-需求/02-当前基线/细化需求/功能清单.md','utf8');
  assert(pageList.includes('| PG-002 | 登录端 | 认证结果 | /auth/result | 前端Mock已完成'));
  assert(pageList.includes('| PG-104 | 用户端 | 待办任务 | /portal/todos | 前端Mock已完成'));
  assert(!pageList.includes('PG-104 | 用户端 | 待办任务 | /portal/todos | 待补字段/查询'));
  assert(pageSpec.includes('## PG-002 认证结果'));
  assert(pageSpec.includes('## PG-104 待办任务'));
  assert(functionList.includes('| F-08 | 用户端 | 待办任务 | 本人待办查询、详情、去处理、状态展示'));
  assert(functionList.includes('前端Mock已完成 / 真实跳转待C'));
});
