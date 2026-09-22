<template>
 <div class="login-shell"><img class="login-bg-image" :src="loginBackground" alt="" aria-hidden="true"/><div class="login-brand">卫健XC统一门户系统</div><div class="login-layout">
  <section class="login-card">
   <div class="login-identity-switch" role="tablist" aria-label="身份切换">
    <button type="button" class="identity-pill" :class="{active:identityType==='CITIZEN'}" @click="selectIdentity('CITIZEN')"><span>公众用户</span></button>
    <button type="button" class="identity-pill" :class="{active:identityType==='GOV'}" @click="selectIdentity('GOV')"><span>政务用户</span></button>
    <button type="button" class="identity-pill" :class="{active:identityType==='LOCAL'}" @click="selectIdentity('LOCAL')"><span>管理账号</span></button>
   </div>
   <div class="demo-login-panel">
    <div class="demo-login-summary">
     <strong>{{ loginTitle }}</strong>
     <span v-if="identityType==='LOCAL'" class="demo-login-account">用户账号：<b>{{ adminAccount }}</b></span>
    </div>
    <t-button block theme="primary" class="login-submit" :loading="loggingIn" @click="enterSelected">
     {{ identityType==='LOCAL'?'进入管理端':'进入系统' }}
    </t-button>
   </div>
   <p v-if="notice" class="inline-note" role="status">{{notice}}</p>
  </section>
 </div><footer>卫健XC统一门户 · 由中电福富提供技术支持</footer></div>
</template>
<script setup>
import {computed,ref} from 'vue';
import {useRouter} from 'vue-router';
import {actor,login} from '../services/runtime.js';
import loginBackground from '../assets/login-health-bg-3840x2160.png';

const router=useRouter();
const identityType=ref('CITIZEN');
const loggingIn=ref(false);
const notice=ref('');
const adminAccount='admin';
const loginTitle=computed(()=>identityType.value==='LOCAL'?'管理账号登录':identityType.value==='GOV'?'政务用户登录':'公众用户登录');

function selectIdentity(type){identityType.value=type;notice.value='';}
async function enterSelected(){
 if(loggingIn.value)return;
 loggingIn.value=true;notice.value='';
 const userId=identityType.value==='LOCAL'?'MOCK_LOCAL_ADMIN':identityType.value==='GOV'?'MOCK_USER_2':'MOCK_USER_1';
 try{await login(userId);}catch(error){notice.value=error.message;loggingIn.value=false;return;}
 if(!actor.value){notice.value=identityType.value==='LOCAL'?'当前管理账号不可用。':'当前账号不可用，请联系管理员。';loggingIn.value=false;return;}
 router.replace(identityType.value==='LOCAL'?'/admin/home':'/portal/home');
}
</script>
