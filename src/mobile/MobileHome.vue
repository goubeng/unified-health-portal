<template>
  <div class="mobile-home">
    <section class="mobile-home-hero">
      <p class="mobile-home-kicker">卫健 XC · 便民服务</p>
      <h1>健康服务，一站直达</h1>
      <p>您好，{{ displayName }}。您需要的服务都在这里。</p>
      <div class="mobile-home-hero-actions">
        <button type="button" @click="go('/m/todos')"><strong>{{ overview.todoCount ?? 0 }}</strong><span>待办事项</span></button>
        <button type="button" @click="go('/m/messages')"><strong>{{ overview.unreadCount ?? 0 }}</strong><span>未读消息</span></button>
        <button type="button" @click="go('/m/announcements')"><strong>{{ overview.unreadAnnouncementCount ?? 0 }}</strong><span>新公告</span></button>
      </div>
    </section>

    <div v-if="error" class="mobile-home-error" role="alert">{{ error }}<MobileButton size="small" variant="text" @click="load">重试</MobileButton></div>
    <div v-if="loading" class="mobile-home-loading">正在加载服务内容…</div>

    <template v-else>
      <section class="mobile-home-section">
        <div class="mobile-home-section-head"><div><small>快捷入口</small><h2>我的应用</h2></div><button type="button" @click="go('/m/apps')">全部应用 <ChevronRightIcon /></button></div>
        <div v-if="mine.length" class="mobile-home-app-grid">
          <button v-for="(app, index) in mine.slice(0, APP_PREVIEW_LIMIT)" :key="app.id" type="button" @click="openApp(app)">
            <span class="mobile-home-app-icon" :class="`tone-${index % APP_TONE_COUNT}`"><AppIcon /></span>
            <span>{{ app.name }}</span>
          </button>
        </div>
        <p v-else class="mobile-home-empty">暂无可用应用，前往全部应用看看</p>
      </section>

      <section class="mobile-home-section">
        <div class="mobile-home-section-head"><div><small>要事提醒</small><h2>待办事项 <em>{{ overview.todoCount ?? pendingTodos.length }}</em></h2></div><button type="button" @click="go('/m/todos')">查看全部 <ChevronRightIcon /></button></div>
        <div v-if="pendingTodos.length" class="mobile-home-feed">
          <button v-for="item in pendingTodos.slice(0, FEED_PREVIEW_LIMIT)" :key="item.id" type="button" @click="go('/m/todos', { todoId: item.id })">
            <span class="mobile-home-feed-dot"></span><span class="mobile-home-feed-copy"><strong>{{ item.title }}</strong><small>{{ item.appName || '业务事项' }} · {{ formatDate(item.receivedAt) }}</small></span><ChevronRightIcon />
          </button>
        </div>
        <p v-else class="mobile-home-empty">暂无待办事项</p>
      </section>

      <section class="mobile-home-section">
        <div class="mobile-home-section-head"><div><small>及时知晓</small><h2>消息中心 <em>{{ overview.unreadCount ?? unreadMessages.length }}</em></h2></div><button type="button" @click="go('/m/messages')">查看全部 <ChevronRightIcon /></button></div>
        <div v-if="unreadMessages.length" class="mobile-home-feed">
          <button v-for="item in unreadMessages.slice(0, FEED_PREVIEW_LIMIT)" :key="item.id" type="button" @click="go('/m/messages', { messageId: item.id })">
            <span class="mobile-home-feed-dot"></span><span class="mobile-home-feed-copy"><strong>{{ item.title }}</strong><small>{{ item.appName || '平台消息' }} · {{ formatDate(item.receivedAt) }}</small></span><ChevronRightIcon />
          </button>
        </div>
        <p v-else class="mobile-home-empty">暂无未读消息</p>
      </section>

      <section class="mobile-home-section mobile-home-announcements">
        <div class="mobile-home-section-head"><div><small>平台动态</small><h2>通知公告</h2></div><button type="button" @click="go('/m/announcements')">查看全部 <ChevronRightIcon /></button></div>
        <div v-if="announcements.length" class="mobile-home-feed">
          <button v-for="item in announcements.slice(0, FEED_PREVIEW_LIMIT)" :key="item.id" type="button" @click="go(`/m/announcements/${encodeURIComponent(item.id)}`)">
            <span class="mobile-home-notice-mark">{{ dateDay(item.publishedAt) }}</span><span class="mobile-home-feed-copy"><strong>{{ item.title }}</strong><small>{{ item.type || '通知' }} · {{ formatDate(item.publishedAt) }}</small></span><ChevronRightIcon />
          </button>
        </div>
        <p v-else class="mobile-home-empty">暂无通知公告</p>
      </section>
    </template>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue';
import { useRouter } from 'vue-router';
import { Button as MobileButton } from 'tdesign-mobile-vue';
import { AppIcon, ChevronRightIcon } from 'tdesign-icons-vue-next';
import { command, portal, revision } from '../services/runtime.js';
import { mobileActor as actor } from './mobileActor';

type PortalRow = { id: string; title?: string; name?: string; appName?: string; type?: string; status?: string; receivedAt?: string; publishedAt?: string; sortOrder?: number; ssoRuntimeStatus?: string };
type Overview = { todoCount?: number; unreadCount?: number; unreadAnnouncementCount?: number };
const APP_PREVIEW_LIMIT = 8;
const APP_TONE_COUNT = 4;
const FEED_PREVIEW_LIMIT = 3;
const router = useRouter();
const loading = ref(true);
const error = ref('');
const overview = ref<Overview>({});
const mine = ref<PortalRow[]>([]);
const pendingTodos = ref<PortalRow[]>([]);
const unreadMessages = ref<PortalRow[]>([]);
const announcements = ref<PortalRow[]>([]);
const displayName = computed(() => String(actor.value?.name || '用户').replace(/\s*·\s*演示$|演示|模拟/g, '').trim());

function go(path: string, query?: Record<string, string>) { router.push({ path, query }); }
function formatDate(value?: string) { const time = Date.parse(value || ''); return Number.isFinite(time) ? new Intl.DateTimeFormat('zh-CN', { month: '2-digit', day: '2-digit' }).format(time) : '暂无时间'; }
function dateDay(value?: string) { const time = Date.parse(value || ''); return Number.isFinite(time) ? String(new Date(time).getDate()).padStart(2, '0') : '--'; }
function newest(rows: PortalRow[], field: 'receivedAt' | 'publishedAt') { return [...rows].sort((a, b) => (Date.parse(b[field] || '') || 0) - (Date.parse(a[field] || '') || 0)); }
async function read(resource: string) { const response = await portal.read(resource); if (!response.ok) throw new Error(response.error.message); return response.data; }
async function load() {
  loading.value = true; error.value = '';
  try {
    const [home, apps, todos, messages, notices] = await Promise.all([read('home'), read('mine'), read('todos'), read('messages'), read('announcements')]);
    overview.value = home || {};
    mine.value = [...(apps || [])].sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0));
    pendingTodos.value = newest((todos || []).filter((item: PortalRow) => item.status === 'PENDING'), 'receivedAt');
    unreadMessages.value = newest((messages || []).filter((item: PortalRow) => item.status === 'UNREAD'), 'receivedAt');
    announcements.value = newest(notices || [], 'publishedAt');
  } catch (cause) { error.value = cause instanceof Error ? cause.message : '首页加载失败'; }
  finally { loading.value = false; }
}
async function openApp(app: PortalRow) {
  if (app.ssoRuntimeStatus !== 'NORMAL') { window.alert('应用入口暂不可用，请稍后重试'); return; }
  const result = await command('enterApp', { id: app.id });
  window.alert(result.ok ? result.data.message : result.error.message);
}
onMounted(load);
watch(revision, load);
</script>

<style scoped>
.mobile-home{padding:0 16px 28px;color:#172b48}.mobile-home-hero{margin:0 -16px 16px;padding:28px 20px 22px;background:linear-gradient(130deg,#0b55ad,#117cd1 65%,#38a6d3);color:#fff;border-radius:0 0 24px 24px;box-shadow:0 12px 30px rgba(17,99,184,.18)}.mobile-home-kicker{margin:0 0 10px;font-size:12px;letter-spacing:2px;opacity:.85}.mobile-home-hero h1{margin:0;font-size:25px;letter-spacing:.6px;font-weight:600}.mobile-home-hero>p:not(.mobile-home-kicker){margin:9px 0 22px;font-size:14px;opacity:.88}.mobile-home-hero-actions{display:grid;grid-template-columns:repeat(3,1fr);gap:9px}.mobile-home-hero-actions button{display:flex;flex-direction:column;gap:5px;align-items:flex-start;padding:12px 14px;border:1px solid rgba(255,255,255,.25);border-radius:14px;background:rgba(255,255,255,.13);color:#fff;text-align:left}.mobile-home-hero-actions strong{font-size:23px;line-height:1;font-weight:700}.mobile-home-hero-actions span{font-size:12px}.mobile-home-section{margin-bottom:14px;padding:17px 15px;background:#fff;border:1px solid #ecf1f7;border-radius:18px;box-shadow:0 4px 16px rgba(22,53,90,.035)}.mobile-home-section-head{display:flex;align-items:center;justify-content:space-between;margin-bottom:15px}.mobile-home-section-head small{font-size:12px;letter-spacing:1px;color:#8899ad}.mobile-home-section-head h2{margin:3px 0 0;font-size:17px;font-weight:600}.mobile-home-section-head em{font-size:13px;font-style:normal;color:#1476c6;font-weight:600}.mobile-home-section-head>button{display:flex;align-items:center;gap:2px;border:0;background:transparent;color:#71839b;font-size:13px}.mobile-home-section-head svg{width:15px;height:15px}.mobile-home-app-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:18px 6px}.mobile-home-app-grid button{display:flex;align-items:center;flex-direction:column;gap:8px;min-width:0;border:0;background:none;color:#253b59;font-size:12px}.mobile-home-app-grid button>span:last-child{max-width:100%;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}.mobile-home-app-icon{display:grid;place-items:center;width:49px;height:49px;border-radius:15px;background:#e4f2ff;color:#1879cf}.mobile-home-app-icon svg{width:24px;height:24px}.mobile-home-app-icon.tone-1{background:#e7f6ef;color:#209768}.mobile-home-app-icon.tone-2{background:#fff2e4;color:#d98927}.mobile-home-app-icon.tone-3{background:#efeaff;color:#785fc0}.mobile-home-feed{display:grid}.mobile-home-feed button{display:flex;align-items:center;gap:10px;width:100%;min-height:57px;padding:10px 0;border:0;border-top:1px solid #eef2f6;background:none;text-align:left;color:#6f8097}.mobile-home-feed button:first-child{border-top:0}.mobile-home-feed-copy{display:flex;flex:1;flex-direction:column;gap:5px;min-width:0}.mobile-home-feed-copy strong{overflow:hidden;color:#253b59;font-size:14px;font-weight:600;text-overflow:ellipsis;white-space:nowrap}.mobile-home-feed-copy small{font-size:12px;color:#8899ad}.mobile-home-feed svg{width:15px;height:15px;flex:none}.mobile-home-feed-dot{width:7px;height:7px;border-radius:50%;background:#f2a345;flex:none}.mobile-home-notice-mark{display:grid;place-items:center;width:36px;height:36px;border-radius:9px;background:#e8f3ff;color:#1476c6;font-weight:700;flex:none;font-size:15px}.mobile-home-empty,.mobile-home-loading{margin:0;padding:16px 0;color:#91a0b1;font-size:14px;text-align:center}.mobile-home-error{display:flex;align-items:center;justify-content:space-between;margin:0 0 14px;padding:10px 14px;border-radius:12px;background:#fff4f1;color:#b44a39;font-size:13px}
</style>
