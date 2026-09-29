<template>
  <section class="panel portal-profile">
    <aside class="portal-profile-sidebar"><span class="portal-profile-avatar">{{text(user.name).slice(0,1)}}</span><h2>{{text(user.name)}}</h2><p>{{text(user.orgName)||'-'}}</p><t-tag theme="primary" variant="light">{{localAccount?'本地管理账号':label(user.userType)}}</t-tag></aside>
    <div class="portal-profile-content"><h3>账号信息</h3><DetailGrid :items="accountItems"><template #userType="{item}"><t-tag theme="primary" variant="light" size="small">{{item.value}}</t-tag></template></DetailGrid><h3>个人资料</h3><DetailGrid :items="personalItems"/><p class="muted">{{localAccount?'本地管理账号资料由平台管理员维护。':`个人身份资料由${source(user)}提供。如需更新，请前往对应平台维护。`}}</p></div>
  </section>
</template>
<script setup>
import {computed} from 'vue';
import DetailGrid from './DetailGrid.vue';
import {text,label,source} from './presentation.js';
const props=defineProps({user:{type:Object,required:true}});
const localAccount=computed(()=>props.user.authType==='LOCAL');
const accountItems=computed(()=>[
  {key:'account',label:'登录账号',value:props.user.account||'-'},
  {key:'source',label:'身份来源',value:source(props.user)},
  {key:'userType',label:localAccount.value?'账号类型':'用户类别',value:localAccount.value?'本地管理账号':label(props.user.userType)}
]);
const personalItems=computed(()=>[
  {key:'name',label:'姓名',value:text(props.user.name)||'-'},
  {key:'orgName',label:'所属单位',value:text(props.user.orgName)||'-'},
  {key:'phone',label:'手机号',value:props.user.phone||'-'},
  {key:'email',label:'邮箱',value:props.user.email||'-'}
]);
</script>
