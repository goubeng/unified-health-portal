<template>
  <div class="portal-app-grid">
    <article v-for="(app,index) in apps" :key="app.id" class="portal-app-card" :class="[`tone-${index%4+1}`,compact?'is-compact':'']">
      <span class="portal-app-logo"><Icon name="application"/></span>
      <div class="portal-app-info">
        <PortalTooltip :content="text(app.name)" placement="top"><button class="portal-app-name" @click="emit('detail',app)">{{text(app.name)}}</button></PortalTooltip>
        <div class="portal-app-meta">
          <PortalTooltip :content="text(app.category)||'未分类'" placement="top"><span class="portal-app-category" :class="categoryTone(app.category)">{{text(app.category)||'未分类'}}</span></PortalTooltip>
        </div>
        <div class="portal-app-result">
          <span v-if="app.applicable===false" class="portal-app-restriction">仅限{{label(app.userType)}}</span>
          <template v-else>
            <t-tag v-if="showState(app)" class="portal-app-status-tag" size="small" variant="light" :theme="stateTheme(app.accessState)">{{stateText(app)}}</t-tag>
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
import PortalTooltip from './PortalTooltip.vue';
import {Icon} from 'tdesign-icons-vue-next';
import {text,label} from './presentation.js';

const props=defineProps({apps:{type:Array,default:()=>[]},compact:Boolean,hideNormalState:Boolean});
const emit=defineEmits(['detail','enter','bind','request','view-request','view-binding','view-conflict']);

function categoryTone(category){
 const value=text(category)||'未分类';
 let hash=0;
 for(const char of value)hash=(hash+char.codePointAt(0))%5;
 return 'category-tone-'+(hash+1);
}
function showState(app){if(!app.accessState||app.accessState==='DIRECT')return false;if(props.hideNormalState&&app.accessState==='BOUND')return false;return true;}
function stateText(app){
 if(app.accessState==='BOUND')return '已关联';
 if(app.accessState==='UNBOUND')return '需确认账号';
 if(app.accessState==='VERIFYING')return '待继续处理';
 if(app.accessState==='REVIEWING')return '处理中';
 if(app.accessState==='FAILED')return app.externalAccountStatus==='DISABLED'?'账号不可用':'处理失败';
 if(app.accessState==='CONFLICT')return '账号异常';
 if(app.accessState==='REQUEST_REQUIRED')return '待申请';
 if(app.accessState==='REQUEST_PENDING')return '申请处理中';
 if(app.accessState==='REQUEST_REJECTED')return '申请未通过';
 return label(app.accessState);
}
function stateTheme(state){
 if(['BOUND'].includes(state))return 'success';
 if(['CONFLICT','FAILED','APP_DISABLED','REQUEST_REJECTED'].includes(state))return 'danger';
 if(['VERIFYING','REVIEWING','REQUEST_PENDING'].includes(state))return 'warning';
 return 'default';
}
function buttonText(app){
 if(app.accessState==='REQUEST_REJECTED')return '查看原因';
 return {
  ENTER:'进入应用',
  BIND:'申请使用',
  CONTINUE_BIND:'继续处理',
  VIEW_BINDING:'查看进度',
  VIEW_REASON:'查看原因',
  VIEW_CONFLICT:'查看原因',
  RETRY_BIND:'重新处理',
  REQUEST:'申请使用',
  VIEW_REQUEST:'查看申请'
 }[app.primaryAction]||'';
}
function buttonDisabled(app){
 if(app.enabled===false)return true;
 if(app.primaryAction==='ENTER'&&app.ssoRuntimeStatus!=='NORMAL')return true;
 return false;
}
function trigger(app){
 const events={ENTER:'enter',BIND:'bind',CONTINUE_BIND:'bind',RETRY_BIND:'bind',VIEW_BINDING:'view-binding',VIEW_REASON:'view-binding',VIEW_CONFLICT:'view-conflict',REQUEST:'request',VIEW_REQUEST:'view-request'};
 const event=events[app.primaryAction];if(event)emit(event,app);
}
</script>