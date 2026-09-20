<template>
  <section class="panel portal-profile">
    <aside class="portal-profile-sidebar"><span class="portal-profile-avatar">{{text(user.name).slice(0,1)}}</span><h2>{{text(user.name)}}</h2><p v-if="showOrganization">{{text(user.orgName)}}</p><t-tag theme="primary" variant="light">{{label(user.userType)}}</t-tag></aside>
    <div class="portal-profile-content"><h3>账号信息</h3><DetailGrid :items="accountItems"><template #userType="{item}"><t-tag theme="primary" variant="light" size="small">{{item.value}}</t-tag></template></DetailGrid><h3>个人资料</h3><DetailGrid :items="personalItems"/><p class="muted">个人身份资料由{{source(user)}}提供。如需更新，请前往对应平台维护。</p></div>
  </section>
</template>
<script setup>
import {computed} from 'vue';
import DetailGrid from './DetailGrid.vue';
import {text,label,source} from './presentation.js';
const props=defineProps({user:{type:Object,required:true}});
const showOrganization=computed(()=>props.user.userType!=='CITIZEN'&&Boolean(text(props.user.orgName)));
const accountItems=computed(()=>[
  {key:'account',label:'登录账号',value:props.user.account||'—'},
  {key:'source',label:'身份来源',value:source(props.user)},
  {key:'userType',label:'用户类别',value:label(props.user.userType)}
]);
const personalItems=computed(()=>[
  {key:'name',label:'姓名',value:text(props.user.name)},
  ...(showOrganization.value?[{key:'orgName',label:'所属单位',value:text(props.user.orgName)}]:[]),
  {key:'phone',label:'手机号',value:props.user.phone||'—'},
  {key:'email',label:'邮箱',value:props.user.email||'—'}
]);
</script>
