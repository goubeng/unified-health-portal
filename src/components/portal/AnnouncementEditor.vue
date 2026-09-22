<template>
  <section class="announcement-editor">
    <label class="announcement-editor-label">正文<span class="portal-required"> *</span></label>
    <div class="rich-editor-shell">
      <div class="rich-editor-toolbar" role="toolbar" aria-label="公告正文格式工具栏">
        <t-tooltip content="加粗"><t-button class="editor-icon-button" size="small" variant="text" @click.prevent="exec('bold')"><Icon name="textformat-bold"/></t-button></t-tooltip>
        <t-tooltip content="斜体"><t-button class="editor-icon-button" size="small" variant="text" @click.prevent="exec('italic')"><Icon name="textformat-italic"/></t-button></t-tooltip>
        <t-tooltip content="下划线"><t-button class="editor-icon-button" size="small" variant="text" @click.prevent="exec('underline')"><Icon name="textformat-underline"/></t-button></t-tooltip>
        <span class="toolbar-divider"></span>
        <t-tooltip content="正文"><t-button size="small" variant="text" @click.prevent="block('p')">正文</t-button></t-tooltip>
        <t-tooltip content="标题"><t-button size="small" variant="text" @click.prevent="block('h3')">标题</t-button></t-tooltip>
        <span class="toolbar-divider"></span>
        <t-tooltip content="项目符号"><t-button class="editor-icon-button" size="small" variant="text" @click.prevent="exec('insertUnorderedList')"><Icon name="view-list"/></t-button></t-tooltip>
        <t-tooltip content="编号"><t-button class="editor-icon-button" size="small" variant="text" @click.prevent="exec('insertOrderedList')"><Icon name="list-numbered"/></t-button></t-tooltip>
        <span class="toolbar-divider"></span>
        <t-tooltip content="左对齐"><t-button class="editor-icon-button" size="small" variant="text" @click.prevent="exec('justifyLeft')"><Icon name="format-vertical-align-left"/></t-button></t-tooltip>
        <t-tooltip content="居中对齐"><t-button class="editor-icon-button" size="small" variant="text" @click.prevent="exec('justifyCenter')"><Icon name="format-vertical-align-center"/></t-button></t-tooltip>
        <t-tooltip content="右对齐"><t-button class="editor-icon-button" size="small" variant="text" @click.prevent="exec('justifyRight')"><Icon name="format-vertical-align-right"/></t-button></t-tooltip>
        <span class="toolbar-divider"></span>
        <t-tooltip content="插入图片"><t-button class="editor-icon-button" size="small" variant="text" @click.prevent="imageInput?.click()"><Icon name="image"/></t-button></t-tooltip>
        <t-tooltip content="导入HTML/TXT"><t-button size="small" variant="text" @click.prevent="importInput?.click()">导入文本</t-button></t-tooltip>
        <span class="toolbar-divider"></span>
        <t-tooltip content="清除格式"><t-button class="editor-icon-button" size="small" variant="text" @click.prevent="exec('removeFormat')"><Icon name="clear"/></t-button></t-tooltip>
        <input ref="imageInput" class="editor-hidden-input" type="file" accept="image/*" @change="insertImage"/>
        <input ref="importInput" class="editor-hidden-input" type="file" accept=".html,.htm,.txt" @change="importDocument"/>
      </div>
      <div ref="editor" class="rich-editor-content" contenteditable="true" data-placeholder="请输入公告正文" @input="syncContent" @blur="syncContent"></div>
    </div>

    <label class="announcement-editor-label attachment-label">附件</label>
    <t-upload
      v-model="localFiles"
      theme="file"
      :auto-upload="false"
      multiple
      accept="image/*,.pdf,.doc,.docx,.xls,.xlsx,.txt,.zip"
      :max="5"
      :size-limit="{ size: 2, unit: 'MB' }"
      :abridge-name="[16,8]"
      tips="支持图片、PDF、Word、Excel、TXT、ZIP，单个不超过2MB，最多5个附件"
      @change="emitFiles"
      @remove="emitFiles"
    />
  </section>
</template>

<script setup>
import {nextTick,ref,watch} from 'vue';
import {MessagePlugin} from 'tdesign-vue-next';
import {Icon} from 'tdesign-icons-vue-next';

const props=defineProps({modelValue:{type:String,default:''},files:{type:Array,default:()=>[]}});
const emit=defineEmits(['update:modelValue','update:files']);
const editor=ref(null),localFiles=ref([]),imageInput=ref(null),importInput=ref(null);
let syncing=false;

function syncEditor(value){
 if(!editor.value)return;
 const html=String(value||'');
 if(editor.value.innerHTML!==html)editor.value.innerHTML=html;
}
function syncContent(){
 if(!editor.value)return;
 const html=editor.value.innerHTML;
 emit('update:modelValue',html==='<br>'?'':html);
}
function focusEditor(){editor.value?.focus();}
function exec(command,value=null){
 focusEditor();
 document.execCommand(command,false,value);
 syncContent();
}
function block(tag){exec('formatBlock',tag);}
function readFile(file,mode='text'){return new Promise((resolve,reject)=>{const reader=new FileReader();reader.onload=()=>resolve(reader.result);reader.onerror=()=>reject(new Error('文件读取失败'));mode==='data'?reader.readAsDataURL(file):reader.readAsText(file);});}
async function insertImage(event){
 const file=event.target.files?.[0];event.target.value='';if(!file)return;
 if(file.size>2*1024*1024){MessagePlugin.warning('正文图片单张不能超过2MB');return;}
 try{const data=await readFile(file,'data');focusEditor();document.execCommand('insertImage',false,data);syncContent();}catch(cause){MessagePlugin.error(cause.message);}
}
async function importDocument(event){
 const file=event.target.files?.[0];event.target.value='';if(!file)return;
 const ext=file.name.split('.').pop()?.toLowerCase();
 if(['html','htm','txt'].includes(ext)){
  try{const raw=String(await readFile(file));const html=ext==='txt'?raw.replace(/[&<>]/g,ch=>({'&':'&amp;','<':'&lt;','>':'&gt;'}[ch])).replace(/\r?\n/g,'<br>'):raw;editor.value.innerHTML=html;syncContent();MessagePlugin.success('正文已导入');}catch(cause){MessagePlugin.error(cause.message);}
  return;
 }
 MessagePlugin.warning('仅支持HTML/TXT正文导入；Word文件请作为附件上传。');
}
function emitFiles(){nextTick(()=>emit('update:files',[...localFiles.value]));}

watch(()=>props.modelValue,value=>nextTick(()=>syncEditor(value)),{immediate:true});
watch(()=>props.files,value=>{
 if(syncing)return;
 syncing=true;
 localFiles.value=(value||[]).map(item=>({...item}));
 nextTick(()=>{syncing=false;});
},{immediate:true,deep:true});
watch(localFiles,value=>{
 if(syncing)return;
 emit('update:files',[...value]);
},{deep:true});
</script>

