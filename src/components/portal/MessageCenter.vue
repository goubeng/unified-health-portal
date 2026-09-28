<template>
  <section class="portal-message-center">
    <Teleport v-if="!activeMessage" to="#page-header-extra">
      <span class="portal-title-count">（共<span class="portal-title-count-number">{{ unreadCount }}</span>封未读）</span>
    </Teleport>
    <template v-if="!activeMessage">
      <t-form layout="inline" class="portal-query list-toolbar message-filters">
        <t-form-item class="portal-query-keyword query-width-keyword" label="关键词"><t-input v-model="keyword" placeholder="消息标题" clearable/></t-form-item>
        <t-form-item class="portal-query-select query-width-source" label="来源应用"><t-select v-model="sourceFilter" clearable filterable placeholder="全部" :options="sourceOptions"/></t-form-item>
        <t-form-item class="portal-query-select query-width-message-type" label="消息类型"><t-select v-model="typeFilter" clearable placeholder="全部" :options="typeOptions"/></t-form-item>
        <t-form-item class="portal-query-select query-width-status" label="阅读状态"><t-select v-model="statusFilter" clearable placeholder="全部" :options="statusOptions"/></t-form-item>
        <t-form-item class="portal-query-action"><t-button class="query-reset-button" theme="default" variant="outline" @click="resetFilters">重置</t-button></t-form-item>
      </t-form>

      <section class="panel message-content-shell">
        <div class="message-content-toolbar">
          <div class="message-content-actions">
            <t-button variant="outline" size="medium" :disabled="!selectedIds.length" @click="confirmDelete(selectedIds)">删除</t-button>
            <t-button variant="outline" size="medium" :disabled="!selectedUnreadIds.length" @click="markSelectedRead">标记为已读</t-button>
            <t-button variant="outline" size="medium" :disabled="!unreadCount" @click="markAllRead">全部标为已读</t-button>
          </div>
        </div>

        <section class="message-list-panel">
          <t-table row-key="id" :data="pagedMessages" :columns="columns" hover table-layout="fixed" size="medium">
            <template #empty><EmptyState :description="statusFilter==='UNREAD'?'暂无未读的消息':'暂无符合条件的消息'"/></template>
          </t-table>
          <t-pagination v-if="filteredMessages.length" v-model="page" v-model:page-size="pageSize" :total="filteredMessages.length" :page-size-options="[10,20,50]" show-jumper/>
        </section>
      </section>
    </template>

    <template v-else>
      <div class="message-detail-toolbar list-toolbar">
        <t-button variant="outline" size="medium" :disabled="!prevMessage" @click="open(prevMessage)"><template #icon><Icon name="arrow-left"/></template>上一封</t-button>
        <t-button variant="outline" size="medium" :disabled="!nextMessage" @click="open(nextMessage)"><template #icon><Icon name="arrow-right"/></template>下一封</t-button>
        <t-button variant="outline" size="medium" theme="danger" @click="confirmDelete([activeMessage.id])"><template #icon><Icon name="delete"/></template>删除</t-button>
      </div>
      <div class="message-letter-wrap"><div class="message-letter-panel"><article class="message-letter">
        <h2>{{ text(activeMessage.title) }}</h2>
        <div class="message-letter-meta">
          <div><Icon name="user"/><span>接收对象</span><strong>{{ text(receiver)||'当前登录用户' }}</strong></div>
          <div><Icon name="time"/><span>接收时间</span><strong>{{ date(activeMessage.receivedAt) }}</strong></div>
          <div><Icon name="mail"/><span>消息类型</span><strong>{{ label(activeMessage.messageType||'BUSINESS') }}</strong></div>
          <div><Icon name="tag"/><span>消息来源</span><strong>{{ text(activeMessage.appName||'统一门户') }}</strong></div>
          <div><Icon name="user-talk"/><span>发送方</span><strong>{{ text(activeMessage.appName||'统一门户') }}</strong></div>
        </div>
        <p>您好！</p>
        <p class="message-letter-body">{{ text(activeMessage.content)||'暂无正文' }}</p>
        <section class="message-business-detail"><h3>关联信息</h3><div class="message-business-grid">
          <div><span>来源应用</span><strong>{{ text(activeMessage.appName)||'统一门户' }}</strong></div>
          <div><span>读取状态</span><strong><t-tag :theme="activeMessage.status==='UNREAD'?'warning':'success'" variant="light">{{ activeMessage.status==='UNREAD'?'未读':'已读' }}</t-tag></strong></div>
        </div></section>
        <div class="message-letter-actions"><t-button v-if="activeMessage.appId" theme="primary" @click="openBusiness">查看关联业务</t-button></div>
      </article></div></div>
    </template>
  </section>
</template>

<script setup>
import {computed,h,ref,resolveComponent,watch} from 'vue';
import {useRoute,useRouter} from 'vue-router';
import {DialogPlugin,MessagePlugin} from 'tdesign-vue-next';
import {Icon} from 'tdesign-icons-vue-next';
import EmptyState from './EmptyState.vue';
import TableCellTooltip from './TableCellTooltip.vue';
import {command} from '../../services/runtime.js';
import {text,label,date,theme} from './presentation.js';

const props=defineProps({rows:{type:Array,default:()=>[]},receiver:{type:String,default:''}});
const route=useRoute(),router=useRouter();
const statusFilter=ref('UNREAD'),sourceFilter=ref(''),typeFilter=ref(''),keyword=ref(''),page=ref(1),pageSize=ref(10),selectedIds=ref([]);
const TCheckbox=resolveComponent('t-checkbox');
const statusOptions=[{label:'未读',value:'UNREAD'},{label:'已读',value:'READ'}];
const sourceOptions=computed(()=>[...new Set(props.rows.map(item=>item.appName).filter(Boolean))].map(value=>({value,label:text(value)})));
const typeOptions=computed(()=>[...new Set(props.rows.map(item=>item.messageType).filter(Boolean))].map(value=>({value,label:label(value)})));
const unreadCount=computed(()=>props.rows.filter(item=>item.status==='UNREAD').length);
const filteredMessages=computed(()=>props.rows.filter(item=>{
 const term=keyword.value.trim().toLowerCase();
 return (!statusFilter.value||item.status===statusFilter.value)&&(!sourceFilter.value||item.appName===sourceFilter.value)&&(!typeFilter.value||item.messageType===typeFilter.value)&&(!term||text(item.title).toLowerCase().includes(term));
}).sort((a,b)=>(Date.parse(b.receivedAt)||0)-(Date.parse(a.receivedAt)||0)));
const filteredIds=computed(()=>filteredMessages.value.map(item=>item.id));
const selectedUnreadIds=computed(()=>selectedIds.value.filter(id=>props.rows.find(item=>item.id===id)?.status==='UNREAD'));
const allFilteredSelected=computed(()=>filteredIds.value.length>0&&filteredIds.value.every(id=>selectedIds.value.includes(id)));
const partialFilteredSelected=computed(()=>!allFilteredSelected.value&&filteredIds.value.some(id=>selectedIds.value.includes(id)));
const pagedMessages=computed(()=>filteredMessages.value.slice((page.value-1)*pageSize.value,page.value*pageSize.value));
const activeMessage=computed(()=>props.rows.find(item=>item.id===String(route.query.messageId||''))||null);
const activeIndex=computed(()=>activeMessage.value?props.rows.findIndex(item=>item.id===activeMessage.value.id):-1);
const prevMessage=computed(()=>activeIndex.value>0?props.rows[activeIndex.value-1]:null);
const nextMessage=computed(()=>activeIndex.value>=0&&activeIndex.value<props.rows.length-1?props.rows[activeIndex.value+1]:null);
const columns=computed(()=>[
 {colKey:'selector',title:()=>h(TCheckbox,{checked:allFilteredSelected.value,indeterminate:partialFilteredSelected.value,onChange:toggleAllFiltered}),width:48,cell:(_,context)=>h(TCheckbox,{checked:selectedIds.value.includes(context.row.id),onChange:checked=>toggleRow(context.row.id,checked)})},
 {colKey:'serial',title:'序号',width:64,cell:(_,context)=>(page.value-1)*pageSize.value+context.rowIndex+1},
 {colKey:'title',title:'标题',minWidth:280,cell:(_,context)=>h(TableCellTooltip,{text:text(context.row.title)||'-'},()=>h('button',{class:'portal-field-link message-title-link',onClick:()=>open(context.row)},text(context.row.title)||'-'))},
 {colKey:'appName',title:'来源应用',minWidth:220,ellipsis:true,cell:(_,context)=>h(TableCellTooltip,{text:text(context.row.appName)||'统一门户'},()=>text(context.row.appName)||'统一门户')},
 {colKey:'messageType',title:'消息类型',width:130,cell:(_,context)=>label(context.row.messageType||'BUSINESS')},
 {colKey:'status',title:'阅读状态',width:100,cell:(_,context)=>h(resolveComponent('t-tag'),{theme:theme(context.row.status),variant:'light'},()=>label(context.row.status))},
 {colKey:'receivedAt',title:'接收时间',width:180,cell:(_,context)=>date(context.row.receivedAt)}
]);

function toggleRow(id,checked){selectedIds.value=checked?[...new Set([...selectedIds.value,id])]:selectedIds.value.filter(item=>item!==id);}
function toggleAllFiltered(checked){selectedIds.value=checked?[...new Set([...selectedIds.value,...filteredIds.value])]:selectedIds.value.filter(id=>!filteredIds.value.includes(id));}
function resetFilters(){statusFilter.value='UNREAD';sourceFilter.value='';typeFilter.value='';keyword.value='';page.value=1;}
function open(item){if(item)router.push({path:route.path,query:{...route.query,messageId:item.id}});}
function backToList(){const query={...route.query};delete query.messageId;router.replace({path:route.path,query});}
async function markSelectedRead(){if(!selectedUnreadIds.value.length)return;const result=await command('markMessagesRead',{ids:selectedUnreadIds.value});if(!result.ok){MessagePlugin.error(text(result.error.message));return;}selectedIds.value=[];MessagePlugin.success(`已标记 ${result.data.count} 条消息为已读`);}
async function markAllRead(){const result=await command('markAllMessagesRead');if(!result.ok){MessagePlugin.error(text(result.error.message));return;}selectedIds.value=[];MessagePlugin.success(result.data.count?`已将 ${result.data.count} 条消息标记为已读`:'当前没有未读消息');}
function confirmDelete(ids){const targets=[...new Set(ids)].filter(Boolean);if(!targets.length)return;const dialog=DialogPlugin.confirm({placement:'center',header:'删除消息',body:`确认删除选中的 ${targets.length} 条消息吗？`,confirmBtn:{theme:'danger',content:'删除'},onConfirm:async()=>{const result=await command('deleteMessages',{ids:targets});if(!result.ok){MessagePlugin.error(text(result.error.message));return;}selectedIds.value=[];if(activeMessage.value)await backToList();dialog.hide();MessagePlugin.success(`已删除 ${result.data.count} 条消息`);}});}
async function openBusiness(){const result=await command('enterApp',{id:activeMessage.value.appId});if(!result.ok){MessagePlugin.error(text(result.error.message));return;}DialogPlugin.alert({placement:'center',header:'应用访问',body:text(result.data.message),confirmBtn:'知道了'});}
watch([statusFilter,sourceFilter,typeFilter,keyword,pageSize],()=>{page.value=1;});
watch(filteredMessages,()=>{const visible=new Set(filteredIds.value);selectedIds.value=selectedIds.value.filter(id=>visible.has(id));page.value=Math.min(page.value,Math.max(1,Math.ceil(filteredMessages.value.length/pageSize.value)));});
watch(activeMessage,async item=>{if(!item||item.status!=='UNREAD')return;const result=await command('markRead',{id:item.id});if(!result.ok)MessagePlugin.error(text(result.error.message));},{immediate:true});
</script>