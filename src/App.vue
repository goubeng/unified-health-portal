<template>
 <router-view v-if="route.meta.group==='登录'||['portal-preview','public-portal'].includes(route.meta.layout)" />
 <div v-else class="app-shell" :class="{collapsed}">
  <header class="topbar">
   <PortalTooltip :content="collapsed?'展开菜单':'收起菜单'" placement="bottom"><t-button class="collapse-button" shape="square" variant="text" aria-label="展开或收起菜单" @click="collapsed=!collapsed"><template #icon><component :is="collapsed?MenuUnfoldIcon:MenuFoldIcon"/></template></t-button></PortalTooltip>
   <span class="brand">卫健XC统一门户</span><span class="portal-caption" :class="{admin}">{{admin?'平台管理端':'用户端门户'}}</span>
   <div class="topbar-actions">
    <PortalTooltip v-if="can(actor,'any')" :content="admin?'切换到用户端门户':'切换到平台管理端'" placement="bottom"><t-button class="portal-switch-button" variant="text" @click="router.push(admin?'/portal/home':'/admin/home')"><template #icon><SwapIcon size="16px"/></template>{{admin?'用户端门户':'平台管理端'}}</t-button></PortalTooltip>
    <t-badge class="message-badge" :count="unread" :max-count="99" :show-zero="false"><PortalTooltip content="消息中心" placement="bottom"><t-button class="topbar-icon-button" shape="square" variant="text" aria-label="消息中心" @click="router.push('/portal/messages')"><template #icon><MailIcon size="16px"/></template></t-button></PortalTooltip></t-badge>
    <t-popup v-model:visible="accountOpen" trigger="click" placement="bottom-right" :show-arrow="true">
     <button class="account-entry" :aria-expanded="accountOpen" aria-label="用户菜单"><span class="avatar">{{displayName(actor).slice(0,1)}}</span><span class="user-name">{{displayName(actor)}}</span><ChevronDownIcon/></button>
     <template #content><div class="account-popover">
      <div class="account-summary">
       <strong>{{displayName(actor)}}</strong>
       <div class="account-info-grid">
        <div class="account-info-item"><span class="account-id-label">账号 ID</span><b>{{actor?.account||'未提供'}}</b></div>
        <div class="account-info-item"><span class="account-id-label">所属单位</span><b>{{actor?.orgName||'未提供'}}</b></div>
       </div>
       <span class="account-role-line"><t-tag size="small" variant="light">{{typeLabel(actor)}}</t-tag><t-tag size="small" theme="primary" variant="light">{{can(actor,'any')?(actor?.roleName||'门户管理员'):'普通用户'}}</t-tag></span>
      </div>
      <div class="account-links"><button @click="openProfile">个人信息</button><button @click="changePassword">修改密码</button></div><button class="logout-button" @click="exitSystem">退出系统</button>
     </div></template>
    </t-popup>
   </div>
  </header>
  <div class="workbench"><aside class="aside"><nav class="menu-wrap" :class="{collapsed}" aria-label="主菜单">
   <template v-if="admin">
    <section v-for="group in menu" :key="group.name" class="menu-section">
     <button v-if="!collapsed" type="button" class="menu-group" @click="toggleMenuGroup(group.name)"><span>{{group.name}}</span><ChevronDownIcon size="12px" class="group-chevron" :class="{closed:collapsedGroups.has(group.name)}"/></button>
     <div v-show="collapsed||!collapsedGroups.has(group.name)" class="menu-group-items"><PortalTooltip v-for="p in group.pages" :key="p.id" :content="displayTitle(p.title)" placement="right" :disabled="!collapsed"><router-link :to="p.path" class="menu-item" active-class="active" :class="{active:isMenuActive(p)}"><component :is="iconFor(p.resource)" class="menu-symbol"/><span v-if="!collapsed" class="menu-item-label">{{displayTitle(p.title)}}</span></router-link></PortalTooltip></div>
    </section>
   </template>
   <div v-else class="menu-group-items user-flat-menu"><PortalTooltip v-for="p in userMenu" :key="p.id" :content="displayTitle(p.title)" placement="right" :disabled="!collapsed"><router-link :to="p.path" class="menu-item" active-class="active" :class="{active:isMenuActive(p)}"><component :is="iconFor(p.resource)" class="menu-symbol"/><span v-if="!collapsed" class="menu-item-label">{{displayTitle(p.title)}}</span></router-link></PortalTooltip></div>
  </nav></aside>
   <main class="content"><div class="content-header"><div class="title-row"><PortalTooltip v-if="showBack" content="返回" placement="bottom"><button type="button" class="back-button" aria-label="返回" @click="backToList"><ArrowLeftIcon/></button></PortalTooltip><h1>{{currentPageTitle}}</h1><div id="page-header-extra" class="page-header-extra-host"></div><div id="page-header-actions" class="page-header-actions-host"></div></div></div><div class="content-body"><router-view :key="route.fullPath+'|'+actor?.id"/></div></main>
  </div>
  <t-dialog v-model:visible="passwordVisible" placement="center" header="修改本地账号密码" width="520px" :confirm-btn="{content:'确认修改',loading:passwordSaving}" :close-on-overlay-click="false" @confirm="savePassword">
   <div v-if="passwordError" class="error-note">{{passwordError}}</div>
   <div class="form-grid">
    <div class="form-field full"><label>当前密码 <span class="portal-required">*</span></label><t-input v-model="passwordForm.currentPassword" type="password" autocomplete="current-password" placeholder="请输入当前密码"/></div>
    <div class="form-field full"><label>新密码 <span class="portal-required">*</span></label><t-input v-model="passwordForm.newPassword" type="password" autocomplete="new-password" placeholder="请输入新密码"/></div>
    <div class="form-field full"><label>确认新密码 <span class="portal-required">*</span></label><t-input v-model="passwordForm.confirmPassword" type="password" autocomplete="new-password" placeholder="请再次输入新密码"/></div>
   </div>
  </t-dialog>
 </div>
</template>
<script setup>
import {computed,reactive,ref,watch} from 'vue';
import {useRoute,useRouter} from 'vue-router';
import {AppIcon,HomeIcon,TaskIcon,MailIcon,NotificationIcon,UserIcon,UserSafetyIcon,SettingIcon,LinkIcon,FileIcon,ChartBarIcon,FolderIcon,BookIcon,UserAddIcon,UserPasswordIcon,ActivityIcon,CodeIcon,BugReportIcon,MenuFoldIcon,MenuUnfoldIcon,ChevronDownIcon,LogoutIcon,ArrowLeftIcon,SwapIcon} from 'tdesign-icons-vue-next';
import {pages,can,labels} from './config/pages.js';
import {actor,portal,revision,logout,command} from './services/runtime.js';
import {validateLocalPassword} from './config/password-policy.js';
import {MessagePlugin} from 'tdesign-vue-next';
import PortalTooltip from './components/portal/PortalTooltip.vue';
const route=useRoute(),router=useRouter(),collapsed=ref(false),collapsedGroups=ref(new Set()),unread=ref(0),accountOpen=ref(false);
const passwordVisible=ref(false),passwordSaving=ref(false),passwordError=ref(''),passwordForm=reactive({currentPassword:'',newPassword:'',confirmPassword:''});
const admin=computed(()=>route.path.startsWith('/admin'));
const displayName=user=>(user?.name||'用户').replace(/\s*·\s*演示$|演示|模拟/g,'').trim();
const typeLabel=user=>labels[user?.authType==='LOCAL'?'LOCAL':user?.userType]||user?.userType||'用户';
const displayTitle=title=>String(title||'').replace('上层身份映射','闽政通 / 闽政务身份映射').replace('上层公共服务接入','公共服务接入');
const showBack=computed(()=>route.meta.resource==='announcementDetail'||(route.meta.resource==='messages'&&Boolean(route.query.messageId)));
const currentPageTitle=computed(()=>route.meta.resource==='messages'&&route.query.messageId?'消息详情':displayTitle(route.meta.title));
const isMenuActive=page=>{
 if(route.meta.resource==='announcementDetail'&&page.resource==='announcements')return page.path===(admin.value?'/admin/announcements':'/portal/announcements');
 return route.path===page.path;
};
function backToList(){
 if(route.meta.resource==='messages'){const query={...route.query};delete query.messageId;router.replace({path:route.path,query});return;}
 if(route.meta.resource==='announcementDetail'){
  router.push(admin.value?'/admin/announcements':'/portal/announcements');return;
 }
}
const menu=computed(()=>{
 const list=pages.filter(p=>!p.hidden&&p.path.startsWith('/admin')&&!p.path.includes(':')&&can(actor.value,p.scope));
 return [...new Set(list.map(x=>x.group))].map(name=>({name,pages:list.filter(x=>x.group===name)}));
});
const userMenu=computed(()=>{
 const order=['home','todos','messages','announcements','apps','myApplicationRequests','profile'];
 const list=pages.filter(p=>!p.hidden&&p.path.startsWith('/portal')&&!p.path.includes(':')&&can(actor.value,p.scope));
 return order.map(resource=>list.find(p=>p.resource===resource)).filter(Boolean);
});
const icons={
 home:HomeIcon,
 todos:TaskIcon,
 myApplicationRequests:FileIcon,
 messages:MailIcon,
 announcements:NotificationIcon,
 profile:UserIcon,
 mine:AppIcon,
 apps:AppIcon,
 adminHome:HomeIcon,
 applicationRequests:TaskIcon,
 accountOpeningRequests:UserAddIcon,
 users:UserIcon,
 roles:UserSafetyIcon,
 organizations:FolderIcon,
 dictionaries:BookIcon,
 identityOverview:LinkIcon,
 categories:AppIcon,
 permissions:UserSafetyIcon,
 settings:SettingIcon,
 monitor:ChartBarIcon,
 'logs:login':UserPasswordIcon,
 'logs:access':ActivityIcon,
 'logs:operation':TaskIcon,
 'logs:api':CodeIcon,
 'logs:error':BugReportIcon,
 access:LinkIcon,
 identities:UserIcon,
 identityMappings:LinkIcon,
 mappings:LinkIcon,
 exceptions:NotificationIcon,
 sso:LinkIcon,
 todoIntegration:TaskIcon,
 messageIntegration:MailIcon,
 external:LinkIcon
};
const iconFor=resource=>icons[resource]||FileIcon;
function toggleMenuGroup(name){const next=new Set(collapsedGroups.value);next.has(name)?next.delete(name):next.add(name);collapsedGroups.value=next;}
function openProfile(){accountOpen.value=false;router.push(admin.value?'/admin/profile':'/portal/profile');}
function changePassword(){accountOpen.value=false;if(actor.value?.authType==='LOCAL'){passwordVisible.value=true;return;}window.open(actor.value?.userType==='GOV'?'https://zwfw.fujian.gov.cn':'https://mztapp.fujian.gov.cn','_blank','noopener');}
async function savePassword(){
 if(passwordSaving.value)return;
 const validation=validateLocalPassword({...passwordForm,requireCurrent:true});
 if(validation){passwordError.value=validation;return;}
 passwordSaving.value=true;passwordError.value='';
 try{
  const result=await command('changeLocalPassword',{id:actor.value.id,currentPassword:passwordForm.currentPassword,newPassword:passwordForm.newPassword,confirmPassword:passwordForm.confirmPassword});
  if(!result.ok){passwordError.value=result.error.message;return;}
  passwordVisible.value=false;MessagePlugin.success('密码维护记录已更新');
 }finally{passwordSaving.value=false;}
}
watch(passwordVisible,visible=>{if(!visible){passwordForm.currentPassword='';passwordForm.newPassword='';passwordForm.confirmPassword='';passwordError.value='';}});
async function exitSystem(){accountOpen.value=false;try{await logout();router.replace('/login');}catch(error){window.alert(error.message);}}
watch(()=>route.fullPath,()=>{accountOpen.value=false;});
watch([actor,revision],async(_,__,onCleanup)=>{
 let active=true;onCleanup(()=>{active=false;});unread.value=0;
 if(!actor.value){if(route.meta.group!=='登录')router.replace('/login');return;}
 if(route.meta.group!=='登录'&&!can(actor.value,route.meta.scope))router.replace('/portal/home');
 const result=await portal.read('home');if(active&&result.ok)unread.value=result.data.unreadCount;
},{immediate:true});
</script>
