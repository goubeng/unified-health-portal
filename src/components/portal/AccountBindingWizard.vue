<template>
  <t-dialog
    :visible="visible"
    placement="center"
    :header="`应用访问 · ${text(app?.name)||'应用'}`"
    width="680px"
    :footer="false"
    :close-on-overlay-click="false"
    @update:visible="updateVisible"
  >
    <div class="binding-wizard">
      <t-loading :loading="busy" :show-overlay="false" size="small">
        <section v-if="busy" class="binding-stage" style="min-height:160px"></section>

        <section v-else class="binding-stage binding-result">
          <t-alert :theme="resultTheme" :message="resultTitle">
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

const props=defineProps({visible:Boolean,app:{type:Object,default:null}});
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