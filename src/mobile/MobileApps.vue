<template>
  <div class="mobile-apps">
    <!-- 顶部标题栏：全部应用标题，胶囊搜索框，无圆角直连 -->
    <header class="mobile-apps-topbar">
      <div class="mobile-apps-title-row">
        <h1>全部应用</h1>
      </div>

      <!-- 标题下方、搜索框上方：全部应用数量与已关联数量统计 -->
      <div class="mobile-apps-hero-stats">
        <span class="hero-stat-pill">全部应用 {{ apps.length }}</span>
        <span class="hero-stat-pill is-bound">已关联 {{ totalBoundCount }}</span>
      </div>

      <div class="mobile-apps-search-wrap">
        <TMobileInput
          v-model="keyword"
          placeholder="搜索应用名称或编码"
          clearable
          :maxlength="MAX_SEARCH_LENGTH"
        />
      </div>
    </header>

    <!-- 加载与异常状态 -->
    <div v-if="error" class="mobile-apps-error" role="alert">
      {{ error }} <button type="button" @click="load">重新加载</button>
    </div>
    <div v-if="loading" class="mobile-apps-loading">正在加载数据…</div>

    <!-- 全部应用视图（左右分栏主体） -->
    <div v-else class="mobile-apps-body">
      <!-- 左侧分类侧边栏 -->
      <aside class="mobile-apps-sidebar" aria-label="应用分类">
        <button
          v-for="item in displayCategories"
          :key="item"
          type="button"
          class="sidebar-item"
          :class="{ active: currentCategory === item }"
          :aria-pressed="currentCategory === item"
          @click="selectCategory(item)"
        >
          <span class="sidebar-item-text">{{ item }}</span>
        </button>
      </aside>

      <!-- 右侧应用列表区域 -->
      <main class="mobile-apps-content" aria-label="应用列表">
        <div class="apps-section-header">
          <span class="apps-section-bar"></span>
          <h2 class="apps-section-title">{{ currentCategoryTitle }}</h2>
          <span class="apps-section-count">({{ currentApps.length }})</span>
        </div>

        <div v-if="currentApps.length" class="apps-item-list">
          <div
            v-for="app in currentApps"
            :key="app.id"
            class="app-item-row"
            :class="{ disabled: app.enabled === false }"
            @click="handleAppClick(app)"
          >
            <!-- 左侧按应用类型专属绘制的彩色矢量 SVG 图标 -->
            <div class="app-item-icon">
              <CategoryAppIcon :category="app.category" />
            </div>

            <!-- 中间纯净应用名称（缩小1号） -->
            <div class="app-item-info">
              <span class="app-item-name">{{ app.name }}</span>
            </div>

            <!-- 右侧操作入口与图标（去关联改成灰色标签“未关联”） -->
            <div class="app-item-action">
              <!-- 未关联：灰色标签 -->
              <span v-if="isBindAction(app)" class="app-tag-unbound">
                未关联
              </span>

              <!-- 申请使用 -->
              <button
                v-else-if="app.primaryAction === 'REQUEST'"
                type="button"
                class="app-btn-pill pill-request"
                @click.stop="takeAction(app)"
              >
                申请
              </button>

              <!-- 查看进度 -->
              <button
                v-else-if="isProgressAction(app)"
                type="button"
                class="app-btn-pill pill-progress"
                @click.stop="takeAction(app)"
              >
                进度
              </button>

              <!-- 已停用 -->
              <span v-else-if="app.enabled === false" class="app-text-disabled">停用</span>

              <!-- 进入应用 / 可直接访问：向右操作图标 -->
              <div v-else class="app-enter-action">
                <ChevronRightIcon class="app-chevron-icon" />
              </div>
            </div>
          </div>
        </div>

        <div v-else class="apps-empty-view">
          <p>{{ keyword ? '未找到匹配应用' : '该分类下暂无应用' }}</p>
        </div>
      </main>
    </div>

    <!-- 申请使用弹窗（移动端标准居中卡片规范） -->
    <div v-if="requestApp" class="mobile-apps-overlay" @click.self="closeDialog">
      <section ref="requestSheet" class="mobile-apps-sheet" role="dialog" aria-modal="true" aria-label="申请使用应用" tabindex="-1">
        <header class="mobile-apps-sheet-head">
          <h2>申请使用 · {{ requestApp.name }}</h2>
          <button type="button" aria-label="关闭" @click="closeDialog"><CloseIcon /></button>
        </header>
        <div class="mobile-apps-sheet-fields">
          <label>申请原因 <span>*</span><textarea v-model.trim="requestReason" rows="3" placeholder="请填写申请使用原因"></textarea></label>
          <label>联系方式<input v-model.trim="requestContact" type="text" placeholder="选填" /></label>
          <label>备注<textarea v-model.trim="requestRemark" rows="2" placeholder="选填"></textarea></label>
          <p v-if="requestError" class="mobile-apps-error" role="alert">{{ requestError }}</p>
        </div>
        <footer class="mobile-apps-sheet-footer">
          <MobileButton block :loading="saving" theme="primary" class="mobile-submit-btn" @click="submitRequest">提交申请</MobileButton>
        </footer>
      </section>
    </div>

    <!-- 移动端应用访问提示居中模态弹窗（替代 PC 端 DialogPlugin.alert） -->
    <div
      v-if="noticeModal.visible"
      class="mobile-notice-overlay"
      role="dialog"
      aria-modal="true"
      :aria-label="noticeModal.header"
      @click.self="closeAppNotice"
    >
      <section class="mobile-notice-card">
        <header class="mobile-notice-head">
          <h3 class="mobile-notice-title">{{ noticeModal.header }}</h3>
          <button
            type="button"
            class="mobile-notice-close-btn"
            aria-label="关闭"
            @click="closeAppNotice"
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
            @click="closeAppNotice"
          >
            知道了
          </button>
        </footer>
      </section>
    </div>

    <!-- 移动端专属账号关联向导居中弹窗 -->
    <MobileAccountBindingModal
      v-model:visible="bindingVisible"
      :app="bindingApp || undefined"
      @completed="load"
    />
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { Button as MobileButton, Input as TMobileInput } from 'tdesign-mobile-vue';
import {
  ChevronRightIcon,
  CloseIcon,
  InfoCircleFilledIcon,
} from 'tdesign-icons-vue-next';
import { command, portal, revision } from '../services/runtime.js';
import MobileAccountBindingModal from './MobileAccountBindingModal.vue';
import CategoryAppIcon from './CategoryAppIcon.vue';
import { useMobileDialog } from './useMobileDialog';

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

function closeAppNotice() {
  noticeModal.value.visible = false;
}

type App = {
  id: string;
  name: string;
  code?: string;
  category?: string;
  description?: string;
  userType?: string;
  accessState?: string;
  primaryAction?: string;
  enabled?: boolean;
  ssoRuntimeStatus?: string;
  sortOrder?: number;
  externalAccountStatus?: string;
};

const ALL_CATEGORY = '全部';
const MAX_SEARCH_LENGTH = 50;

const route = useRoute();
const router = useRouter();
const loading = ref(true);
const error = ref('');
const apps = ref<App[]>([]);
const keyword = ref('');
const currentCategory = ref(ALL_CATEGORY);
const requestApp = ref<App | null>(null);
const requestSheet = ref<HTMLElement | null>(null);

const { closeDialog } = useMobileDialog({
  open: computed(() => Boolean(requestApp.value)),
  element: computed(() => requestSheet.value),
  close: () => { requestApp.value = null; },
});

const requestReason = ref('');
const requestContact = ref('');
const requestRemark = ref('');
const requestError = ref('');
const saving = ref(false);
const bindingVisible = ref(false);
const bindingApp = ref<App | null>(null);

const displayCategories = computed(() => {
  const dynamicCategories = Array.from(new Set(apps.value.map(app => app.category).filter((val): val is string => Boolean(val))));
  return [ALL_CATEGORY, ...dynamicCategories];
});

function isBindAction(app: App): boolean {
  return ['BIND', 'CONTINUE_BIND', 'RETRY_BIND'].includes(app.primaryAction || '') || app.accessState === 'UNBOUND';
}

function isProgressAction(app: App): boolean {
  return ['VIEW_BINDING', 'VIEW_REQUEST'].includes(app.primaryAction || '') || ['REQUEST_PENDING', 'REVIEWING', 'VERIFYING'].includes(app.accessState || '');
}

function isAppBound(app: App): boolean {
  if (isBindAction(app)) return false;
  if (app.primaryAction === 'REQUEST' || isProgressAction(app)) return false;
  return true;
}

const totalBoundCount = computed(() => apps.value.filter(isAppBound).length);

const currentApps = computed(() => {
  const term = keyword.value.trim().toLocaleLowerCase();
  const list = apps.value.filter(app => {
    const matchCategory = currentCategory.value === ALL_CATEGORY || app.category === currentCategory.value;
    const matchKeyword = !term || `${app.name} ${app.code || ''}`.toLocaleLowerCase().includes(term);
    return matchCategory && matchKeyword;
  });

  return list.sort((a, b) => {
    const boundA = isAppBound(a) ? 0 : 1;
    const boundB = isAppBound(b) ? 0 : 1;
    if (boundA !== boundB) {
      return boundA - boundB;
    }
    return (a.sortOrder || 0) - (b.sortOrder || 0);
  });
});

const currentCategoryTitle = computed(() => {
  if (keyword.value.trim()) return '搜索结果';
  return currentCategory.value === ALL_CATEGORY ? '全部应用' : currentCategory.value;
});

function selectCategory(item: string) {
  currentCategory.value = item;
}

async function read(resource: string) {
  const response = await portal.read(resource);
  if (!response.ok) throw new Error(response.error.message);
  return response.data;
}

async function load() {
  loading.value = true;
  error.value = '';
  try {
    const all = await read('apps');
    apps.value = [...(all || [])].sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0));

    if (currentCategory.value !== ALL_CATEGORY && !apps.value.some(app => app.category === currentCategory.value)) {
      currentCategory.value = ALL_CATEGORY;
    }

    const requestedApp = apps.value.find(app => app.id === route.query.requestAppId && (app.primaryAction === 'REQUEST' || app.accessState === 'REQUEST_REJECTED'));
    if (requestedApp) {
      requestApp.value = requestedApp;
      router.replace('/m/apps');
    }
  } catch (cause) {
    error.value = cause instanceof Error ? cause.message : '应用加载失败';
  } finally {
    loading.value = false;
  }
}

async function takeAction(app: App) {
  const action = app.primaryAction;

  if (isBindAction(app)) {
    bindingApp.value = app;
    bindingVisible.value = true;
    return;
  }

  if (action === 'ENTER') {
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
    return;
  }

  if (action === 'REQUEST') {
    requestApp.value = app;
    requestReason.value = '';
    requestContact.value = '';
    requestRemark.value = '';
    requestError.value = '';
    return;
  }

  if (isProgressAction(app)) {
    router.push('/m/applications');
  }
}

function handleAppClick(app: App) {
  if (app.enabled === false) return;
  takeAction(app);
}

async function submitRequest() {
  if (!requestApp.value || saving.value) return;
  if (!requestReason.value) {
    requestError.value = '请填写申请原因';
    return;
  }
  saving.value = true;
  requestError.value = '';
  try {
    const result = await command('submitApplicationRequest', {
      appId: requestApp.value.id,
      reason: requestReason.value,
      contact: requestContact.value,
      remark: requestRemark.value,
    });
    if (!result.ok) {
      requestError.value = result.error.message;
      return;
    }
    requestApp.value = null;
    await load();
    showAppNotice('申请已提交，可在“我的申请”查看进度', '申请提交成功');
  } catch (cause) {
    requestError.value = cause instanceof Error ? cause.message : '提交失败';
  } finally {
    saving.value = false;
  }
}

onMounted(load);
watch(revision, load);
</script>

<style scoped>
.mobile-apps {
  height: calc(100dvh - 64px - env(safe-area-inset-bottom));
  display: flex;
  flex-direction: column;
  background: #f7f9fc;
  overflow: hidden;
}

/* 顶部栏：蓝渐变、三段式布局，间距严格统一为 gap: 12px 与 padding: 20px 16px 18px */
.mobile-apps-topbar {
  flex: none;
  background: linear-gradient(135deg, #0052d9 0%, #1e6beb 58%, #4489f7 100%);
  padding: 20px 16px 18px;
  color: #ffffff;
  display: flex;
  flex-direction: column;
  gap: 12px;
  box-sizing: border-box;
}

.mobile-apps-title-row {
  display: flex;
  align-items: center;
  justify-content: flex-start;
  margin: 0;
  line-height: 1.25;
}

/* 标题行：引用待办事项字号规范 22px */
.mobile-apps-title-row h1 {
  margin: 0;
  font-size: 22px;
  font-weight: 700;
  letter-spacing: 0.5px;
  color: #ffffff;
  line-height: 1.25;
}

/* 标题下方、搜索框上方：全部应用数量与已关联数量统计胶囊（高度与消息中心筛选保持一致 30px） */
.mobile-apps-hero-stats {
  display: flex;
  align-items: center;
  gap: 8px;
  height: 30px;
  margin: 0;
}

.hero-stat-pill {
  display: inline-flex;
  align-items: center;
  height: 30px;
  box-sizing: border-box;
  padding: 0 12px;
  border-radius: 999px;
  background: rgba(255, 255, 255, 0.16);
  border: 1px solid rgba(255, 255, 255, 0.28);
  color: #ffffff;
  font-size: 13px;
  font-weight: 500;
  backdrop-filter: blur(4px);
}

.hero-stat-pill.is-bound {
  background: rgba(255, 255, 255, 0.24);
  border-color: rgba(255, 255, 255, 0.38);
}

.mobile-apps-search-wrap {
  width: 100%;
}

/* Tab 1: 全部应用主体区域（左右分栏，平齐无圆角） */
.mobile-apps-body {
  flex: 1;
  display: flex;
  min-height: 0;
  overflow: hidden;
  background: #ffffff;
}

.mobile-apps-sidebar {
  width: 96px;
  flex: none;
  background: #f4f6fa;
  overflow-y: auto;
  border-right: 1px solid #ebf0f6;
  scrollbar-width: none;
  -webkit-overflow-scrolling: touch;
}

.mobile-apps-sidebar::-webkit-scrollbar {
  display: none;
}

.sidebar-item {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  min-height: 48px;
  padding: 10px 8px;
  border: 0;
  border-left: 3px solid transparent;
  background: transparent;
  color: #63758b;
  font-size: 13px;
  text-align: center;
  cursor: pointer;
  transition: all 0.18s ease;
  line-height: 1.35;
}

.sidebar-item.active {
  background: #ffffff;
  color: #0052d9;
  font-weight: 600;
  border-left-color: #0052d9;
}

.mobile-apps-content {
  flex: 1;
  min-width: 0;
  background: #ffffff;
  overflow-y: auto;
  padding: 12px 14px 24px;
  -webkit-overflow-scrolling: touch;
}

.apps-section-header {
  display: flex;
  align-items: center;
  gap: 6px;
  margin-bottom: 8px;
  padding-bottom: 6px;
  border-bottom: 1px solid #f5f7fa;
}

.apps-section-bar {
  width: 3px;
  height: 14px;
  background: #0052d9;
  border-radius: 2px;
}

.apps-section-title {
  margin: 0;
  font-size: 15px;
  font-weight: 600;
  color: #1a2d48;
}

.apps-section-count {
  font-size: 12px;
  color: #92a2b5;
}

.apps-item-list {
  display: flex;
  flex-direction: column;
}

.app-item-row {
  display: flex;
  align-items: center;
  gap: 12px;
  min-height: 56px;
  padding: 10px 0;
  border-bottom: 1px solid #f2f5f9;
  cursor: pointer;
  transition: background-color 0.15s ease;
}

.app-item-row:active {
  background-color: #f8fafc;
}

.app-item-row.disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.app-item-icon {
  display: grid;
  place-items: center;
  width: 38px;
  height: 38px;
  flex: none;
  border-radius: 11px;
  background: linear-gradient(135deg, #ff9f43, #ff7638);
  color: #ffffff;
  box-shadow: 0 3px 8px rgba(255, 118, 56, 0.18);
}

.app-item-icon.tone-0 {
  background: linear-gradient(135deg, #ff9f43, #ff7638);
  box-shadow: 0 3px 8px rgba(255, 118, 56, 0.18);
}

.app-item-icon.tone-1 {
  background: linear-gradient(135deg, #2ecc71, #10ac84);
  box-shadow: 0 3px 8px rgba(16, 172, 132, 0.18);
}

.app-item-icon.tone-2 {
  background: linear-gradient(135deg, #48dbfb, #0abde3);
  box-shadow: 0 3px 8px rgba(10, 189, 227, 0.18);
}

.app-item-icon.tone-3 {
  background: linear-gradient(135deg, #9b59b6, #8e44ad);
  box-shadow: 0 3px 8px rgba(142, 68, 173, 0.18);
}

.app-item-icon svg {
  width: 20px;
  height: 20px;
}

.app-item-info {
  flex: 1;
  min-width: 0;
}

/* 应用名称缩小1号至 14px */
.app-item-name {
  display: block;
  font-size: 14px;
  font-weight: 500;
  color: #1e2f47;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  line-height: 1.4;
}

.app-item-action {
  flex: none;
  display: flex;
  align-items: center;
  gap: 4px;
}

/* 去关联改为灰色的标签“未关联” */
.app-tag-unbound {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 2px 7px;
  border-radius: 4px;
  background: #f1f4f8;
  color: #8596a6;
  font-size: 11.5px;
  font-weight: 500;
  border: 1px solid #e2e8f0;
}

.app-btn-pill {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 48px;
  height: 26px;
  padding: 0 10px;
  border-radius: 13px;
  font-size: 12px;
  font-weight: 500;
  border: 0;
  cursor: pointer;
  transition: all 0.15s ease;
}

.app-btn-pill.pill-request {
  background: #e7f7ee;
  color: #0b9356;
}

.app-btn-pill.pill-progress {
  background: #fef4e8;
  color: #d97816;
}

.app-text-disabled {
  font-size: 12px;
  color: #a4b4c4;
}

.app-enter-action {
  display: flex;
  align-items: center;
  justify-content: center;
  color: #b0bfce;
}

.app-chevron-icon {
  width: 16px;
  height: 16px;
}

.apps-empty-view {
  padding: 50px 0;
  text-align: center;
  color: #92a2b5;
  font-size: 13px;
}

/* 申请使用居中模态弹窗样式 */
.mobile-apps-overlay {
  position: fixed;
  inset: 0;
  z-index: 3000;
  background: rgba(12, 32, 58, 0.52);
  backdrop-filter: blur(2px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 16px;
  box-sizing: border-box;
}

.mobile-apps-sheet {
  box-sizing: border-box;
  width: 100%;
  max-width: min(calc(100vw - 24px), 420px);
  max-height: 85vh;
  overflow-y: auto;
  padding: 20px 18px 18px;
  border-radius: 16px;
  background: #ffffff;
  box-shadow: 0 16px 36px rgba(12, 32, 58, 0.18);
  display: flex;
  flex-direction: column;
}

.mobile-apps-sheet-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
}

.mobile-apps-sheet-head h2 {
  margin: 0;
  font-size: 16.5px;
  font-weight: 600;
  color: #172b4d;
  line-height: 1.4;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.mobile-apps-sheet-head button {
  border: 0;
  background: none;
  color: #8b9baa;
  cursor: pointer;
  padding: 6px;
  margin: -6px -6px 0 0;
  border-radius: 50%;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.mobile-apps-sheet-head button:active {
  background-color: #f1f4f8;
  color: #243b55;
}

.mobile-apps-sheet-head svg {
  width: 18px;
  height: 18px;
}

.mobile-apps-sheet-fields {
  display: flex;
  flex-direction: column;
}

.mobile-apps-sheet label {
  display: block;
  margin-bottom: 12px;
  font-size: 13px;
  color: #4b6075;
}

.mobile-apps-sheet label span {
  color: #d1493b;
}

.mobile-apps-sheet input,
.mobile-apps-sheet textarea {
  display: block;
  width: 100%;
  box-sizing: border-box;
  margin-top: 6px;
  padding: 9px 12px;
  border-radius: 8px;
  border: 1px solid #dbe2ea;
  font-size: 13px;
  background: #fbfcfe;
}

.mobile-apps-sheet input:focus,
.mobile-apps-sheet textarea:focus {
  border-color: #0052d9;
  outline: none;
  background: #ffffff;
}

.mobile-apps-sheet-footer {
  margin-top: 8px;
}

.mobile-submit-btn {
  height: 40px !important;
  border-radius: 999px !important;
  font-size: 14px !important;
  font-weight: 500 !important;
}

/* 移动端应用访问提示居中模态弹窗样式 */
.mobile-notice-overlay {
  position: fixed;
  inset: 0;
  z-index: 3100;
  background: rgba(12, 32, 58, 0.52);
  backdrop-filter: blur(2px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 16px;
  box-sizing: border-box;
}

.mobile-notice-card {
  box-sizing: border-box;
  width: 100%;
  max-width: min(calc(100vw - 24px), 420px);
  border-radius: 16px;
  background: #ffffff;
  padding: 20px 18px 18px;
  box-shadow: 0 16px 36px rgba(12, 32, 58, 0.18);
  display: flex;
  flex-direction: column;
}

.mobile-notice-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;
}

.mobile-notice-title {
  margin: 0;
  font-size: 16px;
  font-weight: 600;
  color: #172b4d;
}

.mobile-notice-close-btn {
  border: 0;
  background: none;
  color: #8b9baa;
  cursor: pointer;
  padding: 6px;
  margin: -6px -6px 0 0;
  border-radius: 50%;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.mobile-notice-close-btn:active {
  background-color: #f1f4f8;
  color: #243b55;
}

.mobile-notice-close-btn svg {
  width: 18px;
  height: 18px;
}

.mobile-notice-body {
  margin-bottom: 14px;
}

.mobile-notice-info-card {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  padding: 12px 14px;
  border-radius: 10px;
  background: #f0f6ff;
  border: 1px solid #cde0fc;
}

.notice-info-icon {
  flex: none;
  width: 18px;
  height: 18px;
  color: #0052d9;
  margin-top: 1px;
}

.notice-info-text {
  margin: 0;
  font-size: 13.5px;
  line-height: 1.55;
  color: #173f7a;
}

.mobile-notice-footer {
  display: flex;
}

.mobile-notice-confirm-btn {
  width: 100%;
  height: 40px;
  border-radius: 999px;
  border: none;
  background: #0052d9;
  color: #ffffff;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.15s ease;
  display: inline-flex;
  align-items: center;
  justify-content: center;
}

.mobile-notice-confirm-btn:active {
  background: #0043b3;
}

.mobile-apps-error {
  margin: 12px 16px;
  padding: 10px 12px;
  border-radius: 8px;
  background: #fff1ef;
  color: #ba3e38;
  font-size: 13px;
}

.mobile-apps-loading {
  padding: 60px 0;
  text-align: center;
  color: #92a2b5;
  font-size: 14px;
}
</style>
