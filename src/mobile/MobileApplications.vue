<template>
  <div class="mobile-requests">
    <header class="mobile-requests-head">
      <button type="button" aria-label="返回" @click="router.push('/m/profile')">
        <ChevronLeftIcon />
      </button>
      <h1>我的申请</h1>
    </header>

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

    <p v-if="loading" class="mobile-requests-empty">正在加载申请…</p>

    <!-- 申请卡片列表：与全部应用-我的申请保持一致，去掉查看详情字段 -->
    <div v-else-if="visibleRows.length" class="mobile-requests-list">
      <article
        v-for="item in visibleRows"
        :key="item.id"
        class="mobile-app-request-card"
        @click="detail = item"
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

    <!-- 申请详情弹窗（居中弹窗显示样式） -->
    <div v-if="detail" class="mobile-requests-center-overlay" @click.self="detail = null">
      <section
        class="mobile-requests-center-modal"
        role="dialog"
        aria-modal="true"
        aria-label="申请详情"
        tabindex="-1"
      >
        <div class="mobile-modal-head">
          <h2>申请详情</h2>
          <button type="button" aria-label="关闭" @click="detail = null">
            <CloseIcon />
          </button>
        </div>
        <dl class="request-detail-dl">
          <div><dt>应用名称</dt><dd>{{ detail.appName || '-' }}</dd></div>
          <div><dt>申请编号</dt><dd>{{ detail.requestNo || '-' }}</dd></div>
          <div><dt>申请类型</dt><dd>{{ detail.requestType === 'ACCOUNT_OPENING' ? '账号开通申请' : '应用访问申请' }}</dd></div>
          <div>
            <dt>当前状态</dt>
            <dd>
              <span class="request-status-tag" :class="statusClass(detail.status)">
                {{ statusText(detail.status) }}
              </span>
            </dd>
          </div>
          <div><dt>申请时间</dt><dd>{{ formatDate(detail.submittedAt) }}</dd></div>
          <div v-if="detail.reason"><dt>申请原因</dt><dd>{{ detail.reason }}</dd></div>
          <div v-if="detail.reviewNote"><dt>处理意见</dt><dd>{{ detail.reviewNote }}</dd></div>
        </dl>
        <!-- 弹窗底部操作栏：与列表中可操作按钮保持一致，无多余关闭按钮，右上角已有关闭 -->
        <div v-if="hasCardActions(detail)" class="mobile-modal-footer">
          <button
            v-if="detail.status === 'PENDING' && detail.requestType === 'APPLICATION_ACCESS'"
            type="button"
            class="modal-action-btn action-danger"
            @click="withdraw(detail); detail = null"
          >
            撤回申请
          </button>
          <button
            v-else-if="detail.status === 'REJECTED' && detail.requestType === 'APPLICATION_ACCESS'"
            type="button"
            class="modal-action-btn action-default"
            @click="reapply(detail)"
          >
            重新申请
          </button>
          <button
            v-else-if="detail.status === 'APPROVED' && detail.postGrantMode === 'DIRECT'"
            type="button"
            class="modal-action-btn action-primary"
            @click="enter(detail); detail = null"
          >
            进入应用
          </button>
          <button
            v-else-if="(detail.status === 'APPROVED' && detail.postGrantMode === 'BIND') || (detail.status === 'COMPLETED' && detail.requestType === 'ACCOUNT_OPENING')"
            type="button"
            class="modal-action-btn action-primary"
            @click="bind(detail); detail = null"
          >
            完成账号确认
          </button>
        </div>
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
import { useRouter } from 'vue-router';
import { ChevronLeftIcon, CloseIcon, InfoCircleFilledIcon } from 'tdesign-icons-vue-next';
import { DialogPlugin } from 'tdesign-vue-next';
import { command, portal, revision } from '../services/runtime.js';
import MobileAccountBindingModal from './MobileAccountBindingModal.vue';

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
};

type App = {
  id: string;
  name: string;
  accessState?: string;
  primaryAction?: string;
  url?: string;
  externalAccountStatus?: string;
};

const router = useRouter();
const loading = ref(true);
const error = ref('');
const rows = ref<Request[]>([]);
const apps = ref<App[]>([]);
const tab = ref('APPLICATION_ACCESS');
const detail = ref<Request | null>(null);
const bindingVisible = ref(false);
const bindingApp = ref<App | null>(null);

const accessRows = computed(() => rows.value.filter(item => item.requestType === 'APPLICATION_ACCESS'));
const openingRows = computed(() => rows.value.filter(item => item.requestType === 'ACCOUNT_OPENING'));
const visibleRows = computed(() => tab.value === 'APPLICATION_ACCESS' ? accessRows.value : openingRows.value);

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
  detail.value = null;
  router.push({ path: '/m/apps', query: { requestAppId: appId } });
}

onMounted(load);
watch(revision, load);
</script>

<style scoped src="./mobile-applications.css"></style>
