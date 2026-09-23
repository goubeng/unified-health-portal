import assert from 'node:assert/strict';
import {randomUUID} from 'node:crypto';
import {createRepository,dbId,sqlQuery} from '../../server/repository.mjs';

const repository=createRepository();
const token=randomUUID().replaceAll('-','').slice(0,12);
const marker=`DBACC_${token}`;
const id=kind=>`MOCK_${marker}_${kind}`;
const now=()=>new Date().toISOString();
const identifiers={category:id('CAT'),app:id('APP'),request:id('REQ'),grant:id('GRANT'),opening:id('OPEN'),todo:id('TODO'),message:id('MSG'),organization:id('ORG'),dictType:id('DTYPE'),dictItem:id('DITEM'),role:id('ROLE')};
const domains={categories:'category',apps:'app',applicationRequests:'request',applicationGrants:'grant',accountOpeningRequests:'opening',todos:'todo',messages:'message',organizations:'organization',dictTypes:'dictType',dictItems:'dictItem',roles:'role'};
const resources=Object.fromEntries(Object.entries(domains).map(([resource,key])=>[key,resource]));
const find=(state,key)=>state[resources[key]].find(row=>row.id===identifiers[key]);
const stamp=()=>({createdAt:now(),updatedAt:now(),version:1});
const dropTestRows=state=>{
 for(const [resource,key] of Object.entries(domains))state[resource]=(state[resource]||[]).filter(row=>row.id!==identifiers[key]);
 return state;
};

let created=false,cleaned=false;
try{
 const start=await repository.load(),base=structuredClone(start.state),user=base.users.find(row=>row.userType==='CITIZEN'),admin=base.users.find(row=>row.adminAccess||row.kind==='ADMIN'||(row.roleIds||[]).includes('ROLE_SUPER'));
 assert.ok(user&&admin,'需要现有演示用户和管理员');
 const category={id:identifiers.category,...stamp(),code:marker,name:'持久化验收分类',status:'ENABLED',sortOrder:999};
 const app={...structuredClone(base.apps[0]),id:identifiers.app,...stamp(),code:marker,name:'持久化验收应用',category:category.name,categoryId:category.id,
  url:'https://example.invalid/db-acceptance',enabled:true,status:'ENABLED',sortOrder:999};
 const organization={id:identifiers.organization,...stamp(),code:marker,name:'持久化验收组织',type:'PORTAL_UNIT',source:'PORTAL_LOCAL',status:'ENABLED',sortOrder:999,parentId:null,parentName:null,path:'持久化验收组织',remark:''};
 const dictType={id:identifiers.dictType,...stamp(),code:marker,name:'持久化验收字典',status:'ENABLED',sortOrder:999,systemLocked:false};
 const dictItem={id:identifiers.dictItem,...stamp(),typeCode:marker,label:'验收项',value:'VALUE',sortOrder:1,status:'ENABLED',systemLocked:false};
 const role={id:identifiers.role,...stamp(),roleCode:marker,roleName:'持久化验收角色',permissions:[],status:'ENABLED',builtIn:false};
 const common={...stamp(),userId:user.id,userName:user.name,appId:app.id,appName:app.name,reason:'持久化验收',status:'PENDING',submittedAt:now()};
 const request={id:identifiers.request,...common,requestNo:`REQ-${marker}`,contact:'',remark:'',reviewedBy:null,reviewedAt:null,reviewNote:null};
 const opening={id:identifiers.opening,...common,requestNo:`OPEN-${marker}`,contact:'',remark:'',handledBy:null,handledAt:null,handleNote:null};
 const todo={id:identifiers.todo,...stamp(),receivedAt:now(),sourceCreatedAt:now(),sourceUpdatedAt:now(),appId:app.id,appName:app.name,
  userId:user.id,sourceTodoId:marker,title:'持久化验收待办',summary:'验收',businessType:'服务事项',status:'PENDING',url:app.url};
 const message={id:identifiers.message,...stamp(),receivedAt:now(),appId:app.id,appName:app.name,userId:user.id,sourceMessageId:marker,
  title:'持久化验收消息',content:'验收',sourceKind:'APPLICATION',messageType:'BUSINESS',status:'UNREAD',readAt:null,deleted:false,deletedAt:null};
 for(const [resource,row] of Object.entries({categories:category,apps:app,organizations:organization,dictTypes:dictType,dictItems:dictItem,roles:role,
  applicationRequests:request,accountOpeningRequests:opening,todos:todo,messages:message}))base[resource].push(row);
 await repository.commit(start.state,base,start.version,null);created=true;

 const fresh=await createRepository().load();
 for(const key of ['category','app','request','opening','todo','message','organization','dictType','dictItem','role'])assert.ok(find(fresh.state,key),`${key} 新增后未从数据库读回`);
 const edited=structuredClone(fresh.state),editedAt=now();
 Object.assign(find(edited,'app'),{name:'持久化验收应用 已编辑',updatedAt:editedAt,version:2});
 Object.assign(find(edited,'request'),{status:'APPROVED',reviewedBy:admin.id,reviewedAt:editedAt,reviewNote:'通过',updatedAt:editedAt,version:2});
 Object.assign(find(edited,'opening'),{status:'COMPLETED',handledBy:admin.id,handledAt:editedAt,handleNote:'演示完成',updatedAt:editedAt,version:2});
 Object.assign(find(edited,'todo'),{status:'COMPLETED',updatedAt:editedAt,version:2});
 Object.assign(find(edited,'message'),{status:'READ',readAt:editedAt,deleted:true,deletedAt:editedAt,updatedAt:editedAt,version:2});
 edited.applicationGrants.push({id:identifiers.grant,...stamp(),userId:user.id,appId:app.id,status:'ACTIVE',grantedBy:admin.id,grantedAt:editedAt,expiresAt:null});
 await repository.commit(fresh.state,edited,fresh.version,null);
 const verified=await createRepository().load();
 assert.equal(find(verified.state,'app').name,'持久化验收应用 已编辑');
 assert.equal(find(verified.state,'request').status,'APPROVED');
 assert.equal(find(verified.state,'opening').status,'COMPLETED');
 assert.equal(find(verified.state,'todo').status,'COMPLETED');
 assert.equal(find(verified.state,'message').deleted,true);
 assert.equal(find(verified.state,'grant').status,'ACTIVE');
 console.log(JSON.stringify({marker,created:true,edited:true,reloaded:true}));
}finally{
 if(created){
  const current=await repository.load(),next=dropTestRows(structuredClone(current.state));
  await repository.commit(current.state,next,current.version,null);
  await sqlQuery(`BEGIN;
   DELETE FROM "pb3gir75kkooyea"."application" WHERE id='${dbId(identifiers.app)}' AND deleted_at IS NOT NULL;
   DELETE FROM "pb3gir75kkooyea"."application_category" WHERE id='${dbId(identifiers.category)}' AND deleted_at IS NOT NULL;
   COMMIT;`);
  const after=await createRepository().load();
  for(const key of Object.values(domains))assert.equal(find(after.state,key),undefined,`${key} 清理后残留`);
  const raw=await sqlQuery(`SELECT json_build_object(
   'app',(SELECT count(*) FROM "pb3gir75kkooyea"."application" WHERE id='${dbId(identifiers.app)}'),
   'category',(SELECT count(*) FROM "pb3gir75kkooyea"."application_category" WHERE id='${dbId(identifiers.category)}'),
   'todo',(SELECT count(*) FROM "pb3gir75kkooyea"."todo_item" WHERE id='${dbId(identifiers.todo)}'),
   'message',(SELECT count(*) FROM "pb3gir75kkooyea"."message" WHERE id='${dbId(identifiers.message)}'),
   'request',(SELECT count(*) FROM "pb3gir75kkooyea"."application_access_request" WHERE id='${dbId(identifiers.request)}'))`);
  assert.ok(Object.values(JSON.parse(raw)).every(value=>Number(value)===0),'物理表仍有验收记录');
  cleaned=true;
 }
 console.log(JSON.stringify({marker,cleaned}));
}
