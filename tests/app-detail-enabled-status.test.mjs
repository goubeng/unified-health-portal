import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

const source=fs.readFileSync('src/components/portal/RecordDetail.vue','utf8');

test('application enabled boolean is mapped to a Chinese status tag',()=>{
 assert.match(source,/row\.enabled===true\?'ENABLED':row\.enabled===false\?'DISABLED':'UNCONFIGURED'/);
 assert.match(source,/\{key:'enabled',label:'启用状态',value:label\(enabledState,'enable_status'\),state:enabledState\}/);
 assert.match(source,/<template v-if="kind==='apps'(\|\|isMonitorException)?" #enabled="\{item\}"><t-tag :theme="theme\(item\.state\)" variant="light">\{\{item\.value\}\}<\/t-tag><\/template>/);
});

test('each connection enabled state uses the same Chinese status label and tag',()=>{
 assert.match(source,/enabledState:\['ENABLED','DISABLED'\]\.includes\(item\.enabled\)\?item\.enabled:'UNCONFIGURED'/);
 assert.match(source,/<t-tag :theme="theme\(item\.enabledState\)" variant="light">\{\{label\(item\.enabledState,'enable_status'\)\}\}<\/t-tag>/);
 assert.doesNotMatch(source,/<span>\{\{item\.enabled\}\}<\/span>/);
});
