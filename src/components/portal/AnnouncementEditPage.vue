<template>
  <section class="announcement-admin-edit-page">
    <Teleport to="#page-header-actions">
      <t-button variant="outline" @click="$emit('cancel')">取消</t-button>
      <t-button variant="outline" theme="primary" @click="openPreview">预览</t-button>
      <t-button theme="primary" :loading="saving" @click="save">保存修改</t-button>
    </Teleport>

    <section class="panel announcement-admin-edit-panel">
      <div v-if="formError" class="error-note">{{formError}}</div>
      <div class="form-grid announcement-form-grid">
        <div class="form-field full">
          <label>公告标题 <span class="portal-required">*</span></label>
          <t-input v-model="form.title" :maxlength="120"/>
        </div>
        <div class="form-field">
          <label>公告类型</label>
          <t-select v-model="form.type" :options="typeOptions"/>
        </div>
        <div class="form-field">
          <label>发布范围</label>
          <t-select v-model="form.scope" :options="scopeOptions"/>
        </div>
        <div class="form-field">
          <label>失效日期</label>
          <t-date-picker v-model="form.effectiveEnd" clearable format="YYYY-MM-DD" value-type="YYYY-MM-DD" placeholder="留空表示永久有效"/>
          <small class="form-helper">选择日期后，于当天 23:59:59 后失效。</small>
        </div>
        <div class="form-field">
          <label>当前状态</label>
          <t-input :value="label(form.status||'DRAFT')" disabled/>
        </div>
      </div>

      <AnnouncementEditor v-model="form.content" v-model:files="uploadFiles"/>
    </section>

    <t-dialog v-model:visible="previewVisible" placement="center" header="公告预览" width="min(1040px, calc(100vw - 48px))" :footer="false">
      <AnnouncementDetail :record="previewRecord" @download="download"/>
    </t-dialog>
  </section>
</template>

<script setup>
import {computed,reactive,ref,watch} from 'vue';
import {MessagePlugin} from 'tdesign-vue-next';
import AnnouncementEditor from './AnnouncementEditor.vue';
import AnnouncementDetail from './AnnouncementDetail.vue';
import {label,text} from './presentation.js';
import {command} from '../../services/runtime.js';

const props=defineProps({
  record:{type:Object,required:true},
  typeItems:{type:Array,default:()=>[]}
});
const emit=defineEmits(['saved','cancel']);

const form=reactive({});
const uploadFiles=ref([]);
const saving=ref(false),formError=ref('');
const previewVisible=ref(false),previewRecord=ref(null);

const typeOptions=computed(()=>{
  const items=props.typeItems.filter(item=>item.typeCode==='announcement_type'&&item.status==='ENABLED');
  return items.length?items.map(item=>({value:item.label,label:item.label})):[{value:'通知',label:'通知'},{value:'提示',label:'提示'}];
});
const scopeOptions=['ALL','CITIZEN','GOV'].map(value=>({value,label:label(value)}));

function toDateValue(value){
  const d=new Date(value);
  if(!Number.isFinite(d.getTime()))return String(value||'').slice(0,10);
  const pad=n=>String(n).padStart(2,'0');
  return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())}`;
}
function toEndOfDayIso(value){return value?new Date(String(value).slice(0,10)+'T23:59:59').toISOString():null;}

function assign(record){
  Object.keys(form).forEach(key=>delete form[key]);
  Object.assign(form,JSON.parse(JSON.stringify(record||{})));
  if(form.effectiveEnd)form.effectiveEnd=toDateValue(form.effectiveEnd);
  uploadFiles.value=(form.attachments||[]).map(file=>({
    name:file.name||'附件',url:file.data||'',status:'success',id:file.id||crypto.randomUUID(),
    originAttachment:JSON.parse(JSON.stringify(file))
  }));
  formError.value='';
}
watch(()=>props.record,assign,{immediate:true,deep:true});

async function fileToDataUrl(file){
  return new Promise((resolve,reject)=>{
    const reader=new FileReader();
    reader.onload=()=>resolve(reader.result);
    reader.onerror=()=>reject(new Error('附件读取失败'));
    reader.readAsDataURL(file);
  });
}
async function normalizeFiles(files,originals){
  const list=[...(files||[])];
  if(list.length>5)throw new Error('附件最多5个');
  const result=[];
  for(const item of list){
    const original=item?.originAttachment||(originals||[]).find(file=>file.id===item?.id||file.name===item?.name);
    if(original?.data){result.push(original);continue;}
    const raw=item?.raw||item?.rawFile||item?.file||((typeof File!=='undefined'&&item instanceof File)?item:null);
    const size=Number(raw?.size??item?.size??0);
    if(size>2*1024*1024)throw new Error('单个附件不能超过2MB');
    if(raw){
      result.push({
        id:item.id||'FILE_'+crypto.randomUUID(),name:raw.name||item.name||'附件',size:raw.size||size,
        type:raw.type||item.type||'',uploadedAt:new Date().toISOString(),data:await fileToDataUrl(raw)
      });
      continue;
    }
    if(item?.url?.startsWith('data:'))result.push({
      id:item.id||'FILE_'+crypto.randomUUID(),name:item.name||'附件',size,type:item.type||'',
      uploadedAt:new Date().toISOString(),data:item.url
    });
  }
  return result;
}

async function save(){
  if(saving.value)return;
  if(!form.title?.trim()){formError.value='请填写公告标题';return;}
  if(!String(form.content||'').replace(/<[^>]*>/g,'').replace(/&nbsp;/gi,' ').trim()){formError.value='请填写公告正文';return;}
  saving.value=true;formError.value='';
  try{
    const attachments=await normalizeFiles(uploadFiles.value,form.attachments||[]);
    const result=await command('saveAnnouncement',{
      id:form.id,version:form.version,title:form.title.trim(),type:form.type,scope:form.scope,
      effectiveEnd:toEndOfDayIso(form.effectiveEnd),content:form.content,attachments
    });
    if(!result.ok){formError.value=result.error.message;return;}
    MessagePlugin.success('公告修改已保存');
    emit('saved',result.data);
  }catch(cause){formError.value=cause.message;}
  finally{saving.value=false;}
}
function openPreview(){
  previewRecord.value={
    ...JSON.parse(JSON.stringify(form)),
    attachments:uploadFiles.value.map(file=>file.originAttachment||{id:file.id,name:file.name,size:file.size||0,url:file.url||''})
  };
  previewVisible.value=true;
}
function download(file){
  if(!file?.data?.startsWith('data:')){MessagePlugin.warning('附件内容不可用');return;}
  const link=document.createElement('a');link.href=file.data;link.download=file.name;link.click();
}
</script>
