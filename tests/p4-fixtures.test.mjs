import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {createSeed,actors} from '../src/mock/seed.js';
import {createMockProvider} from '../src/providers/mock.js';
import {createPortalService} from '../src/services/portal.js';

test('应用逐项匹配原始需求42个未划除系统，描述与归组齐全',()=>{
 const source=fs.readFileSync('docs/01-需求/01-原始需求/原始需求.md','utf8');
 const expected=[...source.matchAll(/^\|(\d+)\|([^|]+)\|/gm)].filter(m=>!m[2].includes('~~')).map(m=>({sourceNo:Number(m[1]),name:m[2].trim()}));
 const seed=createSeed();
 assert.equal(expected.length,42);assert.equal(seed.apps.length,42);
 assert.deepEqual(seed.apps.map(({sourceNo,name})=>({sourceNo,name})),expected);
 assert(seed.apps.every(x=>x.description.length>=15));
 assert.equal(new Set(seed.apps.map(x=>x.id)).size,42);
 assert(!seed.apps.some(x=>x.sourceNo===42));
 assert(seed.apps.some(x=>x.sourceNo===43));
});

test('每人多条待办消息、应用关联、公告与日志有足够展示数据且无展示占位词',()=>{
 const d=createSeed();assert.equal(d.schemaVersion,6);assert.equal(d.users.length,5);
 for(const actor of actors.filter(x=>x.userType!=='LOCAL')){assert(d.todos.filter(x=>x.userId===actor.id&&x.status==='PENDING').length>=8);assert(d.messages.filter(x=>x.userId===actor.id&&x.status==='UNREAD').length>=8);assert(d.mappings.filter(x=>x.userId===actor.id&&x.status==='BOUND').length>=5);}
 const local=actors.find(x=>x.userType==='LOCAL');assert(local);assert.equal(d.todos.filter(x=>x.userId===local.id).length,0);assert.equal(d.messages.filter(x=>x.userId===local.id).length,0);assert.equal(d.mappings.filter(x=>x.userId===local.id).length,0);
 assert(d.announcements.length>=8);assert(d.integrations.length>=42);
 for(const kind of ['login','access','operation','api','error'])assert(d.logs.some(x=>x.kind===kind));
 for(const rows of [d.apps,d.users,d.todos,d.messages,d.announcements])for(const row of rows)for(const key of ['name','title','description','content','orgName','roleName'])assert(!/模拟|演示|示例|上层身份/.test(row[key]||''),key);
});

test('公众仅查看适用应用且不能绑定政务限定应用',async()=>{
 const d=createMockProvider();const s=createPortalService(d,()=>actors[0]);
 const apps=(await s.read('apps')).data;assert.equal(apps.length,15);assert(apps.every(x=>x.applicable&&x.status==='ENABLED'));
 const gov=d.read().apps.find(x=>x.userType==='GOV'&&x.status==='ENABLED');assert(!apps.some(x=>x.id===gov.id));
 assert.equal((await s.command('bind',{appId:gov.id,externalAccount:'account'})).error.code,'FORBIDDEN');
});

test('v6缓存与旧版本隔离，持久化失败不提交内存事务',()=>{
 const keys=[];const storage={getItem:k=>{keys.push(k);return null;},setItem:()=>{throw new Error('quota');}};
 const p=createMockProvider(storage),before=p.read();assert.deepEqual(keys,['wj-portal-p4-demo-v6']);
 assert.throws(()=>p.transact(d=>{d.apps=[];return true;}),/quota/);assert.deepEqual(p.read(),before);
});

test('已有账号前后空白不能绕过占用冲突',async()=>{
 let actor=actors[1];const p=createMockProvider(),s=createPortalService(p,()=>actor);
 const app=p.read().apps.find(x=>x.userType==='BOTH'&&x.status==='ENABLED'&&!p.read().mappings.some(m=>m.appId===x.id));
 assert(app);assert((await s.command('bind',{appId:app.id,externalAccount:'shared_account'})).ok);
 actor=actors[0];assert.equal((await s.command('bind',{appId:app.id,externalAccount:' shared_account '})).data.status,'CONFLICT');
});
