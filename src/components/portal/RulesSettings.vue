<template>
 <div class="rules-settings-page">
  <t-alert class="rules-page-notice" theme="info" message="统一维护门户规则。公告自动清理默认关闭，开启后每分钟检查；已清理公告保留回收档案。身份平台密码规则不在此维护。"/>
  <section class="panel rules-settings">
   <t-form class="rules-settings-form" @submit.prevent>
    <div class="rules-settings-scroll">
     <section v-for="group in groups" :key="group" class="rule-group"><h3>{{group}}</h3>
      <div class="rule-grid">
       <div v-for="rule in rules.filter(x=>x.group===group)" :key="rule.code" class="rule-field">
        <div class="rule-field-label">{{rule.name}}</div>
        <div class="rule-value"><t-input-number v-model="values[rule.code]" :min="rule.min" :max="rule.max" :decimal-places="0"/><span>{{rule.unit}}</span></div>
        <p class="rule-help">{{rule.help}}</p>
       </div>
      </div>
     </section>
    </div>
    <div class="rules-settings-footer">
     <t-button theme="primary" :loading="saving" @click="save">应用修改</t-button>
     <p v-if="error" role="alert" class="rules-settings-error">{{error}}</p>
    </div>
   </t-form>
  </section>
 </div>
</template>
<script setup>
import {reactive,ref,watch} from 'vue';
import {MessagePlugin} from 'tdesign-vue-next';
import {rules} from '../../config/rules.js';
import {command} from '../../services/runtime.js';
const props=defineProps({rows:{type:Array,default:()=>[]}}),emit=defineEmits(['saved']);
const values=reactive({}),saving=ref(false),error=ref(''),groups=[...new Set(rules.map(x=>x.group))];
watch(()=>props.rows,rows=>{for(const rule of rules)values[rule.code]=Number(rows.find(x=>x.code===rule.code)?.value??rule.default);},{immediate:true});
async function save(){
 if(saving.value)return;
 error.value='';saving.value=true;
 try{const result=await command('saveRules',{items:rules.map(rule=>({...props.rows.find(x=>x.code===rule.code),code:rule.code,value:values[rule.code]}))});if(!result.ok){error.value=result.error.message;return;}MessagePlugin.success('规则已保存');emit('saved');}finally{saving.value=false;}
}
</script>
