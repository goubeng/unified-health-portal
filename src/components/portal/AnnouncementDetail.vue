<template>
  <section class="portal-announcement-detail-page">
    <article v-if="record" class="portal-announcement-article">
      <header class="portal-announcement-header">
        <h2>{{ text(record.title) }}</h2>
        <div class="portal-announcement-meta-inline">
          <span><Icon name="notification"/><em>公告类型</em><strong>{{ text(record.type || '通知') }}</strong></span>
          <span><Icon name="user"/><em>发布范围</em><strong>{{ label(record.scope || 'ALL','announcement_scope') }}</strong></span>
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
              <Icon :name="fileIcon(file)" :class="['portal-announcement-file-icon','is-'+fileKind(file)]"/>
              <div class="portal-announcement-file-text">
                <div class="portal-announcement-file-name-line">
                  <strong>{{ text(file.name) }}</strong>
                  <t-tooltip content="下载附件">
                    <t-button class="portal-announcement-download" size="small" variant="text" theme="primary" :aria-label="'下载'+text(file.name)" @click="$emit('download',file)">
                      <Icon name="download"/>
                    </t-button>
                  </t-tooltip>
                </div>
                <span>{{ fileSize(file.size) }}</span>
              </div>
            </div>
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
const fileKind=file=>{
 const name=String(file?.name||'').toLowerCase();
 const ext=name.includes('.')?name.split('.').pop():'';
 const mime=String(file?.type||'').toLowerCase();
 if(ext==='pdf'||mime.includes('pdf'))return 'pdf';
 if(['jpg','jpeg','png','gif','bmp','webp','svg'].includes(ext)||mime.startsWith('image/'))return 'image';
 if(['doc','docx'].includes(ext)||mime.includes('word'))return 'word';
 if(['xls','xlsx','csv'].includes(ext)||mime.includes('excel')||mime.includes('spreadsheet'))return 'excel';
 return 'file';
};
const fileIcon=file=>({pdf:'file-pdf',image:'image',word:'file-word',excel:'file-excel'}[fileKind(file)]||'file');
const fileSize=value=>{
 const size=Number(value||0);
 if(!size)return '附件';
 if(size<1024)return `${size} B`;
 if(size<1024*1024)return `${(size/1024).toFixed(1)} KB`;
 return `${(size/1024/1024).toFixed(1)} MB`;
};
</script>
