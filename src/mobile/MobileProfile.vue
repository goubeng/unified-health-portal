<template>
  <section class="mobile-profile">
    <div class="mobile-profile-hero"><span class="mobile-profile-avatar">{{ text(profile?.name||actor?.name).slice(0,1)||'我' }}</span><div><h1>{{ text(profile?.name||actor?.name)||'当前用户' }}</h1><p>{{ text(profile?.orgName||actor?.orgName)||'统一门户' }}</p></div></div>
    <p v-if="error" class="mobile-profile-error" role="alert">{{ error }}</p>
    <section class="mobile-profile-card"><h2>我的服务</h2><button class="mobile-profile-link" type="button" @click="router.push('/m/applications')"><span>我的申请</span><ChevronRightIcon class="mobile-profile-link-arrow" /></button></section>
    <section class="mobile-profile-card"><h2>个人资料</h2><dl><div><dt>登录账号</dt><dd>{{ text(profile?.account||actor?.account)||'-' }}</dd></div><div><dt>身份来源</dt><dd>{{ source(profile||actor) }}</dd></div><div><dt>用户类别</dt><dd>{{ label(profile?.userType||actor?.userType) }}</dd></div><div><dt>姓名</dt><dd>{{ text(profile?.name||actor?.name)||'-' }}</dd></div><div><dt>所属单位</dt><dd>{{ text(profile?.orgName||actor?.orgName)||'-' }}</dd></div><div><dt>手机号</dt><dd>{{ text(profile?.phone||actor?.phone)||'-' }}</dd></div><div><dt>邮箱</dt><dd>{{ text(profile?.email||actor?.email)||'-' }}</dd></div></dl></section>
    <TMobileButton block shape="round" variant="outline" theme="danger" :loading="exiting" @click="exit">退出登录</TMobileButton>
  </section>
</template>

<script setup lang="ts">
import {onMounted,ref,watch} from 'vue';
import {useRouter} from 'vue-router';
import {Button as TMobileButton} from 'tdesign-mobile-vue';
import {ChevronRightIcon} from 'tdesign-icons-vue-next';
import {logout,portal,revision} from '../services/runtime.js';
import {mobileActor as actor} from './mobileActor';
import {label,source,text} from '../components/portal/presentation.js';

interface Profile {name?:string;account?:string;orgName?:string;userType?:string;identitySource?:string;authType?:string;phone?:string;email?:string}
const router=useRouter(),profile=ref<Profile|null>(null),error=ref(''),exiting=ref(false);
let requestVersion=0;
async function load(){const version=++requestVersion;const result=await portal.read('profile');if(version!==requestVersion)return;profile.value=result.ok?result.data:null;error.value=result.ok?'':text(result.error?.message);}
async function exit(){if(exiting.value)return;exiting.value=true;error.value='';try{await logout();window.location.assign('/login?redirect=%2Fm%2Fhome');}catch(cause){error.value=text(cause instanceof Error?cause.message:String(cause));}finally{exiting.value=false;}}
onMounted(load);
watch(revision,load);
</script>

<style scoped src="./mobile-profile.css"></style>
