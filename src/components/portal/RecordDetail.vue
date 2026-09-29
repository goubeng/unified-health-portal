<template>
  <t-dialog class="portal-record-detail-dialog" placement="center" :visible="visible" :header="dialogTitle" :width="isAccountOpeningDetail?'1120px':kind==='messages'?'1120px':kind==='todos'?'900px':'920px'" :footer="false" @update:visible="$emit('update:visible',$event)">
    <template v-if="record">
      <TodoDetailContent v-if="kind==='todos'" :record="record"/>
      <article v-else-if="kind==='messages'" class="portal-message-letter">
            <h2>{{text(record.title)}}</h2>
            <div class="portal-message-meta">
              <div><Icon name="user"/><span>接收对象</span><strong>{{text(receiver)||'当前登录用户'}}</strong></div>
              <div><Icon name="time"/><span>接收时间</span><strong>{{date(record.receivedAt)}}</strong></div>
              <div><Icon name="mail"/><span>消息类型</span><strong>{{label(record.messageType||'BUSINESS','message_type')}}</strong></div>
              <div><Icon name="tag"/><span>消息来源</span><strong>{{text(record.appName||'统一门户')}}</strong></div>
              <div><Icon name="user-talk"/><span>发送方</span><strong>{{text(record.appName||'统一门户')}}</strong></div>
              <div><Icon name="check-circle"/><span>读取状态</span><strong><t-tag :theme="record.status==='UNREAD'?'warning':'success'" variant="light">{{label(record.status,'message_read_status')}}</t-tag></strong></div>
            </div>
            <p>您好！</p>
            <p class="portal-message-body">{{text(record.content)||'暂无正文'}}</p>
      </article>
      <article v-else-if="kind==='announcements'" class="portal-letter">
        <h2>{{text(record.title)}}</h2>
        <div class="portal-letter-meta"><span><Icon name="time"/> {{date(record.publishedAt||record.createdAt)}}</span><span><Icon name="notification"/> {{text(record.type||'通知')}}</span><span><Icon name="user"/> {{text(receiver)||'当前登录用户'}}</span></div>
        <div class="portal-letter-body portal-rich-content" v-html="richText(record.content)"></div>
        <h3>相关信息</h3><DetailGrid :items="metadata"/>
      </article>
      <section v-else-if="isAccountOpeningDetail" class="portal-generic-detail portal-account-opening-detail">
        <h3 class="portal-detail-section-title">申请信息</h3>
        <dl class="portal-detail-grid portal-account-opening-grid">
          <div v-for="item in openingApplicationDetails" :key="item.key" class="portal-detail-item" :class="item.layout">
            <dt>{{item.label}}</dt>
            <dd><t-tag v-if="item.key==='status'" :theme="theme(record.status)" variant="light">{{label(record.status,'account_opening_status')}}</t-tag><template v-else>{{item.value}}</template></dd>
          </div>
        </dl>
        <h3 class="portal-detail-section-title">处理信息</h3>
        <DetailGrid :items="openingProcessingDetails"/>
      </section>
      <template v-else>
        <div class="portal-generic-detail">
          <h3 v-if="showBasicSectionTitle" class="portal-detail-section-title">基本信息</h3>
          <DetailGrid :items="kind==='apps'?appDetails:(isAuditLog?auditDetails:details)">
            <template v-if="kind==='apps'" #enabled="{item}"><t-tag :theme="theme(item.state)" variant="light">{{item.value}}</t-tag></template>
            <template v-if="kind==='apps'" #aggregateRuntimeStatus="{item}"><t-tag :theme="theme(item.state)" variant="light">{{item.value}}</t-tag></template>
          </DetailGrid>
          <section v-if="showConnection&&kind==='apps'" class="portal-app-connection-detail">
            <h3 class="portal-detail-section-title">连接信息</h3>
            <div class="portal-connection-table">
              <div class="portal-connection-row is-head"><span>接入类型</span><span>接入方式</span><span>配置状态</span><span>启用状态</span></div>
              <div v-for="item in connectionRows" :key="item.kind" class="portal-connection-row">
                <strong>{{item.kind}}</strong>
                <span>{{item.mode}}</span>
                <span><t-tag :theme="theme(item.status)" variant="light">{{label(item.status)}}</t-tag></span>
                <span><t-tag :theme="theme(item.enabledState)" variant="light">{{label(item.enabledState,'enable_status')}}</t-tag></span>
              </div>
            </div>
          </section>
        </div>
      </template>
      <div v-for="file in record.attachments||[]" :key="file.id" class="attachment"><span>{{file.name}}</span><t-button variant="text" @click="$emit('download',file)">下载附件</t-button></div>
    </template>
  </t-dialog>
</template>
<script setup>
import {computed} from 'vue';
import {Icon} from 'tdesign-icons-vue-next';
import DetailGrid from './DetailGrid.vue';
import TodoDetailContent from './TodoDetailContent.vue';
import {text,label,date,titles,display,richText,theme} from './presentation.js';
const props=defineProps({visible:Boolean,record:Object,kind:String,receiver:String,accessProfile:{type:Object,default:null},showConnection:{type:Boolean,default:false}});
defineEmits(['update:visible','download']);
const auditTitles={
  'logs:login':'登录/认证日志详情',
  'logs:access':'应用访问日志详情',
  'logs:operation':'门户操作日志详情',
  'logs:api':'接口调用日志详情',
  'logs:error':'异常日志详情'
};
const auditEventLabels={
  'logs:login':'认证事件',
  'logs:access':'访问事件',
  'logs:operation':'操作类型',
  'logs:api':'接口事件',
  'logs:error':'异常类型'
};
const isAuditLog=computed(()=>String(props.kind||'').startsWith('logs:'));
const isAccountOpeningDetail=computed(()=>props.kind==='accountOpeningRequests'||props.kind==='myApplicationRequests'&&props.record?.requestType==='ACCOUNT_OPENING');
const showBasicSectionTitle=computed(()=>props.kind==='apps'&&props.showConnection);
const dialogTitle=computed(()=>isAccountOpeningDetail.value?'子系统账号开通申请详情':props.kind==='todos'?'待办详情':props.kind==='messages'?'消息详情':props.kind==='announcements'?'公告详情':props.kind==='apps'?'应用详情':props.kind==='myApplicationRequests'?'申请详情':auditTitles[props.kind]||'详情');
const detailTitle=(key)=>{
 const overrides={
  apps:{name:'应用名称',code:'应用编码',enabled:'启用状态'},
  myApplicationRequests:{requestNo:'申请编号',requestType:'申请类型',appName:'应用名称',status:'申请状态'},
  categories:{status:'启用状态'},
  users:{name:'姓名',status:'启用状态'},
  identities:{status:'启用状态'},
  roles:{description:'描述',status:'启用状态'},
  permissions:{code:'权限编码',name:'权限名称'},
  monitor:{appName:'应用名称'}
 };
 if(overrides[props.kind]?.[key])return overrides[props.kind][key];
 if(key==='receivedAt'&&['todos','messages'].includes(props.kind))return '接收时间';
 return titles[key]||key;
};
const details=computed(()=>Object.entries(props.record||{}).filter(([key,value])=>titles[key]&&(key==='permissions'||key==='roleIds'||typeof value!=='object'||value===null)).map(([key,value])=>({key,label:detailTitle(key),value:display(key,value,props.kind==='myApplicationRequests'&&props.record?.requestType==='ACCOUNT_OPENING'?'accountOpeningRequests':props.kind),wide:['content','description','summary','remark','reason','reviewNote','handleNote','permissions','roleIds'].includes(key)})));
const openingApplicationDetails=computed(()=>{
 const row=props.record||{};
 return [
  ['requestNo','申请编号','is-third'],['submittedAt','申请时间','is-third'],['status','状态','is-third'],
  ['userName','申请人','is-third'],['contact','联系方式','is-third'],['userId','统一身份标识','is-third'],
  ['appName','来源应用','is-wide'],
  ['reason','申请原因','is-wide'],['remark','备注','is-wide']
 ].map(([key,labelText,layout])=>({key,label:labelText,layout,value:display(key,row[key],'accountOpeningRequests')}));
});
const openingProcessingDetails=computed(()=>{
 const row=props.record||{};
 return [
  {key:'handledByName',label:'处理人',value:text(row.handledByName)||'-'},
  {key:'handledAt',label:'处理时间',value:date(row.handledAt)},
  {key:'handleNote',label:'处理说明',value:text(row.handleNote)||'-',wide:true}
 ];
});
const appDetails=computed(()=>{
  const row=props.record||{};
  const item=(key,labelText,wide=false)=>({key,label:labelText,value:display(key,row[key],'apps'),wide});
  const enabledState=row.enabled===true?'ENABLED':row.enabled===false?'DISABLED':'UNCONFIGURED';
  return [
    item('name','应用名称'),
    item('code','应用编码'),
    item('category','系统分类'),
    {key:'enabled',label:'启用状态',value:label(enabledState,'enable_status'),state:enabledState},
    item('userType','用户类别'),
    item('createdAt','创建时间'),
    {key:'aggregateRuntimeStatus',label:'综合运行状态',value:display('aggregateRuntimeStatus',row.aggregateRuntimeStatus,'apps'),state:row.aggregateRuntimeStatus||'UNCONFIGURED',wide:true},
    item('url','入口地址',true),
    item('description','说明',true)
  ];
});
const auditDetails=computed(()=>{
  if(!isAuditLog.value)return[];
  const row=props.record||{};
  const item=(key,labelText,wide=false)=>({key,label:labelText,value:display(key,row[key]),wide});
  return [
    item('appName','来源应用'),
    item('actor','操作人'),
    item('name',auditEventLabels[props.kind]||'日志事件'),
    item('status','状态'),
    item('createdAt','发生时间'),
    item('requestId','请求ID'),
    item('description','说明',true)
  ];
});
const metadata=computed(()=>details.value.filter(item=>['appName','status','scope','type','effectiveStart','effectiveEnd'].includes(item.key)));
const connectionRows=computed(()=>['SSO','TODO','MESSAGE'].map(kind=>{
  const item=props.accessProfile?.integrations?.[kind]||null;
  if(!item)return {kind,status:'UNCONFIGURED',enabledState:'UNCONFIGURED',mode:'未配置'};
  const configStatus=item.configStatus||'UNCONFIGURED';
  return {
    kind,
    status:configStatus,
    enabledState:['ENABLED','DISABLED'].includes(item.enabled)?item.enabled:'UNCONFIGURED',
    mode:kind==='SSO'?(item.protocol||item.mode||'未配置'):(item.mode||'未配置')
  };
}));
</script>
