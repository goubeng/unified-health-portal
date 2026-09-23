import test from 'node:test';
import assert from 'node:assert/strict';
import {loadRemainingState,remainingMirrorSql} from '../server/remaining-persistence.mjs';

test('remaining entities load from rows while leaving dedicated domains intact',async()=>{
 const snapshot={users:[{id:'stale'}],organizations:[{id:'old'}],apps:[{id:'app'}],announcements:[{id:'ann'}]};
 const query=async()=>JSON.stringify([
  {resource:'users',items:[{id:'user',name:'持久化用户'}]},
  {resource:'organizations',items:[{id:'org',name:'持久化组织'}]},
  {resource:'dictItems',items:[]}
 ]);
 const loaded=await loadRemainingState(query,snapshot);
 assert.deepEqual(loaded.users,[{id:'user',name:'持久化用户'}]);
 assert.deepEqual(loaded.organizations,[{id:'org',name:'持久化组织'}]);
 assert.deepEqual(loaded.dictItems,[]);
 assert.deepEqual(loaded.apps,snapshot.apps);
 assert.deepEqual(loaded.announcements,snapshot.announcements);
});

test('remaining entities persist changed rows, order and precise deletions',()=>{
 const before={organizations:[{id:'a',name:'旧'},{id:'b',name:'保留'}]};
 const after={organizations:[{id:'b',name:'保留'},{id:'c',name:"新'组织"}]};
 const sql=remainingMirrorSql(before,after);
 assert.match(sql,/portal_runtime_entity_domain/);
 assert.match(sql,/runtime_id='a'/);
 assert.match(sql,/runtime_id,position,payload/);
 assert.match(sql,/新''组织/);
 assert.doesNotMatch(sql,/DELETE FROM .*runtime_id='b'/);
 assert.equal(remainingMirrorSql(after,structuredClone(after)),'');
});

test('receipt and visit rows use stable keys without generated DTO IDs',()=>{
 const receipt={appId:'app',eventId:'event',payload:'{}',result:{entityId:'todo'}};
 const visit={appId:'app',userId:'user',at:'2026-09-23T00:00:00Z'};
 const first=remainingMirrorSql({receipts:[],visits:[]},{receipts:[receipt],visits:[visit]});
 const second=remainingMirrorSql({receipts:[receipt],visits:[visit]},{receipts:[receipt],visits:[visit]});
 assert.match(first,/portal_runtime_entity/);
 assert.equal(second,'');
});
