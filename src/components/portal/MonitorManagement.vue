<template>
  <section class="portal-list monitor-management">
    <t-form layout="inline" class="portal-query list-toolbar">
      <t-form-item class="portal-query-keyword query-width-keyword" label="应用">
        <t-input v-model="keyword" clearable placeholder="应用名称 / 应用编码"/>
      </t-form-item>
      <t-form-item class="portal-query-select query-width-sso-status" label="SSO状态">
        <t-select v-model="ssoStatus" clearable placeholder="全部" :options="statusOptions"/>
      </t-form-item>
      <t-form-item class="portal-query-select query-width-todo-status" label="TODO状态">
        <t-select v-model="todoStatus" clearable placeholder="全部" :options="statusOptions"/>
      </t-form-item>
      <t-form-item class="portal-query-select query-width-message-status" label="MESSAGE状态">
        <t-select v-model="messageStatus" clearable placeholder="全部" :options="statusOptions"/>
      </t-form-item>
      <t-form-item class="portal-query-action">
        <t-button theme="default" variant="outline" @click="reset">重置</t-button>
      </t-form-item>
    </t-form>

    <section class="panel portal-table-panel">
      <t-table row-key="id" :data="paged" :columns="columns" hover table-layout="fixed" size="medium">
        <template #empty><EmptyState description="暂无符合条件的运行监控记录"/></template>
        <template #appName="{row}"><button class="portal-field-link" @click="openDetail(row)">{{text(row.appName)}}</button></template>
        <template #ssoStatus="{row}"><StatusTag :value="row.ssoStatus"/></template>
        <template #todoStatus="{row}"><StatusTag :value="row.todoStatus"/></template>
        <template #messageStatus="{row}"><StatusTag :value="row.messageStatus"/></template>
        <template #lastCheckedAt="{row}">{{date(row.lastCheckedAt)}}</template>
      </t-table>
      <t-pagination v-model="page" v-model:page-size="pageSize" :total="filtered.length" :page-size-options="[10,20,50]" show-jumper/>
    </section>

    <t-dialog v-model:visible="detailVisible" placement="center" :header="(text(detail?.appName)||'应用')+' · 运行监控'" width="920px" :footer="false">
      <div v-if="detail" class="monitor-service-grid">
        <section v-for="kind in kinds" :key="kind" class="monitor-service-card">
          <div class="monitor-service-card-head">
            <strong>{{kind}}</strong>
            <StatusTag :value="detail.services?.[kind]?.status"/>
          </div>
          <DetailGrid :items="serviceDetails(kind)"/>
        </section>
      </div>
      <t-alert theme="info" class="monitor-mock-note">
        当前为A阶段运行场景数据，不执行真实外部探测。正式联调时继续沿用相同SSO/TODO/MESSAGE字段结构。
      </t-alert>
    </t-dialog>
  </section>
</template>

<script setup>
import {computed,defineComponent,h,ref,watch} from 'vue';
import {Tag} from 'tdesign-vue-next';
import EmptyState from './EmptyState.vue';
import DetailGrid from './DetailGrid.vue';
import {date,label,text,theme} from './presentation.js';

const props=defineProps({rows:{type:Array,default:()=>[]}});
const keyword=ref(''),ssoStatus=ref(''),todoStatus=ref(''),messageStatus=ref(''),page=ref(1),pageSize=ref(10);
const detailVisible=ref(false),detail=ref(null),kinds=['SSO','TODO','MESSAGE'];
const statusOptions=['NORMAL','ABNORMAL','UNCONFIGURED','DISABLED'].map(value=>({value,label:label(value)}));
const StatusTag=defineComponent({props:{value:{type:String,default:'UNCONFIGURED'}},setup(p){return()=>h(Tag,{theme:theme(p.value),variant:'light'},()=>label(p.value));}});

const filtered=computed(()=>{
  const term=keyword.value.trim().toLowerCase();
  return props.rows.filter(row=>{
    const matchKeyword=!term||[row.appName,row.appCode].some(value=>text(value).toLowerCase().includes(term));
    return matchKeyword&&(!ssoStatus.value||row.ssoStatus===ssoStatus.value)&&(!todoStatus.value||row.todoStatus===todoStatus.value)&&(!messageStatus.value||row.messageStatus===messageStatus.value);
  });
});
const paged=computed(()=>filtered.value.slice((page.value-1)*pageSize.value,page.value*pageSize.value));
const columns=[
  {colKey:'appName',title:'应用名称',minWidth:250,ellipsis:true},
  {colKey:'appCode',title:'应用编码',width:170,ellipsis:true},
  {colKey:'ssoStatus',title:'SSO状态',width:120},
  {colKey:'todoStatus',title:'TODO状态',width:120},
  {colKey:'messageStatus',title:'MESSAGE状态',width:135},
  {colKey:'lastCheckedAt',title:'最近检测时间',width:180}
];

function reset(){keyword.value='';ssoStatus.value='';todoStatus.value='';messageStatus.value='';page.value=1;}
function openDetail(row){detail.value=JSON.parse(JSON.stringify(row));detailVisible.value=true;}
function serviceDetails(kind){
  const item=detail.value?.services?.[kind]||{};
  return [
    {key:'status',label:'运行状态',value:label(item.status)},
    {key:'lastCheckedAt',label:'最近检测',value:date(item.lastCheckedAt)},
    {key:'lastSuccessAt',label:'最近成功',value:date(item.lastSuccessAt)},
    {key:'lastFailureAt',label:'最近失败',value:date(item.lastFailureAt)},
    {key:'failureCount',label:'失败次数',value:String(item.failureCount??0)},
    {key:'responseTimeMs',label:'响应耗时',value:item.responseTimeMs==null?'—':String(item.responseTimeMs)+' ms'},
    {key:'lastError',label:'最近错误',value:text(item.lastError)||'—'},
    {key:'remark',label:'接入说明',value:text(item.remark)||'—'}
  ];
}
watch([keyword,ssoStatus,todoStatus,messageStatus,pageSize],()=>{page.value=1;});
watch(()=>filtered.value.length,()=>{page.value=Math.min(page.value,Math.max(1,Math.ceil(filtered.value.length/pageSize.value)));});
</script>
