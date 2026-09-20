<template>
 <router-view v-if="route.meta.group==='登录'" />
 <div v-else class="app-shell" :class="{collapsed}">
  <header class="topbar">
   <button class="collapse-button" aria-label="展开或收起菜单" title="展开或收起菜单" @click="collapsed=!collapsed"><component :is="collapsed?MenuUnfoldIcon:MenuFoldIcon" size="16px"/></button>
   <span class="brand">卫健XC统一门户</span><span class="portal-caption" :class="{admin}">{{admin?'平台管理端':'用户端门户'}}</span>
   <div class="topbar-actions">
    <t-select class="user-switch-select" :value="actor?.id" :options="userOptions" :disabled="switching" filterable aria-label="切换用户" placeholder="切换用户" @change="switchUser"/>
    <t-button v-if="actor?.kind==='ADMIN'" class="portal-switch-button" variant="text" :title="admin?'切换到用户端门户':'切换到平台管理端'" @click="router.push(admin?'/portal/home':'/admin/home')"><template #icon><component :is="admin?UserIcon:SettingIcon" size="16px"/></template>{{admin?'用户端门户':'平台管理端'}}</t-button>
    <t-badge class="message-badge" :count="unread" :max-count="99" :show-zero="false"><t-button class="topbar-icon-button" shape="square" variant="text" aria-label="消息中心" title="消息中心" @click="router.push('/portal/messages')"><template #icon><MailIcon size="16px"/></template></t-button></t-badge>
    <t-popup v-model:visible="accountOpen" trigger="click" placement="bottom-right" :show-arrow="true">
     <button class="account-entry" :aria-expanded="accountOpen" aria-label="用户菜单"><span class="avatar">{{displayName(actor).slice(0,1)}}</span><span class="user-name">{{displayName(actor)}}</span><ChevronDownIcon/></button>
     <template #content><div class="account-popover">
      <div class="account-summary">
       <strong>{{displayName(actor)}}</strong>
       <div class="account-info-grid">
        <div class="account-info-item"><span class="account-id-label">账号 ID</span><b>{{actor?.account||'未提供'}}</b></div>
        <div class="account-info-item"><span class="account-id-label">所属单位</span><b>{{actor?.orgName||'未提供'}}</b></div>
       </div>
       <span class="account-role-line"><t-tag size="small" variant="light">{{typeLabel(actor)}}</t-tag><t-tag size="small" theme="primary" variant="light">{{actor?.roleName|| (actor?.kind==='ADMIN'?'门户管理员':'普通用户')}}</t-tag></span>
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
     <div v-show="collapsed||!collapsedGroups.has(group.name)" class="menu-group-items"><t-tooltip v-for="p in group.pages" :key="p.id" :content="displayTitle(p.title)" placement="right" :disabled="!collapsed"><router-link :to="p.path" class="menu-item" active-class="active" :class="{active:isMenuActive(p)}"><component :is="iconFor(p.resource)" class="menu-symbol"/><span v-if="!collapsed" class="menu-item-label">{{displayTitle(p.title)}}</span></router-link></t-tooltip></div>
    </section>
   </template>
   <div v-else class="menu-group-items user-flat-menu"><t-tooltip v-for="p in userMenu" :key="p.id" :content="displayTitle(p.title)" placement="right" :disabled="!collapsed"><router-link :to="p.path" class="menu-item" active-class="active" :class="{active:isMenuActive(p)}"><component :is="iconFor(p.resource)" class="menu-symbol"/><span v-if="!collapsed" class="menu-item-label">{{displayTitle(p.title)}}</span></router-link></t-tooltip></div>
  </nav></aside>
   <main class="content"><div class="content-header"><div class="title-row"><button v-if="showBack" type="button" class="back-button" title="返回" aria-label="返回" @click="backToList"><ArrowLeftIcon/></button><h1>{{currentPageTitle}}</h1><div id="page-header-extra" class="page-header-extra-host"></div><div id="page-header-actions" class="page-header-actions-host"></div></div></div><div class="content-body"><router-view :key="route.fullPath+'|'+actor?.id"/></div></main>
  </div>
 </div>
</template>
<script setup>
import {computed,ref,watch} from 'vue';
import {useRoute,useRouter} from 'vue-router';
import {AppIcon,HomeIcon,TaskIcon,MailIcon,NotificationIcon,UserIcon,UserSafetyIcon,SettingIcon,LinkIcon,FileIcon,ChartBarIcon,FolderIcon,MenuFoldIcon,MenuUnfoldIcon,ChevronDownIcon,LogoutIcon,ArrowLeftIcon} from 'tdesign-icons-vue-next';
import {pages,can,scopes,labels} from './config/pages.js';
import {actor,availableUsers,portal,revision,login,logout} from './services/runtime.js';
const route=useRoute(),router=useRouter(),collapsed=ref(false),collapsedGroups=ref(new Set()),unread=ref(0),accountOpen=ref(false),switching=ref(false);
const admin=computed(()=>route.path.startsWith('/admin'));
const displayName=user=>(user?.name||'用户').replace(/\s*·\s*演示$|演示|模拟/g,'').trim();
const typeLabel=user=>labels[user?.userType]||user?.userType||'用户';
const displayTitle=title=>String(title||'').replace('上层身份映射','闽政通 / 闽政务身份映射').replace('上层公共服务接入','公共服务接入');
const showBack=computed(()=>route.meta.resource==='announcementDetail'||(route.meta.resource==='messages'&&Boolean(route.query.messageId)));
const currentPageTitle=computed(()=>{
 if(route.meta.resource==='announcementDetail'&&admin.value&&route.query.mode==='edit')return '编辑公告';
 return route.meta.resource==='messages'&&route.query.messageId?'消息详情':displayTitle(route.meta.title);
});
const isMenuActive=page=>{
 if(route.meta.resource==='announcementDetail'&&page.resource==='announcements')return page.path===(admin.value?'/admin/announcements':'/portal/announcements');
 return route.path===page.path;
};
function backToList(){
 if(route.meta.resource==='messages'){const query={...route.query};delete query.messageId;router.replace({path:route.path,query});return;}
 if(route.meta.resource==='announcementDetail'){
  if(admin.value&&route.query.mode==='edit'){router.push('/admin/announcements/'+encodeURIComponent(route.params.id));return;}
  router.push(admin.value?'/admin/announcements':'/portal/announcements');return;
 }
}
const userOptions=computed(()=>availableUsers.value.map(user=>({value:user.id,label:displayName(user)+'（'+typeLabel(user)+(user.kind==='ADMIN'?' / 管理员':'')+'）'})));
const menu=computed(()=>{
 const list=pages.filter(p=>!p.hidden&&p.path.startsWith('/admin')&&!p.path.includes(':')&&can(actor.value,p.scope));
 return [...new Set(list.map(x=>x.group))].map(name=>({name,pages:list.filter(x=>x.group===name)}));
});
const userMenu=computed(()=>{
 const order=['home','todos','messages','announcements','apps','myApplicationRequests','profile'];
 const list=pages.filter(p=>!p.hidden&&p.path.startsWith('/portal')&&!p.path.includes(':')&&can(actor.value,p.scope));
 return order.map(resource=>list.find(p=>p.resource===resource)).filter(Boolean);
});
const icons={home:HomeIcon,adminHome:ChartBarIcon,mine:AppIcon,apps:AppIcon,myApplicationRequests:FileIcon,applicationRequests:LinkIcon,accountOpeningRequests:LinkIcon,todos:TaskIcon,messages:MailIcon,announcements:NotificationIcon,profile:UserIcon,users:UserIcon,categories:FolderIcon,organizations:FolderIcon,dictionaries:FolderIcon,access:LinkIcon,identities:UserIcon,identityMappings:LinkIcon,mappings:LinkIcon,exceptions:NotificationIcon,roles:UserSafetyIcon,permissions:UserSafetyIcon,sso:LinkIcon,todoIntegration:TaskIcon,messageIntegration:MailIcon,external:LinkIcon,settings:SettingIcon,monitor:ChartBarIcon};
const iconFor=resource=>icons[resource]||FileIcon;
function toggleMenuGroup(name){const next=new Set(collapsedGroups.value);next.has(name)?next.delete(name):next.add(name);collapsedGroups.value=next;}
async function switchUser(id){
 if(switching.value||id===actor.value?.id||!availableUsers.value.some(user=>user.id===id))return;
 switching.value=true;accountOpen.value=false;
 try{await login(id);await router.replace(can(actor.value,route.meta.scope)?route.fullPath:'/portal/home');}
 catch(error){window.alert(error.message);}
 finally{switching.value=false;}
}
function openProfile(){accountOpen.value=false;router.push('/portal/profile');}
function changePassword(){accountOpen.value=false;if(actor.value?.userType==='LOCAL'){window.alert('当前为前端Mock阶段，本地账号密码修改将在数据库改造阶段接入真实凭证服务。');return;}window.open(actor.value?.userType==='GOV'?'https://zwfw.fujian.gov.cn':'https://mztapp.fujian.gov.cn','_blank','noopener');}
async function exitSystem(){accountOpen.value=false;try{await logout();router.replace('/login');}catch(error){window.alert(error.message);}}
watch(()=>route.fullPath,()=>{accountOpen.value=false;});
watch([actor,revision],async(_,__,onCleanup)=>{
 let active=true;onCleanup(()=>{active=false;});unread.value=0;
 if(!actor.value){if(route.meta.group!=='登录')router.replace('/login');return;}
 if(route.meta.group!=='登录'&&!can(actor.value,route.meta.scope))router.replace('/portal/home');
 const result=await portal.read('home');if(active&&result.ok)unread.value=result.data.unreadCount;
},{immediate:true});
</script>
