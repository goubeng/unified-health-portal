<template>
  <section class="portal-list role-management">
    <Teleport to="#page-header-actions">
      <t-button theme="primary" @click="openCreate">新增角色</t-button>
    </Teleport>

    <t-form layout="inline" class="portal-query list-toolbar">
      <t-form-item class="portal-query-keyword query-width-keyword" label="关键词">
        <t-input v-model="keyword" clearable placeholder="角色名称 / 角色编码 / 说明"/>
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
        <template #empty><EmptyState description="暂无符合条件的角色"/></template>
        <template #serial="{rowIndex}">{{(page-1)*pageSize+rowIndex+1}}</template>
        <template #roleCode="{row}"><button class="portal-field-link" @click="openEdit(row)">{{text(row.roleCode)}}</button></template>
        <template #status="{row}"><t-tag :theme="row.status==='ENABLED'?'success':'default'" variant="light">{{label(row.status)}}</t-tag></template>
        <template #builtIn="{row}"><t-tag v-if="row.builtIn" variant="light">内置</t-tag><span v-else>自定义</span></template>
        <template #operation="{row}">
          <div class="row-actions">
            <t-button size="small" variant="text" theme="primary" @click="openEdit(row)">权限配置</t-button>
          </div>
        </template>
      </t-table>
      <t-pagination v-model="page" v-model:page-size="pageSize" :total="filtered.length" :page-size-options="[10,20,50]" show-jumper/>
    </section>

    <t-dialog
      v-model:visible="formVisible"
      placement="center"
      :header="form.id?'角色权限配置':'新增角色'"
      width="920px"
      :confirm-btn="{content:'保存',loading:saving}"
      :close-on-overlay-click="false"
      @confirm="save"
    >
      <div v-if="formError" class="error-note">{{formError}}</div>
      <div class="form-grid role-basic-form">
        <div class="form-field"><label>角色编码 <span class="portal-required">*</span></label><t-input v-model="form.roleCode" :disabled="Boolean(form.builtIn)" placeholder="例如 CUSTOM_OPERATOR"/></div>
        <div class="form-field"><label>角色名称 <span class="portal-required">*</span></label><t-input v-model="form.roleName" :disabled="Boolean(form.builtIn)" placeholder="请输入角色名称"/></div>
        <div class="form-field"><label>启用状态</label><t-switch :value="form.status==='ENABLED'" :disabled="form.id==='ROLE_SUPER'" :label="['启用','停用']" @change="form.status=$event?'ENABLED':'DISABLED'"/></div>
        <div class="form-field"><label>数据范围</label><t-input value="ALL_PORTAL" disabled/></div>
        <div class="form-field full"><label>角色说明</label><t-textarea v-model="form.description" :autosize="{minRows:2,maxRows:4}"/></div>
      </div>

      <div class="role-permission-title">
        <div><h3>门户权限</h3><p>按菜单 → 页面 → 操作配置。仅控制统一门户本身，不授予任何子系统业务权限。</p></div>
        <t-tag variant="light">{{selectedScopes.length}} 项权限范围</t-tag>
      </div>

      <div class="role-permission-groups">
        <section v-for="group in permissionGroups" :key="group.scope" class="role-permission-group">
          <div class="role-permission-group-head">
            <t-checkbox
              :checked="selectedScopes.includes(group.scope)"
              :disabled="group.scope==='super'&&form.id!=='ROLE_SUPER'"
              @change="toggleScope(group.scope,$event)"
            >
              {{group.menu}}
            </t-checkbox>
            <span>{{group.description}}</span>
          </div>
          <div class="role-permission-pages">
            <div v-for="pageItem in group.pages" :key="pageItem.name" class="role-permission-page">
              <strong>{{pageItem.name}}</strong>
              <div class="role-permission-actions">
                <t-tag v-for="action in pageItem.actions" :key="action" size="small" variant="light">{{action}}</t-tag>
              </div>
            </div>
          </div>
        </section>
      </div>

      <t-alert v-if="form.id==='ROLE_SUPER'" theme="warning" class="role-permission-note">
        门户超级管理员必须保持启用并保留超级管理权限；系统同时保护最后一个有效超级管理员账号。
      </t-alert>
    </t-dialog>
  </section>
</template>

<script setup>
import {computed,reactive,ref,watch} from 'vue';
import {MessagePlugin} from 'tdesign-vue-next';
import EmptyState from './EmptyState.vue';
import {label,text} from './presentation.js';
import {command} from '../../services/runtime.js';

const props=defineProps({rows:{type:Array,default:()=>[]}});
const emit=defineEmits(['saved']);

const keyword=ref(''),status=ref(''),page=ref(1),pageSize=ref(10);
const formVisible=ref(false),form=reactive({}),formError=ref(''),saving=ref(false);
const statusOptions=[{value:'ENABLED',label:'启用'},{value:'DISABLED',label:'停用'}];

const permissionGroups=[
  {scope:'application',menu:'应用管理',description:'应用目录与入口资格',pages:[
    {name:'应用列表',actions:['查看','新增','编辑','启停','连接配置']},
    {name:'应用访问申请',actions:['查看','通过','驳回']},
    {name:'子系统账号开通申请',actions:['查看','处理']}
  ]},
  {scope:'integration',menu:'运行监控',description:'SSO / TODO / MESSAGE接入运行',pages:[
    {name:'运行监控',actions:['查看','查看详情']},
    {name:'接入配置',actions:['查看','维护']}
  ]},
  {scope:'identity',menu:'身份与子系统映射',description:'账号映射、审核与冲突处理',pages:[
    {name:'身份与子系统映射',actions:['查看','审核','解绑']},
    {name:'关联冲突处理',actions:['查看','处理']}
  ]},
  {scope:'announcement',menu:'工作台',description:'门户通知公告维护',pages:[
    {name:'通知公告管理',actions:['查看','新增','编辑','提交','发布','撤回']}
  ]},
  {scope:'system',menu:'系统管理',description:'用户、组织、字典日常维护',pages:[
    {name:'用户管理',actions:['查看','门户启停']},
    {name:'组织管理',actions:['查看','新增','编辑']},
    {name:'字典管理',actions:['查看','维护']}
  ]},
  {scope:'audit',menu:'日志审计',description:'登录、访问、操作、接口与异常日志',pages:[
    {name:'日志审计',actions:['查看','查询','异常处理']}
  ]},
  {scope:'super',menu:'超级管理',description:'高风险系统能力，仅内置超级管理员',pages:[
    {name:'角色管理',actions:['新增角色','权限配置','管理员授权']},
    {name:'本地账号管理',actions:['新增本地用户','重置密码','解除锁定']},
    {name:'关键配置',actions:['维护系统规则','删除关键数据']}
  ]}
];

const filtered=computed(()=>{
  const term=keyword.value.trim().toLowerCase();
  return props.rows.filter(row=>{
    const matchKeyword=!term||[row.roleCode,row.roleName,row.description].some(value=>text(value).toLowerCase().includes(term));
    return matchKeyword&&(!status.value||row.status===status.value);
  });
});
const paged=computed(()=>filtered.value.slice((page.value-1)*pageSize.value,page.value*pageSize.value));
const selectedScopes=computed(()=>form.scopes||[]);

const columns=[
  {colKey:'serial',title:'序号',width:64},
  {colKey:'roleCode',title:'角色编码',width:170,ellipsis:true},
  {colKey:'roleName',title:'角色名称',width:170,ellipsis:true},
  {colKey:'description',title:'角色说明',minWidth:280,ellipsis:true},
  {colKey:'builtIn',title:'角色类型',width:100},
  {colKey:'userCount',title:'关联用户数',width:110},
  {colKey:'status',title:'启用状态',width:100},
  {colKey:'updatedAt',title:'更新时间',width:180,ellipsis:true},
  {colKey:'operation',title:'操作',width:120,fixed:'right'}
];

function reset(){keyword.value='';status.value='';page.value=1;}
function assignForm(row){Object.keys(form).forEach(key=>delete form[key]);Object.assign(form,JSON.parse(JSON.stringify(row)));}
function openCreate(){assignForm({roleCode:'',roleName:'',description:'',status:'ENABLED',scopes:[],builtIn:false});formError.value='';formVisible.value=true;}
function openEdit(row){assignForm(row);formError.value='';formVisible.value=true;}
function toggleScope(scope,checked){
  if(scope==='super'&&form.id!=='ROLE_SUPER')return;
  const next=new Set(form.scopes||[]);
  checked?next.add(scope):next.delete(scope);
  if(form.id==='ROLE_SUPER')next.add('super');
  form.scopes=[...next];
}
async function save(){
  if(saving.value)return;
  if(!form.roleCode?.trim()||!form.roleName?.trim()){formError.value='角色编码与角色名称为必填';return;}
  saving.value=true;formError.value='';
  const result=await command('saveSystemRole',{
    id:form.id,version:form.version,roleCode:form.roleCode,roleName:form.roleName,
    description:form.description||'',status:form.status,scopes:[...(form.scopes||[])]
  });
  saving.value=false;
  if(!result.ok){formError.value=result.error.message;return;}
  formVisible.value=false;MessagePlugin.success('角色权限已保存');emit('saved');
}
watch([keyword,status,pageSize],()=>{page.value=1;});
watch(()=>filtered.value.length,()=>{page.value=Math.min(page.value,Math.max(1,Math.ceil(filtered.value.length/pageSize.value)));});
</script>
