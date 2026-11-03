import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {applicationCatalog,platforms} from '../src/mock/catalog.js';
import {createSeed,actors} from '../src/mock/seed.js';
import {createMockProvider} from '../src/providers/mock.js';
import {createPortalService} from '../src/services/portal.js';

test('42 个纳管应用分别归入 7 个整合后子系统，划掉的 42 号不纳入',()=>{
 assert.equal(platforms.length,7);
 assert.equal(applicationCatalog.length,42);
 assert.equal(applicationCatalog.some(app=>app.sourceNo===42),false);
 assert.equal(applicationCatalog.find(app=>app.sourceNo===43)?.platformId,platforms[6].id);
 const counts=platforms.map(platform=>applicationCatalog.filter(app=>app.platformId===platform.id).length);
 assert.deepEqual(counts,[13,4,14,1,1,5,4]);
 const seed=createSeed();
 assert.equal(seed.apps.length,42);
 assert(seed.apps.every(app=>platforms.some(platform=>platform.id===app.platformId&&platform.name===app.platformName)));
});

test('应用归属与系统分类独立，新建必须选择归属，修改可从服务读回',async()=>{
 const service=createPortalService(createMockProvider(),()=>actors[2]);
 const input={name:'归属测试应用',code:'SUBSYSTEM_TEST_APP',category:'公众服务',platformId:platforms[0].id,userType:'BOTH',accessMode:'DIRECT',url:'https://example.invalid/subsystem'};
 const missing=await service.command('saveApp',{...input,platformId:null});
 assert.equal(missing.error?.code,'VALIDATION_ERROR');
 const invalid=await service.command('saveApp',{...input,platformId:'UNKNOWN'});
 assert.equal(invalid.error?.code,'VALIDATION_ERROR');
 const created=await service.command('saveApp',input);
 assert.equal(created.ok,true,JSON.stringify(created));
 assert.equal(created.data.platformName,platforms[0].name);
 assert.equal(created.data.category,input.category);
 const changed=await service.command('saveApp',{...created.data,platformId:platforms[1].id});
 assert.equal(changed.ok,true,JSON.stringify(changed));
 const readback=await service.read('adminApps');
 assert.equal(readback.ok,true,JSON.stringify(readback));
 const row=readback.data.find(app=>app.id===created.data.id);
 assert.equal(row.platformId,platforms[1].id);
 assert.equal(row.platformName,platforms[1].name);
 assert.equal(row.category,input.category);
});

test('物理迁移建立归属目录及外键，历史回填只针对清单中的应用',()=>{
 const sql=readFileSync(new URL('../database/migrations/012_application_subsystem.sql',import.meta.url),'utf8');
 assert.match(sql,/CREATE TABLE IF NOT EXISTS .*application_subsystem/);
 assert.match(sql,/ADD COLUMN IF NOT EXISTS platform_id text/);
 assert.match(sql,/FOREIGN KEY \(platform_id\)/);
 assert.match(sql,/WHERE n <> 42/);
 assert.match(sql,/a\.platform_id IS NULL/);
});
