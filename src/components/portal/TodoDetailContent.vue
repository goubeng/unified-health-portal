<template>
  <article v-if="record" class="todo-detail-article">
    <header class="todo-detail-header">
      <h2>{{text(record.title)||'-'}}</h2>
      <div class="todo-detail-meta-inline">
        <span class="todo-detail-meta-item">
          <Icon name="app"/>
          <em>来源应用：</em>
          <PortalTooltip :content="text(record.appName)||'-'" placement="top"><strong>{{text(record.appName)||'-'}}</strong></PortalTooltip>
        </span>
        <span class="todo-detail-meta-item">
          <Icon name="task"/>
          <em>业务类型：</em>
          <PortalTooltip :content="text(record.businessType)||'-'" placement="top"><strong>{{text(record.businessType)||'-'}}</strong></PortalTooltip>
        </span>
        <span class="todo-detail-meta-item">
          <Icon name="time"/>
          <em>接收时间：</em>
          <strong>{{date(record.createdAt)}}</strong>
        </span>
        <span class="todo-detail-meta-item">
          <Icon name="check-circle"/>
          <em>状态：</em>
          <t-tag size="small" variant="light" :theme="statusTheme(record.status)">{{label(record.status)}}</t-tag>
        </span>
      </div>
      <div class="todo-detail-divider"></div>
    </header>

    <section class="todo-detail-body">
      <p>{{text(record.summary)||'-'}}</p>
    </section>
  </article>
</template>

<script setup>
import {Icon} from 'tdesign-icons-vue-next';
import {date,label,text} from './presentation.js';
import PortalTooltip from './PortalTooltip.vue';

defineProps({record:{type:Object,default:null}});

function statusTheme(value){
  return value==='PENDING'?'warning':value==='COMPLETED'?'success':'default';
}
</script>
