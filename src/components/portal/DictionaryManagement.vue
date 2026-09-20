<template>
  <section class="dictionary-management">
    <Teleport to="#page-header-actions">
      <t-button variant="outline" theme="primary" @click="openTypeCreate">新增字典类型</t-button>
      <t-button theme="primary" :disabled="!selectedType||selectedType.systemLocked" @click="openItemCreate">新增字典项</t-button>
    </Teleport>

    <div class="dictionary-layout">
      <section class="panel dictionary-types-panel">
        <div class="section-head">
          <h2>字典类型 <span class="portal-count">{{types.length}}</span></h2>
        </div>
        <t-input v-model="typeKeyword" clearable placeholder="搜索名称 / 编码"/>
        <div class="dictionary-type-list">
          <button
            v-for="item in filteredTypes"
            :key="item.id"
            type="button"
            class="dictionary-type-item"
            :class="{active:item.code===selectedTypeCode}"
            @click="selectedTypeCode=item.code"
          >
            <span>
              <strong>{{text(item.name)}}</strong>
              <small>{{text(item.code)}}</small>
            </span>
            <t-tag v-if="item.systemLocked" size="small" variant="light">系统受控</t-tag>
          </button>
          <EmptyState v-if="!filteredTypes.length" description="暂无字典类型"/>
        </div>
      </section>

      <section class="panel dictionary-items-panel">
        <div class="dictionary-items-head">
          <div>
            <h2>{{selectedType?.name||'字典项'}}</h2>
            <p>{{selectedType?.description||'请选择左侧字典类型'}}</p>
          </div>
          <div v-if="selectedType" class="dictionary-type-actions">
            <t-tag :theme="selectedType.status==='ENABLED'?'success':'default'" variant="light">{{label(selectedType.status)}}</t-tag>
            <t-button size="small" variant="text" theme="primary" @click="openTypeEdit(selectedType)">编辑类型</t-button>
          </div>
        </div>

        <t-alert v-if="selectedType?.systemLocked" theme="info" class="dictionary-lock-alert">
          系统受控字典只能维护显示标签、排序和启用状态；不能新增代码未支持的状态/协议，也不能修改字典值。
        </t-alert>

        <t-form v-if="selectedType" layout="inline" class="portal-query list-toolbar dictionary-query">
          <t-form-item class="portal-query-keyword query-width-keyword" label="关键词">
            <t-input v-model="itemKeyword" clearable placeholder="标签 / 值"/>
          </t-form-item>
          <t-form-item class="portal-query-select query-width-status" label="启用状态">
            <t-select v-model="itemStatus" clearable placeholder="全部" :options="statusOptions"/>
          </t-form-item>
          <t-form-item class="portal-query-action">
            <t-button theme="default" variant="outline" @click="resetItemQuery">重置</t-button>
          </t-form-item>
        </t-form>

        <t-table v-if="selectedType" row-key="id" :data="pagedItems" :columns="columns" hover table-layout="fixed" size="medium">
          <template #empty><EmptyState description="当前字典类型暂无字典项"/></template>
          <template #serial="{rowIndex}">{{(page-1)*pageSize+rowIndex+1}}</template>
          <template #label="{row}"><button class="portal-field-link" @click="openItemEdit(row)">{{text(row.label)}}</button></template>
          <template #status="{row}"><t-tag :theme="row.status==='ENABLED'?'success':'default'" variant="light">{{label(row.status)}}</t-tag></template>
          <template #operation="{row}"><t-button size="small" variant="text" theme="primary" @click="openItemEdit(row)">编辑</t-button></template>
        </t-table>
        <t-pagination v-if="selectedType" v-model="page" v-model:page-size="pageSize" :total="filteredItems.length" :page-size-options="[10,20,50]" show-jumper/>
      </section>
    </div>

    <t-dialog
      v-model:visible="typeDialogVisible"
      placement="center"
      :header="typeForm.id?'编辑字典类型':'新增字典类型'"
      width="680px"
      :confirm-btn="{content:'保存',loading:saving}"
      :close-on-overlay-click="false"
      @confirm="saveType"
    >
      <div v-if="formError" class="error-note">{{formError}}</div>
      <div class="form-grid">
        <div class="form-field"><label>字典编码 <span class="portal-required">*</span></label><t-input v-model="typeForm.code" :disabled="Boolean(typeForm.systemLocked)||Boolean(typeForm.id)" placeholder="请输入唯一编码"/></div>
        <div class="form-field"><label>字典名称 <span class="portal-required">*</span></label><t-input v-model="typeForm.name"/></div>
        <div class="form-field"><label>启用状态</label><t-switch :value="typeForm.status==='ENABLED'" :label="['启用','停用']" @change="typeForm.status=$event?'ENABLED':'DISABLED'"/></div>
        <div class="form-field"><label>排序</label><t-input-number v-model="typeForm.sortOrder" :decimal-places="0"/></div>
        <div class="form-field full"><label>说明</label><t-textarea v-model="typeForm.description" :autosize="{minRows:3,maxRows:5}"/></div>
      </div>
    </t-dialog>

    <t-dialog
      v-model:visible="itemDialogVisible"
      placement="center"
      :header="itemForm.id?'编辑字典项':'新增字典项'"
      width="680px"
      :confirm-btn="{content:'保存',loading:saving}"
      :close-on-overlay-click="false"
      @confirm="saveItem"
    >
      <div v-if="formError" class="error-note">{{formError}}</div>
      <div class="form-grid">
        <div class="form-field"><label>所属字典</label><t-input :value="selectedType?.name||''" disabled/></div>
        <div class="form-field"><label>显示标签 <span class="portal-required">*</span></label><t-input v-model="itemForm.label"/></div>
        <div class="form-field"><label>字典值 <span class="portal-required">*</span></label><t-input v-model="itemForm.value" :disabled="Boolean(selectedType?.systemLocked)||Boolean(itemForm.id)" placeholder="请输入稳定值"/></div>
        <div class="form-field"><label>启用状态</label><t-switch :value="itemForm.status==='ENABLED'" :label="['启用','停用']" @change="itemForm.status=$event?'ENABLED':'DISABLED'"/></div>
        <div class="form-field"><label>排序</label><t-input-number v-model="itemForm.sortOrder" :decimal-places="0"/></div>
        <div class="form-field full"><label>备注</label><t-textarea v-model="itemForm.remark" :autosize="{minRows:3,maxRows:5}"/></div>
      </div>
    </t-dialog>
  </section>
</template>

<script setup>
import {computed,reactive,ref,watch} from 'vue';
import {MessagePlugin} from 'tdesign-vue-next';
import EmptyState from './EmptyState.vue';
import {label,text} from './presentation.js';
import {command} from '../../services/runtime.js';

const props=defineProps({types:{type:Array,default:()=>[]},items:{type:Array,default:()=>[]}});
const emit=defineEmits(['saved']);

const selectedTypeCode=ref(''),typeKeyword=ref(''),itemKeyword=ref(''),itemStatus=ref(''),page=ref(1),pageSize=ref(10);
const typeDialogVisible=ref(false),itemDialogVisible=ref(false),typeForm=reactive({}),itemForm=reactive({}),formError=ref(''),saving=ref(false);
const statusOptions=[{value:'ENABLED',label:'启用'},{value:'DISABLED',label:'停用'}];

const types=computed(()=>[...props.types].sort((a,b)=>(a.sortOrder||0)-(b.sortOrder||0)));
const selectedType=computed(()=>types.value.find(item=>item.code===selectedTypeCode.value)||types.value[0]||null);
const filteredTypes=computed(()=>{
  const term=typeKeyword.value.trim().toLowerCase();
  return types.value.filter(item=>!term||[item.name,item.code].some(value=>text(value).toLowerCase().includes(term)));
});
const filteredItems=computed(()=>{
  const term=itemKeyword.value.trim().toLowerCase(),code=selectedType.value?.code;
  return props.items.filter(item=>item.typeCode===code)
    .filter(item=>(!term||[item.label,item.value].some(value=>text(value).toLowerCase().includes(term)))&&(!itemStatus.value||item.status===itemStatus.value))
    .sort((a,b)=>(a.sortOrder||0)-(b.sortOrder||0));
});
const pagedItems=computed(()=>filteredItems.value.slice((page.value-1)*pageSize.value,page.value*pageSize.value));
const columns=[
  {colKey:'serial',title:'序号',width:64},
  {colKey:'label',title:'显示标签',minWidth:180,ellipsis:true},
  {colKey:'value',title:'字典值',width:180,ellipsis:true},
  {colKey:'sortOrder',title:'排序',width:90},
  {colKey:'status',title:'启用状态',width:100},
  {colKey:'remark',title:'备注',minWidth:240,ellipsis:true},
  {colKey:'operation',title:'操作',width:100,fixed:'right'}
];

function resetItemQuery(){itemKeyword.value='';itemStatus.value='';page.value=1;}
function assign(target,row){Object.keys(target).forEach(key=>delete target[key]);Object.assign(target,JSON.parse(JSON.stringify(row)));}
function openTypeCreate(){assign(typeForm,{code:'',name:'',description:'',status:'ENABLED',sortOrder:types.value.length+1,systemLocked:false});formError.value='';typeDialogVisible.value=true;}
function openTypeEdit(row){assign(typeForm,row);formError.value='';typeDialogVisible.value=true;}
function openItemCreate(){if(!selectedType.value||selectedType.value.systemLocked)return;assign(itemForm,{typeCode:selectedType.value.code,label:'',value:'',sortOrder:filteredItems.value.length+1,status:'ENABLED',remark:'',systemLocked:false});formError.value='';itemDialogVisible.value=true;}
function openItemEdit(row){assign(itemForm,row);formError.value='';itemDialogVisible.value=true;}

async function saveType(){
  if(saving.value)return;
  if(!typeForm.code?.trim()||!typeForm.name?.trim()){formError.value='字典编码与字典名称为必填';return;}
  saving.value=true;formError.value='';
  const result=await command('saveDictionaryType',JSON.parse(JSON.stringify(typeForm)));
  saving.value=false;
  if(!result.ok){formError.value=result.error.message;return;}
  selectedTypeCode.value=result.data.code;typeDialogVisible.value=false;MessagePlugin.success('字典类型已保存');emit('saved');
}
async function saveItem(){
  if(saving.value)return;
  if(!itemForm.label?.trim()||!itemForm.value?.trim()){formError.value='显示标签与字典值为必填';return;}
  saving.value=true;formError.value='';
  const result=await command('saveDictionaryItem',{...JSON.parse(JSON.stringify(itemForm)),typeCode:selectedType.value.code});
  saving.value=false;
  if(!result.ok){formError.value=result.error.message;return;}
  itemDialogVisible.value=false;MessagePlugin.success('字典项已保存');emit('saved');
}
watch(types,value=>{if(!value.some(item=>item.code===selectedTypeCode.value))selectedTypeCode.value=value[0]?.code||'';},{immediate:true});
watch([selectedTypeCode,itemKeyword,itemStatus,pageSize],()=>{page.value=1;});
watch(()=>filteredItems.value.length,()=>{page.value=Math.min(page.value,Math.max(1,Math.ceil(filteredItems.value.length/pageSize.value)));});
</script>
