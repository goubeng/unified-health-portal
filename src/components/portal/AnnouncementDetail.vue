<template>
  <section class="portal-announcement-detail-page">
    <article v-if="record" class="portal-announcement-article">
      <header class="portal-announcement-header">
        <h2>{{ text(record.title) }}</h2>
        <div class="portal-announcement-meta-inline">
          <span><Icon name="notification"/><em>公告类型</em><strong>{{ text(record.type || '通知') }}</strong></span>
          <span><Icon name="user"/><em>发布范围</em><strong>{{ label(record.scope || 'ALL') }}</strong></span>
          <span><Icon name="time"/><em>发布时间</em><strong>{{ date(record.publishedAt || record.createdAt) }}</strong></span>
        </div>
        <div class="portal-announcement-divider"></div>
      </header>

      <div class="portal-announcement-body portal-rich-content" v-html="richText(record.content)"></div>

      <section v-if="record.attachments?.length" class="portal-announcement-attachments">
        <h3>附件材料（{{ record.attachments.length }}）</h3>
        <div class="portal-announcement-attachment-list">
          <div v-for="file in record.attachments" :key="file.id || file.name" class="portal-announcement-attachment-row">
            <div class="portal-announcement-file-info">
              <Icon name="file"/>
              <div><strong>{{ text(file.name) }}</strong><span>{{ fileSize(file.size) }}</span></div>
            </div>
            <t-button size="small" variant="text" theme="primary" @click="$emit('download',file)">下载附件</t-button>
          </div>
        </div>
      </section>
      <div v-else class="portal-announcement-no-attachment"><span>附件</span><strong>无附件</strong></div>
    </article>
  </section>
</template>
<script setup>
import {Icon} from 'tdesign-icons-vue-next';
import {text,label,date,richText} from './presentation.js';
defineProps({record:{type:Object,default:null}});
defineEmits(['download']);
const fileSize=value=>{
 const size=Number(value||0);
 if(!size)return '附件';
 if(size<1024)return `${size} B`;
 if(size<1024*1024)return `${(size/1024).toFixed(1)} KB`;
 return `${(size/1024/1024).toFixed(1)} MB`;
};
</script>
