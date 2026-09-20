<template>
  <section class="portal-list organization-management">
    <Teleport to="#page-header-actions">
      <t-button theme="primary" @click="openCreate">新增本地组织</t-button>
    </Teleport>

    <t-form layout="inline" class="portal-query list-toolbar">
      <t-form-item class="portal-query-keyword query-width-keyword" label="关键词">
        <t-input v-model="keyword" clearable placeholder="组织名称 / 组织编码"/>
      </t-form-item>
      <t-form-item class="portal-query-select query-width-kind" label="组织类型">
        <t-select v-model="type" clearable placeholder="全部" :options="typeOptions"/>
      </t-form-item>
      <t-form-item class="portal-query-select query-width-user-type" label="数据来源">
        <t-select v-model="sourceValue" clearable placeholder="全部" :options="sourceOptions"/>
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
        <template #empty><EmptyState description="暂无符合条件的组织"/></template>
        <template #serial="{rowIndex}">{{(page-1)*pageSize+rowIndex+1}}</template>
        <template #code="{row}"><button class="portal-field-link" @click="openDetail(row)">{{text(row.code)}}</button></template>
        <template #type="{row}">{{typeLabel(row.type)}}</template>
        <template #source="{row}"><t-tag variant="light">{{sourceLabel(row.source)}}</t-tag></template>
        <template #status="{row}"><t-tag :theme="row.status==='ENABLED'?'success':'default'" variant="light">{{label(row.status)}}</t-tag></template>
        <template #operation="{row}">
          <div class="row-actions">
            <t-button v-if="row.source==='PORTAL_LOCAL'" size="small" variant="text" theme="primary" @click="openEdit(row)">编辑</t-button>
            <t-button v-if="canSuper&&row.source==='PORTAL_LOCAL'" size="small" variant="text" theme="danger" @click="remove(row)">删除</t-button>
          </div>
        </template>
      </t-table>
      <t-pagination v-model="page" v-model:page-size="pageSize" :total="filtered.length" :page-size-options="[10,20,50]" show-jumper/>
    </section>

    <t-dialog v-model:visible="detailVisible" placement="center" header="组织详情" width="760px" :footer="false">
      <DetailGrid v-if="detail" :items="detailItems"/>
      <t-alert v-if="detail?.source==='MINZHENGWU'" theme="info" class="organization-source-alert">
        该组织来自闽政务组织索引，门户仅展示引用，不维护上游权威组织主数据。
      </t-alert>
    </t-dialog>

    <t-dialog
      v-model:visible="formVisible"
      placement="center"
      :header="form.id?'编辑组织':'新增本地组织'"
      width="760px"
      :confirm-btn="{content:'保存',loading:saving}"
      :close-on-overlay-click="false"
      @confirm="save"
    >
      <div v-if="formError" class="error-note">{{formError}}</div>
      <div class="form-grid">
        <div class="form-field"><label>组织编码 <span class="portal-required">*</span></label><t-input v-model="form.code" :disabled="Boolean(form.id)" placeholder="请输入组织编码"/></div>
        <div class="form-field"><label>组织名称 <span class="portal-required">*</span></label><t-input v-model="form.name" placeholder="请输入组织名称"/></div>
        <div class="form-field"><label>组织类型</label><t-select v-model="form.type" :options="typeOptions"/></div>
        <div class="form-field"><label>上级组织</label><t-select v-model="form.parentId" clearable filterable :options="parentOptions"/></div>
        <div class="form-field"><label>数据来源</label><t-input value="门户本地" disabled/></div>
        <div class="form-field"><label>启用状态</label><div class="form-switch-control"><t-switch :value="form.status==='ENABLED'" @change="form.status=$event?'ENABLED':'DISABLED'"/><span>{{form.status==='ENABLED'?'启用':'停用'}}</span></div></div>
        <div class="form-field full"><label>备注</label><t-textarea v-model="form.remark" :autosize="{minRows:3,maxRows:5}"/></div>
      </div>
    </t-dialog>
  </section>
</template>

<script setup>
import {computed,reactive,ref,watch} from 'vue';
import {DialogPlugin,MessagePlugin} from 'tdesign-vue-next';
import EmptyState from './EmptyState.vue';
import DetailGrid from './DetailGrid.vue';
import {date,label,text} from './presentation.js';
import {command} from '../../services/runtime.js';

const props=defineProps({
  rows:{type:Array,default:()=>[]},
  typeItems:{type:Array,default:()=>[]},
  canSuper:Boolean
});
const emit=defineEmits(['saved']);

const keyword=ref(''),type=ref(''),sourceValue=ref(''),status=ref(''),page=ref(1),pageSize=ref(10);
const detailVisible=ref(false),detail=ref(null),formVisible=ref(false),form=reactive({}),formError=ref(''),saving=ref(false);
const statusOptions=[{value:'ENABLED',label:'启用'},{value:'DISABLED',label:'停用'}];
const sourceOptions=[{value:'MINZHENGWU',label:'闽政务'},{value:'PORTAL_LOCAL',label:'门户本地'}];
const typeOptions=computed(()=>{
  const items=props.typeItems.filter(item=>item.typeCode==='organization_type'&&item.status==='ENABLED');
  return items.length?items.map(item=>({value:item.value,label:item.label})):[
    {value:'PORTAL_UNIT',label:'门户单位'},{value:'GOV_DEPARTMENT',label:'政务部门'},{value:'OTHER',label:'其他组织'}
  ];
});
const parentOptions=computed(()=>props.rows.filter(row=>row.status==='ENABLED'&&row.id!==form.id).map(row=>({value:row.id,label:row.path||row.name})));
const typeLabel=value=>typeOptions.value.find(item=>item.value===value)?.label||text(value);
const sourceLabel=value=>({MINZHENGWU:'闽政务',PORTAL_LOCAL:'门户本地',MINZHENGTONG:'闽政通'}[value]||text(value));

const filtered=computed(()=>{
  const term=keyword.value.trim().toLowerCase();
  return props.rows.filter(row=>{
    const matchKeyword=!term||[row.name,row.code,row.path].some(value=>text(value).toLowerCase().includes(term));
    return matchKeyword&&(!type.value||row.type===type.value)&&(!sourceValue.value||row.source===sourceValue.value)&&(!status.value||row.status===status.value);
  });
});
const paged=computed(()=>filtered.value.slice((page.value-1)*pageSize.value,page.value*pageSize.value));
const columns=[
  {colKey:'serial',title:'序号',width:64},
  {colKey:'code',title:'组织编码',width:160,ellipsis:true},
  {colKey:'name',title:'组织名称',width:180,ellipsis:true},
  {colKey:'type',title:'组织类型',width:120},
  {colKey:'parentName',title:'上级组织',width:180,ellipsis:true},
  {colKey:'path',title:'组织路径',minWidth:260,ellipsis:true},
  {colKey:'source',title:'数据来源',width:110},
  {colKey:'status',title:'启用状态',width:100},
  {colKey:'operation',title:'操作',width:130,fixed:'right'}
];
const detailItems=computed(()=>{
  const row=detail.value||{};
  return [
    ['code','组织编码',row.code],['name','组织名称',row.name],['type','组织类型',typeLabel(row.type)],['parentName','上级组织',row.parentName||'-'],
    ['path','组织路径',row.path],['source','数据来源',sourceLabel(row.source)],['status','启用状态',label(row.status)],['remark','备注',row.remark||'-'],
    ['createdAt','创建时间',date(row.createdAt)],['updatedAt','更新时间',date(row.updatedAt)]
  ].map(([key,labelText,value])=>({key,label:labelText,value}));
});

function reset(){keyword.value='';type.value='';sourceValue.value='';status.value='';page.value=1;}
function openDetail(row){detail.value=JSON.parse(JSON.stringify(row));detailVisible.value=true;}
function assign(row){Object.keys(form).forEach(key=>delete form[key]);Object.assign(form,JSON.parse(JSON.stringify(row)));}
function openCreate(){assign({code:'',name:'',type:typeOptions.value[0]?.value||'OTHER',parentId:null,source:'PORTAL_LOCAL',status:'ENABLED',sortOrder:0,remark:''});formError.value='';formVisible.value=true;}
function openEdit(row){assign(row);formError.value='';formVisible.value=true;}
async function save(){
  if(saving.value)return;
  if(!form.code?.trim()||!form.name?.trim()){formError.value='组织编码与组织名称为必填';return;}
  saving.value=true;formError.value='';
  const result=await command('saveOrganization',{...JSON.parse(JSON.stringify(form)),source:'PORTAL_LOCAL'});
  saving.value=false;
  if(!result.ok){formError.value=result.error.message;return;}
  formVisible.value=false;MessagePlugin.success('组织信息已保存');emit('saved');
}
function remove(row){
  const dialog=DialogPlugin.confirm({placement:'center',header:'删除组织',body:'确认删除该门户本地组织？存在下级组织或用户引用时将拒绝删除。',onConfirm:async()=>{
    const result=await command('removeOrganization',{id:row.id,version:row.version});
    if(!result.ok){MessagePlugin.error(result.error.message);return;}
    dialog.hide();MessagePlugin.success('组织已删除');emit('saved');
  }});
}
watch([keyword,type,sourceValue,status,pageSize],()=>{page.value=1;});
watch(()=>filtered.value.length,()=>{page.value=Math.min(page.value,Math.max(1,Math.ceil(filtered.value.length/pageSize.value)));});
</script>
