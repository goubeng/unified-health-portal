<template>
  <section class="portal-list monitor-management">
    <p class="inline-note">运行状态为本地演示样本，尚未接入真实上下游系统；“正常”仅用于演示，不代表实际连通。</p>
    <t-form layout="inline" class="portal-query list-toolbar">
      <t-form-item class="portal-query-keyword query-width-keyword" label="应用">
        <t-input v-model="keyword" clearable placeholder="应用名称 / 应用编码"/>
      </t-form-item>
      <t-form-item class="portal-query-select query-width-sso-status" label="SSO状态">
        <t-select v-model="ssoStatus" clearable placeholder="全部" :options="statusOptions"/>
      </t-form-item>
      <t-form-item class="portal-query-select query-width-todo-status" label="TODO状态">
        <t-select v-model="todoStatus" clearable placeholder="全部" :options="statusOptions"/>
      </t-form-item>
      <t-form-item class="portal-query-select query-width-message-status" label="MESSAGE状态">
        <t-select v-model="messageStatus" clearable placeholder="全部" :options="statusOptions"/>
      </t-form-item>
      <t-form-item class="portal-query-action">
        <t-button theme="default" variant="outline" @click="reset">重置</t-button>
      </t-form-item>
      <t-form-item class="monitor-view-switch">
        <t-radio-group v-model="viewMode" variant="default-filled" size="small">
          <t-radio-button value="table">列表</t-radio-button>
          <t-radio-button value="visual">图示</t-radio-button>
        </t-radio-group>
      </t-form-item>
    </t-form>

    <section v-if="viewMode==='table'" class="panel portal-table-panel">
      <t-table row-key="id" :data="paged" :columns="columns" hover table-layout="fixed" size="medium">
        <template #empty><EmptyState description="暂无符合条件的运行监控记录"/></template>
        <template #serial="{rowIndex}">{{(page-1)*pageSize+rowIndex+1}}</template>
        <template #appName="{row}"><TableCellTooltip :text="text(row.appName)"><button class="portal-field-link" @click="openDetail(row)">{{text(row.appName)}}</button></TableCellTooltip></template>
        <template #ssoStatus="{row}"><StatusTag :value="row.ssoStatus"/></template>
        <template #todoStatus="{row}"><StatusTag :value="row.todoStatus"/></template>
        <template #messageStatus="{row}"><StatusTag :value="row.messageStatus"/></template>
        <template #lastCheckedAt="{row}">{{date(row.lastCheckedAt)}}</template>
      </t-table>
      <t-pagination v-model="page" v-model:page-size="pageSize" :total="filtered.length" :page-size-options="[10,20,50]" show-jumper/>
    </section>

    <section v-else class="panel monitor-visual-panel">
      <div class="monitor-visual-legend">
        <span>状态图例：</span>
        <t-tag theme="success" variant="light" size="small">正常</t-tag>
        <t-tag theme="danger" variant="light" size="small">异常 / 停用</t-tag>
        <t-tag theme="default" variant="light" size="small">未配置</t-tag>
      </div>
      <div v-if="filtered.length" class="monitor-visual-grid">
        <button v-for="row in filtered" :key="row.id" type="button" class="monitor-visual-card" @click="openDetail(row)">
          <span class="monitor-visual-name" :title="text(row.appName)">{{text(row.appName)}}</span>
          <span class="monitor-visual-status-grid">
            <t-tag
              v-for="kind in kinds"
              :key="kind"
              class="monitor-visual-status-tag"
              :theme="visualStatusTheme(row[kind.toLowerCase()+'Status'])"
              variant="light"
              size="small"
            >{{kind}} {{visualStatusText(row[kind.toLowerCase()+'Status'])}}</t-tag>
          </span>
        </button>
      </div>
      <EmptyState v-else description="暂无符合条件的运行监控记录"/>
    </section>

    <t-dialog
      v-model:visible="detailVisible"
      placement="center"
      :header="(text(detail?.appName)||'应用')+' · 运行监控'"
      width="min(1180px, calc(100vw - 48px))"
      :footer="false"
    >
      <t-table
        v-if="detail"
        row-key="kind"
        :data="detailRows"
        :columns="detailColumns"
        hover
        table-layout="fixed"
        size="medium"
      >
        <template #configStatus="{row}">
          <t-tag :theme="row.configStatus==='CONFIGURED'?'success':'default'" variant="light">
            {{row.configStatus==='CONFIGURED'?'已配置':'未配置'}}
          </t-tag>
        </template>
        <template #enabled="{row}">
          <span>{{row.enabled}}</span>
        </template>
        <template #runStatus="{row}">
          <StatusTag v-if="row.runStatus!=='-'" :value="row.runStatus"/>
          <span v-else>-</span>
        </template>
      </t-table>
    </t-dialog>
  </section>
</template>

<script setup>
import {computed,defineComponent,h,ref,watch} from 'vue';
import {Tag} from 'tdesign-vue-next';
import EmptyState from './EmptyState.vue';
import TableCellTooltip from './TableCellTooltip.vue';
import {date,label,text,theme,dictionaryOptions} from './presentation.js';

const props=defineProps({rows:{type:Array,default:()=>[]}});
const keyword=ref(''),ssoStatus=ref(''),todoStatus=ref(''),messageStatus=ref(''),viewMode=ref('table'),page=ref(1),pageSize=ref(10);
const detailVisible=ref(false),detail=ref(null),kinds=['SSO','TODO','MESSAGE'];
const statusOptions=computed(()=>dictionaryOptions('runtime_status',['NORMAL','ABNORMAL','UNCONFIGURED','DISABLED']));
const StatusTag=defineComponent({props:{value:{type:String,default:'UNCONFIGURED'}},setup(p){return()=>h(Tag,{theme:theme(p.value),variant:'light'},()=>label(p.value,'runtime_status'));}});

const filtered=computed(()=>{
  const term=keyword.value.trim().toLowerCase();
  return props.rows.filter(row=>{
    const matchKeyword=!term||[row.appName,row.appCode].some(value=>text(value).toLowerCase().includes(term));
    return matchKeyword&&(!ssoStatus.value||row.ssoStatus===ssoStatus.value)&&(!todoStatus.value||row.todoStatus===todoStatus.value)&&(!messageStatus.value||row.messageStatus===messageStatus.value);
  });
});
const paged=computed(()=>filtered.value.slice((page.value-1)*pageSize.value,page.value*pageSize.value));
const columns=[
  {colKey:'serial',title:'序号',width:64},
  {colKey:'appName',title:'应用名称',minWidth:250,ellipsis:true},
  {colKey:'appCode',title:'应用编码',width:170,ellipsis:true},
  {colKey:'ssoStatus',title:'SSO状态',width:120},
  {colKey:'todoStatus',title:'TODO状态',width:120},
  {colKey:'messageStatus',title:'MESSAGE状态',width:135},
  {colKey:'lastCheckedAt',title:'最近检测时间',width:180}
];

const detailColumns=[
  {colKey:'kind',title:'接入服务',width:100},
  {colKey:'configStatus',title:'配置状态',width:110},
  {colKey:'enabled',title:'启用状态',width:100},
  {colKey:'runStatus',title:'运行状态',width:110},
  {colKey:'lastCheckedAt',title:'最近检测',width:165},
  {colKey:'lastSuccessAt',title:'最近成功',width:165},
  {colKey:'lastFailureAt',title:'最近失败',width:165},
  {colKey:'responseTime',title:'响应耗时',width:110},
  {colKey:'lastError',title:'最近错误',minWidth:210,ellipsis:true}
];

const detailRows=computed(()=>kinds.map(kind=>{
  const item=detail.value?.services?.[kind]||{};
  const configStatus=item.configStatus||'UNCONFIGURED';
  const runtimeStatus=item.runtimeStatus||'UNCONFIGURED';
  return {
    kind,
    configStatus,
    enabled:item.enabled==='ENABLED'?'启用':item.enabled==='DISABLED'?'停用':'-',
    runStatus:configStatus==='CONFIGURED'?runtimeStatus:'-',
    lastCheckedAt:date(item.lastCheckedAt),
    lastSuccessAt:date(item.lastSuccessAt),
    lastFailureAt:date(item.lastFailureAt),
    responseTime:item.responseTimeMs==null?'-':String(item.responseTimeMs)+' ms',
    lastError:text(item.lastError)||'-'
  };
}));

const visualStatusText=value=>value==='NORMAL'?'正常':value==='DISABLED'?'停用':value==='ABNORMAL'?'异常':'未配置';
const visualStatusTheme=value=>value==='NORMAL'?'success':['DISABLED','ABNORMAL'].includes(value)?'danger':'default';
function reset(){keyword.value='';ssoStatus.value='';todoStatus.value='';messageStatus.value='';page.value=1;}
function openDetail(row){detail.value=JSON.parse(JSON.stringify(row));detailVisible.value=true;}
watch([keyword,ssoStatus,todoStatus,messageStatus,pageSize],()=>{page.value=1;});
watch(()=>filtered.value.length,()=>{page.value=Math.min(page.value,Math.max(1,Math.ceil(filtered.value.length/pageSize.value)));});
</script>
