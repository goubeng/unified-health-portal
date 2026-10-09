<template>
  <div class="mobile-apps">
    <header class="mobile-apps-head"><p>服务大厅</p><h1>全部应用</h1><span>按需查找，便捷办理</span></header>
    <div class="mobile-apps-search"><SearchIcon /><input v-model.trim="keyword" type="search" aria-label="搜索应用" placeholder="搜索应用名称或编码" /></div>
    <div class="mobile-apps-categories" aria-label="应用分类">
      <button v-for="item in categories" :key="item" type="button" :class="{ active: category === item }" :aria-pressed="category === item" @click="category = item">{{ item }}</button>
    </div>
    <div class="mobile-apps-shortcut"><span>申请使用的应用可在“我的申请”查看进度</span><button type="button" @click="router.push('/m/applications')">我的申请 <ChevronRightIcon /></button></div>
    <p v-if="error" class="mobile-apps-error" role="alert">{{ error }} <button type="button" @click="load">重新加载</button></p>
    <p v-if="loading" class="mobile-apps-empty">正在加载应用…</p>
    <template v-else>
      <section v-for="group in groups" :key="group.key" class="mobile-apps-section">
        <div class="mobile-apps-section-head"><h2>{{ group.title }}</h2><span>{{ group.rows.length }} 项</span></div>
        <div v-if="group.rows.length" class="mobile-apps-list">
          <article v-for="(app, index) in group.rows" :key="app.id" class="mobile-app-card">
            <button class="mobile-app-main" type="button" @click="detail = app">
              <span class="mobile-app-logo" :class="`tone-${index % APP_TONE_COUNT}`"><AppIcon /></span>
              <span class="mobile-app-meta"><strong>{{ app.name }}</strong><small>{{ app.category || '业务应用' }} · {{ app.code || '暂无编码' }}</small></span>
              <ChevronRightIcon class="mobile-app-chevron" />
            </button>
            <div class="mobile-app-foot"><span :class="stateClass(app)">{{ stateText(app) }}</span><MobileButton v-if="actionText(app)" size="small" variant="outline" :disabled="actionDisabled(app)" @click="takeAction(app)">{{ actionText(app) }}</MobileButton></div>
          </article>
        </div>
        <p v-else class="mobile-apps-empty">{{ keyword || category !== ALL_CATEGORY ? '当前筛选下暂无应用' : '暂无应用' }}</p>
      </section>
    </template>

    <div v-if="detail" class="mobile-apps-overlay" @click.self="closeDialog">
      <section ref="detailSheet" class="mobile-apps-sheet" role="dialog" aria-modal="true" aria-label="应用详情" tabindex="-1">
        <div class="mobile-apps-sheet-head"><h2>{{ detail.name }}</h2><button type="button" aria-label="关闭" @click="closeDialog"><CloseIcon /></button></div>
        <p>{{ detail.description || '暂无应用简介' }}</p>
        <dl><div><dt>应用分类</dt><dd>{{ detail.category || '业务应用' }}</dd></div><div><dt>适用用户</dt><dd>{{ userTypeText(detail.userType) }}</dd></div><div><dt>访问状态</dt><dd>{{ stateText(detail) }}</dd></div></dl>
        <MobileButton v-if="actionText(detail)" block :disabled="actionDisabled(detail)" @click="takeAction(detail)">{{ actionText(detail) }}</MobileButton>
      </section>
    </div>

    <div v-if="requestApp" class="mobile-apps-overlay" @click.self="closeDialog">
      <section ref="requestSheet" class="mobile-apps-sheet" role="dialog" aria-modal="true" aria-label="申请使用应用" tabindex="-1">
        <div class="mobile-apps-sheet-head"><h2>申请使用 · {{ requestApp.name }}</h2><button type="button" aria-label="关闭" @click="closeDialog"><CloseIcon /></button></div>
        <label>申请原因 <span>*</span><textarea v-model.trim="requestReason" rows="4" placeholder="请填写申请使用原因"></textarea></label>
        <label>联系方式<input v-model.trim="requestContact" type="text" placeholder="选填" /></label>
        <label>备注<textarea v-model.trim="requestRemark" rows="2" placeholder="选填"></textarea></label>
        <p v-if="requestError" class="mobile-apps-error" role="alert">{{ requestError }}</p>
        <MobileButton block :loading="saving" @click="submitRequest">提交申请</MobileButton>
      </section>
    </div>
    <AccountBindingWizard v-model:visible="bindingVisible" :app="bindingApp || undefined" @completed="load" />
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { Button as MobileButton } from 'tdesign-mobile-vue';
import { AppIcon, ChevronRightIcon, CloseIcon, SearchIcon } from 'tdesign-icons-vue-next';
import { command, portal, revision } from '../services/runtime.js';
import AccountBindingWizard from '../components/portal/AccountBindingWizard.vue';
import { useMobileDialog } from './useMobileDialog';

type App = { id: string; name: string; code?: string; category?: string; description?: string; userType?: string; accessState?: string; primaryAction?: string; enabled?: boolean; ssoRuntimeStatus?: string; sortOrder?: number; externalAccountStatus?: string };
const ALL_CATEGORY = '全部';
const APP_TONE_COUNT = 4;
const route = useRoute();
const router = useRouter();
const loading = ref(true);
const error = ref('');
const apps = ref<App[]>([]);
const mineIds = ref<string[]>([]);
const keyword = ref('');
const category = ref(ALL_CATEGORY);
const detail = ref<App | null>(null);
const requestApp = ref<App | null>(null);
const detailSheet = ref<HTMLElement | null>(null);
const requestSheet = ref<HTMLElement | null>(null);
const { closeDialog } = useMobileDialog({
  open: computed(() => Boolean(detail.value || requestApp.value)),
  element: computed(() => requestSheet.value || detailSheet.value),
  close: () => { detail.value = null; requestApp.value = null; },
});
const requestReason = ref('');
const requestContact = ref('');
const requestRemark = ref('');
const requestError = ref('');
const saving = ref(false);
const bindingVisible = ref(false);
const bindingApp = ref<App | null>(null);
const categories = computed(() => [ALL_CATEGORY, ...new Set(apps.value.map(app => app.category).filter((value): value is string => Boolean(value)))]);
const filtered = computed(() => apps.value.filter(app => {
  const term = keyword.value.toLocaleLowerCase();
  return (category.value === ALL_CATEGORY || app.category === category.value) && (!term || `${app.name} ${app.code || ''}`.toLocaleLowerCase().includes(term));
}));
const groups = computed(() => [
  { key: 'mine', title: '我的应用', rows: filtered.value.filter(app => mineIds.value.includes(app.id)) },
  { key: 'other', title: '其他应用', rows: filtered.value.filter(app => !mineIds.value.includes(app.id)) },
]);
async function read(resource: string) { const response = await portal.read(resource); if (!response.ok) throw new Error(response.error.message); return response.data; }
async function load() {
  loading.value = true; error.value = '';
  try {
    const [all, mine] = await Promise.all([read('apps'), read('mine')]);
    apps.value = [...(all || [])].sort((a, b) => (a.sortOrder || 0) - (b.sortOrder || 0));
    mineIds.value = (mine || []).map((app: App) => app.id);
    const requestedApp = apps.value.find(app => app.id === route.query.requestAppId && (app.primaryAction === 'REQUEST' || app.accessState === 'REQUEST_REJECTED'));
    if (requestedApp) { requestApp.value = requestedApp; router.replace('/m/apps'); }
  } catch (cause) { error.value = cause instanceof Error ? cause.message : '应用加载失败'; }
  finally { loading.value = false; }
}
function stateText(app: App) {
  if (app.accessState === 'DIRECT') return '可直接访问';
  if (app.accessState === 'BOUND') return '已关联';
  if (app.accessState === 'UNBOUND') return '需确认账号';
  if (app.accessState === 'VERIFYING') return '待继续处理';
  if (app.accessState === 'REVIEWING') return '处理中';
  if (app.accessState === 'FAILED') return app.externalAccountStatus === 'DISABLED' ? '账号不可用' : '处理失败';
  if (app.accessState === 'CONFLICT') return '账号异常';
  if (app.accessState === 'REQUEST_REQUIRED') return '待申请';
  if (app.accessState === 'REQUEST_PENDING') return '申请处理中';
  if (app.accessState === 'REQUEST_REJECTED') return '申请未通过';
  return '暂不可用';
}
function stateClass(app: App) { return ['FAILED', 'CONFLICT', 'REQUEST_REJECTED'].includes(app.accessState || '') ? 'is-error' : ['REQUEST_PENDING', 'REVIEWING', 'VERIFYING'].includes(app.accessState || '') ? 'is-pending' : ''; }
function actionText(app: App) { return ({ ENTER: '进入应用', BIND: '申请使用', CONTINUE_BIND: '继续处理', RETRY_BIND: '重新处理', VIEW_BINDING: '查看进度', VIEW_REASON: '查看原因', VIEW_CONFLICT: '查看原因', REQUEST: '申请使用', VIEW_REQUEST: '查看申请' } as Record<string, string>)[app.primaryAction || ''] || ''; }
function actionDisabled(app: App) { return app.enabled === false || app.primaryAction === 'ENTER' && app.ssoRuntimeStatus !== 'NORMAL'; }
function userTypeText(value?: string) { return ({ BOTH: '公众及政务', CITIZEN: '公众用户', GOV: '政务用户' } as Record<string, string>)[value || ''] || '全部用户'; }
async function takeAction(app: App) {
  const action = app.primaryAction;
  detail.value = null;
  if (action === 'ENTER') {
    const result = await command('enterApp', { id: app.id });
    window.alert(result.ok ? result.data.message : result.error.message);
    return;
  }
  if (action === 'REQUEST') { requestApp.value = app; requestReason.value = ''; requestContact.value = ''; requestRemark.value = ''; requestError.value = ''; return; }
  if (['BIND', 'CONTINUE_BIND', 'RETRY_BIND', 'VIEW_BINDING', 'VIEW_REASON', 'VIEW_CONFLICT'].includes(action || '')) { bindingApp.value = app; bindingVisible.value = true; return; }
  if (action === 'VIEW_REQUEST') router.push('/m/applications');
}
async function submitRequest() {
  if (!requestApp.value || saving.value) return;
  if (!requestReason.value) { requestError.value = '请填写申请原因'; return; }
  saving.value = true; requestError.value = '';
  try {
    const result = await command('submitApplicationRequest', { appId: requestApp.value.id, reason: requestReason.value, contact: requestContact.value, remark: requestRemark.value });
    if (!result.ok) { requestError.value = result.error.message; return; }
    requestApp.value = null; await load(); window.alert('申请已提交，可在“我的申请”查看进度');
  } catch (cause) { requestError.value = cause instanceof Error ? cause.message : '提交失败'; }
  finally { saving.value = false; }
}
onMounted(load);
watch(revision, load);
</script>

<style scoped>
.mobile-apps{padding:0 16px 28px;color:#172b48}.mobile-apps-head{margin:0 -16px;padding:22px 20px 27px;background:linear-gradient(125deg,#0b56a9,#1884ca);color:#fff}.mobile-apps-head p{margin:0 0 6px;font-size:12px;letter-spacing:2px;opacity:.8}.mobile-apps-head h1{margin:0;font-size:25px}.mobile-apps-head span{display:block;margin-top:5px;font-size:12px;opacity:.85}.mobile-apps-search{display:flex;align-items:center;gap:10px;height:46px;margin-top:-18px;padding:0 14px;border-radius:14px;background:#fff;box-shadow:0 8px 22px rgba(34,75,116,.1)}.mobile-apps-search svg{width:19px;height:19px;color:#8293a9}.mobile-apps-search input{flex:1;min-width:0;border:0;outline:0;background:transparent;color:#1b3552;font-size:14px}.mobile-apps-categories{display:flex;gap:8px;overflow:auto;margin:16px -16px 12px;padding:0 16px;scrollbar-width:none}.mobile-apps-categories button{flex:none;padding:7px 13px;border:0;border-radius:16px;background:#e9eef5;color:#6b7e94;font-size:12px}.mobile-apps-categories button.active{background:#dceeff;color:#126fba;font-weight:600}.mobile-apps-shortcut{display:flex;align-items:center;justify-content:space-between;gap:8px;margin-bottom:17px;padding:12px;border-radius:12px;background:#eaf4fc;color:#667d97;font-size:11px}.mobile-apps-shortcut button{display:flex;align-items:center;flex:none;border:0;background:none;color:#1476c6;font-size:12px}.mobile-apps-shortcut svg{width:14px;height:14px}.mobile-apps-section{margin-bottom:18px}.mobile-apps-section-head{display:flex;align-items:baseline;justify-content:space-between;margin-bottom:10px}.mobile-apps-section-head h2{margin:0;font-size:17px}.mobile-apps-section-head span{font-size:11px;color:#95a4b5}.mobile-apps-list{display:grid;gap:10px}.mobile-app-card{padding:14px;border:1px solid #edf1f5;border-radius:15px;background:#fff;box-shadow:0 4px 14px rgba(25,55,91,.035)}.mobile-app-main{display:flex;align-items:center;gap:11px;width:100%;padding:0;border:0;background:none;text-align:left}.mobile-app-logo{display:grid;place-items:center;width:45px;height:45px;flex:none;border-radius:12px;background:#e7f2ff;color:#1275c6}.mobile-app-logo svg{width:24px;height:24px}.mobile-app-logo.tone-1{background:#e7f6ef;color:#209768}.mobile-app-logo.tone-2{background:#fff2e4;color:#d98927}.mobile-app-logo.tone-3{background:#efeaff;color:#785fc0}.mobile-app-meta{display:flex;flex:1;flex-direction:column;gap:5px;min-width:0}.mobile-app-meta strong{overflow:hidden;font-size:14px;text-overflow:ellipsis;white-space:nowrap}.mobile-app-meta small{overflow:hidden;color:#92a0b0;font-size:11px;text-overflow:ellipsis;white-space:nowrap}.mobile-app-chevron{width:16px;height:16px;color:#9ba9b7}.mobile-app-foot{display:flex;align-items:center;justify-content:space-between;min-height:34px;margin-top:10px;padding-top:10px;border-top:1px solid #f0f3f6;font-size:12px;color:#178567}.mobile-app-foot .is-error{color:#bd5744}.mobile-app-foot .is-pending{color:#b78126}.mobile-apps-empty{margin:0;padding:20px 0;color:#91a0b1;font-size:12px;text-align:center}.mobile-apps-error{padding:12px;border-radius:10px;background:#fff2f0;color:#aa4c3d;font-size:12px}.mobile-apps-error button{border:0;background:none;color:#ba4b3b}.mobile-apps-overlay{position:fixed;z-index:3000;inset:0;display:flex;align-items:flex-end;background:rgba(11,30,53,.45)}.mobile-apps-sheet{box-sizing:border-box;width:100%;max-height:84vh;overflow:auto;padding:20px 20px max(24px,env(safe-area-inset-bottom));border-radius:22px 22px 0 0;background:#fff}.mobile-apps-sheet-head{display:flex;align-items:center;justify-content:space-between;margin-bottom:15px}.mobile-apps-sheet-head h2{margin:0;font-size:18px}.mobile-apps-sheet-head button{border:0;background:none;color:#677f98}.mobile-apps-sheet-head svg{width:20px;height:20px}.mobile-apps-sheet>p{color:#647b93;font-size:13px;line-height:1.7}.mobile-apps-sheet dl{margin:18px 0}.mobile-apps-sheet dl div{display:flex;justify-content:space-between;padding:12px 0;border-top:1px solid #edf1f6;font-size:13px}.mobile-apps-sheet dt{color:#8b9bab}.mobile-apps-sheet dd{margin:0}.mobile-apps-sheet label{display:block;margin:12px 0;color:#465b73;font-size:13px}.mobile-apps-sheet label span{color:#d65b48}.mobile-apps-sheet textarea,.mobile-apps-sheet input{box-sizing:border-box;display:block;width:100%;margin-top:7px;padding:10px;border:1px solid #dce5ee;border-radius:9px;outline:0;font:inherit}
</style>

<style>
@media (max-width: 600px) {
  body:has(.mobile-apps) .t-dialog { width: calc(100vw - 24px) !important; max-width: calc(100vw - 24px) !important; }
  body:has(.mobile-apps) .binding-wizard { max-width: 100%; }
  body:has(.mobile-apps) .binding-actions { flex-wrap: wrap; }
}
</style>
