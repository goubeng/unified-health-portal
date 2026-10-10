<template>
  <div class="mobile-home">
    <section class="mobile-home-hero">
      <span class="mobile-home-portal-tag">公众门户</span>
      <p class="mobile-home-kicker">卫健 XC · 便民服务</p>
      <h1>健康服务，一站直达</h1>
    </section>

    <div v-if="error" class="mobile-home-error" role="alert">{{ error }}<MobileButton size="small" variant="text" @click="load">重试</MobileButton></div>
    <div v-if="loading" class="mobile-home-loading"><MobileLoading message="正在加载服务内容…" /></div>

    <template v-else>
      <section class="mobile-home-section mobile-home-section--first">
        <div class="mobile-home-section-head"><div><h2>我的应用</h2></div><button type="button" @click="go('/m/apps')">全部应用</button></div>
        <div v-if="mine.length" class="mobile-home-app-grid">
          <button v-for="app in mine.slice(0, APP_PREVIEW_LIMIT)" :key="app.id" type="button" @click="openApp(app)">
            <div class="mobile-home-app-icon">
              <CategoryAppIcon :category="app.category" />
            </div>
            <span class="mobile-home-app-name">{{ app.name }}</span>
          </button>
        </div>
        <p v-else class="mobile-home-empty">暂无可用应用，前往全部应用看看</p>
      </section>

      <section class="mobile-home-notice-card" aria-label="最新公告">
        <button type="button" class="notice-badge" aria-label="查看全部通知公告" @click="go('/m/announcements')">
          <img v-if="noticeMegaphone" :src="noticeMegaphone" alt="" />
          <span v-else class="notice-megaphone-fallback" aria-hidden="true">📣</span>
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

      <section class="mobile-home-section mobile-home-section--todos">
        <div class="mobile-home-section-head"><div><h2>待办事项 <span v-if="pendingTodoCount > 0" class="todo-badge">{{ pendingTodoCount }}</span></h2></div><button type="button" @click="go('/m/todos')">查看全部</button></div>
        <div v-if="pendingTodos.length" class="mobile-home-feed">
          <button v-for="item in pendingTodos.slice(0, FEED_PREVIEW_LIMIT)" :key="item.id" type="button" @click="go('/m/todos')">
            <span class="mobile-home-feed-copy">
              <span class="mobile-home-feed-top">
                <span class="mobile-home-feed-dot" aria-hidden="true"></span>
                <strong>{{ item.title }}</strong>
                <ChevronRightIcon class="mobile-home-feed-arrow" aria-hidden="true" />
              </span>
              <small class="mobile-home-feed-meta mobile-home-feed-meta--source">
                <span class="feed-meta-item meta-app">
                  <svg class="meta-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
                    <rect x="3" y="3" width="7" height="7" rx="1.5" />
                    <rect x="14" y="3" width="7" height="7" rx="1.5" />
                    <rect x="3" y="14" width="7" height="7" rx="1.5" />
                    <rect x="14" y="14" width="7" height="7" rx="1.5" />
                  </svg>
                  <span>{{ item.appName || '业务事项' }}</span>
                </span>
              </small>
              <small class="mobile-home-feed-meta mobile-home-feed-meta--time">
                <span class="feed-meta-item meta-time">
                  <CalendarIcon class="meta-icon" />
                  <span>{{ date(item.receivedAt) }}</span>
                </span>
              </small>
            </span>
          </button>
        </div>
        <div v-else class="mobile-home-todo-empty">
          <img :src="nopicSvg" alt="暂无待办事项" />
          <p>暂无待办事项</p>
        </div>
      </section>
    </template>

    <!-- 移动端应用访问提示居中模态弹窗 -->
    <div
      v-if="noticeModal.visible"
      class="mobile-notice-overlay"
      role="dialog"
      aria-modal="true"
      :aria-label="noticeModal.header"
      @click.self="noticeModal.visible = false"
    >
      <section class="mobile-notice-card">
        <header class="mobile-notice-head">
          <h3 class="mobile-notice-title">{{ noticeModal.header }}</h3>
          <button
            type="button"
            class="mobile-notice-close-btn"
            aria-label="关闭"
            @click="noticeModal.visible = false"
          >
            <CloseIcon />
          </button>
        </header>
        <div class="mobile-notice-body">
          <div class="mobile-notice-info-card">
            <InfoCircleFilledIcon class="notice-info-icon" />
            <p class="notice-info-text">{{ noticeModal.body }}</p>
          </div>
        </div>
        <footer class="mobile-notice-footer">
          <button
            type="button"
            class="mobile-notice-confirm-btn"
            @click="noticeModal.visible = false"
          >
            知道了
          </button>
        </footer>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue';
import { useRouter } from 'vue-router';
import { Button as MobileButton } from 'tdesign-mobile-vue';
import {
  CalendarIcon,
  ChevronRightIcon,
  CloseIcon,
  InfoCircleFilledIcon,
} from 'tdesign-icons-vue-next';
import { command, portal, revision } from '../services/runtime.js';
import { date } from '../components/portal/presentation.js';
import CategoryAppIcon from './CategoryAppIcon.vue';
import MobileLoading from './MobileLoading.vue';
import noticeMegaphone from '../assets/mobile-home/notice-megaphone.png';
import nopicSvg from '../assets/nopic.svg';

interface NoticeState {
  visible: boolean;
  header: string;
  body: string;
}

const noticeModal = ref<NoticeState>({
  visible: false,
  header: '应用访问',
  body: '',
});

function showAppNotice(body: string, header = '应用访问') {
  noticeModal.value = {
    visible: true,
    header,
    body,
  };
}

type PortalRow = {
  id: string;
  title?: string;
  name?: string;
  appName?: string;
  category?: string;
  type?: string;
  status?: string;
  receivedAt?: string;
  publishedAt?: string;
  sortOrder?: number;
  ssoRuntimeStatus?: string;
  businessType?: string;
};
type Overview = { todoCount?: number; unreadCount?: number; unreadAnnouncementCount?: number };
// 应用分类图标直接复用 CategoryAppIcon.vue 的内联 SVG；公告插画保留 PNG。
const APP_PREVIEW_LIMIT = 8;
const FEED_PREVIEW_LIMIT = 3;
const NOTICE_LINE_HEIGHT_PX = 35;
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
  if (app.ssoRuntimeStatus !== 'NORMAL') {
    showAppNotice('应用入口暂不可用，请稍后重试', '应用访问提示');
    return;
  }
  const result = await command('enterApp', { id: app.id });
  if (result.ok) {
    showAppNotice(result.data.message, '应用访问');
  } else {
    showAppNotice(result.error.message, '应用访问提示');
  }
}

onMounted(load);
onBeforeUnmount(stopNoticeScroll);
watch(revision, load);
</script>

<style scoped src="./mobile-home-base.css"></style>
<style scoped src="./mobile-home-refresh.css"></style>

<style scoped src="./mobile-home-detail.css"></style>
