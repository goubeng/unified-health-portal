<template>
  <t-dialog
    :visible="visible"
    placement="center"
    :header="`关联子系统账号 · ${text(app?.name)||'应用'}`"
    width="780px"
    :footer="false"
    :close-on-overlay-click="false"
    @update:visible="updateVisible"
  >
    <div class="binding-wizard">
      <div class="binding-stepbar" aria-label="账号关联步骤">
        <div v-for="(item,index) in stepItems" :key="item" class="binding-step" :class="{active:step===index,done:step>index}">
          <span>{{index+1}}</span><strong>{{item}}</strong>
        </div>
      </div>

      <t-alert theme="info" class="binding-demo-alert">
        当前为 Mock 演示流程，不调用真实子系统、短信或身份平台。正式接入时页面流程不变，仅替换 Service/Provider。
      </t-alert>

      <div v-if="error" class="error-note" role="alert">{{error}}</div>

      <section v-if="step===0" class="binding-stage">
        <h3>查找已有子系统账号</h3>
        <p class="muted">优先尝试可信身份信息自动匹配；也可输入已有子系统账号辅助查找。姓名、手机号等只用于发现候选，不直接完成绑定。</p>

        <div class="binding-search-row">
          <t-input v-model="externalAccount" clearable placeholder="已有子系统账号（可选）"/>
          <t-button theme="primary" :loading="busy" @click="discover">查找账号</t-button>
        </div>

        <template v-if="discovery?.state==='NO_ACCOUNT'">
          <t-alert theme="warning" message="未找到已有账号">
            暂未在该子系统中找到与当前身份对应的有效账号。
          </t-alert>
          <div v-if="discovery.accountOpeningMode==='REQUEST'" class="binding-opening-form">
            <h3>申请开通子系统账号</h3>
            <p class="muted">门户仅模拟/承接申请流程，账号是否创建仍由目标子系统负责。</p>
            <label>申请原因 <span class="portal-required">*</span></label>
            <t-textarea v-model="openingReason" :autosize="{minRows:3,maxRows:5}" placeholder="请输入申请原因"/>
            <label>联系方式</label>
            <t-input v-model="openingContact" placeholder="可选"/>
            <div class="binding-actions">
              <t-button theme="primary" :loading="busy" @click="submitOpening">提交开通申请</t-button>
            </div>
          </div>
          <div v-else class="binding-actions">
            <t-button variant="outline" @click="close">关闭</t-button>
          </div>
        </template>

        <template v-if="candidate">
          <div class="binding-candidate-card">
            <div class="binding-candidate-head">
              <strong>发现可能属于您的账号</strong>
              <t-tag :theme="candidate.accountStatus==='ACTIVE'?'success':'danger'" variant="light">{{candidate.accountStatus==='ACTIVE'?'正常':'已停用'}}</t-tag>
            </div>
            <dl>
              <div><dt>子系统账号</dt><dd>{{text(candidate.externalAccount)}}</dd></div>
              <div><dt>姓名</dt><dd>{{text(candidate.name)}}</dd></div>
              <div><dt>预留手机号</dt><dd>{{text(candidate.maskedPhone)}}</dd></div>
              <div><dt>所属单位</dt><dd>{{text(candidate.orgName)}}</dd></div>
              <div><dt>账号级别</dt><dd>{{candidate.highPrivilege?'高权限账号':'普通账号'}}</dd></div>
            </dl>
          </div>

          <t-alert v-if="candidate.accountStatus==='DISABLED'" theme="error" message="子系统账号已停用">
            当前账号不能建立有效访问关系，请联系目标子系统管理员恢复账号状态。
          </t-alert>
          <t-alert v-else-if="candidate.conflict" theme="warning" message="发现账号关联冲突">
            该账号已存在其他有效绑定，不能自动覆盖。请进入异常处理流程。
          </t-alert>

          <div class="binding-actions">
            <t-button variant="outline" @click="resetSearch">重新查找</t-button>
            <t-button v-if="candidate.accountStatus==='ACTIVE'&&!candidate.conflict" theme="primary" @click="goVerify">这就是我的账号，继续验证</t-button>
            <t-button v-else-if="candidate.conflict" theme="primary" @click="showConflict">查看异常</t-button>
          </div>
        </template>
      </section>

      <section v-else-if="step===1" class="binding-stage">
        <h3>验证账号归属</h3>
        <p class="muted">候选匹配不等于绑定成功。请选择可用方式证明当前账号确实属于您。</p>

        <t-alert v-if="candidate?.highPrivilege" theme="warning" message="高权限账号">
          验证通过后仍需门户管理员审核，状态将进入“待审核”。
        </t-alert>

        <div class="binding-methods">
          <button
            v-for="method in candidate?.verificationMethods||[]"
            :key="method"
            type="button"
            class="binding-method"
            :class="{active:verificationMethod===method}"
            @click="verificationMethod=method"
          >
            <strong>{{methodTitle(method)}}</strong>
            <small>{{methodDescription(method)}}</small>
          </button>
        </div>

        <template v-if="verificationMethod==='SUBSYSTEM_OTP'">
          <div class="binding-verification-box">
            <p>验证码将发送至子系统原账号预留手机：<strong>{{candidate?.maskedPhone}}</strong></p>
            <div class="code-input-row">
              <t-input v-model="otpCode" placeholder="请输入验证码"/>
              <t-button variant="outline" :loading="busy" @click="sendOtp">{{otpSent?'重新获取':'获取验证码'}}</t-button>
            </div>
            <p v-if="otpSent" class="binding-demo-code">演示环境验证码：<strong>123456</strong>（未发送真实短信）</p>
            <div class="binding-actions">
              <t-button variant="outline" @click="step=0">上一步</t-button>
              <t-button theme="primary" :loading="busy" :disabled="!otpSent" @click="verifyOtp">确认验证</t-button>
            </div>
          </div>
        </template>

        <template v-else-if="verificationMethod==='SUBSYSTEM_CREDENTIAL'">
          <div class="binding-verification-box">
            <t-alert theme="info">账号和密码仅用于本次 Mock 验证，统一门户不会保存。演示账号：demo01 / 123456。</t-alert>
            <label>子系统账号</label>
            <t-input v-model="credentialAccount" placeholder="请输入原系统账号"/>
            <label>子系统密码</label>
            <t-input v-model="credentialPassword" type="password" placeholder="请输入原系统密码"/>
            <div class="binding-actions">
              <t-button variant="outline" @click="step=0">上一步</t-button>
              <t-button theme="primary" :loading="busy" @click="verifyCredential">验证账号</t-button>
            </div>
          </div>
        </template>

        <template v-else-if="verificationMethod==='UPSTREAM_REAUTH'">
          <div class="binding-verification-box">
            <p>正式环境将重新调用当前身份来源完成身份回验；本阶段只模拟返回成功结果。</p>
            <div class="binding-actions">
              <t-button variant="outline" @click="step=0">上一步</t-button>
              <t-button theme="primary" :loading="busy" @click="verifyUpstream">模拟重新认证</t-button>
            </div>
          </div>
        </template>

        <template v-else-if="verificationMethod==='TRUSTED_ID'">
          <div class="binding-verification-box">
            <p>已发现可信稳定唯一标识且唯一匹配，可执行自动关联。</p>
            <div class="binding-actions">
              <t-button variant="outline" @click="step=0">上一步</t-button>
              <t-button theme="primary" :loading="busy" @click="autoBind">确认自动关联</t-button>
            </div>
          </div>
        </template>
      </section>

      <section v-else class="binding-stage binding-result">
        <template v-if="resultStatus==='BOUND'">
          <t-alert theme="success" message="账号关联成功">门户已建立当前统一用户与子系统账号的映射。后续可从应用中心进入。</t-alert>
        </template>
        <template v-else-if="resultStatus==='REVIEWING'">
          <t-alert theme="warning" message="验证成功，等待管理员审核">该账号属于高权限/风险账号，管理员审核通过后才会变为“已关联”。</t-alert>
        </template>
        <template v-else-if="resultStatus==='CONFLICT'">
          <t-alert theme="warning" message="账号关联存在冲突">该子系统账号已存在其他有效绑定，系统不会自动覆盖，请等待管理员处理。</t-alert>
        </template>
        <template v-else-if="resultStatus==='ACCOUNT_DISABLED'">
          <t-alert theme="error" message="子系统账号已停用">请联系目标子系统管理员处理，门户不会自动启用子系统账号。</t-alert>
        </template>
        <template v-else-if="resultStatus==='OPENING_REQUESTED'">
          <t-alert theme="info" message="账号开通申请已提交">当前为 Mock 流程，可到“我的申请”查看处理状态。</t-alert>
        </template>
        <template v-else>
          <t-alert theme="error" message="账号关联未完成">{{error||'请重新尝试关联或联系管理员。'}}</t-alert>
        </template>

        <div v-if="result?.externalAccount" class="binding-result-summary">
          <span>子系统账号</span><strong>{{text(result.externalAccount)}}</strong>
          <span>当前状态</span><strong>{{resultStatusText}}</strong>
        </div>

        <div class="binding-actions">
          <t-button v-if="resultStatus==='FAILED'" variant="outline" @click="restart">重新关联</t-button>
          <t-button v-if="resultStatus==='OPENING_REQUESTED'" variant="outline" @click="viewRequests">查看我的申请</t-button>
          <t-button theme="primary" @click="close">完成</t-button>
        </div>
      </section>
    </div>
  </t-dialog>
</template>

<script setup>
import {computed,ref,watch} from 'vue';
import {command} from '../../services/runtime.js';
import {text,label} from './presentation.js';

const props=defineProps({visible:Boolean,app:{type:Object,default:null}});
const emit=defineEmits(['update:visible','completed','view-request']);
const stepItems=['查找账号','身份验证','关联结果'];
const step=ref(0),busy=ref(false),error=ref('');
const externalAccount=ref(''),discovery=ref(null),candidate=ref(null);
const verificationMethod=ref(''),otpSent=ref(false),otpCode=ref('');
const credentialAccount=ref('demo01'),credentialPassword=ref('');
const openingReason=ref('业务使用需要'),openingContact=ref('');
const result=ref(null),resultStatus=ref('');

const resultStatusText=computed(()=>label(resultStatus.value));

function reset(){
 step.value=0;busy.value=false;error.value='';externalAccount.value='';discovery.value=null;candidate.value=null;
 verificationMethod.value='';otpSent.value=false;otpCode.value='';credentialAccount.value='demo01';credentialPassword.value='';
 openingReason.value='业务使用需要';openingContact.value='';result.value=null;resultStatus.value='';
 if(['REVIEWING','CONFLICT','FAILED'].includes(props.app?.accessState)){
  const status=props.app?.externalAccountStatus==='DISABLED'?'ACCOUNT_DISABLED':props.app.accessState;
  result.value={externalAccount:props.app?.externalAccount||'',status};
  resultStatus.value=status;step.value=2;
 }
}
watch(()=>props.visible,visible=>{if(visible)reset();});
watch(()=>props.app?.id,()=>{if(props.visible)reset();});

function updateVisible(value){emit('update:visible',value);}
function close(){emit('update:visible',false);}
function resetSearch(){discovery.value=null;candidate.value=null;verificationMethod.value='';externalAccount.value='';error.value='';}
function restart(){step.value=0;result.value=null;resultStatus.value='';error.value='';discovery.value=null;candidate.value=null;verificationMethod.value='';otpSent.value=false;otpCode.value='';}
function methodTitle(method){return {TRUSTED_ID:'可信身份自动匹配',SUBSYSTEM_OTP:'手机验证码',SUBSYSTEM_CREDENTIAL:'原系统账号验证',UPSTREAM_REAUTH:'重新进行身份认证'}[method]||method;}
function methodDescription(method){return {TRUSTED_ID:'使用稳定唯一标识完成关联',SUBSYSTEM_OTP:'验证码发送至子系统原账号预留手机号',SUBSYSTEM_CREDENTIAL:'使用原系统账号密码完成一次性校验',UPSTREAM_REAUTH:'重新调用闽政通/闽政务等上层身份认证'}[method]||'';}

async function call(action,payload){
 busy.value=true;error.value='';
 try{
  const response=await command(action,payload);
  if(!response.ok){error.value=response.error.message;return null;}
  return response.data;
 }catch(cause){error.value=cause.message;return null;}
 finally{busy.value=false;}
}
async function discover(){
 const data=await call('discoverApplicationAccountCandidates',{appId:props.app.id,externalAccount:externalAccount.value.trim()});
 if(!data)return;
 discovery.value=data;
 if(data.state==='BOUND'){finish(data.mapping,'BOUND');return;}
 candidate.value=data.candidates?.[0]||null;
 if(data.state==='ACCOUNT_DISABLED'){finish(candidate.value,'ACCOUNT_DISABLED');return;}
 if(data.state==='CONFLICT'){finish(candidate.value,'CONFLICT');return;}
 if(candidate.value)verificationMethod.value=candidate.value.verificationMethods?.[0]||'';
}
function goVerify(){step.value=1;}
function showConflict(){finish(candidate.value,'CONFLICT');}
async function autoBind(){
 const data=await call('startApplicationAccountBinding',{appId:props.app.id,externalAccount:candidate.value.externalAccount});
 if(data)finish(data,data.status);
}
async function sendOtp(){
 const data=await call('sendSubsystemBindingOtp',{appId:props.app.id,externalAccount:candidate.value.externalAccount});
 if(data){otpSent.value=true;}
}
async function verifyOtp(){
 const data=await call('verifyBindingOtp',{appId:props.app.id,externalAccount:candidate.value.externalAccount,code:otpCode.value});
 if(data)finish(data,data.status);
}
async function verifyCredential(){
 const data=await call('verifyBindingBySubsystemCredential',{appId:props.app.id,externalAccount:credentialAccount.value.trim(),password:credentialPassword.value});
 if(data)finish(data,data.status);
}
async function verifyUpstream(){
 const data=await call('verifyBindingByUpstreamReauth',{appId:props.app.id,externalAccount:candidate.value.externalAccount});
 if(data)finish(data,data.status);
}
async function submitOpening(){
 if(!openingReason.value.trim()){error.value='请填写开通申请原因';return;}
 const data=await call('submitAccountOpeningRequest',{appId:props.app.id,reason:openingReason.value.trim(),contact:openingContact.value.trim()});
 if(data)finish({request:data},'OPENING_REQUESTED');
}
function finish(data,status){
 result.value=data||{};resultStatus.value=status||data?.status||'FAILED';step.value=2;emit('completed',{status:resultStatus.value,data:result.value,app:props.app});
}
function viewRequests(){emit('view-request');close();}
</script>
