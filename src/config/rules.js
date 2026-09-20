export const rules=[
 {code:'retention.announcement_expired_days',name:'公告过期后自动删除',group:'公告规则',unit:'天',min:0,max:3650,default:0,help:'0 表示不自动删除；仅处理已发布且有失效时间的公告。清理记录保留在回收档案和审计中。'},
 {code:'retention.message_days',name:'消息留存周期',group:'留存规则',unit:'天',min:1,max:3650,default:90,help:'保留策略参数；消息清理任务尚未启用。'},
 {code:'retention.todo_terminal_days',name:'终态待办留存周期',group:'留存规则',unit:'天',min:1,max:3650,default:180,help:'仅针对已终结事项；待办清理任务尚未启用。'},
 {code:'retention.log_days',name:'日志留存周期',group:'留存规则',unit:'天',min:1,max:3650,default:180,help:'审计留存策略；当前不会自动删除审计记录。'},
 {code:'auth.session_ttl_seconds',name:'门户会话有效期',group:'访问规则',unit:'秒',min:60,max:86400,default:7200,help:'对新建立的门户会话生效，不改变闽政通/闽政务认证规则。'},
 {code:'integration.timeout_ms',name:'接口超时时间',group:'接入规则',unit:'毫秒',min:100,max:60000,default:5000,help:'对接预留参数，当前PUSH接收不主动请求子系统。'},
 {code:'integration.max_retries',name:'接口重试上限',group:'接入规则',unit:'次',min:0,max:10,default:3,help:'重试建议，来源系统负责PUSH重试；门户不主动拉取。'},
 {code:'monitor.failure_threshold',name:'连续失败告警阈值',group:'监控规则',unit:'次',min:1,max:100,default:5,help:'监控策略参数，外部探测尚未接入。'}
];
export function ensureRules(state){for(const rule of rules)if(!state.settings.some(x=>x.code===rule.code))state.settings.push({id:'RULE_'+rule.code,version:1,...rule,value:rule.default,status:'CONFIGURED'});return state;}
export function archiveExpired(state,now=Date.now()){
 const days=Number(state.settings.find(x=>x.code==='retention.announcement_expired_days')?.value);
 if(!Number.isSafeInteger(days)||days<=0)return [];
 const expired=state.announcements.filter(x=>x.status==='PUBLISHED'&&x.effectiveEnd&&Number.isFinite(Date.parse(x.effectiveEnd))&&Date.parse(x.effectiveEnd)+days*86400000<=now);
 if(!expired.length)return [];
 state.announcementTrash??=[];
 for(const row of expired)state.announcementTrash.push({...row,deletedAt:new Date(now).toISOString(),deletedBy:'SYSTEM',deleteReason:'EXPIRED_RETENTION'});
 const ids=new Set(expired.map(x=>x.id));state.announcements=state.announcements.filter(x=>!ids.has(x.id));state.announcementReads=(state.announcementReads||[]).filter(x=>!ids.has(x.announcementId));return expired;
}
