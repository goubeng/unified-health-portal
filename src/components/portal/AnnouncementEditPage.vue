<template>
  <t-dialog
    :visible="visible"
    placement="center"
    header="编辑公告"
    width="min(1180px, calc(100vw - 48px))"
    :close-on-overlay-click="false"
    @update:visible="updateVisible"
  >
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

      <div
        v-if="isDraft||isScheduled"
        class="announcement-publish-row"
        :class="{'is-scheduled':form.publishMode==='SCHEDULED'}"
      >
        <div class="form-field announcement-publish-mode-field">
          <label>发布方式 <span class="portal-required">*</span></label>
          <t-radio-group v-model="form.publishMode">
            <t-radio value="IMMEDIATE">立即发布</t-radio>
            <t-radio value="SCHEDULED">定时发布</t-radio>
          </t-radio-group>
        </div>
        <div v-if="form.publishMode==='SCHEDULED'" class="form-field announcement-schedule-field">
          <label>定时发布时间 <span class="portal-required">*</span></label>
          <t-date-picker
            v-model="form.scheduledPublishAt"
            enable-time-picker
            format="YYYY-MM-DD HH:mm:ss"
            value-type="YYYY-MM-DD HH:mm:ss"
            placeholder="请选择未来发布时间"
          />
        </div>
        <div class="form-field announcement-expiry-field">
          <label>失效日期</label>
          <t-date-picker v-model="form.effectiveEnd" clearable format="YYYY-MM-DD" value-type="YYYY-MM-DD" placeholder="留空表示永久有效"/>
          <small class="form-helper">当天 23:59:59 后失效。</small>
        </div>
      </div>

      <template v-else>
        <div class="form-field">
          <label>失效日期</label>
          <t-date-picker v-model="form.effectiveEnd" clearable format="YYYY-MM-DD" value-type="YYYY-MM-DD" placeholder="留空表示永久有效"/>
          <small class="form-helper">当天 23:59:59 后失效。</small>
        </div>
      </template>
    </div>

    <AnnouncementEditor v-model="form.content" v-model:files="uploadFiles"/>

    <template #footer>
      <div class="announcement-form-actions">
        <t-button variant="outline" @click="close">取消</t-button>
        <t-button variant="outline" theme="primary" @click="openPreview">预览</t-button>
        <template v-if="isDraft||isScheduled">
          <t-button variant="outline" theme="primary" :loading="saving" @click="saveDraft">保存草稿</t-button>
          <t-button theme="primary" :loading="saving" @click="publishDraft">{{form.publishMode==='SCHEDULED'?'定时发布':'立即发布'}}</t-button>
        </template>
        <t-button v-else theme="primary" :loading="saving" @click="saveCurrent">保存修改</t-button>
      </div>
    </template>
  </t-dialog>

  <t-dialog v-model:visible="previewVisible" placement="center" header="公告预览" width="min(1040px, calc(100vw - 48px))" :footer="false">
    <AnnouncementDetail :record="previewRecord" @download="download"/>
  </t-dialog>
</template>

<script setup>
import {computed,reactive,ref,watch} from 'vue';
import {MessagePlugin} from 'tdesign-vue-next';
import AnnouncementEditor from './AnnouncementEditor.vue';
import AnnouncementDetail from './AnnouncementDetail.vue';
import {label} from './presentation.js';
import {command} from '../../services/runtime.js';

const props=defineProps({
  visible:Boolean,
  record:{type:Object,default:null},
  typeItems:{type:Array,default:()=>[]}
});
const emit=defineEmits(['update:visible','saved']);

const form=reactive({});
const uploadFiles=ref([]);
const saving=ref(false),formError=ref('');
const previewVisible=ref(false),previewRecord=ref(null);

const isDraft=computed(()=>form.status==='DRAFT');
const isPublished=computed(()=>form.status==='PUBLISHED');
const isScheduled=computed(()=>form.status==='SCHEDULED');

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
function toDateTimeValue(value){
  const d=new Date(value);
  if(!Number.isFinite(d.getTime()))return String(value||'');
  const pad=n=>String(n).padStart(2,'0');
  return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}:${pad(d.getSeconds())}`;
}
function toIso(value){return value?new Date(String(value).replace(' ','T')).toISOString():null;}
function toEndOfDayIso(value){return value?new Date(String(value).slice(0,10)+'T23:59:59').toISOString():null;}

function assign(record){
  Object.keys(form).forEach(key=>delete form[key]);
  Object.assign(form,JSON.parse(JSON.stringify(record||{})));
  if(!form.publishMode)form.publishMode=form.status==='SCHEDULED'?'SCHEDULED':'IMMEDIATE';
  if(form.effectiveEnd)form.effectiveEnd=toDateValue(form.effectiveEnd);
  if(form.scheduledPublishAt)form.scheduledPublishAt=toDateTimeValue(form.scheduledPublishAt);
  uploadFiles.value=(form.attachments||[]).map(file=>({
    name:file.name||'附件',url:file.data||'',status:'success',id:file.id||crypto.randomUUID(),
    originAttachment:JSON.parse(JSON.stringify(file))
  }));
  formError.value='';
}
watch(()=>props.record,record=>{if(record)assign(record);},{immediate:true,deep:true});
watch(()=>props.visible,value=>{if(value&&props.record)assign(props.record);});
watch(()=>form.publishMode,value=>{if((isDraft.value||isScheduled.value)&&value!=='SCHEDULED')form.scheduledPublishAt='';});

function updateVisible(value){emit('update:visible',value);}
function close(){emit('update:visible',false);}

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

function validateBase(){
  if(!form.title?.trim()){formError.value='请填写公告标题';return false;}
  if(!String(form.content||'').replace(/<[^>]*>/g,'').replace(/&nbsp;/gi,' ').trim()){formError.value='请填写公告正文';return false;}
  return true;
}

async function saveBase(overrides={}){
  if(!validateBase())return null;
  const attachments=await normalizeFiles(uploadFiles.value,form.attachments||[]);
  const payload={
    id:form.id,version:form.version,title:form.title.trim(),type:form.type,scope:form.scope,
    effectiveEnd:toEndOfDayIso(form.effectiveEnd),content:form.content,attachments,...overrides
  };
  if(isScheduled.value&&form.publishMode==='SCHEDULED')payload.scheduledPublishAt=toIso(form.scheduledPublishAt);
  const result=await command('saveAnnouncement',payload);
  if(!result.ok){formError.value=result.error.message;return null;}
  Object.assign(form,{id:result.data.id,version:result.data.version,status:result.data.status,scheduledPublishAt:result.data.scheduledPublishAt?toDateTimeValue(result.data.scheduledPublishAt):form.scheduledPublishAt});
  return result.data;
}

async function saveDraft(){
  if(saving.value)return;
  saving.value=true;formError.value='';
  try{
    const saved=await saveBase({targetStatus:'DRAFT'});
    if(!saved)return;
    MessagePlugin.success(isScheduled.value?'定时计划已取消，公告已保存为草稿':'公告草稿已保存');
    emit('saved',saved);
    close();
  }catch(cause){formError.value=cause.message;}
  finally{saving.value=false;}
}

async function publishDraft(){
  if(saving.value)return;
  if(form.publishMode==='SCHEDULED'&&!form.scheduledPublishAt){formError.value='请选择定时发布时间';return;}
  saving.value=true;formError.value='';
  try{
    const saved=await saveBase();
    if(!saved)return;
    const result=await command('submitAnnouncement',{
      id:saved.id,version:saved.version,publishMode:form.publishMode,
      scheduledPublishAt:form.publishMode==='SCHEDULED'?toIso(form.scheduledPublishAt):null
    });
    if(!result.ok){formError.value=result.error.message;return;}
    MessagePlugin.success(form.publishMode==='SCHEDULED'?'公告已设置定时发布':'公告已发布');
    emit('saved',result.data);
    close();
  }catch(cause){formError.value=cause.message;}
  finally{saving.value=false;}
}

async function saveCurrent(){
  if(saving.value)return;
  if(isScheduled.value&&form.publishMode==='SCHEDULED'&&!form.scheduledPublishAt){formError.value='请选择定时发布时间';return;}
  saving.value=true;formError.value='';
  try{
    const saved=await saveBase();
    if(!saved)return;
    if(isScheduled.value){
      const result=await command('submitAnnouncement',{
        id:saved.id,version:saved.version,publishMode:form.publishMode,
        scheduledPublishAt:form.publishMode==='SCHEDULED'?toIso(form.scheduledPublishAt):null
      });
      if(!result.ok){formError.value=result.error.message;return;}
      MessagePlugin.success(form.publishMode==='IMMEDIATE'?'公告已立即发布':'定时公告修改已保存');
      emit('saved',result.data);
      close();
      return;
    }
    MessagePlugin.success('公告修改已生效');
    emit('saved',saved);
    close();
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
