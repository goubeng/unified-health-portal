// Values are persisted business codes. Dictionary maintenance may change labels/order,
// but must not extend the executable state machines.
export const businessDictionaryCatalog=[
 {code:'todo_status',name:'待办状态',sortOrder:10,items:[['PENDING','待处理'],['COMPLETED','已处理'],['WITHDRAWN','已撤回'],['EXPIRED','已过期（历史）','DISABLED']]},
 {code:'todo_task_type',name:'待办任务类型',sortOrder:11,systemLocked:false,items:[['服务事项','服务事项'],['材料补正','材料补正'],['审核审批','审核审批'],['结果确认','结果确认']]},
 {code:'message_type',name:'消息类型',sortOrder:12,items:[['SYSTEM','系统消息'],['BUSINESS','业务消息'],['TODO_REMINDER','待办提醒']]},
 {code:'message_read_status',name:'消息阅读状态',sortOrder:13,items:[['UNREAD','未读'],['READ','已读']]},
 {code:'application_request_status',name:'应用申请状态',sortOrder:14,items:[['PENDING','待审核'],['APPROVED','已通过'],['REJECTED','已驳回'],['WITHDRAWN','已撤回']]},
 {code:'account_opening_status',name:'账号开通状态',sortOrder:15,items:[['PENDING','待处理'],['PROCESSING','处理中'],['COMPLETED','已完成']]},
 {code:'mapping_status',name:'账号关联状态',sortOrder:16,items:[['UNBOUND','未关联'],['VERIFYING','验证中'],['REVIEWING','待审核'],['BOUND','已关联'],['FAILED','关联失败'],['CONFLICT','关联冲突']]},
 {code:'announcement_status',name:'公告状态',sortOrder:17,items:[['DRAFT','草稿'],['PUBLISHED','已发布'],['WITHDRAWN','已撤回'],['SCHEDULED','定时发布','DISABLED'],['EXPIRED','已过期（展示）','DISABLED']]},
 {code:'announcement_scope',name:'公告适用范围',sortOrder:18,items:[['ALL','全部用户'],['CITIZEN','公众用户'],['GOV','政务用户']]},
 {code:'publish_mode',name:'公告发布方式',sortOrder:19,items:[['IMMEDIATE','立即发布'],['SCHEDULED','定时发布']]}
];

export function businessDictionarySeed(row){
 return {
  types:businessDictionaryCatalog.map(type=>row('MOCK_DICT_TYPE_'+type.code.toUpperCase(),{code:type.code,name:type.name,description:'门户业务字典；编码由业务规则控制',status:'ENABLED',sortOrder:type.sortOrder,systemLocked:type.systemLocked!==false})),
  items:businessDictionaryCatalog.flatMap(type=>type.items.map(([value,label,status='ENABLED'],index)=>row('MOCK_DICT_'+type.code.toUpperCase()+'_'+index,{typeCode:type.code,label,value,sortOrder:index+1,status,remark:status==='DISABLED'?'历史或派生状态，仅用于展示':'业务字典',systemLocked:type.systemLocked!==false})))
 };
}

// Semantic-key merge: keep administrator edits, including disabled rows and labels.
export function reconcileBusinessDictionaries(state,now=new Date().toISOString()){
 const next=structuredClone(state),seed=businessDictionarySeed((id,values)=>({id,version:1,createdAt:now,updatedAt:now,...values}));
 next.dictTypes??=[];next.dictItems??=[];
 const added={types:[],items:[]};
 for(const type of seed.types)if(!next.dictTypes.some(existing=>existing.code===type.code)){next.dictTypes.push(type);added.types.push(type.code);}
 for(const item of seed.items)if(!next.dictItems.some(existing=>existing.typeCode===item.typeCode&&existing.value===item.value)){next.dictItems.push(item);added.items.push(`${item.typeCode}:${item.value}`);}
 return {state:next,added};
}
