<template>
  <div class="mobile-notices">
    <header class="mobile-notices-head"><button type="button" aria-label="返回" @click="back"><ChevronLeftIcon /></button><h1>{{ selected ? '公告详情' : '通知公告' }}</h1></header>
    <div v-if="error" class="mobile-notices-error" role="alert">{{ error }} <button type="button" @click="load">重新加载</button></div>
    <p v-if="loading" class="mobile-notices-empty">正在加载公告…</p>
    <template v-else-if="selected">
      <article class="mobile-notices-detail">
        <h2>{{ selected.title }}</h2>
        <div class="mobile-notices-meta"><span>{{ selected.type || '通知' }}</span><span>{{ scopeText(selected.scope) }}</span><span>{{ formatDate(selected.publishedAt) }}</span></div>
        <div class="mobile-notices-content" v-html="richText(selected.content)"></div>
        <section class="mobile-notices-files"><h3>附件材料</h3><p v-if="!selected.attachments?.length">无附件</p><button v-for="file in selected.attachments || []" :key="file.id || file.name" type="button" @click="download(file)"><FileIcon />{{ file.name }}<DownloadIcon /></button></section>
      </article>
    </template>
    <template v-else>
      <p class="mobile-notices-intro">及时了解平台通知与服务信息</p>
      <div v-if="notices.length" class="mobile-notices-list"><button v-for="item in notices" :key="item.id" type="button" @click="open(item)"><span class="mobile-notices-date"><strong>{{ day(item.publishedAt) }}</strong><small>{{ month(item.publishedAt) }}</small></span><span class="mobile-notices-copy"><strong>{{ item.title }}</strong><small>{{ item.type || '通知' }} · {{ formatDate(item.publishedAt) }}</small></span><i v-if="item.readStatus === 'UNREAD'"></i><ChevronRightIcon /></button></div>
      <p v-else class="mobile-notices-empty">暂无通知公告</p>
    </template>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { ChevronLeftIcon, ChevronRightIcon, DownloadIcon, FileIcon } from 'tdesign-icons-vue-next';
import { command, portal, revision } from '../services/runtime.js';
import { richText } from '../components/portal/presentation.js';

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

<style scoped>
.mobile-notices{padding:0 16px 28px;color:#1d3552}.mobile-notices-head{display:flex;align-items:center;gap:13px;height:54px;margin:0 -16px;padding:0 16px;background:#fff}.mobile-notices-head button{display:grid;place-items:center;width:28px;height:28px;border:0;background:none;color:#355577}.mobile-notices-head svg{width:21px;height:21px}.mobile-notices-head h1{margin:0;font-size:17px}.mobile-notices-intro{margin:17px 0;color:#8294a7;font-size:12px}.mobile-notices-list{overflow:hidden;border-radius:16px;background:#fff}.mobile-notices-list button{display:flex;align-items:center;gap:12px;width:100%;min-height:77px;padding:13px;border:0;border-top:1px solid #edf2f6;background:none;text-align:left}.mobile-notices-list button:first-child{border-top:0}.mobile-notices-date{display:flex;align-items:center;flex-direction:column;justify-content:center;width:43px;height:46px;flex:none;border-radius:10px;background:#e7f2ff;color:#1475c4}.mobile-notices-date strong{font-size:18px;line-height:1}.mobile-notices-date small{margin-top:4px;font-size:10px}.mobile-notices-copy{display:flex;flex:1;flex-direction:column;gap:7px;min-width:0}.mobile-notices-copy strong{overflow:hidden;color:#28415d;font-size:13px;text-overflow:ellipsis;white-space:nowrap}.mobile-notices-copy small{color:#96a6b6;font-size:11px}.mobile-notices-list i{width:6px;height:6px;border-radius:50%;background:#e99141}.mobile-notices-list svg{width:14px;height:14px;color:#a4b2c0}.mobile-notices-detail{margin-top:14px;padding:20px 16px;border-radius:16px;background:#fff}.mobile-notices-detail h2{margin:0;font-size:20px;line-height:1.4}.mobile-notices-meta{display:flex;flex-wrap:wrap;gap:8px;margin:13px 0;padding-bottom:16px;border-bottom:1px solid #e9eff5;color:#889bad;font-size:11px}.mobile-notices-content{min-height:120px;overflow-wrap:anywhere;color:#344e69;font-size:14px;line-height:1.8}.mobile-notices-content :deep(img){max-width:100%}.mobile-notices-files{margin-top:24px;border-top:1px solid #e9eff5}.mobile-notices-files h3{font-size:14px}.mobile-notices-files p{font-size:12px;color:#94a2b1}.mobile-notices-files button{display:flex;align-items:center;gap:7px;width:100%;padding:12px 0;border:0;border-top:1px solid #f0f3f6;background:none;color:#2d597e;text-align:left;font-size:12px}.mobile-notices-files button svg{width:17px;height:17px}.mobile-notices-files button svg:last-child{margin-left:auto}.mobile-notices-empty{padding:30px 0;text-align:center;color:#94a4b4;font-size:13px}.mobile-notices-error{margin:14px 0;padding:12px;border-radius:10px;background:#fff0ed;color:#ad4b3d;font-size:12px}.mobile-notices-error button{border:0;background:none;color:#ad4b3d}
</style>
