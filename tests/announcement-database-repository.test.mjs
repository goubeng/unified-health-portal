import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {createSeed} from '../src/mock/seed.js';
import {
  announcementMirrorSql,
  createRepository,
  loadAnnouncementState
} from '../server/repository.mjs';

test('005迁移幂等补入legacy announcementTrash且不覆盖现有公告',()=>{
  const sql=fs.readFileSync('database/migrations/005_announcement_runtime_crud.sql','utf8');
  const legacyBlock=sql.split('P4RUN_STATE.announcementTrash')[1]?.split('ALTER TABLE "pb3gir75kkooyea"."announcement_attachment"')[0]||'';
  assert.match(legacyBlock,/->'announcementTrash'/);
  assert.match(legacyBlock,/INSERT INTO "pb3gir75kkooyea"\."announcement"/);
  assert.match(legacyBlock,/"publish_mode"/);
  assert.match(legacyBlock,/"submitted_at"/);
  assert.match(legacyBlock,/"withdrawn_at"/);
  assert.match(legacyBlock,/"last_edited_at"/);
  assert.match(legacyBlock,/"deleted_at"/);
  assert.match(legacyBlock,/LEFT JOIN "pb3gir75kkooyea"\."unified_user"/);
  assert.match(legacyBlock,/WHERE NOT EXISTS/);
  assert.match(legacyBlock,/ON CONFLICT DO NOTHING/);
  assert.doesNotMatch(legacyBlock,/DO UPDATE/,'历史归档导入不得覆盖数据库已有版本');
  assert.match(sql,/->'announcements'.*->'announcementTrash'/s,'附件导入应同时覆盖活动公告与历史归档');
});

const activeAnnouncement={
  id:'MOCK_ANN_DB_ACTIVE',version:4,
  createdAt:'2026-09-20T01:00:00.000Z',updatedAt:'2026-09-22T02:00:00.000Z',
  title:"数据库公告 'A'",type:'工作安排',content:'<p>完整正文</p>',scope:'ORG',status:'DRAFT',
  effectiveStart:'2026-09-24T00:00:00.000Z',effectiveEnd:'2026-10-24T00:00:00.000Z',
  publishMode:'SCHEDULED',scheduledPublishAt:'2026-09-24T01:30:00.000Z',publishedAt:null,
  submittedAt:'2026-09-22T02:00:00.000Z',submittedBy:'MOCK_EDITOR',publisherId:null,
  withdrawnAt:null,withdrawnBy:null,withdrawReason:'',lastEditedAt:'2026-09-22T02:00:00.000Z',lastEditedBy:'MOCK_EDITOR',
  attachments:[{
    id:'MOCK_FILE_DB_1',name:'演示附件.pdf',size:2048,type:'application/pdf',
    uploadedAt:'2026-09-22T02:00:00.000Z',uploadedBy:'MOCK_EDITOR',data:'data:application/pdf;base64,VEVTVA=='
  }]
};

const archivedAnnouncement={
  ...activeAnnouncement,id:'MOCK_ANN_DB_ARCHIVED',title:'已归档公告',attachments:[],status:'WITHDRAWN',
  deletedAt:'2026-09-23T03:00:00.000Z',deletedBy:'MOCK_ADMIN',deleteReason:'WITHDRAWN_DELETE'
};

test('公告数据库映射包含完整业务字段、附件、已读与软删除归档',()=>{
  const before={announcements:[],announcementTrash:[],announcementReads:[]};
  const after={
    announcements:[activeAnnouncement],announcementTrash:[archivedAnnouncement],
    announcementReads:[{announcementId:activeAnnouncement.id,userId:'MOCK_USER_1',readAt:'2026-09-23T04:00:00.000Z'}]
  };
  const sql=announcementMirrorSql(before,after);

  for(const column of [
    'runtime_id','announcement_type','effective_start','effective_end','publish_mode','scheduled_publish_at',
    'submitted_at','submitted_by','publisher_id','published_at','withdrawn_at','withdrawn_by','withdrawn_reason',
    'last_edited_at','last_edited_by','deleted_at','deleted_by','delete_reason'
  ])assert.match(sql,new RegExp(`"${column}"`),`缺少公告字段 ${column}`);
  assert.match(sql,/数据库公告 ''A''/,'文本应按 SQL 字面量转义');
  assert.match(sql,/"pb3gir75kkooyea"\."announcement_attachment"/);
  for(const value of ['演示附件.pdf','application/pdf','data:application/pdf;base64,VEVTVA=='])assert.match(sql,new RegExp(value.replace(/[.*+?^${}()|[\]\\]/g,'\\$&')));
  assert.match(sql,/"pb3gir75kkooyea"\."announcement_read_receipt"/);
  assert.match(sql,/P4FIX_USER_1/);
  assert.match(sql,/P4FIX_ANN_DB_ARCHIVED/);
  assert.match(sql,/2026-09-23T03:00:00\.000Z/);
  assert.match(sql,/P4FIX_ADMIN/);
  assert.match(sql,/WITHDRAWN_DELETE/);
  assert.doesNotMatch(sql,/DELETE FROM "pb3gir75kkooyea"\."announcement"/,'归档不得物理删除公告');
});

test('公告规范表重载恢复活动公告、附件、已读和归档，同时保留其他 state',async()=>{
  const original=createSeed();
  const unrelated={
    apps:structuredClone(original.apps),todos:structuredClone(original.todos),messages:structuredClone(original.messages),
    organizations:structuredClone(original.organizations),customMarker:{keep:'不可覆盖'}
  };
  const state={...original,...unrelated,announcements:[{id:'STALE'}],announcementTrash:[{id:'STALE_TRASH'}],announcementReads:[{announcementId:'STALE'}]};
  const databasePayload={
    announcements:[
      {
        id:'P4FIX_ANN_DB_ACTIVE',runtime_id:'MOCK_ANN_DB_ACTIVE',created_at:activeAnnouncement.createdAt,updated_at:activeAnnouncement.updatedAt,version:4,
        title:activeAnnouncement.title,announcement_type:activeAnnouncement.type,content:activeAnnouncement.content,scope:activeAnnouncement.scope,status:activeAnnouncement.status,
        effective_start:activeAnnouncement.effectiveStart,effective_end:activeAnnouncement.effectiveEnd,publish_mode:activeAnnouncement.publishMode,
        scheduled_publish_at:activeAnnouncement.scheduledPublishAt,submitted_at:activeAnnouncement.submittedAt,submitted_by:'P4FIX_EDITOR',
        publisher_id:null,published_at:null,withdrawn_at:null,withdrawn_by:null,withdrawn_reason:null,last_edited_at:activeAnnouncement.lastEditedAt,last_edited_by:'P4FIX_EDITOR',
        deleted_at:null,deleted_by:null,delete_reason:null
      },
      {
        id:'P4FIX_ANN_DB_ARCHIVED',runtime_id:'MOCK_ANN_DB_ARCHIVED',created_at:activeAnnouncement.createdAt,updated_at:archivedAnnouncement.updatedAt,version:5,
        title:archivedAnnouncement.title,announcement_type:'通知',content:'归档正文',scope:'ALL',status:'WITHDRAWN',
        deleted_at:archivedAnnouncement.deletedAt,deleted_by:'P4FIX_ADMIN',delete_reason:archivedAnnouncement.deleteReason
      }
    ],
    attachments:[{
      id:'P4FIX_FILE_DB_1',runtime_id:'MOCK_FILE_DB_1',announcement_id:'P4FIX_ANN_DB_ACTIVE',file_name:'演示附件.pdf',size_bytes:'2048',mime_type:'application/pdf',
      created_at:activeAnnouncement.attachments[0].uploadedAt,attachment:JSON.stringify({data:activeAnnouncement.attachments[0].data,uploadedAt:activeAnnouncement.attachments[0].uploadedAt})
    }],
    reads:[{announcement_id:'P4FIX_ANN_DB_ACTIVE',user_id:'P4FIX_USER_1',read_at:'2026-09-23T04:00:00.000Z'}]
  };
  let queryCount=0;
  const loaded=await loadAnnouncementState(async sql=>{
    queryCount++;
    assert.match(sql,/announcement_read_receipt/);
    return JSON.stringify(databasePayload);
  },state);

  assert.equal(queryCount,1);
  assert.equal(loaded.announcements.length,1);
  assert.equal(loaded.announcements[0].id,'MOCK_ANN_DB_ACTIVE');
  assert.equal(loaded.announcements[0].publishMode,'SCHEDULED');
  assert.deepEqual(loaded.announcements[0].attachments,[{
    data:activeAnnouncement.attachments[0].data,uploadedAt:activeAnnouncement.attachments[0].uploadedAt,
    id:'MOCK_FILE_DB_1',name:'演示附件.pdf',size:2048,type:'application/pdf'
  }]);
  assert.deepEqual(loaded.announcementReads,[{announcementId:'MOCK_ANN_DB_ACTIVE',userId:'MOCK_USER_1',readAt:'2026-09-23T04:00:00.000Z'}]);
  assert.equal(loaded.announcementTrash.length,1);
  assert.deepEqual(
    {id:loaded.announcementTrash[0].id,deletedAt:loaded.announcementTrash[0].deletedAt,deletedBy:loaded.announcementTrash[0].deletedBy,deleteReason:loaded.announcementTrash[0].deleteReason},
    {id:'MOCK_ANN_DB_ARCHIVED',deletedAt:archivedAnnouncement.deletedAt,deletedBy:'MOCK_ADMIN',deleteReason:'WITHDRAWN_DELETE'}
  );
  for(const key of ['apps','todos','messages','organizations','customMarker'])assert.deepEqual(loaded[key],unrelated[key],`${key} 不应被公告重载覆盖`);
  assert.notStrictEqual(loaded,state);
});

test('DATABASE Repository 每次 load 都以公告规范表恢复且不污染持久化 state',async()=>{
  const storedState=createSeed();
  storedState.customMarker={keep:'repository-state'};
  const databasePayload={announcements:[{
    id:'P4FIX_ANN_RELOAD',runtime_id:'MOCK_ANN_RELOAD',created_at:'2026-09-20T00:00:00.000Z',updated_at:'2026-09-23T00:00:00.000Z',version:2,
    title:'重载公告',announcement_type:'通知',content:'数据库内容',scope:'ALL',status:'PUBLISHED',publish_mode:'IMMEDIATE',published_at:'2026-09-23T00:00:00.000Z'
  }],attachments:[],reads:[]};
  const sqlCalls=[];
  const repository=createRepository(async sql=>{
    sqlCalls.push(sql);
    if(sql.includes("id='P4RUN_STATE'"))return JSON.stringify({version:9,state:storedState});
    if(sql.includes('portal_runtime_entity_domain'))return '[]';
    if(sql.includes("'categories'"))return JSON.stringify({categories:[],apps:[]});
    if(sql.includes("'todos'"))return JSON.stringify({todos:[],messages:[]});
    if(sql.includes("'applicationRequests'"))return JSON.stringify({applicationRequests:[],applicationGrants:[],accountOpeningRequests:[]});
    if(sql.includes("'announcements'"))return JSON.stringify(databasePayload);
    throw new Error('测试未预期的 SQL');
  });

  const first=await repository.load();
  first.state.announcements[0].title='仅修改返回副本';
  first.state.apps.length=0;
  const second=await repository.load();

  assert.equal(first.version,9);
  assert.equal(second.state.announcements[0].title,'重载公告');
  assert.equal(second.state.apps.length,0);
  assert.ok(storedState.apps.length>0);
  assert.deepEqual(second.state.customMarker,{keep:'repository-state'});
  assert.equal(sqlCalls.filter(sql=>sql.includes("id='P4RUN_STATE'")).length,2);
  assert.equal(sqlCalls.filter(sql=>sql.includes("'announcements'")).length,2);
});
