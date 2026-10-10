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
    <div v-if="loading" class="mobile-list-empty">正在加载待办…</div>
    <div v-else-if="!filtered.length" class="mobile-list-empty">暂无符合条件的待办</div>

    <!-- 待办列表：扁平无多层嵌套 -->
    <div v-else class="mobile-todo-list">
      <article v-for="item in filtered" :key="item.id" class="mobile-todo-card">
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
          <TMobileButton size="small" theme="primary" class="todo-process-btn" @click="process(item)">
            去处理
          </TMobileButton>
        </div>
      </article>
    </div>
  </section>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue';
import { Button as TMobileButton, Input as TMobileInput } from 'tdesign-mobile-vue';
import { CalendarIcon } from 'tdesign-icons-vue-next';
import { command, portal, revision, loadDictionaryLookups } from '../services/runtime.js';
import { date, label, text } from '../components/portal/presentation.js';

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

const rows = ref<Todo[]>([]);
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
</script>

<style scoped src="./mobile-todos.css"></style>
