<template>
  <section class="todo-center">
    <section class="list-toolbar-wrap">
      <t-form layout="inline" class="portal-query list-toolbar">
        <t-form-item class="portal-query-keyword todo-query-keyword" label="待办标题">
          <t-input v-model="keyword" clearable placeholder="请输入待办标题"/>
        </t-form-item>
        <t-form-item class="portal-query-select query-width-source" label="来源应用">
          <t-select v-model="appName" clearable placeholder="全部" :options="appOptions"/>
        </t-form-item>
        <t-form-item class="portal-query-select query-width-status" label="状态">
          <t-select v-model="status" clearable placeholder="全部" :options="statusOptions"/>
        </t-form-item>
        <t-form-item class="portal-query-action">
          <t-button class="query-reset-button" theme="default" variant="outline" @click="reset">重置</t-button>
        </t-form-item>
      </t-form>
    </section>

    <section class="panel portal-table-panel">
      <t-table row-key="id" :data="paged" :columns="columns" hover table-layout="fixed" size="medium">
        <template #empty><EmptyState description="暂无符合条件的待办"/></template>
        <template #serial="{rowIndex}">{{(page-1)*pageSize+rowIndex+1}}</template>
        <template #title="{row}">
          <button class="portal-field-link" @click="openDetail(row)">{{text(row.title)||'-'}}</button>
        </template>
        <template #status="{row}">
          <t-tag size="small" variant="light" :theme="statusTheme(row.status)">{{label(row.status)}}</t-tag>
        </template>
        <template #operation="{row}">
          <t-button v-if="row.status==='PENDING'" size="small" variant="text" theme="primary" @click="process(row)">去处理</t-button>
          <span v-else>-</span>
        </template>
      </t-table>
      <t-pagination
        v-model="page"
        v-model:page-size="pageSize"
        :total="filtered.length"
        :page-size-options="[10,20,50]"
        show-jumper
      />
    </section>

    <t-dialog v-model:visible="detailVisible" placement="center" header="待办详情" width="900px">
      <TodoDetailContent :record="active"/>
      <template #footer>
        <div class="todo-detail-footer">
          <t-button variant="outline" @click="detailVisible=false">关闭</t-button>
          <t-button v-if="active?.status==='PENDING'" theme="primary" @click="process(active)">去处理</t-button>
        </div>
      </template>
    </t-dialog>
  </section>
</template>

<script setup>
import {computed,ref,watch} from 'vue';
import {DialogPlugin,MessagePlugin} from 'tdesign-vue-next';
import EmptyState from './EmptyState.vue';
import TodoDetailContent from './TodoDetailContent.vue';
import {command} from '../../services/runtime.js';
import {date,label,text} from './presentation.js';

const props=defineProps({rows:{type:Array,default:()=>[]}});
const keyword=ref(''),appName=ref(''),status=ref('');
const page=ref(1),pageSize=ref(10);
const detailVisible=ref(false),active=ref(null);

const appOptions=computed(()=>[...new Set(props.rows.map(row=>row.appName).filter(Boolean))].map(value=>({value,label:value})));
const statusOptions=['PENDING','COMPLETED','WITHDRAWN'].map(value=>({value,label:label(value)}));

const filtered=computed(()=>{
  const term=keyword.value.trim().toLowerCase();
  return props.rows.filter(row=>{
    const keywordMatched=!term||String(row.title||'').toLowerCase().includes(term);
    const appMatched=!appName.value||row.appName===appName.value;
    const statusMatched=!status.value||row.status===status.value;
    return keywordMatched&&appMatched&&statusMatched;
  }).sort((a,b)=>{
    if(a.status==='PENDING'&&b.status!=='PENDING')return -1;
    if(a.status!=='PENDING'&&b.status==='PENDING')return 1;
    return (Date.parse(b.createdAt)||0)-(Date.parse(a.createdAt)||0);
  });
});
const paged=computed(()=>filtered.value.slice((page.value-1)*pageSize.value,page.value*pageSize.value));
watch([keyword,appName,status,pageSize],()=>{page.value=1;});
watch(()=>filtered.value.length,()=>{page.value=Math.min(page.value,Math.max(1,Math.ceil(filtered.value.length/pageSize.value)));});

const columns=[
  {colKey:'serial',title:'序号',width:64},
  {colKey:'title',title:'待办标题',minWidth:250,ellipsis:true},
  {colKey:'appName',title:'来源应用',width:220,ellipsis:true},
  {colKey:'businessType',title:'业务类型',width:120},
  {colKey:'status',title:'状态',width:120},
  {colKey:'createdAt',title:'接收时间',width:170,cell:(_,context)=>date(context.row.createdAt)},
  {colKey:'operation',title:'操作',width:100,fixed:'right'}
];



function statusTheme(value){return value==='PENDING'?'warning':value==='COMPLETED'?'success':'default';}
function reset(){keyword.value='';appName.value='';status.value='';page.value=1;}
function openDetail(row){active.value=JSON.parse(JSON.stringify(row));detailVisible.value=true;}
async function process(row){
  try{
    const result=await command('openTodo',{id:row.id});
    if(!result.ok){MessagePlugin.error(text(result.error.message));return;}
    const dialog=DialogPlugin.alert({
      placement:'center',
      header:'待办处理',
      body:text(result.data.message),
      confirmBtn:'知道了',
      onConfirm:()=>dialog.hide()
    });
  }catch(cause){MessagePlugin.error(text(cause.message));}
}
</script>
