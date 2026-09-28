<template>
  <div class="public-portal-shell">
    <header class="public-portal-header">
      <div class="public-portal-header-inner">
        <button class="public-portal-brand" type="button" @click="go('home')">
          <span class="public-portal-brand-copy">
            <strong>卫健XC统一门户</strong>
            <small>便民 · 协同 · 服务</small>
          </span>
        </button>

        <nav class="public-portal-nav" aria-label="公众门户导航">
          <button class="active" type="button">首页</button>
          <button type="button" @click="go('todos')">待办任务</button>
          <button type="button" @click="go('messages')">消息中心</button>
          <button type="button" @click="go('announcements')">通知公告</button>
          <button type="button" @click="go('apps')">应用中心</button>
          <button type="button" @click="go('applications')">我的申请</button>
        </nav>

        <div class="public-portal-user-area">
          <t-badge size="small" :count="overview.unreadCount || 0" :max-count="99" :show-zero="false">
            <button class="public-portal-icon-button" type="button" aria-label="消息中心" @click="go('messages')">
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
                <button type="button" @click="go('profile')">个人中心</button>
                <button v-if="can(actor,'any')" type="button" @click="router.push('/admin/home')">平台管理端</button>
                <button class="danger" type="button" @click="exitSystem">退出系统</button>
              </div>
            </template>
          </t-popup>
        </div>
      </div>
    </header>

    <main>
      <section class="public-portal-hero" :style="{backgroundImage: heroBackground}">
        <div class="public-portal-hero-mask"></div>
        <div class="public-portal-hero-content">
          <h1>统一入口 · 集约服务 · 协同共享</h1>
          <p>打造高效、便捷、安全的卫生健康服务平台</p>
        </div>
      </section>

      <div class="public-portal-main">
        <section class="public-portal-feed-grid">
          <article class="public-portal-card public-portal-feed-card">
            <div class="public-portal-section-head">
              <h2><span class="feed-title-icon todo-title"><TaskIcon /></span> 我的待办 <span class="feed-count">（<b>{{ overview.todoCount ?? homeTodos.length }}</b>）</span></h2>
              <button type="button" @click="go('todos')">查看全部 <ChevronRightIcon size="16px" /></button>
            </div>
            <button v-for="item in homeTodos.slice(0,4)" :key="item.id" class="public-portal-todo-row" type="button" @click="openTodo(item)">
              <span class="todo-dot"></span>
              <span class="public-portal-row-main">
                <strong>{{ text(item.title) }}</strong>
                <small>来自：{{ text(item.appName) }} <i></i> {{ date(item.receivedAt) }}</small>
              </span>
            </button>
            <div v-if="!homeTodos.length && !loading" class="public-portal-empty">暂无待办</div>
          </article>

          <article class="public-portal-card public-portal-feed-card">
            <div class="public-portal-section-head">
              <h2><span class="feed-title-icon message"><MailIcon /></span> 消息中心 <span class="feed-count">（<b>{{ overview.unreadCount ?? homeMessages.length }}</b>）</span></h2>
              <button type="button" @click="go('messages')">查看全部 <ChevronRightIcon size="16px" /></button>
            </div>
            <button v-for="item in homeMessages.slice(0,5)" :key="item.id" class="public-portal-message-row" type="button" @click="openMessage(item)">
              <span class="todo-dot"></span>
              <span class="public-portal-row-main">
                <strong>{{ text(item.title) }}</strong>
                <small>来自：{{ text(item.appName) }} <i></i> {{ date(item.receivedAt) }}</small>
              </span>
            </button>
            <div v-if="!homeMessages.length && !loading" class="public-portal-empty">暂无未读消息</div>
          </article>

          <article class="public-portal-card public-portal-feed-card">
            <div class="public-portal-section-head">
              <h2><span class="feed-title-icon notice"><NotificationIcon /></span> 通知公告 <span class="feed-count">（<b>{{ overview.unreadAnnouncementCount ?? 0 }}</b>）</span></h2>
              <button type="button" @click="go('announcements')">查看全部 <ChevronRightIcon size="16px" /></button>
            </div>
            <button v-for="item in homeAnnouncements.slice(0,5)" :key="item.id" class="public-portal-notice-row" type="button" @click="openAnnouncement(item)">
              <span class="public-portal-notice-date">
                <strong>{{ noticeDay(item.publishedAt) }}</strong>
                <small>{{ noticeMonth(item.publishedAt) }}</small>
              </span>
              <span class="public-portal-notice-copy">
                <strong>{{ text(item.title) }}</strong>
                <small>发布时间：{{ date(item.publishedAt) }}</small>
              </span>
            </button>
            <div v-if="!homeAnnouncements.length && !loading" class="public-portal-empty">暂无公告</div>
          </article>
        </section>

        <section class="public-portal-card public-portal-apps">
          <div class="public-portal-section-head">
            <h2>我的应用 <b>（{{ homeApps.length }}）</b></h2>
            <button type="button" @click="go('apps')">查看更多 <span>›</span></button>
          </div>

          <div v-if="visibleApps.length" class="public-portal-app-grid">
            <button v-for="(app,index) in visibleApps" :key="app.id" type="button" class="public-portal-app-item" @click="enterApp(app)">
              <span class="public-portal-app-icon" :class="'tone-'+(index%7)"><AppIcon /></span>
              <span class="public-portal-app-copy">
                <strong class="public-portal-app-name">{{ text(app.name) }}</strong>
                <small class="public-portal-app-category" :class="categoryTone(app.category)">{{ app.category || '业务应用' }}</small>
              </span>
            </button>
            <button type="button" class="public-portal-app-item" @click="go('apps')">
              <span class="public-portal-app-icon tone-more"><span class="public-portal-grid-glyph">••<br/>••</span></span>
              <span class="public-portal-app-copy">
                <strong class="public-portal-app-name">更多应用</strong>
                <small>查看全部应用</small>
              </span>
            </button>
          </div>
          <div v-else-if="!loading" class="public-portal-inline-empty">暂无应用</div>
          <div v-else class="public-portal-inline-empty">正在加载应用...</div>
        </section>

        <div v-if="error" class="public-portal-error">
          {{ error }}
          <button type="button" @click="load">重新加载</button>
        </div>
      </div>
    </main>
  </div>
</template>

<script setup>
import {computed,onMounted,ref,watch} from 'vue';
import {useRoute,useRouter} from 'vue-router';
import {AppIcon,ChevronDownIcon,ChevronRightIcon,MailIcon,NotificationIcon,TaskIcon,UserIcon} from 'tdesign-icons-vue-next';
import {DialogPlugin,MessagePlugin} from 'tdesign-vue-next';
import {actor,command,logout,portal,revision} from '../services/runtime.js';
import {can} from '../config/pages.js';
import {date,latest,text} from '../components/portal/presentation.js';
import heroImage from '../assets/login-health3-bg-3840x2160.png';
import '../styles/portal-home-preview.css';

const route=useRoute();
const router=useRouter();
const isPreviewRoute=computed(()=>route.path.startsWith('/portal-preview'));
const portalBase=computed(()=>isPreviewRoute.value?'/portal-preview':'/portal');
const loading=ref(true);
const error=ref('');
const overview=ref({});
const homeApps=ref([]);
const homeTodos=ref([]);
const homeMessages=ref([]);
const homeAnnouncements=ref([]);
const accountOpen=ref(false);
const heroBackground=computed(()=>`url("${heroImage}")`);
const displayName=computed(()=>(actor.value?.name||'用户').replace(/\s*·\s*演示$|演示|模拟/g,'').trim());
const visibleApps=computed(()=>homeApps.value.slice(0,7));
function go(target){
  const map=isPreviewRoute.value
    ? {home:'/home',todos:'/todos',messages:'/messages',announcements:'/announcements',apps:'/apps',applications:'/applications',profile:'/profile'}
    : {home:'/home',todos:'/todos',messages:'/messages',announcements:'/announcements',apps:'/apps/all',applications:'/applications',profile:'/profile'};
  router.push(portalBase.value+(map[target]||'/home'));
}

async function read(key){
  const result=await portal.read(key);
  if(!result.ok)throw new Error(result.error.message);
  return result.data;
}

async function load(){
  loading.value=true;
  error.value='';
  try{
    const [home,mine,todos,messages,announcements]=await Promise.all([
      read('home'),read('mine'),read('todos'),read('messages'),read('announcements')
    ]);
    overview.value=home||{};
    homeApps.value=(mine||[]).slice().sort((a,b)=>(a.sortOrder||0)-(b.sortOrder||0));
    homeTodos.value=latest((todos||[]).filter(item=>item.status==='PENDING'));
    homeMessages.value=latest((messages||[]).filter(item=>item.status==='UNREAD'),'receivedAt');
    homeAnnouncements.value=latest(announcements||[],'publishedAt');
  }catch(cause){
    error.value=cause?.message||'门户首页加载失败';
  }finally{
    loading.value=false;
  }
}

async function enterApp(app){
  try{
    const result=await command('enterApp',{id:app.id});
    if(!result.ok){MessagePlugin.error(text(result.error.message));return;}
    const dialog=DialogPlugin.alert({
      placement:'center',
      header:'应用访问',
      body:text(result.data.message),
      confirmBtn:'知道了',
      onConfirm:()=>dialog.hide()
    });
  }catch(cause){
    MessagePlugin.error(text(cause?.message||'应用访问失败'));
  }
}

function openTodo(){go('todos');}
function openAnnouncement(item){router.push(portalBase.value+'/announcements/'+encodeURIComponent(item.id));}
function openMessage(item){router.push({path:portalBase.value+'/messages',query:{messageId:item.id}});}
function categoryTone(category){
  const value=text(category)||'业务应用';
  let hash=0;
  for(const char of value)hash=(hash+char.codePointAt(0))%5;
  return 'category-tone-'+(hash+1);
}
function noticeDateParts(value){
  if(!value||!Number.isFinite(Date.parse(value)))return {day:'--',month:'--月'};
  const current=new Date(value);
  return {
    day:String(current.getDate()).padStart(2,'0'),
    month:String(current.getMonth()+1).padStart(2,'0')+'月'
  };
}
function noticeDay(value){return noticeDateParts(value).day;}
function noticeMonth(value){return noticeDateParts(value).month;}
async function exitSystem(){
  accountOpen.value=false;
  try{
    await logout();
    router.replace('/login');
  }catch(cause){
    MessagePlugin.error(text(cause?.message||'退出失败'));
  }
}

onMounted(load);
watch(revision,load);
</script>
