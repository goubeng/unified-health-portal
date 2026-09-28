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

test('登录页保留三身份与模拟认证元素且身份页签样式固定',()=>{
  const source=fs.readFileSync('src/views/Login.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  for(const marker of ['扫码登录','手机号登录','<t-qrcode','login-phone','login-slider','login-code','local-account','local-password','local-captcha'])assert(source.includes(marker),marker+' 应保留');
  assert(source.includes("localAccount=ref('admin')"));
  assert(!source.includes("method.value==='phone'&&!verified.value"));
  assert(css.includes('.login-identity-switch{justify-content:space-around;align-items:flex-end;gap:32px;padding:0 22px;margin-top:10px!important}'));
  assert(css.includes('.identity-pill{font-size:18px!important;font-weight:500!important'));
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
  for(const label of ['纳管应用','启用应用','门户访问用户','接入异常','待处理事项','接入运行状态','常用管理'])assert(source.includes(label),label+' 未体现');
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
  assert(source.includes("if(value==='create'&&!formVisible.value)openCreate();"));
  assert(source.includes('{immediate:true}'));
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
  assert(announcement.includes('#title')&&announcement.includes(`@click="$emit('detail',row)"`));
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
  assert(logs.includes('<template #requestId="{row}">'));
  assert(logs.includes('class="portal-field-link" @click="openDetail(row)"'));
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
  const formDialog=source.split(':mode="createFullscreen?\'full-screen\':\'modal\'"')[1]?.split('</t-dialog>')[0]||'';
  assert(formDialog.includes('<span>新增公告</span>'));
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
  const formDialog=source.split(':mode="createFullscreen?\'full-screen\':\'modal\'"')[1]?.split('</t-dialog>')[0]||'';
  assert(formDialog.includes('<span>新增公告</span>'));
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
  assert(app.includes("router.push(admin.value?'/admin/announcements':portalPath('/announcements'))"));
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
  assert(editor.includes('<span>编辑公告</span>'));
  assert(editor.includes(":mode=\"isFullscreen?'full-screen':'modal'\""));
  assert(!editor.includes('to="#page-header-actions"'));
});

test('新增公告仅定时发布时显示定时发布时间且失效日期按当天235959处理',()=>{
  const source=fs.readFileSync('src/components/portal/AnnouncementManagement.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  const createDialog=source.split(':mode="createFullscreen?\'full-screen\':\'modal\'"')[1]?.split('</t-dialog>')[0]||'';
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
  assert(source.includes("const currentDisplayStatus=computed(()=>form.displayStatus||form.status||'DRAFT')"));
  assert(source.includes("const isDraft=computed(()=>currentDisplayStatus.value==='DRAFT')"));
  assert(source.includes("const isScheduled=computed(()=>currentDisplayStatus.value==='SCHEDULED')"));
  assert(source.includes("const isWithdrawn=computed(()=>currentDisplayStatus.value==='WITHDRAWN')"));
  assert(source.includes('const isPublishEditable=computed(()=>isDraft.value||isScheduled.value||isWithdrawn.value)'));
  assert(source.includes('v-if="isPublishEditable"'));
  assert(source.includes('<template v-if="isPublishEditable">'));
  assert(source.includes('v-model="form.publishMode"'));
  assert(source.includes("v-if=\"form.publishMode==='SCHEDULED'\""));
  assert(source.includes("else if(!form.publishMode)form.publishMode=currentDisplayStatus.value==='SCHEDULED'?'SCHEDULED':'IMMEDIATE'"));
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
  assert(list.includes("['DRAFT','SCHEDULED','PUBLISHED','WITHDRAWN'].includes(displayStatus(row))"));
  assert(list.includes("['DRAFT','WITHDRAWN','EXPIRED'].includes(displayStatus(row))"));
  assert(page.includes("['DRAFT','SCHEDULED','PUBLISHED','WITHDRAWN'].includes(announcementViewStatus(detail))"));
  assert(page.includes("['DRAFT','WITHDRAWN','EXPIRED'].includes(announcementViewStatus(detail))"));
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
  assert(functionList.includes('页面字段、完整状态、业务流程及验收要求仍以《卫健统一门户系统需求规格说明书》为准'));
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
  assert(source.includes("title:'启用状态'"));
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

test('门户管理用户按认证类型区分标签且不把LOCAL作为普通用户类别',()=>{
  const source=fs.readFileSync('src/components/portal/UserManagement.vue','utf8');
  assert(source.includes("adminAuthType(row)==='LOCAL'?'warning':'primary'"));
  assert(source.includes("const authTypeOptions=[{value:'EXTERNAL',label:'外部身份'},{value:'LOCAL',label:'本地账号'}]"));
  assert(source.includes('授权外部用户'));
  assert(source.includes('新增本地管理账号'));
  assert(!source.includes("const userTypeOptions=['CITIZEN','GOV','LOCAL']"));
});

test('系统提示框统一13px紧凑高度并覆盖用户详情来源提示',()=>{
  const user=fs.readFileSync('src/components/portal/UserManagement.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(user.includes('class="user-source-alert user-detail-source-alert"'));
  assert(user.includes('门户仅维护管理端授权，不修改上游权威身份主数据'));
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

test('角色编码打开只读查看弹窗且门户权限支持折叠展示',()=>{
  const source=fs.readFileSync('src/components/portal/RoleManagement.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(source.includes('@click="openDetail(row)"'));
  assert(source.includes('header="角色查看"'));
  assert(source.includes("import DetailGrid from './DetailGrid.vue';"));
  assert(source.includes('<DetailGrid :items="detailItems" class="role-detail-grid">'));
  assert(source.includes('<template #status>'));
  assert(!source.includes('role-detail-descriptions'));
  assert(source.includes('class="role-detail-permission-tree"'));
  assert(source.includes('<details v-for="group in detailPermissionGroups"'));
  assert(source.includes('<summary>'));
  assert(source.includes('<ChevronRightIcon/>'));
  assert(source.includes('仅展示当前角色已拥有的门户权限'));
  assert(source.includes('@click="openEdit(row)">权限配置</t-button>'));
  assert(css.includes('.role-detail-permission-group[open]>summary .role-detail-tree-toggle .t-icon{transform:rotate(90deg)'));
});

test('组织管理列表不显示组织路径但详情继续保留',()=>{
  const source=fs.readFileSync('src/components/portal/OrganizationManagement.vue','utf8');
  const columns=source.split('const columns=[')[1]?.split('];')[0]||'';
  const detailItems=source.split('const detailItems=computed')[1]?.split('function reset')[0]||'';
  assert(!columns.includes("colKey:'path'"));
  assert(detailItems.includes("['path','组织路径',row.path]"));
  assert(source.includes('[row.name,row.code,row.path]'));
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

test('用户端首页我的应用展示可访问数量、最多10个并在超量时显示更多',()=>{
  const page=fs.readFileSync('src/views/PortalPage.vue','utf8');
  assert(page.includes('const homeAppLimit=10;'));
  assert(page.includes('const homeAppCount=computed(()=>homeApps.value.length);'));
  assert(page.includes('const homeVisibleApps=computed(()=>homeApps.value.slice(0,homeAppLimit));'));
  assert(page.includes('{{homeAppCount}}'));
  assert(page.includes('v-if="homeAppCount>homeAppLimit"'));
  assert(page.includes('to="/portal/apps/all">更多</router-link>'));
  assert(page.includes(':apps="homeVisibleApps"'));
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
  const alertPos=source.indexOf('class="user-source-alert user-detail-source-alert"');
  const gridPos=source.indexOf('<DetailGrid v-if="detail" :items="detailItems"/>');
  assert(alertPos>=0);
  assert(gridPos>=0);
  assert(alertPos<gridPos);
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(css.includes('.user-detail-source-alert,.organization-detail-source-alert{margin:0 0 14px!important}'));
  assert(css.includes('.user-detail-source-alert + .portal-detail-grid,.organization-detail-source-alert + .portal-detail-grid{margin-top:0}'));
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
  assert(source.includes('外部身份字段只读；此处仅维护管理端启停和门户角色，不影响该人员的用户端访问，也不授予任何子系统业务权限。'));
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


test('管理端应用列表使用全量目录且启用状态与适用用户按实际字段精确筛选',()=>{
  const source=fs.readFileSync('src/views/PortalPage.vue','utf8');
  assert(source.includes("else if(key==='apps'&&isAdmin){tasks.rows=tasks.apps;}"));
  assert(source.includes("filterDef('enabled','启用状态','请选择启用状态',fixedOptions(['ENABLED','DISABLED']),'status')"));
  assert(source.includes("if(filter.key==='enabled')return (row.enabled===false?'DISABLED':'ENABLED')===String(selected)"));
  assert(!source.includes("if(filter.key==='userType'&&['apps','mine'].includes(listResource.value))"));
  assert(source.includes("const actual=String(row[filter.key]??'');return actual===String(selected);"));
  assert(source.includes("fieldMap={apps:['name','code','category','userType','accessMode','aggregateRuntimeStatus','enabled']"));
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
  assert(mine.includes("@click=\"emit('detail',row)\""));
  assert(!mine.includes("@click=\"emit('detail',row)\">查看"));
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


test('应用中心我的应用和其他应用默认每页20条并支持10/20/50切换',()=>{
  const source=fs.readFileSync('src/views/PortalPage.vue','utf8');
  assert(source.includes('const appPageSizes=reactive({mine:20,other:20}),appPages=reactive({mine:1,other:1});'));
  const center=source.split('<template v-if="isAppCenter">')[1]?.split('</template>')[0]||'';
  assert(center.includes(':page-size="group.pageSize"'));
  assert(center.includes(':page-size-options="[10,20,50]"'));
  assert(center.includes('@current-change="setAppPage(group.key,$event)"'));
  assert(center.includes('@page-size-change="setAppPageSize(group.key,$event)"'));
  assert(source.includes('const size=appPageSizes[key];'));
  assert(source.includes('entries.slice((current-1)*size,current*size)'));
  assert(source.includes('function setAppPageSize(key,value){appPageSizes[key]=Number(value)||20;appPages[key]=1;}'));
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


test('登录框内容左右增加10px留白且登录按钮加高',()=>{
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(css.includes('.login-card{background:#fff!important;border:0!important;border-radius:0!important;box-shadow:none!important;padding:28px 42px!important}'));
  assert(css.includes('.login-submit{height:40px!important;min-height:40px!important}'));
});


test('登录二维码与手机号模拟控件保持显示',()=>{
  const source=fs.readFileSync('src/views/Login.vue','utf8');
  assert(source.includes('<t-qrcode'));
  assert(source.includes('qr-auth'));
  assert(source.includes('phone-auth'));
  assert(source.includes('手机号'));
  assert(source.includes('验证码'));
});


test('登录页使用独立图片层渲染卫健高清背景',()=>{
  const source=fs.readFileSync('src/views/Login.vue','utf8');
  const layout=fs.readFileSync('src/styles/layout.css','utf8');
  assert(fs.existsSync('src/assets/login-health-bg-3840x2160.png'));
  assert(source.includes("import loginBackground from '../assets/login-health-bg-3840x2160.png';"));
  assert(source.includes('class="login-bg-image"'));
  assert(source.includes(':src="loginBackground"'));
  assert(layout.includes('.login-bg-image{position:absolute;inset:0;z-index:0;width:100%;height:100%;object-fit:cover;object-position:center center'));
});


test('登录页身份切换与模拟登录内容区间距一致且登录框高度自适应',()=>{
  const source=fs.readFileSync('src/views/Login.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(source.includes('class="local-auth phone-auth"'));
  assert(css.includes('.login-card{width:460px!important;max-width:460px!important;height:auto!important;min-height:0!important;display:block!important}'));
  assert(css.includes('.login-identity-switch{margin-bottom:32px!important}'));
  assert(css.includes('.qr-auth{padding-top:32px!important}'));
  assert(css.includes('.phone-auth:not(.local-auth){margin-top:32px!important}'));
  assert(css.includes('.local-auth{display:block!important;margin-top:32px!important}'));
});

test('管理端演示账号固定为admin且输入内容不参与校验',()=>{
  const source=fs.readFileSync('src/views/Login.vue','utf8');
  const seed=fs.readFileSync('src/mock/seed.js','utf8');
  assert(source.includes("localAccount=ref('admin')"));
  assert(seed.includes("account:'admin'"));
  for(const field of ['local-account','local-password','local-captcha'])assert(source.includes(field));
  const adminFn=source.split('async function enterLocalAdmin(){')[1].split('\n}')[0];
  assert(!/localAccount|localPassword|localCaptchaInput|localCaptchaCode/.test(adminFn));
});


test('登录页保留身份Tab和登录方式切换',()=>{
  const source=fs.readFileSync('src/views/Login.vue','utf8');
  assert(source.includes('class="login-identity-switch"'));
  assert(source.includes('auth-method-pills'));
  assert(source.includes('method-pill'));
});


test('登录页登录按钮使用统一高度',()=>{
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(css.includes('.login-submit{height:40px!important;min-height:40px!important}'));
});


test('登录背景按短边铺满并居中裁切',()=>{
  const layout=fs.readFileSync('src/styles/layout.css','utf8');
  assert(layout.includes('object-fit:cover'));
  assert(layout.includes('object-position:center center'));
});

test('过期二维码点击后仍可直接完成模拟登录',()=>{
  const source=fs.readFileSync('src/views/Login.vue','utf8');
  assert(source.includes("if(qrStage.value==='expired')refreshQr();qrStage.value='success'"));
  assert(source.includes('qrSuccessTimer=setTimeout(()=>enter(),420)'));
});


test('应用列表所有应用均显示删除操作',()=>{
  const source=fs.readFileSync('src/views/PortalPage.vue','utf8');
  assert(source.includes("confirm('removeApp',row"));
  assert(!source.includes('v-if="!row.sourceNo"'));
  assert(source.includes('确认删除该应用？'));
});


test('子系统映射统计项使用统一背景框',()=>{
  const source=fs.readFileSync('src/components/portal/IdentityMappings.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(source.includes('class="identity-mappings-summary"'));
  assert(source.includes('已关联 <strong>{{selected.boundCount??0}}</strong> 个'));
  assert(source.includes('异常 <strong>{{selected.exceptionCount??0}}</strong> 个'));
  assert(css.includes('.identity-mappings-summary{box-sizing:border-box;display:inline-flex;min-height:28px;align-items:center;gap:6px;padding:3px 10px;border:1px solid #e5e8ef;border-radius:3px;background:#f6f8fb'));
  assert(css.includes('.identity-mapping-summary-item+.identity-mapping-summary-item{margin-left:0;padding-left:0;border-left:0}'));
});


test('应用列表操作列加宽且三个操作不换行',()=>{
  const source=fs.readFileSync('src/views/PortalPage.vue','utf8');
  const css=fs.readFileSync('src/styles/core.css','utf8');
  assert(source.includes("width:resource.value==='apps'&&admin.value?240:200"));
  assert(source.includes("'app-list-row-actions':resource==='apps'&&admin"));
  assert(css.includes('.portal-table-panel .app-list-row-actions{flex-wrap:nowrap!important;white-space:nowrap!important;gap:8px!important}'));
  assert(css.includes('.portal-table-panel .app-list-row-actions .t-button{flex:none!important;white-space:nowrap!important}'));
});


test('正式公众门户使用新版独立布局且管理端保持原布局',()=>{
  const router=fs.readFileSync('src/router.js','utf8');
  const app=fs.readFileSync('src/App.vue','utf8');
  assert(router.includes("{path:'/portal/home',name:'PG-101',component:PortalHomePreview,meta:portalMeta('home')}"));
  assert(router.includes("{path:'/portal',component:PortalPreviewLayout,meta:{group:'个人事务',layout:'public-portal'}"));
  assert(router.includes("{path:'todos',name:'PG-104',component:PortalPage,meta:portalMeta('todos')}"));
  assert(router.includes("{path:'messages',name:'PG-105',component:PortalPage,meta:portalMeta('messages')}"));
  assert(router.includes("{path:'announcements',name:'PG-106',component:PortalPage,meta:portalMeta('announcements')}"));
  assert(router.includes("{path:'apps/all',name:'PG-103',component:PortalPage,meta:portalMeta('apps')}"));
  assert(router.includes("{path:'applications',name:'PG-109',component:PortalPage,meta:portalMeta('myApplicationRequests')}"));
  assert(app.includes("['portal-preview','public-portal'].includes(route.meta.layout)"));
  assert(app.includes("const admin=computed(()=>route.path.startsWith('/admin'))"));
});

test('正式公众门户头部导航不会跳回预览地址',()=>{
  const layout=fs.readFileSync('src/views/PortalPreviewLayout.vue','utf8');
  assert(layout.includes('@click="go(\'/home\')"'));
  assert(layout.includes('@click="go(\'/messages\')"'));
  assert(layout.includes("const portalBase=computed(()=>isPreviewRoute.value?'/portal-preview':'/portal')"));
  assert(!layout.includes('@click="router.push(\'/portal-preview/home\')"'));
  assert(!layout.includes('@click="router.push(\'/portal-preview/messages\')"'));
});

test('正式公众门户内页启用轻量列表且我的申请使用表格展示',()=>{
  const page=fs.readFileSync('src/views/PortalPage.vue','utf8');
  const todo=fs.readFileSync('src/components/portal/TodoCenter.vue','utf8');
  const message=fs.readFileSync('src/components/portal/MessageCenter.vue','utf8');
  const applications=fs.readFileSync('src/components/portal/MyApplications.vue','utf8');
  assert(page.includes("const preview=computed(()=>previewRoute.value||route.path.startsWith('/portal/'))"));
  assert(page.includes("v-else-if=\"preview&&resource==='announcements'\""));
  assert(todo.includes("route.path.startsWith('/portal-preview')||route.path.startsWith('/portal/')"));
  assert(message.includes("route.path.startsWith('/portal-preview')||route.path.startsWith('/portal/')"));
  assert(todo.includes('class="public-record-list public-todo-list"'));
  assert(message.includes('class="message-content-toolbar"'));
  assert(message.includes('<t-table row-key="id" :data="pagedMessages" :columns="columns"'));
  assert(applications.includes('class="my-applications-table"'));
  assert(!applications.includes('class="public-application-list"'));
});


test('公众二级页按需加载且头部未读数使用轻量接口',()=>{
  const page=fs.readFileSync('src/views/PortalPage.vue','utf8');
  const layout=fs.readFileSync('src/views/PortalPreviewLayout.vue','utf8');
  const service=fs.readFileSync('src/services/portal.js','utf8');
  assert(page.includes("const needsAppCatalog=isAdmin?shouldLoadAppCatalog(true,actor.value):(center||key==='myApplicationRequests');"));
  assert(page.includes("watch(()=>preview.value?route.path:route.fullPath"));
  assert(layout.includes("<router-view :key=\"route.path+'|'+actor?.id\" />"));
  assert(layout.includes("portal.read('header')"));
  assert(service.includes("if(resource==='header')return {unreadCount:"));
  assert(service.includes("const allApps=()=>decorate(d,a),userApps=()=>accountApps(d,a);"));
});


test('通知公告使用标签元信息和单行Banner',()=>{
  const page=fs.readFileSync('src/views/PortalPage.vue','utf8');
  const layout=fs.readFileSync('src/views/PortalPreviewLayout.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  assert(page.includes("'portal-announcement-center':preview&&resource==='announcements'"));
  assert(page.includes('class="public-announcement-meta-tag"'));
  assert(page.includes('class="public-announcement-meta-tag scope"'));
  assert(layout.includes("import announcementBanner from '../assets/banner-announcements.png';"));
  assert(layout.includes('v-if="bannerInfo" class="public-announcement-banner public-portal-section-banner"'));
  assert(css.includes('.portal-announcement-center>.portal-query{'));
  assert(css.includes('.public-announcement-item .public-record-main strong{'));
  assert(css.includes('font-size:16px;'));
});


test('应用中心卡片使用浅色背景并给应用类型增加标签色',()=>{
  const cards=fs.readFileSync('src/components/portal/AppCards.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  assert(cards.includes(':class="categoryTone(app.category)"'));
  assert(cards.includes("return 'category-tone-'+(hash+1);"));
  assert(css.includes('.portal-app-center .portal-app-card{'));
  assert(css.includes('background:#f8fafc!important;'));
  assert(css.includes('.portal-app-category.category-tone-1'));
  assert(css.includes('.portal-app-category.category-tone-5'));
});

test('通知公告标题显示在Banner内且列表页隐藏外部标题',()=>{
  const layout=fs.readFileSync('src/views/PortalPreviewLayout.vue','utf8');
  assert(layout.includes('<strong>{{ bannerInfo.title }}</strong>'));
  assert(layout.includes("title:'通知公告'"));
  assert(layout.includes('及时了解平台通知与重要信息'));
  assert(layout.includes("const isAnnouncementListPage=computed(()=>route.meta.resource==='announcements')"));
  assert(layout.includes('v-if="showSubpageHead" class="public-portal-subpage-head"'));
});


test('应用中心标题显示在Banner内且去掉独立页标题图标',()=>{
  const layout=fs.readFileSync('src/views/PortalPreviewLayout.vue','utf8');
  assert(layout.includes('v-if="bannerInfo" class="public-announcement-banner public-portal-section-banner"'));
  assert(layout.includes('<strong>{{ bannerInfo.title }}</strong>'));
  assert(layout.includes("title:'应用中心'"));
  assert(layout.includes('汇聚卫生健康服务应用 · 便捷访问常用业务系统'));
  assert(!layout.includes('public-portal-app-banner-icon'));
  assert(!layout.includes('AppIcon'));
});


test('消息中心列表页使用Banner且详情页保留外部标题',()=>{
  const layout=fs.readFileSync('src/views/PortalPreviewLayout.vue','utf8');
  assert(layout.includes("const isMessageListPage=computed(()=>route.meta.resource==='messages'&&!route.query.messageId)"));
  assert(layout.includes('v-if="bannerInfo" class="public-announcement-banner public-portal-section-banner"'));
  assert(layout.includes('<strong>{{ bannerInfo.title }}</strong>'));
  assert(layout.includes("title:'消息中心'"));
  assert(layout.includes('集中查看业务消息与系统通知'));
  assert(layout.includes("const showSubpageHead=computed(()=>!bannerInfo.value);"));
});


test('公众端全部二级列表页统一Banner和查询布局',()=>{
  const layout=fs.readFileSync('src/views/PortalPreviewLayout.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  for(const title of ['待办任务','消息中心','通知公告','应用中心','我的申请','个人中心']){
    assert(layout.includes("title:'"+title+"'"),title+' 未接入统一Banner');
  }
  assert(layout.includes('v-if="bannerInfo" class="public-announcement-banner public-portal-section-banner"'));
  assert(layout.includes('id="page-header-extra" class="page-header-extra-host"'));
  assert(layout.includes('id="page-header-actions" class="page-header-actions-host public-portal-banner-actions"'));
  assert(css.includes('.public-portal-secondary-shell .portal-query.list-toolbar{'));
  assert(css.includes('background:transparent!important;'));
  assert(css.includes('.portal-query.list-toolbar .query-reset-button{'));
  assert(css.includes('min-width:64px!important;'));
});

test('公众端二级Banner等比铺满居中且窄屏内容可撑高',()=>{
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  const banner=css.match(/\.public-announcement-banner\s*\{([^}]*)\}/)?.[1];
  const section=css.match(/\.public-portal-section-banner\s*\{([^}]*)\}/)?.[1];
  const inner=css.match(/\.public-portal-banner-inner\s*\{([^}]*)\}/)?.[1];
  assert(banner,'缺少公众端二级Banner样式');
  assert(section,'缺少公众端二级Banner适配样式');
  assert(inner,'缺少公众端二级Banner内容布局');
  assert.match(banner,/background-size\s*:\s*cover\s*;/);
  assert.match(section,/aspect-ratio\s*:\s*10\s*\/\s*1\s*;/);
  assert.match(section,/background-position\s*:\s*center center\s*;/);
  assert.match(banner,/min-height\s*:\s*132px\s*;/);
  assert.match(inner,/min-height\s*:\s*132px\s*;/);
  assert.doesNotMatch(inner,/(?:^|;)\s*(?:height|max-height)\s*:/);
  assert.match(css,/@media\s*\(max-width\s*:\s*760px\)\s*\{[\s\S]*?\.public-announcement-banner\s*\{\s*min-height\s*:\s*110px\s*\}/);
  assert.match(css,/\.public-portal-banner-inner\s*\{\s*min-height\s*:\s*110px\s*;[\s\S]*?padding\s*:\s*16px 20px\s*;/);
  assert.match(css,/\.public-portal-section-banner \.public-announcement-banner-copy\s*\{\s*height\s*:\s*auto\s*;/);
});


test('我的申请增加顶部留白与独立分页',()=>{
  const source=fs.readFileSync('src/components/portal/MyApplications.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  assert(source.includes('const accessPage=ref(1),accessPageSize=ref(10);'));
  assert(source.includes('const openingPage=ref(1),openingPageSize=ref(10);'));
  assert(source.includes(':data="pagedAccessRows"'));
  assert(source.includes(':data="pagedOpeningRows"'));
  assert.equal((source.match(/<t-pagination/g)||[]).length,2);
  assert(css.includes('.public-portal-secondary-shell .my-applications{'));
  assert(css.includes('padding:16px 20px 18px!important;'));
  assert(css.includes('.public-portal-secondary-shell .my-applications .t-pagination{'));
});


test('消息中心使用标准表格并把批量操作放在内容区',()=>{
  const source=fs.readFileSync('src/components/portal/MessageCenter.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  assert(!source.includes('to="#page-header-actions"'));
  assert(source.includes('class="message-content-toolbar"'));
  assert(source.includes('class="message-content-actions"'));
  assert(source.includes('删除</t-button>'));
  assert(source.includes('标记为已读</t-button>'));
  assert(source.includes('全部标为已读</t-button>'));
  assert(source.includes('<t-table row-key="id" :data="pagedMessages" :columns="columns"'));
  assert(!source.includes('class="public-message-list"'));
  assert(css.includes('.public-portal-secondary-shell .message-content-toolbar{'));
});


test('消息中心列表与操作使用统一白色内容容器',()=>{
  const source=fs.readFileSync('src/components/portal/MessageCenter.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  assert(source.includes('class="panel message-content-shell"'));
  assert(source.includes('class="message-content-toolbar"'));
  assert(source.includes('class="message-list-panel"'));
  assert(!source.includes('class="panel portal-table-panel message-list-panel"'));
  assert(css.includes('.public-portal-secondary-shell .message-content-shell{'));
  assert(css.includes('background:#fff!important;'));
  assert(css.includes('padding:16px 20px 18px!important;'));
});


test('首页我的应用保留深色图标并对齐应用中心卡片标签',()=>{
  const source=fs.readFileSync('src/views/PortalHomePreview.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-home-preview.css','utf8');
  assert(source.includes('class="public-portal-app-category" :class="categoryTone(app.category)"'));
  assert(source.includes("return 'category-tone-'+(hash+1);"));
  assert(css.includes('.public-portal-home .public-portal-app-item{'));
  assert(css.includes('background:#f8fafc;'));
  assert(css.includes('border-radius:0;'));
  assert(css.includes('.public-portal-app-icon.tone-0{background:linear-gradient'));
  assert(css.includes('.public-portal-app-category.category-tone-1'));
  assert(css.includes('.public-portal-app-category.category-tone-5'));
});


test('服务端只读请求绕过写事务串行队列',()=>{
  const source=fs.readFileSync('server/api.mjs','utf8');
  assert(source.includes('let queue=Promise.resolve(),snapshot=null,snapshotLoad=null;'));
  assert(source.includes('if(snapshotLoad)return snapshotLoad;'));
  assert(source.includes("const readOnly=req.method==='GET'&&['/api/portal/health','/api/portal/session','/api/portal/read'].includes(path);"));
  assert(source.includes('if(readOnly)await processRequest();'));
  assert(source.includes('else await serial(processRequest);'));
  assert(!source.includes('await serial(async()=>{\n    const readOnly='));
});


test('消息中心去掉列表统计并将操作按钮左对齐',()=>{
  const source=fs.readFileSync('src/components/portal/MessageCenter.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  const toolbar=source.split('class="message-content-toolbar"')[1]?.split('</div>\n\n        <section')[0]||'';
  assert(!toolbar.includes('message-content-summary'));
  assert(!toolbar.includes('共 {{ filteredMessages.length }} 条'));
  assert(toolbar.includes('class="message-content-actions"'));
  assert(toolbar.includes('删除</t-button>'));
  assert(toolbar.includes('标记为已读</t-button>'));
  assert(toolbar.includes('全部标为已读</t-button>'));
  assert(css.includes('.message-content-shell .message-content-toolbar{'));
  assert(css.includes('justify-content:flex-start!important;'));
});


test('首页查看全部与二级页返回按钮使用图标组件保持垂直居中',()=>{
  const home=fs.readFileSync('src/views/PortalHomePreview.vue','utf8');
  const layout=fs.readFileSync('src/views/PortalPreviewLayout.vue','utf8');
  const homeCss=fs.readFileSync('src/styles/portal-home-preview.css','utf8');
  const secondaryCss=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  assert(home.includes('查看全部 <ChevronRightIcon size="16px" />'));
  assert(home.includes('ChevronRightIcon'));
  assert(layout.includes('<ArrowLeftIcon size="18px" />'));
  assert(layout.includes('ArrowLeftIcon'));
  assert(homeCss.includes('.public-portal-section-head button .t-icon{'));
  assert(secondaryCss.includes('.public-portal-subpage-back .t-icon{'));
  assert(secondaryCss.includes('align-items:center!important;'));
});


test('消息中心未读筛选空态显示暂无未读的消息',()=>{
  const source=fs.readFileSync('src/components/portal/MessageCenter.vue','utf8');
  assert(source.includes(`:description="statusFilter==='UNREAD'?'暂无未读的消息':'暂无符合条件的消息'"`));
});


test('待办任务类型和状态使用标签并将状态放到标题旁',()=>{
  const source=fs.readFileSync('src/components/portal/TodoCenter.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  assert(source.includes('class="public-todo-title-line"'));
  assert(source.includes('class="public-todo-status-tag"'));
  assert(source.includes('class="public-todo-type-tag"'));
  assert(source.includes("{colKey:'businessType',title:'任务类型'"));
  assert(source.includes('<template #businessType="{row}">'));
  assert(!source.includes('<span class="public-record-status">{{ label(row.status) }}</span>'));
  assert(css.includes('.public-portal-secondary-shell .public-todo-title-line{'));
});


test('首页我的应用样式作用域命中实际首页结构',()=>{
  const css=fs.readFileSync('src/styles/portal-home-preview.css','utf8');
  assert(css.includes('.public-portal-shell .public-portal-apps .public-portal-app-item{'));
  assert(css.includes('.public-portal-shell .public-portal-apps .public-portal-app-category{'));
  assert(!css.includes('.public-portal-home .public-portal-app-item{'));
});


test('应用中心图标背景配色与首页保持一致',()=>{
  const cards=fs.readFileSync('src/components/portal/AppCards.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  const homeCss=fs.readFileSync('src/styles/portal-home-preview.css','utf8');
  assert(cards.includes(`:class="'icon-tone-'+(index%7)"`));
  for(let i=0;i<7;i++)assert(css.includes('.portal-app-logo.icon-tone-'+i));
  assert(css.includes('linear-gradient(145deg,#4bbcff,#1382ee)'));
  assert(css.includes('linear-gradient(145deg,#62df9a,#21bd72)'));
  assert(homeCss.includes('.public-portal-app-icon.tone-0{background:linear-gradient(145deg,#4bbcff,#1382ee)'));
  assert(homeCss.includes('.public-portal-app-icon.tone-1{background:linear-gradient(145deg,#62df9a,#21bd72)'));
});


test('应用中心卡片使用首页同款图标并采用两行布局',()=>{
  const cards=fs.readFileSync('src/components/portal/AppCards.vue','utf8');
  const page=fs.readFileSync('src/views/PortalPage.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  assert(cards.includes('<AppIcon />'));
  assert(cards.includes('actionRow:Boolean'));
  assert(cards.includes("actionRow?'has-action-row':''"));
  assert(cards.includes('v-if="actionRow" class="portal-app-result portal-app-action-row"'));
  assert(page.includes('<AppCards :apps="group.rows" action-row'));
  assert(css.includes('.portal-app-card.has-action-row{'));
  assert(css.includes('grid-template-columns:38px minmax(0,1fr)!important;'));
  assert(css.includes('.portal-app-action-row{'));
});


test('待办任务和消息中心加宽来源应用查询项',()=>{
  const todo=fs.readFileSync('src/components/portal/TodoCenter.vue','utf8');
  const message=fs.readFileSync('src/components/portal/MessageCenter.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  assert(todo.includes('class="portal-query-select query-width-source"'));
  assert(message.includes('class="portal-query-select query-width-source"'));
  assert(css.includes('.todo-center .query-width-source .t-select__wrap'));
  assert(css.includes('.portal-message-center .query-width-source .t-select__wrap'));
  assert(css.includes('width:250px!important;'));
});


test('待办任务最后一行保留下边框',()=>{
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  assert(css.includes('.public-portal-secondary-shell .public-todo-list .public-record-item:last-child{'));
  assert(css.includes('border-bottom:1px solid #edf1f6!important;'));
});


test('公众端二级页按业务主题使用独立PNG Banner',()=>{
  const layout=fs.readFileSync('src/views/PortalPreviewLayout.vue','utf8');
  assert(layout.includes("import todoBanner from '../assets/banner-todos.png';"));
  assert(layout.includes("import messageBanner from '../assets/banner-messages.png';"));
  assert(layout.includes("import announcementBanner from '../assets/banner-announcements.png';"));
  assert(layout.includes("import appsBanner from '../assets/banner-apps.png';"));
  assert(layout.includes(":style=\"{backgroundImage:\`url('\${bannerInfo.image}')\`}\""));
  assert(layout.includes("title:'待办任务',subtitle:'集中处理来自各业务系统的待办事项',image:todoBanner"));
  assert(layout.includes("title:'消息中心',subtitle:'集中查看业务消息与系统通知',image:messageBanner"));
  assert(layout.includes("title:'通知公告',subtitle:'及时了解平台通知与重要信息',image:announcementBanner"));
  assert(layout.includes("title:'应用中心',subtitle:'汇聚卫生健康服务应用 · 便捷访问常用业务系统',image:appsBanner"));
  assert(layout.includes("title:'我的申请',subtitle:'查看应用访问与账号开通申请进度',image:applicationsBanner"));
  assert(layout.includes("title:'个人中心',subtitle:'查看账号信息与个人资料',image:messageBanner"));
  assert(!layout.includes("login-health3-bg-3840x2160.png"));
});


test('我的申请使用独立Banner图片',()=>{
  const layout=fs.readFileSync('src/views/PortalPreviewLayout.vue','utf8');
  assert(layout.includes("import applicationsBanner from '../assets/banner-applications.png';"));
  assert(layout.includes("title:'我的申请',subtitle:'查看应用访问与账号开通申请进度',image:applicationsBanner"));
  assert(!layout.includes("title:'我的申请',subtitle:'查看应用访问与账号开通申请进度',image:todoBanner"));
});


test('公众公告详情头部居中且附件下载图标显示在文件大小后',()=>{
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  assert(css.includes('.public-portal-secondary-shell .portal-announcement-header{'));
  assert(css.includes('text-align:center;'));
  assert(css.includes('.public-portal-secondary-shell .portal-announcement-meta-inline{'));
  assert(css.includes('justify-content:center!important;'));
  assert(css.includes('.public-portal-secondary-shell .portal-announcement-file-name-line{'));
  assert(css.includes('display:contents;'));
  assert(css.includes('.public-portal-secondary-shell .portal-announcement-file-text>span{'));
  assert(css.includes('order:2;'));
  assert(css.includes('.public-portal-secondary-shell .portal-announcement-download{'));
  assert(css.includes('order:3;'));
});


test('公众首页Banner底部使用向上渐变过渡',()=>{
  const css=fs.readFileSync('src/styles/portal-home-preview.css','utf8');
  assert(css.includes('.public-portal-hero-mask{'));
  assert(css.includes('linear-gradient(to top,#f3f8fd 0%'));
  assert(css.includes('rgba(243,248,253,0) 65%'));
});


test('首页通知公告使用日期块和发布时间布局',()=>{
  const source=fs.readFileSync('src/views/PortalHomePreview.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-home-preview.css','utf8');
  assert(source.includes('class="public-portal-notice-date"'));
  assert(source.includes('{{ noticeDay(item.publishedAt) }}'));
  assert(source.includes('{{ noticeMonth(item.publishedAt) }}'));
  assert(source.includes("发布类型：{{ text(item.type)||'通知' }}"));
  assert(source.includes("发布对象：{{ label(item.scope||'ALL') }}"));
  assert(source.includes("function noticeDateParts(value)"));
  assert(css.includes('.public-portal-notice-date{'));
  assert(css.includes('background:linear-gradient(145deg,#315fdb,#2454ff);'));
  assert(css.includes('color:#fff!important;'));
  assert(css.includes('color:rgba(255,255,255,.9);'));
  assert(css.includes('.public-portal-notice-copy>small{'));
});


test('首页待办消息公告空态使用统一空态图',()=>{
  const source=fs.readFileSync('src/views/PortalHomePreview.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-home-preview.css','utf8');
  assert(source.includes("import EmptyState from '../components/portal/EmptyState.vue';"));
  assert(source.includes('description="暂无待办"'));
  assert(source.includes('description="暂无未读消息"'));
  assert(source.includes('description="暂无公告"'));
  assert(source.includes('class="public-portal-empty public-portal-home-empty"'));
  assert(css.includes('.public-portal-home-empty img{'));
  assert(css.includes('opacity:.75;'));
});


test('首页我的应用最多显示8条并移除更多应用卡片',()=>{
  const source=fs.readFileSync('src/views/PortalHomePreview.vue','utf8');
  assert(source.includes("const visibleApps=computed(()=>homeApps.value.slice(0,8));"));
  assert(source.includes("homeApps.value=(mine||[]).slice().sort"));
  assert(source.includes('查看更多 <ChevronRightIcon size="16px" />'));
  assert(!source.includes('class="public-portal-app-name">更多应用</strong>'));
  assert(!source.includes('查看全部应用'));
});


test('公众二级页内容区统一为应用中心方角卡片',()=>{
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  assert(css.includes('.public-portal-secondary-shell .portal-table-panel,'));
  assert(css.includes('.public-portal-secondary-shell .message-content-shell,'));
  assert(css.includes('.public-portal-secondary-shell .my-applications,'));
  assert(css.includes('.public-portal-secondary-shell .public-announcement-list,'));
  assert(css.includes('.public-portal-secondary-shell .portal-profile{'));
  assert(css.includes('border-radius:0!important;'));
  assert(css.includes('border:1px solid #e7edf5!important;'));
  assert(css.includes('background:#fff!important;'));
});


test('公众端Banner统一使用cover居中裁切适配',()=>{
  const homeCss=fs.readFileSync('src/styles/portal-home-preview.css','utf8');
  const pagesCss=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  assert(homeCss.includes('background-position:center center;background-size:cover;background-repeat:no-repeat;'));
  assert(pagesCss.includes('background-position:center center;'));
  assert(pagesCss.includes('background-size:cover;'));
  assert(pagesCss.includes('background-repeat:no-repeat;'));
  assert(pagesCss.includes('height:132px;'));
  assert(!pagesCss.includes('aspect-ratio:10 / 1;'));
  assert(pagesCss.includes('.public-announcement-banner{height:110px;min-height:110px}'));
});


test('首页公告元信息改为发布类型和发布对象',()=>{
  const source=fs.readFileSync('src/views/PortalHomePreview.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-home-preview.css','utf8');
  assert(source.includes("import {date,label,latest,text} from '../components/portal/presentation.js';"));
  assert(source.includes("发布类型：{{ text(item.type)||'通知' }}"));
  assert(source.includes("发布对象：{{ label(item.scope||'ALL') }}"));
  assert(!source.includes('发布时间：{{ date(item.publishedAt) }}'));
  assert(css.includes('.public-portal-notice-copy>small i{'));
});


test('我的申请两个Tab增加分页连续序号列',()=>{
  const source=fs.readFileSync('src/components/portal/MyApplications.vue','utf8');
  assert(source.includes("{colKey:'serial',title:'序号',width:64,cell:(_,ctx)=>(accessPage.value-1)*accessPageSize.value+ctx.rowIndex+1}"));
  assert(source.includes("{colKey:'serial',title:'序号',width:64,cell:(_,ctx)=>(openingPage.value-1)*openingPageSize.value+ctx.rowIndex+1}"));
});


test('公众待办任务使用标准表格列表并加宽来源应用查询',()=>{
  const source=fs.readFileSync('src/components/portal/TodoCenter.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  assert(source.includes('class="public-todo-table"'));
  assert(source.includes("{colKey:'serial',title:'序号',width:64}"));
  assert(source.includes("{colKey:'title',title:'待办标题',width:200,ellipsis:true}"));
  assert(source.includes("{colKey:'appName',title:'来源应用',width:320,ellipsis:true}"));
  assert(source.includes("{colKey:'businessType',title:'任务类型',width:120}"));
  assert(source.includes("{colKey:'status',title:'状态',width:120}"));
  assert(!source.includes('class="public-record-list public-todo-list"'));
  assert(css.includes('.public-portal-secondary-shell .todo-center .portal-query.list-toolbar .query-width-source{'));
  assert(css.includes('width:360px!important;'));
  assert(css.includes('flex:0 0 360px!important;'));
  assert(css.includes('.public-portal-secondary-shell .todo-center .portal-query.list-toolbar .query-width-source :is(.t-form__controls,.t-form__controls-content,.t-select__wrap){'));
});


test('首页单条待办打开详情弹窗而查看全部进入二级页',()=>{
  const source=fs.readFileSync('src/views/PortalHomePreview.vue','utf8');
  assert(source.includes('@click="go(\'todos\')">查看全部'));
  assert(source.includes('@click="openTodo(item)"'));
  assert(source.includes('v-model:visible="homeTodoDetailVisible"'));
  assert(source.includes('<TodoDetailContent :record="homeTodoActive"/>'));
  assert(source.includes("function openTodo(item){"));
  assert(source.includes("homeTodoDetailVisible.value=true;"));
  assert(!source.includes("function openTodo(){go('todos');}"));
});


test('待办任务列表内容顶部间距与消息中心一致',()=>{
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  assert(css.includes('.public-portal-secondary-shell .todo-center .portal-table-panel{'));
  assert(css.includes('padding:16px 20px 18px!important;'));
});


test('待办来源应用宽度覆盖通用查询项限制',()=>{
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  assert(css.includes('.public-portal-secondary-shell .portal-query.list-toolbar .portal-query-select{'));
  assert(css.includes('width:190px!important;'));
  assert(css.includes('.public-portal-secondary-shell .todo-center .portal-query.list-toolbar .query-width-source{'));
  assert(css.includes('width:360px!important;'));
  assert(css.includes('flex:0 0 360px!important;'));
});


test('公众公告和消息详情使用紧凑面包屑头部',()=>{
  const layout=fs.readFileSync('src/views/PortalPreviewLayout.vue','utf8');
  const page=fs.readFileSync('src/views/PortalPage.vue','utf8');
  const message=fs.readFileSync('src/components/portal/MessageCenter.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  assert(layout.includes('class="public-portal-breadcrumb"'));
  assert(layout.includes('{{ breadcrumbParent }}'));
  assert(layout.includes('id="page-header-current-title"'));
  assert(layout.includes("route.meta.resource==='announcementDetail'?'通知公告':route.meta.resource==='messages'?'消息中心':''"));
  assert(!layout.includes('class="public-portal-subpage-back" aria-label="返回"'));
  assert(page.includes('<Teleport v-if="preview&&detail" to="#page-header-current-title">'));
  assert(page.includes("{{ text(detail.title)||'公告详情' }}"));
  assert(message.includes('<Teleport v-if="publicPortal&&activeMessage" to="#page-header-current-title">'));
  assert(message.includes("{{ text(activeMessage.title)||'消息详情' }}"));
  assert(css.includes('.public-portal-subpage-head.is-breadcrumb{'));
  assert(css.includes('min-height:34px!important;'));
  assert(css.includes('.public-portal-breadcrumb-current{'));
});


test('消息中心来源应用查询项加宽',()=>{
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  assert(css.includes('.public-portal-secondary-shell .portal-message-center .portal-query.list-toolbar .query-width-source{'));
  assert(css.includes('width:320px!important;'));
  assert(css.includes('flex:0 0 320px!important;'));
  assert(css.includes('.public-portal-secondary-shell .portal-message-center .portal-query.list-toolbar .query-width-source :is(.t-form__controls,.t-form__controls-content,.t-select__wrap){'));
});


test('公众详情面包屑右侧增加返回按钮',()=>{
  const layout=fs.readFileSync('src/views/PortalPreviewLayout.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  assert(layout.includes('class="public-portal-breadcrumb-back"'));
  assert(layout.includes('<ArrowLeftIcon size="14px" />'));
  assert(layout.includes('<span>返回</span>'));
  assert(layout.includes('@click="backToList"'));
  assert(css.includes('.public-portal-subpage-head.is-breadcrumb .public-portal-subpage-actions{'));
  assert(css.includes('margin-left:auto;'));
  assert(css.includes('.public-portal-breadcrumb-back{'));
});


test('公众消息详情保持原有信件式布局',()=>{
  const css=fs.readFileSync('src/styles/portal-preview-pages.css','utf8');
  const source=fs.readFileSync('src/components/portal/MessageCenter.vue','utf8');
  assert(source.includes('class="message-detail-toolbar list-toolbar"'));
  assert(source.includes('class="message-letter-wrap"'));
  assert(source.includes('class="message-letter-panel"'));
  assert(source.includes('class="message-letter"'));
  assert(source.includes('class="message-letter-meta"'));
  assert(source.includes('class="message-business-detail"'));
  assert(css.includes('.public-portal-secondary-shell .portal-message-center .message-letter-panel{'));
  assert(css.includes('width:min(960px,100%)!important;'));
  assert(css.includes('padding:24px!important;'));
  assert(css.includes('background:#f6f8fb!important;'));
  assert(css.includes('.public-portal-secondary-shell .portal-message-center .message-letter{'));
  assert(css.includes('border-top:4px solid var(--portal-primary)!important;'));
  assert(css.includes('background:#fff!important;'));
});


test('个人中心使用独立Banner图片',()=>{
  const source=fs.readFileSync('src/views/PortalPreviewLayout.vue','utf8');
  assert(source.includes("import profileBanner from '../assets/banner-profile.png.png';"));
  assert(source.includes("if(resource==='profile')return {title:'个人中心',subtitle:'查看账号信息与个人资料',image:profileBanner};"));
  assert(!source.includes("if(resource==='profile')return {title:'个人中心',subtitle:'查看账号信息与个人资料',image:messageBanner};"));
});


test('首页公告发布类型和发布对象使用淡灰标签',()=>{
  const source=fs.readFileSync('src/views/PortalHomePreview.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-home-preview.css','utf8');
  assert(source.includes('class="public-portal-notice-meta-tags"'));
  assert(source.includes('class="public-portal-notice-meta-tag">{{ text(item.type)||\'通知\' }}</span>'));
  assert(source.includes('class="public-portal-notice-meta-tag">{{ label(item.scope||\'ALL\') }}</span>'));
  assert(css.includes('.public-portal-notice-meta-tag{'));
  assert(css.includes('background:#f4f6f8;'));
  assert(css.includes('color:#667085;'));
});


test('首页待办消息来源与时间增加小图标',()=>{
  const source=fs.readFileSync('src/views/PortalHomePreview.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-home-preview.css','utf8');
  assert(source.includes('class="public-portal-row-meta"'));
  assert(source.includes('<Icon name="app"/>'));
  assert(source.includes('<Icon name="time"/>'));
  assert(source.includes("Icon,MailIcon"));
  assert(css.includes('.public-portal-row-meta>span>.t-icon{'));
  assert(css.includes('width:13px!important;'));
  assert(css.includes('font-size:13px!important;'));
});


test('公众门户用户浮层显示当前用户类型标签',()=>{
  const home=fs.readFileSync('src/views/PortalHomePreview.vue','utf8');
  const layout=fs.readFileSync('src/views/PortalPreviewLayout.vue','utf8');
  const css=fs.readFileSync('src/styles/portal-home-preview.css','utf8');
  for(const source of [home,layout]){
    assert(source.includes('class="public-portal-account-meta"'));
    assert(source.includes('class="public-portal-user-type-tag"'));
    assert(source.includes('{{ label(actor?.userType) }}'));
  }
  assert(layout.includes("import {label} from '../components/portal/presentation.js';"));
  assert(css.includes('.public-portal-account-meta{'));
  assert(css.includes('.public-portal-user-type-tag{'));
});


test('首页来源系统去掉来自文字前缀',()=>{
  const source=fs.readFileSync('src/views/PortalHomePreview.vue','utf8');
  assert(source.includes('<span><Icon name="app"/>{{ text(item.appName) }}</span>'));
  assert(!source.includes('<em>来自：</em>'));
});


test('顶部消息徽标靠近铃铛并收紧用户区间距',()=>{
  const css=fs.readFileSync('src/styles/portal-home-preview.css','utf8');
  assert(css.includes('.public-portal-user-area{min-width:215px;display:flex;align-items:center;justify-content:flex-end;gap:8px}'));
  assert(css.includes('top:2px!important;right:2px!important;transform:translate(35%,-35%)!important'));
});
