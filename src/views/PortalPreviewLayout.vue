<template>
  <div class="public-portal-shell public-portal-secondary-shell">
    <header class="public-portal-header">
      <div class="public-portal-header-inner">
        <button class="public-portal-brand" type="button" @click="router.push('/portal-preview/home')">
          <span class="public-portal-brand-copy">
            <strong>卫健XC统一门户</strong>
            <small>便民 · 协同 · 服务</small>
          </span>
        </button>

        <nav class="public-portal-nav" aria-label="公众门户导航">
          <button type="button" :class="{active:isActive('home')}" @click="router.push('/portal-preview/home')">首页</button>
          <button type="button" :class="{active:isActive('todos')}" @click="router.push('/portal-preview/todos')">待办任务</button>
          <button type="button" :class="{active:isActive('messages')}" @click="router.push('/portal-preview/messages')">消息中心</button>
          <button type="button" :class="{active:isActive('announcements')}" @click="router.push('/portal-preview/announcements')">通知公告</button>
          <button type="button" :class="{active:isActive('apps')}" @click="router.push('/portal-preview/apps')">应用中心</button>
          <button type="button" :class="{active:isActive('applications')}" @click="router.push('/portal-preview/applications')">我的申请</button>
        </nav>

        <div class="public-portal-user-area">
          <t-badge size="small" :count="unread" :max-count="99" :show-zero="false">
            <button class="public-portal-icon-button" type="button" aria-label="消息中心" @click="router.push('/portal-preview/messages')">
              <NotificationIcon />
            </button>
          </t-badge>
          <t-popup v-model:visible="accountOpen" trigger="click" placement="bottom-right" :show-arrow="true">
            <button class="public-portal-account" type="button">
              <span class="public-portal-avatar"><UserIcon /></span>
              <span>{{ displayName }}</span>
              <ChevronDownIcon size="16px" />
            </button>
            <template #content>
              <div class="public-portal-account-popover">
                <strong>{{ displayName }}</strong>
                <span>{{ actor?.orgName || '未提供所属单位' }}</span>
                <button type="button" @click="router.push('/portal/profile')">个人中心</button>
                <button v-if="can(actor,'any')" type="button" @click="router.push('/admin/home')">平台管理端</button>
                <button class="danger" type="button" @click="exitSystem">退出系统</button>
              </div>
            </template>
          </t-popup>
        </div>
      </div>
    </header>

    <main class="public-portal-subpage-wrap">
      <div class="public-portal-subpage-head">
        <div class="public-portal-subpage-title-row">
          <button v-if="showBack" type="button" class="public-portal-subpage-back" aria-label="返回" @click="backToList">‹</button>
          <h1>{{ pageTitle }}</h1>
          <div id="page-header-extra" class="page-header-extra-host"></div>
        </div>
        <div id="page-header-actions" class="page-header-actions-host"></div>
      </div>
      <div class="public-portal-subpage-content">
        <router-view :key="route.fullPath+'|'+actor?.id" />
      </div>
    </main>
  </div>
</template>

<script setup>
import {computed,ref,watch} from 'vue';
import {useRoute,useRouter} from 'vue-router';
import {ChevronDownIcon,NotificationIcon,UserIcon} from 'tdesign-icons-vue-next';
import {MessagePlugin} from 'tdesign-vue-next';
import {actor,logout,portal,revision} from '../services/runtime.js';
import {can} from '../config/pages.js';
import '../styles/portal-home-preview.css';
import '../styles/portal-preview-pages.css';

const route=useRoute();
const router=useRouter();
const accountOpen=ref(false);
const unread=ref(0);
const displayName=computed(()=>(actor.value?.name||'用户').replace(/\s*·\s*演示$|演示|模拟/g,'').trim());
const pageTitle=computed(()=>route.meta.resource==='messages'&&route.query.messageId?'消息详情':route.meta.resource==='announcementDetail'?'公告详情':route.meta.title||'');
const showBack=computed(()=>route.meta.resource==='announcementDetail'||(route.meta.resource==='messages'&&Boolean(route.query.messageId)));

function isActive(resource){
  if(resource==='home')return route.path==='/portal-preview/home';
  if(resource==='announcements')return route.path.startsWith('/portal-preview/announcements');
  return route.path.startsWith('/portal-preview/'+resource);
}
function backToList(){
  if(route.meta.resource==='messages'){router.replace('/portal-preview/messages');return;}
  if(route.meta.resource==='announcementDetail')router.push('/portal-preview/announcements');
}
async function exitSystem(){
  accountOpen.value=false;
  try{await logout();router.replace('/login');}
  catch(error){MessagePlugin.error(error?.message||'退出失败');}
}

watch(()=>route.fullPath,()=>{accountOpen.value=false;});
watch([actor,revision],async(_,__,onCleanup)=>{
  let active=true;
  onCleanup(()=>{active=false;});
  unread.value=0;
  if(!actor.value)return;
  const result=await portal.read('home');
  if(active&&result.ok)unread.value=result.data.unreadCount||0;
},{immediate:true});
</script>
