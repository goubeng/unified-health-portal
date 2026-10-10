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

        <!-- 胶囊搜索框 -->
        <div class="mobile-message-search">
          <TMobileInput v-model="keyword" placeholder="搜索消息标题" clearable />
        </div>
      </header>

      <!-- 消息列表主体区域（已去掉未读/已读/全部Tab，默认展示全部） -->
      <div class="mobile-message-body-wrap">
        <p v-if="error" class="mobile-inline-error" role="alert">{{ error }}</p>
        <div v-if="loading" class="mobile-list-empty">正在加载消息…</div>
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
        正在加载消息详情…
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
import { Button as TMobileButton, Input as TMobileInput } from 'tdesign-mobile-vue';
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
const keyword = ref('');

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
  const kw = keyword.value.trim().toLowerCase();

  return rows.value
    .filter(item => {
      // 1. 标题搜索
      if (kw && !text(item.title).toLowerCase().includes(kw)) {
        return false;
      }
      // 2. 阅读状态筛选
      if (activeFilters.value.readStatus && item.status !== activeFilters.value.readStatus) {
        return false;
      }
      // 3. 消息类型筛选
      if (activeFilters.value.messageType) {
        const isSecurity = isSecurityMessage(item);
        if (activeFilters.value.messageType === 'SECURITY' && !isSecurity) {
          return false;
        }
        if (activeFilters.value.messageType === 'BUSINESS' && isSecurity) {
          return false;
        }
      }
      // 4. 时间范围筛选
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

<style scoped>
.mobile-messages {
  padding: 0 0 32px;
  color: #173047;
  width: 100%;
  max-width: 100%;
  box-sizing: border-box;
  overflow-x: hidden;
}

/* 顶部品牌蓝渐变区域 */
.mobile-message-hero {
  padding: 20px 16px 18px;
  background: linear-gradient(135deg, #0052d9 0%, #1e6beb 58%, #4489f7 100%);
  color: #ffffff;
  display: flex;
  flex-direction: column;
  gap: 12px;
  box-sizing: border-box;
}

/* 标题行：引用待办事项字号规范 22px */
.mobile-message-title-row h1 {
  margin: 0;
  font-size: 22px;
  font-weight: 700;
  letter-spacing: 0.5px;
  color: #ffffff;
  line-height: 1.25;
}

/* 操作栏：筛选 与 清除未读 */
.mobile-message-action-bar {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-top: 2px;
}

/* 筛选按钮（胶囊样式，高度统一 30px） */
.mobile-filter-trigger-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  height: 30px;
  box-sizing: border-box;
  border: 1px solid rgba(255, 255, 255, 0.35);
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.2);
  color: #ffffff;
  font-size: 13px;
  font-weight: 500;
  padding: 0 14px;
  cursor: pointer;
  backdrop-filter: blur(4px);
  transition: all 0.2s ease;
}

.mobile-filter-trigger-btn:active {
  background: rgba(255, 255, 255, 0.3);
}

.mobile-filter-trigger-btn.has-filter {
  background: #ffffff;
  color: #0052d9;
  font-weight: 600;
  border-color: #ffffff;
}

.mobile-filter-trigger-btn .trigger-icon {
  font-size: 14px;
}

/* 清除未读操作（参考图右侧：文重细，橡皮擦图标） */
.mobile-clear-unread-btn {
  display: inline-flex;
  align-items: center;
  gap: 5px;
  border: none;
  background: transparent;
  color: rgba(255, 255, 255, 0.92);
  font-size: 13px;
  font-weight: 400;
  cursor: pointer;
  padding: 4px 6px;
  transition: opacity 0.2s ease;
}

.mobile-clear-unread-btn:active {
  opacity: 0.75;
}

.mobile-clear-unread-btn:disabled {
  opacity: 0.45;
  cursor: not-allowed;
}

.mobile-clear-unread-btn .eraser-icon {
  width: 15px;
  height: 15px;
  stroke: currentColor;
}

.mobile-clear-unread-btn .clear-icon {
  font-size: 16px;
}

/* 未读重要提醒卡片横幅（参考图） */
.mobile-unread-alert-banner {
  display: flex;
  align-items: center;
  gap: 10px;
  padding: 10px 12px;
  border-radius: 12px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(240, 246, 255, 0.97) 100%);
  color: #1a2d48;
  box-shadow: 0 4px 14px rgba(0, 32, 80, 0.08);
}

.banner-icon-badge {
  display: grid;
  place-items: center;
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background: #ffaa00;
  color: #ffffff;
  font-size: 14px;
  font-weight: 800;
  flex: none;
}

.banner-text {
  margin: 0;
  font-size: 12.5px;
  line-height: 1.4;
  color: #273849;
  flex: 1;
  min-width: 0;
}

.banner-count {
  color: #e34d59;
  font-weight: 700;
  font-size: 14px;
}

.banner-view-btn {
  border: none;
  border-radius: 999px;
  background: #0052d9;
  color: #ffffff;
  font-size: 12px;
  font-weight: 500;
  padding: 5px 12px;
  white-space: nowrap;
  flex: none;
  cursor: pointer;
}

.mobile-message-search {
  width: 100%;
  box-sizing: border-box;
}

/* 列表主体 */
.mobile-message-body-wrap {
  padding: 14px 16px 0;
  width: 100%;
  box-sizing: border-box;
  overflow-x: hidden;
}

.mobile-inline-error {
  padding: 10px 12px;
  border-radius: 8px;
  background: #fff1ef;
  color: #ba3e38;
  font-size: 13px;
}

.mobile-list-empty {
  padding: 58px 0;
  text-align: center;
  color: #91a2af;
  font-size: 14px;
}

/* 消息列表：严格充满容器宽度，禁止溢出 */
.mobile-message-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
  width: 100%;
  box-sizing: border-box;
}

.mobile-message-card {
  display: flex;
  align-items: flex-start;
  gap: 12px;
  border: 1px solid #edf2f7;
  border-radius: 16px;
  background: #ffffff;
  padding: 15px 14px;
  box-shadow: 0 4px 14px rgba(16, 54, 99, 0.04);
  width: 100%;
  max-width: 100%;
  box-sizing: border-box;
  cursor: pointer;
  transition: background-color 0.15s ease;
}

.mobile-message-card:active {
  background-color: #f9fbfd;
}

/* 分类图标：参考图黄色小喇叭与蓝色小盾牌 */
.mobile-message-icon {
  display: grid;
  place-items: center;
  width: 38px;
  height: 38px;
  flex: none;
  border-radius: 11px;
  background: #fef7e8;
  color: #f5a623;
  margin-top: 1px;
}

.mobile-message-icon.icon-shield {
  background: #ecf3fe;
  color: #0052d9;
}

.mobile-message-icon svg {
  width: 20px;
  height: 20px;
}

/* 主体内容：自适应截断，防止撑开屏幕 */
.mobile-message-main {
  flex: 1;
  min-width: 0;
  width: 0;
  display: flex;
  flex-direction: column;
}

.mobile-message-row-top {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
  width: 100%;
  min-width: 0;
}

.mobile-message-title {
  font-size: 15px;
  line-height: 1.4;
  font-weight: 600;
  color: #1a2d48;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  flex: 1;
  min-width: 0;
}

.mobile-message-date {
  font-size: 12px;
  color: #8c9fae;
  flex: none;
  white-space: nowrap;
}

.mobile-message-row-mid {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  margin-top: 5px;
  width: 100%;
  min-width: 0;
}

.mobile-message-excerpt {
  margin: 0;
  color: #6b8092;
  font-size: 13px;
  line-height: 1.45;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  flex: 1;
  min-width: 0;
}

/* 未读红点（参考图：在摘要右侧显示） */
.mobile-message-unread-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #e34d59;
  flex: none;
  box-shadow: 0 0 0 2px rgba(227, 77, 89, 0.15);
}

.mobile-message-meta {
  display: block;
  margin-top: 4px;
  font-size: 11.5px;
  color: #9cb0c2;
}

/* 筛选抽屉弹窗（参考图半屏面板设计：居中且锁定480px避免超屏） */
.mobile-filter-drawer-mask {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  backdrop-filter: blur(2px);
  z-index: 1000;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  align-items: center;
  animation: fadeIn 0.2s ease-out;
}

.mobile-filter-drawer-panel {
  width: 100%;
  max-width: 480px;
  margin: 0 auto;
  box-sizing: border-box;
  background: #ffffff;
  border-radius: 20px 20px 0 0;
  padding: 24px 18px 28px;
  max-height: 82vh;
  overflow-y: auto;
  box-shadow: 0 -8px 24px rgba(0, 0, 0, 0.12);
  display: flex;
  flex-direction: column;
  gap: 20px;
  animation: slideUp 0.25s cubic-bezier(0.16, 1, 0.3, 1);
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes slideUp {
  from { transform: translateY(100%); }
  to { transform: translateY(0); }
}

.filter-section {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.filter-section-title {
  margin: 0;
  font-size: 15px;
  font-weight: 600;
  color: #1d2129;
}

/* 网格选项按钮：每排 3 个（参考图布局） */
.filter-options-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 10px;
}

.filter-option-btn {
  position: relative;
  overflow: hidden;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid transparent;
  border-radius: 8px;
  background: #f2f3f5;
  color: #4e5969;
  font-size: 13.5px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.15s ease;
  user-select: none;
}

.filter-option-btn:active {
  background: #e5e6eb;
}

/* 激活选中态：浅蓝底、品牌蓝字、边框、右下角三角打勾 */
.filter-option-btn.active {
  background: #ecf2fe;
  color: #0052d9;
  font-weight: 600;
  border-color: #bad3fb;
}

.filter-checked-corner {
  position: absolute;
  right: 0;
  bottom: 0;
  width: 0;
  height: 0;
  border-style: solid;
  border-width: 0 0 16px 16px;
  border-color: transparent transparent #0052d9 transparent;
}

.filter-checked-corner svg {
  position: absolute;
  right: -16px;
  bottom: -15px;
  width: 9px;
  height: 9px;
  color: #ffffff;
}

/* 底部重置与确定操作栏 */
.filter-actions-footer {
  display: flex;
  gap: 14px;
  margin-top: 10px;
  padding-top: 10px;
}

.filter-reset-btn {
  flex: 1;
  height: 44px;
  border-radius: 999px;
  border: 1.5px solid #0052d9;
  background: #ffffff;
  color: #0052d9;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  transition: background-color 0.15s ease;
}

.filter-reset-btn:active {
  background: #f2f6ff;
}

.filter-submit-btn {
  flex: 1;
  height: 44px;
  border-radius: 999px;
  border: none;
  background: #0052d9;
  color: #ffffff;
  font-size: 15px;
  font-weight: 600;
  cursor: pointer;
  box-shadow: 0 4px 12px rgba(0, 82, 217, 0.28);
  transition: background-color 0.15s ease;
}

.filter-submit-btn:active {
  background: #0043b3;
}

/* 消息详情页面（信函风格 + 底部上一封/下一封与删除工具栏） */
.mobile-message-detail-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 50px;
  margin: 0;
  padding: 0 12px;
  background: #ffffff;
  border-bottom: 1px solid #edf1f6;
  position: sticky;
  top: 0;
  z-index: 10;
}

.mobile-message-detail-head strong {
  font-size: 17px;
  font-weight: 600;
  color: #1a2d48;
  text-align: center;
  flex: 1;
}

/* TD移动端规范导航按钮（无文字，默认24px图标，触控热区良好） */
.mobile-nav-back-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 36px;
  height: 36px;
  border: 0;
  border-radius: 8px;
  background: transparent;
  color: #24344d;
  cursor: pointer;
  padding: 0;
  flex: none;
  transition: background-color 0.15s ease;
}

.mobile-nav-back-btn:active {
  background-color: #f0f3f8;
}

.mobile-nav-back-btn svg {
  width: 24px;
  height: 24px;
}

.mobile-nav-placeholder {
  width: 36px;
  height: 36px;
  flex: none;
}

.mobile-detail-loading,
.mobile-detail-notfound {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 60px 16px;
  color: #8b9baa;
  font-size: 14px;
  text-align: center;
  gap: 12px;
}

.mobile-back-list-btn {
  border: 1px solid #c9d8e8;
  background: #ffffff;
  color: #0052d9;
  border-radius: 999px;
  padding: 6px 16px;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
}

/* 消息详情主体：保留默认背景色，增加与边缘14px间距 */
.mobile-message-detail-body {
  padding: 14px 14px calc(70px + env(safe-area-inset-bottom, 0px));
  background: #f4f7fb;
  min-height: calc(100dvh - 50px);
  box-sizing: border-box;
}

.mobile-message-detail-card {
  position: relative;
  background: #ffffff;
  border-radius: 0; /* 用户明确要求：去掉圆角显示 */
  border: 1px solid #eef2f7;
  box-shadow: 0 4px 18px rgba(16, 44, 80, 0.05);
  padding: 24px 20px 28px;
  width: 100%;
  box-sizing: border-box;
  display: flex;
  flex-direction: column;
}

/* 顶部系统蓝条：保持截图中的蓝色装饰线 */
.message-card-accent-bar {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: #0052d9;
}

/* 标题：大字号，加粗，符合单列垂直排版规范 */
.message-card-title {
  margin: 8px 0 14px;
  font-size: 18px;
  font-weight: 700;
  color: #112033;
  line-height: 1.45;
  letter-spacing: 0.2px;
}

/* 信头元信息（时间、应用等） */
.message-card-meta {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 8px 12px;
  margin-bottom: 20px;
  padding-bottom: 14px;
  border-bottom: 1px dashed #e8edf3;
  font-size: 12.5px;
  color: #7b8e9f;
}

/* 消息类型标签：与“我的申请”保持完全一致的徽章样式，字号统一提升至 12px 粗体 */
.meta-type-tag {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 2.5px 8px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 600;
  line-height: 1.3;
  flex-shrink: 0;
}

.meta-type-tag.is-business {
  background: #ecf2fe;
  color: #0052d9;
}

.meta-type-tag.is-security {
  background: #fff0ee;
  color: #d1493b;
}

.meta-app {
  color: #0052d9;
  font-weight: 500;
}

/* 正文：行距舒展，字迹清晰，垂直自上向下正常流动 */
.message-card-content {
  font-size: 14.5px;
  line-height: 1.85;
  color: #283a4d;
  white-space: pre-wrap;
  word-break: break-word;
  min-height: 180px;
}

.message-card-actions {
  margin-top: 28px;
  padding-top: 20px;
  border-top: 1px solid #f0f3f6;
}

/* 底部操作栏（复刻截图底栏）：左侧上一封/下一封，右侧删除垃圾桶图标 */
.mobile-message-detail-toolbar {
  position: fixed;
  left: 50%;
  bottom: 0;
  width: 100%;
  max-width: var(--mobile-max-width, 480px);
  transform: translateX(-50%);
  height: calc(52px + env(safe-area-inset-bottom, 0px));
  padding: 0 16px env(safe-area-inset-bottom, 0px);
  background: #ffffff;
  border-top: 1px solid #ebeff5;
  box-shadow: 0 -2px 10px rgba(0, 0, 0, 0.04);
  display: flex;
  align-items: center;
  justify-content: space-between;
  box-sizing: border-box;
  z-index: 100;
}

.toolbar-nav-group {
  display: flex;
  align-items: center;
  gap: 24px;
}

/* 上一封 / 下一封 按钮：保持本系统的蓝色配色 #0052d9 */
.toolbar-nav-btn {
  border: 0;
  background: transparent;
  color: #0052d9;
  font-size: 14.5px;
  font-weight: 500;
  cursor: pointer;
  padding: 6px 0;
  transition: opacity 0.15s ease;
}

.toolbar-nav-btn:active {
  opacity: 0.7;
}

.toolbar-nav-btn.disabled,
.toolbar-nav-btn:disabled {
  color: #a4b4c4;
  cursor: not-allowed;
  opacity: 0.6;
}

/* 删除图标按钮：无文字，纯图标，大小 22px，TD移动端规范配色与交互 */
.toolbar-delete-btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 38px;
  height: 38px;
  border: 0;
  border-radius: 8px;
  background: transparent;
  color: #4b5b76;
  cursor: pointer;
  padding: 0;
  transition: all 0.15s ease;
}

.toolbar-delete-btn:active {
  color: #e34d59;
  background-color: #fff1f0;
}

.toolbar-delete-btn svg {
  width: 22px;
  height: 22px;
}
</style>
