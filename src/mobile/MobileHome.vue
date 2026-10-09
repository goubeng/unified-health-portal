<template>
  <div class="mobile-home">
    <section class="mobile-home-hero">
      <p class="mobile-home-kicker">卫健 XC · 便民服务</p>
      <h1>健康服务，一站直达</h1>
    </section>

    <div v-if="error" class="mobile-home-error" role="alert">{{ error }}<MobileButton size="small" variant="text" @click="load">重试</MobileButton></div>
    <div v-if="loading" class="mobile-home-loading">正在加载服务内容…</div>

    <template v-else>
      <section class="mobile-home-section mobile-home-section--first">
        <div class="mobile-home-section-head"><div><h2>我的应用</h2></div><button type="button" @click="go('/m/apps')">全部应用</button></div>
        <div v-if="mine.length" class="mobile-home-app-grid">
          <button v-for="(app, index) in mine.slice(0, APP_PREVIEW_LIMIT)" :key="app.id" type="button" @click="openApp(app)">
            <span class="mobile-home-app-icon" :class="`tone-${index % APP_TONE_COUNT}`"><AppIcon /></span>
            <span class="mobile-home-app-name">{{ app.name }}</span>
          </button>
        </div>
        <p v-else class="mobile-home-empty">暂无可用应用，前往全部应用看看</p>
      </section>

      <section class="mobile-home-notice-card" aria-label="最新公告">
        <button type="button" class="notice-badge" aria-label="查看全部通知公告" @click="go('/m/announcements')">
          <span class="notice-badge-top">最新</span>
          <span class="notice-badge-bottom">
            <span class="notice-badge-text">公告</span>
            <i class="notice-badge-highlight" aria-hidden="true"></i>
          </span>
        </button>

        <div
          class="notice-slider"
          @mouseenter="pauseNoticeScroll"
          @mouseleave="resumeNoticeScroll"
          @touchstart.passive="pauseNoticeScroll"
          @touchend.passive="resumeNoticeScroll"
        >
          <div
            v-if="announcements.length"
            class="notice-track"
            :style="noticeTrackStyle"
            @transitionend="handleNoticeTransitionEnd"
          >
            <button
              v-for="(item, idx) in scrollingAnnouncements"
              :key="`${item.id}-${idx}`"
              type="button"
              class="notice-row"
              @click="go(`/m/announcements/${encodeURIComponent(item.id)}`)"
            >
              <span class="notice-row-title">{{ item.title }}</span>
              <ChevronRightIcon class="notice-row-arrow" />
            </button>
          </div>
          <div v-else class="notice-empty">暂无最新公告</div>
        </div>
      </section>

      <section class="mobile-home-section">
        <div class="mobile-home-section-head"><div><h2>待办事项 <span v-if="pendingTodoCount > 0" class="todo-badge">{{ pendingTodoCount }}</span></h2></div><button type="button" @click="go('/m/todos')">查看全部</button></div>
        <div v-if="pendingTodos.length" class="mobile-home-feed">
          <button v-for="item in pendingTodos.slice(0, FEED_PREVIEW_LIMIT)" :key="item.id" type="button" @click="go('/m/todos')">
            <span class="mobile-home-feed-dot"></span>
            <span class="mobile-home-feed-copy">
              <span class="mobile-home-feed-top">
                <strong>{{ item.title }}</strong>
              </span>
              <small class="mobile-home-feed-meta">
                <span class="feed-meta-item meta-app">
                  <AppIcon class="meta-icon" />
                  <span>{{ item.appName || '业务事项' }}</span>
                </span>
                <span class="feed-meta-item meta-time">
                  <TimeIcon class="meta-icon" />
                  <span>{{ date(item.receivedAt) }}</span>
                </span>
              </small>
            </span>
            <ChevronRightIcon />
          </button>
        </div>
        <div v-else class="mobile-home-todo-empty">
          <img :src="nopicSvg" alt="暂无待办事项" />
          <p>暂无待办事项</p>
        </div>
      </section>
    </template>
  </div>
</template>

<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue';
import { useRouter } from 'vue-router';
import { Button as MobileButton } from 'tdesign-mobile-vue';
import { AppIcon, ChevronRightIcon, TimeIcon } from 'tdesign-icons-vue-next';
import { command, portal, revision } from '../services/runtime.js';
import { date } from '../components/portal/presentation.js';
import nopicSvg from '../assets/nopic.svg';

type PortalRow = { id: string; title?: string; name?: string; appName?: string; type?: string; status?: string; receivedAt?: string; publishedAt?: string; sortOrder?: number; ssoRuntimeStatus?: string; businessType?: string };
type Overview = { todoCount?: number; unreadCount?: number; unreadAnnouncementCount?: number };
const APP_PREVIEW_LIMIT = 8;
const APP_TONE_COUNT = 4;
const FEED_PREVIEW_LIMIT = 3;
const NOTICE_LINE_HEIGHT_PX = 28;
const NOTICE_VISIBLE_ROWS = 2;
const NOTICE_SCROLL_INTERVAL_MS = 3500;

const router = useRouter();
const loading = ref(true);
const error = ref('');
const overview = ref<Overview>({});
const mine = ref<PortalRow[]>([]);
const pendingTodos = ref<PortalRow[]>([]);
const announcements = ref<PortalRow[]>([]);
const noticeScrollOffset = ref(0);
const noticeTransitionEnabled = ref(true);
let noticeTimer: ReturnType<typeof setInterval> | null = null;

const pendingTodoCount = computed(() => overview.value.todoCount ?? pendingTodos.value.length);

const scrollingAnnouncements = computed(() => {
  if (announcements.value.length <= NOTICE_VISIBLE_ROWS) {
    return announcements.value;
  }
  return [...announcements.value, ...announcements.value.slice(0, NOTICE_VISIBLE_ROWS)];
});

const noticeTrackStyle = computed(() => ({
  transform: `translateY(-${noticeScrollOffset.value * NOTICE_LINE_HEIGHT_PX}px)`,
  transition: noticeTransitionEnabled.value ? 'transform 0.45s ease' : 'none',
}));

function go(path: string, query?: Record<string, string>) { router.push({ path, query }); }
function newest(rows: PortalRow[], field: 'receivedAt' | 'publishedAt') { return [...rows].sort((a, b) => (Date.parse(b[field] || '') || 0) - (Date.parse(a[field] || '') || 0)); }
async function read(resource: string) { const response = await portal.read(resource); if (!response.ok) throw new Error(response.error.message); return response.data; }

function startNoticeScroll() {
  stopNoticeScroll();
  if (announcements.value.length <= NOTICE_VISIBLE_ROWS) return;
  noticeTimer = setInterval(() => {
    noticeTransitionEnabled.value = true;
    noticeScrollOffset.value++;
  }, NOTICE_SCROLL_INTERVAL_MS);
}

function stopNoticeScroll() {
  if (noticeTimer) {
    clearInterval(noticeTimer);
    noticeTimer = null;
  }
}

function handleNoticeTransitionEnd() {
  if (noticeScrollOffset.value >= announcements.value.length) {
    noticeTransitionEnabled.value = false;
    noticeScrollOffset.value = 0;
  }
}

function pauseNoticeScroll() {
  stopNoticeScroll();
}

function resumeNoticeScroll() {
  startNoticeScroll();
}

async function load() {
  loading.value = true; error.value = '';
  try {
    const [home, apps, todos, notices] = await Promise.all([read('home'), read('mine'), read('todos'), read('announcements')]);
    overview.value = home || {};
    mine.value = [...(apps || [])].sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0));
    pendingTodos.value = newest((todos || []).filter((item: PortalRow) => item.status === 'PENDING'), 'receivedAt');
    announcements.value = newest(notices || [], 'publishedAt');
    noticeScrollOffset.value = 0;
    noticeTransitionEnabled.value = false;
    startNoticeScroll();
  } catch (cause) { error.value = cause instanceof Error ? cause.message : '首页加载失败'; }
  finally { loading.value = false; }
}

async function openApp(app: PortalRow) {
  if (app.ssoRuntimeStatus !== 'NORMAL') { window.alert('应用入口暂不可用，请稍后重试'); return; }
  const result = await command('enterApp', { id: app.id });
  window.alert(result.ok ? result.data.message : result.error.message);
}

onMounted(load);
onBeforeUnmount(stopNoticeScroll);
watch(revision, load);
</script>

<style scoped>
.mobile-home{padding:0 16px 28px;color:#172b48}.mobile-home-hero{position:relative;margin:0 -16px 0;min-height:160px;padding:22px 20px 36px;background-image:url('../assets/login-health3-bg-3840x2160.png');background-size:cover;background-position:0% 48%;background-repeat:no-repeat;overflow:hidden;display:flex;flex-direction:column;justify-content:center;align-items:flex-end;text-align:right}.mobile-home-hero::after{content:"";position:absolute;left:0;right:0;bottom:0;height:36px;background:linear-gradient(to bottom,rgba(244,247,251,0) 0%,rgba(244,247,251,.45) 55%,#f4f7fb 100%);pointer-events:none}.mobile-home-kicker{position:relative;z-index:1;margin:0 0 6px;font-size:13px;letter-spacing:1.5px;font-weight:600;color:#0052d9;text-shadow:0 1px 3px #fff,0 0 8px rgba(255,255,255,.95)}.mobile-home-hero h1{position:relative;z-index:1;margin:0;font-size:22px;letter-spacing:.5px;font-weight:700;color:#062b59;text-shadow:0 1px 3px #fff,0 0 12px rgba(255,255,255,.9)}.mobile-home-section{position:relative;z-index:1;margin-bottom:14px;padding:18px 16px;background:#fff;border:1px solid #edf2f7;border-radius:20px;box-shadow:0 4px 16px rgba(18,52,95,.04)}.mobile-home-section--first{margin-top:-24px;z-index:2;border:1px solid rgba(255,255,255,.95);box-shadow:0 8px 24px rgba(16,54,99,.08)}.mobile-home-section-head{display:flex;align-items:center;justify-content:space-between;margin-bottom:15px}.mobile-home-section-head h2{margin:0;font-size:17px;font-weight:600}.todo-badge{display:inline-flex;align-items:center;justify-content:center;min-width:18px;height:18px;padding:0 6px;margin-left:6px;border-radius:9px;background:#e34d59;color:#fff;font-size:12px;font-weight:600;line-height:1;vertical-align:1px}.mobile-home-section-head>button{display:flex;align-items:center;gap:2px;border:0;background:transparent;color:#71839b;font-size:13px}.mobile-home-section-head svg{width:15px;height:15px}.mobile-home-app-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:18px 6px}.mobile-home-app-grid button{display:flex;align-items:center;flex-direction:column;gap:8px;min-width:0;border:0;background:none;color:#253b59;font-size:12px}.mobile-home-app-grid button>span:last-child,.mobile-home-app-name{display:-webkit-box;-webkit-box-orient:vertical;-webkit-line-clamp:2;line-clamp:2;overflow:hidden;text-overflow:ellipsis;width:100%;max-width:100%;height:2.8em;line-height:1.4;word-break:break-all;text-align:center}.mobile-home-app-icon{display:grid;place-items:center;width:49px;height:49px;border-radius:15px;background:#ecf2fe;color:#0052d9}.mobile-home-app-icon svg{width:24px;height:24px}.mobile-home-app-icon.tone-1{background:#e7f6ef;color:#209768}.mobile-home-app-icon.tone-2{background:#fff2e4;color:#d98927}.mobile-home-app-icon.tone-3{background:#efeaff;color:#785fc0}.mobile-home-feed{display:grid}.mobile-home-feed button{display:flex;align-items:center;gap:10px;width:100%;min-height:57px;padding:10px 0;border:0;border-top:1px solid #eef2f6;background:none;text-align:left;color:#6f8097}.mobile-home-feed button:first-child{border-top:0}.mobile-home-feed-copy{display:flex;flex:1;flex-direction:column;gap:5px;min-width:0}.mobile-home-feed-top{display:flex;align-items:center;justify-content:space-between;gap:8px}.todo-type-tag{display:inline-flex;align-items:center;padding:1px 6px;border-radius:4px;background:#ecf2fe;color:#0052d9;font-size:11px;font-weight:500;flex-shrink:0}.mobile-home-feed-copy strong{overflow:hidden;color:#253b59;font-size:14px;font-weight:600;text-overflow:ellipsis;white-space:nowrap}.mobile-home-feed-copy small{font-size:12px;color:#8899ad}.mobile-home-feed-meta{display:flex;align-items:center;flex-wrap:nowrap;gap:8px;font-size:12px;color:#8899ad;width:100%;overflow:hidden;line-height:1.2}.feed-meta-item{display:inline-flex;align-items:center;gap:3px;white-space:nowrap;flex-shrink:0}.feed-meta-item svg,.feed-meta-item .meta-icon{width:12px;height:12px;flex:none;color:#9cb0c2}.feed-meta-item.meta-type{color:#718598;font-weight:400;flex-shrink:0}.feed-meta-item.meta-type svg{color:#9cb0c2}.feed-meta-item.meta-app{color:#4b6279;flex-shrink:1;min-width:0;overflow:hidden;text-overflow:ellipsis}.feed-meta-item.meta-app span{overflow:hidden;text-overflow:ellipsis;white-space:nowrap}.feed-meta-item.meta-time{color:#8c9ea0;flex-shrink:0;margin-left:0}.mobile-home-feed svg{width:15px;height:15px;flex:none}.mobile-home-feed-dot{width:7px;height:7px;border-radius:50%;background:#f2a345;flex:none}.mobile-home-todo-empty{display:flex;flex-direction:column;align-items:center;justify-content:center;padding:22px 0 14px;text-align:center}.mobile-home-todo-empty img{width:112px;height:auto;max-width:100%;margin-bottom:8px;opacity:.9}.mobile-home-todo-empty p{margin:0;color:#91a0b1;font-size:14px}.mobile-home-notice-card{display:flex;align-items:center;gap:16px;margin-bottom:14px;padding:12px 14px;background:#fff;border:1px solid #edf1f7;border-radius:18px;box-shadow:0 4px 16px rgba(22,53,90,.035)}.notice-badge{display:flex;flex-direction:column;align-items:center;justify-content:center;flex:none;padding:0 2px;border:0;background:none;cursor:pointer;line-height:1.12;font-weight:900;font-style:italic;letter-spacing:1px}.notice-badge-top{font-size:20px;font-weight:900;color:#e83f2c;-webkit-text-stroke:.5px #e83f2c;text-shadow:.3px 0 0 #e83f2c,-.3px 0 0 #e83f2c;transform:skewX(-5deg)}.notice-badge-bottom{position:relative;display:inline-flex;align-items:center;justify-content:center;margin-top:2px}.notice-badge-text{position:relative;z-index:1;font-size:20px;font-weight:900;color:#e83f2c;-webkit-text-stroke:.5px #e83f2c;text-shadow:.3px 0 0 #e83f2c,-.3px 0 0 #e83f2c;transform:skewX(-5deg)}.notice-badge-highlight{position:absolute;left:-3px;right:-3px;bottom:1px;height:8px;background:#ffe39a;border-radius:4px;z-index:0}.notice-slider{flex:1;min-width:0;height:56px;overflow:hidden;position:relative}.notice-track{display:flex;flex-direction:column}.notice-row{display:flex;align-items:center;justify-content:space-between;width:100%;height:28px;min-height:28px;padding:0;border:0;background:none;color:inherit;text-align:left;cursor:pointer}.notice-row-title{flex:1;min-width:0;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-size:14px;font-weight:500;color:#253549;line-height:28px}.notice-row-arrow{width:14px;height:14px;flex:none;color:#aebbc8;margin-left:6px}.notice-empty{display:flex;align-items:center;height:56px;font-size:14px;color:#91a0b1}.mobile-home-empty,.mobile-home-loading{margin:0;padding:16px 0;color:#91a0b1;font-size:14px;text-align:center}.mobile-home-error{display:flex;align-items:center;justify-content:space-between;margin:0 0 14px;padding:10px 14px;border-radius:12px;background:#fff4f1;color:#b44a39;font-size:13px}
</style>
