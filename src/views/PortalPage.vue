<template>
 <div class="portal-page">
  <Teleport v-if="admin&&resource==='announcements'&&can(actor,'announcement')" to="#page-header-actions"><t-button theme="primary" @click="openForm('saveAnnouncement')"><template #icon><Icon name="add"/></template>新增公告</t-button></Teleport>
  <Teleport v-if="admin&&resource==='apps'&&canCreate" to="#page-header-actions"><t-button variant="outline" theme="primary" @click="downloadAccessSpec"><template #icon><Icon name="download"/></template>下载接口文件</t-button><t-button theme="primary" @click="openForm('saveApp')"><template #icon><Icon name="add"/></template>新增应用</t-button></Teleport>
  <Teleport v-if="admin&&resource==='roles'&&canCreate" to="#page-header-actions"><t-button theme="primary" @click="openForm('saveSystemRole')"><template #icon><Icon name="add"/></template>新增角色</t-button></Teleport>
  <Teleport v-if="admin&&resource==='categories'&&canCreate" to="#page-header-actions"><t-button theme="primary" @click="openForm('saveCategory')"><template #icon><Icon name="add"/></template>新增分类</t-button></Teleport>
  <Teleport v-if="resource==='todos'" to="#page-header-extra"><span class="portal-title-count">（共<span class="portal-title-count-number">{{rows.length}}</span>条待办任务）</span></Teleport>
  <div v-if="error" role="alert" class="error-note">{{text(error)}} <t-button variant="text" theme="primary" @click="load">重试</t-button></div>
  <t-loading :loading="loading" :show-overlay="false" size="small">
   <template v-if="isHome">
    <template v-if="admin">
     <div class="admin-overview-grid">
      <button v-for="card in adminOverviewCards" :key="card.label" type="button" class="admin-overview-card" @click="card.path&&router.push(card.path)"><span>{{card.label}}</span><strong>{{card.value}}</strong><small>{{card.hint}}</small></button>
     </div>
     <section class="panel admin-work-panel"><div class="section-head"><h2>管理工作</h2><span class="muted">按当前账号权限显示</span></div><div class="admin-entry-grid compact"><button v-if="can(actor,'announcement')" class="admin-entry-card compact" @click="openForm('saveAnnouncement')"><Icon name="notification"/><span><strong>发布公告</strong><small>公告内容维护</small></span></button><button v-for="item in adminShortcuts" :key="item.id" class="admin-entry-card compact" @click="router.push(item.path)"><Icon name="file"/><span><strong>{{text(item.title)}}</strong><small>{{adminShortcutHint(item.resource)}}</small></span></button></div></section>
     <div class="admin-home-grid">
      <section class="panel"><div class="section-head"><h2>管理提醒</h2><router-link v-if="can(actor,'integration')" to="/admin/monitor">查看运行监控</router-link></div><div class="admin-reminder-grid"><button v-for="item in adminReminders" :key="item.label" type="button" class="admin-reminder-card" @click="item.path&&router.push(item.path)"><span>{{item.label}}</span><strong :class="{'is-danger':item.danger}">{{item.value}}</strong><small>{{item.hint}}</small></button></div></section>
      <section class="panel"><div class="section-head"><h2>异常接入消息 <span class="portal-count">{{homeExceptions.length}}</span></h2><router-link v-if="can(actor,'integration')" to="/admin/monitor">全部异常</router-link></div><div v-for="item in latest(homeExceptions).slice(0,5)" :key="item.id" class="list-row"><div><button class="portal-field-link" @click="showDetail(item,'monitor')">{{text(item.appName||item.name)}}</button><p>{{label(item.kind)}} · {{text(item.remark)||label(item.status)}}</p></div><t-tag :theme="theme(item.status)" variant="light">{{label(item.status)}}</t-tag></div><EmptyState v-if="!homeExceptions.length" :description="can(actor,'integration')||can(actor,'identity')?'暂无异常接入消息':'当前权限范围暂无接入消息'"/></section>
     </div>
    </template>
    <template v-else>
     <div class="portal-home-feeds">
      <section class="panel"><div class="section-head"><h2>我的待办 <t-tag class="portal-count-tag" theme="danger" variant="light" size="small">{{overview.todoCount??0}}</t-tag></h2><router-link to="/portal/todos">全部待办</router-link></div><div v-for="item in homeTodos" :key="item.id" class="list-row"><div><button class="portal-field-link" @click="showDetail(item,'todos')">{{text(item.title)}}</button><p>{{text(item.appName)}}</p></div><t-button size="small" variant="text" theme="primary" @click="run('openTodo',{id:item.id},true)">去处理</t-button></div><EmptyState v-if="!homeTodos.length" description="暂无待办"/></section>
      <section class="panel"><div class="section-head"><h2>通知公告 <t-tag class="portal-count-tag" theme="danger" variant="light" size="small">{{overview.unreadAnnouncementCount??0}}</t-tag></h2><router-link to="/portal/announcements">全部公告</router-link></div><div v-for="item in homeAnnouncements" :key="item.id" class="list-row"><div><button class="portal-field-link" :class="{'is-unread':item.readStatus==='UNREAD'}" @click="showDetail(item,'announcements')">{{text(item.title)}}</button><p>{{date(item.publishedAt)}}</p></div></div><EmptyState v-if="!homeAnnouncements.length" description="暂无公告"/></section>
      <section class="panel"><div class="section-head"><h2>消息 <t-tag class="portal-count-tag" theme="danger" variant="light" size="small">{{overview.unreadCount??0}}</t-tag></h2><router-link to="/portal/messages">全部消息</router-link></div><div v-for="item in homeMessages" :key="item.id" class="list-row"><div><button class="portal-field-link" :class="{'is-unread':item.status==='UNREAD'}" @click="showDetail(item,'messages')">{{text(item.title)}}</button><p>{{text(item.appName)}} · {{date(item.createdAt)}}</p></div></div><EmptyState v-if="!homeMessages.length" description="暂无消息"/></section>
     </div>
     <section class="panel portal-home-apps"><div class="section-head"><h2>我的应用</h2><router-link to="/portal/apps/mine">应用中心</router-link></div><AppCards :apps="homeApps" compact @detail="showDetail($event,'apps')" @enter="enterApp" @bind="bindApp" @request="requestApp" @view-request="viewApplicationRequest" @view-binding="viewBinding" @view-conflict="viewConflict"/></section>
    </template>
   </template>
   <IdentityMappings v-else-if="resource==='identityOverview'" :key="route.path" :rows="rows" :can-manage="can(actor,'identity')" :exceptions-only="route.path==='/admin/mapping-exceptions'" @unbind="confirm('unbind',$event,'确认解除此账号关联？不会修改子系统账号或授权。')" @resolve="openForm('resolveMapping',$event)"/>
   <MessageCenter v-else-if="resource==='messages'" :rows="rows" :receiver="actor?.name"/>
   <RulesSettings v-else-if="resource==='settings'" :rows="rows" @saved="load"/>
   <PersonalProfile v-else-if="resource==='profile'" :user="actor"/>
   <template v-else-if="resource==='announcementDetail'"><AnnouncementDetail v-if="detail" :record="detail" @download="download"/><section v-else class="panel"><EmptyState description="公告不存在或暂无查看权限"/></section></template>
   <section v-else-if="resource==='external'" class="panel"><div class="empty-conditional"><t-tag theme="warning" variant="light">尚未启用</t-tag><h2>公共服务接入</h2><p>通过闽政通、闽政务提供二维码、手机验证码等公共服务。服务开通后，可按授权范围使用。</p><router-link to="/admin/monitor">查看接入状态</router-link></div></section>
   <section v-else class="portal-list">
    <t-form layout="inline" class="portal-query list-toolbar">
     <t-form-item class="portal-query-keyword query-width-keyword" :label="querySpec.keywordLabel||'关键词'"><t-input v-model="search" :placeholder="querySpec.keywordPlaceholder" clearable/></t-form-item>
     <t-form-item v-for="filter in queryFilters" :key="filter.key" class="portal-query-select" :class="queryWidthClass(filter.widthKey||filter.key)" :label="filter.label"><t-select v-model="filterValues[filter.key]" clearable :placeholder="filter.placeholder" :options="filter.options"/></t-form-item>
     <t-form-item class="portal-query-action"><t-button class="query-reset-button" theme="default" variant="outline" @click="resetQuery">重置</t-button></t-form-item>
    </t-form>
    <template v-if="isAppCenter">
     <section v-for="group in appGroups" :key="group.key" class="panel portal-app-section"><div class="section-head"><h2>{{group.title}}<span class="portal-section-count">（{{group.total}}）</span></h2></div><AppCards :apps="group.rows" @detail="showDetail($event,'apps')" @enter="enterApp" @bind="bindApp" @request="requestApp" @view-request="viewApplicationRequest" @view-binding="viewBinding" @view-conflict="viewConflict"/><t-pagination v-if="group.total" :current="group.page" :page-size="appPageSize" :total="group.total" :page-size-options="[12,24,48]" show-jumper @current-change="setAppPage(group.key,$event)" @page-size-change="appPageSize=$event"/></section>
    </template>
    <section v-else class="panel portal-table-panel">
     <t-table row-key="id" :data="paged" :columns="columns" hover table-layout="fixed" size="medium" empty="暂无符合条件的记录">
      <template #empty><EmptyState description="暂无符合条件的记录"/></template>
      <template #serial="{rowIndex}">{{(page-1)*pageSize+rowIndex+1}}</template>
      <template #primary="{row}"><button class="portal-field-link" :class="{'is-unread':row.status==='UNREAD'||row.readStatus==='UNREAD'}" @click="showDetail(row)">{{text(row[primaryField])||'—'}}</button></template>
      <template v-if="resource==='apps'" #status="{row}"><t-switch :value="row.status==='ENABLED'" :label="['启用','停用']" @change="toggleAppStatus(row,$event)"/></template>
      <template #operation="{row}"><div class="row-actions">
       <template v-if="resource==='apps'&&admin&&can(actor,'application')"><t-button size="small" variant="text" theme="primary" @click="openForm('saveApp',row)">编辑</t-button><t-button size="small" variant="text" theme="primary" @click="openConnectionConfig(row)">连接配置</t-button></template>
       <template v-if="resource==='categories'"><t-button size="small" variant="text" theme="primary" @click="openForm('saveCategory',row)">编辑</t-button><t-button size="small" variant="text" theme="danger" @click="confirm('removeCategory',row,'确认删除未被应用引用的分类？')">删除</t-button></template>
       <t-button v-if="resource==='users'&&can(actor,'super')" size="small" variant="text" theme="primary" @click="openForm('savePortalUser',row)">编辑</t-button>
       <t-button v-if="resource==='roles'&&can(actor,'super')" size="small" variant="text" theme="primary" @click="openForm('saveSystemRole',row)">编辑</t-button>
       <t-button v-if="resource==='todos'&&row.status==='PENDING'" size="small" variant="text" theme="primary" @click="run('openTodo',{id:row.id},true)">去处理</t-button>
       <template v-if="resource==='announcements'&&admin"><t-button v-if="row.status==='DRAFT'" size="small" variant="text" theme="danger" @click="confirm('removeAnnouncement',row,'确认删除此草稿？删除后退出公告列表，回收档案保留。')">删除</t-button><t-button v-if="row.status==='DRAFT'" size="small" variant="text" theme="primary" @click="openForm('saveAnnouncement',row)">编辑</t-button><t-button v-if="row.status==='DRAFT'" size="small" variant="text" theme="primary" @click="confirm('publish',row,'确认发布公告？发布后不可直接编辑。')">发布</t-button><t-button v-if="row.status==='PUBLISHED'" size="small" variant="text" theme="danger" @click="confirm('withdraw',row,'确认撤回公告？撤回后用户将不可见。')">撤回</t-button></template>
       <t-button v-if="resource==='mappings'&&row.status==='BOUND'" size="small" variant="text" theme="danger" @click="confirm('unbind',row,'确认解除此账号关联？不会修改子系统账号或授权。')">解绑</t-button>
       <t-button v-if="resource==='exceptions'&&row.status==='CONFLICT'" size="small" variant="text" theme="primary" @click="openForm('resolveMapping',row)">处理冲突</t-button>
       <template v-if="resource==='myApplicationRequests'">
        <t-button v-if="row.requestType==='APPLICATION_ACCESS'&&row.status==='PENDING'" size="small" variant="text" theme="danger" @click="confirm('withdrawApplicationRequest',row,'确认撤回此应用访问申请？')">撤回</t-button>
        <t-button v-if="row.requestType==='APPLICATION_ACCESS'&&row.status==='REJECTED'" size="small" variant="text" theme="primary" @click="openForm('submitApplicationRequest',{appId:row.appId,appName:row.appName})">重新申请</t-button>
        <t-button v-if="row.requestType==='ACCOUNT_OPENING'&&row.status==='COMPLETED'" size="small" variant="text" theme="primary" @click="bindByRequest(row)">去关联</t-button>
       </template>
       <template v-if="resource==='applicationRequests'&&row.status==='PENDING'"><t-button size="small" variant="text" theme="primary" @click="confirm('approveApplicationRequest',row,'确认通过此应用访问申请？通过后仅授予门户入口资格。')">通过</t-button><t-button size="small" variant="text" theme="danger" @click="openForm('rejectApplicationRequest',row)">驳回</t-button></template>
       <template v-if="resource==='accountOpeningRequests'&&['PENDING','PROCESSING'].includes(row.status)"><t-button size="small" variant="text" theme="primary" @click="confirm('completeMockAccountOpeningRequest',row,'演示环境：确认模拟目标子系统已完成账号开通？此操作不会创建真实子系统账号。')">模拟已开通</t-button></template>
      </div></template>
     </t-table>
     <t-pagination v-model="page" v-model:page-size="pageSize" :total="filtered.length" :page-size-options="[10,20,50]" show-jumper/>
    </section>
   </section>
  </t-loading>
  <t-dialog v-model:visible="formVisible" placement="center" :header="formTitle" :width="formAction==='saveAnnouncement'?'min(1180px, calc(100vw - 48px))':'720px'" :confirm-btn="{content:formAction==='bind'?'核验并关联':formAction==='submitApplicationRequest'?'提交申请':formAction==='rejectApplicationRequest'?'确认驳回':'保存',loading:saving,disabled:saving}" :close-on-overlay-click="false" @confirm="saveForm">
   <p v-if="formAction==='bind'" class="inline-note">当前应用已在此账号的可见范围内。请输入已开通的子系统账号，提交后查看关联结果。</p>
   <p v-if="formAction==='submitApplicationRequest'" class="inline-note">申请应用：{{text(form.appName)}}。当前申请仅授予统一门户入口资格；如果目标应用还需要账号关联，审核通过后继续执行BIND。</p>
   <p v-if="formAction==='rejectApplicationRequest'" class="inline-note">请填写驳回原因。驳回后用户可在“我的申请”中查看并重新申请。</p>
   <p v-if="formAction==='saveIntegration'" class="inline-note">待办和消息采用PUSH方式接收。凭据填写服务端环境变量名，不填写密钥。SSO参数可维护，认证适配器尚未接入。</p>
   <template v-if="formAction==='savePortalUser'"><h3>身份信息</h3><DetailGrid :items="userFormIdentity"/><p class="muted">身份资料由{{source(form)}}提供；此处仅维护启用状态和系统角色，不授予子系统业务权限。</p></template>
   <template v-if="formAction==='saveSystemRole'"><p class="inline-note">系统角色仅控制卫健统一门户自身页面与操作权限。应用内部业务权限仍由各子系统自行管理。</p></template>
   <div v-if="formError" role="alert" class="error-note">{{text(formError)}}</div><t-alert v-if="bindFeedback" :theme="bindFeedback.theme" :message="bindFeedback.message" class="portal-bind-feedback"/>
   <div class="form-grid"><div v-for="field in formFields" :key="field.key" class="form-field" :class="{full:field.full}"><label>{{field.label}}<span v-if="field.required" class="portal-required"> *</span></label><t-switch v-if="field.key==='status'&&['savePortalUser','saveSystemRole'].includes(formAction)" :value="form.status!=='DISABLED'" :label="['启用','停用']" @change="form.status=$event?(formAction==='savePortalUser'?'NORMAL':'ENABLED'):'DISABLED'"/><t-select v-else-if="field.options" v-model="form[field.key]" :options="field.options" :multiple="['scopes','roleIds'].includes(field.key)" :clearable="['scopes','roleIds'].includes(field.key)"/><t-textarea v-else-if="field.type==='textarea'" v-model="form[field.key]" :autosize="{minRows:4,maxRows:8}"/><t-date-picker v-else-if="field.type==='date'" v-model="form[field.key]" enable-time-picker clearable format="YYYY-MM-DD HH:mm:ss" value-type="YYYY-MM-DD HH:mm:ss" placeholder="请选择日期时间"/><t-input-number v-else-if="field.type==='number'" v-model="form[field.key]" :decimal-places="0"/><t-input v-else v-model="form[field.key]" :maxlength="300"/></div></div>
   <AnnouncementEditor v-if="formAction==='saveAnnouncement'" v-model="form.content" v-model:files="announcementUploadFiles"/>
  </t-dialog>
  <t-dialog v-model:visible="accessDialogVisible" placement="center" :header="accessDialogTitle" width="1180px" :footer="false" :close-on-overlay-click="false">
   <AccessConfigDetail :profile="accessProfile" :saving="accessSaving" @save="saveAccessIntegration"/>
  </t-dialog>
  <AccountBindingWizard v-model:visible="bindingVisible" :app="bindingApp" @completed="handleBindingCompleted" @view-request="viewBindingRequests"/>
  <RecordDetail :visible="detailVisible" :record="detail" :kind="detailKind" :receiver="actor?.name" :access-profile="detailAccessProfile" :show-connection="admin&&detailKind==='apps'" @update:visible="closeDetail" @download="download"/>
 </div>
</template>

<script setup>
import EmptyState from '../components/portal/EmptyState.vue';
import {computed,h,reactive,ref,watch} from 'vue';
import {useRoute,useRouter} from 'vue-router';
import {MessagePlugin,DialogPlugin,Tag} from 'tdesign-vue-next';
import {Icon} from 'tdesign-icons-vue-next';
import {actor,portal,command,revision,availableUsers,downloadAccessContract} from '../services/runtime.js';
import {scopes,pages,can} from '../config/pages.js';
import RulesSettings from '../components/portal/RulesSettings.vue';
import MessageCenter from '../components/portal/MessageCenter.vue';
import IdentityMappings from '../components/portal/IdentityMappings.vue';
import AccessConfigDetail from '../components/portal/AccessConfigDetail.vue';
import AppCards from '../components/portal/AppCards.vue';
import AccountBindingWizard from '../components/portal/AccountBindingWizard.vue';
import DetailGrid from '../components/portal/DetailGrid.vue';
import PersonalProfile from '../components/portal/PersonalProfile.vue';
import RecordDetail from '../components/portal/RecordDetail.vue';
import AnnouncementEditor from '../components/portal/AnnouncementEditor.vue';
import AnnouncementDetail from '../components/portal/AnnouncementDetail.vue';
import {text,label,date,source,theme,latest,titles,display} from '../components/portal/presentation.js';

const route=useRoute(),router=useRouter();
const resource=computed(()=>route.meta.resource||''),admin=computed(()=>route.path.startsWith('/admin'));
const isHome=computed(()=>['home','adminHome'].includes(resource.value));
const isAppCenter=computed(()=>!admin.value&&['apps','mine'].includes(resource.value));
const listResource=computed(()=>resource.value==='announcementDetail'?'announcements':resource.value);
const rows=ref([]),overview=ref({}),allApps=ref([]),categories=ref([]),systemRoles=ref([]),mineIds=ref([]),accessProfiles=ref([]);
const homeApps=ref([]),homeTodos=ref([]),homeMessages=ref([]),homeAnnouncements=ref([]),homeExceptions=ref([]);
const error=ref(''),loading=ref(false),search=ref(''),filterValues=reactive({}),page=ref(1),pageSize=ref(10);
const appPageSize=ref(24),appPages=reactive({mine:1,other:1});
const formVisible=ref(false),formAction=ref(''),form=reactive({}),formError=ref(''),saving=ref(false),bindFeedback=ref(null),announcementUploadFiles=ref([]);
const detailVisible=ref(false),detail=ref(null),detailKind=ref(''),detailAccessProfile=ref(null);
const accessDialogVisible=ref(false),accessProfile=ref(null),accessSaving=ref(false);
const bindingVisible=ref(false),bindingApp=ref(null);
const accessDialogTitle=computed(()=>accessProfile.value?`${text(accessProfile.value.appName)}-连接配置`:'连接配置');
const adminShortcuts=computed(()=>pages.filter(item=>['PG-220','PG-202','PG-205','PG-222','PG-225'].includes(item.id)&&can(actor.value,item.scope)));
const adminOverviewCards=computed(()=>[
 {label:'应用总数',value:overview.value.appCount??0,hint:'统一应用目录',path:can(actor.value,'application')?'/admin/apps':''},
 {label:'已启用应用',value:overview.value.enabledCount??0,hint:'当前启用状态',path:can(actor.value,'application')?'/admin/apps':''},
 {label:'待审核申请',value:overview.value.pendingAccessCount??0,hint:'应用入口资格',path:can(actor.value,'application')?'/admin/application-requests':''},
 {label:'正常接入项',value:overview.value.integrationCount??0,hint:'SSO / 待办 / 消息',path:can(actor.value,'integration')?'/admin/monitor':''},
 {label:'待处理异常',value:overview.value.exceptionCount??0,hint:'账号映射与接入异常',path:can(actor.value,'identity')?'/admin/mapping-exceptions':can(actor.value,'integration')?'/admin/monitor':''}
]);
const adminShortcutHint=resource=>({announcements:'公告内容维护',apps:'应用目录配置',identityOverview:'账号映射核对',monitor:'运行状态检查'}[resource]||(String(resource||'').startsWith('logs:')?'查看门户操作日志':'进入管理模块'));
const adminReminders=computed(()=>[
 {label:'待审核申请',value:overview.value.pendingAccessCount??0,hint:'用户应用访问申请',path:can(actor.value,'application')?'/admin/application-requests':'',danger:(overview.value.pendingAccessCount??0)>0},
 {label:'异常接入',value:overview.value.exceptionCount??0,hint:'需及时核查',path:can(actor.value,'integration')?'/admin/monitor':'',danger:(overview.value.exceptionCount??0)>0},
 {label:'停用应用',value:Math.max((overview.value.appCount??0)-(overview.value.enabledCount??0),0),hint:'检查目录启停',path:can(actor.value,'application')?'/admin/apps':'',danger:false},
 {label:'身份冲突',value:homeExceptions.value.filter(item=>String(item.status||'').includes('CONFLICT')).length,hint:'查看映射冲突',path:can(actor.value,'identity')?'/admin/mapping-exceptions':'',danger:homeExceptions.value.some(item=>String(item.status||'').includes('CONFLICT'))},
 {label:'公告管理',value:can(actor.value,'announcement')?'已开通':'只读',hint:'维护公告发布',path:can(actor.value,'announcement')?'/admin/announcements':'',danger:false}
 ]);
let loadVersion=0;
async function read(key){const result=await portal.read(key);if(!result.ok)throw new Error(result.error.message);return result.data;}
async function load(){
 const version=++loadVersion;loading.value=true;error.value='';
 try{
  const key=resource.value,home=isHome.value,center=isAppCenter.value,isAdmin=admin.value;
  const tasks={apps:read(isAdmin?'adminApps':'apps')};
  if(can(actor.value,'application')){tasks.categories=read('categories');if(isAdmin&&key==='apps')tasks.accessProfiles=read('access');}
  if(can(actor.value,'super')&&key==='users')tasks.systemRoles=read('roles');
  if(home){
   tasks.overview=read(key);
   if(!isAdmin){for(const name of ['mine','todos','messages','announcements'])tasks[name]=read(name);}
   if(isAdmin&&can(actor.value,'integration'))tasks.monitor=read('monitor');
   if(isAdmin&&can(actor.value,'identity'))tasks.exceptions=read('exceptions');
  }else if(center)tasks.mine=read('mine');
  else if(!['profile','external'].includes(key))tasks.rows=read(key==='announcementDetail'?(isAdmin?'adminAnnouncements':'announcements'):key==='announcements'&&isAdmin?'adminAnnouncements':key);
  const entries=await Promise.all(Object.entries(tasks).map(async([name,promise])=>[name,await promise]));
  if(version!==loadVersion)return;
  const data=Object.fromEntries(entries);allApps.value=data.apps;categories.value=data.categories||[];accessProfiles.value=data.accessProfiles||accessProfiles.value;systemRoles.value=data.systemRoles||(key==='roles'?data.rows:[])||[];
  if(home){
   overview.value=data.overview;
   homeApps.value=(data.mine||[]).slice().sort((a,b)=>(a.sortOrder||0)-(b.sortOrder||0));
   homeTodos.value=latest((data.todos||[]).filter(item=>item.status==='PENDING'));
   homeMessages.value=latest(data.messages||[]);homeAnnouncements.value=latest(data.announcements||[],'publishedAt');
   homeExceptions.value=[...(data.monitor||[]).filter(item=>!['NORMAL','CONFIGURED'].includes(item.status)),...(data.exceptions||[])];
  }
  mineIds.value=(data.mine||[]).map(item=>item.id);rows.value=center?data.apps:data.rows||[];
  if(key==='announcementDetail'){
   const article=rows.value.find(item=>item.id===route.params.id);
   if(!article){detail.value=null;error.value='公告不存在或不在当前用户的可见范围';}
   else{detail.value=JSON.parse(JSON.stringify(article));detailKind.value='announcements';if(!isAdmin&&article.readStatus==='UNREAD'){const marked=await command('markAnnouncementRead',{id:article.id});if(marked.ok)detail.value.readStatus='READ';}}
  }
 }catch(cause){if(version===loadVersion)error.value=cause.message;}
 finally{if(version===loadVersion)loading.value=false;}
}
function resetQuery(){
 search.value='';
 for(const key of Object.keys(filterValues))delete filterValues[key];
 page.value=1;appPages.mine=1;appPages.other=1;
}
watch(()=>route.fullPath,()=>{resetQuery();detailVisible.value=false;formVisible.value=false;accessDialogVisible.value=false;bindingVisible.value=false;bindingApp.value=null;load();},{immediate:true});
watch(revision,load);
const queryWidthClass=key=>({
 category:'query-width-category',
 userType:'query-width-user-type',
 priority:'query-width-priority',
 messageType:'query-width-message-type',
 scope:'query-width-scope',
 appName:'query-width-source',
 actor:'query-width-actor',
 orgName:'query-width-org',
 kind:'query-width-kind',
 type:'query-width-kind',
 mode:'query-width-mode',
 status:'query-width-status',
 runtimeStatus:'query-width-runtime-status',
 readStatus:'query-width-status',
 ssoStatus:'query-width-sso-status',
 todoStatus:'query-width-todo-status',
 messageStatus:'query-width-message-status'
}[key]||'query-width-default');
const fixedOptions=values=>values.map(value=>({value,label:label(value)}));
const rowOptions=(field,useLabel=false)=>[...new Set(rows.value.map(row=>row[field]).filter(value=>value!==null&&value!==undefined&&String(value)!==''))].map(value=>({value,label:useLabel?label(value):text(value)}));
const filterDef=(key,labelText,placeholder,options,widthKey=key)=>({key,label:labelText,placeholder:'全部',options,widthKey});
const querySpec=computed(()=>{
 const key=listResource.value;
 const logKind=resource.value.startsWith('logs:')?resource.value.split(':')[1]:'';
 if(key==='apps'||key==='mine')return {keywordPlaceholder:'应用名称 / 应用编码',keywordFields:['name','code'],filters:[
  filterDef('category','系统分类','请选择系统分类',rowOptions('category'),'category'),
  filterDef('runtimeStatus','运行状态','请选择运行状态',fixedOptions(['NORMAL','ABNORMAL','UNCONFIGURED','DISABLED']),'runtimeStatus'),
  ...(admin.value?[filterDef('status','启用状态','请选择启用状态',fixedOptions(['ENABLED','DISABLED']),'status')]:[]),
  filterDef('userType','适用用户','请选择适用用户',fixedOptions(['BOTH','CITIZEN','GOV']),'userType')
 ]};
 if(key==='categories')return {keywordPlaceholder:'分类名称 / 分类编码',keywordFields:['name','code'],filters:[filterDef('status','启用状态','请选择启用状态',fixedOptions(['ENABLED','DISABLED']),'status')]};
 if(key==='users')return {keywordPlaceholder:'姓名 / 登录账号 / 所属单位',keywordFields:['name','account','orgName'],filters:[filterDef('userType','用户类别','请选择用户类别',fixedOptions(['CITIZEN','GOV']),'userType'),filterDef('status','启用状态','请选择启用状态',fixedOptions(['NORMAL','DISABLED']),'status')]};
 if(key==='roles')return {keywordPlaceholder:'角色名称 / 角色编码 / 描述',keywordFields:['roleName','roleCode','description'],filters:[filterDef('status','启用状态','请选择启用状态',fixedOptions(['ENABLED','DISABLED']),'status')]};
 if(['myApplicationRequests','applicationRequests','accountOpeningRequests'].includes(key))return {keywordPlaceholder:'申请编号 / 应用名称 / 申请人',keywordFields:['requestNo','appName','userName','reason'],filters:[filterDef('appName','应用','请选择应用',rowOptions('appName'),'appName'),filterDef('status','状态','请选择状态',fixedOptions(['PENDING','APPROVED','REJECTED','WITHDRAWN','EXPIRED']),'status')]};
 if(key==='permissions')return {keywordPlaceholder:'权限名称 / 权限编码',keywordFields:['name','code'],filters:[]};
 if(key==='todos')return {keywordPlaceholder:'待办标题',keywordFields:['title'],filters:[filterDef('appName','来源应用','请选择来源应用',rowOptions('appName'),'appName'),filterDef('status','状态','请选择待办状态',fixedOptions(['PENDING','COMPLETED','WITHDRAWN','EXPIRED']),'status')]};
 if(key==='announcements')return admin.value
  ?{keywordPlaceholder:'公告标题',keywordFields:['title'],filters:[filterDef('type','公告类型','请选择公告类型',rowOptions('type'),'type'),filterDef('scope','发布范围','请选择发布范围',fixedOptions(['ALL','CITIZEN','GOV','ORG']),'scope'),filterDef('status','状态','请选择公告状态',fixedOptions(['DRAFT','PUBLISHED','WITHDRAWN']),'status')]}
  :{keywordPlaceholder:'公告标题',keywordFields:['title'],filters:[filterDef('type','公告类型','请选择公告类型',rowOptions('type'),'type'),filterDef('scope','发布范围','请选择发布范围',fixedOptions(['ALL','CITIZEN','GOV']),'scope'),filterDef('readStatus','阅读状态','请选择阅读状态',fixedOptions(['UNREAD','READ']),'status')]};
 if(key==='monitor')return {keywordPlaceholder:'应用名称 / 应用编码',keywordFields:['appName','appCode'],filters:[filterDef('ssoStatus','SSO状态','请选择SSO状态',fixedOptions(['UNCONFIGURED','DISABLED','NORMAL','ABNORMAL']),'ssoStatus'),filterDef('todoStatus','TODO状态','请选择TODO状态',fixedOptions(['UNCONFIGURED','DISABLED','NORMAL','ABNORMAL']),'todoStatus'),filterDef('messageStatus','MESSAGE状态','请选择MESSAGE状态',fixedOptions(['UNCONFIGURED','DISABLED','NORMAL','ABNORMAL']),'messageStatus')]};
 if(key==='mappings'||key==='exceptions')return {keywordPlaceholder:'来源应用 / 子系统账号 / 统一身份标识',keywordFields:['appName','externalAccount','userId'],filters:[filterDef('appName','来源应用','请选择来源应用',rowOptions('appName'),'appName'),filterDef('status','状态','请选择映射状态',fixedOptions(['BOUND','FAILED','CONFLICT','UNBOUND']),'status')]};
 if(logKind)return {keywordPlaceholder:'请求ID / 说明',keywordFields:['requestId','description','name'],filters:[filterDef('appName','来源应用','请选择来源应用',rowOptions('appName'),'appName'),filterDef('actor','操作人','请选择操作人',rowOptions('actor'),'actor'),filterDef('status','结果状态','请选择结果状态',fixedOptions(['SUCCESS','FAILURE','DENIED']),'status')]};
 return {keywordPlaceholder:'关键词',keywordFields:Object.keys(titles),filters:[]};
});
const queryFilters=computed(()=>querySpec.value.filters||[]);
const filtered=computed(()=>{
 const term=search.value.trim().toLowerCase();
 const keywordFields=querySpec.value.keywordFields||[];
 return rows.value.filter(row=>{
  const matchesFilters=queryFilters.value.every(filter=>{const selected=filterValues[filter.key];return !selected||String(row[filter.key]??'')===String(selected);});
  const matchesKeyword=!term||keywordFields.some(key=>display(key,row[key]).toLowerCase().includes(term));
  return matchesFilters&&matchesKeyword;
 }).sort((a,b)=>'sortOrder'in a?(a.sortOrder||0)-(b.sortOrder||0):(Date.parse(b.publishedAt||b.createdAt)||0)-(Date.parse(a.publishedAt||a.createdAt)||0));
});
const paged=computed(()=>filtered.value.slice((page.value-1)*pageSize.value,page.value*pageSize.value));
watch([search,()=>JSON.stringify(filterValues),pageSize,appPageSize],()=>{page.value=1;appPages.mine=1;appPages.other=1;});
watch(()=>filtered.value.length,()=>{page.value=Math.min(page.value,Math.max(1,Math.ceil(filtered.value.length/pageSize.value)));});
const appGroups=computed(()=>['mine','other'].map(key=>{const entries=filtered.value.filter(row=>mineIds.value.includes(row.id)===(key==='mine'));const current=Math.min(appPages[key],Math.max(1,Math.ceil(entries.length/appPageSize.value)));return {key,title:key==='mine'?'我的应用':'其它应用',page:current,total:entries.length,rows:entries.slice((current-1)*appPageSize.value,current*appPageSize.value)};}));
function setAppPage(key,value){appPages[key]=value;}
const fieldMap={apps:['name','code','category','userType','runtimeStatus','status'],myApplicationRequests:['requestNo','requestType','appName','status','submittedAt','reviewNote'],applicationRequests:['requestNo','userName','appName','reason','status','submittedAt'],accountOpeningRequests:['requestNo','userName','appName','reason','status','submittedAt','handleNote'],categories:['name','code','status'],users:['name','account','orgName','userType','roleLabels','status'],todos:['title','appName','status','createdAt'],messages:['title','appName','messageType','status','createdAt'],announcements:['title','type','scope','status','publishedAt'],identities:['name','orgName','userType','status'],identityMappings:['name','source','status'],mappings:['appName','userId','externalAccount','status'],exceptions:['appName','externalAccount','status'],roles:['roleCode','roleName','scopeLabels','status','description'],permissions:['code','name','description'],settings:['name','code','value','status'],monitor:['appName','appCode','ssoStatus','todoStatus','messageStatus','lastCheckedAt']};
const fields=computed(()=>fieldMap[listResource.value]||(resource.value.startsWith('logs:')?['name','actor','appName','description','status','createdAt']:['appName','kind','mode','status','remark']));
const primaryField=computed(()=>fields.value[0]);
const hasOperations=computed(()=>['apps','categories','users','roles','todos','messages','settings','mappings','exceptions','myApplicationRequests','applicationRequests','accountOpeningRequests'].includes(resource.value)||(resource.value==='announcements'&&admin.value));
const columnTitle=(key)=>{
 const resourceKey=listResource.value;
 const overrides={
  apps:{name:'应用名称',code:'应用编码',status:'启用状态'},
  categories:{status:'启用状态'},
  users:{name:'姓名',status:'启用状态'},
  identities:{status:'启用状态'},
  roles:{description:'描述',status:'启用状态'},
  permissions:{code:'权限编码',name:'权限名称'},
  monitor:{appName:'应用名称'}
 };
 if(overrides[resourceKey]?.[key])return overrides[resourceKey][key];
 if(key==='createdAt'&&['todos','messages'].includes(resourceKey))return '接收时间';
 return titles[key]||key;
};
const columnWidth=(key,index)=>{
 if(resource.value.startsWith('logs:')){
  if(key==='appName')return 260;
  if(key==='status')return 110;
 }
 if(index===0)return 250;
 if(['scopeLabels','roleLabels'].includes(key))return 280;
 if(key==='description')return 300;
 return 160;
};
const columns=computed(()=>[
 {colKey:'serial',title:'序号',width:64},
 ...fields.value.map((key,index)=>({colKey:index===0?'primary':key,title:columnTitle(key),width:columnWidth(key,index),ellipsis:true,cell:index===0||resource.value==='apps'&&key==='status'?undefined:(_,context)=>['status','runtimeStatus','ssoStatus','todoStatus','messageStatus'].includes(key)?h(Tag,{theme:resource.value==='monitor'&&context.row[key]==='ABNORMAL'?'warning':theme(context.row[key]),variant:'light'},()=>label(context.row[key])):display(key,context.row[key])})),
 ...(hasOperations.value?[{colKey:'operation',title:'操作',width:200,fixed:'right'}]:[])
]);
const createAction=computed(()=>({apps:'saveApp',categories:'saveCategory',announcements:'saveAnnouncement',roles:'saveSystemRole'})[resource.value]);
const createScope={apps:'application',categories:'application',announcements:'announcement',roles:'super'};
const canCreate=computed(()=>admin.value&&!!createAction.value&&can(actor.value,createScope[resource.value]));
const createLabel=computed(()=>({apps:'新增应用',categories:'新增分类',announcements:'新增公告',roles:'新增角色'})[resource.value]);
const formTitle=computed(()=>formAction.value==='saveAnnouncement'?(form.id?'编辑公告':'新增公告'):({saveApp:'应用信息',saveCategory:'系统分类',bind:'关联已有账号',savePortalUser:'编辑系统用户',saveSystemRole:'系统角色',saveConfig:'参数配置',saveIntegration:'接入配置',resolveMapping:'处理账号关联冲突',submitApplicationRequest:'申请使用应用',rejectApplicationRequest:'驳回应用访问申请',pushTodo:'录入来源待办',pushMessage:'录入来源消息'})[formAction.value]);
const opt=values=>values.map(value=>({value,label:label(value)}));
const formFields=computed(()=>{
 const f=(key,labelText,type='text',required=false,options=null,full=false)=>({key,label:labelText,type,required,options,full});
 const appOpts=allApps.value.map(item=>({value:item.id,label:text(item.name)}));
 const userOpts=availableUsers.value.map(item=>({value:item.id,label:text(item.name)}));
 const roleOpts=systemRoles.value.filter(item=>item.status==='ENABLED'||form.roleIds?.includes(item.id)).map(item=>({value:item.id,label:text(item.roleName)}));
 return ({
  saveApp:[f('name','应用名称','text',true),f('code','应用编码','text',true),f('category','系统分类','text',true,categories.value.map(item=>({value:item.name,label:text(item.name)}))),f('userType','适用用户','text',true,opt(['BOTH','CITIZEN','GOV'])),f('url','入口地址','text',true,null,true),f('sortOrder','显示排序','number'),f('description','说明','textarea',false,null,true)],
  saveCategory:[f('name','分类名称','text',true),f('code','分类编码','text',true),f('sortOrder','排序','number')],
  saveAnnouncement:[f('title','公告标题','text',true,null,true),f('type','公告类型'),f('scope','发布范围','text',true,opt(['ALL','CITIZEN','GOV'])),f('effectiveStart','生效时间','date'),f('effectiveEnd','失效时间','date')],
  bind:[f('externalAccount','已有子系统账号','text',true,null,true)],
  submitApplicationRequest:[f('reason','申请原因','textarea',true,null,true),f('contact','联系方式','text',false),f('remark','备注','textarea',false,null,true)],
  rejectApplicationRequest:[f('reviewNote','驳回原因','textarea',true,null,true)],
  savePortalUser:[f('status','启用状态'),f('roleIds','系统角色','text',false,roleOpts,true)],
  saveSystemRole:[f('roleCode','角色编码','text',true),f('roleName','角色名称','text',true),f('status','启用状态'),f('scopes','门户权限范围','text',true,Object.entries(scopes).map(([value,labelText])=>({value,label:labelText})),true),f('description','角色描述','textarea',false,null,true)],
  saveConfig:[f('value','配置值（使用当前参数标注单位）','number',true,null,true)],
  saveIntegration:[f('enabled','启用接入','text',true,opt(['ENABLED','DISABLED'])),...(form.kind==='SSO'?[f('protocol','协议','text',true,opt(['OIDC','SAML2','CUSTOM'])),f('clientId','Client ID'),f('authorizeUrl','授权地址'),f('tokenUrl','令牌地址'),f('callbackUrl','回调地址')]:[f('mode','接入方式','text',true,opt(['PUSH'])),f('fieldMapping','字段映射（JSON：标准字段→来源字段）','textarea',false,null,true)]),f('credentialRef','凭据环境变量名'),f('remark','接入说明','textarea',false,null,true)],resolveMapping:[f('reason','核验证据说明','textarea',true,null,true)],
  pushTodo:[f('appId','来源应用','text',true,appOpts),f('userId','接收人','text',true,userOpts),f('sourceTodoId','源事项ID','text',true),f('eventId','事件ID','text',true),f('sourceRevision','来源版本','number',true),f('status','源状态','text',true,opt(['PENDING','COMPLETED','WITHDRAWN','EXPIRED'])),f('title','待办标题','text',true,null,true)],
  pushMessage:[f('appId','来源应用','text',true,appOpts),f('userId','接收人','text',true,userOpts),f('sourceMessageId','源消息ID','text',true),f('eventId','事件ID','text',true),f('title','消息标题','text',true,null,true),f('content','消息内容','textarea',true,null,true)]
 })[formAction.value]||[];
});
const userFormIdentity=computed(()=>['name','account','orgName','userType'].map(key=>({key,label:titles[key],value:display(key,form[key])})).concat({key:'source',label:'身份来源',value:source(form)}));
function toDateTimeValue(value){const d=new Date(value);if(!Number.isFinite(d.getTime()))return String(value||'');const pad=n=>String(n).padStart(2,'0');return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;}
function openForm(action,row={}){
 Object.keys(form).forEach(key=>delete form[key]);
 const defaults={name:'',code:'',category:categories.value[0]?.name||'公众服务',userType:'BOTH',url:'',sortOrder:0,description:'',title:'',content:'',type:'通知',scope:'ALL',scopes:[],roleIds:[],roleCode:'',roleName:'',attachments:[],value:null,reason:'',contact:'',remark:'',reviewNote:'',appName:'',appId:allApps.value.find(app=>!rows.value.some(item=>item.appId===app.id))?.id||allApps.value[0]?.id,userId:actor.value.id,sourceRevision:1,status:'PENDING',eventId:crypto.randomUUID(),sourceTodoId:'',sourceMessageId:''};
 if(action==='savePortalUser')defaults.status='NORMAL';
 if(action==='saveSystemRole')defaults.status='ENABLED';
 Object.assign(form,defaults,JSON.parse(JSON.stringify(row)));
 if(action==='saveIntegration'){form.enabled=row.enabled||'DISABLED';form.protocol=['OIDC','SAML2','CUSTOM'].includes(row.protocol)?row.protocol:'OIDC';form.mode='PUSH';form.fieldMapping=JSON.stringify(row.fieldMapping||{},null,2);}
 for(const key of ['effectiveStart','effectiveEnd'])if(form[key])form[key]=toDateTimeValue(form[key]);
 formAction.value=action;formError.value='';bindFeedback.value=null;
 announcementUploadFiles.value=action==='saveAnnouncement'?(form.attachments||[]).map(file=>({name:file.name||'附件',url:file.data||'',status:'success',id:file.id||crypto.randomUUID(),originAttachment:JSON.parse(JSON.stringify(file))})):[];
 formVisible.value=true;
}
async function saveForm(){
 if(saving.value)return;
 const missing=formFields.value.find(field=>field.required&&(form[field.key]===null||form[field.key]===undefined||!String(form[field.key]).trim()));
 if(missing){formError.value='请填写'+missing.label;return;}
 if(formAction.value==='saveAnnouncement'&&!String(form.content||'').replace(/<[^>]*>/g,'').replace(/&nbsp;/gi,' ').trim()){formError.value='请填写正文';return;}
 saving.value=true;formError.value='';bindFeedback.value=null;
 try{
  let payload=JSON.parse(JSON.stringify(form));
  if(formAction.value==='saveAnnouncement')payload.attachments=await normalizeAnnouncementFiles(announcementUploadFiles.value);
  if(formAction.value==='savePortalUser')payload={id:form.id,version:form.version,status:form.status,roleIds:[...(form.roleIds||[])]};
  if(formAction.value==='bind')payload={appId:form.appId,externalAccount:form.externalAccount.trim()};
  if(formAction.value==='submitApplicationRequest')payload={appId:form.appId,reason:form.reason.trim(),contact:form.contact?.trim()||'',remark:form.remark?.trim()||''};
  if(formAction.value==='rejectApplicationRequest')payload={id:form.id,version:form.version,reviewNote:form.reviewNote.trim()};
  for(const key of ['effectiveStart','effectiveEnd'])if(payload[key])payload[key]=new Date(String(payload[key]).replace(' ','T')).toISOString();
  const result=await command(formAction.value,payload);
  if(!result.ok){formError.value=result.error.message;return;}
  if(formAction.value==='bind'){
   const state=result.data.status;
   bindFeedback.value={theme:state==='BOUND'?'success':state==='CONFLICT'?'warning':'error',message:state==='BOUND'?'账号关联已保存。':state==='CONFLICT'?'该账号存在关联冲突，请联系管理员核查。':'账号关联未通过，请核对账号后重试。'};
   return;
  }
  formVisible.value=false;
  const successText=formAction.value==='saveAnnouncement'?'公告草稿已保存，请在公告管理中发布':formAction.value==='submitApplicationRequest'?'申请已提交，可在“我的申请”查看进度':formAction.value==='rejectApplicationRequest'?'申请已驳回':'保存成功';
  MessagePlugin.success(successText);
 }catch(cause){formError.value=cause.message;}finally{saving.value=false;}
}
async function run(action,payload,show=false){
 try{const result=await command(action,payload);if(!result.ok){MessagePlugin.error(text(result.error.message));return;}if(show)DialogPlugin.alert({placement:'center',header:'应用访问',body:text(result.data.message),confirmBtn:'知道了'});else MessagePlugin.success('操作成功');return result;}catch(cause){MessagePlugin.error(text(cause.message));}
}
const enterApp=app=>run('enterApp',{id:app.id},true);
function openBinding(app){bindingApp.value=JSON.parse(JSON.stringify(app));bindingVisible.value=true;}
const bindApp=app=>openBinding(app);
const requestApp=app=>openForm('submitApplicationRequest',{appId:app.id,appName:app.name});
const viewApplicationRequest=()=>router.push('/portal/applications');
const viewBinding=app=>openBinding(app);
const viewConflict=app=>openBinding(app);
function handleBindingCompleted(){load();}
function viewBindingRequests(){router.push('/portal/applications');}
function bindByRequest(row){
 const app=allApps.value.find(item=>item.id===row.appId);
 if(!app){MessagePlugin.error('应用信息不存在，请刷新后重试');return;}
 openBinding(app);
}
function confirm(action,row,body){const dialog=DialogPlugin.confirm({placement:'center',header:'操作确认',body,onConfirm:async()=>{if(await run(action,{...row}))dialog.hide();}});}
async function showDetail(row,kind=listResource.value){
 if(kind==='announcements'){await router.push(`${admin.value?'/admin':'/portal'}/announcements/${encodeURIComponent(row.id)}`);return;}
 if(kind==='messages'){await router.push({path:'/portal/messages',query:{messageId:row.id}});return;}
 detail.value=JSON.parse(JSON.stringify(row));detailKind.value=kind;
 detailAccessProfile.value=kind==='apps'&&admin.value?JSON.parse(JSON.stringify(accessProfiles.value.find(item=>item.appId===row.id)||null)):null;
 detailVisible.value=true;
}
function closeDetail(visible){detailVisible.value=visible;if(!visible)detailAccessProfile.value=null;}
function backToAnnouncements(){router.push(admin.value?'/admin/announcements':'/portal/announcements');}
async function downloadAccessSpec(){try{await downloadAccessContract();MessagePlugin.success('接口文件已下载');}catch(cause){MessagePlugin.error(cause.message);}}
async function toggleAppStatus(row,enabled){const result=await command('setAppStatus',{id:row.id,version:row.version,status:enabled?'ENABLED':'DISABLED'});if(!result.ok){MessagePlugin.error(text(result.error.message));await load();return;}MessagePlugin.success(enabled?'应用已启用':'应用已停用');await load();}
async function openConnectionConfig(app){
 let profile=accessProfiles.value.find(item=>item.appId===app.id);
 if(!profile||['SSO','TODO','MESSAGE'].some(kind=>!profile.integrations[kind])){const created=await command('createAccessProfile',{appId:app.id});if(!created.ok){MessagePlugin.error(text(created.error.message));return;}profile=created.data;accessProfiles.value=[...accessProfiles.value.filter(item=>item.appId!==app.id),profile];}
 accessProfile.value=JSON.parse(JSON.stringify(profile));accessDialogVisible.value=true;
}
async function saveAccessIntegration({payload}){if(accessSaving.value)return;accessSaving.value=true;try{const result=await command('saveIntegration',payload);if(!result.ok){MessagePlugin.error(text(result.error.message));return;}MessagePlugin.success('接入配置已保存');const refreshed=await portal.read('access');if(refreshed.ok){accessProfiles.value=refreshed.data;const next=refreshed.data.find(item=>item.appId===accessProfile.value?.appId);if(next)accessProfile.value=JSON.parse(JSON.stringify(next));}}finally{accessSaving.value=false;}}
async function fileToDataUrl(file){return new Promise((resolve,reject)=>{const reader=new FileReader();reader.onload=()=>resolve(reader.result);reader.onerror=()=>reject(new Error('附件读取失败'));reader.readAsDataURL(file);});}
async function normalizeAnnouncementFiles(files){
 const list=[...(files||[])];
 if(list.length>5)throw new Error('附件最多5个');
 const result=[];
 for(const item of list){
  const original=item?.originAttachment||(form.attachments||[]).find(file=>file.id===item?.id||file.name===item?.name);
  if(original?.data){result.push(original);continue;}
  const raw=item?.raw||item?.rawFile||item?.file||((typeof File!=='undefined'&&item instanceof File)?item:null);
  const size=Number(raw?.size??item?.size??0);
  if(size>2*1024*1024)throw new Error('单个附件不能超过2MB');
  if(raw){
   const data=await fileToDataUrl(raw);
   result.push({id:item.id||'FILE_'+crypto.randomUUID(),name:raw.name||item.name||'附件',size:raw.size||size,type:raw.type||item.type||'',uploadedAt:new Date().toISOString(),data});
   continue;
  }
  if(item?.url?.startsWith('data:'))result.push({id:item.id||'FILE_'+crypto.randomUUID(),name:item.name||'附件',size,type:item.type||'',uploadedAt:new Date().toISOString(),data:item.url});
 }
 return result;
}

function download(file){if(!file.data?.startsWith('data:')){MessagePlugin.warning('附件内容不可用');return;}const link=document.createElement('a');link.href=file.data;link.download=file.name;link.click();}
</script>
