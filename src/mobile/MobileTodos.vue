<template>
  <section class="mobile-todos">
    <!-- 头部品牌蓝渐变区域（无多余赘述，大方利落） -->
    <header class="mobile-todos-header">
      <div class="mobile-todos-title-bar">
        <h1>待办事项</h1>
        <p class="mobile-todos-subtitle">您当前有 <strong class="todo-highlight-num">{{ pendingCount }}</strong> 条事项待处理</p>
      </div>
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
          <TMobileTag
            :theme="item.status === 'PENDING' ? 'warning' : item.status === 'COMPLETED' ? 'success' : 'default'"
            variant="light"
            size="small"
          >
            {{ label(item.status, 'todo_status') }}
          </TMobileTag>
        </div>

        <p v-if="text(item.summary)" class="mobile-card-summary">{{ text(item.summary) }}</p>

        <!-- 指标在分隔线上方：来源系统与发布时间 -->
        <div class="mobile-card-meta-list">
          <span class="meta-item meta-app">
            <AppIcon class="meta-icon" />
            <span>{{ text(item.appName) || '统一门户' }}</span>
          </span>
          <span class="meta-item meta-time">
            <TimeIcon class="meta-icon" />
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
import { Button as TMobileButton, Input as TMobileInput, Tag as TMobileTag } from 'tdesign-mobile-vue';
import { AppIcon, TimeIcon } from 'tdesign-icons-vue-next';
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

onMounted(() => {
  loadDictionaryLookups();
  load();
});

watch(revision, load);
</script>

<style scoped>
.mobile-todos {
  padding: 0 0 32px;
  color: #173047;
}

/* 头部品牌蓝渐变区域 */
.mobile-todos-header {
  padding: 20px 16px 18px;
  background: linear-gradient(135deg, #0052d9 0%, #1e6beb 58%, #4489f7 100%);
  color: #ffffff;
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.mobile-todos-title-bar {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.mobile-todos-title-bar h1 {
  margin: 0;
  font-size: 22px;
  font-weight: 700;
  letter-spacing: 0.5px;
  color: #ffffff;
  line-height: 1.25;
}

.mobile-todos-subtitle {
  margin: 0;
  font-size: 13px;
  color: rgba(255, 255, 255, 0.88);
  line-height: 1.4;
}

.todo-highlight-num {
  font-weight: 800;
  font-size: 18px;
  color: #ffe600;
  margin: 0 4px;
  text-shadow: 0 1px 2px rgba(0, 0, 0, 0.2);
  display: inline-block;
  vertical-align: baseline;
}

.mobile-todo-search {
  width: 100%;
}

/* 筛选 Tab 按钮 */
.mobile-todo-filters {
  display: flex;
  gap: 8px;
  padding: 14px 16px 8px;
  overflow: auto;
}

.mobile-todo-filters button {
  flex: none;
  border: 0;
  border-radius: 18px;
  background: #edf3f7;
  color: #5a7287;
  padding: 7px 16px;
  font-size: 13px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.18s ease;
}

.mobile-todo-filters button.active {
  background: #ecf2fe;
  color: #0052d9;
  font-weight: 700;
}

.mobile-inline-error {
  margin: 10px 16px;
  padding: 10px 12px;
  border-radius: 8px;
  background: #fff1ef;
  color: #ba3e38;
  font-size: 13px;
}

.mobile-list-empty {
  padding: 58px 0;
  text-align: center;
  color: #91a2af;
  font-size: 14px;
}

/* 待办列表 */
.mobile-todo-list {
  display: grid;
  gap: 12px;
  padding: 6px 16px;
}

.mobile-todo-card {
  background: #ffffff;
  border: 1px solid #edf2f6;
  border-radius: 16px;
  padding: 15px 15px 12px;
  box-shadow: 0 4px 14px rgba(18, 52, 95, 0.04);
}

.mobile-card-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 10px;
}

.mobile-card-top strong {
  font-size: 15px;
  line-height: 1.45;
  color: #172d42;
  flex: 1;
  min-width: 0;
  font-weight: 600;
}

.mobile-card-summary {
  margin: 6px 0 0;
  color: #6b8090;
  font-size: 13px;
  line-height: 1.5;
  display: -webkit-box;
  -webkit-line-clamp: 2;
  line-clamp: 2;
  -webkit-box-orient: vertical;
  overflow: hidden;
}

/* 3 个指标在分隔线上方：统一中性灰配色，不单独使用蓝色 */
.mobile-card-meta-list {
  display: flex;
  align-items: center;
  flex-wrap: nowrap;
  gap: 10px;
  min-width: 0;
  width: 100%;
  margin-top: 10px;
  font-size: 12px;
  overflow: hidden;
}

.meta-item {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  color: #718598;
  white-space: nowrap;
  flex-shrink: 0;
}

.meta-item.meta-app {
  flex-shrink: 1;
  min-width: 0;
  overflow: hidden;
  text-overflow: ellipsis;
}

.meta-item.meta-app span {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.meta-item.meta-time {
  margin-left: 0;
}

.meta-item svg,
.meta-icon {
  width: 13px;
  height: 13px;
  flex: none;
  color: #8c9fae;
}

/* 按钮“去处理”显示在分隔线下面，右对齐 */
.mobile-card-actions-row {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  margin-top: 10px;
  padding-top: 10px;
  border-top: 1px solid #f0f3f6;
}

.todo-process-btn {
  height: 28px !important;
  padding: 0 14px !important;
  font-size: 12.5px !important;
  font-weight: 600 !important;
  border-radius: 999px !important;
}
</style>
