<template>
  <section class="mobile-messages">
    <template v-if="!active">
      <div class="mobile-message-heading"><div><h1>消息中心</h1><p>{{ unreadCount }} 条未读消息</p></div><TMobileButton v-if="unreadCount" size="small" variant="text" theme="primary" @click="markAll">全部已读</TMobileButton></div>
      <div class="mobile-message-search"><TMobileInput v-model="keyword" placeholder="搜索消息标题" clearable /></div>
      <nav class="mobile-message-filters" aria-label="阅读状态"><button v-for="item in filters" :key="item.value" type="button" :class="{active:status===item.value}" :aria-pressed="status===item.value" @click="status=item.value">{{ item.label }}</button></nav>
      <div v-if="selectedIds.length" class="mobile-message-selection"><span>已选 {{ selectedIds.length }} 条</span><TMobileButton size="small" variant="text" @click="markSelected">标为已读</TMobileButton><TMobileButton size="small" variant="text" theme="danger" @click="removeSelected">删除</TMobileButton></div>
      <p v-if="error" class="mobile-inline-error" role="alert">{{ error }}</p>
      <div v-if="loading" class="mobile-list-empty">正在加载消息…</div><div v-else-if="!filtered.length" class="mobile-list-empty">暂无符合条件的消息</div>
      <div v-else class="mobile-message-list"><article v-for="item in filtered" :key="item.id" class="mobile-message-card" :class="{unread:item.status==='UNREAD'}">
        <input type="checkbox" :aria-label="`选择${text(item.title)}消息`" :checked="selectedIds.includes(item.id)" @change="toggle(item.id)" />
        <button type="button" class="mobile-message-main" @click="open(item)"><span class="mobile-message-title"><i v-if="item.status==='UNREAD'"></i><strong>{{ text(item.title)||'-' }}</strong></span><span class="mobile-message-excerpt">{{ text(item.content)||'暂无正文' }}</span><span class="mobile-message-meta">{{ text(item.appName)||'统一门户' }} · {{ date(item.receivedAt) }}</span></button>
      </article></div>
    </template>
    <template v-else>
      <header class="mobile-message-detail-head"><button type="button" @click="back">返回</button><strong>消息详情</strong><button type="button" @click="remove([active.id])">删除</button></header>
      <p v-if="error" class="mobile-inline-error" role="alert">{{ error }}</p>
      <article class="mobile-message-detail"><h1>{{ text(active.title)||'-' }}</h1><p class="mobile-message-detail-date">{{ date(active.receivedAt) }}</p><dl><div><dt>接收对象</dt><dd>{{ text(actor?.name)||'当前登录用户' }}</dd></div><div><dt>来源应用</dt><dd>{{ text(active.appName)||'统一门户' }}</dd></div><div><dt>消息类型</dt><dd>{{ label(active.messageType||'BUSINESS','message_type') }}</dd></div><div><dt>阅读状态</dt><dd><TMobileTag :theme="active.status==='UNREAD'?'warning':'success'" variant="light">{{ label(active.status,'message_read_status') }}</TMobileTag></dd></div></dl><div class="mobile-message-body">{{ text(active.content)||'暂无正文' }}</div><TMobileButton v-if="active.appId" block theme="primary" @click="openBusiness">查看关联业务</TMobileButton></article>
    </template>
  </section>
</template>

<script setup lang="ts">
import {computed,onMounted,ref,watch} from 'vue';
import {useRoute,useRouter} from 'vue-router';
import {Button as TMobileButton,Input as TMobileInput,Tag as TMobileTag} from 'tdesign-mobile-vue';
import {command,portal,revision,loadDictionaryLookups} from '../services/runtime.js';
import {mobileActor as actor} from './mobileActor';
import {date,label,text} from '../components/portal/presentation.js';

interface Message {id:string;title?:string;content?:string;appName?:string;appId?:string;messageType?:string;receivedAt?:string;status:string}
const filters=[{value:'UNREAD',label:'未读'},{value:'',label:'全部'},{value:'READ',label:'已读'}];
const route=useRoute(),router=useRouter();
const rows=ref<Message[]>([]),loading=ref(true),error=ref(''),keyword=ref(''),status=ref('UNREAD'),selectedIds=ref<string[]>([]);
const active=computed(()=>rows.value.find(item=>item.id===String(route.query.messageId||''))||null);
const unreadCount=computed(()=>rows.value.filter(item=>item.status==='UNREAD').length);
const filtered=computed(()=>rows.value.filter(item=>(!status.value||item.status===status.value)&&(!keyword.value.trim()||text(item.title).toLowerCase().includes(keyword.value.trim().toLowerCase()))).sort((a,b)=>(Date.parse(b.receivedAt||'')||0)-(Date.parse(a.receivedAt||'')||0)));
let requestVersion=0,markingId='';
async function load(){const version=++requestVersion;loading.value=true;error.value='';const result=await portal.read('messages');if(version!==requestVersion)return;rows.value=result.ok?result.data:[];error.value=result.ok?'':text(result.error?.message);loading.value=false;selectedIds.value=selectedIds.value.filter(id=>rows.value.some(row=>row.id===id));}
function toggle(id:string){selectedIds.value=selectedIds.value.includes(id)?selectedIds.value.filter(item=>item!==id):[...selectedIds.value,id];}
function open(item:Message){router.push({path:'/m/messages',query:{messageId:item.id}});}
function back(){router.replace('/m/messages');}
async function markSelected(){const ids=selectedIds.value.filter(id=>rows.value.some(item=>item.id===id&&item.status==='UNREAD'));if(!ids.length)return;const result=await command('markMessagesRead',{ids});if(!result.ok){error.value=text(result.error?.message);return;}selectedIds.value=[];}
async function markAll(){const result=await command('markAllMessagesRead');if(!result.ok)error.value=text(result.error?.message);}
function removeSelected(){const visible=new Set(filtered.value.map(item=>item.id));return remove(selectedIds.value.filter(id=>visible.has(id)));}
async function remove(ids:string[]){const unique=[...new Set(ids)].filter(Boolean);if(!unique.length||!window.confirm(`确认删除选中的 ${unique.length} 条消息吗？`))return;const result=await command('deleteMessages',{ids:unique});if(!result.ok){error.value=text(result.error?.message);return;}selectedIds.value=[];if(active.value)back();}
async function openBusiness(){if(!active.value?.appId)return;const result=await command('enterApp',{id:active.value.appId});if(!result.ok){error.value=text(result.error?.message);return;}window.alert(text(result.data?.message)||'已打开关联业务');}
onMounted(()=>{loadDictionaryLookups();load();});
watch(revision,load);
watch(filtered,items=>{const visible=new Set(items.map(item=>item.id));selectedIds.value=selectedIds.value.filter(id=>visible.has(id));});
watch(active,async item=>{if(!item||item.status!=='UNREAD'||markingId===item.id)return;markingId=item.id;const result=await command('markRead',{id:item.id});if(!result.ok)error.value=text(result.error?.message);markingId='';},{immediate:true});
</script>

<style scoped>
.mobile-messages{padding:20px 16px 32px;color:#173047}.mobile-message-heading{display:flex;justify-content:space-between;align-items:center}.mobile-message-heading h1{margin:0;font-size:25px}.mobile-message-heading p{margin:5px 0 18px;color:#71879a;font-size:13px}.mobile-message-search{margin-bottom:16px}.mobile-message-filters{display:flex;gap:8px;margin-bottom:16px}.mobile-message-filters button{border:0;border-radius:18px;background:#edf3f7;color:#5a7287;padding:8px 17px;font-size:13px}.mobile-message-filters button.active{background:#dceef0;color:#087c83;font-weight:700}.mobile-message-selection{display:flex;align-items:center;gap:6px;margin:0 0 12px;color:#5a7287;font-size:12px}.mobile-message-selection span{margin-right:auto}.mobile-inline-error{padding:10px 12px;border-radius:8px;background:#fff1ef;color:#ba3e38;font-size:13px}.mobile-list-empty{padding:58px 0;text-align:center;color:#91a2af;font-size:14px}.mobile-message-list{display:grid;gap:10px}.mobile-message-card{display:flex;align-items:flex-start;gap:12px;border:1px solid #edf2f4;border-radius:15px;background:#fff;padding:15px;box-shadow:0 5px 18px #164f5b0a}.mobile-message-card.unread{border-left:3px solid #00a3a7}.mobile-message-card input{margin-top:4px;accent-color:#008f97}.mobile-message-main{display:block;flex:1;min-width:0;text-align:left;border:0;background:none;padding:0;color:inherit}.mobile-message-title{display:flex;align-items:center;gap:8px}.mobile-message-title strong{font-size:15px;line-height:1.4;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}.mobile-message-title i{width:7px;height:7px;border-radius:50%;background:#ef7565;flex:none}.mobile-message-excerpt,.mobile-message-meta{display:block;margin-top:8px;color:#708697;font-size:13px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}.mobile-message-meta{font-size:12px;color:#98a8b3}.mobile-message-detail-head{display:grid;grid-template-columns:1fr 2fr 1fr;align-items:center;margin:-20px -16px 20px;padding:16px;background:#fff}.mobile-message-detail-head strong{text-align:center}.mobile-message-detail-head button{border:0;background:none;color:#008b92;text-align:left}.mobile-message-detail-head button:last-child{text-align:right;color:#cd5d54}.mobile-message-detail{padding:20px 18px;border-radius:16px;background:#fff}.mobile-message-detail h1{margin:0;font-size:20px;line-height:1.5}.mobile-message-detail-date{margin:8px 0 20px;color:#8da0ad;font-size:12px}.mobile-message-detail dl{margin:0}.mobile-message-detail dl div{display:flex;justify-content:space-between;gap:10px;padding:10px 0;border-bottom:1px solid #f0f3f5;font-size:13px}.mobile-message-detail dt{color:#8397a4}.mobile-message-detail dd{margin:0;text-align:right}.mobile-message-body{min-height:130px;padding:20px 0;color:#435d70;font-size:15px;line-height:1.8;white-space:pre-wrap}
</style>
