<template>
  <div class="login-shell">
    <div class="login-brand">卫健XC统一门户系统</div>
    <section class="login-card auth-result-card" :class="'is-'+result.theme">
      <div class="auth-result-symbol" aria-hidden="true">{{result.symbol}}</div>
      <h2>{{result.title}}</h2>
      <p class="auth-result-description">{{result.description}}</p>

      <dl class="auth-result-meta">
        <div><dt>认证来源</dt><dd>{{sourceText}}</dd></div>
        <div><dt>结果状态</dt><dd>{{result.statusText}}</dd></div>
        <div v-if="requestId"><dt>请求ID</dt><dd>{{requestId}}</dd></div>
      </dl>

      <div class="auth-result-actions">
        <t-button v-if="showSecondary" variant="outline" @click="secondaryAction">{{secondaryText}}</t-button>
        <t-button theme="primary" @click="primaryAction">{{primaryText}}</t-button>
      </div>
    </section>
  </div>
</template>

<script setup>
import {computed} from 'vue';
import {useRoute,useRouter} from 'vue-router';
import {actor} from '../services/runtime.js';

const route=useRoute(),router=useRouter();

const resultMap={
  SUCCESS:{
    title:'认证成功',description:'身份认证已完成，正在进入统一门户。',statusText:'成功',theme:'success',symbol:'✓'
  },
  FAILURE:{
    title:'认证失败',description:'本次身份认证未通过，请返回登录页重新发起认证。',statusText:'失败',theme:'error',symbol:'×'
  },
  DISABLED:{
    title:'账号已停用',description:'当前门户账号已停用，暂不能继续访问。请联系门户管理员核实账号状态。',statusText:'账号停用',theme:'warning',symbol:'!'
  },
  LOCKED:{
    title:'账号已锁定',description:'当前门户账号处于锁定状态，暂不能登录。请联系门户管理员处理或稍后重试。',statusText:'账号锁定',theme:'warning',symbol:'!'
  },
  NO_PERMISSION:{
    title:'无管理权限',description:'身份认证已完成，但当前账号没有平台管理端权限。可返回用户端继续使用门户服务。',statusText:'无管理权限',theme:'warning',symbol:'!'
  },
  UPSTREAM_ERROR:{
    title:'外部认证异常',description:'闽政通或闽政务认证服务暂时不可用，请稍后重新发起认证。',statusText:'外部认证异常',theme:'error',symbol:'!'
  },
  SESSION_ERROR:{
    title:'会话建立失败',description:'身份认证结果已返回，但Portal Session未能成功建立，请重新登录。',statusText:'会话建立失败',theme:'error',symbol:'!'
  }
};

const aliases={
  OK:'SUCCESS',SUCCESS:'SUCCESS',
  FAIL:'FAILURE',FAILED:'FAILURE',FAILURE:'FAILURE',
  DISABLED:'DISABLED',ACCOUNT_DISABLED:'DISABLED',
  LOCKED:'LOCKED',ACCOUNT_LOCKED:'LOCKED',
  NO_PERMISSION:'NO_PERMISSION',FORBIDDEN:'NO_PERMISSION',
  UPSTREAM_ERROR:'UPSTREAM_ERROR',AUTH_ERROR:'UPSTREAM_ERROR',
  SESSION_ERROR:'SESSION_ERROR',SESSION_FAILED:'SESSION_ERROR'
};
const status=computed(()=>{
  const raw=String(route.query.status||route.query.result||'SESSION_ERROR').trim().toUpperCase();
  return aliases[raw]||'SESSION_ERROR';
});
const result=computed(()=>resultMap[status.value]);
const requestId=computed(()=>String(route.query.requestId||'').trim());
const sourceText=computed(()=>{
  const source=String(route.query.source||'').trim().toUpperCase();
  return {MINZHENGTONG:'闽政通',MINZHENGWU:'闽政务',PORTAL_LOCAL:'门户本地'}[source]||'-';
});
const target=computed(()=>String(route.query.target||'').toLowerCase());
const primaryText=computed(()=>{
  if(status.value==='SUCCESS')return actor.value?'进入门户':'返回登录';
  if(status.value==='NO_PERMISSION'&&actor.value)return '进入用户端';
  return ['UPSTREAM_ERROR','SESSION_ERROR','FAILURE'].includes(status.value)?'重新登录':'返回登录';
});
const showSecondary=computed(()=>status.value==='SUCCESS'&&Boolean(actor.value));
const secondaryText=computed(()=>target.value==='admin'?'进入用户端':'返回登录');

function resolvedHome(){
  if(!actor.value)return '/login';
  if(target.value==='admin'&&actor.value.kind==='ADMIN')return '/admin/home';
  return '/portal/home';
}
function primaryAction(){
  if(status.value==='SUCCESS')router.replace(resolvedHome());
  else if(status.value==='NO_PERMISSION'&&actor.value)router.replace('/portal/home');
  else router.replace('/login');
}
function secondaryAction(){
  if(target.value==='admin')router.replace('/portal/home');
  else router.replace('/login');
}
</script>
