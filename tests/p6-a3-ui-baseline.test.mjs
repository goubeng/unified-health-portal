import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';

function walk(dir,ext){
  return fs.readdirSync(dir,{withFileTypes:true}).flatMap(entry=>{
    const full=path.join(dir,entry.name);
    if(entry.isDirectory())return walk(full,ext);
    return full.endsWith(ext)?[full]:[];
  });
}

test('所有TDesign业务弹窗显式垂直居中',()=>{
  for(const file of walk('src','.vue')){
    const source=fs.readFileSync(file,'utf8');
    const tags=[...source.matchAll(/<t-dialog\b[^>]*>/g)].map(match=>match[0]);
    for(const tag of tags){
      assert(
        tag.includes('placement="center"')||tag.includes(':placement'),
        file+' 存在未显式居中的 t-dialog: '+tag
      );
    }
  }
});

test('登录页不恢复滑块下方冗余提示',()=>{
  const source=fs.readFileSync('src/views/Login.vue','utf8');
  assert(!source.includes('slide-verification-tip'));
  assert(!source.includes('按住滑块向右拖动'));
});

test('业务链接保持普通蓝色，不使用粗体强调',()=>{
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(!/portal-page \.portal-field-link\{[^}]*font-weight:600/i.test(css));
  assert(!/portal-home-feeds>\.panel:first-child \.portal-field-link\{[^}]*font-weight:600/i.test(css));
  assert(css.includes('.portal-page .portal-field-link{color:#0052d9!important;font-weight:400!important}'));
});

test('核心信息卡片不恢复自定义hover阴影',()=>{
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(!/\.app-card:hover\{[^}]*box-shadow/i.test(css));
  assert(!/\.admin-overview-card:hover\{[^}]*box-shadow/i.test(css));
});

test('旧系统分类与门户权限配置URL只做兼容跳转',()=>{
  const router=fs.readFileSync('src/router.js','utf8');
  assert(router.includes("{path:'/admin/app-categories',redirect:'/admin/dictionaries'}"));
  assert(router.includes("{path:'/admin/permissions',redirect:'/admin/roles'}"));
  assert(router.includes('pages.filter(page=>!page.hidden)'));
});

test('系统管理正式菜单为用户角色组织字典配置',()=>{
  const source=fs.readFileSync('src/config/pages.js','utf8');
  for(const label of ['用户管理','角色管理','组织管理','字典管理','配置管理'])assert(source.includes("'"+label+"'"));
  assert(source.includes("{...p('PG-203','/admin/app-categories','系统分类'"));
  assert(source.includes("{...p('PG-210','/admin/permissions','门户权限配置'"));
});

test('前端A阶段标准启动仍强制MEMORY_A，不允许默认数据库模式',()=>{
  const pkg=JSON.parse(fs.readFileSync('package.json','utf8'));
  const api=fs.readFileSync('server/api.mjs','utf8');
  assert.equal(pkg.scripts.api,'node server/api.mjs');
  assert.equal(pkg.scripts['api:db'],'node server/api.mjs --db');
  assert(api.includes("PORTAL_REPOSITORY:dbRequested?'db':'memory'"));
});

test('全局业务基线字体仍为13px',()=>{
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(css.includes('--control-font-size:13px'));
  assert(css.includes('body{margin:0;font-size:13px}'));
  assert(css.includes('.t-table td{font-size:13px}'));
});


test('详情入口使用业务字段，不在操作列重复显示详情',()=>{
  const user=fs.readFileSync('src/components/portal/UserManagement.vue','utf8');
  const org=fs.readFileSync('src/components/portal/OrganizationManagement.vue','utf8');
  const monitor=fs.readFileSync('src/components/portal/MonitorManagement.vue','utf8');
  const announcement=fs.readFileSync('src/components/portal/AnnouncementManagement.vue','utf8');
  const logs=fs.readFileSync('src/components/portal/LogManagement.vue','utf8');
  assert(user.includes('#account')&&user.includes('@click="openDetail(row)"'));
  assert(!user.includes('>详情</t-button>'));
  assert(org.includes('#code')&&org.includes('@click="openDetail(row)"'));
  assert(!org.includes('>详情</t-button>'));
  assert(monitor.includes('#appName')&&monitor.includes('@click="openDetail(row)"'));
  assert(!monitor.includes('>查看详情</t-button>'));
  assert(announcement.includes('#title')&&announcement.includes('@click="preview(row)"'));
  const announcementOperation=announcement.split('<template #operation="{row}">')[1]?.split('</template>')[0]||'';
  assert(!announcementOperation.includes('>预览</t-button>'));
  assert(logs.includes('#requestId')&&logs.includes('@click="openDetail(row)"'));
  assert(!logs.includes('>详情</t-button>'));
});

test('管理表单启用状态使用紧凑TDesign开关，不把label写进开关轨道',()=>{
  for(const file of [
    'src/components/portal/UserManagement.vue',
    'src/components/portal/OrganizationManagement.vue',
    'src/components/portal/RoleManagement.vue',
    'src/components/portal/DictionaryManagement.vue'
  ]){
    const source=fs.readFileSync(file,'utf8');
    assert(!source.includes(':label="[\'启用\',\'停用\']"'),file+' 不应使用会拉伸开关的label数组');
    assert(source.includes('form-switch-control'),file+' 应使用统一紧凑开关容器');
  }
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(css.includes('.form-switch-control{'));
  assert(css.includes('.form-switch-control .t-switch{flex:none!important;width:auto!important'));
});
