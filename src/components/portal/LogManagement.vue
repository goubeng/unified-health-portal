<template>
  <section class="portal-list log-management">
    <t-form layout="inline" class="portal-query list-toolbar">
      <t-form-item class="portal-query-keyword query-width-keyword" label="关键词">
        <t-input v-model="keyword" clearable :placeholder="keywordPlaceholder"/>
      </t-form-item>
      <t-form-item v-if="showAppFilter" class="portal-query-select query-width-source" label="来源应用">
        <t-select v-model="appName" clearable filterable placeholder="全部" :options="appOptions"/>
      </t-form-item>
      <t-form-item class="portal-query-select query-width-status" label="结果">
        <t-select v-model="status" clearable placeholder="全部" :options="resultOptions"/>
      </t-form-item>
      <t-form-item v-if="kind==='error'" class="portal-query-select query-width-status" label="处理状态">
        <t-select v-model="resolutionStatus" clearable placeholder="全部" :options="resolutionOptions"/>
      </t-form-item>
      <t-form-item class="portal-query-action">
        <t-button theme="default" variant="outline" @click="reset">重置</t-button>
      </t-form-item>
    </t-form>

    <section class="panel portal-table-panel">
      <t-table row-key="id" :data="paged" :columns="columns" :sort="tableSort" hover table-layout="fixed" size="medium" @sort-change="handleSortChange">
        <template #empty><EmptyState description="暂无符合条件的日志"/></template>
        <template #serial="{rowIndex}">{{(page-1)*pageSize+rowIndex+1}}</template>
        <template #status="{row}"><t-tag :theme="row.status==='SUCCESS'?'success':row.status==='DENIED'?'warning':'danger'" variant="light">{{label(row.status)}}</t-tag></template>
        <template #resolutionStatus="{row}"><t-tag :theme="row.resolutionStatus==='RESOLVED'?'success':'warning'" variant="light">{{label(row.resolutionStatus||'OPEN')}}</t-tag></template>
        <template #requestId="{row}"><TableCellTooltip :text="auditText(row.requestId)||'-'"><button class="portal-field-link" @click="openDetail(row)">{{auditText(row.requestId)||'-'}}</button></TableCellTooltip></template>
        <template #operation="{row}">
          <div class="row-actions">
            <t-button v-if="kind==='error'&&row.resolutionStatus!=='RESOLVED'" size="small" variant="text" theme="primary" @click="openResolve(row)">处理</t-button>
          </div>
        </template>
      </t-table>
      <t-pagination v-model="page" v-model:page-size="pageSize" :total="filtered.length" :page-size-options="[10,20,50]" show-jumper/>
    </section>

    <t-dialog v-model:visible="detailVisible" placement="center" :header="detailTitle" width="820px" :footer="false">
      <DetailGrid v-if="detail" :items="detailItems"/>
    </t-dialog>

    <t-dialog v-model:visible="resolveVisible" placement="center" header="处理异常" width="680px" :confirm-btn="{content:'确认处理',loading:saving}" :close-on-overlay-click="false" @confirm="resolveError">
      <div v-if="formError" class="error-note">{{formError}}</div>
      <DetailGrid v-if="resolveRow" :items="[
        {key:'errorCode',label:'错误编码',value:resolveRow.errorCode||'-'},
        {key:'errorMessage',label:'异常信息',value:resolveRow.errorMessage||resolveRow.description||'-'},
        {key:'requestId',label:'请求ID',value:resolveRow.requestId||'-'}
      ]"/>
      <div class="form-field log-resolution-note"><label>处理说明 <span class="portal-required">*</span></label><t-textarea v-model="resolutionNote" :autosize="{minRows:4,maxRows:7}" placeholder="请填写排查与处理结果"/></div>
    </t-dialog>
  </section>
</template>

<script setup>
import {computed,ref,watch} from 'vue';
import {MessagePlugin} from 'tdesign-vue-next';
import EmptyState from './EmptyState.vue';
import DetailGrid from './DetailGrid.vue';
import TableCellTooltip from './TableCellTooltip.vue';
import {date,label} from './presentation.js';
import {command} from '../../services/runtime.js';

const props=defineProps({rows:{type:Array,default:()=>[]},kind:{type:String,default:'operation'}});
const auditText=value=>String(value??'').trim();
const emit=defineEmits(['saved']);
const keyword=ref(''),appName=ref(''),status=ref(''),resolutionStatus=ref(''),page=ref(1),pageSize=ref(10);
const defaultTableSort=()=>({sortBy:'createdAt',descending:true});
const tableSort=ref(defaultTableSort());
const detailVisible=ref(false),detail=ref(null),resolveVisible=ref(false),resolveRow=ref(null),resolutionNote=ref(''),formError=ref(''),saving=ref(false);
const resultOptions=['SUCCESS','FAILURE','DENIED'].map(value=>({value,label:label(value)}));
const resolutionOptions=['OPEN','RESOLVED'].map(value=>({value,label:label(value)}));
const showAppFilter=computed(()=>props.kind!=='login');
const appOptions=computed(()=>[...new Set(props.rows.map(row=>row.appName).filter(Boolean))].map(value=>({value,label:value})));
const keywordPlaceholder=computed(()=>({
  login:'登录用户 / 账号 / 请求ID',access:'用户 / 应用 / 请求ID',operation:'操作人 / 模块 / 动作',api:'接口 / 应用 / 请求ID',error:'错误编码 / 异常信息 / 请求ID'
}[props.kind]||'关键词'));

const searchFields=computed(()=>({
  login:['userName','account','requestId','failureReason'],access:['userName','account','appName','requestId'],operation:['actor','moduleName','pageName','actionName','requestId'],
  api:['appName','interfaceName','requestId','errorMessage'],error:['errorCode','errorMessage','moduleName','requestId','resolutionNote']
}[props.kind]||['description','requestId']));
const compareLogRows=(a,b,key)=>{
  if(key==='createdAt')return (Date.parse(a.createdAt)||0)-(Date.parse(b.createdAt)||0);
  if(['statusCode','durationMs'].includes(key))return (Number(a[key])||0)-(Number(b[key])||0);
  const enumKeys=['status','identitySource','loginMethod','accessMode','severity','resolutionStatus'];
  const av=key==='actorType'?actorTypeLabel(a):key==='authType'?authTypeLabel(a):enumKeys.includes(key)?label(a[key]):auditText(a[key]);
  const bv=key==='actorType'?actorTypeLabel(b):key==='authType'?authTypeLabel(b):enumKeys.includes(key)?label(b[key]):auditText(b[key]);
  return av.localeCompare(bv,'zh-CN',{numeric:true,sensitivity:'base'});
};
const filtered=computed(()=>{
  const term=keyword.value.trim().toLowerCase();
  const result=props.rows.filter(row=>{
    const matchesKeyword=!term||searchFields.value.some(key=>auditText(row[key]).toLowerCase().includes(term));
    return matchesKeyword&&(!appName.value||row.appName===appName.value)&&(!status.value||row.status===status.value)&&(!resolutionStatus.value||row.resolutionStatus===resolutionStatus.value);
  });
  const active=Array.isArray(tableSort.value)?tableSort.value[0]:tableSort.value;
  if(!active?.sortBy)return result;
  const direction=active.descending?-1:1;
  return result.sort((a,b)=>direction*compareLogRows(a,b,active.sortBy));
});
const paged=computed(()=>filtered.value.slice((page.value-1)*pageSize.value,page.value*pageSize.value));
const column=(colKey,title,options={})=>({colKey,title,...options,cell:(_,ctx)=>auditText(ctx.row[colKey])||'-'});
const sortColumn=(colKey,title,options={})=>column(colKey,title,{...options,sorter:true,sortType:'all'});

const columns=computed(()=>{
  const serial={colKey:'serial',title:'序号',width:64};
  const requestId={colKey:'requestId',title:'请求ID',width:190,ellipsis:true};
  const commonStatus={colKey:'status',title:props.kind==='login'?'登录结果':'结果',width:100,sorter:true,sortType:'all'};
  const operation={colKey:'operation',title:'操作',width:100,fixed:'right'};
  const timeColumn=title=>({colKey:'createdAt',title,width:180,sorter:true,sortType:'all',cell:(_,ctx)=>date(ctx.row.createdAt)});
  if(props.kind==='login')return [
    serial,requestId,timeColumn('登录时间'),
    sortColumn('userName','登录用户',{width:120,ellipsis:true}),sortColumn('account','登录账号',{width:150,ellipsis:true}),
    {colKey:'actorType',title:'主体类型',width:130,sorter:true,sortType:'all',cell:(_,ctx)=>actorTypeLabel(ctx.row)},{colKey:'authType',title:'认证类型',width:110,sorter:true,sortType:'all',cell:(_,ctx)=>authTypeLabel(ctx.row)},
    {colKey:'identitySource',title:'身份来源',width:120,sorter:true,sortType:'all',cell:(_,ctx)=>label(ctx.row.identitySource)},
    sortColumn('loginSource','登录来源',{width:110}),{colKey:'loginMethod',title:'登录方式',width:110,sorter:true,sortType:'all',cell:(_,ctx)=>label(ctx.row.loginMethod)},
    commonStatus,column('failureReason','失败原因',{minWidth:180,ellipsis:true}),column('ip','IP',{width:130}),column('client','客户端',{width:160,ellipsis:true})
  ];
  if(props.kind==='access')return [
    serial,requestId,timeColumn('访问时间'),sortColumn('userName','用户',{width:120}),sortColumn('account','账号',{width:150}),
    sortColumn('appName','来源应用',{minWidth:230,ellipsis:true}),{colKey:'accessMode',title:'访问模式',width:110,sorter:true,sortType:'all',cell:(_,ctx)=>label(ctx.row.accessMode)},commonStatus,
    column('ip','IP',{width:130})
  ];
  if(props.kind==='operation')return [
    serial,requestId,timeColumn('操作时间'),sortColumn('actor','操作人',{width:120}),sortColumn('moduleName','模块',{width:130}),
    sortColumn('pageName','页面',{width:140}),sortColumn('actionName','操作动作',{width:140}),sortColumn('objectType','对象类型',{width:120}),commonStatus
  ];
  if(props.kind==='api')return [
    serial,requestId,timeColumn('调用时间'),sortColumn('appName','来源应用',{minWidth:220,ellipsis:true}),
    sortColumn('interfaceName','接口',{minWidth:250,ellipsis:true}),commonStatus,sortColumn('httpMethod','方法',{width:90}),sortColumn('statusCode','状态码',{width:90}),
    sortColumn('durationMs','耗时(ms)',{width:100}),column('errorMessage','错误信息',{minWidth:200,ellipsis:true})
  ];
  return [
    serial,requestId,timeColumn('发生时间'),{colKey:'severity',title:'级别',width:90,sorter:true,sortType:'all',cell:(_,ctx)=>label(ctx.row.severity)},
    sortColumn('moduleName','模块',{width:130}),sortColumn('errorCode','错误编码',{width:190,ellipsis:true}),column('errorMessage','异常信息',{minWidth:260,ellipsis:true}),
    {colKey:'resolutionStatus',title:'处理状态',width:110,sorter:true,sortType:'all'},column('resolutionNote','处理说明',{minWidth:220,ellipsis:true}),operation
  ];
});

const detailTitle=computed(()=>({login:'登录/认证日志详情',access:'应用访问日志详情',operation:'门户操作日志详情',api:'接口调用日志详情',error:'异常日志详情'}[props.kind]||'日志详情'));
const detailKeys=computed(()=>({
  login:[['createdAt','登录时间'],['userName','登录用户'],['account','登录账号'],['actorType','主体类型'],['authType','认证类型'],['identitySource','身份来源'],['loginSource','登录来源'],['loginMethod','登录方式'],['status','登录结果'],['failureReason','失败原因'],['ip','IP'],['client','客户端'],['requestId','请求ID']],
  access:[['createdAt','访问时间'],['userName','用户'],['account','账号'],['appName','应用'],['accessMode','访问模式'],['status','结果'],['ip','IP'],['requestId','请求ID']],
  operation:[['createdAt','操作时间'],['actor','操作人'],['moduleName','模块'],['pageName','页面'],['actionName','动作'],['objectType','对象类型'],['objectId','对象ID'],['status','结果'],['requestId','请求ID']],
  api:[['createdAt','调用时间'],['appName','来源应用'],['interfaceName','接口'],['status','结果'],['httpMethod','方法'],['statusCode','状态码'],['durationMs','耗时(ms)'],['errorMessage','错误信息'],['requestId','请求ID']],
  error:[['createdAt','发生时间'],['severity','级别'],['moduleName','模块'],['errorCode','错误编码'],['errorMessage','异常信息'],['resolutionStatus','处理状态'],['resolutionNote','处理说明'],['resolvedAt','处理时间'],['requestId','请求ID']]
}[props.kind]||[]));
const actorTypeLabel=row=>row?.actorType==='PORTAL_ADMIN_USER'?'门户管理用户':row?.actorType==='APPLICATION'?'应用':row?.actorType==='ACCESS_USER'?'门户访问用户':'-';
const authTypeLabel=row=>row?.authType==='LOCAL'?'本地账号':row?.authType==='EXTERNAL'?'外部身份':'-';
const detailItems=computed(()=>detailKeys.value.map(([key,labelText])=>{
  let value;
  if(key.endsWith('At')||key==='createdAt')value=date(detail.value?.[key]);
  else if(key==='actorType')value=actorTypeLabel(detail.value);
  else if(key==='authType')value=authTypeLabel(detail.value);
  else if(['status','identitySource','loginMethod','accessMode','severity','resolutionStatus'].includes(key))value=label(detail.value?.[key]);
  else value=auditText(detail.value?.[key])||'-';
  return {key,label:labelText,value};
}));

function handleSortChange(sort){
  const next=Array.isArray(sort)?sort[0]:sort;
  tableSort.value=next?.sortBy?{sortBy:next.sortBy,descending:!!next.descending}:defaultTableSort();
  page.value=1;
}
function reset(){keyword.value='';appName.value='';status.value='';resolutionStatus.value='';tableSort.value=defaultTableSort();page.value=1;}
function openDetail(row){detail.value=JSON.parse(JSON.stringify(row));detailVisible.value=true;}
function openResolve(row){resolveRow.value=JSON.parse(JSON.stringify(row));resolutionNote.value='';formError.value='';resolveVisible.value=true;}
async function resolveError(){
  if(!resolutionNote.value.trim()){formError.value='请填写处理说明';return;}
  saving.value=true;formError.value='';
  const result=await command('resolveLogError',{id:resolveRow.value.id,version:resolveRow.value.version,resolutionNote:resolutionNote.value.trim()});
  saving.value=false;
  if(!result.ok){formError.value=result.error.message;return;}
  resolveVisible.value=false;MessagePlugin.success('异常已处理');emit('saved');
}
watch([keyword,appName,status,resolutionStatus,pageSize],()=>{page.value=1;});
watch(()=>filtered.value.length,()=>{page.value=Math.min(page.value,Math.max(1,Math.ceil(filtered.value.length/pageSize.value)));});
</script>
