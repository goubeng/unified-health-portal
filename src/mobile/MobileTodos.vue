<template>
  <section class="mobile-todos">
    <div class="mobile-page-intro"><h1>待办事项</h1><p>当前有 {{ pendingCount }} 项待处理</p></div>
    <div class="mobile-todo-search"><TMobileInput v-model="keyword" placeholder="搜索待办标题" clearable /></div>
    <nav class="mobile-todo-filters" aria-label="待办状态">
       <button v-for="item in filters" :key="item.value" type="button" :class="{active:status===item.value}" :aria-pressed="status===item.value" @click="status=item.value">{{ item.label }}</button>
    </nav>
    <p v-if="error" class="mobile-inline-error" role="alert">{{ error }}</p>
    <div v-if="loading" class="mobile-list-empty">正在加载待办…</div>
    <div v-else-if="!filtered.length" class="mobile-list-empty">暂无符合条件的待办</div>
    <div v-else class="mobile-todo-list">
      <article v-for="item in filtered" :key="item.id" class="mobile-todo-card">
         <button class="mobile-card-main" type="button" :data-mobile-todo-trigger="item.id" @click="openDetail(item)">
          <span class="mobile-card-top"><strong>{{ text(item.title)||'-' }}</strong><TMobileTag :theme="item.status==='PENDING'?'warning':item.status==='COMPLETED'?'success':'default'" variant="light">{{ label(item.status,'todo_status') }}</TMobileTag></span>
          <span class="mobile-card-summary">{{ text(item.summary)||'点击查看待办详情' }}</span>
          <span class="mobile-card-meta">{{ text(item.appName)||'统一门户' }} · {{ date(item.receivedAt) }}</span>
        </button>
        <TMobileButton v-if="item.status==='PENDING'" size="small" variant="text" theme="primary" @click="process(item)">去处理</TMobileButton>
      </article>
    </div>
     <div v-if="active" class="mobile-detail-shade" @click.self="closeDialog">
       <section ref="detailPanel" class="mobile-detail-panel" role="dialog" aria-modal="true" aria-label="待办详情" tabindex="-1">
         <header><button type="button" class="mobile-nav-back-btn" @click="closeDialog"><ChevronLeftIcon /><span>返回</span></button><strong>待办详情</strong><span></span></header>
        <h2>{{ text(active.title)||'-' }}</h2>
        <dl><div><dt>来源应用</dt><dd>{{ text(active.appName)||'-' }}</dd></div><div><dt>任务类型</dt><dd>{{ label(active.businessType,'todo_task_type') }}</dd></div><div><dt>接收时间</dt><dd>{{ date(active.receivedAt) }}</dd></div><div><dt>状态</dt><dd>{{ label(active.status,'todo_status') }}</dd></div></dl>
        <p class="mobile-detail-body">{{ text(active.summary)||'-' }}</p>
        <TMobileButton v-if="active.status==='PENDING'" block theme="primary" @click="process(active)">去处理</TMobileButton>
      </section>
    </div>
  </section>
</template>

<script setup lang="ts">
import {computed,onMounted,ref,watch} from 'vue';
import {useRoute,useRouter} from 'vue-router';
import {Button as TMobileButton,Input as TMobileInput,Tag as TMobileTag} from 'tdesign-mobile-vue';
import {ChevronLeftIcon} from 'tdesign-icons-vue-next';
import {command,portal,revision,loadDictionaryLookups} from '../services/runtime.js';
import {date,label,text} from '../components/portal/presentation.js';
import {useMobileDialog} from './useMobileDialog';

interface Todo {id:string;title?:string;summary?:string;appName?:string;businessType?:string;receivedAt?:string;status:string}
const filters=[{value:'PENDING',label:'待处理'},{value:'',label:'全部'},{value:'COMPLETED',label:'已完成'}];
const route=useRoute(),router=useRouter();
const rows=ref<Todo[]>([]),loading=ref(true),error=ref(''),keyword=ref(''),status=ref('PENDING');
const active=computed(()=>rows.value.find(row=>row.id===String(route.query.todoId||''))||null);
const detailPanel=ref<HTMLElement|null>(null);
let restoreTodoId=String(route.query.todoId||'');
const {closeDialog}=useMobileDialog({open:computed(()=>Boolean(active.value)),element:detailPanel,close:closeDetail,restore:()=>[...document.querySelectorAll<HTMLElement>('[data-mobile-todo-trigger]')].find(node=>node.dataset.mobileTodoTrigger===restoreTodoId)||null});
const pendingCount=computed(()=>rows.value.filter(row=>row.status==='PENDING').length);
const filtered=computed(()=>rows.value.filter(row=>(!status.value||row.status===status.value)&&(!keyword.value.trim()||text(row.title).toLowerCase().includes(keyword.value.trim().toLowerCase()))).sort((a,b)=>(Date.parse(b.receivedAt||'')||0)-(Date.parse(a.receivedAt||'')||0)));
let requestVersion=0;
async function load(){const version=++requestVersion;loading.value=true;error.value='';const result=await portal.read('todos');if(version!==requestVersion)return;rows.value=result.ok?result.data:[];error.value=result.ok?'':text(result.error?.message);loading.value=false;}
function openDetail(item:Todo){restoreTodoId=item.id;router.push({path:'/m/todos',query:{todoId:item.id}});}
function closeDetail(){router.replace('/m/todos');}
async function process(item:Todo){error.value='';const result=await command('openTodo',{id:item.id});if(!result.ok){error.value=text(result.error?.message);return;}window.alert(text(result.data?.message)||'已打开待办');}
onMounted(()=>{loadDictionaryLookups();load();});
watch(revision,load);
</script>

<style scoped>
.mobile-todos{padding:20px 16px 32px;color:#173047}.mobile-page-intro h1{margin:0;font-size:25px;font-weight:600}.mobile-page-intro p{margin:5px 0 18px;color:#71879a;font-size:14px}.mobile-todo-search{margin-bottom:16px}.mobile-todo-filters{display:flex;gap:8px;margin-bottom:16px;overflow:auto}.mobile-todo-filters button{flex:none;border:0;border-radius:18px;background:#edf3f7;color:#5a7287;padding:8px 16px;font-size:14px}.mobile-todo-filters button.active{background:#dceef0;color:#087c83;font-weight:700}.mobile-inline-error{padding:10px 12px;border-radius:8px;background:#fff1ef;color:#ba3e38;font-size:13px}.mobile-list-empty{padding:58px 0;text-align:center;color:#91a2af;font-size:14px}.mobile-todo-list{display:grid;gap:12px}.mobile-todo-card{background:#fff;border:1px solid #edf2f4;border-radius:16px;padding:16px;box-shadow:0 5px 18px #164f5b0a}.mobile-card-main{display:block;width:100%;padding:0;text-align:left;border:0;background:none;color:inherit}.mobile-card-top{display:flex;justify-content:space-between;align-items:flex-start;gap:12px}.mobile-card-top strong{font-size:16px;line-height:1.5}.mobile-card-summary,.mobile-card-meta{display:block;margin-top:10px;color:#6b8090;font-size:13px;line-height:1.5}.mobile-card-meta{font-size:12px;color:#8f9fae}.mobile-card-summary{display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}.mobile-todo-card :deep(.t-button){margin-top:10px}.mobile-detail-shade{position:fixed;inset:0;z-index:100;background:#0007;display:flex;align-items:flex-end}.mobile-detail-panel{width:100%;max-height:86dvh;overflow:auto;box-sizing:border-box;padding:0 20px max(28px,env(safe-area-inset-bottom));border-radius:22px 22px 0 0;background:#fff}.mobile-detail-panel header{display:grid;grid-template-columns:1fr 2fr 1fr;align-items:center;height:56px;border-bottom:1px solid #eef2f4}.mobile-detail-panel header strong{text-align:center;font-size:17px}.mobile-nav-back-btn{display:flex;align-items:center;gap:3px;border:0;background:none;color:#0b858a;font-size:14px;padding:6px 0}.mobile-nav-back-btn svg{width:18px;height:18px}.mobile-detail-panel h2{font-size:19px;line-height:1.4;margin:16px 0 12px;font-weight:600}.mobile-detail-panel dl{margin:0}.mobile-detail-panel dl div{display:flex;justify-content:space-between;gap:12px;padding:12px 0;border-bottom:1px solid #f1f3f5;font-size:14px}.mobile-detail-panel dt{color:#8193a0}.mobile-detail-panel dd{margin:0;text-align:right}.mobile-detail-body{min-height:80px;color:#50697b;font-size:14px;line-height:1.7;margin:16px 0}
</style>
