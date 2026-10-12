<template>
  <div class="mobile-requests">
    <header class="mobile-requests-head">
      <button type="button" aria-label="返回" @click="goBack">
        <ChevronLeftIcon />
      </button>
      <h1>{{ isDetailPage ? '申请详情' : '我的申请' }}</h1>
    </header>

    <template v-if="!isDetailPage">
    <div class="mobile-requests-tabs" role="tablist">
      <button
        type="button"
        role="tab"
        class="requests-tab-btn"
        :class="{ active: tab === 'APPLICATION_ACCESS' }"
        :aria-selected="tab === 'APPLICATION_ACCESS'"
        @click="tab = 'APPLICATION_ACCESS'"
      >
        <span class="tab-title">应用访问申请<span class="tab-count">({{ accessRows.length }})</span></span>
        <span v-if="tab === 'APPLICATION_ACCESS'" class="tab-indicator" aria-hidden="true"></span>
      </button>
      <button
        type="button"
        role="tab"
        class="requests-tab-btn"
        :class="{ active: tab === 'ACCOUNT_OPENING' }"
        :aria-selected="tab === 'ACCOUNT_OPENING'"
        @click="tab = 'ACCOUNT_OPENING'"
      >
        <span class="tab-title">账号开通申请<span class="tab-count">({{ openingRows.length }})</span></span>
        <span v-if="tab === 'ACCOUNT_OPENING'" class="tab-indicator" aria-hidden="true"></span>
      </button>
    </div>

    <div v-if="error" class="mobile-requests-error" role="alert">
      {{ error }} <button type="button" @click="load">重新加载</button>
    </div>

    <div v-if="loading" class="mobile-requests-empty"><MobileLoading message="正在加载申请…" /></div>

    <!-- 申请卡片列表：与全部应用-我的申请保持一致，去掉查看详情字段 -->
    <div v-else-if="visibleRows.length" class="mobile-requests-list">
      <article
        v-for="item in visibleRows"
        :key="item.id"
        class="mobile-app-request-card"
        @click="openDetail(item)"
      >
        <div class="request-card-header">
          <strong>{{ item.appName || '业务应用' }}</strong>
          <span class="request-status-tag" :class="statusClass(item.status)">
            {{ statusText(item.status) }}
          </span>
        </div>
        <div class="request-card-info">
          <span class="info-type">{{ item.requestType === 'ACCOUNT_OPENING' ? '账号开通申请' : '应用访问申请' }}</span>
          <span class="info-date">{{ formatDate(item.submittedAt) }}</span>
        </div>
        <div v-if="item.requestNo" class="request-card-no">申请编号：{{ item.requestNo }}</div>
        <div v-if="item.reviewNote" class="request-card-note">处理意见：{{ item.reviewNote }}</div>

        <!-- 底部快捷操作栏（无查看详情字段，只在有动作时呈现） -->
        <div v-if="hasCardActions(item)" class="request-card-footer">
          <div class="request-quick-actions" @click.stop>
            <button
              v-if="item.status === 'PENDING' && item.requestType === 'APPLICATION_ACCESS'"
              type="button"
              class="action-btn-mini action-btn-danger"
              @click="withdraw(item)"
            >
              撤回申请
            </button>
            <button
              v-else-if="item.status === 'REJECTED' && item.requestType === 'APPLICATION_ACCESS'"
              type="button"
              class="action-btn-mini"
              @click="router.push({ path: '/m/apps', query: { requestAppId: item.appId } })"
            >
              重新申请
            </button>
            <button
              v-else-if="item.status === 'APPROVED' && item.postGrantMode === 'DIRECT'"
              type="button"
              class="action-btn-mini action-btn-primary"
              @click="enter(item)"
            >
              进入应用
            </button>
            <button
              v-else-if="(item.status === 'APPROVED' && item.postGrantMode === 'BIND') || (item.status === 'COMPLETED' && item.requestType === 'ACCOUNT_OPENING')"
              type="button"
              class="action-btn-mini action-btn-primary"
              @click="bind(item)"
            >
              完成账号确认
            </button>
          </div>
        </div>
      </article>
    </div>

    <p v-else class="mobile-requests-empty">暂无申请记录</p>
    </template>

    <!-- 路由详情页：字段、顺序与PC共用请求详情定义，不再使用居中弹窗。 -->
    <main v-else class="mobile-request-detail-page">
      <div v-if="loading" class="mobile-requests-empty"><MobileLoading message="正在加载申请详情…" /></div>
      <template v-else-if="detail">
        <section class="mobile-request-detail-section">
          <h2>申请信息</h2>
          <dl class="mobile-request-detail-grid">
            <div v-for="item in detailSections.application" :key="item.key" class="mobile-request-detail-field">
              <dt>{{ item.label }}</dt>
              <dd>
                <span v-if="item.key === 'status'" class="request-status-tag" :class="statusClass(detail.status)">{{ item.value }}</span>
                <template v-else>{{ item.value }}</template>
              </dd>
            </div>
          </dl>
        </section>
        <section class="mobile-request-detail-section">
          <h2>审核信息</h2>
          <dl class="mobile-request-detail-grid">
            <div v-for="item in detailSections.review" :key="item.key" class="mobile-request-detail-field">
              <dt>{{ item.label }}</dt>
              <dd>{{ item.value }}</dd>
            </div>
          </dl>
        </section>
      </template>
      <div v-else class="mobile-requests-empty">
        <p>{{ error || '该申请不存在或无权查看' }}</p>
        <button type="button" class="mobile-request-detail-back" @click="goBack">返回申请列表</button>
      </div>
      <footer v-if="detail && detailActions.length" class="mobile-request-detail-footer">
        <button
          v-for="action in detailActions"
          :key="action.key"
          type="button"
          class="modal-action-btn"
          :class="action.theme === 'danger' ? 'action-danger' : 'action-primary'"
          @click="performDetailAction(action.key)"
        >{{ action.label }}</button>
      </footer>
    </main>

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
import { ChevronLeftIcon, CloseIcon, InfoCircleFilledIcon } from 'tdesign-icons-vue-next';
import { DialogPlugin } from 'tdesign-vue-next';
import { command, portal, revision } from '../services/runtime.js';
import MobileAccountBindingModal from './MobileAccountBindingModal.vue';
import MobileLoading from './MobileLoading.vue';
import { requestDetailSections, requestDetailActions } from '../components/portal/request-detail.js';

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

type Request = {
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
  userName?: string;
  userId?: string;
  contact?: string;
  remark?: string;
  reviewedByName?: string;
  reviewedAt?: string;
  handledByName?: string;
  handledAt?: string;
  handleNote?: string;
};

type App = {
  id: string;
  name: string;
  accessState?: string;
  primaryAction?: string;
  url?: string;
  externalAccountStatus?: string;
};

const route = useRoute();
const router = useRouter();
const loading = ref(true);
const error = ref('');
const rows = ref<Request[]>([]);
const apps = ref<App[]>([]);
const tab = ref(route.query.tab === 'ACCOUNT_OPENING' ? 'ACCOUNT_OPENING' : 'APPLICATION_ACCESS');
const isDetailPage = computed(() => Boolean(route.params.id));
const detail = computed<Request | null>(() => rows.value.find(item => item.id === String(route.params.id || '')) || null);
const detailSections = computed(() => requestDetailSections(detail.value));
const detailActions = computed(() => requestDetailActions(detail.value));
const bindingVisible = ref(false);
const bindingApp = ref<App | null>(null);

const accessRows = computed(() => rows.value.filter(item => item.requestType === 'APPLICATION_ACCESS'));
const openingRows = computed(() => rows.value.filter(item => item.requestType === 'ACCOUNT_OPENING'));
const visibleRows = computed(() => tab.value === 'APPLICATION_ACCESS' ? accessRows.value : openingRows.value);
const returnOriginQuery = computed(() => ['apps', 'home'].includes(String(route.query.from || '')) ? { from: String(route.query.from) } : {});

function openDetail(item: Request) {
  router.push({ path: `/m/applications/${encodeURIComponent(item.id)}`, query: { ...returnOriginQuery.value, tab: tab.value } });
}
function goBack() {
  if (isDetailPage.value) {
    router.push({ path: '/m/applications', query: { ...returnOriginQuery.value, tab: tab.value } });
  } else {
    router.push(route.query.from === 'apps' ? '/m/apps' : route.query.from === 'home' ? '/m/home' : '/m/profile');
  }
}
function performDetailAction(action: string) {
  const item = detail.value;
  if (!item) return;
  if (action === 'withdraw') void withdraw(item);
  else if (action === 'reapply') reapply(item);
  else if (action === 'enter') void enter(item);
  else if (action === 'bind') bind(item);
}


function statusText(status: string) {
  return (
    {
      PENDING: '待处理',
      APPROVED: '已通过',
      REJECTED: '已驳回',
      WITHDRAWN: '已撤回',
      PROCESSING: '处理中',
      COMPLETED: '已完成',
      FAILED: '处理失败',
    } as Record<string, string>
  )[status] || status;
}

function statusClass(status: string) {
  return ['REJECTED', 'FAILED'].includes(status)
    ? 'is-error'
    : ['PENDING', 'PROCESSING'].includes(status)
      ? 'is-pending'
      : 'is-success';
}

function formatDate(value?: string) {
  const time = Date.parse(value || '');
  return Number.isFinite(time)
    ? new Intl.DateTimeFormat('zh-CN', { year: 'numeric', month: '2-digit', day: '2-digit' }).format(time)
    : '暂无时间';
}

function hasCardActions(item: Request): boolean {
  return (
    (item.status === 'PENDING' && item.requestType === 'APPLICATION_ACCESS') ||
    (item.status === 'REJECTED' && item.requestType === 'APPLICATION_ACCESS') ||
    (item.status === 'APPROVED' && item.postGrantMode === 'DIRECT') ||
    (item.status === 'APPROVED' && item.postGrantMode === 'BIND') ||
    (item.status === 'COMPLETED' && item.requestType === 'ACCOUNT_OPENING')
  );
}

async function load() {
  loading.value = true;
  error.value = '';
  try {
    const [requests, catalog] = await Promise.all([portal.read('myApplicationRequests'), portal.read('apps')]);
    if (!requests.ok) throw new Error(requests.error.message);
    if (!catalog.ok) throw new Error(catalog.error.message);
    rows.value = requests.data || [];
    apps.value = catalog.data || [];
  } catch (cause) {
    error.value = cause instanceof Error ? cause.message : '申请加载失败';
  } finally {
    loading.value = false;
  }
}

async function withdraw(item: Request) {
  const dialog = DialogPlugin.confirm({
    placement: 'center',
    theme: 'danger',
    header: '撤回申请',
    body: '确认撤回此应用访问申请？',
    confirmBtn: { content: '确认撤回', theme: 'danger' },
    onConfirm: async () => {
      dialog.hide();
      const result = await command('withdrawApplicationRequest', { id: item.id, version: item.version });
      if (!result.ok) {
        showAppNotice(result.error.message, '撤回失败');
        return;
      }
      await load();
      showAppNotice('申请已撤回', '撤回成功');
    },
  });
}

async function enter(item: Request) {
  const app = apps.value.find(entry => entry.id === item.appId);
  if (!app) {
    showAppNotice('应用信息不存在，请刷新后重试', '应用访问提示');
    return;
  }
  const result = await command('enterApp', { id: app.id });
  if (result.ok) {
    showAppNotice(result.data.message, '应用访问');
  } else {
    showAppNotice(result.error.message, '应用访问提示');
  }
}

function bind(item: Request) {
  const app = apps.value.find(entry => entry.id === item.appId);
  if (!app) {
    showAppNotice('应用信息不存在，请刷新后重试', '应用访问提示');
    return;
  }
  bindingApp.value = app;
  bindingVisible.value = true;
}

function reapply(item: Request) {
  const appId = item.appId;
  router.push({ path: '/m/apps', query: { requestAppId: appId } });
}

onMounted(load);
watch(revision, load);
watch(() => route.query.tab, value => {
  tab.value = value === 'ACCOUNT_OPENING' ? 'ACCOUNT_OPENING' : 'APPLICATION_ACCESS';
});
</script>

<style scoped src="./mobile-applications.css"></style>
