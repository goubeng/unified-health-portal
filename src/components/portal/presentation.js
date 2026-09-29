import {labels,permissions} from '../../config/pages.js';
import {dictionaryLookups} from '../../services/runtime.js';

export const text=value=>String(value??'').replace(/上层身份平台|政务身份平台/g,'闽政务').replace(/公众侧身份平台|公众身份平台/g,'闽政通').replace(/上层公共服务/g,'公共服务').replace(/上层身份/g,'统一身份').replace(/\s*·\s*[^·]*演示/g,'').replace(/(?:模拟|演示|示例)\s*[：:]\s*/g,'').replace(/模拟|演示|示例/g,'').trim();

const escapeHtml=value=>String(value??'').replace(/[&<>"']/g,char=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[char]));
export function richText(value){
  const raw=String(value??'').trim();
  if(!raw)return '<p>暂无正文</p>';
  const hasMarkup=/<\/?[a-z][\s\S]*>/i.test(raw);
  let html=hasMarkup?raw:escapeHtml(raw).replace(/\r?\n/g,'<br>');
  html=html.replace(/<\s*(script|style|iframe|object|embed|link|meta)[^>]*>[\s\S]*?<\/\s*\1\s*>/gi,'')
           .replace(/<\s*(script|style|iframe|object|embed|link|meta)\b[^>]*\/?>/gi,'')
           .replace(/\s+on[a-z]+\s*=\s*("[^"]*"|'[^']*'|[^\s>]+)/gi,'')
           .replace(/(href|src)\s*=\s*(["'])\s*javascript:[\s\S]*?\2/gi,'$1="#"');
  return html;
}
export function label(value,typeCode){
 const item=typeCode&&dictionaryLookups.value.items.find(row=>row.typeCode===typeCode&&row.value===value);
 return text(item?.label||labels[value]||value)||'-';
}
export function dictionaryOptions(typeCode,allowedValues,{includeDisabled=false}={}){
 const type=dictionaryLookups.value.types.find(row=>row.code===typeCode);
 if(type?.status==='DISABLED'&&!includeDisabled)return [];
 const items=dictionaryLookups.value.items.filter(item=>item.typeCode===typeCode);
 const allowed=new Set(allowedValues);
 const ordered=[...items].sort((a,b)=>(a.sortOrder||0)-(b.sortOrder||0));
 if(!ordered.length)return allowedValues.map(value=>({value,label:label(value,typeCode)}));
 return ordered.filter(item=>(includeDisabled||item.status==='ENABLED')&&allowed.has(item.value)).map(item=>({value:item.value,label:label(item.value,typeCode)}));
}
export function dictionaryTypeFor(resource,key){
 if(key==='enabled')return 'enable_status';
 if(['runtimeStatus','aggregateRuntimeStatus','ssoStatus','todoStatus','messageStatus'].includes(key))return 'runtime_status';
 if(key==='messageType')return 'message_type';
 if(key==='businessType')return 'todo_task_type';
 if(key==='readStatus')return 'message_read_status';
 if(key==='scope')return 'announcement_scope';
 if(key==='status')return ({todos:'todo_status',messages:'message_read_status',announcements:'announcement_status',myApplicationRequests:'application_request_status',applicationRequests:'application_request_status',accountOpeningRequests:'account_opening_status',mappings:'mapping_status',exceptions:'mapping_status',identityMappings:'mapping_status',categories:'enable_status',users:'enable_status',identities:'enable_status',roles:'enable_status',organizations:'enable_status',settings:'enable_status'})[resource]||'';
 return '';
}
export const date=value=>value&&Number.isFinite(Date.parse(value))?new Date(value).toLocaleString('zh-CN',{hour12:false}):'-';
export const dateOnly=value=>{
  if(!value||!Number.isFinite(Date.parse(value)))return '-';
  const d=new Date(value),pad=n=>String(n).padStart(2,'0');
  return `${d.getFullYear()}-${pad(d.getMonth()+1)}-${pad(d.getDate())}`;
};
export const source=user=>user?.identitySource?text(user.identitySource):user?.authType==='LOCAL'?'门户本地':user?.userType==='CITIZEN'?'闽政通':'闽政务';
export const theme=value=>['ENABLED','NORMAL','BOUND','READ','SUCCESS','PUBLISHED','CONFIGURED','APPROVED','DIRECT'].includes(value)?'success':['DISABLED','FAILED','FAILURE','DENIED','CONFLICT','ABNORMAL','REJECTED'].includes(value)?'danger':['PENDING','UNREAD','VERIFYING','REVIEWING','OPEN','REQUEST_PENDING','SCHEDULED'].includes(value)?'warning':'default';
export const permissionText=values=>(values||[]).map(value=>permissions[value]||value).join('、')||'无门户管理权限';
export const latest=(rows,key='createdAt',limit=5)=>[...rows].sort((a,b)=>(Date.parse(b[key])||0)-(Date.parse(a[key])||0)).slice(0,limit);
export const titles={name:'名称',account:'登录账号',code:'编码',title:'标题',category:'系统分类',userType:'用户类别',status:'状态',enabled:'启用状态',runtimeStatus:'运行状态',aggregateRuntimeStatus:'综合运行状态',authType:'认证类型',actorType:'主体类型',configStatus:'配置状态',appName:'来源应用',appCode:'应用编码',ssoStatus:'SSO状态',ssoRemark:'SSO备注',todoStatus:'TODO状态',todoRemark:'TODO备注',messageStatus:'MESSAGE状态',messageRemark:'MESSAGE备注',lastCheckedAt:'最近检测时间',messageType:'消息类型',createdAt:'创建时间',receivedAt:'接收时间',publishedAt:'发布时间',content:'正文',summary:'说明',description:'说明',scope:'发布范围',permissions:'门户操作权限',permissionLabels:'门户操作权限',roleIds:'系统角色',roleLabels:'系统角色',roleCode:'角色编码',roleName:'角色名称',externalAccount:'子系统账号',userId:'统一身份标识',source:'身份来源',kind:'接入类型',mode:'接入模式',value:'配置值',remark:'备注',url:'入口地址',mappingStatus:'账号关联状态',orgName:'所属单位',actor:'操作人',effectiveStart:'生效时间',effectiveEnd:'失效日期',type:'公告类型',phone:'手机号',email:'邮箱',requestId:'请求ID',requestNo:'申请编号',userName:'申请人',reason:'申请原因',submittedAt:'申请时间',reviewedAt:'审核时间',reviewNote:'审核意见',withdrawnAt:'撤回时间',expiredAt:'失效时间',contact:'联系方式',accessMode:'访问模式',postGrantMode:'申请通过后',accountBindingMode:'关联方式',accountOpeningMode:'未找到账号时',accessState:'访问状态',requestType:'申请类型',handleNote:'处理说明',handledAt:'处理时间'};
export function display(key,value,resource=''){
  if(key==='permissions')return permissionText(value);
  if(key==='roleIds'||key==='roleNames')return Array.isArray(value)?value.join('、')||'普通用户':text(value)||'普通用户';
  if(key.endsWith('At')||key.startsWith('effective'))return date(value);
  return label(value,dictionaryTypeFor(resource,key));
}
