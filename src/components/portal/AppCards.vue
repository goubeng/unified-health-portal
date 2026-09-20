<template>
  <div class="portal-app-grid">
    <article v-for="(app,index) in apps" :key="app.id" class="portal-app-card" :class="[`tone-${index%4+1}`,compact?'is-compact':'']">
      <span class="portal-app-logo"><Icon name="application"/></span>
      <div class="portal-app-info">
        <button class="portal-app-name" :title="text(app.name)" @click="$emit('detail',app)">{{text(app.name)}}</button>
        <div class="portal-app-meta">
          <span class="portal-app-category" :title="text(app.category)">{{text(app.category)||'未分类'}}</span>
          <span v-if="app.applicable===false" class="portal-app-restriction">仅限{{label(app.userType)}}</span>
          <t-button v-else-if="app.mappingStatus==='BOUND'" class="portal-app-enter" variant="text" size="small" :disabled="app.status!=='ENABLED'||app.runtimeStatus!=='NORMAL'" @click="$emit('enter',app)">进入</t-button>
          <t-button v-else class="portal-app-enter" variant="text" size="small" :disabled="app.status!=='ENABLED'" @click="$emit('bind',app)">关联</t-button>
        </div>
      </div>
    </article>
  </div>
  <EmptyState v-if="!apps.length" description="暂无应用"/>
</template>
<script setup>
import EmptyState from './EmptyState.vue';
import {Icon} from 'tdesign-icons-vue-next';
import {text,label} from './presentation.js';
defineProps({apps:{type:Array,default:()=>[]},compact:Boolean});
defineEmits(['detail','enter','bind']);
</script>
