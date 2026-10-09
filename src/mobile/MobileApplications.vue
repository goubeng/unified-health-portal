<template>
  <div class="mobile-requests">
    <header class="mobile-requests-head"><button type="button" aria-label="返回" @click="router.push('/m/profile')"><ChevronLeftIcon /></button><h1>我的申请</h1></header>
    <div class="mobile-requests-tabs"><button type="button" :class="{ active: tab === 'APPLICATION_ACCESS' }" @click="tab = 'APPLICATION_ACCESS'">应用访问申请 <span>{{ accessRows.length }}</span></button><button type="button" :class="{ active: tab === 'ACCOUNT_OPENING' }" @click="tab = 'ACCOUNT_OPENING'">账号开通申请 <span>{{ openingRows.length }}</span></button></div>
    <div v-if="error" class="mobile-requests-error" role="alert">{{ error }} <button type="button" @click="load">重新加载</button></div>
    <p v-if="loading" class="mobile-requests-empty">正在加载申请…</p>
    <div v-else-if="visibleRows.length" class="mobile-requests-list">
      <article v-for="item in visibleRows" :key="item.id" class="mobile-request-card">
        <button type="button" class="mobile-request-main" @click="detail = item"><span><strong>{{ item.appName || '业务应用' }}</strong><small>{{ item.requestNo || '暂无申请编号' }}</small></span><ChevronRightIcon /></button>
        <div class="mobile-request-summary"><span>{{ formatDate(item.submittedAt) }}</span><b :class="statusClass(item.status)">{{ statusText(item.status) }}</b></div>
        <div v-if="item.reviewNote" class="mobile-request-note">处理意见：{{ item.reviewNote }}</div>
        <div v-if="item.status === 'PENDING' && item.requestType === 'APPLICATION_ACCESS'" class="mobile-request-actions"><MobileButton size="small" variant="outline" @click="withdraw(item)">撤回申请</MobileButton></div>
        <div v-else-if="item.status === 'REJECTED' && item.requestType === 'APPLICATION_ACCESS'" class="mobile-request-actions"><MobileButton size="small" variant="outline" @click="router.push({ path: '/m/apps', query: { requestAppId: item.appId } })">重新申请</MobileButton></div>
        <div v-else-if="item.status === 'APPROVED' && item.postGrantMode === 'DIRECT'" class="mobile-request-actions"><MobileButton size="small" variant="outline" @click="enter(item)">进入应用</MobileButton></div>
        <div v-else-if="item.status === 'APPROVED' && item.postGrantMode === 'BIND' || item.status === 'COMPLETED' && item.requestType === 'ACCOUNT_OPENING'" class="mobile-request-actions"><MobileButton size="small" variant="outline" @click="bind(item)">完成账号确认</MobileButton></div>
      </article>
    </div>
    <p v-else class="mobile-requests-empty">暂无申请记录</p>
    <div v-if="detail" class="mobile-requests-overlay" @click.self="closeDialog"><section ref="detailSheet" class="mobile-requests-sheet" role="dialog" aria-modal="true" aria-label="申请详情" tabindex="-1"><div class="mobile-requests-sheet-head"><h2>申请详情</h2><button type="button" aria-label="关闭" @click="closeDialog"><CloseIcon /></button></div><dl><div><dt>应用名称</dt><dd>{{ detail.appName || '-' }}</dd></div><div><dt>申请编号</dt><dd>{{ detail.requestNo || '-' }}</dd></div><div><dt>申请类型</dt><dd>{{ detail.requestType === 'ACCOUNT_OPENING' ? '账号开通申请' : '应用访问申请' }}</dd></div><div><dt>当前状态</dt><dd>{{ statusText(detail.status) }}</dd></div><div><dt>申请时间</dt><dd>{{ formatDate(detail.submittedAt) }}</dd></div><div v-if="detail.reason"><dt>申请原因</dt><dd>{{ detail.reason }}</dd></div><div v-if="detail.reviewNote"><dt>处理意见</dt><dd>{{ detail.reviewNote }}</dd></div></dl></section></div>
    <AccountBindingWizard v-model:visible="bindingVisible" :app="bindingApp || undefined" @completed="load" />
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue';
import { useRouter } from 'vue-router';
import { Button as MobileButton } from 'tdesign-mobile-vue';
import { ChevronLeftIcon, ChevronRightIcon, CloseIcon } from 'tdesign-icons-vue-next';
import { command, portal, revision } from '../services/runtime.js';
import AccountBindingWizard from '../components/portal/AccountBindingWizard.vue';
import { useMobileDialog } from './useMobileDialog';

type Request = { id: string; version: number; appId: string; appName?: string; requestNo?: string; requestType: string; status: string; submittedAt?: string; reviewNote?: string; reason?: string; postGrantMode?: string };
type App = { id: string; name: string; accessState?: string; primaryAction?: string; url?: string; externalAccountStatus?: string };
const router = useRouter();
const loading = ref(true);
const error = ref('');
const rows = ref<Request[]>([]);
const apps = ref<App[]>([]);
const tab = ref('APPLICATION_ACCESS');
const detail = ref<Request | null>(null);
const detailSheet = ref<HTMLElement | null>(null);
const { closeDialog } = useMobileDialog({open: computed(() => Boolean(detail.value)), element: detailSheet, close: () => { detail.value = null; }});
const bindingVisible = ref(false);
const bindingApp = ref<App | null>(null);
const accessRows = computed(() => rows.value.filter(item => item.requestType === 'APPLICATION_ACCESS'));
const openingRows = computed(() => rows.value.filter(item => item.requestType === 'ACCOUNT_OPENING'));
const visibleRows = computed(() => tab.value === 'APPLICATION_ACCESS' ? accessRows.value : openingRows.value);
function statusText(status: string) { return ({ PENDING: '待处理', APPROVED: '已通过', REJECTED: '已驳回', WITHDRAWN: '已撤回', PROCESSING: '处理中', COMPLETED: '已完成', FAILED: '处理失败' } as Record<string, string>)[status] || status; }
function statusClass(status: string) { return ['REJECTED', 'FAILED'].includes(status) ? 'is-error' : ['PENDING', 'PROCESSING'].includes(status) ? 'is-pending' : 'is-success'; }
function formatDate(value?: string) { const time = Date.parse(value || ''); return Number.isFinite(time) ? new Intl.DateTimeFormat('zh-CN', { year: 'numeric', month: '2-digit', day: '2-digit' }).format(time) : '暂无时间'; }
async function load() {
  loading.value = true; error.value = '';
  try {
    const [requests, catalog] = await Promise.all([portal.read('myApplicationRequests'), portal.read('apps')]);
    if (!requests.ok) throw new Error(requests.error.message);
    if (!catalog.ok) throw new Error(catalog.error.message);
    rows.value = requests.data || []; apps.value = catalog.data || [];
  } catch (cause) { error.value = cause instanceof Error ? cause.message : '申请加载失败'; }
  finally { loading.value = false; }
}
async function withdraw(item: Request) {
  if (!window.confirm('确认撤回此应用访问申请？')) return;
  const result = await command('withdrawApplicationRequest', { id: item.id, version: item.version });
  if (!result.ok) { window.alert(result.error.message); return; }
  await load();
}
async function enter(item: Request) {
  const app = apps.value.find(entry => entry.id === item.appId);
  if (!app) { window.alert('应用信息不存在，请刷新后重试'); return; }
  const result = await command('enterApp', { id: app.id });
  window.alert(result.ok ? result.data.message : result.error.message);
}
function bind(item: Request) {
  const app = apps.value.find(entry => entry.id === item.appId);
  if (!app) { window.alert('应用信息不存在，请刷新后重试'); return; }
  bindingApp.value = app; bindingVisible.value = true;
}
onMounted(load);
watch(revision, load);
</script>

<style scoped>
.mobile-requests{padding:0 16px 28px;color:#1d3552}.mobile-requests-head{display:flex;align-items:center;gap:13px;height:54px;margin:0 -16px;padding:0 16px;background:#fff}.mobile-requests-head button{display:grid;place-items:center;width:28px;height:28px;border:0;background:none;color:#355577}.mobile-requests-head svg{width:21px;height:21px}.mobile-requests-head h1{margin:0;font-size:17px}.mobile-requests-tabs{display:flex;gap:10px;margin:17px 0}.mobile-requests-tabs button{flex:1;padding:10px 6px;border:0;border-radius:11px;background:#e9eef5;color:#71849a;font-size:12px}.mobile-requests-tabs button.active{background:#dceeff;color:#126fba;font-weight:600}.mobile-requests-tabs span{margin-left:3px}.mobile-requests-list{display:grid;gap:11px}.mobile-request-card{padding:15px;border:1px solid #e9eff5;border-radius:14px;background:#fff}.mobile-request-main{display:flex;align-items:center;justify-content:space-between;width:100%;padding:0;border:0;background:none;text-align:left}.mobile-request-main span{display:flex;flex-direction:column;gap:6px}.mobile-request-main strong{font-size:14px}.mobile-request-main small{color:#91a2b2;font-size:11px}.mobile-request-main svg{width:16px;height:16px;color:#9cabb9}.mobile-request-summary{display:flex;justify-content:space-between;align-items:center;margin-top:14px;padding-top:12px;border-top:1px solid #edf1f6;font-size:11px;color:#8b9bad}.mobile-request-summary b{font-weight:600;color:#238a68}.mobile-request-summary b.is-error{color:#c05947}.mobile-request-summary b.is-pending{color:#b58228}.mobile-request-note{margin-top:10px;color:#687f95;font-size:12px}.mobile-request-actions{margin-top:12px;text-align:right}.mobile-requests-empty{padding:30px 0;text-align:center;color:#94a4b4;font-size:13px}.mobile-requests-error{padding:12px;border-radius:10px;background:#fff0ed;color:#ad4b3d;font-size:12px}.mobile-requests-error button{border:0;background:none;color:#ad4b3d}.mobile-requests-overlay{position:fixed;z-index:3000;inset:0;display:flex;align-items:flex-end;background:rgba(11,30,53,.45)}.mobile-requests-sheet{box-sizing:border-box;width:100%;max-height:82vh;overflow:auto;padding:20px 20px max(24px,env(safe-area-inset-bottom));border-radius:22px 22px 0 0;background:#fff}.mobile-requests-sheet-head{display:flex;align-items:center;justify-content:space-between}.mobile-requests-sheet-head h2{margin:0;font-size:18px}.mobile-requests-sheet-head button{border:0;background:none}.mobile-requests-sheet-head svg{width:20px;height:20px}.mobile-requests-sheet dl div{display:flex;justify-content:space-between;gap:16px;padding:12px 0;border-top:1px solid #edf1f6;font-size:13px}.mobile-requests-sheet dt{flex:none;color:#8798aa}.mobile-requests-sheet dd{margin:0;text-align:right;overflow-wrap:anywhere}
</style>

<style>
@media (max-width: 600px) {
  body:has(.mobile-requests) .t-dialog { width: calc(100vw - 24px) !important; max-width: calc(100vw - 24px) !important; }
  body:has(.mobile-requests) .binding-wizard { max-width: 100%; }
  body:has(.mobile-requests) .binding-actions { flex-wrap: wrap; }
}
</style>
