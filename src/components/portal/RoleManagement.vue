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
        <template #roleCode="{row}"><TableCellTooltip :text="text(row.roleCode)"><button class="portal-field-link" @click="openDetail(row)">{{text(row.roleCode)}}</button></TableCellTooltip></template>
        <template #status="{row}"><t-tag :theme="row.status==='ENABLED'?'success':'default'" variant="light">{{label(row.status)}}</t-tag></template>
        <template #builtIn="{row}"><t-tag v-if="row.builtIn" variant="light">内置</t-tag><span v-else>自定义</span></template>
        <template #updatedAt="{row}">{{roleUpdatedAt(row.updatedAt)}}</template>
        <template #operation="{row}">
          <div class="row-actions">
            <t-button size="small" variant="text" theme="primary" @click="openEdit(row)">权限配置</t-button>
          </div>
        </template>
      </t-table>
      <t-pagination v-model="page" v-model:page-size="pageSize" :total="filtered.length" :page-size-options="[10,20,50]" show-jumper/>
    </section>

    <t-dialog
      v-model:visible="detailVisible"
      placement="center"
      header="角色查看"
      width="980px"
      :footer="false"
    >
      <template v-if="detail">
        <t-descriptions bordered :column="2" class="role-detail-descriptions">
          <t-descriptions-item label="角色名称">{{text(detail.roleName)||'-'}}</t-descriptions-item>
          <t-descriptions-item label="角色编码">{{text(detail.roleCode)||'-'}}</t-descriptions-item>
          <t-descriptions-item label="启用状态"><t-tag :theme="detail.status==='ENABLED'?'success':'default'" variant="light">{{label(detail.status)}}</t-tag></t-descriptions-item>
          <t-descriptions-item label="角色类型">{{detail.builtIn?'内置角色':'自定义角色'}}</t-descriptions-item>
          <t-descriptions-item label="关联用户数">{{detail.userCount??0}}</t-descriptions-item>
          <t-descriptions-item label="更新时间">{{roleUpdatedAt(detail.updatedAt)}}</t-descriptions-item>
          <t-descriptions-item label="数据范围">ALL_PORTAL</t-descriptions-item>
          <t-descriptions-item label="角色说明">{{text(detail.description)||'-'}}</t-descriptions-item>
        </t-descriptions>

        <div class="role-detail-permission-title">
          <div><h3>门户权限</h3><p>按菜单 → 页面 → 操作查看。仅展示当前角色已拥有的门户权限。</p></div>
          <t-tag variant="light">{{detailPermissions.length}} 项操作权限</t-tag>
        </div>

        <div v-if="detailPermissionGroups.length" class="role-detail-permission-tree">
          <details v-for="group in detailPermissionGroups" :key="group.key" class="role-detail-permission-group" open>
            <summary>
              <span class="role-detail-tree-toggle"><ChevronRightIcon/></span>
              <strong>{{group.menu}}</strong>
              <span>{{group.description}}</span>
              <em>{{group.permissionCount}} 项权限</em>
            </summary>
            <div v-for="pageItem in group.pages" :key="pageItem.name" class="role-detail-permission-page">
              <span>{{pageItem.name}}</span>
              <div>
                <t-tag v-for="action in pageItem.actions" :key="action.code" size="small" theme="primary" variant="light">{{action.label}}</t-tag>
              </div>
            </div>
          </details>
        </div>
        <EmptyState v-else description="当前角色暂无门户操作权限"/>
      </template>
    </t-dialog>

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
      <t-alert v-if="form.id==='ROLE_SUPER'" theme="warning" class="role-permission-note">
        门户超级管理员必须保持启用并保留超级管理权限；系统同时保护最后一个有效超级管理员账号。
      </t-alert>
      <div class="form-grid role-basic-form">
        <div class="form-field"><label>角色编码 <span class="portal-required">*</span></label><t-input v-model="form.roleCode" :disabled="Boolean(form.builtIn)" placeholder="例如 CUSTOM_OPERATOR"/></div>
        <div class="form-field"><label>角色名称 <span class="portal-required">*</span></label><t-input v-model="form.roleName" :disabled="Boolean(form.builtIn)" placeholder="请输入角色名称"/></div>
        <div class="form-field"><label>启用状态</label><t-switch :value="form.status==='ENABLED'" :disabled="form.id==='ROLE_SUPER'" @change="form.status=$event?'ENABLED':'DISABLED'"/></div>
        <div class="form-field"><label>数据范围</label><t-input value="ALL_PORTAL" disabled/></div>
        <div class="form-field full"><label>角色说明</label><t-textarea v-model="form.description" :autosize="{minRows:2,maxRows:4}"/></div>
      </div>

      <div class="role-permission-title">
        <div><h3>门户权限</h3><p>按菜单 → 页面 → 操作配置。仅控制统一门户本身，不授予任何子系统业务权限。</p></div>
        <t-tag variant="light">{{selectedPermissions.length}} 项操作权限</t-tag>
      </div>

      <div class="role-permission-groups">
        <section v-for="group in permissionGroups" :key="group.key" class="role-permission-group">
          <div class="role-permission-group-head">
            <t-checkbox
              :checked="isGroupChecked(group)"
              :indeterminate="isGroupIndeterminate(group)"
              @change="toggleGroup(group,$event)"
            >
              {{group.menu}}
            </t-checkbox>
            <span>{{group.description}}</span>
          </div>
          <div class="role-permission-pages">
            <div v-for="pageItem in group.pages" :key="pageItem.name" class="role-permission-page">
              <strong>{{pageItem.name}}</strong>
              <div class="role-permission-actions">
                <t-checkbox
                  v-for="[code,actionLabel] in pageItem.actions"
                  :key="code"
                  :checked="selectedPermissions.includes(code)"
                  :disabled="code==='system:super'&&form.id!=='ROLE_SUPER'"
                  @change="togglePermission(code,$event)"
                >{{actionLabel}}</t-checkbox>
              </div>
            </div>
          </div>
        </section>
      </div>


    </t-dialog>
  </section>
</template>

<script setup>
import {computed,reactive,ref,watch} from 'vue';
import {MessagePlugin} from 'tdesign-vue-next';
import {ChevronRightIcon} from 'tdesign-icons-vue-next';
import EmptyState from './EmptyState.vue';
import TableCellTooltip from './TableCellTooltip.vue';
import {label,text} from './presentation.js';
import {command} from '../../services/runtime.js';
import {rolePermissionGroups,permissionsFromScopes} from '../../config/pages.js';

const props=defineProps({rows:{type:Array,default:()=>[]}});
const emit=defineEmits(['saved']);

const keyword=ref(''),status=ref(''),page=ref(1),pageSize=ref(10);
const detailVisible=ref(false),detail=ref(null),formVisible=ref(false),form=reactive({}),formError=ref(''),saving=ref(false);
const statusOptions=[{value:'ENABLED',label:'启用'},{value:'DISABLED',label:'停用'}];

const permissionGroups=rolePermissionGroups;

const filtered=computed(()=>{
  const term=keyword.value.trim().toLowerCase();
  return props.rows.filter(row=>{
    const matchKeyword=!term||[row.roleCode,row.roleName,row.description].some(value=>text(value).toLowerCase().includes(term));
    return matchKeyword&&(!status.value||row.status===status.value);
  });
});
const paged=computed(()=>filtered.value.slice((page.value-1)*pageSize.value,page.value*pageSize.value));
const selectedPermissions=computed(()=>form.permissions||[]);
const rolePermissions=row=>Array.isArray(row?.permissions)?row.permissions:permissionsFromScopes(row?.scopes||[]);
const detailPermissions=computed(()=>detail.value?rolePermissions(detail.value):[]);
const detailPermissionGroups=computed(()=>permissionGroups.map(group=>{
  const pages=group.pages.map(pageItem=>({
    name:pageItem.name,
    actions:pageItem.actions
      .filter(([code])=>detailPermissions.value.includes(code))
      .map(([code,actionLabel])=>({code,label:actionLabel}))
  })).filter(pageItem=>pageItem.actions.length);
  return {...group,pages,permissionCount:pages.reduce((count,pageItem)=>count+pageItem.actions.length,0)};
}).filter(group=>group.pages.length));

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

function roleUpdatedAt(value){
  if(!value||!Number.isFinite(Date.parse(value)))return '-';
  const d=new Date(value),pad=n=>String(n).padStart(2,'0');
  return `${d.getFullYear()}/${d.getMonth()+1}/${d.getDate()} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
}
function reset(){keyword.value='';status.value='';page.value=1;}
function assignForm(row){
  Object.keys(form).forEach(key=>delete form[key]);
  const copy=JSON.parse(JSON.stringify(row));
  copy.permissions=Array.isArray(copy.permissions)?copy.permissions:permissionsFromScopes(copy.scopes||[]);
  delete copy.scopes;
  Object.assign(form,copy);
}
function openCreate(){assignForm({roleCode:'',roleName:'',description:'',status:'ENABLED',permissions:[],builtIn:false});formError.value='';formVisible.value=true;}
function openDetail(row){detail.value=JSON.parse(JSON.stringify(row));detailVisible.value=true;}
function openEdit(row){assignForm(row);formError.value='';formVisible.value=true;}
const groupCodes=group=>group.pages.flatMap(page=>page.actions.map(([code])=>code));
const isGroupChecked=group=>groupCodes(group).every(code=>selectedPermissions.value.includes(code));
const isGroupIndeterminate=group=>{
  const selected=groupCodes(group).filter(code=>selectedPermissions.value.includes(code)).length;
  return selected>0&&selected<groupCodes(group).length;
};
function togglePermission(code,checked){
  if(code==='system:super'&&form.id!=='ROLE_SUPER')return;
  const next=new Set(form.permissions||[]);
  checked?next.add(code):next.delete(code);
  if(form.id==='ROLE_SUPER')next.add('system:super');
  form.permissions=[...next];
}
function toggleGroup(group,checked){
  const next=new Set(form.permissions||[]);
  for(const code of groupCodes(group)){
    if(code==='system:super'&&form.id!=='ROLE_SUPER')continue;
    checked?next.add(code):next.delete(code);
  }
  if(form.id==='ROLE_SUPER')next.add('system:super');
  form.permissions=[...next];
}
async function save(){
  if(saving.value)return;
  if(!form.roleCode?.trim()||!form.roleName?.trim()){formError.value='角色编码与角色名称为必填';return;}
  saving.value=true;formError.value='';
  const result=await command('saveSystemRole',{
    id:form.id,version:form.version,roleCode:form.roleCode,roleName:form.roleName,
    description:form.description||'',status:form.status,permissions:[...(form.permissions||[])]
  });
  saving.value=false;
  if(!result.ok){formError.value=result.error.message;return;}
  formVisible.value=false;MessagePlugin.success('角色权限已保存');emit('saved');
}
watch([keyword,status,pageSize],()=>{page.value=1;});
watch(()=>filtered.value.length,()=>{page.value=Math.min(page.value,Math.max(1,Math.ceil(filtered.value.length/pageSize.value)));});
</script>