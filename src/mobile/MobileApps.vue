<template>
  <div class="mobile-apps">
    <!-- 顶部标题栏：全部应用标题，胶囊搜索框，无圆角直连 -->
    <header class="mobile-apps-topbar">
      <div class="mobile-apps-title-row">
        <h1>全部应用</h1>
        <!-- 标题右侧的纯文字统计，底部对齐，不再占据独立一行 -->
        <div class="mobile-apps-title-stats" aria-label="应用数量统计">
          <span>共 <strong>{{ apps.length }}</strong> 个</span>
          <span>已关联 <strong>{{ totalBoundCount }}</strong> 个</span>
        </div>
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

<style scoped src="./mobile-apps.css"></style>
