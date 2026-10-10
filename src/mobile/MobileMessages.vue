<template>
  <section class="mobile-messages">
    <template v-if="!isDetailMode">
      <!-- 顶部品牌渐变蓝头部 -->
      <header class="mobile-message-hero">
        <!-- 标题行 -->
        <div class="mobile-message-title-row">
          <h1>消息中心</h1>
        </div>

        <!-- 操作栏：筛选 与 清除未读 -->
        <div class="mobile-message-action-bar">
          <button
            type="button"
            class="mobile-filter-trigger-btn"
            :class="{ 'has-filter': hasActiveFilter }"
            @click="openFilterDrawer"
          >
            <span>筛选</span>
            <FilterIcon class="trigger-icon" />
          </button>
          <button
            type="button"
            class="mobile-clear-unread-btn"
            :disabled="unreadCount === 0"
            @click="markAll"
          >
            <!-- 橡皮擦线框图标（参考图） -->
            <svg class="eraser-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
              <path d="m7 21-4.3-4.3c-1-1-1-2.5 0-3.4l9.6-9.6c1-1 2.5-1 3.4 0l5.6 5.6c1 1 1 2.5 0 3.4L13 21" />
              <path d="M22 21H7" />
              <path d="m5 11 9 9" />
            </svg>
            <span>清除未读</span>
          </button>
        </div>

        <!-- 未读重要提醒卡片提示条（参考图范式） -->
        <div v-if="unreadCount > 0" class="mobile-unread-alert-banner">
          <div class="banner-icon-badge" aria-hidden="true">
            <span>!</span>
          </div>
          <p class="banner-text">
            您有 <strong class="banner-count">{{ unreadCount }}</strong> 条重要提醒尚未阅读，请及时查看并办理相关业务
          </p>
          <button type="button" class="banner-view-btn" @click="quickFilterUnread">
            去查看
          </button>
        </div>

      </header>

      <!-- 消息列表主体区域（已去掉未读/已读/全部Tab，默认展示全部） -->
      <div class="mobile-message-body-wrap">
        <p v-if="error" class="mobile-inline-error" role="alert">{{ error }}</p>
        <div v-if="loading" class="mobile-list-empty"><MobileLoading message="正在加载消息…" /></div>
        <div v-else-if="!filtered.length" class="mobile-list-empty">暂无符合条件的消息</div>

        <!-- 消息卡片列表：无多选框，卡片不超屏，未读右侧红点 -->
        <div v-else class="mobile-message-list">
          <article
            v-for="item in filtered"
            :key="item.id"
            class="mobile-message-card"
            @click="open(item)"
          >
            <!-- 左侧圆角黄色广播或蓝色盾牌图标 -->
            <div class="mobile-message-icon" :class="isSecurityMessage(item) ? 'icon-shield' : 'icon-speaker'">
              <SecuredIcon v-if="isSecurityMessage(item)" />
              <NotificationIcon v-else />
            </div>

            <!-- 右侧主体内容：自适应截断，防止超出屏幕 -->
            <div class="mobile-message-main">
              <div class="mobile-message-row-top">
                <strong class="mobile-message-title">{{ text(item.title) || '-' }}</strong>
                <span class="mobile-message-date">{{ formatShortDate(item.receivedAt) }}</span>
              </div>
              <div class="mobile-message-row-mid">
                <p class="mobile-message-excerpt">{{ text(item.content) || '暂无正文' }}</p>
                <!-- 未读消息在摘要右侧显示红点 -->
                <span v-if="item.status === 'UNREAD'" class="mobile-message-unread-dot" aria-label="未读"></span>
              </div>
              <span class="mobile-message-meta">{{ text(item.appName) || '统一门户' }}</span>
            </div>
          </article>
        </div>
      </div>

      <!-- 筛选抽屉弹窗（半屏抽屉） -->
      <div v-if="showFilterDrawer" class="mobile-filter-drawer-mask" @click="closeFilterDrawer">
        <div class="mobile-filter-drawer-panel" @click.stop>
          <!-- 阅读状态 -->
          <section class="filter-section">
            <h3 class="filter-section-title">阅读状态</h3>
            <div class="filter-options-grid">
              <button
                v-for="opt in READ_STATUS_OPTIONS"
                :key="opt.value"
                type="button"
                class="filter-option-btn"
                :class="{ active: draftFilters.readStatus === opt.value }"
                @click="draftFilters.readStatus = opt.value"
              >
                <span>{{ opt.label }}</span>
                <span v-if="draftFilters.readStatus === opt.value" class="filter-checked-corner">
                  <svg viewBox="0 0 16 16" fill="currentColor">
                    <path d="M13.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 .708-.708L6.5 10.293l6.646-6.647a.5.5 0 0 1 .708 0z" />
                  </svg>
                </span>
              </button>
            </div>
          </section>

          <!-- 消息类型 -->
          <section class="filter-section">
            <h3 class="filter-section-title">消息类型</h3>
            <div class="filter-options-grid">
              <button
                v-for="opt in MESSAGE_TYPE_OPTIONS"
                :key="opt.value"
                type="button"
                class="filter-option-btn"
                :class="{ active: draftFilters.messageType === opt.value }"
                @click="draftFilters.messageType = opt.value"
              >
                <span>{{ opt.label }}</span>
                <span v-if="draftFilters.messageType === opt.value" class="filter-checked-corner">
                  <svg viewBox="0 0 16 16" fill="currentColor">
                    <path d="M13.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 .708-.708L6.5 10.293l6.646-6.647a.5.5 0 0 1 .708 0z" />
                  </svg>
                </span>
              </button>
            </div>
          </section>

          <!-- 时间范围 -->
          <section class="filter-section">
            <h3 class="filter-section-title">时间范围</h3>
            <div class="filter-options-grid">
              <button
                v-for="opt in TIME_RANGE_OPTIONS"
                :key="opt.value"
                type="button"
                class="filter-option-btn"
                :class="{ active: draftFilters.timeRange === opt.value }"
                @click="draftFilters.timeRange = opt.value"
              >
                <span>{{ opt.label }}</span>
                <span v-if="draftFilters.timeRange === opt.value" class="filter-checked-corner">
                  <svg viewBox="0 0 16 16" fill="currentColor">
                    <path d="M13.854 3.646a.5.5 0 0 1 0 .708l-7 7a.5.5 0 0 1-.708 0l-3.5-3.5a.5.5 0 1 1 .708-.708L6.5 10.293l6.646-6.647a.5.5 0 0 1 .708 0z" />
                  </svg>
                </span>
              </button>
            </div>
          </section>

          <!-- 底部操作按钮 -->
          <footer class="filter-actions-footer">
            <button type="button" class="filter-reset-btn" @click="resetFilters">重置</button>
            <button type="button" class="filter-submit-btn" @click="applyFilters">确定</button>
          </footer>
        </div>
      </div>
    </template>

    <!-- 消息详情页面（信函风格 + 底部上一封/下一封与删除工具栏） -->
    <template v-else>
      <header class="mobile-message-detail-head">
        <button type="button" class="mobile-nav-back-btn" aria-label="返回" @click="back">
          <ChevronLeftIcon />
        </button>
        <strong>消息详情</strong>
        <div class="mobile-nav-placeholder" aria-hidden="true"></div>
      </header>

      <p v-if="error" class="mobile-inline-error" role="alert">{{ error }}</p>

      <div v-if="loading && !active" class="mobile-detail-loading">
        <MobileLoading message="正在加载消息详情…" />
      </div>
      <div v-else-if="!active" class="mobile-detail-notfound">
        <p>未找到该消息或已被删除</p>
        <button type="button" class="mobile-back-list-btn" @click="back">返回消息中心</button>
      </div>

      <!-- 消息信纸卡片主体（去掉圆角，垂直正常流排版） -->
      <template v-else>
        <main class="mobile-message-detail-body">
          <article class="mobile-message-detail-card">
            <!-- 顶部系统蓝色装饰横条 -->
            <div class="message-card-accent-bar" aria-hidden="true"></div>

            <!-- 消息大标题 -->
            <h1 class="message-card-title">{{ text(active.title) || '-' }}</h1>

            <!-- 消息信头元信息（优先显示消息标签，再显示发送日期） -->
            <div class="message-card-meta">
              <span
                v-if="active.messageType"
                class="meta-type-tag"
                :class="isSecurityMessage(active) ? 'is-security' : 'is-business'"
              >
                {{ label(active.messageType || 'BUSINESS', 'message_type') }}
              </span>
              <span v-if="active.appName" class="meta-app">{{ text(active.appName) }}</span>
              <span class="meta-date">{{ date(active.receivedAt) }}</span>
            </div>

            <!-- 消息正文 -->
            <div class="message-card-content">
              {{ text(active.content) || '暂无正文内容' }}
            </div>

            <!-- 业务入口按钮（若有关联业务） -->
            <div v-if="active.appId" class="message-card-actions">
              <TMobileButton block theme="primary" variant="base" @click="openBusiness">
                前往相关业务
              </TMobileButton>
            </div>
          </article>
        </main>

        <!-- 底部固定工具栏：左侧上一封/下一封，右侧删除图标 -->
        <footer class="mobile-message-detail-toolbar">
          <div class="toolbar-nav-group">
            <button
              type="button"
              class="toolbar-nav-btn"
              :class="{ disabled: !hasPrev }"
              :disabled="!hasPrev"
              @click="goPrev"
            >
              上一封
            </button>
            <button
              type="button"
              class="toolbar-nav-btn"
              :class="{ disabled: !hasNext }"
              :disabled="!hasNext"
              @click="goNext"
            >
              下一封
            </button>
          </div>
          <button
            type="button"
            class="toolbar-delete-btn"
            aria-label="删除此条消息"
            @click="removeSingle(active.id)"
          >
            <DeleteIcon />
          </button>
        </footer>
      </template>
    </template>
  </section>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { Button as TMobileButton } from 'tdesign-mobile-vue';
import {
  ChevronLeftIcon,
  DeleteIcon,
  FilterIcon,
  NotificationIcon,
  SecuredIcon,
} from 'tdesign-icons-vue-next';
import { DialogPlugin } from 'tdesign-vue-next';
import { command, portal, revision, loadDictionaryLookups } from '../services/runtime.js';
import { date, label, text } from '../components/portal/presentation.js';
import MobileLoading from './MobileLoading.vue';

function showAppNotice(body: string, header = '应用访问') {
  DialogPlugin.alert({
    placement: 'center',
    header,
    body,
    confirmBtn: '知道了',
  });
}

interface Message {
  id: string;
  title?: string;
  content?: string;
  appName?: string;
  appId?: string;
  messageType?: string;
  receivedAt?: string;
  status: string;
}

interface FilterState {
  readStatus: string;
  messageType: string;
  timeRange: string;
}

const READ_STATUS_OPTIONS = [
  { value: '', label: '全部' },
  { value: 'READ', label: '已读消息' },
  { value: 'UNREAD', label: '未读消息' },
] as const;

const MESSAGE_TYPE_OPTIONS = [
  { value: '', label: '全部' },
  { value: 'SECURITY', label: '重要提醒' },
  { value: 'BUSINESS', label: '温馨提示' },
] as const;

const TIME_RANGE_OPTIONS = [
  { value: '', label: '全部' },
  { value: '1M', label: '最近一月' },
  { value: '3M', label: '最近三月' },
  { value: '6M', label: '最近半年' },
  { value: '1Y', label: '最近一年' },
] as const;

const TIME_FILTER_DAYS: Record<string, number> = {
  '1M': 30,
  '3M': 90,
  '6M': 180,
  '1Y': 365,
};

const MILLISECONDS_PER_DAY = 86_400_000;

const route = useRoute();
const router = useRouter();
const rows = ref<Message[]>([]);
const loading = ref(true);
const error = ref('');

const activeFilters = ref<FilterState>({
  readStatus: '',
  messageType: '',
  timeRange: '',
});

const draftFilters = ref<FilterState>({
  readStatus: '',
  messageType: '',
  timeRange: '',
});

const showFilterDrawer = ref(false);

const selectedMessage = ref<Message | null>(null);

const isDetailMode = computed(() => {
  return Boolean(selectedMessage.value || route.query.messageId);
});

const active = computed(() => {
  if (selectedMessage.value) return selectedMessage.value;
  const msgId = String(route.query.messageId || '');
  if (!msgId) return null;
  return rows.value.find((item) => item.id === msgId) || null;
});

const unreadCount = computed(() => rows.value.filter(item => item.status === 'UNREAD').length);

const hasActiveFilter = computed(() => {
  return Boolean(
    activeFilters.value.readStatus ||
    activeFilters.value.messageType ||
    activeFilters.value.timeRange
  );
});

const filtered = computed(() => {
  const now = Date.now();
  return rows.value
    .filter(item => {
      // 1. 阅读状态筛选
      if (activeFilters.value.readStatus && item.status !== activeFilters.value.readStatus) {
        return false;
      }
      // 2. 消息类型筛选
      if (activeFilters.value.messageType) {
        const isSecurity = isSecurityMessage(item);
        if (activeFilters.value.messageType === 'SECURITY' && !isSecurity) {
          return false;
        }
        if (activeFilters.value.messageType === 'BUSINESS' && isSecurity) {
          return false;
        }
      }
      // 3. 时间范围筛选
      if (activeFilters.value.timeRange) {
        const days = TIME_FILTER_DAYS[activeFilters.value.timeRange];
        if (days) {
          const itemTime = Date.parse(item.receivedAt || '');
          if (!Number.isNaN(itemTime)) {
            const diffDays = (now - itemTime) / MILLISECONDS_PER_DAY;
            if (diffDays > days) {
              return false;
            }
          }
        }
      }
      return true;
    })
    .sort((a, b) => (Date.parse(b.receivedAt || '') || 0) - (Date.parse(a.receivedAt || '') || 0));
});

let requestVersion = 0;
let markingId = '';

function isSecurityMessage(item: Message): boolean {
  return item.messageType === 'SECURITY' || Boolean(item.title && (item.title.includes('审核') || item.title.includes('安全') || item.title.includes('权限')));
}

function formatShortDate(val?: string): string {
  if (!val) return '';
  const d = new Date(val);
  if (Number.isNaN(d.getTime())) return date(val);
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
}

async function load() {
  const version = ++requestVersion;
  loading.value = true;
  error.value = '';
  const result = await portal.read('messages');
  if (version !== requestVersion) return;
  rows.value = result.ok ? result.data : [];
  error.value = result.ok ? '' : text(result.error?.message);
  loading.value = false;
  if (route.query.messageId) {
    const found = rows.value.find((item) => item.id === String(route.query.messageId));
    if (found) {
      selectedMessage.value = found;
    }
  }
}

function open(item: Message) {
  selectedMessage.value = item;
  router.push({ path: '/m/messages', query: { messageId: item.id } });
}

function back() {
  selectedMessage.value = null;
  router.replace('/m/messages');
}

function openFilterDrawer() {
  draftFilters.value = { ...activeFilters.value };
  showFilterDrawer.value = true;
}

function closeFilterDrawer() {
  showFilterDrawer.value = false;
}

function resetFilters() {
  draftFilters.value = {
    readStatus: '',
    messageType: '',
    timeRange: '',
  };
}

function applyFilters() {
  activeFilters.value = { ...draftFilters.value };
  showFilterDrawer.value = false;
}

function quickFilterUnread() {
  activeFilters.value = {
    readStatus: 'UNREAD',
    messageType: '',
    timeRange: '',
  };
}

async function markAll() {
  if (unreadCount.value === 0) return;
  const result = await command('markAllMessagesRead');
  if (!result.ok) {
    error.value = text(result.error?.message);
  }
}

const currentIndex = computed(() => {
  if (!active.value) return -1;
  return filtered.value.findIndex(item => item.id === active.value?.id);
});

const hasPrev = computed(() => currentIndex.value > 0);
const hasNext = computed(() => currentIndex.value >= 0 && currentIndex.value < filtered.value.length - 1);

function goPrev() {
  if (!hasPrev.value) return;
  const prevMsg = filtered.value[currentIndex.value - 1];
  if (prevMsg) {
    selectedMessage.value = prevMsg;
    router.replace({ path: '/m/messages', query: { messageId: prevMsg.id } });
  }
}

function goNext() {
  if (!hasNext.value) return;
  const nextMsg = filtered.value[currentIndex.value + 1];
  if (nextMsg) {
    selectedMessage.value = nextMsg;
    router.replace({ path: '/m/messages', query: { messageId: nextMsg.id } });
  }
}

async function removeSingle(id: string) {
  const dialog = DialogPlugin.confirm({
    placement: 'center',
    theme: 'danger',
    header: '删除消息',
    body: '确认删除此条消息吗？',
    confirmBtn: { content: '确认删除', theme: 'danger' },
    onConfirm: async () => {
      dialog.hide();
      const nextTarget = hasNext.value
        ? filtered.value[currentIndex.value + 1]
        : hasPrev.value
        ? filtered.value[currentIndex.value - 1]
        : null;

      const result = await command('deleteMessages', { ids: [id] });
      if (!result.ok) {
        showAppNotice(text(result.error?.message) || '删除失败', '提示');
        return;
      }
      await load();
      if (nextTarget) {
        selectedMessage.value = nextTarget;
        router.replace({ path: '/m/messages', query: { messageId: nextTarget.id } });
      } else {
        back();
      }
    },
  });
}

async function openBusiness() {
  if (!active.value?.appId) return;
  const result = await command('enterApp', { id: active.value.appId });
  if (!result.ok) {
    showAppNotice(text(result.error?.message) || '打开业务失败', '提示');
    return;
  }
  showAppNotice(text(result.data?.message) || '已完成业务系统单点登录会话准备', '应用访问');
}

onMounted(() => {
  loadDictionaryLookups();
  load();
});

watch(revision, load);

watch(
  () => route.query.messageId,
  (newId) => {
    if (!newId) {
      selectedMessage.value = null;
    } else if (rows.value.length > 0) {
      const found = rows.value.find((item) => item.id === String(newId));
      if (found) {
        selectedMessage.value = found;
      }
    }
  },
  { immediate: true }
);

watch(active, async item => {
  if (!item || item.status !== 'UNREAD' || markingId === item.id) return;
  markingId = item.id;
  const result = await command('markRead', { id: item.id });
  if (!result.ok) error.value = text(result.error?.message);
  markingId = '';
}, { immediate: true });
</script>

<style scoped src="./mobile-messages.css"></style>
