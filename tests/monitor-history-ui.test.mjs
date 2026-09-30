import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';

const page=readFileSync(new URL('../src/views/PortalPage.vue',import.meta.url),'utf8');
const monitor=readFileSync(new URL('../src/components/portal/MonitorManagement.vue',import.meta.url),'utf8');

test('运行监控加载状态历史并以监控权限显示',()=>{
 assert.match(page,/tasks\.monitorHistory=read\('monitorHistory'\)/);
 assert.match(page,/:history-rows="monitorHistory" :can-check="can\(actor,'monitor:check'\)" @saved="load"/);
 assert.match(monitor,/接入状态变更记录/);
 for(const field of ['occurredAt','appName','kind','fromStatus','toStatus','reason'])assert.match(monitor,new RegExp(`colKey:'${field}'`));
});

test('检测结果录入调用受权限约束的状态命令',()=>{
 assert.match(monitor,/v-if="canCheck"[^>]*@click="openObservation\(\)"/);
 assert.match(monitor,/command\('recordMonitorObservation',payload\)/);
 assert.match(monitor,/payload\.status==='ABNORMAL'&&!payload\.reason/);
 assert.match(monitor,/emit\('saved'\)/);
});
