<template>
  <div class="mobile-requests">
    <header class="mobile-requests-head">
      <button type="button" aria-label="返回" @click="router.push('/m/profile')">
        <ChevronLeftIcon />
      </button>
      <h1>我的申请</h1>
    </header>

    <div class="mobile-requests-tabs">
      <button type="button" :class="{ active: tab === 'APPLICATION_ACCESS' }" @click="tab = 'APPLICATION_ACCESS'">
        应用访问申请 <span>{{ accessRows.length }}</span>
      </button>
      <button type="button" :class="{ active: tab === 'ACCOUNT_OPENING' }" @click="tab = 'ACCOUNT_OPENING'">
        账号开通申请 <span>{{ openingRows.length }}</span>
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
        <div class="mobile-modal-footer">
          <button
            v-if="detail.status === 'PENDING' && detail.requestType === 'APPLICATION_ACCESS'"
            type="button"
            class="modal-btn-withdraw"
            @click="withdraw(detail); detail = null"
          >
            撤回申请
          </button>
          <button type="button" class="modal-btn-close" @click="detail = null">关闭</button>
        </div>
      </section>
    </div>

    <AccountBindingWizard v-model:visible="bindingVisible" :app="bindingApp || undefined" @completed="load" />
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue';
import { useRouter } from 'vue-router';
import { ChevronLeftIcon, CloseIcon } from 'tdesign-icons-vue-next';
import { command, portal, revision } from '../services/runtime.js';
import AccountBindingWizard from '../components/portal/AccountBindingWizard.vue';

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
  if (!window.confirm('确认撤回此应用访问申请？')) return;
  const result = await command('withdrawApplicationRequest', { id: item.id, version: item.version });
  if (!result.ok) {
    window.alert(result.error.message);
    return;
  }
  await load();
}

async function enter(item: Request) {
  const app = apps.value.find(entry => entry.id === item.appId);
  if (!app) {
    window.alert('应用信息不存在，请刷新后重试');
    return;
  }
  const result = await command('enterApp', { id: app.id });
  window.alert(result.ok ? result.data.message : result.error.message);
}

function bind(item: Request) {
  const app = apps.value.find(entry => entry.id === item.appId);
  if (!app) {
    window.alert('应用信息不存在，请刷新后重试');
    return;
  }
  bindingApp.value = app;
  bindingVisible.value = true;
}

onMounted(load);
watch(revision, load);
</script>

<style scoped>
.mobile-requests {
  padding: 0 16px 28px;
  color: #1d3552;
  box-sizing: border-box;
}

.mobile-requests-head {
  display: flex;
  align-items: center;
  gap: 13px;
  height: 54px;
  margin: 0 -16px;
  padding: 0 16px;
  background: #ffffff;
  border-bottom: 1px solid #edf1f5;
}

.mobile-requests-head button {
  display: grid;
  place-items: center;
  width: 28px;
  height: 28px;
  border: 0;
  background: none;
  color: #355577;
  cursor: pointer;
}

.mobile-requests-head svg {
  width: 21px;
  height: 21px;
}

.mobile-requests-head h1 {
  margin: 0;
  font-size: 18px;
  font-weight: 600;
}

.mobile-requests-tabs {
  display: flex;
  gap: 10px;
  margin: 16px 0;
}

.mobile-requests-tabs button {
  flex: 1;
  padding: 10px 6px;
  border: 0;
  border-radius: 11px;
  background: #edf2f7;
  color: #5d758d;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
}

.mobile-requests-tabs button.active {
  background: #ecf2fe;
  color: #0052d9;
  font-weight: 700;
}

.mobile-requests-tabs span {
  margin-left: 3px;
}

.mobile-requests-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

/* 申请卡片：与全部应用-我的申请完全统一的卡片布局 */
.mobile-app-request-card {
  border: 1px solid #edf2f7;
  border-radius: 14px;
  background: #ffffff;
  padding: 15px 16px;
  box-shadow: 0 4px 14px rgba(16, 54, 99, 0.04);
  cursor: pointer;
  transition: background-color 0.15s ease;
}

.mobile-app-request-card:active {
  background-color: #fbfcfe;
}

.request-card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
}

.request-card-header strong {
  font-size: 15px;
  color: #1a2d48;
  font-weight: 600;
}

.request-status-tag {
  display: inline-flex;
  align-items: center;
  padding: 2px 8px;
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
  margin-top: 7px;
  padding: 7px 10px;
  border-radius: 6px;
  background: #f8fafc;
  color: #586e82;
  font-size: 12px;
  line-height: 1.4;
}

.request-card-footer {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  margin-top: 10px;
  padding-top: 10px;
  border-top: 1px solid #f1f4f8;
}

.request-quick-actions {
  display: flex;
  gap: 8px;
}

.action-btn-mini {
  padding: 4px 12px;
  border: 1px solid #d2dbe5;
  border-radius: 14px;
  background: #ffffff;
  color: #5b6f82;
  font-size: 12px;
  cursor: pointer;
  transition: all 0.15s ease;
}

.action-btn-mini.action-btn-danger {
  border-color: #fbd6d4;
  color: #e34d59;
  background: #fffafa;
}

.action-btn-mini.action-btn-primary {
  border-color: #bad3fb;
  color: #0052d9;
  background: #f2f7ff;
}

.mobile-requests-empty {
  padding: 40px 0;
  text-align: center;
  color: #94a4b4;
  font-size: 14px;
}

.mobile-requests-error {
  padding: 12px;
  border-radius: 10px;
  background: #fff0ed;
  color: #ad4b3d;
  font-size: 13px;
}

.mobile-requests-error button {
  border: 0;
  background: none;
  color: #ad4b3d;
  cursor: pointer;
}

/* 居中模态弹窗样式（申请详情） */
.mobile-requests-center-overlay {
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

.mobile-requests-center-modal {
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

.request-detail-dl div {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 16px;
  padding: 11px 0;
  border-top: 1px solid #edf1f6;
  font-size: 13.5px;
}

.request-detail-dl dt {
  flex: none;
  color: #8194a6;
}

.request-detail-dl dd {
  margin: 0;
  text-align: right;
  overflow-wrap: anywhere;
  color: #1c3047;
  font-weight: 500;
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
</style>

<style>
@media (max-width: 600px) {
  body:has(.mobile-requests) .t-dialog { width: calc(100vw - 24px) !important; max-width: calc(100vw - 24px) !important; }
  body:has(.mobile-requests) .binding-wizard { max-width: 100%; }
  body:has(.mobile-requests) .binding-actions { flex-wrap: wrap; }
}
</style>
