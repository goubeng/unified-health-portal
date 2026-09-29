import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createMockProvider} from '../src/providers/mock.js';
import {createPortalService} from '../src/services/portal.js';
import {actors} from '../src/mock/seed.js';

const input={name:'启用状态测试',code:'ENABLED_EDIT_TEST',category:'公众服务',userType:'BOTH',accessMode:'DIRECT',url:'https://example.invalid/app'};

test('应用表单在访问模式后显示中文启用状态并使用布尔值',()=>{
 const source=readFileSync(new URL('../src/views/PortalPage.vue',import.meta.url),'utf8');
 assert.match(source,/f\('accessMode','访问模式'[^\n]*\n\s*f\('enabled','启用状态','text',true,\[\{value:true,label:'启用'\},\{value:false,label:'停用'\}\]\)/);
 assert.match(source,/accessMode:'BIND',enabled:false/);
 assert.match(source,/field\.key==='enabled'&&formAction==='saveApp'&&!can\(actor,'application:enable'\)/);
});

test('应用编辑可保存启停状态，且无启停权限时只能保持原状态',async()=>{
 const provider=createMockProvider();
 const admin=createPortalService(provider,()=>actors[2]);
 provider.transact(data=>{data.users.find(user=>user.id===actors[3].id).permissions=['application:view','application:edit'];});
 const editor=createPortalService(provider,()=>actors[3]);
 const created=await admin.command('saveApp',{...input,enabled:false});
 assert.equal(created.ok,true);
 assert.equal(created.data.enabled,false);
 assert.equal(created.data.status,'DISABLED');
 assert.equal((await editor.command('saveApp',{...input,code:'EDIT_ONLY_ENABLED',enabled:true})).error.code,'FORBIDDEN');
 assert.equal(provider.read().apps.some(app=>app.code==='EDIT_ONLY_ENABLED'),false);
 const sameState=await editor.command('saveApp',{...created.data,name:'仅编辑名称',enabled:false});
 assert.equal(sameState.ok,true);
 assert.equal(sameState.data.name,'仅编辑名称');
 assert.equal((await editor.command('saveApp',{...sameState.data,enabled:true})).error.code,'FORBIDDEN');
 assert.equal(provider.read().apps.find(app=>app.id===created.data.id).enabled,false);
 const enabled=await admin.command('saveApp',{...sameState.data,enabled:true});
 assert.equal(enabled.ok,true);
 assert.equal(enabled.data.enabled,true);
 assert.equal(enabled.data.status,'ENABLED');
 assert.equal((await editor.command('saveApp',{...enabled.data,enabled:false})).error.code,'FORBIDDEN');
 assert.equal((await admin.command('saveApp',{...enabled.data,enabled:'ENABLED'})).error.code,'VALIDATION_ERROR');
 const legacy=await editor.command('saveApp',{...enabled.data,enabled:undefined,name:'旧调用兼容'});
 assert.equal(legacy.ok,true);
 assert.equal(legacy.data.enabled,true);
 assert.equal(legacy.data.status,'ENABLED');
});
