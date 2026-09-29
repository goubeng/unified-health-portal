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
      <t-table row-key="id" :data="organizationRows" :columns="columns" hover table-layout="fixed" size="medium">
        <template #empty><EmptyState description="暂无符合条件的组织"/></template>
        <template #name="{row}">
          <span class="organization-name" :style="{paddingLeft:`${row._treeLevel * 22}px`}">
            <button
              v-if="row._hasChildren"
              class="tree-toggle"
              type="button"
              :aria-label="expandedOrgIds.has(row.id)?'折叠组织':'展开组织'"
              @click="toggleOrganization(row)"
            >
              <ChevronDownIcon v-if="expandedOrgIds.has(row.id)"/>
              <ChevronRightIcon v-else/>
            </button>
            <span v-else class="tree-toggle-placeholder"></span>
            <span class="organization-name-text">{{text(row.name)}}</span>
          </span>
        </template>
        <template #code="{row}"><TableCellTooltip :text="text(row.code)"><button class="portal-field-link" @click="openDetail(row)">{{text(row.code)}}</button></TableCellTooltip></template>
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
      <t-pagination v-if="treeRows.length" v-model="page" v-model:page-size="pageSize" :total="treeRows.length" :page-size-options="[10,20,50]" show-jumper/>
    </section>

    <t-dialog v-model:visible="detailVisible" placement="center" header="组织详情" width="920px" :footer="false">
      <t-alert v-if="detail?.source==='MINZHENGWU'" theme="info" class="organization-source-alert organization-detail-source-alert">
        该组织来自闽政务组织索引，门户仅展示引用，不维护上游权威组织主数据。
      </t-alert>
      <DetailGrid v-if="detail" :items="detailItems"/>
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
        <div class="form-field">
          <label>上级组织</label>
          <t-tree-select
            v-model="form.parentId"
            :data="parentTreeOptions"
            :filter="parentFilter"
            :tree-props="{expandAll:true}"
            clearable
            filterable
            placeholder="请选择上级组织"
          />
        </div>
        <div class="form-field"><label>数据来源</label><t-input value="门户本地" disabled/></div>
        <div class="form-field"><label>启用状态</label><t-switch :value="form.status==='ENABLED'" @change="form.status=$event?'ENABLED':'DISABLED'"/></div>
        <div class="form-field full"><label>备注</label><t-textarea v-model="form.remark" :autosize="{minRows:3,maxRows:5}"/></div>
      </div>
    </t-dialog>
  </section>
</template>

<script setup>
import {computed,reactive,ref,watch} from 'vue';
import {DialogPlugin,MessagePlugin} from 'tdesign-vue-next';
import {ChevronDownIcon,ChevronRightIcon} from 'tdesign-icons-vue-next';
import EmptyState from './EmptyState.vue';
import DetailGrid from './DetailGrid.vue';
import TableCellTooltip from './TableCellTooltip.vue';
import {date,label,text} from './presentation.js';
import {command} from '../../services/runtime.js';

const props=defineProps({
  rows:{type:Array,default:()=>[]},
  typeItems:{type:Array,default:()=>[]},
  canSuper:Boolean
});
const emit=defineEmits(['saved']);

const keyword=ref(''),type=ref(''),sourceValue=ref(''),status=ref(''),page=ref(1),pageSize=ref(10);
const expandedOrgIds=ref(new Set());
const detailVisible=ref(false),detail=ref(null),formVisible=ref(false),form=reactive({}),formError=ref(''),saving=ref(false);
const statusOptions=[{value:'ENABLED',label:'启用'},{value:'DISABLED',label:'停用'}];
const sourceOptions=[{value:'MINZHENGWU',label:'闽政务'},{value:'PORTAL_LOCAL',label:'门户本地'}];
const typeOptions=computed(()=>{
  const items=props.typeItems.filter(item=>item.typeCode==='organization_type'&&item.status==='ENABLED');
  return items.length?items.map(item=>({value:item.value,label:item.label})):[
    {value:'PORTAL_UNIT',label:'门户单位'},{value:'GOV_DEPARTMENT',label:'政务部门'},{value:'OTHER',label:'其他组织'}
  ];
});
const parentExcludedIds=computed(()=>{
  const excluded=new Set();
  if(!form.id)return excluded;
  excluded.add(form.id);
  let changed=true;
  while(changed){
    changed=false;
    props.rows.forEach(row=>{
      if(!excluded.has(row.id)&&row.parentId&&excluded.has(row.parentId)){
        excluded.add(row.id);
        changed=true;
      }
    });
  }
  return excluded;
});
const parentTreeOptions=computed(()=>{
  const rows=props.rows
    .filter(row=>!parentExcludedIds.value.has(row.id))
    .map(row=>({
      value:row.id,
      label:text(row.name)||text(row.code),
      code:text(row.code),
      path:text(row.path),
      sortOrder:Number(row.sortOrder)||0,
      disabled:row.status!=='ENABLED',
      parentId:row.parentId||null,
      children:[]
    }));
  const byId=new Map(rows.map(row=>[row.value,row]));
  const roots=[];
  rows.forEach(row=>{
    const parent=row.parentId?byId.get(row.parentId):null;
    if(parent)parent.children.push(row);
    else roots.push(row);
  });
  const sortNodes=list=>{
    list.sort((a,b)=>a.sortOrder-b.sortOrder||a.label.localeCompare(b.label,'zh-CN'));
    list.forEach(node=>sortNodes(node.children));
  };
  sortNodes(roots);
  return roots;
});
const parentFilter=(searchText,node)=>{
  const term=text(searchText).trim().toLowerCase();
  if(!term)return true;
  const data=node?.data||{};
  return [data.label,data.code,data.path].some(value=>text(value).toLowerCase().includes(term));
};
const typeLabel=value=>typeOptions.value.find(item=>item.value===value)?.label||text(value);
const sourceLabel=value=>({MINZHENGWU:'闽政务',PORTAL_LOCAL:'门户本地',MINZHENGTONG:'闽政通'}[value]||text(value));

const filtered=computed(()=>{
  const term=keyword.value.trim().toLowerCase();
  return props.rows.filter(row=>{
    const matchKeyword=!term||[row.name,row.code,row.path].some(value=>text(value).toLowerCase().includes(term));
    return matchKeyword&&(!type.value||row.type===type.value)&&(!sourceValue.value||row.source===sourceValue.value)&&(!status.value||row.status===status.value);
  });
});
const treeRows=computed(()=>{
  const sourceRows=filtered.value.map(row=>({...row,children:[]}));
  const byId=new Map(sourceRows.map(row=>[row.id,row]));
  const roots=[];
  sourceRows.forEach(row=>{
    const parent=row.parentId?byId.get(row.parentId):null;
    if(parent)parent.children.push(row);
    else roots.push(row);
  });
  const sortRows=list=>{
    list.sort((a,b)=>(Number(a.sortOrder)||0)-(Number(b.sortOrder)||0)||text(a.name).localeCompare(text(b.name),'zh-CN'));
    list.forEach(row=>sortRows(row.children));
  };
  sortRows(roots);
  return roots;
});
const paged=computed(()=>treeRows.value.slice((page.value-1)*pageSize.value,page.value*pageSize.value));
const hasOrgFilters=computed(()=>Boolean(keyword.value.trim()||type.value||sourceValue.value||status.value));
function flattenOrganizations(rows=[],level=0,respectExpanded=true){
  return rows.flatMap(row=>{
    const children=Array.isArray(row.children)?row.children:[];
    const item={...row,_treeLevel:level,_hasChildren:children.length>0};
    if(respectExpanded&&children.length&&!expandedOrgIds.value.has(row.id))return [item];
    return [item,...flattenOrganizations(children,level+1,respectExpanded)];
  });
}
const organizationRows=computed(()=>flattenOrganizations(paged.value,0,!hasOrgFilters.value));
function toggleOrganization(row){
  const next=new Set(expandedOrgIds.value);
  if(next.has(row.id))next.delete(row.id);
  else next.add(row.id);
  expandedOrgIds.value=next;
}
const columns=[
  {colKey:'name',title:'组织名称',width:220,ellipsis:true},
  {colKey:'code',title:'组织编码',width:160,ellipsis:true},
  {colKey:'type',title:'组织类型',width:120},
  {colKey:'parentName',title:'上级组织',width:180,ellipsis:true},
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
watch(()=>treeRows.value.length,()=>{page.value=Math.min(page.value,Math.max(1,Math.ceil(treeRows.value.length/pageSize.value)));});
watch(()=>props.rows.map(row=>`${row.id}:${row.parentId||''}`).join('|'),()=>{
  const parents=new Set();
  props.rows.forEach(row=>{if(props.rows.some(child=>child.parentId===row.id))parents.add(row.id);});
  expandedOrgIds.value=parents;
},{immediate:true});
</script>
