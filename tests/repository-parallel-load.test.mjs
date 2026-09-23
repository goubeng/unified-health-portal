import test from 'node:test';
import assert from 'node:assert/strict';
import {createSeed} from '../src/mock/seed.js';
import {createRepository} from '../server/repository.mjs';

test('规范域分两波并发读取，依赖域取得最新用户和应用名称',async()=>{
 const state=createSeed(),finished=new Set();let active=0,firstWavePeak=0,secondWavePeak=0;
 const response={
  remaining:[{resource:'users',items:[{id:'MOCK_USER_X',name:'数据库用户',userType:'CITIZEN',status:'ENABLED'}]}],
  application:{categories:[],apps:[{id:'P4FIX_APP_X',runtime_id:'MOCK_APP_X',created_at:'2026-09-23T00:00:00Z',updated_at:'2026-09-23T00:00:00Z',version:1,code:'P4FIX_APP_X',name:'数据库应用',user_type:'BOTH',application_url:'https://example.invalid',status:'ENABLED'}]},
  announcement:{announcements:[],attachments:[],reads:[]},
  message:{todos:[{id:'P4FIX_TODO_X',runtime_id:'MOCK_TODO_X',created_at:'2026-09-23T00:00:00Z',application_id:'P4FIX_APP_X',target_user_id:'P4FIX_USER_X',title:'待办',status:'PENDING'}],messages:[]},
  request:{applicationRequests:[{id:'P4FIX_REQ_X',runtime_id:'MOCK_REQ_X',created_at:'2026-09-23T00:00:00Z',user_id:'P4FIX_USER_X',application_id:'P4FIX_APP_X',request_no:'REQ-X',reason:'演示',status:'PENDING'}],applicationGrants:[],accountOpeningRequests:[]}
 };
 const query=async sql=>{
  if(sql.includes("id='P4RUN_STATE'"))return JSON.stringify({version:23,state});
  const kind=sql.includes('portal_runtime_entity_domain')?'remaining':sql.includes("'categories'")?'application':sql.includes("'announcements'")?'announcement':sql.includes("'todos'")?'message':sql.includes("'applicationRequests'")?'request':null;
  assert(kind,`未预期查询：${sql.slice(0,100)}`);
  if(['message','request'].includes(kind))assert.deepEqual([...finished].sort(),['announcement','application','remaining']);
  active++;
  if(['remaining','application','announcement'].includes(kind))firstWavePeak=Math.max(firstWavePeak,active);
  else secondWavePeak=Math.max(secondWavePeak,active);
  await new Promise(resolve=>setTimeout(resolve,20));
  active--;finished.add(kind);
  return JSON.stringify(response[kind]);
 };
 const loaded=await createRepository(query).load();
 assert.equal(loaded.version,23);
 assert.equal(firstWavePeak,3);
 assert.equal(secondWavePeak,2);
 assert.equal(loaded.state.todos[0].appName,'数据库应用');
 assert.equal(loaded.state.applicationRequests[0].appName,'数据库应用');
 assert.equal(loaded.state.applicationRequests[0].userName,'数据库用户');
 assert.equal(loaded.state.users[0].name,'数据库用户');
 assert.equal(loaded.state.apps[0].name,'数据库应用');
});

test('缺失兼容快照时仍先初始化再按分波读取',async()=>{
 let snapshots=0,inserts=0;
 const query=async sql=>{
  if(sql.includes("id='P4RUN_STATE'"))return ++snapshots===1?'':JSON.stringify({version:1,state:createSeed()});
  if(sql.includes("INSERT INTO \"pb3gir75kkooyea\".\"system_config\"")){inserts++;return '';}
  if(sql.includes('portal_runtime_entity_domain'))return '[]';
  if(sql.includes("'categories'"))return JSON.stringify({categories:[],apps:[]});
  if(sql.includes("'announcements'"))return JSON.stringify({announcements:[],attachments:[],reads:[]});
  if(sql.includes("'todos'"))return JSON.stringify({todos:[],messages:[]});
  if(sql.includes("'applicationRequests'"))return JSON.stringify({applicationRequests:[],applicationGrants:[],accountOpeningRequests:[]});
  throw new Error('未预期 SQL');
 };
 const loaded=await createRepository(query).load();
 assert.equal(snapshots,2);
 assert.equal(inserts,1);
 assert.equal(loaded.version,1);
});
