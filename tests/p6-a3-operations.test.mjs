import test from 'node:test';
import assert from 'node:assert/strict';
import {createMockProvider} from '../src/providers/mock.js';
import {createPortalService} from '../src/services/portal.js';
import {actors} from '../src/mock/seed.js';

function setup(index=2){
  let actor=actors[index];
  const provider=createMockProvider();
  const service=createPortalService(provider,()=>actor);
  return {
    provider,service,switchActor:i=>{actor=actors[i];},
    read:async resource=>{const result=await service.read(resource);assert.equal(result.ok,true,JSON.stringify(result));return result.data;},
    run:async(action,payload)=>{const result=await service.command(action,payload);assert.equal(result.ok,true,JSON.stringify(result));return result.data;}
  };
}

test('公告草稿支持立即提交与定时发布',async()=>{
  const h=setup();
  const immediate=await h.run('saveAnnouncement',{title:'立即发布测试',content:'正文',scope:'ALL'});
  const published=await h.run('submitAnnouncement',{id:immediate.id,version:immediate.version,publishMode:'IMMEDIATE'});
  assert.equal(published.status,'PUBLISHED');
  assert(published.publishedAt);

  const scheduledDraft=await h.run('saveAnnouncement',{title:'定时发布测试',content:'正文',scope:'GOV'});
  const future=new Date(Date.now()+24*3600*1000).toISOString();
  const scheduled=await h.run('submitAnnouncement',{id:scheduledDraft.id,version:scheduledDraft.version,publishMode:'SCHEDULED',scheduledPublishAt:future});
  assert.equal(scheduled.status,'DRAFT');assert.equal(scheduled.displayStatus,'SCHEDULED');
  assert.equal(scheduled.scheduledPublishAt,future);
});

test('已发布公告可编辑且保持PUBLISHED，已发布不可直接删除',async()=>{
  const h=setup();
  const draft=await h.run('saveAnnouncement',{title:'编辑测试',content:'正文',scope:'ALL'});
  const published=await h.run('submitAnnouncement',{id:draft.id,version:draft.version,publishMode:'IMMEDIATE'});
  const edited=await h.run('saveAnnouncement',{...published,title:'编辑后的标题',content:'修改正文'});
  assert.equal(edited.status,'PUBLISHED');
  assert.equal(edited.title,'编辑后的标题');

  const denied=await h.service.command('removeAnnouncement',{id:edited.id,version:edited.version});
  assert.equal(denied.error?.code,'INVALID_TRANSITION');
});

test('已撤回公告可转草稿并重新立即或定时发布',async()=>{
  const h=setup();
  const draft=await h.run('saveAnnouncement',{title:'撤回重发测试',content:'正文',scope:'ALL'});
  const published=await h.run('submitAnnouncement',{id:draft.id,version:draft.version,publishMode:'IMMEDIATE'});
  const withdrawn=await h.run('withdraw',{id:published.id,version:published.version,reason:'调整内容'});

  const savedDraft=await h.run('saveAnnouncement',{...withdrawn,title:'撤回后转草稿',content:'调整后的正文',targetStatus:'DRAFT'});
  assert.equal(savedDraft.status,'DRAFT');
  const republished=await h.run('submitAnnouncement',{id:savedDraft.id,version:savedDraft.version,publishMode:'IMMEDIATE'});
  assert.equal(republished.status,'PUBLISHED');

  const withdrawnAgain=await h.run('withdraw',{id:republished.id,version:republished.version,reason:'改为定时'});
  const edited=await h.run('saveAnnouncement',{...withdrawnAgain,title:'撤回后定时重发',content:'定时正文'});
  assert.equal(edited.status,'WITHDRAWN');
  const future=new Date(Date.now()+24*3600*1000).toISOString();
  const scheduled=await h.run('submitAnnouncement',{id:edited.id,version:edited.version,publishMode:'SCHEDULED',scheduledPublishAt:future});
  assert.equal(scheduled.status,'DRAFT');assert.equal(scheduled.displayStatus,'SCHEDULED');
  assert.equal(scheduled.scheduledPublishAt,future);
});

test('撤回和失效公告可删除并进入Mock回收档案',async()=>{
  const h=setup();
  const draft=await h.run('saveAnnouncement',{title:'撤回删除测试',content:'正文',scope:'ALL'});
  const published=await h.run('submitAnnouncement',{id:draft.id,version:draft.version,publishMode:'IMMEDIATE'});
  const withdrawn=await h.run('withdraw',{id:published.id,version:published.version,reason:'测试撤回'});
  await h.run('removeAnnouncement',{id:withdrawn.id,version:withdrawn.version});
  assert(!h.provider.read().announcements.some(x=>x.id===withdrawn.id));
  assert(h.provider.read().announcementTrash.some(x=>x.id===withdrawn.id));

  const expired=(await h.read('adminAnnouncements')).find(x=>x.displayStatus==='EXPIRED');
  assert(expired);
  await h.run('removeAnnouncement',{id:expired.id,version:expired.version});
  assert(!h.provider.read().announcements.some(x=>x.id===expired.id));
});

test('登录日志覆盖LOCAL门户本地账号密码登录字段',async()=>{
  const h=setup();
  const rows=await h.read('logs:login');
  const local=rows.find(x=>x.authType==='LOCAL');
  assert(local);
  assert.equal(local.identitySource,'PORTAL_LOCAL');
  assert.equal(local.loginMethod,'PASSWORD');
  assert(local.account);
  assert(local.requestId);
  assert(local.ip);
  assert(local.client);
});

test('异常日志支持OPEN到RESOLVED处理闭环',async()=>{
  const h=setup();
  const rows=await h.read('logs:error');
  const open=rows.find(x=>x.resolutionStatus==='OPEN');
  assert(open);
  const resolved=await h.run('resolveLogError',{id:open.id,version:open.version,resolutionNote:'已完成Mock排查与处理'});
  assert.equal(resolved.resolutionStatus,'RESOLVED');
  assert.equal(resolved.resolutionNote,'已完成Mock排查与处理');
  assert(resolved.resolvedAt);
});

test('运行监控只输出SSO TODO MESSAGE服务状态，不包含冗余综合status',async()=>{
  const h=setup();
  const rows=await h.read('monitor');
  assert(rows.length);
  for(const row of rows.slice(0,5)){
    assert(!Object.hasOwn(row,'status'));
    assert(row.services?.SSO);
    assert(row.services?.TODO);
    assert(row.services?.MESSAGE);
    for(const kind of ['SSO','TODO','MESSAGE']){
      assert(Object.hasOwn(row.services[kind],'status'));
      assert(Object.hasOwn(row.services[kind],'failureCount'));
      assert(Object.hasOwn(row.services[kind],'responseTimeMs'));
    }
  }
});

test('管理首页按服务级口径输出规模待办与三类接入健康统计',async()=>{
  const h=setup();
  const home=await h.read('adminHome');
  assert.equal(typeof home.appCount,'number');
  assert.equal(typeof home.enabledCount,'number');
  assert.equal(typeof home.userCount,'number');
  assert.equal(typeof home.pendingAccessCount,'number');
  assert.equal(typeof home.mappingExceptionCount,'number');
  assert.equal(typeof home.openErrorCount,'number');
  assert(!Object.hasOwn(home,'normalAppCount'));
  assert(!Object.hasOwn(home,'abnormalAppCount'));
  let abnormalTotal=0;
  for(const kind of ['SSO','TODO','MESSAGE']){
    assert(home.serviceHealth?.[kind]);
    assert.equal(typeof home.serviceHealth[kind].normal,'number');
    assert.equal(typeof home.serviceHealth[kind].abnormal,'number');
    assert.equal(typeof home.serviceHealth[kind].unconfigured,'number');
    abnormalTotal+=home.serviceHealth[kind].abnormal;
  }
  assert.equal(home.abnormalServiceCount,abnormalTotal);
});