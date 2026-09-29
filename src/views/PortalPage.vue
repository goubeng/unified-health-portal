<template>
 <div class="portal-page">
  <Teleport v-if="admin&&resource==='apps'&&canCreate" to="#page-header-actions"><t-button variant="outline" theme="primary" @click="downloadAccessSpec"><template #icon><Icon name="download"/></template>下载接口文件</t-button><t-button theme="primary" @click="openForm('saveApp')"><template #icon><Icon name="add"/></template>新增应用</t-button></Teleport>
  <Teleport v-if="admin&&resource==='categories'&&canCreate" to="#page-header-actions"><t-button theme="primary" @click="openForm('saveCategory')"><template #icon><Icon name="add"/></template>新增分类</t-button></Teleport>
  <Teleport v-if="resource==='todos'" defer to="#page-header-extra"><span class="portal-title-count">（共<span class="portal-title-count-number">{{rows.length}}</span>条待办任务）</span></Teleport>
  <Teleport v-if="admin&&resource==='announcementDetail'&&detail" to="#page-header-actions">
   <t-button v-if="['DRAFT','SCHEDULED','PUBLISHED','WITHDRAWN'].includes(announcementViewStatus(detail))" theme="primary" @click="openAdminAnnouncementEdit(detail)">编辑</t-button>
   <t-button v-if="['DRAFT','WITHDRAWN','EXPIRED'].includes(announcementViewStatus(detail))" variant="outline" theme="danger" @click="removeAdminAnnouncementDetail(detail)">删除</t-button>
  </Teleport>
  <div v-if="error" role="alert" class="error-note">{{text(error)}} <t-button variant="text" theme="primary" @click="load">重试</t-button></div>
  <t-loading :loading="loading" :show-overlay="false" size="small">
   <div v-if="!pageReady" class="portal-loading-placeholder" aria-hidden="true"></div>
   <template v-else>
   <template v-if="isHome">
    <template v-if="admin">
     <div class="admin-overview-grid">
      <button v-for="card in adminOverviewCards" :key="card.label" type="button" class="admin-overview-card" @click="card.path&&router.push(card.path)">
       <span class="admin-overview-icon" :class="'tone-'+card.tone"><Icon :name="card.icon"/></span>
       <span class="admin-overview-content">
        <span class="admin-overview-label">
         <span>{{card.label}}</span>
         <t-tooltip :content="card.hint" placement="top">
          <span class="admin-overview-help" aria-label="查看统计说明" @click.stop><Icon name="help-circle"/></span>
         </t-tooltip>
        </span>
        <strong>{{card.value}}</strong>
       </span>
      </button>
     </div>

     <div class="admin-home-analysis-grid">
      <div class="admin-home-left-stack">
       <section class="panel admin-pending-panel">
        <div class="section-head"><h2>待处理事项</h2></div>
        <div class="admin-reminder-grid">
         <button v-for="item in adminPendingItems" :key="item.label" type="button" class="admin-reminder-card" @click="item.path&&router.push(item.path)">
          <span>{{item.label}}</span>
          <strong :class="{'is-danger':item.danger}">{{item.value}}</strong>
         </button>
        </div>
       </section>

       <section class="panel admin-work-panel">
        <div class="section-head"><h2>快捷入口</h2></div>
        <div class="admin-shortcut-grid">
         <button v-if="can(actor,'announcement:edit')" class="admin-shortcut-card" @click="router.push({path:'/admin/announcements',query:{action:'create'}})">
          <span class="admin-shortcut-icon tone-purple"><Icon name="notification"/></span>
          <strong>新增公告</strong>
         </button>
         <button v-for="item in adminShortcuts" :key="item.id" class="admin-shortcut-card" @click="item.resource==='apps'?openForm('saveApp'):router.push(item.path)">
          <span class="admin-shortcut-icon" :class="'tone-'+adminShortcutTone(item.resource)"><Icon :name="adminShortcutIcon(item.resource)"/></span>
          <strong>{{item.resource==='apps'?'新增应用':text(item.title)}}</strong>
         </button>
        </div>
       </section>
      </div>

      <section class="panel admin-runtime-analysis-panel">
       <div class="section-head"><h2>接入运行分析</h2><router-link v-if="can(actor,'monitor:view')" to="/admin/monitor">查看运行监控</router-link></div>
       <div v-if="overview.serviceHealth" class="admin-runtime-capability-grid">
        <div v-for="kind in ['SSO','TODO','MESSAGE']" :key="kind" class="admin-runtime-capability-card">
         <strong>{{kind}}</strong>
         <div class="admin-runtime-capability-stats">
          <span class="is-normal"><em>正常</em><b>{{overview.serviceHealth[kind]?.normal??0}}</b></span>
          <span class="is-abnormal"><em>异常</em><b>{{overview.serviceHealth[kind]?.abnormal??0}}</b></span>
          <span class="is-muted"><em>未配置/停用</em><b>{{overview.serviceHealth[kind]?.unconfigured??0}}</b></span>
         </div>
        </div>
       </div>

       <div class="admin-runtime-exception-head">
        <h3>接入异常 <span class="admin-runtime-exception-count">（<strong>{{homeExceptions.length}}</strong>）</span></h3>
        <router-link v-if="can(actor,'monitor:view')" to="/admin/monitor">查看全部</router-link>
       </div>
       <div class="admin-runtime-exception-list">
        <div v-for="item in latest(homeExceptions,'lastCheckedAt').slice(0,5)" :key="item.id" class="list-row">
         <div>
          <button class="portal-field-link" @click="showDetail(item,'monitorException')">{{text(item.appName||item.name)}}</button>
          <p class="admin-runtime-exception-meta"><t-tag class="admin-runtime-kind-tag" theme="default" variant="light" size="small">{{label(item.kind)}}</t-tag><span>{{text(item.remark)||label(item.status)}}</span></p>
         </div>
         <t-tag :theme="theme(item.status)" variant="light">{{label(item.status)}}</t-tag>
        </div>
        <EmptyState v-if="!homeExceptions.length" :description="can(actor,'monitor:view')?'暂无接入异常':'当前权限范围暂无接入异常'"/>
       </div>
      </section>
     </div>

     <div v-if="can(actor,'audit:view')" class="admin-home-trend-grid">
      <AdminTrendChart title="近7日门户访问量趋势" :rows="homeAccessLogs" series-name="访问次数"/>
      <AdminTrendChart title="近7日接口调用量趋势" :rows="homeApiLogs" series-name="调用次数"/>
     </div>

    </template>
    <template v-else>
     <div class="portal-home-feeds">
      <section class="panel"><div class="section-head"><h2>我的待办 <t-tag class="portal-count-tag" theme="danger" variant="light" size="small">{{overview.todoCount??0}}</t-tag></h2><router-link to="/portal/todos">全部待办</router-link></div><div v-for="item in homeTodos" :key="item.id" class="list-row"><div><button class="portal-field-link" @click="showDetail(item,'todos')">{{text(item.title)}}</button><p>{{text(item.appName)}} · {{date(item.receivedAt)}}</p></div><t-button size="small" variant="text" theme="primary" @click="run('openTodo',{id:item.id},true)">去处理</t-button></div><EmptyState v-if="!homeTodos.length" description="暂无待办"/></section>
      <section class="panel"><div class="section-head"><h2>通知公告 <t-tag class="portal-count-tag" theme="danger" variant="light" size="small">{{overview.unreadAnnouncementCount??0}}</t-tag></h2><router-link to="/portal/announcements">全部公告</router-link></div><div v-for="item in homeAnnouncements" :key="item.id" class="list-row"><div><button class="portal-field-link" :class="{'is-unread':item.readStatus==='UNREAD'}" @click="showDetail(item,'announcements')">{{text(item.title)}}</button><p>{{date(item.publishedAt)}}</p></div></div><EmptyState v-if="!homeAnnouncements.length" description="暂无公告"/></section>
      <section class="panel"><div class="section-head"><h2>消息 <t-tag class="portal-count-tag" theme="danger" variant="light" size="small">{{overview.unreadCount??0}}</t-tag></h2><router-link to="/portal/messages">全部消息</router-link></div><div v-for="item in homeMessages" :key="item.id" class="list-row"><div><button class="portal-field-link" :class="{'is-unread':item.status==='UNREAD'}" @click="showDetail(item,'messages')">{{text(item.title)}}</button><p>{{text(item.appName)}} · {{date(item.receivedAt)}}</p></div></div><EmptyState v-if="!homeMessages.length" description="暂无未读消息"/></section>
     </div>
     <section class="panel portal-home-apps"><div class="section-head"><h2>我的应用<span class="portal-section-count">（<span class="portal-section-count-number">{{homeAppCount}}</span>）</span></h2><router-link v-if="homeAppCount>homeAppLimit" to="/portal/apps/all">更多</router-link></div><AppCards :apps="homeVisibleApps" compact hide-normal-state @detail="showDetail($event,'apps')" @enter="enterApp" @bind="bindApp" @request="requestApp" @view-request="viewApplicationRequest" @view-binding="viewBinding" @view-conflict="viewConflict"/></section>
    </template>
   </template>
   <IdentityMappings v-else-if="resource==='identityOverview'" :key="route.fullPath" :rows="rows" :can-manage="can(actor,'identity:review')" :exceptions-only="route.query.mapping==='exception'" @unbind="confirm('unbind',$event,'确认解除此账号关联？不会修改子系统账号或授权。')" @resolve="openForm('resolveMapping',$event)" @approve="confirm('approveBindingReview',$event,'确认通过此高权限账号关联？通过后用户可从门户进入该应用。')" @reject="openForm('rejectBindingReview',$event)"/>
   <TodoCenter v-else-if="resource==='todos'" :rows="rows"/>
   <MessageCenter v-else-if="resource==='messages'" :rows="rows" :receiver="actor?.name"/>
   <RulesSettings v-else-if="resource==='settings'" :rows="rows" @saved="load"/>
   <PersonalProfile v-else-if="resource==='profile'" :user="actor"/>
   <UserManagement v-else-if="resource==='users'" :rows="rows" :roles="systemRoles" :organizations="organizations" :access-users="availableUsers" :can-super="can(actor,'system:super')" @saved="load"/>
   <RoleManagement v-else-if="resource==='roles'" :rows="rows" @saved="load"/>
   <OrganizationManagement v-else-if="resource==='organizations'" :rows="rows" :type-items="dictItems" :can-super="can(actor,'system:super')" @saved="load"/>
   <DictionaryManagement v-else-if="resource==='dictionaries'" :types="dictTypes" :items="dictItems" @saved="load"/>
   <AnnouncementManagement v-else-if="resource==='announcements'&&admin" :rows="rows" :type-items="dictItems" @saved="load" @detail="openAdminAnnouncementDetail"/>
   <MonitorManagement v-else-if="resource==='monitor'" :rows="rows"/>
   <LogManagement v-else-if="resource.startsWith('logs:')" :rows="rows" :kind="resource.split(':')[1]" @saved="load"/>
   <MyApplications v-else-if="resource==='myApplicationRequests'" :rows="rows" @withdraw="confirm('withdrawApplicationRequest',$event,'确认撤回此应用访问申请？')" @reapply="openForm('submitApplicationRequest',{appId:$event.appId,appName:$event.appName})" @bind="bindByRequest" @enter="enterAppByRequest" @detail="showDetail($event,'myApplicationRequests')"/>
   <template v-else-if="resource==='announcementDetail'">
    <Teleport v-if="preview&&detail" to="#page-header-current-title">
      <span>{{ text(detail.title)||'公告详情' }}</span>
    </Teleport>
    <AnnouncementDetail v-if="detail" :record="detail" @download="download"/>
    <section v-else class="panel"><EmptyState description="公告不存在或暂无查看权限"/></section>
    <AnnouncementEditPage
      v-if="admin&&detail"
      v-model:visible="announcementEditVisible"
      :record="detail"
      :type-items="dictItems"
      @saved="handleAdminAnnouncementSaved"
    />
   </template>
   <section v-else-if="resource==='external'" class="panel"><div class="empty-conditional"><t-tag theme="warning" variant="light">尚未启用</t-tag><h2>公共服务接入</h2><p>通过闽政通、闽政务提供二维码、手机验证码等公共服务。服务开通后，可按授权范围使用。</p><router-link to="/admin/monitor">查看接入状态</router-link></div></section>
   <section v-else class="portal-list" :class="{'portal-app-center':isAppCenter,'portal-announcement-center':preview&&resource==='announcements'}">
    <div v-if="admin&&resource==='apps'" class="app-user-stats-grid">
     <section v-for="item in appUserTypeStats" :key="item.userType" class="app-user-stat-card">
      <span class="app-user-stat-icon" :class="'tone-'+item.tone"><Icon :name="item.icon"/></span>
      <span class="app-user-stat-content">
       <span class="app-user-stat-label">{{item.label}}</span>
       <span class="app-user-stat-value"><strong>{{item.count}}</strong><small>个应用</small></span>
      </span>
     </section>
    </div>
    <t-form layout="inline" class="portal-query list-toolbar">
     <t-form-item class="portal-query-keyword query-width-keyword" :label="querySpec.keywordLabel||'关键词'"><t-input v-model="search" :placeholder="querySpec.keywordPlaceholder" clearable/></t-form-item>
     <t-form-item v-for="filter in queryFilters" :key="filter.key" class="portal-query-select" :class="queryWidthClass(filter.widthKey||filter.key)" :label="filter.label"><t-select v-model="filterValues[filter.key]" clearable :filterable="filter.searchable===true" :placeholder="filter.placeholder" :options="filter.options"/></t-form-item>
     <t-form-item class="portal-query-action"><t-button class="query-reset-button" theme="default" variant="outline" @click="resetQuery">重置</t-button></t-form-item>
    </t-form>
    <template v-if="isAppCenter">
     <section v-for="group in appGroups" :key="group.key" class="panel portal-app-section"><div class="section-head"><h2>{{group.title}}<span class="portal-section-count">（<span class="portal-section-count-number">{{group.total}}</span>）</span></h2></div><AppCards :apps="group.rows" action-row :hide-normal-state="group.key==='mine'" @detail="showDetail($event,'apps')" @enter="enterApp" @bind="bindApp" @request="requestApp" @view-request="viewApplicationRequest" @view-binding="viewBinding" @view-conflict="viewConflict"/><t-pagination v-if="group.total" :current="group.page" :page-size="group.pageSize" :total="group.total" :page-size-options="[10,20,50]" show-jumper @current-change="setAppPage(group.key,$event)" @page-size-change="setAppPageSize(group.key,$event)"/></section>
    </template>
    <section v-else-if="preview&&resource==='announcements'" class="panel public-announcement-list">
     <article v-for="row in paged" :key="row.id" class="public-announcement-item">
      <span class="public-record-dot" :class="{muted:row.readStatus!=='UNREAD'}"></span>
      <button type="button" class="public-record-main" @click="showDetail(row,'announcements')">
       <strong>{{text(row.title)||'-'}}</strong>
       <small class="public-announcement-meta">
        <t-tag class="public-announcement-meta-tag" size="small" variant="light" theme="primary">{{label(row.type)||'-'}}</t-tag>
        <t-tag class="public-announcement-meta-tag scope" size="small" variant="light" theme="default">{{label(row.scope,'announcement_scope')}}</t-tag>
        <span class="public-announcement-date">{{date(row.publishedAt)}}</span>
       </small>
      </button>
      <span class="public-announcement-read-state">{{label(row.readStatus,'message_read_status')}}</span>
     </article>
     <EmptyState v-if="!paged.length" description="暂无符合条件的公告"/>
     <t-pagination v-if="filtered.length" v-model="page" v-model:page-size="pageSize" :total="filtered.length" :page-size-options="[10,20,50]" show-jumper/>
    </section>
    <section v-else class="panel portal-table-panel">
     <t-table row-key="id" :data="paged" :columns="columns" :sort="tableSort||undefined" hover table-layout="fixed" size="medium" @sort-change="handleTableSortChange">
      <template #empty><EmptyState description="暂无符合条件的记录"/></template>
      <template #serial="{rowIndex}">{{(page-1)*pageSize+rowIndex+1}}</template>
      <template #primary="{row}"><TableCellTooltip :text="text(row[primaryField])||'-'"><button class="portal-field-link" :class="{'is-unread':row.status==='UNREAD'||row.readStatus==='UNREAD'}" @click="showDetail(row)">{{text(row[primaryField])||'-'}}</button></TableCellTooltip></template>
      <template v-if="resource==='apps'" #enabled="{row}"><t-switch :value="row.enabled!==false" @change="toggleAppStatus(row,$event)"/></template>
      <template #operation="{row}"><div class="row-actions" :class="{'app-list-row-actions':resource==='apps'&&admin}">
       <template v-if="resource==='apps'&&admin&&can(actor,'application:edit')"><t-button size="small" variant="text" theme="primary" @click="openForm('saveApp',row)">编辑</t-button><t-button size="small" variant="text" theme="primary" @click="openConnectionConfig(row)">连接配置</t-button><t-button size="small" variant="text" theme="danger" @click="confirm('removeApp',row,'确认删除该应用？删除后将同步清理该应用的连接配置、账号映射、申请、待办、消息等关联演示数据，且不可恢复。')">删除</t-button></template>
       <template v-if="resource==='categories'"><t-button size="small" variant="text" theme="primary" @click="openForm('saveCategory',row)">编辑</t-button><t-button size="small" variant="text" theme="danger" @click="confirm('removeCategory',row,'确认删除未被应用引用的分类？')">删除</t-button></template>
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
       <template v-if="resource==='accountOpeningRequests'&&['PENDING','PROCESSING'].includes(row.status)"><t-button size="small" variant="text" theme="primary" @click="confirm('completeMockAccountOpeningRequest',row,'确认目标子系统已完成账号开通？此操作仅更新门户侧处理状态。')">标记已开通</t-button></template>
      </div></template>
     </t-table>
     <t-pagination v-if="filtered.length" v-model="page" v-model:page-size="pageSize" :total="filtered.length" :page-size-options="[10,20,50]" show-jumper/>
    </section>
   </section>
   </template>
  </t-loading>
  <t-dialog v-model:visible="formVisible" placement="center" :header="formTitle" :width="formAction==='saveAnnouncement'?'min(1180px, calc(100vw - 48px))':formAction==='saveApp'?'min(1080px, calc(100vw - 48px))':'720px'" :confirm-btn="{content:formAction==='bind'?'核验并关联':formAction==='submitApplicationRequest'?'提交申请':formAction==='rejectApplicationRequest'?'确认驳回':'保存',loading:saving,disabled:saving}" :close-on-overlay-click="false" @confirm="saveForm">
   <p v-if="formAction==='bind'" class="inline-note">当前应用已在此账号的可见范围内。请输入已开通的子系统账号，提交后查看关联结果。</p>
   <p v-if="formAction==='submitApplicationRequest'" class="inline-note">申请应用：{{text(form.appName)}}。申请通过后，如目标系统还需要完成账号确认，门户会提示下一步操作。</p>
   <p v-if="formAction==='rejectApplicationRequest'" class="inline-note">请填写驳回原因。驳回后用户可在“我的申请”中查看并重新申请。</p>
   <p v-if="formAction==='saveIntegration'" class="inline-note">待办和消息采用PUSH方式接收。凭据填写服务端环境变量名，不填写密钥。SSO参数可维护，认证适配器尚未接入。</p>
   <div v-if="formError" role="alert" class="error-note">{{text(formError)}}</div><t-alert v-if="bindFeedback" :theme="bindFeedback.theme" :message="bindFeedback.message" class="portal-bind-feedback"/>
   <div class="form-grid" :class="{'app-form-grid':formAction==='saveApp'}"><div v-for="field in formFields" :key="field.key" class="form-field" :class="{full:field.full}"><label>{{field.label}}<span v-if="field.required" class="portal-required"> *</span></label><t-select v-if="field.options" v-model="form[field.key]" :options="field.options" :disabled="field.key==='enabled'&&formAction==='saveApp'&&!can(actor,'application:enable')"/><t-textarea v-else-if="field.type==='textarea'" v-model="form[field.key]" :autosize="{minRows:4,maxRows:8}"/><t-date-picker v-else-if="field.type==='date'" v-model="form[field.key]" enable-time-picker clearable format="YYYY-MM-DD HH:mm:ss" value-type="YYYY-MM-DD HH:mm:ss" placeholder="请选择日期时间"/><t-input-number v-else-if="field.type==='number'" v-model="form[field.key]" :decimal-places="0"/><t-input v-else v-model="form[field.key]" :maxlength="300"/></div></div>
   <AnnouncementEditor v-if="formAction==='saveAnnouncement'" v-model="form.content" v-model:files="announcementUploadFiles"/>
  </t-dialog>
  <t-dialog v-model:visible="accessDialogVisible" placement="center" :header="accessDialogTitle" width="1180px" :close-on-overlay-click="false">
   <AccessConfigDetail ref="accessConfigRef" :profile="accessProfile" @save="saveAccessIntegration"/>
   <template #footer><t-button theme="primary" :loading="accessSaving" :disabled="accessSaving" @click="accessConfigRef?.saveActive()">保存配置</t-button></template>
  </t-dialog>
  <AccountBindingWizard v-model:visible="bindingVisible" :app="bindingApp" @completed="handleBindingCompleted" @view-request="viewBindingRequests"/>
  <RecordDetail :visible="detailVisible" :record="detail" :kind="detailKind" :receiver="actor?.name" :access-profile="detailAccessProfile" :show-connection="admin&&detailKind==='apps'" @update:visible="closeDetail" @download="download"/>
 </div>
</template>

<script setup>
import {createUUID} from '../utils/uuid.js';
import EmptyState from '../components/portal/EmptyState.vue';
import TableCellTooltip from '../components/portal/TableCellTooltip.vue';
import {computed,h,reactive,ref,watch} from 'vue';
import {useRoute,useRouter} from 'vue-router';
import {MessagePlugin,DialogPlugin,Tag} from 'tdesign-vue-next';
import {Icon} from 'tdesign-icons-vue-next';
import {actor,portal,command,revision,availableUsers,downloadAccessContract,loadDictionaryLookups,dictionaryLookups} from '../services/runtime.js';
import {pages,can,shouldLoadAppCatalog} from '../config/pages.js';
import RulesSettings from '../components/portal/RulesSettings.vue';
import MessageCenter from '../components/portal/MessageCenter.vue';
import TodoCenter from '../components/portal/TodoCenter.vue';
import IdentityMappings from '../components/portal/IdentityMappings.vue';
import AccessConfigDetail from '../components/portal/AccessConfigDetail.vue';
import AppCards from '../components/portal/AppCards.vue';
import AccountBindingWizard from '../components/portal/AccountBindingWizard.vue';
import MyApplications from '../components/portal/MyApplications.vue';
import UserManagement from '../components/portal/UserManagement.vue';
import RoleManagement from '../components/portal/RoleManagement.vue';
import OrganizationManagement from '../components/portal/OrganizationManagement.vue';
import DictionaryManagement from '../components/portal/DictionaryManagement.vue';
import AnnouncementManagement from '../components/portal/AnnouncementManagement.vue';
import AnnouncementEditPage from '../components/portal/AnnouncementEditPage.vue';
import MonitorManagement from '../components/portal/MonitorManagement.vue';
import LogManagement from '../components/portal/LogManagement.vue';
import AdminTrendChart from '../components/portal/AdminTrendChart.vue';
import DetailGrid from '../components/portal/DetailGrid.vue';
import PersonalProfile from '../components/portal/PersonalProfile.vue';
import RecordDetail from '../components/portal/RecordDetail.vue';
import AnnouncementEditor from '../components/portal/AnnouncementEditor.vue';
import AnnouncementDetail from '../components/portal/AnnouncementDetail.vue';
import {text,label,date,source,theme,latest,titles,display,dictionaryOptions,dictionaryTypeFor} from '../components/portal/presentation.js';

const route=useRoute(),router=useRouter();
const resource=computed(()=>route.meta.resource||''),admin=computed(()=>route.path.startsWith('/admin'));
const previewRoute=computed(()=>route.path.startsWith('/portal-preview'));
const preview=computed(()=>previewRoute.value||route.path.startsWith('/portal/'));
const portalPath=path=>(previewRoute.value?'/portal-preview':'/portal')+path;
const isHome=computed(()=>['home','adminHome'].includes(resource.value));
const isAppCenter=computed(()=>!admin.value&&['apps','mine'].includes(resource.value));
const listResource=computed(()=>resource.value==='announcementDetail'?'announcements':resource.value);
const rows=ref([]),overview=ref({}),allApps=ref([]),categories=ref([]),systemRoles=ref([]),organizations=ref([]),dictTypes=ref([]),dictItems=ref([]),mineIds=ref([]),accessProfiles=ref([]);
const homeApps=ref([]),homeTodos=ref([]),homeMessages=ref([]),homeAnnouncements=ref([]),homeExceptions=ref([]),homeAccessLogs=ref([]),homeApiLogs=ref([]);
const homeAppLimit=10;
const homeAppCount=computed(()=>homeApps.value.length);
const homeVisibleApps=computed(()=>homeApps.value.slice(0,homeAppLimit));
const error=ref(''),loading=ref(true),pageReady=ref(false),search=ref(''),filterValues=reactive({}),page=ref(1),pageSize=ref(10),tableSort=ref(null);
const appPageSizes=reactive({mine:20,other:20}),appPages=reactive({mine:1,other:1});
const formVisible=ref(false),formAction=ref(''),form=reactive({}),formError=ref(''),saving=ref(false),bindFeedback=ref(null),announcementUploadFiles=ref([]);
const detailVisible=ref(false),detail=ref(null),detailKind=ref(''),detailAccessProfile=ref(null);
const announcementEditVisible=ref(false);
const accessDialogVisible=ref(false),accessProfile=ref(null),accessSaving=ref(false),accessConfigRef=ref(null);
const bindingVisible=ref(false),bindingApp=ref(null);
const accessDialogTitle=computed(()=>accessProfile.value?`${text(accessProfile.value.appName)}-连接配置`:'连接配置');
const announcementViewStatus=row=>row?.displayStatus||row?.status||'DRAFT';
const adminShortcuts=computed(()=>pages.filter(item=>['PG-202','PG-228','PG-205'].includes(item.id)&&can(actor.value,item.scope)&&(item.resource!=='apps'||can(actor.value,'application:edit'))));
const adminOverviewCards=computed(()=>[
 {label:'纳管应用',value:overview.value.appCount??0,icon:'app',tone:'blue',hint:'当前门户应用目录中已纳管的全部应用数量，包含启用和停用应用。',path:can(actor.value,'application:view')?'/admin/apps':''},
 {label:'启用应用',value:overview.value.enabledCount??0,icon:'check-circle',tone:'green',hint:'当前处于启用状态的纳管应用数量。',path:can(actor.value,'application:view')?'/admin/apps':''},
 {label:'接入异常应用',value:overview.value.abnormalApplicationCount??0,icon:'error-circle',tone:'red',hint:'当前应用列表中“综合运行状态”为异常的应用数量；同一应用仅计一次。',path:can(actor.value,'monitor:view')?'/admin/monitor':''},
 {label:'有效用户',value:overview.value.enabledUserCount??0,icon:'user',tone:'cyan',hint:'公众用户和政务用户中，当前未停用且允许访问门户的用户数量。',path:can(actor.value,'identity:view')?'/admin/identities':''},
 {label:'接口调用量(今日)',value:overview.value.todayApiCallCount??0,icon:'code',tone:'indigo',hint:'按北京时间当天统计的接口调用日志数量，包含成功和失败的接口调用。',path:can(actor.value,'audit:view')?'/admin/logs/api':''},
 {label:'今日访问量',value:overview.value.todayAccessCount??0,icon:'browse',tone:'teal',hint:'按北京时间当天统计的门户访问类日志数量，每次访问行为计 1 次，不按用户去重。',path:can(actor.value,'audit:view')?'/admin/logs/access':''}
]);
const adminShortcutIcon=resource=>({apps:'add',users:'user',identityOverview:'link'}[resource]||'file');
const adminShortcutTone=resource=>({apps:'blue',users:'green',identityOverview:'cyan'}[resource]||'gray');
const adminPendingItems=computed(()=>[
 {label:'应用访问申请',value:overview.value.pendingAccessCount??0,hint:'待审核入口资格',path:can(actor.value,'application:view')?'/admin/application-requests':'',danger:(overview.value.pendingAccessCount??0)>0},
 {label:'账号开通申请',value:overview.value.pendingAccountOpeningCount??0,hint:'待子系统处理',path:can(actor.value,'application:view')?'/admin/account-opening-requests':'',danger:(overview.value.pendingAccountOpeningCount??0)>0},
 {label:'账号确认审核',value:overview.value.pendingBindingReviewCount??0,hint:'高风险账号待审核',path:can(actor.value,'identity:view')?'/admin/identities':'',danger:(overview.value.pendingBindingReviewCount??0)>0},
 {label:'映射异常',value:overview.value.mappingExceptionCount??0,hint:'冲突/失败映射',path:can(actor.value,'identity:view')?'/admin/identities?mapping=exception':'',danger:(overview.value.mappingExceptionCount??0)>0},
 {label:'异常日志',value:overview.value.openErrorCount??0,hint:'待处理异常日志',path:can(actor.value,'audit:view')?'/admin/logs/error':'',danger:(overview.value.openErrorCount??0)>0},
 {label:'待发布公告',value:overview.value.scheduledAnnouncementCount??0,hint:'等待定时发布',path:can(actor.value,'announcement:view')?'/admin/announcements':'',danger:false}
 ]);
let loadVersion=0;
async function read(key){const result=await portal.read(key);if(!result.ok)throw new Error(result.error.message);return result.data;}
async function load(){
 const version=++loadVersion;loading.value=true;error.value='';
 try{
  const key=resource.value,home=isHome.value,center=isAppCenter.value,isAdmin=admin.value;
  const tasks={};
  loadDictionaryLookups();
  const needsAppCatalog=isAdmin?shouldLoadAppCatalog(true,actor.value):(center||key==='myApplicationRequests');
  if(needsAppCatalog)tasks.apps=read(isAdmin?'adminApps':'apps');
  if(can(actor.value,'application:view'))tasks.categories=read('categories');
  if(isAdmin&&key==='apps'&&can(actor.value,'integration:view'))tasks.accessProfiles=read('access');
  if(home){
   tasks.overview=read(key);
   if(!isAdmin){for(const name of ['mine','todos','messages','announcements'])tasks[name]=read(name);}
   if(isAdmin&&can(actor.value,'monitor:view'))tasks.monitor=read('monitor');
   if(isAdmin&&can(actor.value,'audit:view')){
    tasks.accessLogs=read('logs:access');
    tasks.apiLogs=read('logs:api');
   }
  }else if(center)tasks.mine=read('mine');
  else if(key==='apps'&&isAdmin){tasks.rows=tasks.apps;}
  else if(key==='users'){
   tasks.rows=read('users');
   if(can(actor.value,'role:view'))tasks.systemRoles=read('roles');
   if(can(actor.value,'organization:view'))tasks.organizations=read('organizations');
  }
  else if(key==='organizations'){
   tasks.rows=read('organizations');
   if(can(actor.value,'dictionary:view'))tasks.dictionaryData=read('dictionaries');
  }
  else if(key==='dictionaries'){tasks.dictionaryData=read('dictionaries');}
  else if(key==='announcements'&&isAdmin){tasks.rows=read('adminAnnouncements');if(can(actor.value,'dictionary:view'))tasks.dictionaryData=read('dictionaries');}
  else if(key==='announcementDetail'){
   tasks.rows=read(isAdmin?'adminAnnouncements':'announcements');
   if(isAdmin&&can(actor.value,'dictionary:view'))tasks.dictionaryData=read('dictionaries');
  }
  else if(!['profile','external'].includes(key))tasks.rows=read(key==='announcements'&&isAdmin?'adminAnnouncements':key);
  const entries=await Promise.all(Object.entries(tasks).map(async([name,promise])=>[name,await promise]));
  if(version!==loadVersion)return;
  const data=Object.fromEntries(entries);allApps.value=data.apps||[];categories.value=data.categories||[];accessProfiles.value=data.accessProfiles||accessProfiles.value;systemRoles.value=data.systemRoles||(key==='roles'?data.rows:[])||[];organizations.value=data.organizations||organizations.value;dictTypes.value=data.dictionaryData?.types||[];dictItems.value=data.dictionaryData?.items||[];
  if(home){
   overview.value=data.overview;
   homeApps.value=(data.mine||[]).slice().sort((a,b)=>(a.sortOrder||0)-(b.sortOrder||0));
   homeTodos.value=latest((data.todos||[]).filter(item=>item.status==='PENDING'));
   homeMessages.value=latest((data.messages||[]).filter(item=>item.status==='UNREAD'),'receivedAt');homeAnnouncements.value=latest(data.announcements||[],'publishedAt');
   const monitorExceptions=(data.monitor||[]).flatMap(item=>['SSO','TODO','MESSAGE'].filter(kind=>item.services?.[kind]?.runtimeStatus==='ABNORMAL').map(kind=>({...item,id:`${item.id||item.appId||item.appCode}-${kind}`,kind,status:'ABNORMAL',remark:text(item.services?.[kind]?.lastError)||'运行异常'})));homeExceptions.value=monitorExceptions;
   homeAccessLogs.value=data.accessLogs||[];
   homeApiLogs.value=data.apiLogs||[];
  }
  mineIds.value=(data.mine||[]).map(item=>item.id);rows.value=center?data.apps||[]:(key==='dictionaries'?[]:data.rows||[]);
  if(key==='announcementDetail'){
   const article=rows.value.find(item=>item.id===route.params.id);
   if(!article){detail.value=null;error.value='公告不存在或不在当前用户的可见范围';}
   else{detail.value=JSON.parse(JSON.stringify(article));detailKind.value='announcements';if(!isAdmin&&article.readStatus==='UNREAD'){const marked=await command('markAnnouncementRead',{id:article.id});if(marked.ok)detail.value.readStatus='READ';}}
  }
  if(version===loadVersion&&!error.value)pageReady.value=true;
 }catch(cause){if(version===loadVersion)error.value=cause.message;}
 finally{if(version===loadVersion)loading.value=false;}
}
function resetQuery(){
 search.value='';
 for(const key of Object.keys(filterValues))delete filterValues[key];
 tableSort.value=['applicationRequests','accountOpeningRequests'].includes(listResource.value)?{sortBy:'submittedAt',descending:true}:null;
 page.value=1;appPages.mine=1;appPages.other=1;
}
watch(()=>preview.value?route.path:route.fullPath,()=>{pageReady.value=false;resetQuery();detailVisible.value=false;formVisible.value=false;announcementEditVisible.value=false;accessDialogVisible.value=false;bindingVisible.value=false;bindingApp.value=null;load();},{immediate:true});
watch(revision,load);
const queryWidthClass=key=>({
 category:'query-width-category',
 userType:'query-width-user-type',
 messageType:'query-width-message-type',
 businessType:'query-width-kind',
 scope:'query-width-scope',
 appName:'query-width-source',
 actor:'query-width-actor',
 orgName:'query-width-org',
 kind:'query-width-kind',
 type:'query-width-kind',
 mode:'query-width-mode',
 status:'query-width-status',
 runtimeStatus:'query-width-runtime-status',
 aggregateRuntimeStatus:'query-width-runtime-status',
 readStatus:'query-width-status',
 ssoStatus:'query-width-sso-status',
 todoStatus:'query-width-todo-status',
 messageStatus:'query-width-message-status'
}[key]||'query-width-default');
const fixedOptions=(values,typeCode)=>typeCode?dictionaryOptions(typeCode,values):values.map(value=>({value,label:label(value)}));
const myRequestStatusOptions=()=>[...new Map([
 ...dictionaryOptions('application_request_status',['PENDING','APPROVED','REJECTED','WITHDRAWN']),
 ...dictionaryOptions('account_opening_status',['PROCESSING','COMPLETED'])
].map(item=>[item.value,item])).values()];
const rowOptions=(field,useLabel=false)=>[...new Set(rows.value.map(row=>row[field]).filter(value=>value!==null&&value!==undefined&&String(value)!==''))].map(value=>({value,label:useLabel?label(value):text(value)}));
const filterDef=(key,labelText,placeholder,options,widthKey=key)=>({key,label:labelText,placeholder:'全部',options,widthKey,searchable:key==='appName'});
const querySpec=computed(()=>{
 const key=listResource.value;
 const logKind=resource.value.startsWith('logs:')?resource.value.split(':')[1]:'';
 if(key==='apps'||key==='mine')return {keywordPlaceholder:'应用名称 / 应用编码',keywordFields:['name','code'],filters:[
  filterDef('category','系统分类','请选择系统分类',rowOptions('category'),'category'),
  filterDef('aggregateRuntimeStatus','综合运行状态','请选择综合运行状态',fixedOptions(['NORMAL','ABNORMAL','UNCONFIGURED','DISABLED'],'runtime_status'),'aggregateRuntimeStatus'),
  ...(admin.value?[filterDef('enabled','启用状态','请选择启用状态',fixedOptions(['ENABLED','DISABLED'],'enable_status'),'status')]:[]),
  filterDef('userType','适用用户','请选择适用用户',fixedOptions(['BOTH','CITIZEN','GOV']),'userType')
 ]};
 if(key==='categories')return {keywordPlaceholder:'分类名称 / 分类编码',keywordFields:['name','code'],filters:[filterDef('status','启用状态','请选择启用状态',fixedOptions(['ENABLED','DISABLED'],'enable_status'),'status')]};
 if(key==='myApplicationRequests')return {keywordPlaceholder:'申请编号 / 应用名称 / 申请人',keywordFields:['requestNo','appName','userName','reason'],filters:[filterDef('appName','应用','请选择应用',rowOptions('appName'),'appName'),filterDef('status','状态','请选择状态',myRequestStatusOptions(),'status')]};
 if(key==='applicationRequests')return {keywordPlaceholder:'申请编号 / 来源应用 / 申请人',keywordFields:['requestNo','appName','userName','reason'],filters:[filterDef('appName','来源应用','请选择来源应用',rowOptions('appName'),'appName'),filterDef('status','状态','请选择状态',fixedOptions(['PENDING','APPROVED','REJECTED','WITHDRAWN'],'application_request_status'),'status')]};
 if(key==='accountOpeningRequests')return {keywordPlaceholder:'申请编号 / 来源应用 / 申请人',keywordFields:['requestNo','appName','userName','reason'],filters:[filterDef('appName','来源应用','请选择来源应用',rowOptions('appName'),'appName'),filterDef('status','状态','请选择状态',fixedOptions(['PENDING','PROCESSING','COMPLETED'],'account_opening_status'),'status')]};
 if(key==='permissions')return {keywordPlaceholder:'权限名称 / 权限编码',keywordFields:['name','code'],filters:[]};
 if(key==='todos')return {keywordPlaceholder:'待办标题',keywordFields:['title'],filters:[filterDef('appName','来源应用','请选择来源应用',rowOptions('appName'),'appName'),filterDef('businessType','任务类型','请选择任务类型',dictionaryOptions('todo_task_type',[...new Set(rows.value.map(row=>row.businessType).filter(Boolean))],{includeDisabled:true}),'businessType'),filterDef('status','状态','请选择待办状态',dictionaryOptions('todo_status',['PENDING','COMPLETED','WITHDRAWN',...(rows.value.some(row=>row.status==='EXPIRED')?['EXPIRED']:[])],{includeDisabled:true}),'status')]};
 if(key==='announcements')return admin.value
  ?{keywordPlaceholder:'公告标题',keywordFields:['title'],filters:[filterDef('type','公告类型','请选择公告类型',rowOptions('type'),'type'),filterDef('scope','发布范围','请选择发布范围',fixedOptions(['ALL','CITIZEN','GOV'],'announcement_scope'),'scope'),filterDef('status','状态','请选择公告状态',fixedOptions(['DRAFT','PUBLISHED','WITHDRAWN'],'announcement_status'),'status')]}
  :{keywordPlaceholder:'公告标题',keywordFields:['title'],filters:[filterDef('type','公告类型','请选择公告类型',rowOptions('type'),'type'),filterDef('scope','发布范围','请选择发布范围',fixedOptions(['ALL','CITIZEN','GOV'],'announcement_scope'),'scope'),filterDef('readStatus','阅读状态','请选择阅读状态',fixedOptions(['UNREAD','READ'],'message_read_status'),'status')]};
 if(key==='monitor')return {keywordPlaceholder:'应用名称 / 应用编码',keywordFields:['appName','appCode'],filters:[filterDef('ssoStatus','SSO状态','请选择SSO状态',fixedOptions(['UNCONFIGURED','DISABLED','NORMAL','ABNORMAL'],'runtime_status'),'ssoStatus'),filterDef('todoStatus','TODO状态','请选择TODO状态',fixedOptions(['UNCONFIGURED','DISABLED','NORMAL','ABNORMAL'],'runtime_status'),'todoStatus'),filterDef('messageStatus','MESSAGE状态','请选择MESSAGE状态',fixedOptions(['UNCONFIGURED','DISABLED','NORMAL','ABNORMAL'],'runtime_status'),'messageStatus')]};
 if(key==='mappings'||key==='exceptions')return {keywordPlaceholder:'来源应用 / 子系统账号 / 统一身份标识',keywordFields:['appName','externalAccount','userId'],filters:[filterDef('appName','来源应用','请选择来源应用',rowOptions('appName'),'appName'),filterDef('status','状态','请选择映射状态',fixedOptions(['BOUND','FAILED','CONFLICT','UNBOUND'],'mapping_status'),'status')]};
 if(logKind)return {keywordPlaceholder:'请求ID / 说明',keywordFields:['requestId','description','name'],filters:[filterDef('appName','来源应用','请选择来源应用',rowOptions('appName'),'appName'),filterDef('actor','操作人','请选择操作人',rowOptions('actor'),'actor'),filterDef('status','结果状态','请选择结果状态',fixedOptions(['SUCCESS','FAILURE','DENIED']),'status')]};
 return {keywordPlaceholder:'关键词',keywordFields:Object.keys(titles),filters:[]};
});
const queryFilters=computed(()=>querySpec.value.filters||[]);
const appUserTypeStats=computed(()=>[
 {userType:'CITIZEN',label:label('CITIZEN'),icon:'user',tone:'blue',count:rows.value.filter(row=>row.userType==='CITIZEN').length},
 {userType:'GOV',label:label('GOV'),icon:'user-safety',tone:'green',count:rows.value.filter(row=>row.userType==='GOV').length},
 {userType:'BOTH',label:label('BOTH'),icon:'usergroup',tone:'purple',count:rows.value.filter(row=>row.userType==='BOTH').length}
]);
const normalizeSortKey=sortBy=>sortBy==='primary'?({apps:'name',applicationRequests:'requestNo',accountOpeningRequests:'requestNo',categories:'name',permissions:'code'}[listResource.value]||sortBy):sortBy;
const compareTableValue=(a,b,key)=>{
 if(['submittedAt','createdAt','publishedAt','receivedAt','lastCheckedAt','updatedAt'].includes(key))return (Date.parse(a?.[key])||0)-(Date.parse(b?.[key])||0);
 if(key==='enabled')return Number(a?.enabled!==false)-Number(b?.enabled!==false);
 if(['sortOrder','userCount'].includes(key))return (Number(a?.[key])||0)-(Number(b?.[key])||0);
 const av=['status','aggregateRuntimeStatus','userType','accessMode'].includes(key)?label(a?.[key]):text(a?.[key]);
 const bv=['status','aggregateRuntimeStatus','userType','accessMode'].includes(key)?label(b?.[key]):text(b?.[key]);
 return String(av||'').localeCompare(String(bv||''),'zh-CN',{numeric:true,sensitivity:'base'});
};
const filtered=computed(()=>{
 const term=search.value.trim().toLowerCase();
 const keywordFields=querySpec.value.keywordFields||[];
 const result=rows.value.filter(row=>{
  const matchesFilters=queryFilters.value.every(filter=>{const selected=filterValues[filter.key];if(selected===undefined||selected===null||selected==='')return true;if(filter.key==='enabled')return (row.enabled===false?'DISABLED':'ENABLED')===String(selected);const actual=String(row[filter.key]??'');return actual===String(selected);});
  const domain=listResource.value==='myApplicationRequests'&&row.requestType==='ACCOUNT_OPENING'?'accountOpeningRequests':listResource.value;
  const matchesKeyword=!term||keywordFields.some(key=>display(key,row[key],domain).toLowerCase().includes(term));
  return matchesFilters&&matchesKeyword;
 });
 const active=Array.isArray(tableSort.value)?tableSort.value[0]:tableSort.value;
 if(active?.sortBy){
  const key=normalizeSortKey(active.sortBy);
  const direction=active.descending?-1:1;
  return result.sort((a,b)=>direction*compareTableValue(a,b,key));
 }
 return result.sort((a,b)=>'sortOrder'in a?(a.sortOrder||0)-(b.sortOrder||0):(Date.parse(b.publishedAt||b.createdAt)||0)-(Date.parse(a.publishedAt||a.createdAt)||0));
});
function handleTableSortChange(sort){
 const next=Array.isArray(sort)?sort[0]:sort;
 tableSort.value=next?.sortBy?{sortBy:next.sortBy,descending:!!next.descending}:null;
 page.value=1;
}
const paged=computed(()=>filtered.value.slice((page.value-1)*pageSize.value,page.value*pageSize.value));
watch([search,()=>JSON.stringify(filterValues),pageSize],()=>{page.value=1;appPages.mine=1;appPages.other=1;});
watch(()=>filtered.value.length,()=>{page.value=Math.min(page.value,Math.max(1,Math.ceil(filtered.value.length/pageSize.value)));});
const appGroups=computed(()=>['mine','other'].map(key=>{
 const entries=filtered.value.filter(row=>mineIds.value.includes(row.id)===(key==='mine'));
 const size=appPageSizes[key];
 const current=Math.min(appPages[key],Math.max(1,Math.ceil(entries.length/size)));
 return {key,title:key==='mine'?'我的应用':'其它应用',page:current,pageSize:size,total:entries.length,rows:entries.slice((current-1)*size,current*size)};
}));
function setAppPage(key,value){appPages[key]=value;}
function setAppPageSize(key,value){appPageSizes[key]=Number(value)||20;appPages[key]=1;}
const fieldMap={apps:['name','code','category','userType','accessMode','aggregateRuntimeStatus','enabled'],myApplicationRequests:['requestNo','requestType','appName','status','submittedAt','reviewNote'],applicationRequests:['requestNo','userName','appName','reason','status','submittedAt'],accountOpeningRequests:['requestNo','userName','appName','reason','status','submittedAt'],categories:['name','code','status'],todos:['title','appName','businessType','status','receivedAt'],messages:['title','appName','messageType','status','receivedAt'],announcements:['title','type','scope','status','publishedAt'],identities:['name','orgName','userType','status'],identityMappings:['name','source','status'],mappings:['appName','userId','externalAccount','status'],exceptions:['appName','externalAccount','status'],permissions:['code','name','description'],settings:['name','code','value','status'],monitor:['appName','appCode','ssoStatus','todoStatus','messageStatus','lastCheckedAt']};
const fields=computed(()=>fieldMap[listResource.value]||(resource.value.startsWith('logs:')?['name','actor','appName','description','status','createdAt']:['appName','kind','mode','status','remark']));
const primaryField=computed(()=>fields.value[0]);
const hasOperations=computed(()=>['apps','categories','todos','messages','settings','mappings','exceptions','myApplicationRequests','applicationRequests','accountOpeningRequests'].includes(resource.value)||(resource.value==='announcements'&&admin.value));
const columnTitle=(key)=>{
 const resourceKey=listResource.value;
 const overrides={
  apps:{name:'应用名称',code:'应用编码',userType:'适用用户',aggregateRuntimeStatus:'综合运行状态',status:'启用状态'},
  categories:{status:'启用状态'},
  users:{name:'姓名',status:'启用状态'},
  identities:{status:'启用状态'},
  roles:{description:'描述',status:'启用状态'},
  permissions:{code:'权限编码',name:'权限名称'},
  monitor:{appName:'应用名称'},
  applicationRequests:{appName:'来源应用'},
  accountOpeningRequests:{appName:'来源应用'}
 };
 if(overrides[resourceKey]?.[key])return overrides[resourceKey][key];
 if(key==='receivedAt'&&['todos','messages'].includes(resourceKey))return '接收时间';
 return titles[key]||key;
};
const columnWidth=(key,index)=>{
 if(resource.value==='applicationRequests'){
  if(key==='userName')return 110;
  if(key==='status')return 100;
  if(key==='appName')return 320;
  if(key==='reason')return 320;
 }
 if(resource.value.startsWith('logs:')){
  if(key==='appName')return 260;
  if(key==='status')return 110;
 }
 if(index===0)return 250;
 if(['permissionLabels','roleLabels'].includes(key))return 280;
 if(key==='description')return 300;
 return 160;
};
const sortableFields={
 apps:new Set(['name','code','category','userType','accessMode','aggregateRuntimeStatus','enabled']),
 applicationRequests:new Set(['requestNo','userName','appName','status','submittedAt']),
 accountOpeningRequests:new Set(['requestNo','userName','appName','status','submittedAt']),
 categories:new Set(['name','code','status']),
 permissions:new Set(['code','name'])
};
const isSortableField=key=>sortableFields[listResource.value]?.has(key)===true;
const accountOpeningStatusTheme=status=>({
 PENDING:'warning',
 PROCESSING:'primary',
 COMPLETED:'success',
 FAILED:'danger',
 REJECTED:'danger'
})[status]||theme(status);
const columns=computed(()=>[
 {colKey:'serial',title:'序号',width:64},
 ...fields.value.map((key,index)=>({colKey:index===0?'primary':key,title:columnTitle(key),width:columnWidth(key,index),ellipsis:true,sorter:isSortableField(key),sortType:'all',cell:index===0||resource.value==='apps'&&key==='enabled'?undefined:(_,context)=>{
  const domain=resource.value==='myApplicationRequests'&&context.row.requestType==='ACCOUNT_OPENING'?'accountOpeningRequests':resource.value;
  return ['status','runtimeStatus','aggregateRuntimeStatus','ssoStatus','todoStatus','messageStatus'].includes(key)
   ?h(Tag,{theme:resource.value==='monitor'&&context.row[key]==='ABNORMAL'?'warning':resource.value==='accountOpeningRequests'&&key==='status'?accountOpeningStatusTheme(context.row[key]):theme(context.row[key]),variant:'light'},()=>label(context.row[key],dictionaryTypeFor(domain,key)))
   :h(TableCellTooltip,{text:display(key,context.row[key],domain)},()=>display(key,context.row[key],domain));
 }})),
 ...(hasOperations.value?[{colKey:'operation',title:'操作',width:resource.value==='apps'&&admin.value?240:200,fixed:'right'}]:[])
]);
const createAction=computed(()=>({apps:'saveApp',categories:'saveCategory',announcements:'saveAnnouncement'})[resource.value]);
const createScope={apps:'application:edit',categories:'application:edit',announcements:'announcement:edit'};
const canCreate=computed(()=>admin.value&&!!createAction.value&&can(actor.value,createScope[resource.value]));
const createLabel=computed(()=>({apps:'新增应用',categories:'新增分类',announcements:'新增公告'})[resource.value]);
const formTitle=computed(()=>formAction.value==='saveAnnouncement'?(form.id?'编辑公告':'新增公告'):({saveApp:'应用信息',saveCategory:'系统分类',bind:'关联已有账号',saveConfig:'参数配置',saveIntegration:'接入配置',resolveMapping:'处理账号关联冲突',submitApplicationRequest:'申请使用应用',rejectApplicationRequest:'驳回应用访问申请',rejectBindingReview:'驳回账号关联审核',pushTodo:'录入来源待办',pushMessage:'录入来源消息'})[formAction.value]);
const opt=(values,typeCode)=>typeCode?dictionaryOptions(typeCode,values):values.map(value=>({value,label:label(value)}));
const taskTypeOptions=computed(()=>dictionaryOptions('todo_task_type',dictionaryLookups.value.items.filter(item=>item.typeCode==='todo_task_type').map(item=>item.value).concat('服务事项')));
const formFields=computed(()=>{
 const f=(key,labelText,type='text',required=false,options=null,full=false)=>({key,label:labelText,type,required,options,full});
 const appOpts=allApps.value.map(item=>({value:item.id,label:text(item.name)}));
 const userOpts=availableUsers.value.map(item=>({value:item.id,label:text(item.name)}));
 return ({
  saveApp:[f('name','应用名称','text',true),f('code','应用编码','text',true),f('category','系统分类','text',true,categories.value.map(item=>({value:item.name,label:text(item.name)}))),f('userType','适用用户','text',true,opt(['BOTH','CITIZEN','GOV'])),
   f('accessMode','访问模式','text',true,opt(['DIRECT','BIND','REQUEST'])),
   f('enabled','启用状态','text',true,[{value:true,label:'启用'},{value:false,label:'停用'}]),
   ...(form.accessMode==='REQUEST'?[f('postGrantMode','申请通过后','text',true,opt(['DIRECT','BIND']))]:[]),
   ...((form.accessMode==='BIND'||(form.accessMode==='REQUEST'&&form.postGrantMode==='BIND'))?[f('accountBindingMode','账号关联方式','text',true,opt(['AUTO','SELF','REVIEW','ADMIN'])),f('accountOpeningMode','未找到账号时','text',true,[{value:'NONE',label:'仅提示联系管理员'},{value:'REQUEST',label:'允许提交开通申请'}])]:[]),
   ...(form.id?[]:[f('sortOrder','显示排序','number')]),f('url','入口地址','text',true,null,true),f('description','说明','textarea',false,null,true)],
  saveCategory:[f('name','分类名称','text',true),f('code','分类编码','text',true),f('sortOrder','排序','number')],
  saveAnnouncement:[f('title','公告标题','text',true,null,true),f('type','公告类型'),f('scope','发布范围','text',true,opt(['ALL','CITIZEN','GOV'],'announcement_scope')),f('effectiveStart','生效时间','date'),f('effectiveEnd','失效时间','date')],
  bind:[f('externalAccount','已有子系统账号','text',true,null,true)],
  submitApplicationRequest:[f('reason','申请原因','textarea',true,null,true),f('contact','联系方式','text',false),f('remark','备注','textarea',false,null,true)],
  rejectApplicationRequest:[f('reviewNote','驳回原因','textarea',true,null,true)],
  rejectBindingReview:[f('reviewNote','驳回原因','textarea',true,null,true)],
  saveConfig:[f('value','配置值（使用当前参数标注单位）','number',true,null,true)],
  saveIntegration:[f('enabled','启用接入','text',true,opt(['ENABLED','DISABLED'])),...(form.kind==='SSO'?[f('protocol','协议','text',true,opt(['OIDC','SAML2','CUSTOM'])),f('clientId','Client ID'),f('authorizeUrl','授权地址'),f('tokenUrl','令牌地址'),f('callbackUrl','回调地址')]:[f('mode','接入方式','text',true,opt(['PUSH'])),f('fieldMapping','字段映射（JSON：标准字段→来源字段）','textarea',false,null,true)]),f('credentialRef','服务端凭据引用'),f('remark','接入说明','textarea',false,null,true)],resolveMapping:[f('reason','核验证据说明','textarea',true,null,true)],
  pushTodo:[f('appId','来源应用','text',true,appOpts),f('userId','接收人','text',true,userOpts),f('sourceTodoId','源事项ID','text',true),f('eventId','事件ID','text',true),f('businessType','待办任务类型','text',true,taskTypeOptions.value),f('status','源状态','text',true,opt(['PENDING','COMPLETED','WITHDRAWN'],'todo_status')),f('title','待办标题','text',true,null,true)],
  pushMessage:[f('appId','来源应用','text',true,appOpts),f('userId','接收人','text',true,userOpts),f('sourceMessageId','源消息ID','text',true),f('eventId','事件ID','text',true),f('title','消息标题','text',true,null,true),f('content','消息内容','textarea',true,null,true)]
 })[formAction.value]||[];
});
function toDateTimeValue(value){const d=new Date(value);if(!Number.isFinite(d.getTime()))return String(value||'');const pad=n=>String(n).padStart(2,'0');return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;}
function openForm(action,row={}){
 Object.keys(form).forEach(key=>delete form[key]);
 const defaults={name:'',code:'',category:categories.value[0]?.name||'公众服务',userType:'BOTH',accessMode:'BIND',enabled:false,postGrantMode:'DIRECT',accountBindingMode:'SELF',accountOpeningMode:'NONE',url:'',sortOrder:0,description:'',title:'',content:'',type:'通知',scope:'ALL',attachments:[],value:null,reason:'',contact:'',remark:'',reviewNote:'',appName:'',appId:allApps.value.find(app=>!rows.value.some(item=>item.appId===app.id))?.id||allApps.value[0]?.id,userId:actor.value.id,status:'PENDING',businessType:'服务事项',eventId:createUUID(),sourceTodoId:'',sourceMessageId:''};
 Object.assign(form,defaults,JSON.parse(JSON.stringify(row)));
 if(action==='pushTodo'&&!taskTypeOptions.value.some(item=>item.value===form.businessType))form.businessType=taskTypeOptions.value[0]?.value||'';
 if(action==='saveIntegration'){form.enabled=row.enabled||'DISABLED';form.protocol=['OIDC','SAML2','CUSTOM'].includes(row.protocol)?row.protocol:'OIDC';form.mode='PUSH';form.fieldMapping=JSON.stringify(row.fieldMapping||{},null,2);}
 for(const key of ['effectiveStart','effectiveEnd'])if(form[key])form[key]=toDateTimeValue(form[key]);
 formAction.value=action;formError.value='';bindFeedback.value=null;
 announcementUploadFiles.value=action==='saveAnnouncement'?(form.attachments||[]).map(file=>({name:file.name||'附件',url:file.data||'',status:'success',id:file.id||createUUID(),originAttachment:JSON.parse(JSON.stringify(file))})):[];
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
  if(formAction.value==='bind')payload={appId:form.appId,externalAccount:form.externalAccount.trim()};
  if(formAction.value==='submitApplicationRequest')payload={appId:form.appId,reason:form.reason.trim(),contact:form.contact?.trim()||'',remark:form.remark?.trim()||''};
  if(formAction.value==='rejectApplicationRequest')payload={id:form.id,version:form.version,reviewNote:form.reviewNote.trim()};
  if(formAction.value==='rejectBindingReview')payload={id:form.id,version:form.version,reviewNote:form.reviewNote.trim()};
  for(const key of ['effectiveStart','effectiveEnd'])if(payload[key])payload[key]=new Date(String(payload[key]).replace(' ','T')).toISOString();
  const result=await command(formAction.value,payload);
  if(!result.ok){formError.value=result.error.message;return;}
  if(formAction.value==='bind'){
   const state=result.data.status;
   bindFeedback.value={theme:state==='BOUND'?'success':state==='CONFLICT'?'warning':'error',message:state==='BOUND'?'账号确认已完成。':state==='CONFLICT'?'账号信息存在异常，请联系管理员核查。':'账号确认未完成，请重新处理。'};
   return;
  }
  formVisible.value=false;
  const successText=formAction.value==='saveAnnouncement'?'公告草稿已保存，请在公告管理中发布':formAction.value==='submitApplicationRequest'?'申请已提交，可在“我的申请”查看进度':formAction.value==='rejectApplicationRequest'?'申请已驳回':formAction.value==='rejectBindingReview'?'账号关联审核已驳回':'保存成功';
  MessagePlugin.success(successText);
 }catch(cause){formError.value=cause.message;}finally{saving.value=false;}
}
async function run(action,payload,show=false){
 try{
  const result=await command(action,payload);
  if(!result.ok){MessagePlugin.error(text(result.error.message));return;}
  if(show){
   const dialog=DialogPlugin.alert({
    placement:'center',
    header:'应用访问',
    body:text(result.data.message),
    confirmBtn:'知道了',
    onConfirm:()=>dialog.hide()
   });
  }else MessagePlugin.success('操作成功');
  return result;
 }catch(cause){MessagePlugin.error(text(cause.message));}
}
const enterApp=app=>run('enterApp',{id:app.id},true);
function openBinding(app){bindingApp.value=JSON.parse(JSON.stringify(app));bindingVisible.value=true;}
const bindApp=app=>openBinding(app);
const requestApp=app=>openForm('submitApplicationRequest',{appId:app.id,appName:app.name});
const viewApplicationRequest=()=>router.push(portalPath('/applications'));
const viewBinding=app=>openBinding(app);
const viewConflict=app=>openBinding(app);
function handleBindingCompleted(){load();}
function viewBindingRequests(){router.push(portalPath('/applications'));}
function requestAppRecord(row){
 const app=allApps.value.find(item=>item.id===row.appId);
 if(!app)MessagePlugin.error('应用信息不存在，请刷新后重试');
 return app||null;
}
function bindByRequest(row){
 const app=requestAppRecord(row);if(!app)return;
 openBinding(app);
}
function enterAppByRequest(row){
 const app=requestAppRecord(row);if(!app)return;
 enterApp(app);
}
function confirm(action,row,body){const dialog=DialogPlugin.confirm({placement:'center',header:'操作确认',body,onConfirm:async()=>{if(await run(action,{...row}))dialog.hide();}});}
async function showDetail(row,kind=listResource.value){
 if(kind==='announcements'){await router.push(`${admin.value?'/admin':(previewRoute.value?'/portal-preview':'/portal')}/announcements/${encodeURIComponent(row.id)}`);return;}
 if(kind==='messages'){await router.push({path:portalPath('/messages'),query:{messageId:row.id}});return;}
 detail.value=JSON.parse(JSON.stringify(row));detailKind.value=kind;
 detailAccessProfile.value=kind==='apps'&&admin.value?JSON.parse(JSON.stringify(accessProfiles.value.find(item=>item.appId===row.id)||null)):null;
 detailVisible.value=true;
}
function closeDetail(visible){detailVisible.value=visible;if(!visible)detailAccessProfile.value=null;}
function backToAnnouncements(){router.push(admin.value?'/admin/announcements':portalPath('/announcements'));}
function openAdminAnnouncementDetail(row){router.push('/admin/announcements/'+encodeURIComponent(row.id));}
function openAdminAnnouncementEdit(row){detail.value=JSON.parse(JSON.stringify(row));announcementEditVisible.value=true;}
function removeAdminAnnouncementDetail(row){
 const dialog=DialogPlugin.confirm({placement:'center',theme:'danger',header:'删除公告',body:'确认删除该公告？删除后将退出公告详情，且不可从当前列表恢复。',confirmBtn:{content:'确认删除',theme:'danger'},onConfirm:async()=>{
  const result=await command('removeAnnouncement',{id:row.id,version:row.version});
  if(!result.ok){MessagePlugin.error(result.error.message);return;}
  dialog.hide();MessagePlugin.success('公告已删除');router.replace('/admin/announcements');
 }});
}
function handleAdminAnnouncementSaved(saved){
 detail.value=JSON.parse(JSON.stringify(saved));
 announcementEditVisible.value=false;
}
async function downloadAccessSpec(){try{await downloadAccessContract();MessagePlugin.success('A阶段本地联调 OpenAPI 文件已下载');}catch(cause){MessagePlugin.error(cause.message);}}
async function toggleAppStatus(row,enabled){const result=await command('setAppStatus',{id:row.id,version:row.version,enabled});if(!result.ok){MessagePlugin.error(text(result.error.message));await load();return;}MessagePlugin.success(enabled?'应用已启用':'应用已停用');await load();}
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
   result.push({id:item.id||'FILE_'+createUUID(),name:raw.name||item.name||'附件',size:raw.size||size,type:raw.type||item.type||'',uploadedAt:new Date().toISOString(),data});
   continue;
  }
  if(item?.url?.startsWith('data:'))result.push({id:item.id||'FILE_'+createUUID(),name:item.name||'附件',size,type:item.type||'',uploadedAt:new Date().toISOString(),data:item.url});
 }
 return result;
}

function download(file){if(!file.data?.startsWith('data:')){MessagePlugin.warning('附件内容不可用');return;}const link=document.createElement('a');link.href=file.data;link.download=file.name;link.click();}
</script>
