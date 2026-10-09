<template>
  <section class="mobile-messages">
    <template v-if="!active">
      <!-- 顶部品牌渐变蓝头部 -->
      <header class="mobile-message-hero">
        <!-- 标题行 -->
        <div class="mobile-message-title-row">
          <h1>消息</h1>
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

    <!-- 消息详情页面 -->
    <template v-else>
      <header class="mobile-message-detail-head">
        <button type="button" class="mobile-nav-back-btn" @click="back">
          <ChevronLeftIcon /><span>返回</span>
        </button>
        <strong>消息详情</strong>
        <button type="button" class="mobile-nav-delete-btn" @click="removeSingle(active.id)">
          <DeleteIcon /><span>删除</span>
        </button>
      </header>
      <p v-if="error" class="mobile-inline-error" role="alert">{{ error }}</p>
      <article class="mobile-message-detail">
        <h1>{{ text(active.title) || '-' }}</h1>
        <p class="mobile-message-detail-date">{{ date(active.receivedAt) }}</p>
        <dl>
          <div><dt>接收对象</dt><dd>{{ text(actor?.name) || '当前登录用户' }}</dd></div>
          <div><dt>来源应用</dt><dd>{{ text(active.appName) || '统一门户' }}</dd></div>
          <div><dt>消息类型</dt><dd>{{ label(active.messageType || 'BUSINESS', 'message_type') }}</dd></div>
          <div>
            <dt>阅读状态</dt>
            <dd>
              <TMobileTag :theme="active.status === 'UNREAD' ? 'warning' : 'success'" variant="light">
                {{ label(active.status, 'message_read_status') }}
              </TMobileTag>
            </dd>
          </div>
        </dl>
        <div class="mobile-message-body">{{ text(active.content) || '暂无正文' }}</div>
        <TMobileButton v-if="active.appId" block theme="primary" @click="openBusiness">查看关联业务</TMobileButton>
      </article>
    </template>
  </section>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { Button as TMobileButton, Input as TMobileInput, Tag as TMobileTag } from 'tdesign-mobile-vue';
import {
  ChevronLeftIcon,
  DeleteIcon,
  FilterIcon,
  NotificationIcon,
  SecuredIcon,
} from 'tdesign-icons-vue-next';
import { command, portal, revision, loadDictionaryLookups } from '../services/runtime.js';
import { mobileActor as actor } from './mobileActor';
import { date, label, text } from '../components/portal/presentation.js';

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

const active = computed(() => rows.value.find(item => item.id === String(route.query.messageId || '')) || null);
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
}

function open(item: Message) {
  router.push({ path: '/m/messages', query: { messageId: item.id } });
}

function back() {
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

async function removeSingle(id: string) {
  if (!window.confirm('确认删除此条消息吗？')) return;
  const result = await command('deleteMessages', { ids: [id] });
  if (!result.ok) {
    error.value = text(result.error?.message);
    return;
  }
  back();
}

async function openBusiness() {
  if (!active.value?.appId) return;
  const result = await command('enterApp', { id: active.value.appId });
  if (!result.ok) {
    error.value = text(result.error?.message);
    return;
  }
  window.alert(text(result.data?.message) || '已打开关联业务');
}

onMounted(() => {
  loadDictionaryLookups();
  load();
});

watch(revision, load);

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

/* 标题行 */
.mobile-message-title-row h1 {
  margin: 0;
  font-size: 24px;
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

/* 筛选按钮（胶囊样式，参考图左侧） */
.mobile-filter-trigger-btn {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  border: 1px solid rgba(255, 255, 255, 0.35);
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.2);
  color: #ffffff;
  font-size: 13.5px;
  font-weight: 500;
  padding: 5px 14px;
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

/* 详情头部与正文 */
.mobile-message-detail-head {
  display: grid;
  grid-template-columns: 1fr 2fr 1fr;
  align-items: center;
  margin: 0 0 16px;
  padding: 16px;
  background: #ffffff;
  border-bottom: 1px solid #edf1f5;
}

.mobile-message-detail-head strong {
  text-align: center;
  font-size: 17px;
}

.mobile-nav-back-btn {
  display: flex;
  align-items: center;
  gap: 4px;
  border: 0;
  background: transparent;
  color: #0052d9;
  font-size: 14px;
  cursor: pointer;
}

.mobile-nav-delete-btn {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 4px;
  border: 0;
  background: transparent;
  color: #e34d59;
  font-size: 14px;
  cursor: pointer;
}

.mobile-message-detail {
  padding: 0 16px;
}

.mobile-message-detail h1 {
  margin: 0 0 8px;
  font-size: 18px;
  line-height: 1.4;
  color: #173047;
}

.mobile-message-detail-date {
  margin: 0 0 16px;
  font-size: 12px;
  color: #8c9fae;
}

.mobile-message-detail dl {
  margin: 0 0 16px;
  padding: 12px 14px;
  background: #f8fafc;
  border-radius: 10px;
  display: grid;
  gap: 8px;
}

.mobile-message-detail dl div {
  display: flex;
  justify-content: space-between;
  font-size: 13px;
}

.mobile-message-detail dt {
  color: #6a7f92;
}

.mobile-message-detail dd {
  margin: 0;
  color: #173047;
  font-weight: 500;
}

.mobile-message-body {
  margin: 0 0 24px;
  padding: 14px;
  background: #ffffff;
  border: 1px solid #edf1f5;
  border-radius: 10px;
  font-size: 14px;
  line-height: 1.6;
  color: #273849;
  white-space: pre-wrap;
}
</style>
