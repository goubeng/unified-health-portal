import test from 'node:test';
import assert from 'node:assert/strict';
import {applicationMirrorSql,loadApplicationState} from '../server/application-persistence.mjs';

const category={id:'MOCK_CAT_1',createdAt:'2026-09-18T00:00:00Z',updatedAt:'2026-09-19T00:00:00Z',version:2,code:'PUBLIC',name:'公众服务',sortOrder:1,status:'ENABLED'};
const app={id:'MOCK_APP_1',createdAt:'2026-09-18T00:00:00Z',updatedAt:'2026-09-19T00:00:00Z',version:3,
 code:'WJ_APP_01',name:'演示应用',category:category.name,categoryId:category.id,userType:'BOTH',url:'https://p4.invalid/app/1',
 accessMode:'REQUEST',postGrantMode:'BIND',accountBindingMode:'SELF',accountOpeningMode:'REQUEST',mockScenario:'REQUEST_BIND',
 description:'演示',sortOrder:1,enabled:true,status:'ENABLED'};

test('应用和分类新增及编辑写入规范字段与运行扩展字段',()=>{
 const sql=applicationMirrorSql({categories:[],apps:[]},{categories:[category],apps:[app]});
 assert.match(sql,/"application_category"/);
 assert.match(sql,/"application"/);
 assert.match(sql,/"runtime_payload"/);
 assert.match(sql,/"category_id"/);
 assert.match(sql,/P4FIX_CAT_1/);
 assert.match(sql,/REQUEST_BIND/);
 assert.match(sql,/"enabled":true/);
 assert.match(sql,/"status"/);
 assert.match(sql,/"runtime_id"/);
});

test('删除应用和分类保留外键历史且释放编码',()=>{
 const sql=applicationMirrorSql({categories:[category],apps:[app]},{categories:[],apps:[]});
 assert.match(sql,/UPDATE "pb3gir75kkooyea"\."application" SET deleted_at=now\(\)/);
 assert.match(sql,/category_id=NULL/);
 assert.match(sql,/UPDATE "pb3gir75kkooyea"\."application_category" SET deleted_at=now\(\)/);
 assert.match(sql,/ARCHIVED_[0-9a-f]{32}/);
 assert.doesNotMatch(sql,/DELETE FROM/);
});

test('从规范表回读时以列覆盖陈旧快照并恢复页面扩展字段',async()=>{
 const state={categories:[{...category,name:'快照旧分类'}],apps:[{...app,name:'快照旧应用'}],todos:[{id:'KEEP'}]};
 const raw={categories:[{id:'P4FIX_CAT_1',runtime_id:'MOCK_CAT_1',runtime_payload:category,created_at:category.createdAt,updated_at:category.updatedAt,version:'2',
  code:'P4FIX_PUBLIC',name:'数据库分类',sort_order:'1',status:'ENABLED'}],
  apps:[{id:'P4FIX_APP_1',runtime_id:'MOCK_APP_1',runtime_payload:app,created_at:app.createdAt,updated_at:app.updatedAt,version:'4',
   code:'P4FIX_WJ_APP_01',name:'数据库应用',category_id:'P4FIX_CAT_1',user_type:'BOTH',application_url:'https://p4.invalid/app/1',
   description:'数据库说明',sort_order:'2',status:'DISABLED',runtime_status:'UNCONFIGURED',allowed_origins:[],binding_methods:['SELF']}]};
 const loaded=await loadApplicationState(async sql=>{assert.match(sql,/deleted_at IS NULL/);return JSON.stringify(raw);},state);
 assert.equal(loaded.categories[0].name,'数据库分类');
 assert.equal(loaded.apps[0].name,'数据库应用');
 assert.equal(loaded.apps[0].category,'数据库分类');
 assert.equal(loaded.apps[0].enabled,false);
 assert.equal(loaded.apps[0].accessMode,'REQUEST');
 assert.equal(loaded.apps[0].version,4);
 assert.deepEqual(loaded.todos,state.todos);
});
