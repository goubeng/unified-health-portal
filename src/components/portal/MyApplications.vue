<template>
  <section class="panel my-applications">
    <t-tabs v-model="active">
      <t-tab-panel value="APPLICATION_ACCESS" :label="`应用访问申请（${accessRows.length}）`">
        <t-table class="my-applications-table" row-key="id" :data="pagedAccessRows" :columns="accessColumns" hover table-layout="fixed" size="medium">
          <template #empty><EmptyState description="暂无应用访问申请"/></template>
          <template #requestNo="{row}"><TableCellTooltip :text="text(row.requestNo)||'-'"><button class="portal-field-link" @click="emit('detail',row)">{{text(row.requestNo)||'-'}}</button></TableCellTooltip></template>
          <template #status="{row}"><t-tag :theme="theme(row.status)" variant="light">{{label(row.status)}}</t-tag></template>
          <template #operation="{row}"><div class="row-actions">
            <t-button v-if="row.status==='PENDING'" size="small" variant="text" theme="danger" @click="emit('withdraw',row)">撤回</t-button>
            <t-button v-if="row.status==='REJECTED'" size="small" variant="text" theme="primary" @click="emit('reapply',row)">重新申请</t-button>
            <t-button v-if="row.status==='APPROVED'&&row.postGrantMode==='DIRECT'" size="small" variant="text" theme="primary" @click="emit('enter',row)">进入应用</t-button>
            <t-button v-if="row.status==='APPROVED'&&row.postGrantMode==='BIND'" size="small" variant="text" theme="primary" @click="emit('bind',row)">完成账号确认</t-button>
          </div></template>
        </t-table>
        <t-pagination
          v-if="accessRows.length"
          v-model="accessPage"
          v-model:page-size="accessPageSize"
          :total="accessRows.length"
          :page-size-options="[10,20,50]"
          show-jumper
        />
      </t-tab-panel>
      <t-tab-panel value="ACCOUNT_OPENING" :label="`子系统账号开通申请（${openingRows.length}）`">
        <t-table class="my-applications-table" row-key="id" :data="pagedOpeningRows" :columns="openingColumns" hover table-layout="fixed" size="medium">
          <template #empty><EmptyState description="暂无子系统账号开通申请"/></template>
          <template #requestNo="{row}"><TableCellTooltip :text="text(row.requestNo)||'-'"><button class="portal-field-link" @click="emit('detail',row)">{{text(row.requestNo)||'-'}}</button></TableCellTooltip></template>
          <template #status="{row}"><t-tag :theme="theme(row.status)" variant="light">{{label(row.status)}}</t-tag></template>
          <template #operation="{row}"><div class="row-actions">
            <t-button v-if="row.status==='COMPLETED'" size="small" variant="text" theme="primary" @click="emit('bind',row)">去关联</t-button>
          </div></template>
        </t-table>
        <t-pagination
          v-if="openingRows.length"
          v-model="openingPage"
          v-model:page-size="openingPageSize"
          :total="openingRows.length"
          :page-size-options="[10,20,50]"
          show-jumper
        />
      </t-tab-panel>
    </t-tabs>
  </section>
</template>

<script setup>
import {computed,ref,h,watch} from 'vue';
import {Tag} from 'tdesign-vue-next';
import EmptyState from './EmptyState.vue';
import TableCellTooltip from './TableCellTooltip.vue';
import {text,label,date,theme} from './presentation.js';

const props=defineProps({rows:{type:Array,default:()=>[]}});
const emit=defineEmits(['withdraw','reapply','bind','enter','detail']);
const active=ref('APPLICATION_ACCESS');
const accessRows=computed(()=>props.rows.filter(row=>row.requestType==='APPLICATION_ACCESS'));
const openingRows=computed(()=>props.rows.filter(row=>row.requestType==='ACCOUNT_OPENING'));
const accessPage=ref(1),accessPageSize=ref(10);
const openingPage=ref(1),openingPageSize=ref(10);
const pagedAccessRows=computed(()=>accessRows.value.slice((accessPage.value-1)*accessPageSize.value,accessPage.value*accessPageSize.value));
const pagedOpeningRows=computed(()=>openingRows.value.slice((openingPage.value-1)*openingPageSize.value,openingPage.value*openingPageSize.value));
watch(accessPageSize,()=>{accessPage.value=1;});
watch(openingPageSize,()=>{openingPage.value=1;});
watch(()=>accessRows.value.length,()=>{accessPage.value=Math.min(accessPage.value,Math.max(1,Math.ceil(accessRows.value.length/accessPageSize.value)));});
watch(()=>openingRows.value.length,()=>{openingPage.value=Math.min(openingPage.value,Math.max(1,Math.ceil(openingRows.value.length/openingPageSize.value)));});
const statusCell=row=>h(Tag,{theme:theme(row.status),variant:'light'},()=>label(row.status));

const accessColumns=[
 {colKey:'serial',title:'序号',width:64,cell:(_,ctx)=>(accessPage.value-1)*accessPageSize.value+ctx.rowIndex+1},
 {colKey:'requestNo',title:'申请编号',width:190,ellipsis:true},
 {colKey:'appName',title:'应用名称',minWidth:240,ellipsis:true},
 {colKey:'submittedAt',title:'申请时间',width:180,cell:(_,ctx)=>date(ctx.row.submittedAt)},
 {colKey:'status',title:'申请状态',width:110},
 {colKey:'reviewNote',title:'审核意见',minWidth:220,ellipsis:true,cell:(_,ctx)=>h(TableCellTooltip,{text:text(ctx.row.reviewNote)||'-'},()=>text(ctx.row.reviewNote)||'-')},
 {colKey:'operation',title:'操作',width:150,fixed:'right'}
];
const openingColumns=[
 {colKey:'serial',title:'序号',width:64,cell:(_,ctx)=>(openingPage.value-1)*openingPageSize.value+ctx.rowIndex+1},
 {colKey:'requestNo',title:'申请编号',width:190,ellipsis:true},
 {colKey:'appName',title:'应用名称',minWidth:240,ellipsis:true},
 {colKey:'submittedAt',title:'申请时间',width:180,cell:(_,ctx)=>date(ctx.row.submittedAt)},
 {colKey:'status',title:'处理状态',width:110},
 {colKey:'handleNote',title:'处理说明',minWidth:240,ellipsis:true,cell:(_,ctx)=>h(TableCellTooltip,{text:text(ctx.row.handleNote)||'-'},()=>text(ctx.row.handleNote)||'-')},
 {colKey:'operation',title:'操作',width:110,fixed:'right'}
];
</script>
