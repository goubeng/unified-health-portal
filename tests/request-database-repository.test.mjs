import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {createSeed} from '../src/mock/seed.js';
import {loadRequestState,requestMirrorSql} from '../server/request-persistence.mjs';

test('008 imports each request aggregate without overwriting newer normalized rows',()=>{
 const sql=fs.readFileSync('database/migrations/008_request_persistence.sql','utf8');
 for(const key of ['applicationRequests','applicationGrants','accountOpeningRequests'])assert.match(sql,new RegExp(`->'${key}'`));
 assert.equal((sql.match(/ON CONFLICT DO NOTHING/g)||[]).length,3);
 assert.match(sql,/uq_access_request_pending/);
 assert.match(sql,/uq_access_grant_active/);
 assert.match(sql,/uq_opening_request_open/);
});

test('request, grant, and opening changes write exact normalized columns',()=>{
 const seed=createSeed();
 const before={applicationRequests:[],applicationGrants:[],accountOpeningRequests:[]};
 const after={applicationRequests:[{...seed.applicationRequests[0],reason:"试用 'A'"}],applicationGrants:[seed.applicationGrants[0]],accountOpeningRequests:[seed.accountOpeningRequests[0]]};
 const sql=requestMirrorSql(before,after);
 for(const table of ['application_access_request','application_access_grant','account_opening_request'])assert.match(sql,new RegExp(`"${table}"`));
 for(const column of ['runtime_id','request_no','reviewed_by','withdrawn_at','expired_at','granted_by','expires_at','handled_by','handle_note'])assert.match(sql,new RegExp(`"${column}"`));
 assert.match(sql,/试用 ''A''/);
 assert.match(sql,/P4FIX_REQ_CITIZEN_EXPIRED/);
 assert.equal(requestMirrorSql(after,structuredClone(after)),'');
});

test('removing an application deletes only its request domain records by id',()=>{
 const seed=createSeed();
 const before={applicationRequests:[seed.applicationRequests[0]],applicationGrants:[seed.applicationGrants[0]],accountOpeningRequests:[seed.accountOpeningRequests[0]]};
 const sql=requestMirrorSql(before,{applicationRequests:[],applicationGrants:[],accountOpeningRequests:[]});
 assert.equal((sql.match(/DELETE FROM/g)||[]).length,3);
 assert.match(sql,/WHERE id='P4FIX_REQ_CITIZEN_EXPIRED'/);
 assert.doesNotMatch(sql,/DELETE FROM "pb3gir75kkooyea"\."application"/);
});

test('normalized reload restores request lifecycle and grant while preserving unrelated state',async()=>{
 const seed=createSeed();
 const physical={applicationRequests:[{id:'P4FIX_REQ_1',runtime_id:'MOCK_REQ_1',created_at:'2026-09-01T00:00:00Z',updated_at:'2026-09-02T00:00:00Z',version:2,request_no:'REQ-1',user_id:'P4FIX_USER_1',application_id:'P4FIX_APP_13',reason:'业务需要',contact:'',remark:'',status:'APPROVED',submitted_at:'2026-09-01T00:00:00Z',reviewed_by:'P4FIX_ADMIN',reviewed_at:'2026-09-02T00:00:00Z',review_note:'通过',withdrawn_at:null,expired_at:null}],applicationGrants:[{id:'P4FIX_GRANT_1',runtime_id:'MOCK_GRANT_1',created_at:'2026-09-02T00:00:00Z',updated_at:'2026-09-02T00:00:00Z',version:1,user_id:'P4FIX_USER_1',application_id:'P4FIX_APP_13',status:'ACTIVE',granted_by:'P4FIX_ADMIN',granted_at:'2026-09-02T00:00:00Z',expires_at:null}],accountOpeningRequests:[]};
 const state=await loadRequestState(async sql=>{assert.match(sql,/application_access_request/);return JSON.stringify(physical);},{...seed,customMarker:'keep'});
 assert.equal(state.applicationRequests[0].id,'MOCK_REQ_1');
 assert.equal(state.applicationRequests[0].reviewedBy,'MOCK_ADMIN');
 assert.equal(state.applicationRequests[0].userName,'林晓');
 assert.equal(state.applicationGrants[0].id,'MOCK_GRANT_1');
 assert.deepEqual(state.accountOpeningRequests,[]);
 assert.equal(state.customMarker,'keep');
});
