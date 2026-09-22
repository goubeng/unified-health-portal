<template>
 <div class="login-shell"><img class="login-bg-image" :src="loginBackground" alt="" aria-hidden="true"/><div class="login-brand">卫健XC统一门户系统</div><div class="login-layout">
  <section class="login-card">
   <div class="login-identity-switch" role="tablist" aria-label="身份切换">
    <button type="button" class="identity-pill" :class="{active:identityType==='CITIZEN'}" @click="identityType='CITIZEN'"><span>公众用户</span></button>
    <button type="button" class="identity-pill" :class="{active:identityType==='GOV'}" @click="identityType='GOV'"><span>政务用户</span></button>
    <button type="button" class="identity-pill" :class="{active:identityType==='LOCAL'}" @click="identityType='LOCAL'"><span>管理账号</span></button>
   </div>

   <template v-if="identityType!=='LOCAL'">
    <div class="auth-method-pills" role="tablist" aria-label="登录方式切换">
     <button type="button" class="method-pill" :class="{active:method==='qr'}" @click="method='qr'">扫码登录</button>
     <button type="button" class="method-pill" :class="{active:method==='phone'}" @click="method='phone'">手机号登录</button>
    </div>
    <div v-if="method==='qr'" class="qr-auth">
     <button type="button" class="qr-frame-button" :class="{'is-expired':qrStage==='expired','is-success':qrStage==='success'}" :disabled="qrStage==='success'" @click="handleQrClick">
      <div class="qr-frame">
       <t-qrcode v-if="qrStage!=='success'" class="login-qrcode" :value="qrPayload" type="svg" :size="176" borderless/>
       <template v-else><CheckCircleIcon size="48px"/><span>扫码成功</span></template>
       <div v-if="qrStage==='expired'" class="qr-expired-mask"><RefreshIcon size="34px"/><strong>点击重新刷新</strong></div>
      </div>
     </button>
     <strong class="qr-tip-title">{{qrPrompt}}</strong>
     <p class="qr-expire-text">{{qrStage==='expired'?'二维码已过期，请刷新':`二维码将在 ${displayCountdown} 后失效`}}</p>
    </div>
    <form v-else class="phone-auth" @submit.prevent="enter">
     <label for="login-phone" class="field-label">手机号</label><t-input id="login-phone" v-model="phone" autocomplete="tel" placeholder="请输入手机号"/>
     <div class="slide-verification" :class="{verified}">
      <div class="slide-verification-head"><span>{{verified?'安全验证已完成':'安全验证'}}</span><strong>{{verified?'验证通过':'请拖动滑块到最右侧'}}</strong></div>
      <input id="login-slider" v-model.number="slide" type="range" min="0" max="100" :disabled="verified" :style="{'--slide-progress':slide+'%'}" aria-label="向右滑动完成验证" @input="verifySlide"/>
     </div>
     <label for="login-code" class="field-label">验证码</label><div class="code-input-row"><t-input id="login-code" v-model="code" autocomplete="one-time-code" placeholder="请输入验证码"/><t-button variant="outline" :disabled="countdown>0" @click="getCode">{{countdown?countdown+'秒后重试':'获取验证码'}}</t-button></div>
     <t-button block type="submit" class="login-submit">登录</t-button>
    </form>
   </template>

   <form v-else class="local-auth phone-auth" @submit.prevent="enterLocalAdmin">
    <label for="local-account" class="field-label">用户账号</label>
    <t-input id="local-account" v-model="localAccount" autocomplete="username" placeholder="请输入用户账号"/>
    <label for="local-password" class="field-label">登录密码</label>
    <t-input id="local-password" v-model="localPassword" type="password" autocomplete="current-password" placeholder="请输入登录密码"/>
    <label for="local-captcha" class="field-label">验证码</label>
    <div class="local-captcha-row">
     <t-input id="local-captcha" v-model="localCaptchaInput" autocomplete="off" :maxlength="4" placeholder="请输入验证码"/>
     <PortalTooltip content="点击刷新验证码" placement="top"><button type="button" class="local-captcha-code" aria-label="刷新验证码" @click="refreshLocalCaptcha">
      <span>{{localCaptchaCode}}</span>
     </button></PortalTooltip>
    </div>
    <t-button block type="submit" theme="primary" class="login-submit" :loading="localLoggingIn">登录</t-button>
   </form>

   <p v-if="notice" class="inline-note" role="status">{{notice}}</p>
   <div v-if="identityType!=='LOCAL'" class="login-assist-row">
    <button type="button" class="assist-link" @click="openRegister">尚未注册？<span>立即注册</span></button>
    <span class="assist-divider">|</span>
    <button type="button" class="assist-link" @click="openForgot">忘记密码</button>
   </div>
  </section>
 </div><footer>卫健XC统一门户 · 由中电福富提供技术支持</footer></div>
</template>
<script setup>
import {createUUID} from '../utils/uuid.js';
import {computed,onBeforeUnmount,ref,watch} from 'vue';
import {useRouter} from 'vue-router';
import {CheckCircleIcon,RefreshIcon} from 'tdesign-icons-vue-next';
import {login} from '../services/runtime.js';
import PortalTooltip from '../components/portal/PortalTooltip.vue';
import loginBackground from '../assets/login-health-bg-3840x2160.png';

const router=useRouter();
const identityType=ref('CITIZEN'),method=ref('qr'),phone=ref(''),code=ref(''),slide=ref(0),verified=ref(false),codeRequested=ref(false),countdown=ref(0),qrStage=ref('ready'),notice=ref('');
const localLoggingIn=ref(false),localAccount=ref('admin'),localPassword=ref(''),localCaptchaInput=ref(''),localCaptchaCode=ref('A7K9');
const platform=computed(()=>identityType.value==='GOV'?'闽政务':'闽政通');
const platformLink=computed(()=>identityType.value==='GOV'?'https://zwfw.fujian.gov.cn':'https://mztapp.fujian.gov.cn');
const qrPrompt=computed(()=>`请使用${platform.value}扫一扫登录`);
const qrNonce=ref(createUUID()),qrPayload=computed(()=>'WJ-PORTAL:'+identityType.value+':'+qrNonce.value);
const qrSeconds=ref(5);
const displayCountdown=computed(()=>`${String(Math.floor(qrSeconds.value/60)).padStart(2,'0')}:${String(qrSeconds.value%60).padStart(2,'0')}`);
let timer,qrExpireTimer,qrSuccessTimer,qrCountdownTimer;

function clearTimers(){clearInterval(timer);clearInterval(qrCountdownTimer);clearTimeout(qrExpireTimer);clearTimeout(qrSuccessTimer);}
function createLocalCaptcha(){
 const chars='ABCDEFGHJKLMNPQRSTUVWXYZ23456789',values=new Uint32Array(4);
 crypto.getRandomValues(values);
 return Array.from(values,value=>chars[value%chars.length]).join('');
}
function refreshLocalCaptcha(){localCaptchaCode.value=createLocalCaptcha();}
function reset(){
 clearTimers();phone.value='';code.value='';slide.value=0;verified.value=false;codeRequested.value=false;countdown.value=0;notice.value='';localLoggingIn.value=false;
 if(identityType.value==='LOCAL')refreshLocalCaptcha();else startQr();
}
function startQr(){
 qrNonce.value=createUUID();qrStage.value='ready';qrSeconds.value=5;clearTimeout(qrExpireTimer);clearInterval(qrCountdownTimer);
 if(identityType.value==='LOCAL'||method.value!=='qr')return;
 qrCountdownTimer=setInterval(()=>{if(qrSeconds.value>0)qrSeconds.value--;else clearInterval(qrCountdownTimer);},1000);
 qrExpireTimer=setTimeout(()=>{if(qrStage.value==='ready'){qrSeconds.value=0;qrStage.value='expired';clearInterval(qrCountdownTimer);}},5000);
}
function verifySlide(event){verified.value=Number(event.target.value)>=100;if(verified.value)slide.value=100;}
function getCode(){
 if(countdown.value)return;
 codeRequested.value=true;countdown.value=60;notice.value='演示环境：验证码流程仅模拟，不发送真实短信。';
 timer=setInterval(()=>{countdown.value--;if(!countdown.value)clearInterval(timer);},1000);
}
function refreshQr(){startQr();notice.value='';}
function handleQrClick(){if(qrStage.value==='success')return;if(qrStage.value==='expired')refreshQr();qrStage.value='success';notice.value='';clearTimeout(qrExpireTimer);clearInterval(qrCountdownTimer);qrSuccessTimer=setTimeout(()=>enter(),420);}
function openRegister(){window.open(platformLink.value,'_blank','noopener');}
function openForgot(){window.open(platformLink.value,'_blank','noopener');}
async function enterLocalAdmin(){
 if(localLoggingIn.value)return;
 localLoggingIn.value=true;notice.value='';
 try{await login('MOCK_LOCAL_ADMIN');}
 catch(error){notice.value=error.message;localLoggingIn.value=false;return;}
 router.replace('/admin/home');
}
async function enter(){
 if(identityType.value==='LOCAL'){await enterLocalAdmin();return;}
 try{await login(identityType.value==='GOV'?'MOCK_USER_2':'MOCK_USER_1');}catch(error){notice.value=error.message;return;}
 router.replace('/portal/home');
}
watch([identityType,method],()=>reset(),{immediate:true});
onBeforeUnmount(()=>clearTimers());
</script>