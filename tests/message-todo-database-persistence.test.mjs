import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {messageTodoMirrorSql,loadMessageTodoState} from '../server/message-todo-persistence.mjs';

const now='2026-09-23T04:00:00.000Z';
const todo={id:'MOCK_TODO_X',version:2,createdAt:now,updatedAt:now,receivedAt:now,sourceCreatedAt:now,sourceUpdatedAt:now,
 appId:'MOCK_APP_X',appName:'应用',sourceTodoId:'SRC_X',userId:'MOCK_USER_X',title:'办理任务',summary:'说明',businessType:'服务事项',status:'PENDING',url:'https://example.test/todo'};
const message={id:'MOCK_MSG_X',version:2,createdAt:now,updatedAt:now,receivedAt:now,appId:'MOCK_APP_X',appName:'应用',sourceMessageId:'SRC_MSG_X',
 userId:'MOCK_USER_X',title:'测试消息',content:'消息正文',status:'READ',readAt:now,deleted:true,deletedAt:now};

test('待办和消息写入包含接收时间、状态、阅读和逻辑删除',()=>{
 const sql=messageTodoMirrorSql({todos:[],messages:[]},{todos:[todo],messages:[message]});
 for(const column of ['runtime_id','received_at','source_todo_id','business_type','source_message_id','read_status','read_at','deleted_at'])assert.match(sql,new RegExp(`"${column}"`));
 assert.match(sql,/P4FIX_APP_X/);
 assert.match(sql,/P4FIX_USER_X/);
 assert.match(sql,/P4FIX_RECIPIENT_MSG_X/);
 assert.doesNotMatch(sql,/DELETE FROM/);
});

test('消息移除只删除对应收件人，仍有收件人时保留消息本体',()=>{
 const sql=messageTodoMirrorSql({todos:[],messages:[message]},{todos:[],messages:[]});
 assert.match(sql,/message_recipient.*user_id='P4FIX_USER_X'/);
 assert.match(sql,/NOT EXISTS\(SELECT 1 FROM .*message_recipient/);
});

test('规范表重载保留待办和消息展示字段及删除状态',async()=>{
 const state={apps:[{id:'MOCK_APP_X',name:'应用'}],todos:[{id:'STALE'}],messages:[{id:'STALE'}],custom:'keep'};
 const loaded=await loadMessageTodoState(async()=>JSON.stringify({todos:[{id:'P4FIX_TODO_X',runtime_id:todo.id,version:2,created_at:now,updated_at:now,
  received_at:now,source_created_at:now,source_updated_at:now,application_id:'P4FIX_APP_X',source_todo_id:'P4FIX_SRC_X',target_user_id:'P4FIX_USER_X',
  title:todo.title,summary:todo.summary,business_type:todo.businessType,status:'PENDING',business_url:todo.url}],messages:[{message:{id:'P4FIX_MSG_X',runtime_id:message.id,
  version:2,created_at:now,updated_at:now,received_at:now,application_id:'P4FIX_APP_X',source_kind:'APPLICATION',source_message_id:'P4FIX_SRC_MSG_X',
  message_type:'BUSINESS',title:message.title,content:message.content},recipient:{version:2,created_at:now,updated_at:now,received_at:now,user_id:'P4FIX_USER_X',
  read_status:'READ',read_at:now,deleted_at:now}}]}),state);
 assert.equal(loaded.todos[0].id,todo.id);
 assert.equal(loaded.todos[0].sourceTodoId,todo.sourceTodoId);
 assert.equal(loaded.todos[0].businessType,todo.businessType);
 assert.equal(loaded.messages[0].sourceMessageId,message.sourceMessageId);
 assert.equal(loaded.messages[0].deleted,true);
 assert.equal(loaded.messages[0].readAt,now);
 assert.equal(loaded.custom,'keep');
});

test('007迁移只回填缺失字段并可重跑',()=>{
 const sql=fs.readFileSync('database/migrations/007_message_todo_runtime.sql','utf8');
 assert.equal((sql.match(/ADD COLUMN IF NOT EXISTS/g)||[]).length,6);
 assert.match(sql,/coalesce\(r\.deleted_at/);
 assert.match(sql,/CREATE UNIQUE INDEX IF NOT EXISTS/);
});
