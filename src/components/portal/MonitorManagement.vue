<template>
  <section class="portal-list monitor-management">
    <Teleport to="#page-header-actions">
      <div class="monitor-header-view-switch" role="group" aria-label="运行监控视图切换">
        <t-button v-if="canCheck" variant="outline" theme="primary" @click="openObservation()">录入检测结果</t-button>
        <t-button
          :theme="viewMode==='table'?'primary':'default'"
          :variant="viewMode==='table'?'base':'outline'"
          @click="viewMode='table'"
        >
          <template #icon><t-icon name="view-list"/></template>
          列表
        </t-button>
        <t-button
          :theme="viewMode==='visual'?'primary':'default'"
          :variant="viewMode==='visual'?'base':'outline'"
          @click="viewMode='visual'"
        >
          <template #icon><t-icon name="view-module"/></template>
          卡片
        </t-button>
      </div>
    </Teleport>
    <p class="inline-note">运行状态为本地演示样本，尚未接入真实上下游系统；“正常”仅用于演示，不代表实际连通。</p>
    <div class="monitor-health-grid">
      <section class="monitor-health-card monitor-health-total-card">
        <span class="monitor-health-kind-icon tone-cyan">
          <AppIcon/>
        </span>
        <div class="monitor-health-content">
          <strong class="monitor-health-title">纳管应用</strong>
          <div class="monitor-health-total">
            <b>{{props.rows.length}}</b>
            <span>个</span>
          </div>
        </div>
      </section>
      <section v-for="item in monitorHealthStats" :key="item.kind" class="monitor-health-card">
        <span class="monitor-health-kind-icon" :class="'tone-'+item.tone">
          <component :is="monitorHealthIcon(item.kind)"/>
        </span>
        <div class="monitor-health-content">
          <strong class="monitor-health-title">{{item.kind}}</strong>
          <div class="monitor-health-stats">
            <span class="monitor-health-stat is-normal">
              <t-icon name="check-circle" class="monitor-health-stat-icon"/>
              <em>正常</em>
              <b>{{item.normal}}</b>
            </span>
            <span class="monitor-health-stat is-abnormal">
              <t-icon name="error-circle" class="monitor-health-stat-icon"/>
              <em>异常</em>
              <b>{{item.abnormal}}</b>
            </span>
            <span class="monitor-health-stat is-muted">
              <t-icon name="minus-circle" class="monitor-health-stat-icon"/>
              <em>未配置/停用</em>
              <b>{{item.inactive}}</b>
            </span>
          </div>
        </div>
      </section>
    </div>
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
    </t-form>

    <section v-if="viewMode==='table'" class="panel portal-table-panel">
      <t-table row-key="id" :data="paged" :columns="columns" :sort="tableSort" hover table-layout="fixed" size="medium" @sort-change="handleSortChange">
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
      <div class="monitor-visual-meta">
        <span class="monitor-visual-summary"><t-icon name="app" class="monitor-visual-summary-icon"/>纳管应用 <strong>{{props.rows.length}}</strong> 个</span>
        <div class="monitor-visual-legend">
          <span>状态图例：</span>
          <t-tag theme="success" variant="light" size="small">正常</t-tag>
          <t-tag theme="danger" variant="light" size="small">异常 / 停用</t-tag>
          <t-tag theme="default" variant="light" size="small">未配置</t-tag>
        </div>
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
            ><span class="monitor-visual-status-dot" aria-hidden="true"></span>{{kind}}</t-tag>
          </span>
        </button>
      </div>
      <EmptyState v-else description="暂无符合条件的运行监控记录"/>
    </section>

    <section class="panel monitor-history-panel">
      <div class="section-head"><h2>接入状态变更记录</h2><span>共 {{historyRows.length}} 条</span></div>
      <t-table row-key="id" :data="pagedHistory" :columns="historyColumns" hover table-layout="fixed" size="medium">
        <template #empty><EmptyState description="暂无状态变更记录；既有状态快照不补造历史"/></template>
        <template #occurredAt="{row}">{{date(row.occurredAt)}}</template>
        <template #fromStatus="{row}"><StatusTag :value="row.fromStatus"/></template>
        <template #toStatus="{row}"><StatusTag :value="row.toStatus"/></template>
        <template #reason="{row}"><TableCellTooltip :text="text(row.reason)||'-'"/></template>
      </t-table>
      <t-pagination v-model="historyPage" :page-size="10" :total="historyRows.length" :page-size-options="[10]" show-jumper/>
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
          <StatusTag :value="row.runStatus"/>
        </template>
      </t-table>
    </t-dialog>
    <t-dialog v-model:visible="observationVisible" placement="center" header="录入检测结果" width="560px" :confirm-btn="{content:'保存',loading:observationSaving}" :close-on-overlay-click="false" @confirm="saveObservation">
      <div v-if="observationError" role="alert" class="error-note">{{observationError}}</div>
      <div class="form-field"><label>应用 <span class="portal-required">*</span></label><t-select v-model="observation.appId" filterable :options="observationApps" placeholder="请选择应用" @change="observation.kind=''"/></div>
      <div class="form-field"><label>接入服务 <span class="portal-required">*</span></label><t-select v-model="observation.kind" :options="observationKinds" placeholder="请选择接入服务"/></div>
      <div class="form-field"><label>检测结果 <span class="portal-required">*</span></label><t-select v-model="observation.status" :options="observationStatuses" placeholder="请选择检测结果"/></div>
      <div class="form-field"><label>{{observation.status==='ABNORMAL'?'异常原因':'检测说明'}} <span v-if="observation.status==='ABNORMAL'" class="portal-required">*</span></label><t-textarea v-model="observation.reason" :autosize="{minRows:3,maxRows:6}" :maxlength="500"/></div>
    </t-dialog>
  </section>
</template>

<script setup>
import {computed,defineComponent,h,ref,watch} from 'vue';
import {Tag} from 'tdesign-vue-next';
import {MessagePlugin} from 'tdesign-vue-next';
import {AppIcon,LinkIcon,TaskIcon,MailIcon} from 'tdesign-icons-vue-next';
import EmptyState from './EmptyState.vue';
import TableCellTooltip from './TableCellTooltip.vue';
import {date,label,text,theme,dictionaryOptions} from './presentation.js';
import {command} from '../../services/runtime.js';

const props=defineProps({rows:{type:Array,default:()=>[]},historyRows:{type:Array,default:()=>[]},canCheck:{type:Boolean,default:false}});
const emit=defineEmits(['saved']);
const keyword=ref(''),ssoStatus=ref(''),todoStatus=ref(''),messageStatus=ref(''),viewMode=ref('table'),page=ref(1),pageSize=ref(10);
const historyPage=ref(1),observationVisible=ref(false),observationSaving=ref(false),observationError=ref('');
const observation=ref({appId:'',kind:'',status:'',reason:''});
const observationApps=computed(()=>props.rows.filter(row=>row.appEnabled&&Object.values(row.services||{}).some(service=>service.enabled==='ENABLED'&&service.configStatus==='CONFIGURED')).map(row=>({value:row.appId,label:row.appName})));
const observationKinds=computed(()=>{
  const app=props.rows.find(row=>row.appId===observation.value.appId);
  return kinds.filter(kind=>app?.services?.[kind]?.enabled==='ENABLED'&&app?.services?.[kind]?.configStatus==='CONFIGURED').map(value=>({value,label:value}));
});
const observationStatuses=[{value:'NORMAL',label:'正常'},{value:'ABNORMAL',label:'异常'}];
const pagedHistory=computed(()=>props.historyRows.slice((historyPage.value-1)*10,historyPage.value*10));
const historyColumns=[
  {colKey:'occurredAt',title:'发生时间',width:170},
  {colKey:'appName',title:'应用名称',minWidth:220,ellipsis:true},
  {colKey:'kind',title:'接入服务',width:100},
  {colKey:'fromStatus',title:'原状态',width:110},
  {colKey:'toStatus',title:'新状态',width:110},
  {colKey:'reason',title:'原因/说明',minWidth:220,ellipsis:true}
];
const defaultTableSort=()=>({sortBy:'lastCheckedAt',descending:true});
const tableSort=ref(defaultTableSort());
const detailVisible=ref(false),detail=ref(null),kinds=['SSO','TODO','MESSAGE'];
const statusOptions=computed(()=>dictionaryOptions('runtime_status',['NORMAL','ABNORMAL','UNCONFIGURED','DISABLED']));
const monitorHealthTones={SSO:'blue',TODO:'green',MESSAGE:'purple'};
const monitorHealthIcons={SSO:LinkIcon,TODO:TaskIcon,MESSAGE:MailIcon};
const monitorHealthIcon=kind=>monitorHealthIcons[kind]||LinkIcon;
const monitorHealthStats=computed(()=>kinds.map(kind=>{
  const key=kind.toLowerCase()+'Status';
  const statuses=props.rows.map(row=>row?.[key]);
  return {
    kind,
    tone:monitorHealthTones[kind]||'blue',
    normal:statuses.filter(value=>value==='NORMAL').length,
    abnormal:statuses.filter(value=>value==='ABNORMAL').length,
    inactive:statuses.filter(value=>value==='UNCONFIGURED'||value==='DISABLED').length
  };
}));
const StatusTag=defineComponent({props:{value:{type:String,default:'UNCONFIGURED'}},setup(p){return()=>h(Tag,{theme:theme(p.value),variant:'light'},()=>label(p.value,'runtime_status'));}});

const filtered=computed(()=>{
  const term=keyword.value.trim().toLowerCase();
  return props.rows.filter(row=>{
    const matchKeyword=!term||[row.appName,row.appCode].some(value=>text(value).toLowerCase().includes(term));
    return matchKeyword&&(!ssoStatus.value||row.ssoStatus===ssoStatus.value)&&(!todoStatus.value||row.todoStatus===todoStatus.value)&&(!messageStatus.value||row.messageStatus===messageStatus.value);
  });
});
const compareMonitorRows=(a,b,key)=>{
  if(key==='lastCheckedAt')return (Date.parse(a.lastCheckedAt)||0)-(Date.parse(b.lastCheckedAt)||0);
  return text(a[key]).localeCompare(text(b[key]),'zh-CN',{numeric:true,sensitivity:'base'});
};
const sortedFiltered=computed(()=>{
  const rows=filtered.value.slice();
  const active=Array.isArray(tableSort.value)?tableSort.value[0]:tableSort.value;
  if(!active?.sortBy)return rows;
  const direction=active.descending?-1:1;
  return rows.sort((a,b)=>direction*compareMonitorRows(a,b,active.sortBy));
});
const paged=computed(()=>sortedFiltered.value.slice((page.value-1)*pageSize.value,page.value*pageSize.value));
const columns=[
  {colKey:'serial',title:'序号',width:64},
  {colKey:'appName',title:'应用名称',minWidth:250,ellipsis:true,sorter:true,sortType:'all'},
  {colKey:'appCode',title:'应用编码',width:170,ellipsis:true,sorter:true,sortType:'all'},
  {colKey:'ssoStatus',title:'SSO状态',width:120},
  {colKey:'todoStatus',title:'TODO状态',width:120},
  {colKey:'messageStatus',title:'MESSAGE状态',width:135},
  {colKey:'lastCheckedAt',title:'最近检测时间',width:180,sorter:true,sortType:'all'}
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
    runStatus:runtimeStatus,
    lastCheckedAt:date(item.lastCheckedAt),
    lastSuccessAt:date(item.lastSuccessAt),
    lastFailureAt:date(item.lastFailureAt),
    responseTime:item.responseTimeMs==null?'-':String(item.responseTimeMs)+' ms',
    lastError:text(item.lastError)||'-'
  };
}));

const visualStatusTheme=value=>value==='NORMAL'?'success':['DISABLED','ABNORMAL'].includes(value)?'danger':'default';
function handleSortChange(sort){
  const next=Array.isArray(sort)?sort[0]:sort;
  tableSort.value=next?.sortBy?{sortBy:next.sortBy,descending:!!next.descending}:defaultTableSort();
  page.value=1;
}
function reset(){keyword.value='';ssoStatus.value='';todoStatus.value='';messageStatus.value='';tableSort.value=defaultTableSort();page.value=1;}
function openDetail(row){detail.value=JSON.parse(JSON.stringify(row));detailVisible.value=true;}
function openObservation(){observation.value={appId:'',kind:'',status:'',reason:''};observationError.value='';observationVisible.value=true;}
async function saveObservation(){
  const payload={...observation.value,reason:observation.value.reason.trim()};
  if(!payload.appId||!payload.kind||!payload.status||(payload.status==='ABNORMAL'&&!payload.reason)){observationError.value='请填写应用、接入服务、检测结果及必填的异常原因';return;}
  observationSaving.value=true;observationError.value='';
  try{
    const result=await command('recordMonitorObservation',payload);
    if(!result.ok){observationError.value=result.error?.message||'保存失败';return;}
    observationVisible.value=false;MessagePlugin.success('检测结果已记录');emit('saved');
  }catch(error){observationError.value=error.message||'保存失败';}
  finally{observationSaving.value=false;}
}
watch([keyword,ssoStatus,todoStatus,messageStatus,pageSize],()=>{page.value=1;});
watch(()=>filtered.value.length,()=>{page.value=Math.min(page.value,Math.max(1,Math.ceil(filtered.value.length/pageSize.value)));});
watch(()=>props.historyRows.length,()=>{historyPage.value=Math.min(historyPage.value,Math.max(1,Math.ceil(props.historyRows.length/10)));});
</script>
