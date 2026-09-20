# P3 Service 与 Mock 契约 v0.1.0

这是拟实现的内部业务契约及源PUSH消息结构，不是已部署HTTP API。真实URL、鉴权协议及NocoDB版本端点待实施核实。本文件不编造43个系统接口。调用链为View → Service → Provider（Mock/NocoDB/外部适配），NocoDB管理token仅在服务端。

## 通用输入输出

`Context={requestId, actorKind, actorUserId?, authenticatedApplicationId?, identityMappingId?, permissions, dataScope}`全部由受信任后端生成；不允许body冒充用户或来源应用。`Command={expectedVersion, idempotencyKey, ...payload}`，新增不用expectedVersion。分页`Query={page:1,pageSize:10,filters,sort}`，page>=1，管理页pageSize∈10/20/50，应用卡片12；排序白名单并追加id稳定排序。

`Result<T>={ok:true,data:T,requestId}`或`{ok:false,error:{code,message,field?,retryable},requestId}`；列表data为`{items,total,page,pageSize}`。日期用UTC RFC3339；bigint值在JS安全整数范围内输出数字，超范围用字符串并由DTO显式声明。Provider将NocoDB Id/分页包装转换为上述结构，不把物理tableId当业务id返回。空集合正常返回items=[]，网络失败不能伪装为空列表。

通用错误码：UNAUTHENTICATED、FORBIDDEN、NOT_FOUND（含不可见对象）、VALIDATION_ERROR、VERSION_CONFLICT、IDEMPOTENCY_CONFLICT、INVALID_TRANSITION、STALE_EVENT、IDENTITY_UNRESOLVED、UPSTREAM_UNAVAILABLE、CAPABILITY_UNAVAILABLE、RATE_LIMITED、CONFIG_UNSET、PARTIAL_FAILURE。前端提示重试条件，日志以requestId关联。对PUSH鉴权失败不泄露目标用户是否存在。

## 业务Service目录

| Service | 核心方法及输入 | 输出/规则 |
|---|---|---|
| AuthService | start(sourceCode,method)、authenticate(requestId,proof)、confirm、retry、logout | 登录请求DTO/认证结果；成功才建最小身份与Session，proof不持久化；上层无用户返回注册方向 |
| IdentityService | getList(Query)、getDetail(id)、getCurrent() | 只读脱敏索引及权威来源；无createUser/resetPassword |
| ApplicationService | getList(Query)、getMine、getDetail、create、update、setEnabled、enter(id,target?)、分类CRUD | AppDTO含管理/运行/映射三种状态；enter返回受控跳转结果，不承诺子系统授权通过 |
| MappingService | getList、verify(appId,proof)、complete、resolve(mappingId,evidence,expectedVersion)、unbind | 映射DTO；自动匹配不得仅凭姓名/手机号；不存子系统密码 |
| TodoService | getList、getDetail、open(id) | 本人待办DTO，isOverdue=状态PENDING且due_at<now；open不改状态 |
| MessageService | getList、getDetail、markRead(id) | 本人消息+阅读DTO；首次已读时间保留；不默认向源回传 |
| AnnouncementService | getList、getDetail、saveDraft、uploadAttachment、publish、withdraw、expire | 发布范围与有效期双校验；附件上传完成后存NocoDB返回对象 |
| IntegrationService | getConfig、saveSso、savePush、rotateCredential、test | 配置DTO只显示credentialConfigured；凭证轮换结果不写日志；test无协议适配时CAPABILITY_UNAVAILABLE |
| PermissionService | getRoles、saveRole、setRolePermissions、assignRole | 只管理门户；原型前端隐藏不代替后端鉴权；正式授权由管理员审查 |
| SmsService（条件保留） | invoke、getList、reconcile(callId,expectedVersion) | 仅当门户需要参与上层短信等公共服务调用链路时启用；具体请求、结果查询和重试规则服从上层接口契约；不提供费用统计 |
| ConfigService | getList、update(code,value,expectedVersion) | 严格类型/范围校验；留存NULL时不清理 |
| DictionaryService | get(type)、save(type,items,expectedVersion?,idempotencyKey) | 通用业务字典复用system_config的dictionary.<type>；仅授权管理员维护；生命周期枚举不可编辑 |
| MonitorService/PortalService | getOverview、getAlerts | 同一数据库快照口径；无成功观察不能标NORMAL |
| AuditService | getList(kind,Query)、getDetail、resolveError | 只读脱敏日志；resolveError只改运维标记不修改业务状态 |

update禁止透传任意字段。状态迁移、关联对象归属、actor、version均由专用动作检查。删除仅开放无引用分类等明确允许对象，不能通过通用remove绕过业务历史。

## PUSH TODO 契约

`TodoPush={eventId,sourceSystemCode,sourceTodoId,targetUserKey:{kind:"UNIFIED_USER_ID"|"EXTERNAL_USER_ID",value},sourceRevision,title,businessType?,summary?,status,priority?,createdTime,updatedTime,dueTime?,businessUrl}`。

必填字段不能为空；sourceRevision为正整数；时间必须带时区；priority省略时MEDIUM；源应用必须与鉴权身份一致。EXTERNAL_USER_ID仅在本应用BOUND映射中解析，无法唯一解析返回IDENTITY_UNRESOLVED，不自动建用户。UNIFIED_USER_ID也必须存在且满足该应用已批准的收件身份规则。

字段映射：sourceSystemCode查application.code得到application_id；sourceTodoId→source_todo_id；targetUserKey解析为target_user_id；sourceRevision→source_revision；createdTime/updatedTime→source_created_at/source_updated_at；dueTime→due_at；businessUrl→business_url。其余标题、摘要、业务类型、优先级、状态对应同名snake_case字段。

执行顺序：鉴权→来源/URL/字段校验→事务锁定事件唯一键(application,TODO,eventId)→比较payload_hash→锁定业务键(application,sourceTodoId)→版本及迁移校验→更新业务+审计+APPLIED回执→提交后返回。eventId同载荷重放返回既有结果；同key异载荷报IDEMPOTENCY_CONFLICT。sourceRevision小于当前值报STALE_EVENT，等于当前且语义相同为幂等成功，等值异载荷拒绝；大于当前必须合法迁移，target_user_id不允许静默换人。

初始仅PENDING；源方补发初始记录后才能提交终态。PENDING仅转COMPLETED/WITHDRAWN/EXPIRED；终态不回退或跨终态。截止时间只能产生逾期提示；只有子系统PUSH可确认EXPIRED。点击去处理不提交业务状态更新。

结果data=`{entityId,version,disposition:"APPLIED"|"DUPLICATE",sourceRevision}`。业务失败不写成功回执，接收失败可独立记录REJECTED及安全错误码；数据库不可用返回可重试失败。多条推送逐条独立返回，不声称整个批次原子成功。

## PUSH MESSAGE 契约

`MessagePush={eventId,sourceSystemCode,sourceMessageId,targetUserKeys:[{kind,value}],messageType,title,content,businessUrl?,createdTime}`。核心支持至少1个收件人；全部收件人解析成功才事务提交本体+收件人+回执，禁止部分落库却返回全成功。

application_id来自鉴权，source_kind=APPLICATION，source_key=application_id；source_message_id为来源唯一ID。相同源ID仅接受语义相同的重放，正文/收件人变化需新源ID，避免把新内容标为旧已读。message_recipient唯一(message_id,user_id)，重放不重置READ。外部read_status不控制门户已读。门户消息使用source_kind=PORTAL、source_key=PORTAL和稳定本地事件ID。

messageType映射BUSINESS/SYSTEM/ACCOUNT/SECURITY/TODO_REMINDER/OTHER；未配置未知类型拒绝并提示映射，不能静默混淆。仅接受安全正文/允许的URL，禁止任意重定向。未确定已读回传协议前不实现回传。

## 上层公共服务（条件）与公告关键契约

### 上层短信等公共服务调用（条件契约）

仅在最终确认“业务子系统必须经门户调用上层短信等公共服务”时启用。当前P3不把短信渠道、模板审批、费用核算、门户自有发送队列作为最低必建能力。

建议抽象请求：
`ExternalServiceRequest={requestKey,serviceCode,target?,payload}`。

基本规则：
- 调用方身份由后端可信上下文确定，不允许body冒充来源应用。
- `requestKey`用于幂等；同key同载荷可返回既有结果，同key异载荷拒绝覆盖。
- 服务地址、鉴权、结果查询、回执、重试规则均以正式上层接口契约为准。
- 若上层允许子系统直接调用，门户不参与该链路。
- 门户参与时仅保存最小必要接入配置、调用结果、错误摘要和审计关联ID。
- `SUCCESS`只表示上层服务确认成功；`UNKNOWN`不得自行视为失败并盲目重试。
- 是否支持查询/核实、是否允许重试以及重试次数全部由上层契约决定。
- 不定义短信费用统计，不把未知费用当0，也不在门户建设独立计费模型。
- 手机号、Secret、Token及业务变量等敏感信息不得明文进入普通日志。

`SmsService（条件保留）`仅作为上述外部服务适配的一种实现形态，不是当前固定门户能力。

公告saveDraft仅允许DRAFT；publish要求title/content、范围、有效期和附件完整。指定组织需(identity_source_code,org_key)。读取实时校验PUBLISHED且start<=now<end，即使定时过期尚未更新也不能泄露失效内容；附件下载复用同一公告可见性检查。Attachment仅接受上传完成的NocoDB附件对象数组，拒绝浏览器File、{}及任意外链冒充附件。

## Mock Schema 与替换

通用业务字典是P3实现设计，复用`system_config`，不新增表/字段/seed。键为`dictionary.<type>`，`unit="json"`，`value={items:[{code,label,enabled,sortOrder}]}`，成功保存置CONFIGURED。type使用后端允许的业务字典类型白名单（本轮包括`announcement_type`），不能把任意配置键当字典；所有生命周期、权限、认证与状态枚举（包括nocodb-schema.json.enums）均排除，禁止用户编辑。公告类型存储code、显示label。

`DictionaryService.get(type)`按code读取并输出DictionaryDTO（含ConfigDTO映射）；无记录返回`configured=false,config=null,items=[]`，未配置记录返回`configured=false,config=<记录>,items=[]`，合法已配置记录返回`configured=true,config=<记录>,items=value.items`，读取失败不能伪装为空字典。items按sortOrder、code稳定排序；读取保留停用项用于历史显示，新增/改选仅可使用enabled=true的项，既有停用项未改动可保留。选项不存在或字典未配置时拒绝依赖该字典的新值，不静默写入未知code。

`save`仅允许后端字典维护权限，全量校验items为数组，code与label为非空字符串、code去首尾空白后在该type内唯一，enabled为布尔值、sortOrder为JS安全范围内整数；禁止额外字段和秘密数据。已存在记录必传expectedVersion，按版本更新value/status并递增version；不存在记录不传expectedVersion，由服务端生成业务id，依赖code唯一约束处理并发创建，幂等键冲突不覆盖已有配置。已有项code不可改名或删除，仅可改label/enabled/sortOrder及新增项，停用代替删除以保留历史标签；保存与DICT_CHANGED审计同事务。ConfigService.update对dictionary.*必须走同一校验与权限路径，不能绕过DictionaryService；未授权类型返回VALIDATION_ERROR。DTO中type由code去掉dictionary.前缀，config映射system_config，items映射value.items；不增加独立字典数据集。

Mock Provider复用[nocodb-schema.json](nocodb-schema.json)的存储枚举和[mock-schema.json](mock-schema.json)的完整输出DTO、Result及分页定义。后者为JSON Schema 2020-12设计文件，x-serviceOutputs声明各方法的结果Schema，x-storage/x-derived声明字段映射与派生规则；所有响应字段显式列出，存储可空字段输出null，不随意省略。DTO使用camelCase，存储使用snake_case；不将存储记录整体透传给页面。配置/凭证/加密引用与Token摘要不进入DTO，认证会话凭证通过服务端安全Cookie传递。JSON可变配置仅限授权管理接口，按Service白名单脱敏；不得从JSON扩展字段绕过秘密过滤。场景数据拟置src/mock/portal（本任务未创建源码），不得作为正式seed导入。至少覆盖：上层无用户/冲突/登录失败；应用启停与映射分离；映射验证成功/失败/冲突；重复与乱序PUSH；本人隔离；待办点击不改状态和过期提示；多收件人独立已读；公告草稿/发布/撤回/定时过期；若启用上层公共服务适配，则覆盖成功/失败/未知结果及幂等处理。

Mock记录标识明确以MOCK_开头，应用不拼造真实43名单。Mock与NocoDB Provider共用契约用例，切换发生于依赖注入，页面不改字段与状态语义。P4运行Demo与P5闭环通过后再形成真实执行证据。


### 当前公共服务边界补充

- 短信等能力优先复用上层公共服务平台。
- `SmsService` 不再作为当前最低必建核心服务，仅作为“门户需要参与转接时”的条件契约保留。
- 不建设短信费用统计接口。
- 若子系统能够直接调用上层短信服务，门户不参与调用链路。
- 二维码/验证码生成、有效期和发送规则由上层身份平台负责；门户认证服务仅发起请求、处理回调和会话。
