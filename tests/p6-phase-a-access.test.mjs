import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {createMockProvider} from '../src/providers/mock.js';
import {createPortalService} from '../src/services/portal.js';
import {actors} from '../src/mock/seed.js';
import {createMemoryRepository} from '../server/repository.mjs';

function setup(index=0,prepare=()=>{}){
  let actor=actors[index];
  const provider=createMockProvider();
  provider.transact(data=>{prepare(data);return null;});
  const service=createPortalService(provider,()=>actor);
  return {
    provider,service,
    switchActor:index=>{actor=actors[index];},
    read:async resource=>{const result=await service.read(resource);assert.equal(result.ok,true,JSON.stringify(result));return result.data;},
    run:async(action,payload)=>{const result=await service.command(action,payload);assert.equal(result.ok,true,JSON.stringify(result));return result.data;}
  };
}

test('0.3.0-A标准API明确使用内存模式，数据库入口必须显式api:db',()=>{
  const pkg=JSON.parse(fs.readFileSync('package.json','utf8'));
  const api=fs.readFileSync('server/api.mjs','utf8');
  assert.equal(pkg.scripts.api,'node server/api.mjs');
  assert.equal(pkg.scripts['api:db'],'node server/api.mjs --db');
  assert(api.includes("PORTAL_REPOSITORY:dbRequested?'db':'memory'"));
  const repository=createMemoryRepository();
  assert.equal(repository.mode,'MEMORY_A');
  assert.equal(repository.database,null);
});

test('LOCAL本地管理员不参与普通用户应用、待办、消息和子系统映射',async()=>{
  const h=setup(4);
  assert.equal((await h.read('apps')).length,0);
  assert.equal((await h.read('todos')).length,0);
  assert.equal((await h.read('messages')).length,0);
  const overview=await h.read('identityOverview');
  assert(!overview.some(x=>x.id===actors[4].id));
});

test('REQUEST应用可提交、管理员审核、用户获得门户入口资格后直接进入',async()=>{
  const h=setup(0,data=>{
    data.applicationRequests=(data.applicationRequests||[]).filter(x=>!(x.userId===actors[0].id&&x.appId==='MOCK_APP_13'));
    data.applicationGrants=(data.applicationGrants||[]).filter(x=>!(x.userId===actors[0].id&&x.appId==='MOCK_APP_13'));
  });
  let app=(await h.read('apps')).find(x=>x.id==='MOCK_APP_13');
  assert.equal(app.accessState,'REQUEST_REQUIRED');

  const request=await h.run('submitApplicationRequest',{appId:app.id,reason:'业务办理需要'});
  assert.equal(request.status,'PENDING');
  app=(await h.read('apps')).find(x=>x.id==='MOCK_APP_13');
  assert.equal(app.accessState,'REQUEST_PENDING');

  h.switchActor(2);
  await h.run('approveApplicationRequest',{id:request.id,version:request.version});

  h.switchActor(0);
  app=(await h.read('apps')).find(x=>x.id==='MOCK_APP_13');
  assert.equal(app.accessState,'DIRECT');
  const entered=await h.run('enterApp',{id:app.id});
  assert.equal(entered.mode,'MOCK');
});

test('REQUEST+BIND应用审核通过后仍需绑定，OTP验证后才允许进入',async()=>{
  const h=setup(0,data=>{
    data.applicationRequests=(data.applicationRequests||[]).filter(x=>!(x.userId===actors[0].id&&x.appId==='MOCK_APP_17'));
    data.applicationGrants=(data.applicationGrants||[]).filter(x=>!(x.userId===actors[0].id&&x.appId==='MOCK_APP_17'));
    data.mappings=(data.mappings||[]).filter(x=>!(x.userId===actors[0].id&&x.appId==='MOCK_APP_17'));
  });
  let app=(await h.read('apps')).find(x=>x.id==='MOCK_APP_17');
  assert.equal(app.accessState,'REQUEST_REQUIRED');

  const request=await h.run('submitApplicationRequest',{appId:app.id,reason:'申请协同业务访问'});
  h.switchActor(2);
  await h.run('approveApplicationRequest',{id:request.id,version:request.version});

  h.switchActor(0);
  app=(await h.read('apps')).find(x=>x.id==='MOCK_APP_17');
  assert.equal(app.accessState,'UNBOUND');
  const denied=await h.service.command('enterApp',{id:app.id});
  assert.equal(denied.error?.code,'ACCOUNT_BINDING_REQUIRED');

  const found=await h.run('discoverApplicationAccountCandidates',{appId:app.id});
  assert.equal(found.state,'CANDIDATE_FOUND');
  const account=found.candidates[0].externalAccount;
  const otp=await h.run('sendSubsystemBindingOtp',{appId:app.id,externalAccount:account});
  assert.equal(otp.demoCode,'123456');
  const mapping=await h.run('verifyBindingOtp',{appId:app.id,externalAccount:account,code:'123456'});
  assert.equal(mapping.status,'BOUND');

  app=(await h.read('apps')).find(x=>x.id==='MOCK_APP_17');
  assert.equal(app.accessState,'BOUND');
  assert.equal((await h.run('enterApp',{id:app.id})).mode,'MOCK');
});

test('未找到子系统账号时可提交开通申请，管理员模拟完成后重新发现候选并关联',async()=>{
  const h=setup(0,data=>{
    data.accountOpeningRequests=(data.accountOpeningRequests||[]).filter(x=>!(x.userId===actors[0].id&&x.appId==='MOCK_APP_6'));
    data.mappings=(data.mappings||[]).filter(x=>!(x.userId===actors[0].id&&x.appId==='MOCK_APP_6'&&x.status==='BOUND'));
  });
  const app=(await h.read('apps')).find(x=>x.id==='MOCK_APP_6');
  const before=await h.run('discoverApplicationAccountCandidates',{appId:app.id});
  assert.equal(before.state,'NO_ACCOUNT');

  const opening=await h.run('submitAccountOpeningRequest',{appId:app.id,reason:'需要办理目标系统业务'});
  assert.equal(opening.status,'PENDING');

  h.switchActor(2);
  const completed=await h.run('completeMockAccountOpeningRequest',{id:opening.id,version:opening.version});
  assert.equal(completed.status,'COMPLETED');

  h.switchActor(0);
  const after=await h.run('discoverApplicationAccountCandidates',{appId:app.id});
  assert.equal(after.state,'CANDIDATE_FOUND');
  assert(after.candidates[0].externalAccount.startsWith('opened_'));
});

test('高权限账号验证后进入REVIEWING，管理员审核后转BOUND',async()=>{
  const h=setup(0);
  const app=(await h.read('apps')).find(x=>x.id==='MOCK_APP_5');
  const found=await h.run('discoverApplicationAccountCandidates',{appId:app.id});
  const candidate=found.candidates[0];
  assert.equal(candidate.highPrivilege,true);

  await h.run('sendSubsystemBindingOtp',{appId:app.id,externalAccount:candidate.externalAccount});
  const reviewing=await h.run('verifyBindingOtp',{appId:app.id,externalAccount:candidate.externalAccount,code:'123456'});
  assert.equal(reviewing.status,'REVIEWING');

  h.switchActor(2);
  const approved=await h.run('approveBindingReview',{id:reviewing.id,version:reviewing.version});
  assert.equal(approved.status,'BOUND');
});

test('原系统账号验证只接受演示凭据，错误凭据不落成BOUND',async()=>{
  const h=setup(0);
  const app=(await h.read('apps')).find(x=>x.id==='MOCK_APP_4');
  const found=await h.run('discoverApplicationAccountCandidates',{appId:app.id});
  assert(found.candidates[0].verificationMethods.includes('SUBSYSTEM_CREDENTIAL'));

  const failed=await h.service.command('verifyBindingBySubsystemCredential',{appId:app.id,externalAccount:'demo01',password:'wrong'});
  assert.equal(failed.error?.code,'INVALID_CREDENTIALS');
  assert(!h.provider.read().mappings.some(x=>x.userId===actors[0].id&&x.appId===app.id&&x.status==='BOUND'));

  const bound=await h.run('verifyBindingBySubsystemCredential',{appId:app.id,externalAccount:'demo01',password:'123456'});
  assert.equal(bound.status,'BOUND');
});