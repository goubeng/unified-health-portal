<template>
  <section class="mobile-profile">
    <div class="mobile-profile-hero"><span class="mobile-profile-avatar">{{ text(profile?.name||actor?.name).slice(0,1)||'我' }}</span><div><h1>{{ text(profile?.name||actor?.name)||'当前用户' }}</h1><p>{{ text(profile?.orgName||actor?.orgName)||'统一门户' }}</p></div></div>
    <p v-if="error" class="mobile-profile-error" role="alert">{{ error }}</p>
    <section class="mobile-profile-card"><h2>我的服务</h2><button class="mobile-profile-link" type="button" @click="router.push('/m/applications')"><span>我的申请</span><span aria-hidden="true">›</span></button></section>
    <section class="mobile-profile-card"><h2>个人资料</h2><dl><div><dt>登录账号</dt><dd>{{ text(profile?.account||actor?.account)||'-' }}</dd></div><div><dt>身份来源</dt><dd>{{ source(profile||actor) }}</dd></div><div><dt>用户类别</dt><dd>{{ label(profile?.userType||actor?.userType) }}</dd></div><div><dt>姓名</dt><dd>{{ text(profile?.name||actor?.name)||'-' }}</dd></div><div><dt>所属单位</dt><dd>{{ text(profile?.orgName||actor?.orgName)||'-' }}</dd></div><div><dt>手机号</dt><dd>{{ text(profile?.phone||actor?.phone)||'-' }}</dd></div><div><dt>邮箱</dt><dd>{{ text(profile?.email||actor?.email)||'-' }}</dd></div></dl></section>
    <TMobileButton block variant="outline" theme="default" :loading="exiting" @click="exit">退出登录</TMobileButton>
  </section>
</template>

<script setup lang="ts">
import {onMounted,ref,watch} from 'vue';
import {useRouter} from 'vue-router';
import {Button as TMobileButton} from 'tdesign-mobile-vue';
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

<style scoped>
.mobile-profile{padding:20px 16px 36px;color:#173047}.mobile-profile-hero{display:flex;align-items:center;gap:16px;padding:23px 18px;margin-bottom:18px;border-radius:18px;background:linear-gradient(120deg,#078c93,#42b5b0);color:#fff}.mobile-profile-avatar{display:grid;place-items:center;flex:none;width:58px;height:58px;border-radius:50%;background:#ffffff38;border:2px solid #ffffff88;font-size:25px;font-weight:700}.mobile-profile-hero h1{margin:0;font-size:22px}.mobile-profile-hero p{margin:6px 0 0;font-size:13px;color:#e6fbfa}.mobile-profile-card{margin-bottom:14px;border:1px solid #edf2f4;border-radius:16px;background:#fff;padding:16px 18px;box-shadow:0 5px 18px #164f5b0a}.mobile-profile-card h2{margin:0 0 8px;font-size:16px}.mobile-profile-link{display:flex;justify-content:space-between;align-items:center;width:100%;padding:13px 0;border:0;background:none;color:#2f4e5d;text-align:left;font-size:15px}.mobile-profile-link span:last-child{font-size:24px;color:#9ab0bc}.mobile-profile-card dl{margin:0}.mobile-profile-card dl div{display:flex;justify-content:space-between;gap:12px;padding:12px 0;border-bottom:1px solid #f1f4f5;font-size:14px}.mobile-profile-card dl div:last-child{border-bottom:0}.mobile-profile-card dt{color:#8194a1}.mobile-profile-card dd{margin:0;text-align:right;overflow-wrap:anywhere}.mobile-profile-error{padding:10px 12px;border-radius:8px;background:#fff1ef;color:#ba3e38;font-size:13px}
</style>
