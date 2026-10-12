<template>
  <t-dialog
    class="account-binding-dialog"
    :class="{'account-binding-dialog--app-center':appCenter}"
    :visible="visible"
    placement="center"
    :header="`应用访问 · ${text(app?.name)||'应用'}`"
    :width="appCenter?APP_CENTER_DIALOG_MAX_WIDTH:DIALOG_MAX_WIDTH"
    :footer="false"
    :close-on-overlay-click="false"
    @update:visible="updateVisible"
  >
    <div class="binding-wizard">
      <t-loading :loading="busy" :show-overlay="false" size="small">
        <section v-if="busy" class="binding-stage" style="min-height:160px"></section>

        <section v-else class="binding-stage binding-result">
          <t-alert class="wizard-alert" :theme="resultTheme" :message="resultTitle">
            {{resultDescription}}
          </t-alert>

          <div v-if="externalHandoff" class="binding-result-summary">
            <span>下一步</span>
            <strong>请在目标系统完成处理后返回本页，再点击“完成后重新检测”。</strong>
          </div>

          <div v-if="error" class="error-note" role="alert">{{error}}</div>

          <div class="binding-actions">
            <t-button
              v-if="resultStatus==='CONFIRM_REQUIRED'"
              variant="outline"
              theme="primary"
              @click="goSubsystem"
            >前往子系统确认</t-button>
            <t-button
              v-if="resultStatus==='OPENING_REQUIRED'"
              variant="outline"
              theme="primary"
              @click="goSubsystem"
            >前往子系统开通</t-button>
            <t-button
              v-if="externalHandoff&&['CONFIRM_REQUIRED','OPENING_REQUIRED'].includes(resultStatus)"
              theme="primary"
              :loading="busy"
              @click="recheck"
            >完成后重新检测</t-button>
            <t-button
              v-if="resultStatus==='FAILED'"
              variant="outline"
              theme="primary"
              :loading="busy"
              @click="retry"
            >重新检测</t-button>
            <t-button theme="primary" @click="close">{{closeButtonText}}</t-button>
          </div>
        </section>
      </t-loading>
    </div>
  </t-dialog>
</template>

<script setup>
import {createUUID} from '../../utils/uuid.js';
import {computed,ref,watch} from 'vue';
import {MessagePlugin} from 'tdesign-vue-next';
import {command} from '../../services/runtime.js';
import {text} from './presentation.js';

const DIALOG_MAX_WIDTH = 'min(calc(100vw - 24px), 420px)';
const APP_CENTER_DIALOG_MAX_WIDTH = 'min(calc(100vw - 48px), 560px)';

const props=defineProps({visible:Boolean,app:{type:Object,default:null},appCenter:{type:Boolean,default:false}});
const emit=defineEmits(['update:visible','completed','view-request']);

const busy=ref(false),error=ref('');
const discovery=ref(null),candidate=ref(null),result=ref(null),resultStatus=ref('');
const externalHandoff=ref(false);

const resultTitle=computed(()=>({
  BOUND:'账号确认成功',
  REVIEWING:'账号确认已提交',
  CONFLICT:'账号信息存在异常',
  ACCOUNT_DISABLED:'账号暂不可用',
  OPENING_REQUIRED:'需要开通账号',
  CONFIRM_REQUIRED:'需要完成账号确认',
  FAILED:'暂未完成账号确认'
}[resultStatus.value]||'应用访问提示'));

const resultDescription=computed(()=>({
  BOUND:'已完成应用访问准备，现在可以返回应用中心进入该应用。',
  REVIEWING:'相关信息正在审核，审核完成后即可使用该应用。',
  CONFLICT:'检测到账号关系异常，暂时无法完成访问，请联系门户管理员处理。',
  ACCOUNT_DISABLED:'目标系统中的账号当前不可用，请联系目标系统管理员处理。',
  OPENING_REQUIRED:'当前未检测到可用账号。请前往目标系统完成账号开通，完成后返回门户重新检测。',
  CONFIRM_REQUIRED:'该应用需要确认您在目标系统中的已有账号。历史账号、密码或验证码等信息均在目标系统中完成，统一门户不采集这些凭据。',
  FAILED:'当前未能完成账号确认，请重新处理或联系目标系统管理员。'
}[resultStatus.value]||'请根据提示完成后续处理。'));

const resultTheme=computed(()=>({
  BOUND:'success',
  REVIEWING:'warning',
  CONFLICT:'warning',
  ACCOUNT_DISABLED:'error',
  OPENING_REQUIRED:'info',
  CONFIRM_REQUIRED:'info',
  FAILED:'error'
}[resultStatus.value]||'info'));

const closeButtonText=computed(()=>resultStatus.value==='BOUND'?'完成':'关闭');

function updateVisible(value){emit('update:visible',value);}
function close(){emit('update:visible',false);}

function setResult(data,status,notify=false){
  result.value=data||{};
  resultStatus.value=status||data?.status||'FAILED';
  if(notify)emit('completed',{status:resultStatus.value,data:result.value,app:props.app});
}

function reset(){
  busy.value=false;error.value='';discovery.value=null;candidate.value=null;result.value=null;resultStatus.value='';externalHandoff.value=false;
}

async function call(action,payload){
  busy.value=true;error.value='';
  try{
    const response=await command(action,payload);
    if(!response.ok){error.value=response.error.message;return null;}
    return response.data;
  }catch(cause){
    error.value=cause.message;return null;
  }finally{
    busy.value=false;
  }
}

async function evaluate(ignoreCurrent=false){
  if(!props.app?.id)return;
  error.value='';externalHandoff.value=false;
  const current=props.app.accessState;
  if(current==='BOUND'||current==='DIRECT'){setResult(props.app,'BOUND');return;}
  if(current==='REVIEWING'){setResult(props.app,'REVIEWING');return;}
  if(current==='CONFLICT'){setResult(props.app,'CONFLICT');return;}
  if(current==='FAILED'&&props.app.externalAccountStatus==='DISABLED'){setResult(props.app,'ACCOUNT_DISABLED');return;}
  if(current==='FAILED'&&!ignoreCurrent){setResult(props.app,'FAILED');return;}

  const data=await call('discoverApplicationAccountCandidates',{appId:props.app.id,externalAccount:''});
  if(!data){setResult({},'FAILED');return;}
  discovery.value=data;

  if(data.state==='BOUND'){setResult(data.mapping,'BOUND');return;}
  if(data.state==='NO_ACCOUNT'){setResult(data,'OPENING_REQUIRED');return;}

  candidate.value=data.candidates?.[0]||null;
  if(data.state==='ACCOUNT_DISABLED'){setResult(candidate.value,'ACCOUNT_DISABLED');return;}
  if(data.state==='CONFLICT'){setResult(candidate.value,'CONFLICT');return;}
  if(!candidate.value){setResult(data,'FAILED');return;}

  if(candidate.value.verificationMethods?.includes('TRUSTED_ID')){
    const bound=await call('startApplicationAccountBinding',{appId:props.app.id,externalAccount:candidate.value.externalAccount});
    if(bound){setResult(bound,bound.status,true);return;}
    setResult({},'FAILED');return;
  }

  setResult(candidate.value,'CONFIRM_REQUIRED');
}

function goSubsystem(){
  externalHandoff.value=true;
  const url=String(props.app?.url||'');
  if(url&&/^https?:\/\//i.test(url)&&!url.includes('.invalid/'))window.open(url,'_blank','noopener');
  MessagePlugin.info('请在目标系统完成处理后返回门户');
}

async function recheck(){
  if(resultStatus.value==='CONFIRM_REQUIRED'&&candidate.value?.externalAccount){
    const data=await call('verifyBindingByUpstreamReauth',{appId:props.app.id,externalAccount:candidate.value.externalAccount});
    if(data){externalHandoff.value=false;setResult(data,data.status,true);return;}
    setResult({},'FAILED');return;
  }
  if(resultStatus.value==='OPENING_REQUIRED'){
    const data=await call('bind',{appId:props.app.id,externalAccount:'opened_'+createUUID(),outcome:'BOUND'});
    if(data){externalHandoff.value=false;setResult(data,data.status,true);return;}
    setResult({},'FAILED');return;
  }
  await evaluate(true);
}
async function retry(){
  await evaluate(true);
}

watch(()=>props.visible,async visible=>{
  if(!visible)return;
  reset();
  await evaluate();
});
watch(()=>props.app?.id,async()=>{
  if(!props.visible)return;
  reset();
  await evaluate();
});
</script>

<style>
/* 弹窗居中与防溢出样式保障（覆盖PC端与移动端） */
.account-binding-dialog.t-dialog__wrap .t-dialog,
.account-binding-dialog.t-dialog,
body .account-binding-dialog .t-dialog {
  width: min(calc(100vw - 24px), 420px) !important;
  max-width: min(calc(100vw - 24px), 420px) !important;
  box-sizing: border-box !important;
  border-radius: 14px !important;
  margin-inline: auto !important;
}

.account-binding-dialog .t-dialog__position {
  padding: 12px !important;
  box-sizing: border-box !important;
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
}

.account-binding-dialog .t-dialog__header {
  padding: 18px 20px 12px !important;
  font-size: 16px !important;
  font-weight: 600 !important;
  color: #1a2d48 !important;
}

.account-binding-dialog .t-dialog__body {
  padding: 10px 20px 20px !important;
}

.account-binding-dialog .t-dialog__close {
  top: 14px !important;
  right: 14px !important;
}

/* 提示信息样式全面优化：清晰浅底高对比度文字，解决文字看不清的问题 */
.account-binding-dialog .wizard-alert {
  padding: 12px 14px !important;
  border-radius: 8px !important;
  line-height: 1.6 !important;
  font-size: 13.5px !important;
  box-sizing: border-box !important;
}

.account-binding-dialog .wizard-alert.t-alert--info {
  background-color: #f0f6ff !important;
  border: 1px solid #cde0fc !important;
}
.account-binding-dialog .wizard-alert.t-alert--info .t-alert__icon {
  color: #0052d9 !important;
}
.account-binding-dialog .wizard-alert.t-alert--info :is(.t-alert__message, .t-alert__description, .t-alert__content) {
  color: #173868 !important;
  font-weight: 400 !important;
}

.account-binding-dialog .wizard-alert.t-alert--warning {
  background-color: #fef8ee !important;
  border: 1px solid #f9dfaf !important;
}
.account-binding-dialog .wizard-alert.t-alert--warning .t-alert__icon {
  color: #ed7b2f !important;
}
.account-binding-dialog .wizard-alert.t-alert--warning :is(.t-alert__message, .t-alert__description, .t-alert__content) {
  color: #7a4608 !important;
  font-weight: 400 !important;
}

.account-binding-dialog .wizard-alert.t-alert--success {
  background-color: #f0f9f3 !important;
  border: 1px solid #c1ebd0 !important;
}
.account-binding-dialog .wizard-alert.t-alert--success .t-alert__icon {
  color: #0b9356 !important;
}
.account-binding-dialog .wizard-alert.t-alert--success :is(.t-alert__message, .t-alert__description, .t-alert__content) {
  color: #116035 !important;
  font-weight: 400 !important;
}

.account-binding-dialog .wizard-alert.t-alert--error {
  background-color: #fff1f0 !important;
  border: 1px solid #fecbc7 !important;
}
.account-binding-dialog .wizard-alert.t-alert--error .t-alert__icon {
  color: #e34d59 !important;
}
.account-binding-dialog .wizard-alert.t-alert--error :is(.t-alert__message, .t-alert__description, .t-alert__content) {
  color: #9c2620 !important;
  font-weight: 400 !important;
}

.account-binding-dialog .binding-actions {
  display: flex;
  align-items: center;
  justify-content: flex-end;
  gap: 10px;
  margin-top: 18px;
  flex-wrap: wrap;
}

/* 仅PC应用中心来源：扩展账号关联对话框，并统一标题、正文距边框留白。 */
.account-binding-dialog.account-binding-dialog--app-center.t-dialog__wrap .t-dialog,
.account-binding-dialog.account-binding-dialog--app-center.t-dialog,
body .account-binding-dialog.account-binding-dialog--app-center .t-dialog {
  width: min(calc(100vw - 48px), 560px) !important;
  max-width: min(calc(100vw - 48px), 560px) !important;
}
.account-binding-dialog.account-binding-dialog--app-center .t-dialog__header {
  padding: 22px 28px 14px !important;
}
.account-binding-dialog.account-binding-dialog--app-center .t-dialog__body {
  padding: 12px 28px 28px !important;
}
.account-binding-dialog.account-binding-dialog--app-center .t-dialog__close {
  right: 20px !important;
}

@media (max-width: 640px) {
  .account-binding-dialog .binding-actions {
    justify-content: stretch;
  }
  .account-binding-dialog .binding-actions .t-button {
    flex: 1 1 auto;
    min-width: 100px;
  }
}
</style>