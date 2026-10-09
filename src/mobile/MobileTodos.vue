<template>
  <section class="mobile-todos">
    <div class="mobile-page-intro">
      <h1>待办事项</h1>
      <p>当前有 {{ pendingCount }} 项待处理</p>
    </div>

    <div class="mobile-todo-search">
      <TMobileInput v-model="keyword" placeholder="搜索待办标题" clearable />
    </div>

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

    <p v-if="error" class="mobile-inline-error" role="alert">{{ error }}</p>
    <div v-if="loading" class="mobile-list-empty">正在加载待办…</div>
    <div v-else-if="!filtered.length" class="mobile-list-empty">暂无符合条件的待办</div>

    <div v-else class="mobile-todo-list">
      <article v-for="item in filtered" :key="item.id" class="mobile-todo-card">
        <div class="mobile-card-main">
          <div class="mobile-card-top">
            <strong>{{ text(item.title) || '-' }}</strong>
            <TMobileTag :theme="item.status === 'PENDING' ? 'warning' : item.status === 'COMPLETED' ? 'success' : 'default'" variant="light" size="small">{{ label(item.status, 'todo_status') }}</TMobileTag>
          </div>
          <p v-if="text(item.summary)" class="mobile-card-summary">{{ text(item.summary) }}</p>
          <div class="mobile-card-footer">
            <div class="mobile-card-meta-list">
              <span v-if="taskTypeText(item)" class="meta-item meta-type">
                <TagIcon class="meta-icon" />
                <span>{{ taskTypeText(item) }}</span>
              </span>
              <span class="meta-item meta-app">
                <AppIcon class="meta-icon" />
                <span>{{ text(item.appName) || '统一门户' }}</span>
              </span>
              <span class="meta-item meta-time">
                <TimeIcon class="meta-icon" />
                <span>{{ date(item.receivedAt) }}</span>
              </span>
            </div>
            <div v-if="item.status === 'PENDING'" class="mobile-card-actions">
              <TMobileButton size="small" variant="text" theme="primary" @click="process(item)">去处理</TMobileButton>
            </div>
          </div>
        </div>
      </article>
    </div>
  </section>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue';
import { Button as TMobileButton, Input as TMobileInput, Tag as TMobileTag } from 'tdesign-mobile-vue';
import { AppIcon, TagIcon, TimeIcon } from 'tdesign-icons-vue-next';
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

function taskTypeText(item: Todo): string {
  return label(item.businessType, 'todo_task_type') || text(item.businessType) || '服务事项';
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
  padding: 20px 16px 32px;
  color: #173047;
}

.mobile-page-intro h1 {
  margin: 0;
  font-size: 25px;
  font-weight: 600;
}

.mobile-page-intro p {
  margin: 5px 0 18px;
  color: #71879a;
  font-size: 14px;
}

.mobile-todo-search {
  margin-bottom: 16px;
}

.mobile-todo-filters {
  display: flex;
  gap: 8px;
  margin-bottom: 16px;
  overflow: auto;
}

.mobile-todo-filters button {
  flex: none;
  border: 0;
  border-radius: 18px;
  background: #edf3f7;
  color: #5a7287;
  padding: 8px 16px;
  font-size: 14px;
  cursor: pointer;
}

.mobile-todo-filters button.active {
  background: #ecf2fe;
  color: #0052d9;
  font-weight: 700;
}

.mobile-inline-error {
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

.mobile-todo-list {
  display: grid;
  gap: 12px;
}

.mobile-todo-card {
  background: #fff;
  border: 1px solid #edf2f4;
  border-radius: 16px;
  padding: 16px;
  box-shadow: 0 5px 18px rgba(22, 79, 91, 0.04);
}

.mobile-card-main {
  display: block;
  width: 100%;
}

.mobile-card-top {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 12px;
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

.mobile-card-footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  margin-top: 10px;
  padding-top: 10px;
  border-top: 1px solid #f2f5f8;
  font-size: 12px;
}

.mobile-card-meta-list {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 10px;
  min-width: 0;
  flex: 1;
}

.meta-item {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  color: #728496;
  white-space: nowrap;
}

.meta-item svg,
.meta-icon {
  width: 13px;
  height: 13px;
  flex: none;
  color: #8c9fae;
}

.meta-item.meta-type {
  color: #0052d9;
  font-weight: 500;
}

.meta-item.meta-type svg,
.meta-item.meta-type .meta-icon {
  color: #0052d9;
}

.meta-item.meta-app {
  color: #435b71;
}

.meta-item.meta-time {
  color: #8c9fae;
}

.mobile-card-actions {
  flex: none;
  display: flex;
  align-items: center;
}

.mobile-card-actions :deep(.t-button) {
  padding: 0 4px;
  height: 24px;
  line-height: 24px;
  font-size: 13px;
  font-weight: 600;
}
</style>
