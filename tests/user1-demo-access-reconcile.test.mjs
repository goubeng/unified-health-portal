import test from 'node:test';
import assert from 'node:assert/strict';
import {buildReadSql,buildTransactionSql,targetAppIds,archiveTodoIds,archiveMessageIds} from '../database/validation/reconcile-user1-demo-access.mjs';

const runtime=n=>`MOCK_MAP_MOCK_USER_1_${n}`;
const physical=id=>'P4FIX_'+id.replace(/^MOCK_/,'');
const fixturePlan=()=>{
 const old=[2,3,4,5,6,11,12,26,28],bound=[2,3,4,5,6,11,12],exceptions=[26,28];
 return {safe:true,issues:[],physical:{
  runtimeMappings:old.map(n=>({id:runtime(n),hash:'old-hash'})),
  physicalMappings:old.map(n=>({id:physical(runtime(n)),hash:'old-hash'})),
  snapshotMappings:old.map(n=>({id:runtime(n),hash:'old-hash'})),
  scopes:bound.map(n=>({id:`P4FIX_SCOPE_${runtime(n)}`,hash:'old-hash'})),
  exceptions:exceptions.map(n=>({id:`P4FIX_EXCEPTION_${runtime(n)}`,hash:'old-hash'})),
  todos:archiveTodoIds.map(id=>({id:physical(id),hash:'old-hash'})),
  messages:archiveMessageIds.map(id=>({id:physical(id),hash:'old-hash'}))
 }};
};

test('只读预览覆盖 12 个应用及精确 7+7 归档对象',()=>{
 assert.equal(targetAppIds.length,12);
 assert.deepEqual(archiveTodoIds,[1,2,3,4,5,6,7].map(n=>`MOCK_TODO_0_${n}`));
 assert.deepEqual(archiveMessageIds,[1,2,3,4,5,6,7].map(n=>`MOCK_MSG_0_${n}`));
 const sql=buildReadSql();
 assert.match(sql,/mappingAudit/);
 assert.match(sql,/existingArchives/);
 assert.match(sql,/md5\(to_jsonb\(m\)::text\|\|to_jsonb\(r\)::text\)/);
 assert.doesNotMatch(sql,/\bUPDATE\b|\bINSERT\b|\bDELETE\b/);
});

test('事务先校验哈希再归档原始 JSON，仅逻辑归档消息待办',()=>{
 const sql=buildTransactionSql(fixturePlan());
 assert.match(sql,/BEGIN; SET LOCAL lock_timeout='5s'; SELECT pg_advisory_xact_lock/);
 assert.match(sql,/Stale runtime mapping/);
 assert.match(sql,/Stale snapshot mapping/);
 assert.match(sql,/Stale todo_item/);
 assert.match(sql,/Stale message/);
 assert.match(sql,/jsonb_build_object\('todo',to_jsonb\(t\)\)/);
 assert.match(sql,/jsonb_build_object\('message',to_jsonb\(m\),'recipient',to_jsonb\(r\)\)/);
 assert.match(sql,/UPDATE "pb3gir75kkooyea"\."todo_item" SET archived_at=now\(\)/);
 assert.match(sql,/UPDATE "pb3gir75kkooyea"\."message_recipient" SET deleted_at=now\(\)/);
 assert.doesNotMatch(sql,/DELETE FROM "pb3gir75kkooyea"\."todo_item"|DELETE FROM "pb3gir75kkooyea"\."message"|UPDATE "pb3gir75kkooyea"\."message" SET application_id/);
 assert.equal((sql.match(/'USER1_DEMO_RESTORE_todo_/g)||[]).length,7);
 assert.equal((sql.match(/'USER1_DEMO_RESTORE_message_/g)||[]).length,7);
});

test('只允许通过已核对的安全预览生成事务',()=>{
 assert.throws(()=>buildTransactionSql({safe:false,issues:['stale']}),/预览存在阻碍/);
});
