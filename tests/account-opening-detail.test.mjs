import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {createMockProvider} from '../src/providers/mock.js';
import {createPortalService} from '../src/services/portal.js';
import {actors} from '../src/mock/seed.js';

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
 assert.match(detail,/\{key:'handleNote',label:'处理说明'/);
});

test('both account-opening detail entries share the specified application and processing layout',()=>{
 assert.match(detail,/props\.kind==='accountOpeningRequests'\|\|props\.kind==='myApplicationRequests'&&props\.record\?\.requestType==='ACCOUNT_OPENING'/);
 assert.match(detail,/v-else-if="isAccountOpeningDetail"/);
 assert.match(detail,/<h3 class="portal-detail-section-title">申请信息<\/h3>/);
 assert.match(detail,/<h3 class="portal-detail-section-title">处理信息<\/h3>/);
 const application=detail.split('const openingApplicationDetails=computed(()=>{')[1]?.split('const openingProcessingDetails=')[0]||'';
 const fields=[...application.matchAll(/\['([^']+)','([^']+)','(is-third|is-half|is-wide)'\]/g)].map(([,key,label,layout])=>[key,label,layout]);
 assert.deepEqual(fields,[
  ['requestNo','申请编号','is-third'],['submittedAt','申请时间','is-third'],['status','状态','is-third'],
  ['userName','申请人','is-half'],['appName','来源应用','is-half'],
  ['userId','统一身份标识','is-half'],['contact','联系方式','is-half'],
  ['reason','申请原因','is-wide'],['remark','备注','is-wide']
 ]);
 assert.match(detail,/<t-tag v-if="item\.key==='status'"[^>]*>\{\{label\(record\.status,'account_opening_status'\)\}\}<\/t-tag>/);
 const processing=detail.split('const openingProcessingDetails=computed(()=>{')[1]?.split('const appDetails=')[0]||'';
 assert.deepEqual([...processing.matchAll(/\{key:'([^']+)',label:'([^']+)'/g)].map(([,key,label])=>[key,label]),[
  ['handledByName','处理人'],['handledAt','处理时间'],['handleNote','处理说明']
 ]);
 assert.match(processing,/handledByName\)\|\|'-'/);
 assert.doesNotMatch(processing,/handledBy\)\|\|/);
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
