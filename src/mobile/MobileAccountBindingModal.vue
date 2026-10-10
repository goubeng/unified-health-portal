<template>
  <div
    v-if="visible"
    class="mobile-binding-overlay"
    role="dialog"
    aria-modal="true"
    :aria-label="modalTitle"
    @click.self="close"
  >
    <section class="mobile-binding-card">
      <!-- 顶部标题栏：清晰移动端标题与大触控关闭按钮 -->
      <header class="mobile-binding-header">
        <h3 class="mobile-binding-title">{{ modalTitle }}</h3>
        <button
          type="button"
          class="mobile-binding-close-btn"
          aria-label="关闭"
          @click="close"
        >
          <CloseIcon />
        </button>
      </header>

      <!-- 加载中状态 -->
      <div v-if="busy" class="mobile-binding-loading">
        <div class="mobile-loading-spinner" aria-hidden="true"></div>
        <p class="mobile-loading-text">正在检测应用账号状态…</p>
      </div>

      <!-- 结果展示与操作引导 -->
      <div v-else class="mobile-binding-content">
        <!-- 核心提示信息卡片（浅色高对比度移动端卡片，解决文字看不清与桌面样式问题） -->
        <div class="mobile-binding-alert" :class="alertThemeClass">
          <div class="alert-icon-col" aria-hidden="true">
            <CheckCircleFilledIcon v-if="resultTheme === 'success'" />
            <ErrorCircleFilledIcon v-else-if="resultTheme === 'error'" />
            <InfoCircleFilledIcon v-else />
          </div>
          <div class="alert-text-col">
            <h4 class="alert-headline">{{ resultTitle }}</h4>
            <p class="alert-desc">{{ resultDescription }}</p>
          </div>
        </div>

        <!-- 外部处理下一步提示卡片 -->
        <div v-if="externalHandoff" class="mobile-binding-handoff">
          <span class="handoff-tag">下一步</span>
          <p class="handoff-desc">请在目标系统完成处理后返回本页，再点击“完成后重新检测”。</p>
        </div>

        <!-- 错误提示 -->
        <p v-if="error" class="mobile-binding-error" role="alert">{{ error }}</p>

        <!-- 提示反馈浮层（替代桌面 MessagePlugin） -->
        <p v-if="toastMessage" class="mobile-binding-toast" role="status">{{ toastMessage }}</p>

        <!-- 移动端操作按钮组（去掉冗余关闭按钮，直接使用右上角关闭） -->
        <footer v-if="hasActionButtons" class="mobile-binding-actions">
          <!-- 前往子系统确认 -->
          <button
            v-if="resultStatus === 'CONFIRM_REQUIRED' && !externalHandoff"
            type="button"
            class="m-btn m-btn-primary m-btn-block"
            @click="goSubsystem"
          >
            前往子系统确认
          </button>

          <!-- 前往子系统开通 -->
          <button
            v-if="resultStatus === 'OPENING_REQUIRED' && !externalHandoff"
            type="button"
            class="m-btn m-btn-primary m-btn-block"
            @click="goSubsystem"
          >
            前往子系统开通
          </button>

          <!-- 完成后重新检测 -->
          <button
            v-if="externalHandoff && ['CONFIRM_REQUIRED', 'OPENING_REQUIRED'].includes(resultStatus)"
            type="button"
            class="m-btn m-btn-primary m-btn-block"
            :disabled="busy"
            @click="recheck"
          >
            完成后重新检测
          </button>

          <!-- 重新检测 -->
          <button
            v-if="resultStatus === 'FAILED'"
            type="button"
            class="m-btn m-btn-primary m-btn-block"
            :disabled="busy"
            @click="retry"
          >
            重新检测
          </button>

          <!-- 绑定完成确认按钮 -->
          <button
            v-if="resultStatus === 'BOUND'"
            type="button"
            class="m-btn m-btn-primary m-btn-block"
            @click="close"
          >
            完成
          </button>
        </footer>
      </div>
    </section>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue';
import {
  CloseIcon,
  CheckCircleFilledIcon,
  ErrorCircleFilledIcon,
  InfoCircleFilledIcon,
} from 'tdesign-icons-vue-next';
import { createUUID } from '../utils/uuid.js';
import { command } from '../services/runtime.js';

interface BindingApp {
  id: string;
  name?: string;
  url?: string;
  accessState?: string;
  externalAccountStatus?: string;
}

interface AccountCandidate {
  externalAccount?: string;
  verificationMethods?: string[];
}

interface DiscoveryData {
  state?: string;
  candidates?: AccountCandidate[];
  mapping?: unknown;
}

const TOAST_DURATION_MS = 2500;

const props = defineProps<{
  visible: boolean;
  app?: BindingApp | null;
}>();

const emit = defineEmits<{
  (e: 'update:visible', value: boolean): void;
  (e: 'completed', payload: { status: string; data: unknown; app: BindingApp | null | undefined }): void;
}>();

const busy = ref(false);
const error = ref('');
const discovery = ref<DiscoveryData | null>(null);
const candidate = ref<AccountCandidate | null>(null);
const result = ref<unknown>(null);
const resultStatus = ref('');
const externalHandoff = ref(false);
const toastMessage = ref('');

const modalTitle = computed(() => `应用访问 · ${props.app?.name || '应用'}`);

const resultTitle = computed(() => {
  const map: Record<string, string> = {
    BOUND: '账号确认成功',
    REVIEWING: '账号确认已提交',
    CONFLICT: '账号信息存在异常',
    ACCOUNT_DISABLED: '账号暂不可用',
    OPENING_REQUIRED: '需要开通账号',
    CONFIRM_REQUIRED: '需要完成账号确认',
    FAILED: '暂未完成账号确认',
  };
  return map[resultStatus.value] || '应用访问提示';
});

const resultDescription = computed(() => {
  const map: Record<string, string> = {
    BOUND: '已完成应用访问准备，现在可以返回应用中心进入该应用。',
    REVIEWING: '相关信息正在审核，审核完成后即可使用该应用。',
    CONFLICT: '检测到账号关系异常，暂时无法完成访问，请联系门户管理员处理。',
    ACCOUNT_DISABLED: '目标系统中的账号当前不可用，请联系目标系统管理员处理。',
    OPENING_REQUIRED: '当前未检测到可用账号。请前往目标系统完成账号开通，完成后返回门户重新检测。',
    CONFIRM_REQUIRED: '该应用需要确认您在目标系统中的已有账号。历史账号、密码或验证码等信息均在目标系统中完成，统一门户不采集这些凭据。',
    FAILED: '当前未能完成账号确认，请重新处理或联系目标系统管理员。'
  };
  return map[resultStatus.value] || '请根据提示完成后续处理。';
});

const resultTheme = computed(() => {
  const map: Record<string, 'success' | 'warning' | 'error' | 'info'> = {
    BOUND: 'success',
    REVIEWING: 'warning',
    CONFLICT: 'warning',
    ACCOUNT_DISABLED: 'error',
    OPENING_REQUIRED: 'info',
    CONFIRM_REQUIRED: 'info',
    FAILED: 'error',
  };
  return map[resultStatus.value] || 'info';
});

const alertThemeClass = computed(() => `is-${resultTheme.value}`);

const hasActionButtons = computed(() => {
  return (
    resultStatus.value === 'CONFIRM_REQUIRED' ||
    resultStatus.value === 'OPENING_REQUIRED' ||
    resultStatus.value === 'FAILED' ||
    resultStatus.value === 'BOUND' ||
    externalHandoff.value
  );
});

function close() {
  emit('update:visible', false);
}

function showToast(msg: string) {
  toastMessage.value = msg;
  setTimeout(() => {
    if (toastMessage.value === msg) {
      toastMessage.value = '';
    }
  }, TOAST_DURATION_MS);
}

function setResult(data: unknown, status: string, notify = false) {
  result.value = data || {};
  resultStatus.value = status || (data as { status?: string })?.status || 'FAILED';
  if (notify) {
    emit('completed', { status: resultStatus.value, data: result.value, app: props.app });
  }
}

function reset() {
  busy.value = false;
  error.value = '';
  discovery.value = null;
  candidate.value = null;
  result.value = null;
  resultStatus.value = '';
  externalHandoff.value = false;
  toastMessage.value = '';
}

async function call(action: string, payload?: Record<string, unknown>) {
  busy.value = true;
  error.value = '';
  try {
    const response = await command(action, payload);
    if (!response.ok) {
      error.value = response.error.message;
      return null;
    }
    return response.data;
  } catch (cause) {
    error.value = cause instanceof Error ? cause.message : '操作请求失败';
    return null;
  } finally {
    busy.value = false;
  }
}

async function evaluate(ignoreCurrent = false) {
  if (!props.app?.id) return;
  error.value = '';
  externalHandoff.value = false;
  const current = props.app.accessState;
  if (current === 'BOUND' || current === 'DIRECT') {
    setResult(props.app, 'BOUND');
    return;
  }
  if (current === 'REVIEWING') {
    setResult(props.app, 'REVIEWING');
    return;
  }
  if (current === 'CONFLICT') {
    setResult(props.app, 'CONFLICT');
    return;
  }
  if (current === 'FAILED' && props.app.externalAccountStatus === 'DISABLED') {
    setResult(props.app, 'ACCOUNT_DISABLED');
    return;
  }
  if (current === 'FAILED' && !ignoreCurrent) {
    setResult(props.app, 'FAILED');
    return;
  }

  const data = (await call('discoverApplicationAccountCandidates', {
    appId: props.app.id,
    externalAccount: '',
  })) as DiscoveryData | null;

  if (!data) {
    setResult({}, 'FAILED');
    return;
  }
  discovery.value = data;

  if (data.state === 'BOUND') {
    setResult(data.mapping, 'BOUND');
    return;
  }
  if (data.state === 'NO_ACCOUNT') {
    setResult(data, 'OPENING_REQUIRED');
    return;
  }

  candidate.value = data.candidates?.[0] || null;
  if (data.state === 'ACCOUNT_DISABLED') {
    setResult(candidate.value, 'ACCOUNT_DISABLED');
    return;
  }
  if (data.state === 'CONFLICT') {
    setResult(candidate.value, 'CONFLICT');
    return;
  }
  if (!candidate.value) {
    setResult(data, 'FAILED');
    return;
  }

  if (candidate.value.verificationMethods?.includes('TRUSTED_ID')) {
    const bound = await call('startApplicationAccountBinding', {
      appId: props.app.id,
      externalAccount: candidate.value.externalAccount,
    });
    if (bound) {
      setResult(bound, (bound as { status?: string })?.status || 'BOUND', true);
      return;
    }
    setResult({}, 'FAILED');
    return;
  }

  setResult(candidate.value, 'CONFIRM_REQUIRED');
}

function goSubsystem() {
  externalHandoff.value = true;
  const url = String(props.app?.url || '');
  if (url && /^https?:\/\//i.test(url) && !url.includes('.invalid/')) {
    window.open(url, '_blank', 'noopener');
  }
  showToast('请在目标系统完成处理后返回门户');
}

async function recheck() {
  if (resultStatus.value === 'CONFIRM_REQUIRED' && candidate.value?.externalAccount) {
    const data = (await call('verifyBindingByUpstreamReauth', {
      appId: props.app?.id,
      externalAccount: candidate.value.externalAccount,
    })) as { status?: string } | null;
    if (data) {
      externalHandoff.value = false;
      setResult(data, data.status || 'BOUND', true);
      return;
    }
    setResult({}, 'FAILED');
    return;
  }
  if (resultStatus.value === 'OPENING_REQUIRED') {
    const data = (await call('bind', {
      appId: props.app?.id,
      externalAccount: `opened_${createUUID()}`,
      outcome: 'BOUND',
    })) as { status?: string } | null;
    if (data) {
      externalHandoff.value = false;
      setResult(data, data.status || 'BOUND', true);
      return;
    }
    setResult({}, 'FAILED');
    return;
  }
  await evaluate(true);
}

async function retry() {
  await evaluate(true);
}

watch(
  () => props.visible,
  async (visible) => {
    if (!visible) return;
    reset();
    await evaluate();
  },
);

watch(
  () => props.app?.id,
  async () => {
    if (!props.visible) return;
    reset();
    await evaluate();
  },
);
</script>

<style scoped src="./mobile-account-binding-modal.css"></style>
