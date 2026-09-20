<template>
  <section class="portal-list announcement-management">
    <Teleport to="#page-header-actions">
      <t-button theme="primary" @click="openCreate">新增公告</t-button>
    </Teleport>

    <t-form layout="inline" class="portal-query list-toolbar">
      <t-form-item class="portal-query-keyword query-width-keyword" label="公告标题">
        <t-input v-model="keyword" clearable placeholder="请输入公告标题"/>
      </t-form-item>
      <t-form-item class="portal-query-select query-width-kind" label="公告类型">
        <t-select v-model="type" clearable placeholder="全部" :options="typeOptions"/>
      </t-form-item>
      <t-form-item class="portal-query-select query-width-scope" label="发布范围">
        <t-select v-model="scope" clearable placeholder="全部" :options="scopeOptions"/>
      </t-form-item>
      <t-form-item class="portal-query-select query-width-status" label="状态">
        <t-select v-model="status" clearable placeholder="全部" :options="statusOptions"/>
      </t-form-item>
      <t-form-item class="portal-query-action">
        <t-button theme="default" variant="outline" @click="reset">重置</t-button>
      </t-form-item>
    </t-form>

    <section class="panel portal-table-panel">
      <t-table row-key="id" :data="paged" :columns="columns" hover table-layout="fixed" size="medium">
        <template #empty><EmptyState description="暂无符合条件的公告"/></template>
        <template #serial="{rowIndex}">{{(page-1)*pageSize+rowIndex+1}}</template>
        <template #title="{row}"><button class="portal-field-link" @click="preview(row)">{{text(row.title)}}</button></template>
        <template #scope="{row}">{{label(row.scope)}}</template>
        <template #status="{row}"><t-tag :theme="statusTheme(row.status)" variant="light">{{label(row.status)}}</t-tag></template>
        <template #publishAt="{row}">
          <span v-if="row.status==='SCHEDULED'">{{date(row.scheduledPublishAt)}}</span>
          <span v-else>{{date(row.publishedAt)}}</span>
        </template>
        <template #effectiveEnd="{row}">{{row.effectiveEnd?date(row.effectiveEnd):'永久有效'}}</template>
        <template #operation="{row}">
          <div class="row-actions">
            <t-button v-if="['DRAFT','SCHEDULED','PUBLISHED'].includes(row.status)" size="small" variant="text" theme="primary" @click="openEdit(row)">编辑</t-button>
            <t-button v-if="row.status==='DRAFT'" size="small" variant="text" theme="primary" @click="openSubmit(row)">提交</t-button>
            <t-button v-if="['SCHEDULED','PUBLISHED'].includes(row.status)" size="small" variant="text" theme="danger" @click="withdraw(row)">撤回</t-button>
            <t-button v-if="['DRAFT','WITHDRAWN','EXPIRED'].includes(row.status)" size="small" variant="text" theme="danger" @click="remove(row)">删除</t-button>
          </div>
        </template>
      </t-table>
      <t-pagination v-model="page" v-model:page-size="pageSize" :total="filtered.length" :page-size-options="[10,20,50]" show-jumper/>
    </section>

    <t-dialog
      v-model:visible="formVisible"
      placement="center"
      :header="form.id?'编辑公告':'新增公告'"
      width="min(1180px, calc(100vw - 48px))"
      :footer="false"
      :close-on-overlay-click="false"
    >
      <div v-if="formError" class="error-note">{{formError}}</div>
      <div class="form-grid announcement-form-grid">
        <div class="form-field full"><label>公告标题 <span class="portal-required">*</span></label><t-input v-model="form.title" :maxlength="120"/></div>
        <div class="form-field"><label>公告类型</label><t-select v-model="form.type" :options="typeOptions"/></div>
        <div class="form-field"><label>发布范围</label><t-select v-model="form.scope" :options="scopeOptions"/></div>
        <div class="form-field"><label>失效时间</label><t-date-picker v-model="form.effectiveEnd" enable-time-picker clearable format="YYYY-MM-DD HH:mm:ss" value-type="YYYY-MM-DD HH:mm:ss" placeholder="留空表示永久有效"/></div>
        <div class="form-field"><label>当前状态</label><t-input :value="label(form.status||'DRAFT')" disabled/></div>
      </div>
      <AnnouncementEditor v-model="form.content" v-model:files="uploadFiles"/>
      <template #footer>
        <div class="announcement-form-actions">
          <t-button variant="outline" @click="formVisible=false">取消</t-button>
          <t-button variant="outline" theme="primary" @click="previewForm">预览</t-button>
          <t-button theme="primary" :loading="saving" @click="saveAnnouncement">{{form.status==='PUBLISHED'?'保存修改':form.status==='SCHEDULED'?'保存修改':'保存草稿'}}</t-button>
        </div>
      </template>
    </t-dialog>

    <t-dialog v-model:visible="submitVisible" placement="center" header="提交发布" width="620px" :confirm-btn="{content:'确认提交',loading:saving}" :close-on-overlay-click="false" @confirm="submitAnnouncement">
      <div v-if="formError" class="error-note">{{formError}}</div>
      <p class="inline-note">公告：{{text(submitRow?.title)}}</p>
      <div class="announcement-submit-options">
        <t-radio-group v-model="publishMode">
          <t-radio value="IMMEDIATE">立即发布</t-radio>
          <t-radio value="SCHEDULED">定时发布</t-radio>
        </t-radio-group>
        <div v-if="publishMode==='SCHEDULED'" class="form-field">
          <label>定时发布时间 <span class="portal-required">*</span></label>
          <t-date-picker v-model="scheduledPublishAt" enable-time-picker format="YYYY-MM-DD HH:mm:ss" value-type="YYYY-MM-DD HH:mm:ss" placeholder="请选择未来时间"/>
        </div>
      </div>
    </t-dialog>

    <t-dialog v-model:visible="previewVisible" placement="center" header="公告预览" width="min(1040px, calc(100vw - 48px))" :footer="false">
      <AnnouncementDetail :record="previewRecord" @download="download"/>
    </t-dialog>
  </section>
</template>

<script setup>
import {computed,reactive,ref,watch} from 'vue';
import {DialogPlugin,MessagePlugin} from 'tdesign-vue-next';
import EmptyState from './EmptyState.vue';
import AnnouncementEditor from './AnnouncementEditor.vue';
import AnnouncementDetail from './AnnouncementDetail.vue';
import {date,label,text} from './presentation.js';
import {command} from '../../services/runtime.js';

const props=defineProps({rows:{type:Array,default:()=>[]},typeItems:{type:Array,default:()=>[]}});
const emit=defineEmits(['saved']);

const keyword=ref(''),type=ref(''),scope=ref(''),status=ref(''),page=ref(1),pageSize=ref(10);
const formVisible=ref(false),form=reactive({}),formError=ref(''),saving=ref(false),uploadFiles=ref([]);
const submitVisible=ref(false),submitRow=ref(null),publishMode=ref('IMMEDIATE'),scheduledPublishAt=ref('');
const previewVisible=ref(false),previewRecord=ref(null);

const typeOptions=computed(()=>{
  const items=props.typeItems.filter(item=>item.typeCode==='announcement_type'&&item.status==='ENABLED');
  return items.length?items.map(item=>({value:item.label,label:item.label})):[{value:'通知',label:'通知'},{value:'提示',label:'提示'}];
});
const scopeOptions=['ALL','CITIZEN','GOV'].map(value=>({value,label:label(value)}));
const statusOptions=['DRAFT','SCHEDULED','PUBLISHED','WITHDRAWN','EXPIRED'].map(value=>({value,label:label(value)}));
const statusTheme=value=>value==='PUBLISHED'?'success':value==='SCHEDULED'?'warning':['WITHDRAWN','EXPIRED'].includes(value)?'default':'primary';

const filtered=computed(()=>{
  const term=keyword.value.trim().toLowerCase();
  return props.rows.filter(row=>(!term||text(row.title).toLowerCase().includes(term))&&(!type.value||row.type===type.value)&&(!scope.value||row.scope===scope.value)&&(!status.value||row.status===status.value))
    .sort((a,b)=>(Date.parse(b.updatedAt||b.createdAt)||0)-(Date.parse(a.updatedAt||a.createdAt)||0));
});
const paged=computed(()=>filtered.value.slice((page.value-1)*pageSize.value,page.value*pageSize.value));
const columns=[
  {colKey:'serial',title:'序号',width:64},
  {colKey:'title',title:'公告标题',minWidth:260,ellipsis:true},
  {colKey:'type',title:'公告类型',width:110},
  {colKey:'scope',title:'发布范围',width:110},
  {colKey:'status',title:'状态',width:110},
  {colKey:'publishAt',title:'发布/计划时间',width:180},
  {colKey:'effectiveEnd',title:'失效时间',width:180},
  {colKey:'updatedAt',title:'更新时间',width:180,cell:(_,ctx)=>date(ctx.row.updatedAt)},
  {colKey:'operation',title:'操作',width:220,fixed:'right'}
];

function reset(){keyword.value='';type.value='';scope.value='';status.value='';page.value=1;}
function assign(row){
  Object.keys(form).forEach(key=>delete form[key]);
  Object.assign(form,JSON.parse(JSON.stringify(row)));
  if(!form.status)form.status='DRAFT';
  if(form.effectiveEnd)form.effectiveEnd=toDateTimeValue(form.effectiveEnd);
  uploadFiles.value=(form.attachments||[]).map(file=>({name:file.name||'附件',url:file.data||'',status:'success',id:file.id||crypto.randomUUID(),originAttachment:JSON.parse(JSON.stringify(file))}));
}
function openCreate(){assign({title:'',type:typeOptions.value[0]?.value||'通知',scope:'ALL',status:'DRAFT',effectiveEnd:'',content:'',attachments:[]});formError.value='';formVisible.value=true;}
function openEdit(row){assign(row);formError.value='';formVisible.value=true;}
function preview(row){previewRecord.value=JSON.parse(JSON.stringify(row));previewVisible.value=true;}
function previewForm(){previewRecord.value={...JSON.parse(JSON.stringify(form)),attachments:uploadFiles.value.map(file=>file.originAttachment||{id:file.id,name:file.name,size:file.size||0})};previewVisible.value=true;}
function openSubmit(row){submitRow.value=JSON.parse(JSON.stringify(row));publishMode.value='IMMEDIATE';scheduledPublishAt.value='';formError.value='';submitVisible.value=true;}
function toDateTimeValue(value){const d=new Date(value);if(!Number.isFinite(d.getTime()))return String(value||'');const pad=n=>String(n).padStart(2,'0');return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;}
function toIso(value){return value?new Date(String(value).replace(' ','T')).toISOString():null;}

async function saveAnnouncement(){
  if(saving.value)return;
  if(!form.title?.trim()){formError.value='请填写公告标题';return;}
  if(!String(form.content||'').replace(/<[^>]*>/g,'').replace(/&nbsp;/gi,' ').trim()){formError.value='请填写公告正文';return;}
  saving.value=true;formError.value='';
  try{
    const attachments=await normalizeFiles(uploadFiles.value,form.attachments||[]);
    const payload={id:form.id,version:form.version,title:form.title.trim(),type:form.type,scope:form.scope,effectiveEnd:toIso(form.effectiveEnd),content:form.content,attachments};
    const result=await command('saveAnnouncement',payload);
    if(!result.ok){formError.value=result.error.message;return;}
    formVisible.value=false;MessagePlugin.success(form.id?'公告修改已保存':'公告草稿已保存');emit('saved');
  }catch(cause){formError.value=cause.message;}
  finally{saving.value=false;}
}
async function submitAnnouncement(){
  if(!submitRow.value||saving.value)return;
  if(publishMode.value==='SCHEDULED'&&!scheduledPublishAt.value){formError.value='请选择定时发布时间';return;}
  saving.value=true;formError.value='';
  const result=await command('submitAnnouncement',{
    id:submitRow.value.id,version:submitRow.value.version,publishMode:publishMode.value,
    scheduledPublishAt:publishMode.value==='SCHEDULED'?toIso(scheduledPublishAt.value):null
  });
  saving.value=false;
  if(!result.ok){formError.value=result.error.message;return;}
  submitVisible.value=false;MessagePlugin.success(publishMode.value==='SCHEDULED'?'已提交定时发布':'公告已发布');emit('saved');
}
function withdraw(row){
  const dialog=DialogPlugin.confirm({placement:'center',header:'撤回公告',body:'确认撤回该公告？撤回后用户端立即不可见。',onConfirm:async()=>{
    const result=await command('withdraw',{id:row.id,version:row.version,reason:'管理端撤回'});
    if(!result.ok){MessagePlugin.error(result.error.message);return;}
    dialog.hide();MessagePlugin.success('公告已撤回');emit('saved');
  }});
}
function remove(row){
  const dialog=DialogPlugin.confirm({placement:'center',header:'删除公告',body:'确认删除该公告？删除后将退出公告列表，Mock回收档案仍保留。',onConfirm:async()=>{
    const result=await command('removeAnnouncement',{id:row.id,version:row.version});
    if(!result.ok){MessagePlugin.error(result.error.message);return;}
    dialog.hide();MessagePlugin.success('公告已删除');emit('saved');
  }});
}
async function fileToDataUrl(file){return new Promise((resolve,reject)=>{const reader=new FileReader();reader.onload=()=>resolve(reader.result);reader.onerror=()=>reject(new Error('附件读取失败'));reader.readAsDataURL(file);});}
async function normalizeFiles(files,originals){
  const list=[...(files||[])];if(list.length>5)throw new Error('附件最多5个');
  const result=[];
  for(const item of list){
    const original=item?.originAttachment||(originals||[]).find(file=>file.id===item?.id||file.name===item?.name);
    if(original?.data){result.push(original);continue;}
    const raw=item?.raw||item?.rawFile||item?.file||((typeof File!=='undefined'&&item instanceof File)?item:null);
    const size=Number(raw?.size??item?.size??0);if(size>2*1024*1024)throw new Error('单个附件不能超过2MB');
    if(raw){result.push({id:item.id||'FILE_'+crypto.randomUUID(),name:raw.name||item.name||'附件',size:raw.size||size,type:raw.type||item.type||'',uploadedAt:new Date().toISOString(),data:await fileToDataUrl(raw)});continue;}
    if(item?.url?.startsWith('data:'))result.push({id:item.id||'FILE_'+crypto.randomUUID(),name:item.name||'附件',size,type:item.type||'',uploadedAt:new Date().toISOString(),data:item.url});
  }
  return result;
}
function download(file){if(!file?.data?.startsWith('data:')){MessagePlugin.warning('附件内容不可用');return;}const link=document.createElement('a');link.href=file.data;link.download=file.name;link.click();}
watch([keyword,type,scope,status,pageSize],()=>{page.value=1;});
watch(()=>filtered.value.length,()=>{page.value=Math.min(page.value,Math.max(1,Math.ceil(filtered.value.length/pageSize.value)));});
</script>
