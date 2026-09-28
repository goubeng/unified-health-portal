import test from 'node:test';
import assert from 'node:assert/strict';
import {Readable} from 'node:stream';
import {createPortalApi,redactAuditPayload} from '../server/api.mjs';
import {createMemoryRepository} from '../server/repository.mjs';
import {validateLocalPassword} from '../src/config/password-policy.js';

test('本地密码重置和修改共用复杂度、确认和当前密码输入校验',()=>{
 const valid={newPassword:'StrongA1!demo',confirmPassword:'StrongA1!demo'};
 assert.equal(validateLocalPassword(valid),null);
 assert.match(validateLocalPassword({...valid,newPassword:'weak',confirmPassword:'weak'}),/8–64/);
 assert.match(validateLocalPassword({...valid,confirmPassword:'MismatchB2!'}),/不一致/);
 assert.match(validateLocalPassword({...valid,requireCurrent:true}),/当前密码/);
 assert.equal(validateLocalPassword({...valid,currentPassword:'OldA1!demo',requireCurrent:true}),null);
 assert.match(validateLocalPassword({...valid,currentPassword:valid.newPassword,requireCurrent:true}),/不能与当前密码相同/);
});

test('审计入参递归脱敏且不改变业务原始入参',()=>{
 const raw={id:'MOCK_LOCAL_ADMIN',newPassword:'StrongA1!demo',nested:[{currentPassword:'OldA1!demo',deep:{password:'HiddenC3#demo'}}]};
 const masked=redactAuditPayload(raw);
 assert.equal(masked.id,raw.id);
 assert.equal(masked.newPassword,'[REDACTED]');
 assert.equal(masked.nested[0].currentPassword,'[REDACTED]');
 assert.equal(masked.nested[0].deep.password,'[REDACTED]');
 assert.equal(raw.nested[0].currentPassword,'OldA1!demo');
});

test('模拟 API 重置和自行修改只持久化安全状态，失败请求也不回显或记录明文',async()=>{
 const backing=createMemoryRepository(),events=[];
 const repository={mode:'MEMORY_A',async load(){return backing.load();},async commit(...args){events.push(args[3]);return backing.commit(...args);},async logs(kind){return backing.logs(kind);}};
 const api=createPortalApi({repository});let cookie='';
 const request=async(path,payload)=>{
  const req=Readable.from(payload===undefined?[]:[JSON.stringify(payload)]);
  Object.assign(req,{url:'/api/portal/'+path,method:payload===undefined?'GET':'POST',headers:{host:'localhost:4011',cookie,origin:'http://localhost:4010'}});
  let status,result;const headers={};
  const res={setHeader(key,value){headers[key]=value;},writeHead(value){status=value;this.headersSent=true;},end(value){result=JSON.parse(value);}};
  await api.handle(req,res);
  if(headers['Set-Cookie'])cookie=headers['Set-Cookie'].split(';')[0];
  return {status,result};
 };
 await request('session',{userId:'MOCK_LOCAL_ADMIN'});
 const reset=await request('command',{action:'resetLocalPassword',payload:{id:'MOCK_LOCAL_ADMIN',newPassword:'ResetA1!demo',confirmPassword:'ResetA1!demo'}});
 assert.equal(reset.status,200);
 assert.equal(reset.result.data.credentialStatus,'MOCK_RESET');
 assert.equal(reset.result.data.mustChangePassword,true);
 const mismatch=await request('command',{action:'changeLocalPassword',payload:{id:'MOCK_LOCAL_ADMIN',currentPassword:'OldA1!demo',newPassword:'ChangeB2@demo',confirmPassword:'MismatchC3#demo'}});
 assert.equal(mismatch.status,400);
 assert.equal(mismatch.result.error.code,'VALIDATION_ERROR');
 const changed=await request('command',{action:'changeLocalPassword',payload:{id:'MOCK_LOCAL_ADMIN',currentPassword:'OldA1!demo',newPassword:'ChangeB2@demo',confirmPassword:'ChangeB2@demo'}});
 assert.equal(changed.status,200);
 assert.equal(changed.result.data.credentialStatus,'MOCK_CHANGE_RECORDED');
 assert.equal(changed.result.data.mustChangePassword,false);
 const stored=(await repository.load()).state.users.find(user=>user.id==='MOCK_LOCAL_ADMIN');
 assert(stored.passwordResetAt);
 assert(stored.passwordChangedAt);
 assert.equal(stored.mustChangePassword,false);
 for(const secret of ['ResetA1!demo','OldA1!demo','ChangeB2@demo','MismatchC3#demo']){
  assert(!JSON.stringify(events).includes(secret));
  assert(!JSON.stringify((await repository.load()).state).includes(secret));
  assert(!JSON.stringify([reset.result,mismatch.result,changed.result]).includes(secret));
 }
});
