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

test('登录页不恢复冗余演示提示且身份页签字重与间距固定',()=>{
  const source=fs.readFileSync('src/views/Login.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(!source.includes('slide-verification-tip'));
  assert(!source.includes('按住滑块向右拖动'));
  assert(!source.includes('管理账号当前仅用于原型演示'));
  assert(!source.includes('演示验证码仅用于页面展示'));
  assert(!source.includes('演示账号默认：admin01'));
  assert(!source.includes('密码和验证码可任意填写或保持默认值'));
  assert(!source.includes('当前演示管理账号不可用'));
  assert(css.includes('.login-identity-switch{justify-content:space-around;align-items:flex-end;gap:32px;padding:0 22px;margin-top:10px!important}'));
  assert(css.includes('.identity-pill{font-size:18px!important;font-weight:500!important'));
  assert(css.includes('.identity-pill>span{display:inline-block;position:relative;padding:0 2px 9px;font-size:18px;font-weight:500;line-height:1.35}'));
});

test('消息中心头部未读统计复用待办任务标题计数样式',()=>{
  const source=fs.readFileSync('src/components/portal/MessageCenter.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(source.includes('class="portal-title-count"'));
  assert(source.includes('class="portal-title-count-number">{{ unreadCount }}</span>封未读）'));
  assert(!source.includes('message-header-count'));
  assert(!source.includes('共{{ rows.length }}封'));
  assert(css.includes('.portal-title-count{font-size:13px!important;font-weight:400!important;color:#344054!important}'));
  assert(css.includes('.portal-title-count-number{color:#e34d59!important;font-weight:600!important}'));
});

test('首页待办公告消息标题链接使用同一规则且未读状态不改变样式',()=>{
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(css.includes('/* 2026-09-21 home feed title links: todo / announcement / message use one rule, including unread states. */'));
  assert(css.includes('.portal-page .portal-home-feeds .list-row .portal-field-link,'));
  assert(css.includes('.portal-page .portal-home-feeds .list-row .portal-field-link.is-unread,'));
  assert(css.includes('.portal-page .portal-home-feeds .list-row .portal-field-link.is-attention{'));
  assert(!css.includes('.portal-home-feeds>.panel:first-child .portal-field-link'));
  assert(!css.includes('.portal-page .portal-home-feeds .portal-field-link,\n.portal-page .portal-table-panel .portal-field-link,'));
  assert(css.includes('color:#0052d9!important;'));
  assert(css.includes('font-size:13px!important;'));
  assert(css.includes('font-weight:500!important;'));
  assert(css.includes('.portal-page .portal-home-feeds .list-row .portal-field-link.is-unread:hover,'));
  assert(css.includes('color:#003cab!important;'));
  assert(css.includes('text-decoration:underline!important;'));
  assert(css.includes('.portal-page .portal-app-name,'));
  assert(css.includes('color:#1f2329!important;'));
});

test('管理首页概览左图右两行且四个图标均有背景色',()=>{
  const source=fs.readFileSync('src/views/PortalPage.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  for(const label of ['纳管应用','启用应用','门户用户','接入异常','待处理事项','接入运行状态','常用管理'])assert(source.includes(label),label+' 未体现');
  assert(!source.includes("{label:'正常应用'"));
  assert(!source.includes("{label:'异常应用'"));
  assert(source.includes('class="admin-overview-icon"'));
  assert(source.includes('class="admin-overview-content"'));
  assert(!source.includes('{{card.hint}}'));
  assert(!source.includes("hint:'统一应用目录'"));
  assert(!source.includes("hint:'当前启用'"));
  assert(!source.includes("hint:'已建立统一用户索引'"));
  assert(!source.includes("hint:'已配置服务运行异常'"));
  assert(!source.includes('按当前账号权限显示'));
  assert(!source.includes('快速进入常用管理模块'));
  assert(source.includes('<strong>新增公告</strong>'));
  assert(source.includes("router.push({path:'/admin/announcements',query:{action:'create'}})"));
  assert(source.includes('class="admin-workbench-grid"'));
  assert(source.includes('class="admin-health-workbench-grid"'));
  assert(source.includes('class="admin-shortcut-grid"'));
  assert(source.includes('class="admin-shortcut-card"'));
  assert(source.includes("icon:'app',tone:'blue'"));
  assert(source.includes("icon:'check-circle',tone:'green'"));
  assert(source.includes("icon:'user',tone:'purple'"));
  assert(source.includes("icon:'error-circle',tone:'red'"));
  assert(source.includes('adminPendingItems'));
  assert(!/adminPendingItems=computed\(\(\)=>\[[\s\S]*tone:'(?:blue|cyan|orange|red|yellow|purple)'/.test(source));
  assert(source.includes("overview.value.abnormalServiceCount??0"));
  assert(source.includes("latest(homeExceptions,'lastCheckedAt')"));
  assert(css.includes('.admin-overview-card{'));
  assert(css.includes('flex-direction:row!important'));
  assert(css.includes('.admin-overview-content{display:flex;min-width:0;flex:1;flex-direction:column'));
  assert(css.includes('.admin-overview-icon{display:inline-flex;width:38px;height:38px;flex:none;align-items:center;justify-content:center;border-radius:4px;background:#f2f3f5;color:#697386}'));
  for(const tone of ['blue','green','purple','red'])assert(css.includes('.admin-overview-icon.tone-'+tone),tone+' 图标背景未配置');
  assert(css.includes('.admin-reminder-card{'));
  assert(css.includes('background:#f6f8fb!important'));
  assert(!css.includes('.admin-reminder-card.tone-blue{'));
  assert(css.includes('.admin-health-workbench-grid{display:grid;grid-template-columns:minmax(0,.9fr) minmax(0,1.1fr)'));
  assert(css.includes('.admin-service-health-grid{display:grid!important;grid-template-columns:1fr!important'));
  assert(source.includes('class="admin-health-stat is-normal"><Icon name="check-circle"/><em>正常</em><b>{{overview.serviceHealth[kind]?.normal??0}}</b>'));
  assert(source.includes('class="admin-health-stat is-abnormal"><Icon name="error-circle"/><em>异常</em><b>{{overview.serviceHealth[kind]?.abnormal??0}}</b>'));
  assert(source.includes('class="admin-health-stat is-muted"><Icon name="minus-circle"/><em>未配置/停用</em><b>{{overview.serviceHealth[kind]?.unconfigured??0}}</b>'));
  assert(css.includes('.admin-health-stat.is-normal,.admin-health-stat.is-normal b,.admin-health-stat.is-normal>.t-icon{color:#2ba471!important}'));
  assert(css.includes('.admin-health-stat.is-abnormal,.admin-health-stat.is-abnormal b,.admin-health-stat.is-abnormal>.t-icon{color:#d54941!important}'));
  assert(css.includes('.admin-health-stat.is-muted,.admin-health-stat.is-muted b,.admin-health-stat.is-muted>.t-icon{color:#86909c!important}'));
});

test('管理首页新增公告快捷入口进入公告管理并自动打开新增弹窗',()=>{
  const source=fs.readFileSync('src/components/portal/AnnouncementManagement.vue','utf8');
  assert(source.includes("import {useRoute,useRouter} from 'vue-router'"));
  assert(source.includes("watch(()=>route.query.action,value=>"));
  assert(source.includes("if(value!=='create')return"));
  assert(source.includes('openCreate();'));
  assert(source.includes('delete query.action;'));
  assert(source.includes("router.replace({path:route.path,query})"));
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

test('角色更新时间格式与日志首列详情入口保持规范',()=>{
  const role=fs.readFileSync('src/components/portal/RoleManagement.vue','utf8');
  const logs=fs.readFileSync('src/components/portal/LogManagement.vue','utf8');
  assert(role.includes('<template #updatedAt="{row}">{{roleUpdatedAt(row.updatedAt)}}</template>'));
  assert(role.includes("function roleUpdatedAt(value){"));
  assert(role.includes("d.getFullYear()"));
  assert(role.includes("d.getMonth()+1"));
  assert(role.includes("pad(d.getHours())"));
  assert(logs.includes('<template #serial="{rowIndex}">{{(page-1)*pageSize+rowIndex+1}}</template>'));
  assert(logs.includes("const serial={colKey:'serial',title:'序号',width:64};"));
  assert(logs.includes("const requestId={colKey:'requestId',title:'请求ID',width:190,ellipsis:true};"));
  assert.equal((logs.match(/serial,requestId,/g)||[]).length,5);
  assert(logs.includes('<template #requestId="{row}"><button class="portal-field-link" @click="openDetail(row)">'));
});

test('全系统TDesign开关统一使用默认无文字样式',()=>{
  for(const file of walk('src','.vue')){
    const source=fs.readFileSync(file,'utf8');
    const switches=[...source.matchAll(/<t-switch\b[^>]*>/g)].map(match=>match[0]);
    for(const tag of switches){
      assert(!/\blabel=|:label=/.test(tag),file+' 的开关不应显示文字: '+tag);
    }
    assert(!source.includes('form-switch-control'),file+' 不应恢复开关外部启用/停用文字');
    assert(!source.includes('user-status-switch'),file+' 不应恢复用户管理专用文字开关');
  }
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(!css.includes('.user-status-switch.t-switch'));
  assert(!css.includes('.form-switch-control{'));
});


test('新增公告主操作固定在Dialog Footer，正文单独滚动',()=>{
  const source=fs.readFileSync('src/components/portal/AnnouncementManagement.vue','utf8');
  assert(source.includes('<template #footer>'));
  assert(source.includes('class="announcement-form-actions"'));
  const formDialog=source.split('header="新增公告"')[1]?.split('</t-dialog>')[0]||'';
  assert(formDialog.includes('<template #footer>'));
  assert(!formDialog.includes(':footer="false"'));
  const editorIndex=source.indexOf('<AnnouncementEditor');
  const footerIndex=source.indexOf('<template #footer>',editorIndex);
  assert(editorIndex>=0&&footerIndex>editorIndex);
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(css.includes('.t-dialog__body{max-height:65vh;overflow:auto}'));
});

test('我的应用隐藏正常关联状态，其它应用保留状态提示',()=>{
  const page=fs.readFileSync('src/views/PortalPage.vue','utf8');
  const cards=fs.readFileSync('src/components/portal/AppCards.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(page.includes('compact hide-normal-state'));
  assert(page.includes(':hide-normal-state="group.key===\'mine\'"'));
  assert(cards.includes("props.hideNormalState&&app.accessState==='BOUND'"));
  assert(cards.includes('class="portal-app-status-tag"'));
  assert(css.includes('.portal-app-status-tag,.portal-app-status-tag .t-tag__text{font-size:12px!important'));
});


test('公众用户所属单位允许为空并统一显示英文半角短横线',()=>{
  const profile=fs.readFileSync('src/components/portal/PersonalProfile.vue','utf8');
  const seed=fs.readFileSync('src/mock/seed.js','utf8');
  assert(profile.includes("{key:'orgName',label:'所属单位',value:text(props.user.orgName)||'-'}"));
  assert(profile.includes("<p>{{text(user.orgName)||'-'}}</p>"));
  assert(seed.includes("userType:'CITIZEN',orgName:'',orgKey:''"));
  assert(!seed.includes("userType:'CITIZEN',orgName:'公众服务'"));
});

test('我的申请Tab与列表保持16px间距',()=>{
  const source=fs.readFileSync('src/components/portal/MyApplications.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert.equal((source.match(/class="my-applications-table"/g)||[]).length,2);
  assert(css.includes('.my-applications-table{margin-top:16px}'));
});

test('新增公告启用Dialog Footer且主操作不会被footer=false关闭',()=>{
  const source=fs.readFileSync('src/components/portal/AnnouncementManagement.vue','utf8');
  const formDialog=source.split('header="新增公告"')[1]?.split('</t-dialog>')[0]||'';
  assert(formDialog.includes('<template #footer>'));
  assert(!formDialog.includes(':footer="false"'));
  assert(formDialog.includes('取消'));
  assert(formDialog.includes('预览'));
  assert(formDialog.includes('saveAnnouncement'));
});


test('公告详情正文默认最小高度为350px且不被后续样式覆盖',()=>{
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(css.includes('.portal-announcement-body{min-height:350px!important'));
  assert(!css.includes('.portal-announcement-body{min-height:0!important'));
});

test('系统空值占位统一使用英文半角短横线',()=>{
  const presentation=fs.readFileSync('src/components/portal/presentation.js','utf8');
  assert(presentation.includes("||'-';"));
  assert(presentation.includes(":'-';"));
  for(const file of walk('src','.vue')){
    const source=fs.readFileSync(file,'utf8');
    assert(!/\|\|\s*['\"]—['\"]/.test(source),file+' 仍存在全角长横线空值占位');
    assert(!/>\s*—\s*</.test(source),file+' 仍存在全角长横线空值占位');
  }
  for(const file of walk('src','.js')){
    const source=fs.readFileSync(file,'utf8');
    assert(!/\|\|\s*['\"]—['\"]/.test(source),file+' 仍存在全角长横线空值占位');
  }
});


test('公告详情保持通知公告菜单选中且返回直接回列表',()=>{
  const app=fs.readFileSync('src/App.vue','utf8');
  assert(app.includes('const isMenuActive=page=>'));
  assert(app.includes("route.meta.resource==='announcementDetail'&&page.resource==='announcements'"));
  assert(app.includes(":class=\"{active:isMenuActive(p)}\""));
  assert(!app.includes('route.query.mode'));
  assert(app.includes("router.push(admin.value?'/admin/announcements':'/portal/announcements')"));
});

test('管理端公告详情保留右侧内容区而编辑统一使用弹窗',()=>{
  const list=fs.readFileSync('src/components/portal/AnnouncementManagement.vue','utf8');
  const page=fs.readFileSync('src/views/PortalPage.vue','utf8');
  const editor=fs.readFileSync('src/components/portal/AnnouncementEditPage.vue','utf8');
  assert(list.includes('@click="$emit(\'detail\',row)"'));
  assert(list.includes('@click="openEdit(row)"'));
  assert(list.includes('function openEdit(row){editRow.value=JSON.parse(JSON.stringify(row));editVisible.value=true;}'));
  assert(list.includes('v-model:visible="editVisible"'));
  assert(!list.includes('@edit="openAdminAnnouncementEdit"'));
  assert(page.includes('v-model:visible="announcementEditVisible"'));
  assert(page.includes("@detail=\"openAdminAnnouncementDetail\""));
  assert(!page.includes('route.query.mode'));
  assert(editor.includes('<t-dialog'));
  assert(editor.includes('header="编辑公告"'));
  assert(!editor.includes('to="#page-header-actions"'));
});

test('新增公告仅定时发布时显示定时发布时间且失效日期按当天235959处理',()=>{
  const source=fs.readFileSync('src/components/portal/AnnouncementManagement.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  const createDialog=source.split('header="新增公告"')[1]?.split('</t-dialog>')[0]||'';
  assert(createDialog.includes("class=\"announcement-publish-row\" :class=\"{'is-scheduled':form.publishMode==='SCHEDULED'}\""));
  assert(createDialog.includes('v-model="form.publishMode"'));
  assert(createDialog.includes('value="IMMEDIATE"'));
  assert(createDialog.includes('value="SCHEDULED"'));
  assert(createDialog.includes("v-if=\"form.publishMode==='SCHEDULED'\""));
  assert(createDialog.includes('v-model="form.scheduledPublishAt"'));
  assert(!createDialog.includes(":disabled=\"form.publishMode!=='SCHEDULED'\""));
  assert(!createDialog.includes('立即发布无需选择'));
  assert(createDialog.includes('v-model="form.effectiveEnd"'));
  assert(createDialog.includes('format="YYYY-MM-DD"'));
  assert(!createDialog.includes('v-model="form.effectiveEnd" enable-time-picker'));
  assert(css.includes('.announcement-publish-row{grid-column:1/-1;display:grid;grid-template-columns:repeat(12,minmax(0,1fr))'));
  assert(css.includes('.announcement-publish-row .announcement-publish-mode-field{grid-column:span 6}'));
  assert(css.includes('.announcement-publish-row .announcement-expiry-field{grid-column:span 6}'));
  assert(css.includes('.announcement-publish-row.is-scheduled .announcement-publish-mode-field{grid-column:span 3}'));
  assert(css.includes('.announcement-publish-row.is-scheduled .announcement-schedule-field{grid-column:span 3}'));
  assert(css.includes('.announcement-publish-row.is-scheduled .announcement-expiry-field{grid-column:span 6}'));
  assert(source.includes("function toEndOfDayIso(value){return value?new Date(String(value).slice(0,10)+'T23:59:59').toISOString():null;}"));
  assert(source.includes('async function saveAndPublish()'));
  assert(source.includes("form.publishMode==='SCHEDULED'?'定时发布':'立即发布'"));
});

test('新增草稿定时发布和已撤回编辑共用发布布局与操作按钮',()=>{
  const create=fs.readFileSync('src/components/portal/AnnouncementManagement.vue','utf8');
  const source=fs.readFileSync('src/components/portal/AnnouncementEditPage.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(source.includes("const isDraft=computed(()=>form.status==='DRAFT')"));
  assert(source.includes("const isScheduled=computed(()=>form.status==='SCHEDULED')"));
  assert(source.includes("const isWithdrawn=computed(()=>form.status==='WITHDRAWN')"));
  assert(source.includes('const isPublishEditable=computed(()=>isDraft.value||isScheduled.value||isWithdrawn.value)'));
  assert(source.includes('v-if="isPublishEditable"'));
  assert(source.includes('<template v-if="isPublishEditable">'));
  assert(source.includes('v-model="form.publishMode"'));
  assert(source.includes("v-if=\"form.publishMode==='SCHEDULED'\""));
  assert(source.includes("if(!form.publishMode)form.publishMode=form.status==='SCHEDULED'?'SCHEDULED':'IMMEDIATE'"));
  assert(source.includes('@click="saveDraft">保存草稿</t-button>'));
  assert(source.includes("@click=\"publishDraft\">{{form.publishMode==='SCHEDULED'?'定时发布':'立即发布'}}</t-button>"));
  assert(source.includes("saveBase({targetStatus:'DRAFT'})"));
  assert(source.includes("command('submitAnnouncement'"));
  assert(source.includes("class=\"announcement-publish-row\""));
  assert(create.includes('@click="saveAnnouncement">保存草稿</t-button>'));
  assert(create.includes("@click=\"saveAndPublish\">{{form.publishMode==='SCHEDULED'?'定时发布':'立即发布'}}</t-button>"));
  assert(css.includes('.announcement-publish-row .announcement-publish-mode-field{grid-column:span 6}'));
  assert(css.includes('.announcement-publish-row.is-scheduled .announcement-expiry-field{grid-column:span 6}'));
  assert(source.includes('<label>失效日期</label>'));
  assert(source.includes('format="YYYY-MM-DD"'));
  assert(source.includes("function toEndOfDayIso(value){return value?new Date(String(value).slice(0,10)+'T23:59:59').toISOString():null;}"));
});

test('侧边菜单与折叠控件对齐office-house当前样式',()=>{
  const source=fs.readFileSync('src/App.vue','utf8');
  const css=fs.readFileSync('src/styles/layout.css','utf8');
  assert(source.includes('<t-button class="collapse-button" shape="square" variant="text"'));
  assert(source.includes('<template #icon><component :is="collapsed?MenuUnfoldIcon:MenuFoldIcon"/></template>'));
  assert(css.includes('.menu-wrap{height:100%;padding:10px 8px;overflow:auto;overflow-x:hidden;flex:1}'));
  assert(css.includes('.menu-wrap.collapsed{padding:10px 7px}'));
  assert(css.includes('.menu-group{box-sizing:border-box;width:100%;display:flex;align-items:center;justify-content:space-between;padding:10px 12px 6px'));
  assert(css.includes('font-size:13px;font-weight:600;letter-spacing:.04em'));
  assert(css.includes('.menu-item{box-sizing:border-box;width:100%;height:36px;display:flex;align-items:center;gap:10px;padding:0 10px 0 12px'));
  assert(css.includes('.menu-item.active{background:#e9edff;color:#2454ff;font-weight:500}'));
  assert(css.includes('.collapsed .aside{width:48px;background:#f8fafc}'));
  assert(css.includes('.menu-wrap.collapsed .menu-item{width:32px;height:32px;justify-content:center;margin:0 auto 6px;padding:0;overflow:visible}'));
  assert(!css.includes('drop-shadow(.35px 0 0 currentColor)'));
  assert(!css.includes('.collapse-button .t-icon{width:18px!important'));
});

test('折叠菜单为主要页面和五类日志显式分配可区分图标',()=>{
  const source=fs.readFileSync('src/App.vue','utf8');
  for(const mapping of [
    'home:HomeIcon','todos:TaskIcon','myApplicationRequests:FileIcon','messages:MailIcon','announcements:NotificationIcon','profile:UserIcon','apps:AppIcon',
    'users:UserIcon','roles:UserSafetyIcon','organizations:FolderIcon','dictionaries:BookIcon','identityOverview:LinkIcon','settings:SettingIcon','monitor:ChartBarIcon','accountOpeningRequests:UserAddIcon',
    "'logs:login':UserPasswordIcon","'logs:access':ActivityIcon","'logs:operation':TaskIcon","'logs:api':CodeIcon","'logs:error':BugReportIcon"
  ])assert(source.includes(mapping),mapping+' 未配置');
});

test('公告操作权限为撤回可编辑删除且过期仅删除',()=>{
  const list=fs.readFileSync('src/components/portal/AnnouncementManagement.vue','utf8');
  const page=fs.readFileSync('src/views/PortalPage.vue','utf8');
  const service=fs.readFileSync('src/services/portal.js','utf8');
  assert(list.includes("['DRAFT','SCHEDULED','PUBLISHED','WITHDRAWN'].includes(row.status)"));
  assert(list.includes("['DRAFT','WITHDRAWN','EXPIRED'].includes(row.status)"));
  assert(page.includes("['DRAFT','SCHEDULED','PUBLISHED','WITHDRAWN'].includes(detail.status)"));
  assert(page.includes("['DRAFT','WITHDRAWN','EXPIRED'].includes(detail.status)"));
  assert(page.includes('function removeAdminAnnouncementDetail(row){'));
  assert(service.includes("if(effectiveStatus==='EXPIRED')fail('INVALID_TRANSITION','已过期公告不可编辑')"));
  assert(service.includes("if(effectiveStatus==='WITHDRAWN'&&p.targetStatus!=='DRAFT'){x.status='WITHDRAWN'"));
  assert(service.includes("if(p.targetStatus==='DRAFT')"));
});

test('公告撤回删除确认分别使用warning和danger提示主题',()=>{
  const source=fs.readFileSync('src/components/portal/AnnouncementManagement.vue','utf8');
  const withdraw=source.split('function withdraw(row){')[1]?.split('function remove(row){')[0]||'';
  const remove=source.split('function remove(row){')[1]?.split('async function fileToDataUrl')[0]||'';
  assert(withdraw.includes("theme:'warning'"));
  assert(withdraw.includes("confirmBtn:{content:'确认撤回',theme:'warning'}"));
  assert(remove.includes("theme:'danger'"));
  assert(remove.includes("confirmBtn:{content:'确认删除',theme:'danger'}"));
});


test('用户管理查询去组织字段并缩小姓名账号宽度',()=>{
  const source=fs.readFileSync('src/components/portal/UserManagement.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  const queryBlock=source.split('<t-form layout="inline" class="portal-query list-toolbar">')[1]?.split('</t-form>')[0]||'';
  assert(queryBlock.includes('class="portal-query-keyword user-query-keyword"'));
  assert(!queryBlock.includes('label="所属组织"'));
  assert(!source.includes("{colKey:'orgName',title:'所属组织'"));
  assert(css.includes('.user-management .portal-query .user-query-keyword{width:220px!important}'));
});

test('新增编辑用户门户角色使用平铺多选项',()=>{
  const source=fs.readFileSync('src/components/portal/UserManagement.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert.equal((source.match(/<t-checkbox-group v-model="form.roleIds" class="user-role-options">/g)||[]).length,2);
  assert(source.includes('v-for="option in roleOptions"'));
  assert(!source.includes('<t-select v-model="form.roleIds" multiple'));
  assert(css.includes('.user-role-options{display:flex!important;align-items:center;flex-wrap:wrap'));
});

test('角色权限配置只保留Dialog外层滚动条',()=>{
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(css.includes('.t-dialog__body{max-height:65vh;overflow:auto}'));
  assert(css.includes('.role-permission-groups{display:flex;flex-direction:column;gap:10px;max-height:none;overflow:visible;padding-right:0}'));
  assert(!css.includes('.role-permission-groups{display:flex;flex-direction:column;gap:10px;max-height:430px;overflow:auto'));
});


test('页面编号唯一且管理端公告详情使用PG-235',()=>{
  const source=fs.readFileSync('src/config/pages.js','utf8');
  const ids=[...source.matchAll(/p\('([^']+)'/g)].map(match=>match[1]);
  assert.equal(new Set(ids).size,ids.length,'页面编号不应重复');
  assert(source.includes("p('PG-235','/admin/announcements/:id','公告详情'"));
  assert(source.includes("p('PG-229','/admin/organizations','组织管理'"));
});

test('主需求规格说明书作为唯一权威需求且功能清单保持模块级',()=>{
  const srs=fs.readFileSync('docs/01-需求/02-当前基线/卫健统一门户系统需求规格说明书.md','utf8');
  const functionList=fs.readFileSync('docs/01-需求/02-当前基线/细化需求/功能清单.md','utf8');
  assert(srs.includes('# 卫健统一门户系统需求规格说明书'));
  assert(srs.includes('当前唯一权威需求基线'));
  assert(srs.includes('## 30. 通知公告管理'));
  assert(srs.includes('## 37. 通用交互要求'));
  assert(functionList.includes('| F-23 | 管理端 | 通知公告管理 |'));
  assert(functionList.includes('页面字段、状态、交互、业务规则等详细要求统一以《卫健统一门户系统需求规格说明书》为准'));
});


test('应用访问提示点击知道了直接关闭',()=>{
  const source=fs.readFileSync('src/views/PortalPage.vue','utf8');
  const block=source.split('async function run(action,payload,show=false){')[1]?.split('const enterApp=')[0]||'';
  assert(block.includes("confirmBtn:'知道了'"));
  assert(block.includes('onConfirm:()=>dialog.hide()'));
});

test('其他应用账号处理改为结果导向且不暴露底层验证过程',()=>{
  const source=fs.readFileSync('src/components/portal/AccountBindingWizard.vue','utf8');
  const cards=fs.readFileSync('src/components/portal/AppCards.vue','utf8');
  assert(source.includes('需要完成账号确认'));
  assert(source.includes('需要开通账号'));
  assert(source.includes('前往子系统确认'));
  assert(source.includes('前往子系统开通'));
  assert(source.includes('完成后重新检测'));
  assert(source.includes('统一门户不采集这些凭据'));
  assert(!source.includes('查找已有子系统账号'));
  assert(!source.includes('验证账号归属'));
  assert(!source.includes('请输入已有子系统账号'));
  assert(!source.includes('演示环境验证码'));
  assert(!source.includes('子系统密码'));
  assert(cards.includes("BIND:'申请使用'"));
  assert(cards.includes("CONTINUE_BIND:'继续处理'"));
  assert(cards.includes("VIEW_CONFLICT:'查看原因'"));
});

test('运行监控详情使用单表展示接入配置与运行健康且不显示阶段提示',()=>{
  const source=fs.readFileSync('src/components/portal/MonitorManagement.vue','utf8');
  assert(source.includes("title:'接入服务'"));
  assert(source.includes("title:'配置状态'"));
  assert(source.includes("title:'运行状态'"));
  assert(source.includes("title:'最近检测'"));
  assert(source.includes("title:'响应耗时'"));
  assert(source.includes("title:'最近错误'"));
  assert(source.includes('width="min(1180px, calc(100vw - 48px))"'));
  assert(!source.includes('monitor-service-grid'));
  assert(!source.includes('当前为A阶段运行场景数据'));
});




test('鼠标悬浮Tooltip提示文字统一为12px',()=>{
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(css.includes('.t-tooltip .t-popup__content{font-size:12px!important;}'));
});
test('系统提示统一复用PortalTooltip而非原生title',()=>{
  const source=fs.readFileSync('src/App.vue','utf8');
  const tooltip=fs.readFileSync('src/components/portal/PortalTooltip.vue','utf8');
  const nav=source.split('<nav class="menu-wrap"')[1]?.split('</nav>')[0]||'';
  assert(tooltip.includes('<t-tooltip'));
  assert(nav.includes('<PortalTooltip'));
  assert(nav.includes('placement="right"'));
  assert(nav.includes(':disabled="!collapsed"'));
  assert(source.includes('<PortalTooltip content="消息中心" placement="bottom">'));
  assert(source.includes(":content=\"collapsed?'展开菜单':'收起菜单'\""));
  for(const file of walk('src','.vue')){
    const vue=fs.readFileSync(file,'utf8');
    assert(!/(?:^|[\s<]):?title\s*=\s*(?:\"[^\"]*\"|'[^']*')/m.test(vue),file+' 仍存在原生title提示');
  }
});

test('页面数据完成前只显示Loading不渲染Empty业务内容',()=>{
  const source=fs.readFileSync('src/views/PortalPage.vue','utf8');
  assert(source.includes("loading=ref(true),pageReady=ref(false)"));
  assert(source.includes('class="portal-loading-placeholder"'));
  assert(source.includes('<template v-else>'));
  assert(source.includes("const version=++loadVersion;loading.value=true;error.value=''"));
  assert(source.includes("watch(()=>route.fullPath,()=>{pageReady.value=false;"));
  assert(source.includes("if(version===loadVersion&&!error.value)pageReady.value=true"));
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(css.includes('.portal-loading-placeholder{min-height:320px'));
});

test('用户类别Tag按类别使用不同配色',()=>{
  const source=fs.readFileSync('src/components/portal/UserManagement.vue','utf8');
  assert(source.includes(':theme="userTypeTheme(row.userType)"'));
  assert(source.includes("CITIZEN:'primary'"));
  assert(source.includes("GOV:'success'"));
  assert(source.includes("LOCAL:'warning'"));
});

test('系统提示框统一13px紧凑高度并覆盖用户详情来源提示',()=>{
  const user=fs.readFileSync('src/components/portal/UserManagement.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(user.includes('class="user-source-alert"'));
  assert(user.includes('姓名、账号、用户类别和身份来源等权威身份字段来自'));
  assert(css.includes('/* 2026-09-21 unified compact prompt/alert baseline. */'));
  assert(css.includes('.portal-page .t-alert,'));
  assert(css.includes('.t-dialog__body .t-alert{'));
  assert(css.includes('min-height:32px!important;'));
  assert(css.includes('padding:6px 10px!important;'));
  assert(css.includes('font-size:13px!important;'));
  assert(css.includes('line-height:20px!important;'));
  assert(css.includes('.portal-page .inline-note,'));
  assert(css.includes('.user-source-alert,'));
  assert(css.includes('.organization-source-alert,'));
  assert(css.includes('.dictionary-lock-alert,'));
});

test('角色超级管理员提示位于表单头部并使用13px紧凑提示',()=>{
  const source=fs.readFileSync('src/components/portal/RoleManagement.vue','utf8');
  const errorIndex=source.indexOf('class="error-note"');
  const alertIndex=source.indexOf('class="role-permission-note"');
  const formIndex=source.indexOf('class="form-grid role-basic-form"');
  assert(errorIndex>=0&&alertIndex>errorIndex&&formIndex>alertIndex);
  assert.equal((source.match(/class="role-permission-note"/g)||[]).length,1);
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(css.includes('.role-permission-note{margin:0 0 14px!important;padding:6px 10px!important;min-height:32px!important;font-size:13px!important'));
});

test('身份与子系统映射详情分区加宽并提供子系统分页',()=>{
  const source=fs.readFileSync('src/components/portal/IdentityMappings.vue','utf8');
  assert(source.includes('>基本信息</h3>'));
  assert(source.includes('>子系统映射</h3>'));
  assert(source.includes('width="min(1320px, calc(100vw - 48px))"'));
  assert(source.includes(':data="mappingPaged"'));
  assert(source.includes('v-model="mappingPage"'));
  assert(source.includes('v-model:page-size="mappingPageSize"'));
  assert(source.includes(':total="selectedMappings.length"'));
});


test('所有列表空态统一使用nopic公共组件且通用列表不回退纯文字empty',()=>{
  const empty=fs.readFileSync('src/components/portal/EmptyState.vue','utf8');
  const page=fs.readFileSync('src/views/PortalPage.vue','utf8');
  const message=fs.readFileSync('src/components/portal/MessageCenter.vue','utf8');
  const todo=fs.readFileSync('src/components/portal/TodoCenter.vue','utf8');
  assert(empty.includes("import nopic from '../../assets/nopic.svg'"));
  assert(empty.includes('<img :src="nopic"'));
  assert(page.includes('<template #empty><EmptyState description="暂无符合条件的记录"/></template>'));
  assert(page.includes("resource==='accountOpeningRequests'"));
  assert(!page.includes('empty="暂无符合条件的记录"'));
  assert(!message.includes('empty="暂无符合条件的消息"'));
  assert(!todo.includes('empty="暂无符合条件的待办"'));
});

test('用户端首页我的应用应用中心链接进入可用应用中心路由',()=>{
  const page=fs.readFileSync('src/views/PortalPage.vue','utf8');
  assert(page.includes('<router-link to="/portal/apps/all">应用中心</router-link>'));
  assert(!page.includes('<router-link to="/portal/apps/mine">应用中心</router-link>'));
});


test('Vue源码不允许重复import声明',()=>{
  for(const file of walk('src','.vue')){
    const source=fs.readFileSync(file,'utf8');
    const imports=source.split('\n').filter(line=>/^import\s+/.test(line.trim()));
    assert.equal(new Set(imports).size,imports.length,file+' 存在重复import声明');
  }
});


test('用户详情来源提示显示在详情网格上方',()=>{
  const source=fs.readFileSync('src/components/portal/UserManagement.vue','utf8');
  const dialog=source.split('header="用户详情"')[1]?.split('</t-dialog>')[0]||'';
  assert(dialog.indexOf('class="user-source-alert"')>=0);
  assert(dialog.indexOf('class="user-source-alert"')<dialog.indexOf('<DetailGrid v-if="detail" :items="detailItems"/>'));
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(css.includes('.user-detail-source-alert{margin:0 0 14px!important}'));
  assert(css.includes('.user-detail-source-alert + .portal-detail-grid{margin-top:0}'));
});


test('子系统映射详情提供序号搜索统计图标与独立分页',()=>{
  const source=fs.readFileSync('src/components/portal/IdentityMappings.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(source.includes("{colKey:'mappingSerial',title:'序号',width:64}"));
  assert(source.includes('<template #mappingSerial="{rowIndex}">{{(mappingPage-1)*mappingPageSize+rowIndex+1}}</template>'));
  assert(source.includes('v-model="mappingKeyword"'));
  assert(source.includes('placeholder="搜索系统名称 / 子系统账号"'));
  assert(source.includes('CheckCircleIcon'));
  assert(source.includes('ErrorCircleIcon'));
  assert(source.includes('已关联 <strong>{{selected.boundCount??0}}</strong> 个'));
  assert(source.includes('异常 <strong>{{selected.exceptionCount??0}}</strong> 个'));
  assert(source.includes("return mappings.filter(mapping=>[mapping.appName,mapping.externalAccount].some"));
  assert(source.includes(':total="selectedMappings.length"'));
  assert(css.includes('.identity-mapping-search{width:280px;flex:none}'));
  assert(css.includes('.identity-mapping-summary-item strong{font-weight:600'));
});


test('编辑外部用户边界说明使用统一提示框',()=>{
  const source=fs.readFileSync('src/components/portal/UserManagement.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(source.includes('<t-alert theme="info" class="user-external-edit-alert">'));
  assert(source.includes('外部身份字段只读；此处仅维护门户启停与门户角色，不授予任何子系统业务权限。'));
  assert(!source.includes('<p class="muted">外部身份字段只读'));
  assert(css.includes('.user-external-edit-alert{margin-top:14px!important}'));
});


test('子系统映射标题到表格的视觉间距与基本信息一致',()=>{
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(css.includes('.identity-mapping-section-title{margin:0 0 10px'));
  assert(css.includes('.identity-mapping-section-head{display:flex;align-items:center;justify-content:space-between;gap:16px;margin-bottom:5px}'));
});


test('列表文本仅在溢出截断时显示完整内容Tooltip',()=>{
  const component=fs.readFileSync('src/components/portal/TableCellTooltip.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(component.includes(':disabled="!overflow||!content"'));
  assert(component.includes('target.scrollWidth>target.clientWidth+1'));
  assert(component.includes('ResizeObserver'));
  assert(component.includes("import PortalTooltip from './PortalTooltip.vue'"));
  assert(css.includes('.table-cell-tooltip-content{display:block;width:100%;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}'));
  for(const file of [
    'src/views/PortalPage.vue',
    'src/components/portal/UserManagement.vue',
    'src/components/portal/RoleManagement.vue',
    'src/components/portal/OrganizationManagement.vue',
    'src/components/portal/DictionaryManagement.vue',
    'src/components/portal/IdentityMappings.vue',
    'src/components/portal/LogManagement.vue',
    'src/components/portal/MonitorManagement.vue',
    'src/components/portal/TodoCenter.vue',
    'src/components/portal/AnnouncementManagement.vue',
    'src/components/portal/MessageCenter.vue',
    'src/components/portal/MyApplications.vue'
  ]){
    const source=fs.readFileSync(file,'utf8');
    assert(source.includes('TableCellTooltip'),file+' 未接入列表溢出Tooltip');
  }
});


test('管理端应用列表使用全量目录且适用用户按包含关系筛选',()=>{
  const source=fs.readFileSync('src/views/PortalPage.vue','utf8');
  assert(source.includes("else if(key==='apps'&&isAdmin){tasks.rows=tasks.apps;}"));
  assert(source.includes("if(filter.key==='userType'&&['apps','mine'].includes(listResource.value))"));
  assert(source.includes("if(selected==='CITIZEN')return ['CITIZEN','BOTH'].includes(actual)"));
  assert(source.includes("if(selected==='GOV')return ['GOV','BOTH'].includes(actual)"));
  assert(source.includes("apps:{name:'应用名称',code:'应用编码',userType:'适用用户',status:'启用状态'}"));
});

test('组织详情来源提示显示在详情网格上方并与用户详情同间距',()=>{
  const source=fs.readFileSync('src/components/portal/OrganizationManagement.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  const dialog=source.split('header="组织详情"')[1]?.split('</t-dialog>')[0]||'';
  assert(dialog.indexOf('organization-detail-source-alert')>=0);
  assert(dialog.indexOf('organization-detail-source-alert')<dialog.indexOf('<DetailGrid v-if="detail" :items="detailItems"/>'));
  assert(css.includes('.user-detail-source-alert,.organization-detail-source-alert{margin:0 0 14px!important}'));
  assert(css.includes('.user-detail-source-alert + .portal-detail-grid,.organization-detail-source-alert + .portal-detail-grid{margin-top:0}'));
});


test('字典管理左右头部对齐且类型信息单行展示',()=>{
  const source=fs.readFileSync('src/components/portal/DictionaryManagement.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(source.includes('class="dictionary-type-summary"'));
  assert(source.includes('class="dictionary-type-edit-button"'));
  assert(source.includes('variant="outline" theme="primary"'));
  assert(source.includes('{{selectedType?.description||\'请选择左侧字典类型\'}}'));
  assert(source.includes("selectedType.status==='ENABLED'?'success':'default'"));
  assert(css.includes('.dictionary-types-panel>.section-head,.dictionary-items-head{min-height:32px;margin-bottom:12px}'));
  assert(css.includes('.dictionary-type-summary{display:flex;min-width:0;align-items:center;gap:10px;flex-wrap:wrap}'));
  assert(css.includes('.dictionary-lock-alert{margin:0 0 14px!important}'));
  assert(css.includes('.dictionary-query{margin-top:0;margin-bottom:16px}'));
});


test('管理端指定菜单使用互不重复的业务图标',()=>{
  const source=fs.readFileSync('src/App.vue','utf8');
  const expected={
    dictionaries:'BookIcon',
    accountOpeningRequests:'UserAddIcon',
    "logs:login":'UserPasswordIcon',
    "logs:access":'ActivityIcon',
    "logs:api":'CodeIcon',
    "logs:error":'BugReportIcon'
  };
  for(const [resource,icon] of Object.entries(expected)){
    const token=resource.includes(':')?`'${resource}':${icon}`:`${resource}:${icon}`;
    assert(source.includes(token),resource+' 图标未按要求配置');
  }
  assert.equal(new Set(Object.values(expected)).size,Object.values(expected).length,'指定菜单图标不应重复');
  for(const icon of Object.values(expected))assert(source.includes(icon),icon+' 未导入');
});


test('应用中心与我的申请覆盖主要结果状态和下一步操作',()=>{
  const cards=fs.readFileSync('src/components/portal/AppCards.vue','utf8');
  const mine=fs.readFileSync('src/components/portal/MyApplications.vue','utf8');
  const page=fs.readFileSync('src/views/PortalPage.vue','utf8');
  const service=fs.readFileSync('src/services/portal.js','utf8');
  const detail=fs.readFileSync('src/components/portal/RecordDetail.vue','utf8');
  const seed=fs.readFileSync('src/mock/seed.js','utf8');

  assert(cards.includes("if(app.accessState==='REQUEST_REJECTED')return '查看原因'"));
  assert(cards.includes("RETRY_BIND:'重新处理'"));
  assert(cards.includes("VIEW_REASON:'查看原因'"));
  assert(service.includes("FAILED:'RETRY_BIND'"));
  assert(service.includes("REQUEST_REJECTED:'VIEW_REQUEST'"));
  assert(service.includes("if(accessState==='FAILED'&&mapping?.externalAccountStatus==='DISABLED')primaryAction='VIEW_REASON'"));

  assert(mine.includes("row.status==='APPROVED'&&row.postGrantMode==='DIRECT'"));
  assert(mine.includes("@click=\"emit('enter',row)\">进入应用"));
  assert(mine.includes("@click=\"emit('detail',row)\">查看"));
  assert(mine.includes("@click=\"emit('reapply',row)\">重新申请"));
  assert(mine.includes("@click=\"emit('withdraw',row)\">撤回"));
  assert(mine.includes("@click=\"emit('bind',row)\">完成账号确认"));
  assert(mine.includes("defineEmits(['withdraw','reapply','bind','enter','detail'])"));

  assert(page.includes('@enter="enterAppByRequest"'));
  assert(page.includes('@detail="showDetail($event,\'myApplicationRequests\')"'));
  assert(page.includes('function enterAppByRequest(row){'));
  assert(detail.includes("props.kind==='myApplicationRequests'?'申请详情'"));

  for(const status of ['PENDING','APPROVED','REJECTED','WITHDRAWN','EXPIRED']){
    assert(seed.includes("status:'"+status+"'"),'Mock申请缺少 '+status);
  }
  assert(seed.includes("MOCK_GRANT_CITIZEN_APP13"));
  assert(seed.includes("MOCK_GRANT_GOV_APP17"));
});

test('申请列表状态筛选按访问申请和账号开通申请分别提供',()=>{
  const page=fs.readFileSync('src/views/PortalPage.vue','utf8');
  assert(page.includes("if(key==='applicationRequests')"));
  assert(page.includes("fixedOptions(['PENDING','APPROVED','REJECTED','WITHDRAWN','EXPIRED'])"));
  assert(page.includes("if(key==='accountOpeningRequests')"));
  assert(page.includes("fixedOptions(['PENDING','PROCESSING','COMPLETED'])"));
  assert(page.includes("if(key==='myApplicationRequests')"));
});


test('字典管理左右卡片顶部严格对齐',()=>{
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(css.includes('.panel+.panel{margin-top:16px}'));
  assert(css.includes('.dictionary-layout>.panel{margin-top:0}'));
});


test('待办任务列表缩小标题列并加宽来源应用列',()=>{
  const source=fs.readFileSync('src/components/portal/TodoCenter.vue','utf8');
  assert(source.includes("{colKey:'title',title:'待办标题',width:200,ellipsis:true}"));
  assert(source.includes("{colKey:'appName',title:'来源应用',width:320,ellipsis:true}"));
  assert(source.includes('<TableCellTooltip :text="text(row.title)||\'-\'">'));
});


test('消息详情去掉关联信息并把读取状态放到发送方同一元信息区域',()=>{
  const source=fs.readFileSync('src/components/portal/RecordDetail.vue','utf8');
  const block=source.split('v-else-if="kind===\'messages\'"')[1]?.split('</article>')[0]||'';
  assert(block.includes('<span>发送方</span>'));
  assert(block.includes('<span>读取状态</span>'));
  assert(block.indexOf('<span>发送方</span>')<block.indexOf('<span>读取状态</span>'));
  assert(block.includes("record.status==='UNREAD'?'未读':'已读'"));
  assert(!block.includes('关联信息'));
  assert(!block.includes('portal-message-business'));
  assert(!block.includes('portal-message-grid'));
});


test('其他应用卡片将应用类型与状态操作分行显示且初始账号处理入口为申请使用',()=>{
  const source=fs.readFileSync('src/components/portal/AppCards.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  const metaIndex=source.indexOf('class="portal-app-meta"');
  const resultIndex=source.indexOf('class="portal-app-result"');
  assert(metaIndex>=0&&resultIndex>metaIndex);
  const metaBlock=source.slice(metaIndex,resultIndex);
  assert(metaBlock.includes('portal-app-category'));
  assert(!metaBlock.includes('portal-app-status-tag'));
  assert(source.includes("BIND:'申请使用'"));
  assert(source.includes("VIEW_CONFLICT:'查看原因'"));
  assert(source.includes("RETRY_BIND:'重新处理'"));
  assert(css.includes('.portal-app-result{display:flex;min-width:0;height:24px;align-items:center;gap:8px;margin-top:2px;white-space:nowrap}'));
  assert(css.includes('.portal-app-category{min-width:0;max-width:100%'));
});


test('公共详情网格自动补齐孤立半行且保持字段顺序',()=>{
  const source=fs.readFileSync('src/components/portal/DetailGrid.vue','utf8');
  assert(source.includes('v-for="item in normalizedItems"'));
  assert(source.includes("'is-wide':item.resolvedWide"));
  assert(source.includes('if(item.wide){'));
  assert(source.includes('const resolvedWide=!next||Boolean(next.wide);'));
  assert(source.includes('column=resolvedWide?0:1;'));
});

test('公共文本清洗不保留演示前缀产生的孤立冒号',()=>{
  const source=fs.readFileSync('src/components/portal/presentation.js','utf8');
  assert(source.includes("replace(/(?:模拟|演示|示例)\\s*[：:]\\s*/g,'')"));
});


test('应用中心我的应用和其他应用固定每页20条',()=>{
  const source=fs.readFileSync('src/views/PortalPage.vue','utf8');
  assert(source.includes('const appPageSize=ref(20),appPages=reactive({mine:1,other:1});'));
  const center=source.split('<template v-if="isAppCenter">')[1]?.split('</template>')[0]||'';
  assert(center.includes(':page-size="appPageSize"'));
  assert(center.includes('@current-change="setAppPage(group.key,$event)"'));
  assert(!center.includes(':page-size-options'));
  assert(!center.includes('@page-size-change'));
});


test('其他应用状态标签文字统一为12px',()=>{
  const source=fs.readFileSync('src/components/portal/AppCards.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(source.includes('class="portal-app-status-tag"'));
  assert(css.includes('.portal-page .portal-app-result .portal-app-status-tag,.portal-page .portal-app-result .portal-app-status-tag .t-tag__text{font-size:12px!important;line-height:20px!important}'));
});


test('应用中心分组统计仅数字增加字重',()=>{
  const source=fs.readFileSync('src/views/PortalPage.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(source.includes('<span class="portal-section-count">（<span class="portal-section-count-number">{{group.total}}</span>）</span>'));
  assert(css.includes('.portal-section-count{font-size:13px!important;font-weight:500!important;color:#1d2129!important}'));
  assert(css.includes('.portal-section-count-number{font-weight:600!important}'));
});
