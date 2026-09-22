<template>
 <section v-if="profile" class="access-config-dialog-body">
  <div class="access-source-summary">
   <div><span>来源应用</span><strong>{{text(profile.appName)}}</strong></div>
   <div><span>应用编码</span><strong>{{text(profile.appCode)}}</strong></div>
  </div>
  <div class="access-config-main">
   <t-tabs v-model="activeKind" placement="left" class="access-config-tabs">
    <t-tab-panel v-for="kind in kinds" :key="kind" :value="kind" :label="kind+' 接入配置'">
     <div class="access-config-scroll">
      <div class="access-config-tab-head">
       <div><span>配置状态</span><t-tag :theme="theme(configStatus(source(kind)))" variant="light">{{label(configStatus(source(kind)))}}</t-tag></div>
       <div><span>运行状态</span><t-tag :theme="theme(runtimeStatus(source(kind)))" variant="light">{{label(runtimeStatus(source(kind)))}}</t-tag></div>
      </div>
      <div class="access-config-grid">
       <label class="access-field">
        <span>启用状态</span>
        <div class="access-switch-line"><t-switch :value="forms[kind].enabled==='ENABLED'" @change="forms[kind].enabled=$event?'ENABLED':'DISABLED'"/></div>
       </label>
       <template v-if="kind==='SSO'">
        <label class="access-field"><span>协议</span><t-select v-model="forms[kind].protocol" :options="protocolOptions"/></label>
        <label class="access-field"><span>Client ID</span><t-input v-model="forms[kind].clientId" placeholder="请输入 Client ID"/></label>
        <label class="access-field full"><span>授权地址</span><t-input v-model="forms[kind].authorizeUrl" placeholder="请输入授权地址"/></label>
        <label class="access-field full"><span>令牌地址</span><t-input v-model="forms[kind].tokenUrl" placeholder="请输入令牌地址"/></label>
        <label class="access-field full"><span>回调地址</span><t-input v-model="forms[kind].callbackUrl" placeholder="请输入回调地址"/></label>
       </template>
       <template v-else>
        <label class="access-field"><span>接入方式</span><t-select v-model="forms[kind].mode" :options="modeOptions" placeholder="请选择接入方式"/></label>
        <label class="access-field full"><span>字段映射</span><t-textarea v-model="forms[kind].fieldMapping" :autosize="{minRows:3,maxRows:7}" placeholder="JSON：标准字段 → 来源字段"/></label>
        <label v-if="kind==='TODO'" class="access-field full"><span>状态映射</span><t-textarea v-model="forms[kind].valueMapping" :autosize="{minRows:2,maxRows:5}" placeholder='{"status":{"待处理":"PENDING","已完成":"COMPLETED"}}'/></label>
       </template>
       <label class="access-field full"><span>服务端凭据引用</span><t-input v-model="forms[kind].credentialRef" placeholder="例如 PORTAL_APP_01_TOKEN"/><small class="form-helper">仅填写服务端凭据引用标识，不填写真实密钥。</small></label>
       <label class="access-field full"><span>备注</span><t-textarea v-model="forms[kind].remark" :autosize="{minRows:2,maxRows:4}" placeholder="请输入接入说明或备注"/></label>
      </div>
     </div>
    </t-tab-panel>
   </t-tabs>
  </div>
  <footer class="access-config-footer">
   <t-button theme="primary" :loading="saving" :disabled="saving" @click="save(activeKind)">保存配置</t-button>
  </footer>
 </section>
</template>
<script setup>
import {reactive,ref,watch} from 'vue';
import {text,label,theme} from './presentation.js';
const props=defineProps({profile:{type:Object,default:null},saving:Boolean});
const emit=defineEmits(['save']);
const kinds=['SSO','TODO','MESSAGE'],activeKind=ref('SSO'),savingKind=ref('');
const protocolOptions=['OIDC','SAML2','CUSTOM'].map(value=>({value,label:value}));
const modeOptions=[{value:'PUSH',label:'PUSH（推送）'}];
const forms=reactive({SSO:{},TODO:{},MESSAGE:{}});
const source=kind=>props.profile?.integrations?.[kind]||null;
const configStatus=item=>item?.configStatus||'UNCONFIGURED';
const runtimeStatus=item=>item?.runtimeStatus||'UNCONFIGURED';
const loadedSources={};let loadedApp=null;
function init(){if(loadedApp!==props.profile?.appId){for(const kind of kinds)delete loadedSources[kind];loadedApp=props.profile?.appId;activeKind.value='SSO';}for(const kind of kinds){const item=source(kind)||{},signature=JSON.stringify(item);if(loadedSources[kind]===signature)continue;loadedSources[kind]=signature;forms[kind]={enabled:item.enabled||'DISABLED',protocol:['OIDC','SAML2','CUSTOM'].includes(item.protocol)?item.protocol:'OIDC',mode:kind==='SSO'?'SSO':(item.mode||'PUSH'),clientId:item.clientId||'',authorizeUrl:item.authorizeUrl||'',tokenUrl:item.tokenUrl||'',callbackUrl:item.callbackUrl||'',credentialRef:item.credentialRef||'',fieldMapping:JSON.stringify(item.fieldMapping||{},null,2),valueMapping:JSON.stringify(item.valueMapping||{},null,2),remark:item.remark||''};}}
watch(()=>props.profile,init,{immediate:true,deep:true});
async function save(kind){const item=source(kind);if(!item)return;savingKind.value=kind;try{await emit('save',{kind,payload:{id:item.id,version:item.version,...forms[kind],mode:kind==='SSO'?'SSO':(forms[kind].mode||'PUSH')}});}finally{savingKind.value='';}}
</script>