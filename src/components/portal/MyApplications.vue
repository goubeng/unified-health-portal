<template>
  <section class="panel my-applications">
    <t-tabs v-model="active">
      <t-tab-panel value="APPLICATION_ACCESS" :label="`应用访问申请（${accessRows.length}）`">
        <t-table class="my-applications-table" row-key="id" :data="accessRows" :columns="accessColumns" hover table-layout="fixed" size="medium">
          <template #empty><EmptyState description="暂无应用访问申请"/></template>
          <template #requestNo="{row}"><TableCellTooltip :text="text(row.requestNo)||'-'"><button class="portal-field-link" @click="emit('detail',row)">{{text(row.requestNo)||'-'}}</button></TableCellTooltip></template>
          <template #status="{row}"><t-tag :theme="theme(row.status)" variant="light">{{label(row.status)}}</t-tag></template>
          <template #operation="{row}"><div class="row-actions">
            <t-button size="small" variant="text" theme="primary" @click="emit('detail',row)">查看</t-button>
            <t-button v-if="row.status==='PENDING'" size="small" variant="text" theme="danger" @click="emit('withdraw',row)">撤回</t-button>
            <t-button v-if="row.status==='REJECTED'" size="small" variant="text" theme="primary" @click="emit('reapply',row)">重新申请</t-button>
            <t-button v-if="row.status==='APPROVED'&&row.postGrantMode==='DIRECT'" size="small" variant="text" theme="primary" @click="emit('enter',row)">进入应用</t-button>
            <t-button v-if="row.status==='APPROVED'&&row.postGrantMode==='BIND'" size="small" variant="text" theme="primary" @click="emit('bind',row)">完成账号确认</t-button>
          </div></template>
        </t-table>
      </t-tab-panel>
      <t-tab-panel value="ACCOUNT_OPENING" :label="`子系统账号开通申请（${openingRows.length}）`">
        <t-table class="my-applications-table" row-key="id" :data="openingRows" :columns="openingColumns" hover table-layout="fixed" size="medium">
          <template #empty><EmptyState description="暂无子系统账号开通申请"/></template>
          <template #requestNo="{row}"><TableCellTooltip :text="text(row.requestNo)||'-'"><button class="portal-field-link" @click="emit('detail',row)">{{text(row.requestNo)||'-'}}</button></TableCellTooltip></template>
          <template #status="{row}"><t-tag :theme="theme(row.status)" variant="light">{{label(row.status)}}</t-tag></template>
          <template #operation="{row}"><div class="row-actions">
            <t-button size="small" variant="text" theme="primary" @click="emit('detail',row)">查看</t-button>
            <t-button v-if="row.status==='COMPLETED'" size="small" variant="text" theme="primary" @click="emit('bind',row)">去关联</t-button>
          </div></template>
        </t-table>
      </t-tab-panel>
    </t-tabs>
  </section>
</template>

<script setup>
import {computed,ref,h} from 'vue';
import {Tag} from 'tdesign-vue-next';
import EmptyState from './EmptyState.vue';
import TableCellTooltip from './TableCellTooltip.vue';
import {text,label,date,theme} from './presentation.js';

const props=defineProps({rows:{type:Array,default:()=>[]}});
const emit=defineEmits(['withdraw','reapply','bind','enter','detail']);
const active=ref('APPLICATION_ACCESS');
const accessRows=computed(()=>props.rows.filter(row=>row.requestType==='APPLICATION_ACCESS'));
const openingRows=computed(()=>props.rows.filter(row=>row.requestType==='ACCOUNT_OPENING'));
const statusCell=row=>h(Tag,{theme:theme(row.status),variant:'light'},()=>label(row.status));

const accessColumns=[
 {colKey:'requestNo',title:'申请编号',width:190,ellipsis:true},
 {colKey:'appName',title:'应用名称',minWidth:240,ellipsis:true},
 {colKey:'submittedAt',title:'申请时间',width:180,cell:(_,ctx)=>date(ctx.row.submittedAt)},
 {colKey:'status',title:'申请状态',width:110},
 {colKey:'reviewNote',title:'审核意见',minWidth:220,ellipsis:true,cell:(_,ctx)=>h(TableCellTooltip,{text:text(ctx.row.reviewNote)||'-'},()=>text(ctx.row.reviewNote)||'-')},
 {colKey:'operation',title:'操作',width:240,fixed:'right'}
];
const openingColumns=[
 {colKey:'requestNo',title:'申请编号',width:190,ellipsis:true},
 {colKey:'appName',title:'应用名称',minWidth:240,ellipsis:true},
 {colKey:'submittedAt',title:'申请时间',width:180,cell:(_,ctx)=>date(ctx.row.submittedAt)},
 {colKey:'status',title:'处理状态',width:110},
 {colKey:'handleNote',title:'处理说明',minWidth:240,ellipsis:true,cell:(_,ctx)=>h(TableCellTooltip,{text:text(ctx.row.handleNote)||'-'},()=>text(ctx.row.handleNote)||'-')},
 {colKey:'operation',title:'操作',width:160,fixed:'right'}
];
</script>
