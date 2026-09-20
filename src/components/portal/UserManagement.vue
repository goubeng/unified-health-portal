<template>
  <section class="portal-list user-management">
    <Teleport v-if="canSuper" to="#page-header-actions">
      <t-button theme="primary" @click="openCreate">新增本地用户</t-button>
    </Teleport>

    <t-form layout="inline" class="portal-query list-toolbar">
      <t-form-item class="portal-query-keyword query-width-keyword" label="姓名/账号">
        <t-input v-model="keyword" clearable placeholder="请输入姓名或账号"/>
      </t-form-item>
      <t-form-item class="portal-query-select query-width-user-type" label="用户类别">
        <t-select v-model="userType" clearable placeholder="全部" :options="userTypeOptions"/>
      </t-form-item>
      <t-form-item class="portal-query-select query-width-user-type" label="身份来源">
        <t-select v-model="identitySource" clearable placeholder="全部" :options="sourceOptions"/>
      </t-form-item>
      <t-form-item class="portal-query-select query-width-org" label="所属组织">
        <t-select v-model="orgName" clearable filterable placeholder="全部" :options="orgOptions"/>
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
        <template #empty><EmptyState description="暂无符合条件的用户"/></template>
        <template #serial="{rowIndex}">{{(page-1)*pageSize+rowIndex+1}}</template>
        <template #account="{row}"><button class="portal-field-link" @click="openDetail(row)">{{text(row.account)||'-'}}</button></template>
        <template #userType="{row}"><t-tag variant="light">{{label(row.userType)}}</t-tag></template>
        <template #identitySource="{row}">{{text(row.identitySource)||source(row)}}</template>
        <template #roleLabels="{row}">{{text(row.roleLabels)||'无管理角色'}}</template>
        <template #status="{row}">
          <div class="form-switch-control is-table">
            <t-switch
              :value="row.status!=='DISABLED'"
              :disabled="row.userType==='LOCAL'&&!canSuper"
              @change="toggleStatus(row,$event)"
            />
            <span>{{row.status==='DISABLED'?'停用':'启用'}}</span>
          </div>
        </template>
        <template #lastLoginAt="{row}">{{date(row.lastLoginAt)}}</template>
        <template #operation="{row}">
          <div class="row-actions">
            <t-button v-if="canSuper" size="small" variant="text" theme="primary" @click="openEdit(row)">编辑</t-button>
            <t-button v-if="canSuper&&row.userType==='LOCAL'" size="small" variant="text" theme="primary" @click="resetPassword(row)">重置密码</t-button>
            <t-button v-if="canSuper&&row.userType==='LOCAL'&&row.lockedUntil" size="small" variant="text" theme="primary" @click="unlock(row)">解除锁定</t-button>
          </div>
        </template>
      </t-table>
      <t-pagination v-model="page" v-model:page-size="pageSize" :total="filtered.length" :page-size-options="[10,20,50]" show-jumper/>
    </section>

    <t-dialog v-model:visible="detailVisible" placement="center" header="用户详情" width="760px" :footer="false">
      <DetailGrid v-if="detail" :items="detailItems"/>
      <t-alert v-if="detail?.userType!=='LOCAL'" theme="info" class="user-source-alert">
        姓名、账号、用户类别和身份来源等权威身份字段来自{{detail?.identitySource||source(detail)}}，门户不修改上游身份主数据。
      </t-alert>
      <t-alert v-else theme="info" class="user-source-alert">
        门户本地用户由本系统维护；密码与密码Hash不在页面/API中展示。
      </t-alert>
    </t-dialog>

    <t-dialog
      v-model:visible="formVisible"
      placement="center"
      :header="formMode==='create'?'新增本地用户':'编辑用户'"
      width="760px"
      :confirm-btn="{content:'保存',loading:saving}"
      :close-on-overlay-click="false"
      @confirm="save"
    >
      <div v-if="formError" class="error-note">{{formError}}</div>
      <template v-if="formMode==='create'||form.userType==='LOCAL'">
        <div class="form-grid">
          <div class="form-field"><label>登录账号 <span class="portal-required">*</span></label><t-input v-model="form.account" :disabled="formMode!=='create'" placeholder="请输入登录账号"/></div>
          <div class="form-field"><label>姓名 <span class="portal-required">*</span></label><t-input v-model="form.name" placeholder="请输入姓名"/></div>
          <div class="form-field"><label>所属组织</label><t-select v-model="form.orgName" clearable filterable :options="orgOptions"/></div>
          <div class="form-field"><label>手机号</label><t-input v-model="form.mobile" placeholder="可选"/></div>
          <div class="form-field"><label>邮箱</label><t-input v-model="form.email" placeholder="可选"/></div>
          <div class="form-field"><label>启用状态</label><div class="form-switch-control"><t-switch :value="form.status!=='DISABLED'" @change="form.status=$event?'NORMAL':'DISABLED'"/><span>{{form.status==='DISABLED'?'停用':'启用'}}</span></div></div>
          <div class="form-field full"><label>门户角色</label><t-select v-model="form.roleIds" multiple clearable :options="roleOptions"/></div>
        </div>
        <t-alert theme="info" class="user-source-alert">
          A阶段只模拟本地用户资料与角色关系，不生成或保存真实密码。真实凭证、首次改密、锁定策略在B阶段数据库改造后接入。
        </t-alert>
      </template>
      <template v-else>
        <DetailGrid :items="externalIdentityItems"/>
        <div class="form-grid user-external-maintenance">
          <div class="form-field"><label>启用状态</label><div class="form-switch-control"><t-switch :value="form.status!=='DISABLED'" @change="form.status=$event?'NORMAL':'DISABLED'"/><span>{{form.status==='DISABLED'?'停用':'启用'}}</span></div></div>
          <div class="form-field full"><label>门户角色</label><t-select v-model="form.roleIds" multiple clearable :options="roleOptions"/></div>
        </div>
        <p class="muted">外部身份字段只读；此处仅维护门户启停与门户角色，不授予任何子系统业务权限。</p>
      </template>
    </t-dialog>
  </section>
</template>

<script setup>
import {computed,reactive,ref,watch} from 'vue';
import {DialogPlugin,MessagePlugin} from 'tdesign-vue-next';
import EmptyState from './EmptyState.vue';
import DetailGrid from './DetailGrid.vue';
import {date,label,source,text} from './presentation.js';
import {command} from '../../services/runtime.js';

const props=defineProps({
  rows:{type:Array,default:()=>[]},
  roles:{type:Array,default:()=>[]},
  organizations:{type:Array,default:()=>[]},
  canSuper:Boolean
});
const emit=defineEmits(['saved']);

const keyword=ref(''),userType=ref(''),identitySource=ref(''),orgName=ref(''),roleId=ref(''),status=ref('');
const page=ref(1),pageSize=ref(10);
const detailVisible=ref(false),detail=ref(null);
const formVisible=ref(false),formMode=ref('edit'),form=reactive({}),formError=ref(''),saving=ref(false);

const userTypeOptions=['CITIZEN','GOV','LOCAL'].map(value=>({value,label:label(value)}));
const sourceOptions=['闽政通','闽政务','门户本地'].map(value=>({value,label:value}));
const statusOptions=[{value:'NORMAL',label:'启用'},{value:'DISABLED',label:'停用'}];
const roleOptions=computed(()=>props.roles.filter(role=>role.status==='ENABLED'||form.roleIds?.includes(role.id)).map(role=>({value:role.id,label:role.roleName})));
const orgOptions=computed(()=>props.organizations.filter(org=>org.status==='ENABLED').map(org=>({value:org.name,label:org.name})));

const filtered=computed(()=>{
  const term=keyword.value.trim().toLowerCase();
  return props.rows.filter(row=>{
    const matchKeyword=!term||[row.name,row.account].some(value=>text(value).toLowerCase().includes(term));
    const matchType=!userType.value||row.userType===userType.value;
    const matchSource=!identitySource.value||(row.identitySource||source(row))===identitySource.value;
    const matchOrg=!orgName.value||row.orgName===orgName.value;
    const matchRole=!roleId.value||(row.roleIds||[]).includes(roleId.value);
    const matchStatus=!status.value||row.status===status.value;
    return matchKeyword&&matchType&&matchSource&&matchOrg&&matchRole&&matchStatus;
  });
});
const paged=computed(()=>filtered.value.slice((page.value-1)*pageSize.value,page.value*pageSize.value));

const columns=[
  {colKey:'serial',title:'序号',width:64},
  {colKey:'account',title:'用户账号',width:160,ellipsis:true},
  {colKey:'name',title:'姓名',width:120,ellipsis:true},
  {colKey:'userType',title:'用户类别',width:120},
  {colKey:'identitySource',title:'身份来源',width:110},
  {colKey:'orgName',title:'所属组织',width:200,ellipsis:true},
  {colKey:'roleLabels',title:'门户角色',width:190,ellipsis:true},
  {colKey:'status',title:'启用状态',width:120},
  {colKey:'lastLoginAt',title:'最近登录',width:180},
  {colKey:'operation',title:'操作',width:210,fixed:'right'}
];

const detailItems=computed(()=>{
  const row=detail.value||{};
  return [
    ['account','用户账号',row.account],['name','姓名',row.name],['userType','用户类别',label(row.userType)],['identitySource','身份来源',row.identitySource||source(row)],
    ['orgName','所属组织',row.orgName||'-'],['roleLabels','门户角色',row.roleLabels||'无管理角色'],['status','启用状态',row.status==='DISABLED'?'停用':'启用'],
    ['firstLoginAt','首次登录',date(row.firstLoginAt)],['lastLoginAt','最近登录',date(row.lastLoginAt)],['lockedUntil','锁定至',date(row.lockedUntil)]
  ].map(([key,labelText,value])=>({key,label:labelText,value}));
});
const externalIdentityItems=computed(()=>[
  {key:'account',label:'用户账号',value:form.account||'-'},
  {key:'name',label:'姓名',value:form.name||'-'},
  {key:'userType',label:'用户类别',value:label(form.userType)},
  {key:'identitySource',label:'身份来源',value:form.identitySource||source(form)},
  {key:'orgName',label:'所属组织',value:form.orgName||'-'}
]);

function reset(){keyword.value='';userType.value='';identitySource.value='';orgName.value='';roleId.value='';status.value='';page.value=1;}
function openDetail(row){detail.value=JSON.parse(JSON.stringify(row));detailVisible.value=true;}
function assignForm(row){Object.keys(form).forEach(key=>delete form[key]);Object.assign(form,JSON.parse(JSON.stringify(row)));}
function openCreate(){formMode.value='create';assignForm({account:'',name:'',userType:'LOCAL',identitySource:'门户本地',orgName:'',mobile:'',email:'',status:'NORMAL',roleIds:[]});formError.value='';formVisible.value=true;}
function openEdit(row){formMode.value='edit';assignForm(row);formError.value='';formVisible.value=true;}

async function toggleStatus(row,enabled){
  const result=await command('setPortalUserStatus',{id:row.id,version:row.version,status:enabled?'NORMAL':'DISABLED'});
  if(!result.ok){MessagePlugin.error(result.error.message);return;}
  MessagePlugin.success(enabled?'用户已启用':'用户已停用');emit('saved');
}
async function save(){
  if(saving.value)return;
  if(!form.name?.trim()||formMode.value==='create'&&!form.account?.trim()){formError.value='请填写必填项';return;}
  saving.value=true;formError.value='';
  const action=formMode.value==='create'?'createLocalPortalUser':'savePortalUser';
  const payload=formMode.value==='create'
    ?{account:form.account,name:form.name,orgName:form.orgName,mobile:form.mobile,email:form.email,roleIds:[...(form.roleIds||[])]}
    :{id:form.id,version:form.version,status:form.status,roleIds:[...(form.roleIds||[])],name:form.name,orgName:form.orgName,mobile:form.mobile,email:form.email};
  const result=await command(action,payload);
  saving.value=false;
  if(!result.ok){formError.value=result.error.message;return;}
  formVisible.value=false;MessagePlugin.success(formMode.value==='create'?'本地用户已创建（Mock）':'用户信息已保存');emit('saved');
}
function resetPassword(row){
  const dialog=DialogPlugin.confirm({placement:'center',header:'重置密码',body:'确认重置该门户本地用户密码？A阶段只记录重置状态，不生成真实密码。',onConfirm:async()=>{
    const result=await command('resetLocalPassword',{id:row.id,version:row.version});
    if(!result.ok){MessagePlugin.error(result.error.message);return;}
    dialog.hide();MessagePlugin.success('已记录密码重置，首次改密将在真实凭证接入后生效');emit('saved');
  }});
}
async function unlock(row){
  const result=await command('unlockLocalUser',{id:row.id,version:row.version});
  if(!result.ok){MessagePlugin.error(result.error.message);return;}
  MessagePlugin.success('账号已解除锁定');emit('saved');
}
watch([keyword,userType,identitySource,orgName,roleId,status,pageSize],()=>{page.value=1;});
watch(()=>filtered.value.length,()=>{page.value=Math.min(page.value,Math.max(1,Math.ceil(filtered.value.length/pageSize.value)));});
</script>
