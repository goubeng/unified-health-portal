<template>
  <div class="mobile-apps">
    <!-- 顶部标题栏：带全部应用与我的申请两个Tab页签，胶囊搜索框，无圆角直连 -->
    <header class="mobile-apps-topbar">
      <div class="mobile-apps-title-row">
        <nav class="mobile-apps-tabs-nav" aria-label="应用与申请分类">
          <button
            type="button"
            class="top-tab-btn"
            :class="{ active: currentTab === 'ALL_APPS' }"
            :aria-selected="currentTab === 'ALL_APPS'"
            @click="switchTab('ALL_APPS')"
          >
            <span>全部应用</span>
            <span v-if="currentTab === 'ALL_APPS'" class="top-tab-indicator" aria-hidden="true"></span>
          </button>
          <button
            type="button"
            class="top-tab-btn"
            :class="{ active: currentTab === 'MY_REQUESTS' }"
            :aria-selected="currentTab === 'MY_REQUESTS'"
            @click="switchTab('MY_REQUESTS')"
          >
            <span>我的申请</span>
            <span v-if="myRequests.length" class="top-tab-badge">{{ myRequests.length }}</span>
            <span v-if="currentTab === 'MY_REQUESTS'" class="top-tab-indicator" aria-hidden="true"></span>
          </button>
        </nav>
      </div>

      <div class="mobile-apps-search-wrap">
        <TMobileInput
          v-model="keyword"
          :placeholder="currentTab === 'ALL_APPS' ? '搜索应用名称或编码' : '搜索申请应用名称或编号'"
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

    <!-- Tab 1: 全部应用视图（左右分栏主体） -->
    <div v-else-if="currentTab === 'ALL_APPS'" class="mobile-apps-body">
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
                @click.stop="switchTab('MY_REQUESTS')"
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

    <!-- Tab 2: 我的申请视图（申请记录列表） -->
    <div v-else class="mobile-apps-requests-body">
      <div v-if="filteredRequests.length" class="requests-item-list">
        <article
          v-for="item in filteredRequests"
          :key="item.id"
          class="mobile-app-request-card"
          @click="openRequestDetail(item)"
        >
          <div class="request-card-header">
            <strong>{{ item.appName || '业务应用' }}</strong>
            <span class="request-status-tag" :class="statusClass(item.status)">
              {{ statusText(item.status) }}
            </span>
          </div>
          <div class="request-card-info">
            <span class="info-type">{{ item.requestType === 'ACCOUNT_OPENING' ? '账号开通申请' : '应用访问申请' }}</span>
            <span class="info-date">{{ formatRequestDate(item.submittedAt) }}</span>
          </div>
          <div v-if="item.requestNo" class="request-card-no">申请编号：{{ item.requestNo }}</div>
          <div v-if="item.reviewNote" class="request-card-note">处理意见：{{ item.reviewNote }}</div>

          <div v-if="item.status === 'PENDING' && item.requestType === 'APPLICATION_ACCESS'" class="request-card-footer">
            <div class="request-quick-actions" @click.stop>
              <button
                type="button"
                class="action-btn-mini"
                @click="withdrawRequest(item)"
              >
                撤回申请
              </button>
            </div>
          </div>
        </article>
      </div>

      <div v-else class="requests-empty-view">
        <p>{{ keyword ? '未找到匹配的申请记录' : '暂无申请记录' }}</p>
      </div>
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

    <!-- 申请详情居中弹窗 -->
    <div v-if="requestDetail" class="mobile-apps-center-overlay" @click.self="closeRequestDetail">
      <section class="mobile-apps-center-modal" role="dialog" aria-modal="true" aria-label="申请详情" tabindex="-1">
        <div class="mobile-modal-head">
          <h2>申请详情</h2>
          <button type="button" aria-label="关闭" @click="closeRequestDetail"><CloseIcon /></button>
        </div>
        <dl class="request-detail-dl">
          <div><dt>应用名称</dt><dd>{{ requestDetail.appName || '-' }}</dd></div>
          <div><dt>申请编号</dt><dd>{{ requestDetail.requestNo || '-' }}</dd></div>
          <div><dt>申请类型</dt><dd>{{ requestDetail.requestType === 'ACCOUNT_OPENING' ? '账号开通申请' : '应用访问申请' }}</dd></div>
          <div>
            <dt>当前状态</dt>
            <dd><span class="request-status-tag" :class="statusClass(requestDetail.status)">{{ statusText(requestDetail.status) }}</span></dd>
          </div>
          <div><dt>申请时间</dt><dd>{{ formatRequestDate(requestDetail.submittedAt) }}</dd></div>
          <div v-if="requestDetail.reason"><dt>申请原因</dt><dd>{{ requestDetail.reason }}</dd></div>
          <div v-if="requestDetail.reviewNote"><dt>处理意见</dt><dd>{{ requestDetail.reviewNote }}</dd></div>
        </dl>
        <div class="mobile-modal-footer">
          <button
            v-if="requestDetail.status === 'PENDING' && requestDetail.requestType === 'APPLICATION_ACCESS'"
            type="button"
            class="modal-btn-withdraw"
            @click="withdrawRequest(requestDetail); closeRequestDetail()"
          >
            撤回申请
          </button>
          <button type="button" class="modal-btn-close" @click="closeRequestDetail">关闭</button>
        </div>
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

type ApplicationRequest = {
  id: string;
  version: number;
  appId: string;
  appName?: string;
  requestNo?: string;
  requestType: string;
  status: string;
  submittedAt?: string;
  reviewNote?: string;
  reason?: string;
  postGrantMode?: string;
};

const ALL_CATEGORY = '全部';
const APP_TONE_COUNT = 4;
const MAX_SEARCH_LENGTH = 50;

const route = useRoute();
const router = useRouter();
const loading = ref(true);
const error = ref('');
const apps = ref<App[]>([]);
const myRequests = ref<ApplicationRequest[]>([]);
const keyword = ref('');
const currentTab = ref<'ALL_APPS' | 'MY_REQUESTS'>('ALL_APPS');
const currentCategory = ref(ALL_CATEGORY);
const requestApp = ref<App | null>(null);
const requestSheet = ref<HTMLElement | null>(null);

const { closeDialog } = useMobileDialog({
  open: computed(() => Boolean(requestApp.value)),
  element: computed(() => requestSheet.value),
  close: () => { requestApp.value = null; },
});

const requestDetail = ref<ApplicationRequest | null>(null);
const requestDetailSheet = ref<HTMLElement | null>(null);

const { closeDialog: closeRequestDetail } = useMobileDialog({
  open: computed(() => Boolean(requestDetail.value)),
  element: computed(() => requestDetailSheet.value),
  close: () => { requestDetail.value = null; },
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

const filteredRequests = computed(() => {
  const term = keyword.value.trim().toLocaleLowerCase();
  return myRequests.value.filter(req => {
    if (!term) return true;
    return `${req.appName || ''} ${req.requestNo || ''}`.toLocaleLowerCase().includes(term);
  }).sort((a, b) => (Date.parse(b.submittedAt || '') || 0) - (Date.parse(a.submittedAt || '') || 0));
});

const currentCategoryTitle = computed(() => {
  if (keyword.value.trim()) return '搜索结果';
  return currentCategory.value === ALL_CATEGORY ? '全部应用' : currentCategory.value;
});

function switchTab(tab: 'ALL_APPS' | 'MY_REQUESTS') {
  currentTab.value = tab;
  keyword.value = '';
}

function selectCategory(item: string) {
  currentCategory.value = item;
}

function statusText(status: string): string {
  return ({ PENDING: '待处理', APPROVED: '已通过', REJECTED: '已驳回', WITHDRAWN: '已撤回', PROCESSING: '处理中', COMPLETED: '已完成', FAILED: '处理失败' } as Record<string, string>)[status] || status;
}

function statusClass(status: string): string {
  return ['REJECTED', 'FAILED'].includes(status) ? 'is-error' : ['PENDING', 'PROCESSING'].includes(status) ? 'is-pending' : 'is-success';
}

function formatRequestDate(value?: string): string {
  if (!value) return '暂无时间';
  const d = new Date(value);
  if (Number.isNaN(d.getTime())) return value;
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${day}`;
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
    const [all, requests] = await Promise.all([read('apps'), read('myApplicationRequests')]);
    apps.value = [...(all || [])].sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0));
    myRequests.value = requests || [];

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
    switchTab('MY_REQUESTS');
  }
}

function handleAppClick(app: App) {
  if (app.enabled === false) return;
  takeAction(app);
}

function openRequestDetail(item: ApplicationRequest) {
  requestDetail.value = item;
}

async function withdrawRequest(item: ApplicationRequest) {
  if (!window.confirm('确认撤回此应用访问申请？')) return;
  const result = await command('withdrawApplicationRequest', { id: item.id, version: item.version });
  if (!result.ok) {
    window.alert(result.error.message);
    return;
  }
  await load();
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

/* 顶部栏：蓝渐变、Tab页签、无圆角平直连接 */
.mobile-apps-topbar {
  flex: none;
  background: linear-gradient(135deg, #0052d9 0%, #1e6beb 58%, #4489f7 100%);
  padding: 16px 16px 14px;
  color: #ffffff;
}

.mobile-apps-title-row {
  display: flex;
  align-items: center;
  justify-content: flex-start;
  margin-bottom: 12px;
}

/* 顶部 Tab 页签：全部应用 vs 我的申请 */
.mobile-apps-tabs-nav {
  display: flex;
  align-items: center;
  gap: 22px;
}

.top-tab-btn {
  position: relative;
  display: inline-flex;
  align-items: center;
  gap: 5px;
  border: 0;
  background: transparent;
  color: rgba(255, 255, 255, 0.76);
  font-size: 17px;
  font-weight: 500;
  padding: 4px 0 8px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.top-tab-btn.active {
  color: #ffffff;
  font-size: 19px;
  font-weight: 700;
}

.top-tab-indicator {
  position: absolute;
  left: 50%;
  bottom: 0;
  transform: translateX(-50%);
  width: 22px;
  height: 3px;
  border-radius: 2px;
  background: #ffffff;
}

.top-tab-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  min-width: 16px;
  height: 16px;
  padding: 0 5px;
  border-radius: 8px;
  background: #e34d59;
  color: #ffffff;
  font-size: 11px;
  font-weight: 700;
  line-height: 1;
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

/* Tab 2: 我的申请视图样式 */
.mobile-apps-requests-body {
  flex: 1;
  min-height: 0;
  overflow-y: auto;
  background: #f7f9fc;
  padding: 14px 16px 24px;
  -webkit-overflow-scrolling: touch;
}

.requests-item-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.mobile-app-request-card {
  background: #ffffff;
  border: 1px solid #edf2f6;
  border-radius: 16px;
  padding: 14px 15px;
  box-shadow: 0 3px 12px rgba(18, 52, 95, 0.04);
  cursor: pointer;
  transition: background-color 0.15s ease;
}

.mobile-app-request-card:active {
  background-color: #f9fbfd;
}

.request-card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 8px;
}

.request-card-header strong {
  font-size: 15px;
  color: #192d47;
  font-weight: 600;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.request-status-tag {
  display: inline-flex;
  align-items: center;
  padding: 2px 7px;
  border-radius: 4px;
  font-size: 11.5px;
  font-weight: 600;
  background: #eef2f6;
  color: #6a7e92;
}

.request-status-tag.is-success {
  background: #e7f7ee;
  color: #109459;
}

.request-status-tag.is-pending {
  background: #fef5e7;
  color: #c97914;
}

.request-status-tag.is-error {
  background: #fff0ee;
  color: #d1493b;
}

.request-card-info {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 8px;
  font-size: 12px;
  color: #8c9fae;
}

.info-type {
  color: #556c80;
}

.request-card-no {
  margin-top: 5px;
  font-size: 11.5px;
  color: #9cb0c2;
}

.request-card-note {
  margin-top: 6px;
  padding: 6px 10px;
  border-radius: 6px;
  background: #f8fafc;
  color: #586e82;
  font-size: 12px;
  line-height: 1.4;
}

.request-card-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 10px;
  padding-top: 10px;
  border-top: 1px solid #f1f4f8;
}

.view-detail-hint {
  display: inline-flex;
  align-items: center;
  gap: 2px;
  font-size: 12px;
  color: #0052d9;
}

.view-detail-hint .arrow-icon {
  width: 13px;
  height: 13px;
}

.action-btn-mini {
  padding: 3px 10px;
  border: 1px solid #d2dbe5;
  border-radius: 12px;
  background: #ffffff;
  color: #5b6f82;
  font-size: 12px;
  cursor: pointer;
}

.requests-empty-view {
  padding: 60px 0;
  text-align: center;
  color: #93a4b6;
  font-size: 14px;
}

/* 弹窗通用样式 */
.mobile-apps-overlay {
  position: fixed;
  inset: 0;
  z-index: 3000;
  background: rgba(12, 32, 58, 0.45);
  display: flex;
  align-items: flex-end;
  justify-content: center;
}

.mobile-apps-sheet {
  box-sizing: border-box;
  width: 100%;
  max-width: 480px;
  margin: 0 auto;
  max-height: 82vh;
  overflow-y: auto;
  padding: 20px 20px max(24px, env(safe-area-inset-bottom));
  border-radius: 22px 22px 0 0;
  background: #ffffff;
}

/* 居中模态弹窗样式（申请详情） */
.mobile-apps-center-overlay {
  position: fixed;
  inset: 0;
  z-index: 3000;
  background: rgba(12, 32, 58, 0.5);
  backdrop-filter: blur(2px);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
  box-sizing: border-box;
}

.mobile-apps-center-modal {
  box-sizing: border-box;
  width: 100%;
  max-width: 360px;
  max-height: 82vh;
  overflow-y: auto;
  padding: 22px 20px 20px;
  border-radius: 18px;
  background: #ffffff;
  box-shadow: 0 16px 36px rgba(0, 0, 0, 0.2);
}

.mobile-modal-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
}

.mobile-modal-head h2 {
  margin: 0;
  font-size: 17px;
  font-weight: 600;
  color: #182e49;
}

.mobile-modal-head button {
  border: 0;
  background: none;
  color: #8b9baa;
  cursor: pointer;
  padding: 4px;
}

.mobile-modal-head svg {
  width: 20px;
  height: 20px;
}

.mobile-modal-footer {
  display: flex;
  gap: 10px;
  margin-top: 20px;
}

.modal-btn-withdraw {
  flex: 1;
  height: 38px;
  border-radius: 999px;
  border: 1px solid #e34d59;
  background: #ffffff;
  color: #e34d59;
  font-size: 13.5px;
  font-weight: 500;
  cursor: pointer;
}

.modal-btn-close {
  flex: 1;
  height: 38px;
  border-radius: 999px;
  border: none;
  background: #0052d9;
  color: #ffffff;
  font-size: 13.5px;
  font-weight: 500;
  cursor: pointer;
}

.mobile-apps-sheet-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 14px;
}

.mobile-apps-sheet-head h2 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
  color: #182e49;
}

.mobile-apps-sheet-head button {
  border: 0;
  background: none;
  color: #8b9baa;
  cursor: pointer;
  padding: 4px;
}

.mobile-apps-sheet-head svg {
  width: 20px;
  height: 20px;
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
}

.request-detail-dl div {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  padding: 12px 0;
  border-top: 1px solid #edf1f6;
  font-size: 14px;
}

.request-detail-dl dt {
  color: #8596a7;
  flex: none;
}

.request-detail-dl dd {
  margin: 0;
  text-align: right;
  color: #1a2d48;
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
