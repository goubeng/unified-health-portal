<template>
  <div class="portal-app-grid">
    <article v-for="(app,index) in apps" :key="app.id" class="portal-app-card" :class="[`tone-${index%4+1}`,compact?'is-compact':'']">
      <span class="portal-app-logo"><Icon name="application"/></span>
      <div class="portal-app-info">
        <button class="portal-app-name" :title="text(app.name)" @click="emit('detail',app)">{{text(app.name)}}</button>
        <div class="portal-app-meta">
          <span class="portal-app-category" :title="text(app.category)">{{text(app.category)||'未分类'}}</span>
          <span v-if="app.applicable===false" class="portal-app-restriction">仅限{{label(app.userType)}}</span>
          <template v-else>
            <t-tag v-if="showState(app)" size="small" variant="light" :theme="stateTheme(app.accessState)">{{stateText(app)}}</t-tag>
            <t-button v-if="buttonText(app)" class="portal-app-enter" variant="text" size="small" :disabled="buttonDisabled(app)" @click="trigger(app)">{{buttonText(app)}}</t-button>
          </template>
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

const props=defineProps({apps:{type:Array,default:()=>[]},compact:Boolean,hideNormalState:Boolean});
const emit=defineEmits(['detail','enter','bind','request','view-request','view-binding','view-conflict']);

function showState(app){if(!app.accessState||app.accessState==='DIRECT')return false;if(props.hideNormalState&&app.accessState==='BOUND')return false;return true;}
function stateText(app){
 if(app.accessState==='BOUND')return '已关联';
 if(app.accessState==='UNBOUND')return '未关联';
 if(app.accessState==='VERIFYING')return '验证中';
 if(app.accessState==='REVIEWING')return '待审核';
 if(app.accessState==='FAILED')return app.externalAccountStatus==='DISABLED'?'账号停用':'关联失败';
 if(app.accessState==='CONFLICT')return '关联异常';
 if(app.accessState==='REQUEST_REQUIRED')return '未申请';
 if(app.accessState==='REQUEST_PENDING')return '审核中';
 if(app.accessState==='REQUEST_REJECTED')return '已驳回';
 return label(app.accessState);
}
function stateTheme(state){
 if(['BOUND'].includes(state))return 'success';
 if(['CONFLICT','FAILED','APP_DISABLED'].includes(state))return 'danger';
 if(['VERIFYING','REVIEWING','REQUEST_PENDING'].includes(state))return 'warning';
 return 'default';
}
function buttonText(app){
 return {
  ENTER:'进入应用',
  BIND:'关联账号',
  CONTINUE_BIND:'继续验证',
  VIEW_BINDING:'查看进度',
  VIEW_CONFLICT:'查看异常',
  REQUEST:'申请使用',
  VIEW_REQUEST:'查看申请'
 }[app.primaryAction]||'';
}
function buttonDisabled(app){
 if(app.status!=='ENABLED')return true;
 if(app.primaryAction==='ENTER'&&app.runtimeStatus!=='NORMAL')return true;
 return false;
}
function trigger(app){
 const events={ENTER:'enter',BIND:'bind',CONTINUE_BIND:'bind',VIEW_BINDING:'view-binding',VIEW_CONFLICT:'view-conflict',REQUEST:'request',VIEW_REQUEST:'view-request'};
 const event=events[app.primaryAction];if(event)emit(event,app);
}
</script>
