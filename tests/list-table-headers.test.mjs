import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';

const source=path=>readFileSync(new URL(`../${path}`,import.meta.url),'utf8');

test('TDesign 列表表头统一单行，正文单元格不受影响',()=>{
  const css=source('src/styles/core.css');
  assert.match(css,/\.t-table th,\s*\.t-table \.t-table__th-cell-inner,\s*\.t-table th \*\s*\{\s*white-space:nowrap!important;/);
});

test('用户启用状态和角色说明不提供排序',()=>{
  const user=source('src/components/portal/UserManagement.vue');
  const role=source('src/components/portal/RoleManagement.vue');
  assert.match(user,/\{colKey:'enabled',title:'启用状态',width:110\}/);
  assert.match(role,/\{colKey:'description',title:'角色说明',minWidth:280,ellipsis:true\}/);
});

test('组织管理无表头排序，仍按组织自身排序号展示树',()=>{
  const organization=source('src/components/portal/OrganizationManagement.vue');
  assert.doesNotMatch(organization,/sorter:|@sort-change|:sort="/);
  assert.match(organization,/list\.sort\(\(a,b\)=>\(Number\(a\.sortOrder\)\|\|0\)/);
});
