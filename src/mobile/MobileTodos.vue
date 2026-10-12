<template>
  <section class="mobile-todos">
    <!-- 头部品牌蓝渐变区域：保持原版文字提示，间距严格统一 gap:12px 与 padding:20px 16px 18px -->
    <header class="mobile-todos-header">
      <div class="mobile-todos-title-row">
        <h1>待办事项</h1>
      </div>
      <p class="mobile-todos-subtitle">
        您当前有 <strong class="todo-highlight-num">{{ pendingCount }}</strong> 条事项待处理
      </p>
      <div class="mobile-todo-search">
        <TMobileInput v-model="keyword" placeholder="搜索待办标题" clearable />
      </div>
    </header>

    <!-- 状态筛选Tab栏 -->
    <nav class="mobile-todo-filters" aria-label="待办状态">
      <button
        v-for="item in filters"
        :key="item.value"
        type="button"
        :class="{ active: status === item.value }"
        :aria-pressed="status === item.value"
        @click="status = item.value"
      >
        {{ item.label }}
      </button>
    </nav>

    <!-- 错误与加载提示 -->
    <p v-if="error" class="mobile-inline-error" role="alert">{{ error }}</p>
    <div v-if="loading" class="mobile-list-empty"><MobileLoading message="正在加载待办…" /></div>
    <div v-else-if="!filtered.length" class="mobile-list-empty">暂无符合条件的待办</div>

    <!-- 待办列表：扁平无多层嵌套 -->
    <div v-else class="mobile-todo-list">
      <article
        v-for="item in filtered"
        :key="item.id"
        class="mobile-todo-card"
        role="button"
        tabindex="0"
        :aria-label="`查看待办详情：${text(item.title) || '待办事项'}`"
        @click="openDetail(item)"
        @keydown.enter.self.prevent="openDetail(item)"
        @keydown.space.self.prevent="openDetail(item)"
      >
        <div class="mobile-card-top">
          <strong>{{ text(item.title) || '-' }}</strong>
          <span class="todo-status-tag" :class="statusClass(item.status)">
            {{ label(item.status, 'todo_status') }}
          </span>
        </div>

        <p v-if="text(item.summary)" class="mobile-card-summary">{{ text(item.summary) }}</p>

        <!-- 来源系统与接收时间同一行，来源前使用首页待办一致的应用网格图标 -->
        <div class="mobile-card-meta-list">
          <span class="meta-item meta-app">
            <svg class="meta-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">
              <rect x="3" y="3" width="7" height="7" rx="1.5" />
              <rect x="14" y="3" width="7" height="7" rx="1.5" />
              <rect x="3" y="14" width="7" height="7" rx="1.5" />
              <rect x="14" y="14" width="7" height="7" rx="1.5" />
            </svg>
            <span>{{ text(item.appName) || '统一门户' }}</span>
          </span>
          <span class="meta-item meta-time">
            <CalendarIcon class="meta-icon" />
            <span>{{ date(item.receivedAt) }}</span>
          </span>
        </div>

        <!-- 分隔线下方：按钮“去处理” -->
        <div v-if="item.status === 'PENDING'" class="mobile-card-actions-row">
          <TMobileButton size="small" theme="primary" class="todo-process-btn" @click.stop="process(item)">
            去处理
          </TMobileButton>
        </div>
      </article>
    </div>

    <!-- 与PC待办详情字段一致的移动端居中弹窗。 -->
    <div v-if="active" class="mobile-todo-detail-overlay" @click.self="closeDetail">
      <section
        ref="detailDialog"
        class="mobile-todo-detail-dialog"
        role="dialog"
        aria-modal="true"
        aria-labelledby="mobile-todo-detail-title"
        tabindex="-1"
      >
        <header class="mobile-todo-detail-header">
          <h2 id="mobile-todo-detail-title">{{ text(active.title) || '-' }}</h2>
          <button type="button" class="mobile-todo-detail-close" aria-label="关闭待办详情" @click="closeDetail">
            <CloseIcon aria-hidden="true" />
          </button>
        </header>
        <div class="mobile-todo-detail-content">
          <dl class="mobile-todo-detail-meta">
            <div><dt>来源应用</dt><dd>{{ text(active.appName) || '-' }}</dd></div>
            <div><dt>业务类型</dt><dd>{{ label(active.businessType, 'todo_task_type') }}</dd></div>
            <div><dt>接收时间</dt><dd>{{ date(active.receivedAt) }}</dd></div>
            <div>
              <dt>状态</dt>
              <dd><span class="todo-status-tag" :class="statusClass(active.status)">{{ label(active.status, 'todo_status') }}</span></dd>
            </div>
          </dl>
          <div class="mobile-todo-detail-description">
            <h4>待办说明</h4>
            <p>{{ text(active.summary) || '-' }}</p>
          </div>
          <p v-if="error" class="mobile-inline-error" role="alert">{{ error }}</p>
        </div>
        <footer v-if="active.status === 'PENDING'" class="mobile-todo-detail-footer">
          <TMobileButton block theme="primary" class="mobile-todo-detail-process-btn" @click="process(active)">去处理</TMobileButton>
        </footer>
      </section>
    </div>
  </section>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { Button as TMobileButton, Input as TMobileInput } from 'tdesign-mobile-vue';
import { CalendarIcon, CloseIcon } from 'tdesign-icons-vue-next';
import { command, portal, revision, loadDictionaryLookups } from '../services/runtime.js';
import { date, label, text } from '../components/portal/presentation.js';
import MobileLoading from './MobileLoading.vue';
import { useMobileDialog } from './useMobileDialog';

interface Todo {
  id: string;
  title?: string;
  summary?: string;
  appName?: string;
  businessType?: string;
  receivedAt?: string;
  status: string;
}

const filters = [
  { value: 'PENDING', label: '待处理' },
  { value: '', label: '全部' },
  { value: 'COMPLETED', label: '已完成' },
];

const route = useRoute();
const router = useRouter();
const rows = ref<Todo[]>([]);
const selectedId = ref<string | null>(null);
const detailDialog = ref<HTMLElement | null>(null);
const active = computed<Todo | null>(() => rows.value.find(item => item.id === selectedId.value) || null);
useMobileDialog({
  open: computed(() => Boolean(active.value)),
  element: computed(() => detailDialog.value),
  close: () => closeDetail(),
});
const loading = ref(true);
const error = ref('');
const keyword = ref('');
const status = ref('PENDING');

const pendingCount = computed(() => rows.value.filter(row => row.status === 'PENDING').length);

const filtered = computed(() =>
  rows.value
    .filter(row => (!status.value || row.status === status.value) && (!keyword.value.trim() || text(row.title).toLowerCase().includes(keyword.value.trim().toLowerCase())))
    .sort((a, b) => (Date.parse(b.receivedAt || '') || 0) - (Date.parse(a.receivedAt || '') || 0))
);

function openDetail(item: Todo) {
  selectedId.value = item.id;
  error.value = '';
}

function closeDetail() {
  selectedId.value = null;
  if (route.query.todoId) {
    const query = { ...route.query };
    delete query.todoId;
    void router.replace({ path: '/m/todos', query });
  }
}

let requestVersion = 0;

async function load() {
  const version = ++requestVersion;
  loading.value = true;
  error.value = '';
  const result = await portal.read('todos');
  if (version !== requestVersion) return;
  rows.value = result.ok ? result.data : [];
  error.value = result.ok ? '' : text(result.error?.message);
  loading.value = false;
}

async function process(item: Todo) {
  error.value = '';
  const result = await command('openTodo', { id: item.id });
  if (!result.ok) {
    error.value = text(result.error?.message);
    return;
  }
  window.alert(text(result.data?.message) || '已打开待办');
}

function statusClass(st: string) {
  if (st === 'PENDING') return 'is-pending';
  if (st === 'COMPLETED') return 'is-success';
  return 'is-default';
}

onMounted(() => {
  loadDictionaryLookups();
  load();
});

watch(revision, load);
watch([() => route.query.todoId, () => rows.value.length], () => {
  const id = typeof route.query.todoId === 'string' ? route.query.todoId : '';
  if (id) {
    const row = rows.value.find(item => item.id === id);
    if (row) selectedId.value = row.id;
  }
}, { immediate: true });
</script>

<style scoped src="./mobile-todos.css"></style>
