<template>
 <div class="login-shell"><div class="login-brand">卫健XC统一门户系统</div><section class="login-card auth-result-card"><h2>认证未完成</h2><p>未能确认闽政通 / 闽政务登录结果，请返回登录页重新登录。</p><t-button block @click="router.replace('/login')">返回登录</t-button></section></div>
</template>
<script setup>
import {useRouter} from 'vue-router';
const router=useRouter();
</script>
