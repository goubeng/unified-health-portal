<template>
  <div class="mobile-notices">
    <header class="mobile-notices-head"><button type="button" aria-label="返回" @click="back"><ChevronLeftIcon /></button><h1>{{ selected ? '公告详情' : '通知公告' }}</h1></header>
    <div v-if="error" class="mobile-notices-error" role="alert">{{ error }} <button type="button" @click="load">重新加载</button></div>
    <div v-if="loading" class="mobile-notices-empty"><MobileLoading message="正在加载公告…" /></div>
    <template v-else-if="selected">
      <article class="mobile-notices-detail">
        <h2>{{ selected.title }}</h2>
        <div class="mobile-notices-meta">
          <span><TagIcon aria-hidden="true" />{{ selected.type || '通知' }}</span>
          <span><UserIcon aria-hidden="true" />{{ scopeText(selected.scope) }}</span>
          <span><CalendarIcon aria-hidden="true" />{{ formatDate(selected.publishedAt) }}</span>
        </div>
        <div class="mobile-notices-content" v-html="richText(selected.content)"></div>
        <section class="mobile-notices-files"><h3>附件材料</h3><p v-if="!selected.attachments?.length">无附件</p><button v-for="file in selected.attachments || []" :key="file.id || file.name" type="button" @click="download(file)"><AttachIcon />{{ file.name }}<DownloadIcon /></button></section>
      </article>
    </template>
    <template v-else>
      <p class="mobile-notices-intro">及时了解平台通知与服务信息</p>
      <div v-if="notices.length" class="mobile-notices-list"><button v-for="item in notices" :key="item.id" type="button" @click="open(item)"><span class="mobile-notices-date"><strong>{{ day(item.publishedAt) }}</strong><small>{{ month(item.publishedAt) }}</small></span><span class="mobile-notices-copy"><strong>{{ item.title }}</strong><small>{{ item.type || '通知' }} · {{ formatDate(item.publishedAt) }}</small></span><span v-if="item.readStatus === 'UNREAD'" class="mobile-notice-unread-dot" aria-label="未读"></span><ChevronRightIcon /></button></div>
      <p v-else class="mobile-notices-empty">暂无通知公告</p>
    </template>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { AttachIcon, CalendarIcon, ChevronLeftIcon, ChevronRightIcon, DownloadIcon, TagIcon, UserIcon } from 'tdesign-icons-vue-next';
import { command, portal, revision } from '../services/runtime.js';
import { richText } from '../components/portal/presentation.js';
import MobileLoading from './MobileLoading.vue';

type Attachment = { id?: string; name: string; data?: string };
type Notice = { id: string; title: string; type?: string; scope?: string; content?: string; publishedAt?: string; readStatus?: string; attachments?: Attachment[] };
const route = useRoute();
const router = useRouter();
const loading = ref(true);
const error = ref('');
const notices = ref<Notice[]>([]);
const selected = computed(() => notices.value.find(item => item.id === route.params.id) || null);
function back() { router.push(selected.value ? '/m/announcements' : '/m/home'); }
function open(item: Notice) { router.push(`/m/announcements/${encodeURIComponent(item.id)}`); }
function formatDate(value?: string) { const time = Date.parse(value || ''); return Number.isFinite(time) ? new Intl.DateTimeFormat('zh-CN', { year: 'numeric', month: '2-digit', day: '2-digit' }).format(time) : '暂无时间'; }
function day(value?: string) { const time = Date.parse(value || ''); return Number.isFinite(time) ? String(new Date(time).getDate()).padStart(2, '0') : '--'; }
function month(value?: string) { const time = Date.parse(value || ''); return Number.isFinite(time) ? `${new Date(time).getMonth() + 1}月` : '--'; }
function scopeText(value?: string) { return ({ ALL: '全部用户', CITIZEN: '公众用户', GOV: '政务用户' } as Record<string, string>)[value || 'ALL'] || '全部用户'; }
async function load() {
  loading.value = true; error.value = '';
  try {
    const result = await portal.read('announcements');
    if (!result.ok) throw new Error(result.error.message);
    notices.value = [...(result.data || [])].sort((a, b) => (Date.parse(b.publishedAt || '') || 0) - (Date.parse(a.publishedAt || '') || 0));
    if (route.params.id && !selected.value) error.value = '公告不存在或不在当前用户可见范围';
  } catch (cause) { error.value = cause instanceof Error ? cause.message : '公告加载失败'; }
  finally { loading.value = false; }
}
async function markSelectedRead() {
  const item = selected.value;
  if (!item || item.readStatus !== 'UNREAD') return;
  const result = await command('markAnnouncementRead', { id: item.id });
  if (result.ok) item.readStatus = 'READ';
}
function download(file: Attachment) { if (!file.data?.startsWith('data:')) { window.alert('附件内容不可用'); return; } const link = document.createElement('a'); link.href = file.data; link.download = file.name; link.click(); }
onMounted(load);
watch(revision, load);
watch(() => route.params.id, markSelectedRead);
watch(selected, markSelectedRead);
</script>

<style scoped src="./mobile-announcements.css"></style>
