<template>
  <div class="monitor-history-table">
    <t-table row-key="id" :data="paged" :columns="columns" hover table-layout="fixed" size="medium">
      <template #empty><EmptyState description="暂无状态变更记录；既有状态快照不补造历史"/></template>
      <template #occurredAt="{row}">{{date(row.occurredAt)}}</template>
      <template #fromStatus="{row}"><t-tag :theme="theme(row.fromStatus)" variant="light">{{label(row.fromStatus,'runtime_status')}}</t-tag></template>
      <template #toStatus="{row}"><t-tag :theme="theme(row.toStatus)" variant="light">{{label(row.toStatus,'runtime_status')}}</t-tag></template>
      <template #reason="{row}"><TableCellTooltip :text="text(row.reason)||'-'"/></template>
    </t-table>
    <t-pagination v-if="sortedHistory.length>PAGE_SIZE" v-model="page" :page-size="PAGE_SIZE" :total="sortedHistory.length" :page-size-options="[PAGE_SIZE]" show-jumper/>
  </div>
</template>

<script setup>
import {computed,ref,watch} from 'vue';
import EmptyState from './EmptyState.vue';
import TableCellTooltip from './TableCellTooltip.vue';
import {date,label,text,theme} from './presentation.js';

const PAGE_SIZE=10;
const props=defineProps({
  rows:{type:Array,default:()=>[]},
  appId:{type:[String,Number],required:true}
});
const columns=[
  {colKey:'occurredAt',title:'发生时间',width:175},
  {colKey:'kind',title:'接入服务',width:110},
  {colKey:'fromStatus',title:'原状态',width:110},
  {colKey:'toStatus',title:'新状态',width:110},
  {colKey:'reason',title:'原因/说明',minWidth:240,ellipsis:true}
];
const page=ref(1);
const sortedHistory=computed(()=>props.rows
  .filter(row=>String(row.appId)===String(props.appId))
  .slice()
  .sort((a,b)=>(Date.parse(b.occurredAt)||0)-(Date.parse(a.occurredAt)||0)));
const paged=computed(()=>sortedHistory.value.slice((page.value-1)*PAGE_SIZE,page.value*PAGE_SIZE));
watch(()=>props.appId,()=>{page.value=1;});
watch(()=>sortedHistory.value.length,()=>{page.value=Math.min(page.value,Math.max(1,Math.ceil(sortedHistory.value.length/PAGE_SIZE)));});
</script>
