import fs from 'node:fs';
import path from 'node:path';
import assert from 'node:assert/strict';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');
const read = file => fs.readFileSync(path.join(root, file), 'utf8');
const design = JSON.parse(read('docs/development/nocodb-schema.json'));
const seed = JSON.parse(read('docs/development/nocodb-seed.json'));
const sql = read('database/schema.sql');
assert.equal(sql, read('database/migrations/001_initial.sql'), 'Initial migration drift');
assert.equal(design.baseId, 'pb3gir75kkooyea');
assert.equal(design.externalDataSource, false);
assert(!/\bPRAGMA\b|\bATTACH\s+DATABASE\b/i.test(sql), 'Wrong SQL dialect');
const names = design.tables.map(t => t.name);
assert.equal(new Set(names).size, names.length, 'Duplicate table');
const sqlNames = [...sql.matchAll(/CREATE TABLE "([^"]+)"/g)].map(m => m[1]);
assert.deepEqual(sqlNames, names, 'SQL tables differ');
for (const table of design.tables) {
  const start = sql.indexOf(`CREATE TABLE "${table.name}" (`);
  const end = sql.indexOf('\n);', start);
  const block = sql.slice(start, end);
  const fields = table.fields.map(f => f.name);
  assert.equal(new Set(fields).size, fields.length, `${table.name}: duplicate field`);
  for (const field of table.fields) {
    const line = block.split('\n').find(l => l.trimStart().startsWith(`"${field.name}" `));
    assert(line, `${table.name}.${field.name}: absent in SQL`);
    assert(line.includes(field.sqlType), `${table.name}.${field.name}: SQL type`);
    assert(!field.required || line.includes('NOT NULL'), `${table.name}.${field.name}: nullable`);
    if (field.enum) assert(design.enums[field.enum], `Unknown enum ${field.enum}`);
    for (const value of (field.enum ? design.enums[field.enum] : field.values || [])) {
      assert(line.includes(`'${value}'`), `${table.name}.${field.name}: SQL enum ${value}`);
    }
  }
  for (const key of [...table.unique, ...table.indexes]) {
    for (const field of key) assert(fields.includes(field), `${table.name}: unknown key ${field}`);
  }
}
const seedSql = read('database/seed.sql');
assert.equal((seedSql.match(/INSERT INTO system_config/g) || []).length, seed.records.system_config.length);
for (const record of seed.records.system_config) {
  assert.equal(record.status, 'UNCONFIGURED');
  assert.equal(record.value, null);
  assert(seedSql.includes(`'${record.code}'`), `Missing SQL seed ${record.code}`);
}
const pageList = [...read('docs/product/页面清单.md').matchAll(/^\| (PG-\d+)/gm)].map(m => m[1]).sort();
const pageSpecs = [...read('docs/product/页面规格.md').matchAll(/^## (PG-\d+)/gm)].map(m => m[1]).sort();
assert.deepEqual(pageList, pageSpecs, 'Page specification coverage');
const readback = JSON.parse(read('doc/nocodb-readback.json'));
const mock = JSON.parse(read('docs/development/mock-schema.json'));
let refs = 0;
function checkRefs(value) {
  if (!value || typeof value !== 'object') return;
  if (value.$ref?.startsWith('#/')) {
    refs++;
    const resolved = value.$ref.slice(2).split('/').reduce((node, key) => node?.[key.replaceAll('~1', '/').replaceAll('~0', '~')], mock);
    assert(resolved, `Unresolved Mock schema reference ${value.$ref}`);
  }
  Object.values(value).forEach(checkRefs);
}
checkRefs(mock);
assert.deepEqual(readback.errors, [], 'Native metadata differences');
assert.equal(readback.tableCount, names.length);
assert.equal(readback.businessFields, design.tables.reduce((n, t) => n + t.fields.length, 0));
assert.equal(readback.tables.reduce((n, t) => n + t.records, 0), 12);
console.log(JSON.stringify({status:'PASS_STATIC', tables:names.length, fields:readback.businessFields, pages:pageList.length, seedRows:seed.records.system_config.length, mockDefinitions:Object.keys(mock.$defs).length, mockReferences:refs, limitations:'Static check only. nocodb-readback.json is the original 12-config snapshot, not current live record counts; see separate native acceptance and P4 fixture readback.'}, null, 2));
