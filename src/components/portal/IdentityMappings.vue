<template>
 <section class="portal-list identity-mappings">
  <t-form layout="inline" class="portal-query list-toolbar">
   <t-form-item class="portal-query-keyword query-width-keyword" label="关键词"><t-input v-model="keyword" placeholder="姓名 / 帐号 / 单位 / 系统名称" clearable/></t-form-item>
   <t-form-item class="portal-query-select query-width-user-type" label="用户类别"><t-select v-model="userTypeFilter" clearable placeholder="全部" :options="userTypeOptions"/></t-form-item>
   <t-form-item class="portal-query-select query-width-user-type" label="身份来源"><t-select v-model="sourceFilter" clearable placeholder="全部" :options="sourceOptions"/></t-form-item>
   <t-form-item class="portal-query-select query-width-status" label="映射情况"><t-select v-model="mappingFilter" clearable placeholder="全部" :options="mappingOptions"/></t-form-item>
   <t-form-item class="portal-query-action"><t-button class="query-reset-button" theme="default" variant="outline" @click="resetFilters">重置</t-button></t-form-item>
  </t-form>
  <section class="panel portal-table-panel">
   <t-table row-key="user.id" :data="paged" :columns="columns" hover table-layout="fixed" size="medium">
    <template #empty><EmptyState description="暂无符合条件的用户"/></template>
    <template #serial="{rowIndex}">{{(page-1)*pageSize+rowIndex+1}}</template>
    <template #name="{row}"><button class="portal-field-link" @click="selectedId=row.user.id">{{text(row.user.name)||'—'}}</button></template>
    <template #operation="{row}"><t-button size="small" variant="text" theme="primary" @click="selectedId=row.user.id">查看映射</t-button></template>
   </t-table>
   <t-pagination v-model="page" v-model:page-size="pageSize" :total="filtered.length" :page-size-options="[10,20,50]" show-jumper/>
  </section>
  <t-dialog class="identity-mappings-dialog" :visible="!!selected" placement="center" :header="`${text(selected?.user.name)||'用户'} · 子系统账号映射`" width="min(1180px, calc(100vw - 48px))" :footer="false" @update:visible="closeDialog">
   <template v-if="selected">
    <DetailGrid :items="identityDetails"/>
    <div class="identity-mappings-summary"><span>已关联 {{selected.boundCount??0}} 个</span><span>异常 {{selected.exceptionCount??0}} 个</span></div>
    <t-table row-key="id" :data="selected.mappings||[]" :columns="mappingColumns" hover table-layout="fixed" size="medium">
     <template #empty><EmptyState description="该用户暂无子系统账号映射"/></template>
     <template #operation="{row}"><div class="row-actions">
      <t-button v-if="canManage&&row.status==='BOUND'" size="small" variant="text" theme="primary" @click="$emit('unbind',row)">解绑</t-button>
      <t-button v-if="canManage&&row.status==='CONFLICT'" size="small" variant="text" theme="primary" @click="$emit('resolve',row)">处理冲突</t-button>
      <span v-if="!canManage||!['BOUND','CONFLICT'].includes(row.status)" class="muted">—</span>
     </div></template>
    </t-table>
   </template>
  </t-dialog>
 </section>
</template>

<script setup>
import {computed,h,ref,watch} from 'vue';
import {Tag} from 'tdesign-vue-next';
import EmptyState from './EmptyState.vue';
import DetailGrid from './DetailGrid.vue';
import {text,label,date,theme} from './presentation.js';

const props=defineProps({rows:{type:Array,default:()=>[]},canManage:Boolean,exceptionsOnly:Boolean});
defineEmits(['unbind','resolve']);
const keyword=ref(''),userTypeFilter=ref(''),sourceFilter=ref(''),mappingFilter=ref(props.exceptionsOnly?'exception':''),page=ref(1),pageSize=ref(10),selectedId=ref(null);
const userTypeOptions=[{value:'CITIZEN',label:'公众用户'},{value:'GOV',label:'政务用户'}];
const sourceOptions=[{value:'闽政通',label:'闽政通'},{value:'闽政务',label:'闽政务'}];
const mappingOptions=[{value:'bound',label:'已关联'},{value:'exception',label:'存在异常'},{value:'none',label:'未关联'}];
const identitySource=user=>text(user.source)||({CITIZEN:'闽政通',GOV:'闽政务'}[user.userType]||'—');
const filtered=computed(()=>props.rows.filter(row=>{
 const term=keyword.value.trim().toLowerCase(),user=row.user||{};
 const matchesMapping=!mappingFilter.value||({bound:row.boundCount>0,exception:row.exceptionCount>0,none:row.boundCount===0}[mappingFilter.value]);
 const values=[user.id,user.name,user.account,user.orgName,...(row.mappings||[]).flatMap(mapping=>[mapping.appName,mapping.externalAccount])];
 return matchesMapping&&(!userTypeFilter.value||user.userType===userTypeFilter.value)&&(!sourceFilter.value||identitySource(user)===sourceFilter.value)&&(!term||values.some(value=>text(value).toLowerCase().includes(term)));
}));
const paged=computed(()=>filtered.value.slice((page.value-1)*pageSize.value,page.value*pageSize.value));
const selected=computed(()=>props.rows.find(row=>row.user.id===selectedId.value)||null);
const identityDetails=computed(()=>{
 const user=selected.value?.user||{};
 return [['id','统一身份标识'],['name','姓名'],['account','帐号'],['orgName','所属单位'],['userType','用户类别'],['status','启用状态']].map(([key,title])=>({key,label:title,value:label(user[key])})).concat({key:'source',label:'身份来源',value:identitySource(user)});
});
const userColumn=(key,title,width)=>({colKey:key,title,width,ellipsis:true,cell:(_,context)=>label(context.row.user[key])});
const statusCell=value=>h(Tag,{theme:theme(value),variant:'light'},()=>label(value));
const columns=[
 {colKey:'serial',title:'序号',width:64},{colKey:'name',title:'姓名',width:130},
 userColumn('account','帐号',180),userColumn('orgName','所属单位',220),userColumn('userType','用户类别',110),
 {colKey:'source',title:'身份来源',width:100,cell:(_,context)=>identitySource(context.row.user)},
 {colKey:'status',title:'启用状态',width:100,cell:(_,context)=>statusCell(context.row.user.status)},
 {colKey:'boundCount',title:'已关联系统',width:110},{colKey:'exceptionCount',title:'异常映射',width:100},
 {colKey:'operation',title:'操作',width:110,fixed:'right'}
];
const mappingColumns=[
 {colKey:'appName',title:'系统名称',width:240,ellipsis:true},
 {colKey:'externalAccount',title:'子系统账号',width:180,ellipsis:true},
 {colKey:'status',title:'映射状态',width:110,cell:(_,context)=>statusCell(context.row.status)},
 {colKey:'todoCount',title:'待办数量',width:100},{colKey:'messageCount',title:'消息数量',width:100},
 {colKey:'boundAt',title:'关联时间',width:180,cell:(_,context)=>date(context.row.boundAt)},
 {colKey:'operation',title:'操作',width:110,fixed:'right'}
];
function resetFilters(){keyword.value='';userTypeFilter.value='';sourceFilter.value='';mappingFilter.value=props.exceptionsOnly?'exception':'';page.value=1;}
function closeDialog(visible){if(!visible)selectedId.value=null;}
watch([keyword,userTypeFilter,sourceFilter,mappingFilter,pageSize],()=>{page.value=1;});
watch(()=>filtered.value.length,()=>{page.value=Math.min(page.value,Math.max(1,Math.ceil(filtered.value.length/pageSize.value)));});
</script>
