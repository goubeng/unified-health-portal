<template>
  <section class="announcement-editor">
    <label class="announcement-editor-label">正文<span class="portal-required"> *</span></label>
    <div class="rich-editor-shell">
      <div class="rich-editor-toolbar" role="toolbar" aria-label="公告正文格式工具栏" @mousedown.capture="saveSelection">
        <t-tooltip content="加粗"><t-button class="editor-icon-button" size="small" variant="text" @click.prevent="exec('bold')"><Icon name="textformat-bold"/></t-button></t-tooltip>
        <t-tooltip content="斜体"><t-button class="editor-icon-button" size="small" variant="text" @mousedown.prevent="saveSelection" @click.prevent="exec('italic')"><Icon name="textformat-italic"/></t-button></t-tooltip>
        <t-tooltip content="下划线"><t-button class="editor-icon-button" size="small" variant="text" @click.prevent="exec('underline')"><Icon name="textformat-underline"/></t-button></t-tooltip>
        <span class="toolbar-divider"></span>
        <t-tooltip content="文字大小">
          <t-select v-model="fontSize" class="editor-toolbar-select editor-font-size-select" size="small" :options="fontSizeOptions" @change="changeFontSize"/>
        </t-tooltip>
        <t-tooltip content="文字颜色">
          <t-color-picker
            v-model="textColor"
            class="editor-color-picker"
            size="small"
            format="HEX"
            :enable-alpha="false"
            :swatch-colors="colorSwatches"
            @change="changeTextColor"
          />
        </t-tooltip>
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
        <t-tooltip content="清空全部正文">
          <t-button class="editor-clear-content-button" size="small" variant="text" theme="danger" @click.prevent="clearContent">清空正文</t-button>
        </t-tooltip>
        <input ref="imageInput" class="editor-hidden-input" type="file" accept="image/*" @change="insertImage"/>
        <input ref="importInput" class="editor-hidden-input" type="file" accept=".html,.htm,.txt" @change="importDocument"/>
      </div>
      <div ref="editor" class="rich-editor-content" contenteditable="true" :data-placeholder="placeholder" @input="syncContent" @blur="syncContent" @mouseup="saveSelection" @keyup="saveSelection"></div>
      <div class="rich-editor-limit" :class="{ 'is-limit-exceeded': charCount > maxlength }">{{ charCount }}/{{ maxlength }}</div>
    </div>

    <label class="announcement-editor-label attachment-label">附件</label>
    <t-upload
      v-model="localFiles"
      theme="file"
      :auto-upload="false"
      multiple
      accept="image/*,.pdf,.doc,.docx,.xls,.xlsx,.txt,.zip"
      :max="5"
      :size-limit="{ size: 20, unit: 'MB' }"
      :abridge-name="[16,8]"
      tips="支持图片、PDF、Word、Excel、TXT、ZIP，单个不超过20MB，最多5个附件"
      @change="emitFiles"
      @remove="emitFiles"
    />
  </section>
</template>

<script setup>
import {nextTick,ref,watch} from 'vue';
import {MessagePlugin} from 'tdesign-vue-next';
import {Icon} from 'tdesign-icons-vue-next';

const props=defineProps({modelValue:{type:String,default:''},files:{type:Array,default:()=>[]},maxlength:{type:Number,default:10000},placeholder:{type:String,default:'请输入公告正文（支持格式排版、插入图片与导入文本）'}});
const emit=defineEmits(['update:modelValue','update:files']);
const editor=ref(null),localFiles=ref([]),imageInput=ref(null),importInput=ref(null),charCount=ref(0);
const fontSize=ref('13px'),textColor=ref('#1f2329');
const fontSizeOptions=['12px','13px','14px','16px','18px','20px','24px','32px'].map(value=>({value,label:value}));
const colorSwatches=['#1f2329','#d54941','#ed7b2f','#e37318','#2ba471','#00a870','#0052d9','#2454ff','#7356e8','#8b5cf6','#86909c','#ffffff'];
let syncing=false,savedRange=null;

function updateCharCount(){if(!editor.value){charCount.value=0;return;}charCount.value=(editor.value.innerText||'').replace(/[\r\n]/g,'').length;}
function syncEditor(value){
 if(!editor.value)return;
 const html=String(value||'');
 if(editor.value.innerHTML!==html){editor.value.innerHTML=html;savedRange=null;}updateCharCount();
}
function syncContent(){
 if(!editor.value)return;
 const html=editor.value.innerHTML;
 const cleanHtml=html==='<br>'||html==='<div><br></div>'?'':html;if(!cleanHtml&&html)editor.value.innerHTML='';emit('update:modelValue',cleanHtml);updateCharCount();
}
function saveSelection(){
 const selection=window.getSelection?.();
 if(!selection?.rangeCount||!editor.value?.contains(selection.anchorNode))return;
 savedRange=selection.getRangeAt(0).cloneRange();
}
function restoreSelection(){
 if(!savedRange)return;
 try{
  const selection=window.getSelection();
  selection.removeAllRanges();
  selection.addRange(savedRange);
 }catch{savedRange=null;}
}
function focusEditor(){editor.value?.focus();restoreSelection();}
function exec(command,value=null){
 focusEditor();
 document.execCommand(command,false,value);
 saveSelection();
 syncContent();
}
function block(tag){exec('formatBlock',tag);}
function clearContent(){
 if(!editor.value)return;
 editor.value.innerHTML='';
 savedRange=null;
 emit('update:modelValue','');updateCharCount();
 editor.value.focus();
}
function changeFontSize(value){
 if(!value)return;
 fontSize.value=value;
 focusEditor();
 document.execCommand('fontSize',false,'7');
 editor.value?.querySelectorAll('font[size="7"]').forEach(node=>{
  node.removeAttribute('size');
  node.style.fontSize=value;
 });
 saveSelection();
 syncContent();
}
function changeTextColor(value){
 if(!value)return;
 textColor.value=value;
 focusEditor();
 document.execCommand('styleWithCSS',false,true);
 document.execCommand('foreColor',false,value);
 saveSelection();
 syncContent();
}
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

