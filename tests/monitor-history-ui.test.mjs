import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';

const page=readFileSync(new URL('../src/views/PortalPage.vue',import.meta.url),'utf8');
const monitor=readFileSync(new URL('../src/components/portal/MonitorManagement.vue',import.meta.url),'utf8');
const detail=readFileSync(new URL('../src/components/portal/RecordDetail.vue',import.meta.url),'utf8');
const history=readFileSync(new URL('../src/components/portal/MonitorHistoryTable.vue',import.meta.url),'utf8');
const service=readFileSync(new URL('../src/services/portal.js',import.meta.url),'utf8');

test('状态变更记录只在运行监控详情页签显示，应用列表详情直接展示应用信息',()=>{
 assert.match(page,/tasks\.monitorHistory=read\('monitorHistory'\)/);
 assert.doesNotMatch(page,/:show-status-history=/);
 assert.doesNotMatch(page,/isAdmin&&key==='apps'&&can\(actor\.value,'monitor:view'\)/);
 assert.match(monitor,/<t-tab-panel value="history" label="状态变更记录">/);
 assert.doesNotMatch(detail,/<t-tabs|状态变更记录|MonitorHistoryTable/);
 assert.match(detail,/<div class="portal-generic-detail">/);
 assert.match(detail,/v-if="showConnection&&kind==='apps'"/);
 assert.match(history,/String\(row\.appId\)===String\(props\.appId\)/);
 for(const field of ['occurredAt','kind','fromStatus','toStatus','reason'])assert.match(history,new RegExp(`colKey:'${field}'`));
 assert.doesNotMatch(monitor,/monitor-history-panel/);
});

test('不再开放人工录入检测功能，仍保留运行状态历史数据读取',()=>{
 assert.doesNotMatch(monitor,/录入检测结果|observationVisible|saveObservation/);
 assert.doesNotMatch(page,/:can-check=/);
 assert.doesNotMatch(service,/recordMonitorObservation/);
 assert.match(service,/if\(resource==='monitorHistory'\)/);
});
