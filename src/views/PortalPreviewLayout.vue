<template>
  <div class="public-portal-shell public-portal-secondary-shell">
    <header class="public-portal-header">
      <div class="public-portal-header-inner">
        <button class="public-portal-brand" type="button" @click="go('/home')">
          <span class="public-portal-brand-copy">
            <strong>卫健XC统一门户</strong>
            <small>便民 · 协同 · 服务</small>
          </span>
        </button>

        <nav class="public-portal-nav" aria-label="公众门户导航">
          <button type="button" :class="{active:isActive('home')}" @click="go('/home')">首页</button>
          <button type="button" :class="{active:isActive('todos')}" @click="go('/todos')">待办任务</button>
          <button type="button" :class="{active:isActive('messages')}" @click="go('/messages')">消息中心</button>
          <button type="button" :class="{active:isActive('announcements')}" @click="go('/announcements')">通知公告</button>
          <button type="button" :class="{active:isActive('apps')}" @click="go('/apps/all')">应用中心</button>
          <button type="button" :class="{active:isActive('applications')}" @click="go('/applications')">我的申请</button>
        </nav>

        <div class="public-portal-user-area">
          <t-badge size="small" :count="unread" :max-count="99" :show-zero="false">
            <button class="public-portal-icon-button" type="button" aria-label="消息中心" @click="go('/messages')">
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
                <button type="button" @click="go('/profile')">个人中心</button>
                <button v-if="can(actor,'any')" type="button" @click="router.push('/admin/home')">平台管理端</button>
                <button class="danger" type="button" @click="exitSystem">退出系统</button>
              </div>
            </template>
          </t-popup>
        </div>
      </div>
    </header>

    <main class="public-portal-subpage-wrap">
      <div v-if="showSubpageHead" class="public-portal-subpage-head">
        <div class="public-portal-subpage-title-row">
          <button v-if="showBack" type="button" class="public-portal-subpage-back" aria-label="返回" @click="backToList">‹</button>
          <h1>{{ pageTitle }}</h1>
          <div id="page-header-extra" class="page-header-extra-host"></div>
        </div>
        <div class="public-portal-subpage-actions">
          <div id="page-header-actions" class="page-header-actions-host"></div>
        </div>
      </div>
      <section v-if="isAppCenterPage" class="public-announcement-banner public-app-center-banner" :style="{backgroundImage:`url('${announcementBanner}')`}">
        <div class="public-announcement-banner-copy">
          <strong>应用中心</strong>
          <span>汇聚卫生健康服务应用 · 便捷访问常用业务系统</span>
        </div>
      </section>
      <section v-if="isAnnouncementListPage" class="public-announcement-banner" :style="{backgroundImage:`url('${announcementBanner}')`}">
        <div class="public-announcement-banner-copy">
          <strong>通知公告</strong>
          <span>及时了解平台通知与重要信息</span>
        </div>
      </section>
      <section v-if="isMessageListPage" class="public-announcement-banner public-message-center-banner" :style="{backgroundImage:`url('${announcementBanner}')`}">
        <div class="public-announcement-banner-copy">
          <strong>消息中心</strong>
          <span>集中查看业务消息与系统通知</span>
        </div>
      </section>
      <div class="public-portal-subpage-content">
        <router-view :key="route.path+'|'+actor?.id" />
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
import announcementBanner from '../assets/login-health3-bg-3840x2160.png';

const route=useRoute();
const router=useRouter();
const accountOpen=ref(false);
const unread=ref(0);
const isPreviewRoute=computed(()=>route.path.startsWith('/portal-preview'));
const portalBase=computed(()=>isPreviewRoute.value?'/portal-preview':'/portal');
const displayName=computed(()=>(actor.value?.name||'用户').replace(/\s*·\s*演示$|演示|模拟/g,'').trim());
const pageTitle=computed(()=>route.meta.resource==='messages'&&route.query.messageId?'消息详情':route.meta.resource==='announcementDetail'?'公告详情':route.meta.title||'');
const showBack=computed(()=>route.meta.resource==='announcementDetail'||(route.meta.resource==='messages'&&Boolean(route.query.messageId)));
const isAppCenterPage=computed(()=>['apps','mine'].includes(route.meta.resource));
const isAnnouncementListPage=computed(()=>route.meta.resource==='announcements');
const isMessageListPage=computed(()=>route.meta.resource==='messages'&&!route.query.messageId);
const showSubpageHead=computed(()=>!isAppCenterPage.value&&!isAnnouncementListPage.value&&!isMessageListPage.value);

function go(path){
  const target=isPreviewRoute.value&&path==='/apps/all'?'/apps':path;
  router.push(portalBase.value+target);
}
function isActive(resource){
  const current=route.meta.resource;
  if(resource==='home')return current==='home'||current==='portalHomePreview';
  if(resource==='announcements')return ['announcements','announcementDetail'].includes(current);
  if(resource==='apps')return ['apps','mine'].includes(current);
  if(resource==='applications')return current==='myApplicationRequests';
  return current===resource;
}
function backToList(){
  if(route.meta.resource==='messages'){router.replace(portalBase.value+'/messages');return;}
  if(route.meta.resource==='announcementDetail')router.push(portalBase.value+'/announcements');
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
  const result=await portal.read('header');
  if(active&&result.ok)unread.value=result.data.unreadCount||0;
},{immediate:true});
</script>
