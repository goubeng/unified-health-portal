import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {createMockProvider} from '../src/providers/mock.js';
import {createPortalService} from '../src/services/portal.js';
import {actors} from '../src/mock/seed.js';
import {requestDetailSections,requestDetailActions} from '../src/components/portal/request-detail.js';

const detail=fs.readFileSync('src/components/portal/RecordDetail.vue','utf8');
const portalPage=fs.readFileSync('src/views/PortalPage.vue','utf8');
const myApplications=fs.readFileSync('src/components/portal/MyApplications.vue','utf8');

test('account-opening list omits processing note while detail retains it',()=>{
 const fields=portalPage.match(/accountOpeningRequests:\[([^\]]+)\]/)?.[1]||'';
 assert.match(fields,/'submittedAt'/);
 assert.doesNotMatch(fields,/'handleNote'/);
 const publicOpeningColumns=myApplications.split('const openingColumns=[')[1]?.split('];')[0]||'';
 assert.doesNotMatch(publicOpeningColumns,/colKey:'handleNote'/);
 assert.match(myApplications,/colKey:'reviewNote',title:'审核意见'/);
 assert.match(detail,/requestDetailSections\(\{/);
});

test('PC and mobile application request details share the required ordered sections',()=>{
 const expectedApplication=[
  ['requestNo','申请编号'],['submittedAt','申请时间'],['status','申请状态'],
  ['userName','申请人'],['contact','联系方式'],['userId','统一身份标识'],
  ['appName','应用名称'],['postGrantMode','申请通过后'],['requestType','申请类型'],
  ['reason','申请原因'],['remark','备注']
 ];
 const expectedReview=[['reviewer','审核人'],['reviewedAt','审核时间'],['reviewNote','审核意见']];
 for(const requestType of ['APPLICATION_ACCESS','ACCOUNT_OPENING']){
  const source={requestType,status:'PENDING'};
  const sections=requestDetailSections(source);
  assert.deepEqual(sections.application.map(item=>[item.key,item.label]),expectedApplication);
  assert.deepEqual(sections.review.map(item=>[item.key,item.label]),expectedReview);
  assert.equal(sections.application.find(item=>item.key==='userName').value,'-');
  assert.equal(sections.review.find(item=>item.key==='reviewer').value,'-');
 }
 const opening=requestDetailSections({requestType:'ACCOUNT_OPENING',handledByName:'李审核',handledAt:'2026-09-29T08:00:00.000Z',handleNote:'已开通'});
 assert.equal(opening.review[0].value,'李审核');
 assert.equal(opening.review[2].value,'已开通');
 const access=requestDetailSections({requestType:'APPLICATION_ACCESS',reviewedByName:'王审核',reviewNote:'审核通过',postGrantMode:'BIND'});
 assert.equal(access.review[0].value,'王审核');
 assert.equal(access.review[2].value,'审核通过');
 assert.equal(access.application.find(item=>item.key==='postGrantMode').value,'完成账号关联');
 assert.match(detail,/v-else-if="isRequestDetail"/);
 assert.match(detail,/<h3 class="portal-detail-section-title">申请信息<\/h3>/);
 assert.match(detail,/<h3 class="portal-detail-section-title">审核信息<\/h3>/);
 assert.match(detail,/:width="isRequestDetail\?'1180px'/);
 assert.match(detail,/#footer/);
});

test('mobile request detail is a routed page with a return button and shared fields',()=>{
 const mobile=fs.readFileSync('src/mobile/MobileApplications.vue','utf8');
 const routes=fs.readFileSync('src/mobile/routes.ts','utf8');
 const shell=fs.readFileSync('src/mobile/MobileShell.vue','utf8');
 assert.match(routes,/path:'applications\/:id'/);
 assert.match(mobile,/requestDetailSections\(detail.value\)/);
 assert.match(mobile,/requestDetailActions\(detail.value\)/);
 assert.match(mobile,/class="mobile-request-detail-page"/);
 assert.doesNotMatch(mobile,/mobile-requests-center-overlay/);
 assert.match(mobile,/goBack/);
 assert.match(shell,/route.path.startsWith\('\/m\/applications\/'\)/);
 assert.deepEqual(requestDetailActions({status:'PENDING',requestType:'APPLICATION_ACCESS'}).map(item=>item.key),['withdraw']);
 assert.deepEqual(requestDetailActions({status:'COMPLETED',requestType:'ACCOUNT_OPENING'}).map(item=>item.key),['bind']);
 assert.deepEqual(requestDetailActions({status:'APPROVED',requestType:'APPLICATION_ACCESS',postGrantMode:'BIND'}).map(item=>item.key),['bind']);
 assert.deepEqual(requestDetailActions({status:'PENDING'},'applicationRequests').map(item=>item.key),['approve','reject']);
});

test('application access request exposes reviewer name without inventing a missing reviewer',async()=>{
 const provider=createMockProvider();
 let actor=actors[0];
 const service=createPortalService(provider,()=>actor);
 const approved=(await service.read('myApplicationRequests')).data.find(row=>row.id==='MOCK_REQ_CITIZEN_APPROVED');
 assert.equal(approved.reviewedByName,actors[2].name);
 provider.transact(data=>{
  data.applicationRequests.find(row=>row.id==='MOCK_REQ_CITIZEN_APPROVED').reviewedBy='MOCK_UNKNOWN';
 });
 const unknown=(await service.read('myApplicationRequests')).data.find(row=>row.id==='MOCK_REQ_CITIZEN_APPROVED');
 assert.equal(unknown.reviewedByName,'');
});

test('saved handler is resolved by ID for both admin and public details, without inventing a handler',async()=>{
 const provider=createMockProvider();
 let actor=actors[2];
 const service=createPortalService(provider,()=>actor);
 const id='MOCK_OPEN_PENDING';
 let admin=(await service.read('accountOpeningRequests')).data.find(row=>row.id===id);
 assert.equal(admin.handledBy,null);
 assert.equal(admin.handledByName,'');
 actor=actors[0];
 let publicRow=(await service.read('myApplicationRequests')).data.find(row=>row.id===id);
 assert.equal(publicRow.handledByName,'');
 provider.transact(data=>{
  const row=data.accountOpeningRequests.find(item=>item.id===id);
  row.handledBy='MOCK_ADMIN';
  row.handledAt='2026-09-29T08:00:00.000Z';
  row.handleNote='已处理';
  row.submittedAt='2026-09-28T08:00:00.000Z';
  row.createdAt='2026-09-28T07:59:00.000Z';
 });
 actor=actors[2];
 admin=(await service.read('accountOpeningRequests')).data.find(row=>row.id===id);
 actor=actors[0];
 publicRow=(await service.read('myApplicationRequests')).data.find(row=>row.id===id);
 for(const row of [admin,publicRow]){
  assert.equal(row.handledBy,'MOCK_ADMIN');
  assert.equal(row.handledByName,actors[2].name);
  assert.equal(row.handledAt,'2026-09-29T08:00:00.000Z');
  assert.equal(row.submittedAt,'2026-09-28T08:00:00.000Z');
  assert.notEqual(row.createdAt,row.submittedAt);
 }
 provider.transact(data=>{data.accountOpeningRequests.find(item=>item.id===id).handledBy='MOCK_UNKNOWN';});
 actor=actors[2];
 const unknown=(await service.read('accountOpeningRequests')).data.find(row=>row.id===id);
 assert.equal(unknown.handledByName,'');
});
