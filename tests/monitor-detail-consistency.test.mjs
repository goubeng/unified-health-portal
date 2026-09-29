import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';

test('运行监控详情直接展示运行状态，未配置也不遮盖列表中的状态',()=>{
 const source=readFileSync(new URL('../src/components/portal/MonitorManagement.vue',import.meta.url),'utf8');
 assert.match(source,/runStatus:runtimeStatus\s*,/);
 assert.match(source,/<template #runStatus="\{row\}">\s*<StatusTag :value="row\.runStatus"\/>/);
 assert.doesNotMatch(source,/runStatus:configStatus==='CONFIGURED'\?runtimeStatus:'-'/);
 assert.match(source,/configStatus,\s*enabled:/);
});
