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
    <template #name="{row}"><button class="portal-field-link" @click="selectedId=row.user.id">{{text(row.user.name)||'-'}}</button></template>
    <template #operation="{row}"><t-button size="small" variant="text" theme="primary" @click="selectedId=row.user.id">查看映射</t-button></template>
   </t-table>
   <t-pagination v-model="page" v-model:page-size="pageSize" :total="filtered.length" :page-size-options="[10,20,50]" show-jumper/>
  </section>
  <t-dialog class="identity-mappings-dialog" :visible="!!selected" placement="center" :header="`${text(selected?.user.name)||'用户'} · 子系统账号映射`" width="min(1320px, calc(100vw - 48px))" :footer="false" @update:visible="closeDialog">
   <template v-if="selected">
    <section class="identity-mapping-section">
     <h3 class="identity-mapping-section-title">基本信息</h3>
     <DetailGrid :items="identityDetails"/>
    </section>
    <section class="identity-mapping-section">
     <div class="identity-mapping-section-head">
      <div class="identity-mapping-title-line">
       <h3 class="identity-mapping-section-title">子系统映射</h3>
       <div class="identity-mappings-summary">
        <span class="identity-mapping-summary-item is-bound"><CheckCircleIcon/><span>已关联 <strong>{{selected.boundCount??0}}</strong> 个</span></span>
        <span class="identity-mapping-summary-item is-exception"><ErrorCircleIcon/><span>异常 <strong>{{selected.exceptionCount??0}}</strong> 个</span></span>
       </div>
      </div>
      <t-input v-model="mappingKeyword" class="identity-mapping-search" placeholder="搜索系统名称 / 子系统账号" clearable>
       <template #prefix-icon><SearchIcon/></template>
      </t-input>
     </div>
    <t-table row-key="id" :data="mappingPaged" :columns="mappingColumns" hover table-layout="fixed" size="medium">
     <template #empty><EmptyState description="暂无符合条件的子系统映射"/></template>
     <template #mappingSerial="{rowIndex}">{{(mappingPage-1)*mappingPageSize+rowIndex+1}}</template>
     <template #operation="{row}"><div class="row-actions">
      <t-button v-if="canManage&&row.status==='BOUND'" size="small" variant="text" theme="primary" @click="$emit('unbind',row)">解绑</t-button>
      <t-button v-if="canManage&&row.status==='REVIEWING'" size="small" variant="text" theme="primary" @click="$emit('approve',row)">通过</t-button>
      <t-button v-if="canManage&&row.status==='REVIEWING'" size="small" variant="text" theme="danger" @click="$emit('reject',row)">驳回</t-button>
      <t-button v-if="canManage&&row.status==='CONFLICT'" size="small" variant="text" theme="primary" @click="$emit('resolve',row)">处理冲突</t-button>
      <span v-if="!canManage||!['BOUND','REVIEWING','CONFLICT'].includes(row.status)" class="muted">-</span>
     </div></template>
    </t-table>
    <t-pagination v-if="selectedMappings.length" v-model="mappingPage" v-model:page-size="mappingPageSize" :total="selectedMappings.length" :page-size-options="[5,10,20]" show-jumper/>
    </section>
   </template>
  </t-dialog>
 </section>
</template>

<script setup>
import {computed,h,ref,watch} from 'vue';
import {Tag} from 'tdesign-vue-next';
import {CheckCircleIcon,ErrorCircleIcon,SearchIcon} from 'tdesign-icons-vue-next';
import EmptyState from './EmptyState.vue';
import DetailGrid from './DetailGrid.vue';
import {text,label,date,theme} from './presentation.js';

const props=defineProps({rows:{type:Array,default:()=>[]},canManage:Boolean,exceptionsOnly:Boolean});
defineEmits(['unbind','resolve','approve','reject']);
const keyword=ref(''),userTypeFilter=ref(''),sourceFilter=ref(''),mappingFilter=ref(props.exceptionsOnly?'exception':''),page=ref(1),pageSize=ref(10),selectedId=ref(null),mappingKeyword=ref(''),mappingPage=ref(1),mappingPageSize=ref(10);
const userTypeOptions=[{value:'CITIZEN',label:'公众用户'},{value:'GOV',label:'政务用户'},{value:'LOCAL',label:'门户本地用户'}];
const sourceOptions=[{value:'闽政通',label:'闽政通'},{value:'闽政务',label:'闽政务'},{value:'门户本地',label:'门户本地'}];
const mappingOptions=[{value:'bound',label:'已关联'},{value:'review',label:'待审核'},{value:'exception',label:'存在异常'},{value:'none',label:'未关联'}];
const identitySource=user=>text(user.source)||({CITIZEN:'闽政通',GOV:'闽政务',LOCAL:'门户本地'}[user.userType]||'-');
const filtered=computed(()=>props.rows.filter(row=>{
 const term=keyword.value.trim().toLowerCase(),user=row.user||{};
 const matchesMapping=!mappingFilter.value||({bound:row.boundCount>0,review:(row.reviewCount||0)>0,exception:row.exceptionCount>0,none:row.boundCount===0&&(row.reviewCount||0)===0}[mappingFilter.value]);
 const values=[user.id,user.name,user.account,user.orgName,...(row.mappings||[]).flatMap(mapping=>[mapping.appName,mapping.externalAccount])];
 return matchesMapping&&(!userTypeFilter.value||user.userType===userTypeFilter.value)&&(!sourceFilter.value||identitySource(user)===sourceFilter.value)&&(!term||values.some(value=>text(value).toLowerCase().includes(term)));
}));
const paged=computed(()=>filtered.value.slice((page.value-1)*pageSize.value,page.value*pageSize.value));
const selected=computed(()=>props.rows.find(row=>row.user.id===selectedId.value)||null);
const selectedMappings=computed(()=>{
 const term=mappingKeyword.value.trim().toLowerCase();
 const mappings=selected.value?.mappings||[];
 if(!term)return mappings;
 return mappings.filter(mapping=>[mapping.appName,mapping.externalAccount].some(value=>text(value).toLowerCase().includes(term)));
});
const mappingPaged=computed(()=>selectedMappings.value.slice((mappingPage.value-1)*mappingPageSize.value,mappingPage.value*mappingPageSize.value));
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
 {colKey:'mappingSerial',title:'序号',width:64},
 {colKey:'appName',title:'系统名称',width:220,ellipsis:true},
 {colKey:'externalAccount',title:'子系统账号',width:180,ellipsis:true},
 {colKey:'bindingMethod',title:'关联方式',width:100,cell:(_,context)=>label(context.row.bindingMethod)},
 {colKey:'verificationMethod',title:'验证方式',width:150,cell:(_,context)=>label(context.row.verificationMethod)},
 {colKey:'riskLevel',title:'风险级别',width:100,cell:(_,context)=>label(context.row.riskLevel)},
 {colKey:'status',title:'映射状态',width:110,cell:(_,context)=>statusCell(context.row.status)},
 {colKey:'boundAt',title:'关联时间',width:180,cell:(_,context)=>date(context.row.boundAt)},
 {colKey:'operation',title:'操作',width:150,fixed:'right'}
];
function resetFilters(){keyword.value='';userTypeFilter.value='';sourceFilter.value='';mappingFilter.value=props.exceptionsOnly?'exception':'';page.value=1;}
function closeDialog(visible){if(!visible)selectedId.value=null;}
watch(selectedId,()=>{mappingKeyword.value='';mappingPage.value=1;});
watch(mappingKeyword,()=>{mappingPage.value=1;});
watch(mappingPageSize,()=>{mappingPage.value=1;});
watch(()=>selectedMappings.value.length,()=>{mappingPage.value=Math.min(mappingPage.value,Math.max(1,Math.ceil(selectedMappings.value.length/mappingPageSize.value)));});
watch([keyword,userTypeFilter,sourceFilter,mappingFilter,pageSize],()=>{page.value=1;});
watch(()=>filtered.value.length,()=>{page.value=Math.min(page.value,Math.max(1,Math.ceil(filtered.value.length/pageSize.value)));});
</script>
