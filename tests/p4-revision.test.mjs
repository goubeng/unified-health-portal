import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {createMockProvider} from '../src/providers/mock.js';
import {createPortalService} from '../src/services/portal.js';
import {actors} from '../src/mock/seed.js';
import {rules,archiveExpired} from '../src/config/rules.js';
const setup=()=>{const p=createMockProvider();return {p,s:createPortalService(p,()=>actors[2])};};
test('草稿可删除并归档，已发布公告拒绝删除',async()=>{const {p,s}=setup();const draft=p.read().announcements.find(x=>x.status==='DRAFT');assert((await s.command('removeAnnouncement',draft)).ok);assert(!p.read().announcements.some(x=>x.id===draft.id));assert(p.read().announcementTrash.some(x=>x.id===draft.id));const published=p.read().announcements.find(x=>x.status==='PUBLISHED');assert.equal((await s.command('removeAnnouncement',published)).error.code,'INVALID_TRANSITION');});
test('规则批量保存校验范围且失败原子回滚',async()=>{const {p,s}=setup();const items=rules.map(r=>({...p.read().settings.find(x=>x.code===r.code),value:r.default}));assert((await s.command('saveRules',{items})).ok);const before=p.read();items[0].value=-1;assert(!(await s.command('saveRules',{items})).ok);assert.deepEqual(p.read(),before);});
test('过期公告默认不清理，开启后仅清理已发布且超过保留期公告',()=>{const {p}=setup();const d=p.read(),now=Date.now();d.announcements=[{id:'expired',status:'PUBLISHED',effectiveEnd:new Date(now-3*86400000).toISOString()},{id:'draft',status:'DRAFT',effectiveEnd:new Date(now-3*86400000).toISOString()},{id:'forever',status:'PUBLISHED'}];assert.equal(archiveExpired(d,now).length,0);d.settings.find(x=>x.code===rules[0].code).value=2;assert.equal(archiveExpired(d,now).length,1);assert.deepEqual(d.announcements.map(x=>x.id),['draft','forever']);assert.equal(d.announcementTrash[0].id,'expired');});
test('接入配置无真实子系统仍可保存，凭据不接受明文密钥',async()=>{const {p,s}=setup();const row=p.read().integrations.find(x=>x.kind==='TODO');const input={...row,enabled:'DISABLED',mode:'PUSH',fieldMapping:'{"title":"subject"}',credentialRef:''};assert((await s.command('saveIntegration',input)).ok);const updated=p.read().integrations.find(x=>x.id===row.id);assert.equal(updated.fieldMapping.title,'subject');assert(!(await s.command('saveIntegration',{...updated,credentialRef:'plain-secret'})).ok);});
test('公众15政务41个启用应用，管理端42个完整目录',async()=>{const p=createMockProvider();for(const [index,count] of [[0,15],[1,41]]){const s=createPortalService(p,()=>actors[index]);const result=await s.read('apps');assert.equal(result.data.length,count);assert(result.data.every(x=>x.applicable));}assert.equal((await createPortalService(p,()=>actors[2]).read('adminApps')).data.length,42);});
test('统一登录保留模拟认证元素但不校验即可进入',()=>{
  const source=fs.readFileSync('src/views/Login.vue','utf8');
  const seed=fs.readFileSync('src/mock/seed.js','utf8');
  for(const marker of ["identityType==='CITIZEN'","identityType==='GOV'","identityType==='LOCAL'",'管理账号','<t-qrcode','扫码登录','手机号登录','id="login-phone"','id="login-slider"','id="login-code"','id="local-account"','id="local-password"','id="local-captcha"'])assert(source.includes(marker),marker+' 应保留');
  assert(source.includes("localAccount=ref('admin')"));
  assert(seed.includes("account:'admin'"));
  assert(!source.includes("method.value==='phone'&&!verified.value"));
  const adminFn=source.split('async function enterLocalAdmin(){')[1].split('\n}')[0];
  assert(!/localAccount|localPassword|localCaptchaInput|localCaptchaCode/.test(adminFn));
});


test('登录响应直接建立当前Session',()=>{
  const runtime=fs.readFileSync('src/services/runtime.js','utf8');
  assert(runtime.includes('function applySession(data={})'));
  assert(runtime.includes('applySession(result.data||{})'));
});


test('npm run dev 自动启动前端与数据库 API',()=>{
  const pkg=JSON.parse(fs.readFileSync('package.json','utf8'));
  const dev=fs.readFileSync('server/dev.mjs','utf8');
  assert.equal(pkg.scripts.dev,'node server/dev.mjs');
  assert.equal(pkg.scripts['dev:ui'],'vite --host 0.0.0.0 --port 4010 --strictPort');
  assert(dev.includes("http://127.0.0.1:4011/api/portal/health"));
  assert(dev.includes("node_modules/vite/bin/vite.js"));
  assert(dev.includes("[apiBin,'--db']"));
  assert.equal(pkg.scripts['dev:mock'],'node server/dev.mjs --mock');
});
