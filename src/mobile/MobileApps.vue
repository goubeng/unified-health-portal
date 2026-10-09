<template>
  <div class="mobile-apps">
    <!-- 顶部标题栏与搜索区 -->
    <header class="mobile-apps-topbar">
      <div class="mobile-apps-title-row">
        <div class="mobile-apps-title">
          <h1>全部应用</h1>
          <span>卫健便民 · 协同大厅</span>
        </div>
        <button type="button" class="mobile-apps-my-request-btn" @click="router.push('/m/applications')">
          我的申请 <ChevronRightIcon />
        </button>
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
    <div v-if="loading" class="mobile-apps-loading">正在加载应用…</div>

    <!-- 左右分栏主体 -->
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
            v-for="(app, index) in currentApps"
            :key="app.id"
            class="app-item-row"
            :class="{ disabled: app.enabled === false }"
            @click="handleAppClick(app)"
          >
            <!-- 左侧彩色圆角应用图标 -->
            <div class="app-item-icon" :class="`tone-${index % APP_TONE_COUNT}`">
              <AppIcon />
            </div>

            <!-- 中间纯净应用名称 -->
            <div class="app-item-info">
              <span class="app-item-name">{{ app.name }}</span>
            </div>

            <!-- 右侧操作入口与图标（进入应用、去关联等） -->
            <div class="app-item-action">
              <!-- 去关联 -->
              <button
                v-if="isBindAction(app)"
                type="button"
                class="app-btn-pill pill-bind"
                @click.stop="takeAction(app)"
              >
                去关联
              </button>

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

    <!-- 申请使用弹窗 -->
    <div v-if="requestApp" class="mobile-apps-overlay" @click.self="closeDialog">
      <section ref="requestSheet" class="mobile-apps-sheet" role="dialog" aria-modal="true" aria-label="申请使用应用" tabindex="-1">
        <div class="mobile-apps-sheet-head">
          <h2>申请使用 · {{ requestApp.name }}</h2>
          <button type="button" aria-label="关闭" @click="closeDialog"><CloseIcon /></button>
        </div>
        <label>申请原因 <span>*</span><textarea v-model.trim="requestReason" rows="4" placeholder="请填写申请使用原因"></textarea></label>
        <label>联系方式<input v-model.trim="requestContact" type="text" placeholder="选填" /></label>
        <label>备注<textarea v-model.trim="requestRemark" rows="2" placeholder="选填"></textarea></label>
        <p v-if="requestError" class="mobile-apps-error" role="alert">{{ requestError }}</p>
        <MobileButton block :loading="saving" @click="submitRequest">提交申请</MobileButton>
      </section>
    </div>

    <!-- 账号关联向导 -->
    <AccountBindingWizard v-model:visible="bindingVisible" :app="bindingApp || undefined" @completed="load" />
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { Button as MobileButton, Input as TMobileInput } from 'tdesign-mobile-vue';
import { AppIcon, ChevronRightIcon, CloseIcon } from 'tdesign-icons-vue-next';
import { command, portal, revision } from '../services/runtime.js';
import AccountBindingWizard from '../components/portal/AccountBindingWizard.vue';
import { useMobileDialog } from './useMobileDialog';

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
const APP_TONE_COUNT = 4;
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

const currentApps = computed(() => {
  const term = keyword.value.trim().toLocaleLowerCase();
  return apps.value.filter(app => {
    const matchCategory = currentCategory.value === ALL_CATEGORY || app.category === currentCategory.value;
    const matchKeyword = !term || `${app.name} ${app.code || ''}`.toLocaleLowerCase().includes(term);
    return matchCategory && matchKeyword;
  });
});

const currentCategoryTitle = computed(() => {
  if (keyword.value.trim()) return '搜索结果';
  return currentCategory.value === ALL_CATEGORY ? '全部应用' : currentCategory.value;
});

function selectCategory(item: string) {
  currentCategory.value = item;
}

function isBindAction(app: App): boolean {
  return ['BIND', 'CONTINUE_BIND', 'RETRY_BIND'].includes(app.primaryAction || '') || app.accessState === 'UNBOUND';
}

function isProgressAction(app: App): boolean {
  return ['VIEW_BINDING', 'VIEW_REQUEST'].includes(app.primaryAction || '') || ['REQUEST_PENDING', 'REVIEWING', 'VERIFYING'].includes(app.accessState || '');
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
    const [all] = await Promise.all([read('apps')]);
    apps.value = [...(all || [])].sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0));

    // 如果当前选中的分类不在列表中，重置为全部
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
      window.alert('应用入口暂不可用，请稍后重试');
      return;
    }
    const result = await command('enterApp', { id: app.id });
    window.alert(result.ok ? result.data.message : result.error.message);
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
    window.alert('申请已提交，可在“我的申请”查看进度');
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

.mobile-apps-topbar {
  flex: none;
  background: #ffffff;
  padding: 14px 16px 10px;
  border-bottom: 1px solid #edf1f6;
  box-shadow: 0 2px 8px rgba(18, 52, 92, 0.03);
}

.mobile-apps-title-row {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 10px;
}

.mobile-apps-title h1 {
  margin: 0;
  font-size: 19px;
  font-weight: 600;
  color: #172b48;
  line-height: 1.25;
}

.mobile-apps-title span {
  display: block;
  font-size: 12px;
  color: #8b9cb0;
  margin-top: 2px;
}

.mobile-apps-my-request-btn {
  display: inline-flex;
  align-items: center;
  gap: 2px;
  padding: 5px 10px;
  border: 0;
  border-radius: 14px;
  background: #ecf2fe;
  color: #0052d9;
  font-size: 12px;
  font-weight: 500;
  cursor: pointer;
}

.mobile-apps-my-request-btn svg {
  width: 13px;
  height: 13px;
}

.mobile-apps-search-wrap {
  width: 100%;
}

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

.app-item-name {
  display: block;
  font-size: 15px;
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

.app-btn-pill {
  border: 0;
  border-radius: 14px;
  padding: 4px 10px;
  font-size: 12px;
  font-weight: 500;
  cursor: pointer;
  transition: transform 0.1s ease;
}

.app-btn-pill:active {
  transform: scale(0.96);
}

.pill-bind {
  background: #ecf2fe;
  color: #0052d9;
}

.pill-request {
  background: #fef4e8;
  color: #d97706;
}

.pill-progress {
  background: #f1f4f9;
  color: #5d718a;
}

.app-text-disabled {
  font-size: 12px;
  color: #a0aec0;
}

.app-enter-action {
  display: flex;
  align-items: center;
  color: #b5c2d1;
}

.app-chevron-icon {
  width: 16px;
  height: 16px;
}

.apps-empty-view,
.mobile-apps-loading {
  padding: 32px 0;
  text-align: center;
  color: #8fa1b5;
  font-size: 14px;
}

.mobile-apps-error {
  margin: 12px;
  padding: 10px 14px;
  border-radius: 12px;
  background: #fff2f0;
  color: #aa4c3d;
  font-size: 13px;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.mobile-apps-error button {
  border: 0;
  background: none;
  color: #ba4b3b;
  cursor: pointer;
}

.mobile-apps-overlay {
  position: fixed;
  z-index: 3000;
  inset: 0;
  display: flex;
  align-items: flex-end;
  background: rgba(11, 30, 53, 0.45);
}

.mobile-apps-sheet {
  box-sizing: border-box;
  width: 100%;
  max-height: 84vh;
  overflow: auto;
  padding: 20px 20px max(24px, env(safe-area-inset-bottom));
  border-radius: 22px 22px 0 0;
  background: #ffffff;
}

.mobile-apps-sheet-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 15px;
}

.mobile-apps-sheet-head h2 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
}

.mobile-apps-sheet-head button {
  border: 0;
  background: none;
  color: #677f98;
  cursor: pointer;
}

.mobile-apps-sheet-head svg {
  width: 20px;
  height: 20px;
}

.mobile-apps-sheet label {
  display: block;
  margin: 12px 0;
  color: #465b73;
  font-size: 14px;
}

.mobile-apps-sheet label span {
  color: #d65b48;
}

.mobile-apps-sheet textarea,
.mobile-apps-sheet input {
  box-sizing: border-box;
  display: block;
  width: 100%;
  margin-top: 7px;
  padding: 10px;
  border: 1px solid #dce5ee;
  border-radius: 9px;
  outline: 0;
  font: inherit;
}
</style>

<style>
@media (max-width: 600px) {
  body:has(.mobile-apps) .t-dialog {
    width: calc(100vw - 24px) !important;
    max-width: calc(100vw - 24px) !important;
  }
  body:has(.mobile-apps) .binding-wizard {
    max-width: 100%;
  }
  body:has(.mobile-apps) .binding-actions {
    flex-wrap: wrap;
  }
}
</style>
