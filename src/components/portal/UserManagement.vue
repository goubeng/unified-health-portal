<template>
  <section class="portal-list user-management">
    <Teleport v-if="canSuper" to="#page-header-actions">
      <t-button variant="outline" theme="primary" @click="openCreateExternal">授权外部用户</t-button>
      <t-button theme="primary" @click="openCreateLocal">新增本地管理账号</t-button>
    </Teleport>

    <t-form layout="inline" class="portal-query list-toolbar">
      <t-form-item class="portal-query-keyword user-query-keyword" label="姓名/管理账号">
        <t-input v-model="keyword" clearable placeholder="请输入姓名或管理账号"/>
      </t-form-item>
      <t-form-item class="portal-query-select query-width-user-type" label="认证类型">
        <t-select v-model="authType" clearable placeholder="全部" :options="authTypeOptions"/>
      </t-form-item>
      <t-form-item class="portal-query-select query-width-user-type" label="身份来源">
        <t-select v-model="identitySource" clearable placeholder="全部" :options="sourceOptions"/>
      </t-form-item>
      <t-form-item class="portal-query-select query-width-default" label="门户角色">
        <t-select v-model="roleId" clearable placeholder="全部" :options="roleOptions"/>
      </t-form-item>
      <t-form-item class="portal-query-select query-width-status" label="启用状态">
        <t-select v-model="status" clearable placeholder="全部" :options="statusOptions"/>
      </t-form-item>
      <t-form-item class="portal-query-action">
        <t-button theme="default" variant="outline" @click="reset">重置</t-button>
      </t-form-item>
    </t-form>

    <section class="panel portal-table-panel">
      <t-table row-key="id" :data="paged" :columns="columns" hover table-layout="fixed" size="medium">
        <template #empty><EmptyState description="暂无符合条件的门户管理用户"/></template>
        <template #serial="{rowIndex}">{{(page-1)*pageSize+rowIndex+1}}</template>
        <template #account="{row}"><TableCellTooltip :text="text(row.account)||'-'"><button class="portal-field-link" @click="openDetail(row)">{{text(row.account)||'-'}}</button></TableCellTooltip></template>
        <template #authType="{row}"><t-tag :theme="adminAuthType(row)==='LOCAL'?'warning':'primary'" variant="light">{{authTypeLabel(adminAuthType(row))}}</t-tag></template>
        <template #identitySource="{row}"><TableCellTooltip :text="identitySourceText(row)">{{identitySourceText(row)}}</TableCellTooltip></template>
        <template #roleLabels="{row}"><TableCellTooltip :text="text(row.roleLabels)||'无管理角色'">{{text(row.roleLabels)||'无管理角色'}}</TableCellTooltip></template>
        <template #enabled="{row}">
          <t-switch
            :value="adminEnabled(row)"
            :disabled="row.id==='MOCK_LOCAL_ADMIN'||adminAuthType(row)==='LOCAL'&&!canSuper"
            @change="toggleStatus(row,$event)"
          />
        </template>
        <template #lastLoginAt="{row}">{{date(row.lastLoginAt)}}</template>
        <template #operation="{row}">
          <div class="row-actions">
            <t-button v-if="canSuper" size="small" variant="text" theme="primary" @click="openEdit(row)">编辑</t-button>
            <t-button v-if="canSuper&&adminAuthType(row)==='LOCAL'" size="small" variant="text" theme="primary" @click="resetPassword(row)">重置密码</t-button>
            <t-button v-if="canSuper&&adminAuthType(row)==='LOCAL'&&row.lockedUntil" size="small" variant="text" theme="primary" @click="unlock(row)">解除锁定</t-button>
          </div>
        </template>
      </t-table>
      <t-pagination v-model="page" v-model:page-size="pageSize" :total="filtered.length" :page-size-options="[10,20,50]" show-jumper/>
    </section>

    <t-dialog v-model:visible="detailVisible" placement="center" header="管理用户详情" width="760px" :footer="false">
      <t-alert v-if="detail&&adminAuthType(detail)==='EXTERNAL'" theme="info" class="user-source-alert user-detail-source-alert">
        当前管理资格绑定{{identitySourceText(detail)}}身份；门户仅维护管理端授权，不修改上游权威身份主数据。
      </t-alert>
      <DetailGrid v-if="detail" :items="detailItems"/>
    </t-dialog>

    <t-dialog
      v-model:visible="formVisible"
      placement="center"
      :header="formMode==='createLocal'?'新增本地管理账号':formMode==='createExternal'?'授权外部用户':'编辑管理用户'"
      width="760px"
      :confirm-btn="{content:'保存',loading:saving}"
      :close-on-overlay-click="false"
      @confirm="save"
    >
      <div v-if="formError" class="error-note">{{formError}}</div>
      <template v-if="formMode==='createLocal'||formMode==='edit'&&adminAuthType(form)==='LOCAL'">
        <div class="form-grid">
          <div class="form-field"><label>管理账号 <span class="portal-required">*</span></label><t-input v-model="form.account" :disabled="formMode!=='createLocal'" placeholder="请输入管理账号"/></div>
          <div class="form-field"><label>姓名 <span class="portal-required">*</span></label><t-input v-model="form.name" placeholder="请输入姓名"/></div>
          <div class="form-field"><label>认证类型</label><t-input :value="authTypeLabel('LOCAL')" disabled/></div>
          <div class="form-field"><label>身份来源</label><t-input value="门户本地" disabled/></div>
          <div class="form-field"><label>启用状态</label><t-switch v-model="form.enabled" :disabled="form.id==='MOCK_LOCAL_ADMIN'"/></div>
          <div class="form-field full"><label>门户角色</label><t-checkbox-group v-model="form.roleIds" class="user-role-options"><t-checkbox v-for="option in roleOptions" :key="option.value" :value="option.value" :disabled="form.id==='MOCK_LOCAL_ADMIN'&&option.value==='ROLE_SUPER'">{{option.label}}</t-checkbox></t-checkbox-group></div>
        </div>
      </template>
      <template v-else>
        <div v-if="formMode==='createExternal'" class="form-grid">
          <div class="form-field full"><label>绑定访问用户 <span class="portal-required">*</span></label><t-select v-model="form.accessUserId" filterable :options="accessUserOptions" placeholder="请选择闽政通/闽政务用户" @change="syncExternalCandidate"/></div>
        </div>
        <DetailGrid v-if="formMode!=='createExternal'||form.accessUserId" :items="externalIdentityItems"/>
        <div class="form-grid user-external-maintenance">
          <div class="form-field"><label>启用状态</label><t-switch v-model="form.enabled"/></div>
          <div class="form-field full"><label>门户角色</label><t-checkbox-group v-model="form.roleIds" class="user-role-options"><t-checkbox v-for="option in roleOptions" :key="option.value" :value="option.value">{{option.label}}</t-checkbox></t-checkbox-group></div>
        </div>
        <t-alert theme="info" class="user-external-edit-alert">
          外部身份字段只读；此处仅维护管理端启停和门户角色，不影响该人员的用户端访问，也不授予任何子系统业务权限。
        </t-alert>
      </template>
    </t-dialog>

    <t-dialog v-model:visible="resetVisible" placement="center" header="重置本地管理账号密码" width="520px" :confirm-btn="{content:'确认重置',loading:resetSaving}" :close-on-overlay-click="false" @confirm="saveResetPassword">
      <div v-if="resetError" class="error-note">{{resetError}}</div>
      <div class="form-grid">
        <div class="form-field full"><label>新密码 <span class="portal-required">*</span></label><t-input v-model="resetForm.newPassword" type="password" autocomplete="new-password" placeholder="请输入新密码"/></div>
        <div class="form-field full"><label>确认新密码 <span class="portal-required">*</span></label><t-input v-model="resetForm.confirmPassword" type="password" autocomplete="new-password" placeholder="请再次输入新密码"/></div>
      </div>
    </t-dialog>
  </section>
</template>

<script setup>
import {computed,reactive,ref,watch} from 'vue';
import {MessagePlugin} from 'tdesign-vue-next';
import EmptyState from './EmptyState.vue';
import DetailGrid from './DetailGrid.vue';
import TableCellTooltip from './TableCellTooltip.vue';
import {date,source,text,label} from './presentation.js';
import {command} from '../../services/runtime.js';
import {validateLocalPassword} from '../../config/password-policy.js';

const props=defineProps({
  rows:{type:Array,default:()=>[]},
  roles:{type:Array,default:()=>[]},
  organizations:{type:Array,default:()=>[]},
  accessUsers:{type:Array,default:()=>[]},
  canSuper:Boolean
});
const emit=defineEmits(['saved']);

const keyword=ref(''),authType=ref(''),identitySource=ref(''),roleId=ref(''),status=ref('');
const page=ref(1),pageSize=ref(10);
const detailVisible=ref(false),detail=ref(null);
const formVisible=ref(false),formMode=ref('edit'),form=reactive({}),formError=ref(''),saving=ref(false);
const resetVisible=ref(false),resetTarget=ref(null),resetForm=reactive({newPassword:'',confirmPassword:''}),resetError=ref(''),resetSaving=ref(false);

const adminAuthType=row=>row?.authType||'EXTERNAL';
const adminEnabled=row=>row?.enabled!==false;
const authTypeLabel=value=>value==='LOCAL'?'本地账号':'外部身份';
const identitySourceText=row=>text(row?.identitySource)||source(row)||'-';
const authTypeOptions=[{value:'EXTERNAL',label:'外部身份'},{value:'LOCAL',label:'本地账号'}];
const sourceOptions=['闽政通','闽政务','门户本地'].map(value=>({value,label:value}));
const statusOptions=[{value:'ENABLED',label:'启用'},{value:'DISABLED',label:'停用'}];
const roleOptions=computed(()=>props.roles.filter(role=>role.status==='ENABLED'||form.roleIds?.includes(role.id)).map(role=>({value:role.id,label:role.roleName})));
const adminRows=computed(()=>props.rows.filter(row=>row.adminSubject||row.adminAccess||row.kind==='ADMIN'||(row.roleIds||[]).length));
const accessUserOptions=computed(()=>props.accessUsers.filter(user=>['CITIZEN','GOV'].includes(user.userType)&&!adminRows.value.some(admin=>admin.id===user.id||admin.accessUserId===user.id)).map(user=>({value:user.id,label:`${text(user.name)}（${text(user.account)} · ${text(user.identitySource)||source(user)}）`})));

const filtered=computed(()=>{
  const term=keyword.value.trim().toLowerCase();
  return adminRows.value.filter(row=>{
    const matchKeyword=!term||[row.name,row.account].some(value=>text(value).toLowerCase().includes(term));
    const matchType=!authType.value||adminAuthType(row)===authType.value;
    const matchSource=!identitySource.value||identitySourceText(row)===identitySource.value;
    const matchRole=!roleId.value||(row.roleIds||[]).includes(roleId.value);
    const matchStatus=!status.value||(status.value==='ENABLED'?adminEnabled(row):!adminEnabled(row));
    return matchKeyword&&matchType&&matchSource&&matchRole&&matchStatus;
  });
});
const paged=computed(()=>filtered.value.slice((page.value-1)*pageSize.value,page.value*pageSize.value));

const columns=[
  {colKey:'serial',title:'序号',width:64},
  {colKey:'account',title:'管理账号',width:160,ellipsis:true},
  {colKey:'name',title:'姓名',width:120,ellipsis:true},
  {colKey:'authType',title:'认证类型',width:110},
  {colKey:'identitySource',title:'身份来源',width:110},
  {colKey:'roleLabels',title:'门户角色',width:220,ellipsis:true},
  {colKey:'enabled',title:'启用状态',width:110},
  {colKey:'lastLoginAt',title:'最近管理端登录',width:180},
  {colKey:'operation',title:'操作',width:210,fixed:'right'}
];

const detailItems=computed(()=>{
  const row=detail.value||{};
  const items=[
    ['account','管理账号',row.account],['name','姓名',row.name],['authType','认证类型',authTypeLabel(adminAuthType(row))],['identitySource','身份来源',identitySourceText(row)],
    ['roleLabels','门户角色',row.roleLabels||'无管理角色'],['enabled','启用状态',adminEnabled(row)?'启用':'停用'],['lastLoginAt','最近管理端登录',date(row.lastLoginAt)]
  ];
  if(adminAuthType(row)==='LOCAL')items.push(['lockedUntil','锁定至',date(row.lockedUntil)]);
  return items.map(([key,labelText,value])=>({key,label:labelText,value}));
});
const externalIdentityItems=computed(()=>[
  {key:'account',label:'管理账号',value:form.account||'-'},
  {key:'name',label:'姓名',value:form.name||'-'},
  {key:'authType',label:'认证类型',value:authTypeLabel(adminAuthType(form))},
  {key:'identitySource',label:'身份来源',value:identitySourceText(form)},
  {key:'accessUserType',label:'绑定访问身份',value:form.userType?label(form.userType):'-'}
]);

function reset(){keyword.value='';authType.value='';identitySource.value='';roleId.value='';status.value='';page.value=1;}
function openDetail(row){detail.value=JSON.parse(JSON.stringify(row));detailVisible.value=true;}
function assignForm(row){Object.keys(form).forEach(key=>delete form[key]);Object.assign(form,JSON.parse(JSON.stringify(row)));}
function openCreateLocal(){formMode.value='createLocal';assignForm({account:'',name:'',authType:'LOCAL',identitySource:'门户本地',enabled:true,roleIds:[]});formError.value='';formVisible.value=true;}
function openCreateExternal(){formMode.value='createExternal';assignForm({accessUserId:'',authType:'EXTERNAL',enabled:true,roleIds:[]});formError.value='';formVisible.value=true;}
function openEdit(row){formMode.value='edit';assignForm({...row,enabled:adminEnabled(row)});formError.value='';formVisible.value=true;}
function syncExternalCandidate(id){
  const candidate=props.accessUsers.find(user=>user.id===id);
  if(!candidate)return;
  Object.assign(form,{account:candidate.account,name:candidate.name,userType:candidate.userType,identitySource:candidate.identitySource||source(candidate),orgName:candidate.orgName||'',accessUserId:candidate.id});
}

async function toggleStatus(row,enabled){
  const result=await command('setPortalUserStatus',{id:row.id,version:row.version,enabled});
  if(!result.ok){MessagePlugin.error(result.error.message);return;}
  MessagePlugin.success(enabled?'管理用户已启用':'管理用户已停用');emit('saved');
}
async function save(){
  if(saving.value)return;
  if(formMode.value==='createLocal'&&(!form.name?.trim()||!form.account?.trim())){formError.value='请填写必填项';return;}
  if(formMode.value==='createExternal'&&!form.accessUserId){formError.value='请选择需要授权的外部用户';return;}
  saving.value=true;formError.value='';
  const action=formMode.value==='createLocal'?'createLocalPortalUser':formMode.value==='createExternal'?'createExternalPortalAdmin':'savePortalUser';
  const payload=formMode.value==='createLocal'
    ?{account:form.account,name:form.name,roleIds:[...(form.roleIds||[])]}
    :formMode.value==='createExternal'
      ?{accessUserId:form.accessUserId,enabled:form.enabled!==false,roleIds:[...(form.roleIds||[])]}
      :{id:form.id,version:form.version,enabled:form.enabled!==false,roleIds:[...(form.roleIds||[])],name:form.name};
  const result=await command(action,payload);
  saving.value=false;
  if(!result.ok){formError.value=result.error.message;return;}
  formVisible.value=false;MessagePlugin.success(formMode.value==='createLocal'?'本地管理账号已创建':formMode.value==='createExternal'?'外部用户管理资格已授权':'管理用户信息已保存');emit('saved');
}
function resetPassword(row){
  resetTarget.value=row;resetForm.newPassword='';resetForm.confirmPassword='';resetError.value='';resetVisible.value=true;
}
async function saveResetPassword(){
  if(resetSaving.value||!resetTarget.value)return;
  const validation=validateLocalPassword(resetForm);
  if(validation){resetError.value=validation;return;}
  resetSaving.value=true;resetError.value='';
  try{
    const result=await command('resetLocalPassword',{id:resetTarget.value.id,version:resetTarget.value.version,newPassword:resetForm.newPassword,confirmPassword:resetForm.confirmPassword});
    if(!result.ok){resetError.value=result.error.message;return;}
    resetVisible.value=false;MessagePlugin.success('密码重置记录已更新');emit('saved');
  }finally{resetSaving.value=false;}
}
watch(resetVisible,visible=>{if(!visible){resetForm.newPassword='';resetForm.confirmPassword='';resetTarget.value=null;resetError.value='';}});
async function unlock(row){
  const result=await command('unlockLocalUser',{id:row.id,version:row.version});
  if(!result.ok){MessagePlugin.error(result.error.message);return;}
  MessagePlugin.success('管理账号已解除锁定');emit('saved');
}
watch([keyword,authType,identitySource,roleId,status,pageSize],()=>{page.value=1;});
watch(()=>filtered.value.length,()=>{page.value=Math.min(page.value,Math.max(1,Math.ceil(filtered.value.length/pageSize.value)));});
</script>
