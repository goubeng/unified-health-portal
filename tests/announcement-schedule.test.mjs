import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {disablePastPublishDate,disablePastPublishTime,isFuturePublishTime} from '../src/utils/announcementSchedule.js';

test('定时发布时间仅允许未来日期与时间',()=>{
  const now=new Date();
  const yesterday=new Date(now.getFullYear(),now.getMonth(),now.getDate()-1);
  const tomorrow=new Date(now.getFullYear(),now.getMonth(),now.getDate()+1);
  const localDate=date=>[date.getFullYear(),String(date.getMonth()+1).padStart(2,'0'),String(date.getDate()).padStart(2,'0')].join('-');
  assert.equal(disablePastPublishDate(localDate(yesterday)),true);
  assert.equal(disablePastPublishDate(localDate(now)),false);
  assert.equal(disablePastPublishDate(localDate(tomorrow)),false);
  assert.equal(isFuturePublishTime(new Date(Date.now()-60_000)),false);
  assert.equal(isFuturePublishTime(new Date(Date.now()+60_000)),true);
  assert.equal(isFuturePublishTime('无效日期'),false);
});

test('今天已经过去的小时和分钟不能选择，未来日期不限制时间',()=>{
  const now=new Date();
  const today=disablePastPublishTime(now);
  assert.equal(today.hour.length,now.getHours());
  assert.equal(today.minute.length,now.getMinutes());
  assert(today.second.includes(now.getSeconds()));
  const tomorrow=new Date(now.getFullYear(),now.getMonth(),now.getDate()+1,1);
  assert.deepEqual(disablePastPublishTime(tomorrow),{});
});

test('新增、编辑和提交发布均使用时间禁选和提交前校验',()=>{
  for(const file of ['AnnouncementManagement.vue','AnnouncementEditPage.vue']){
    const source=readFileSync(new URL('../src/components/portal/'+file,import.meta.url),'utf8');
    assert.match(source,/:disable-date="disablePastPublishDate"/);
    assert.match(source,/:disable-time="disablePastPublishTime"/);
    assert.match(source,/isFuturePublishTime/);
  }
});

test('公告富文本斜体在工具栏保持选区，正文允许模拟斜体字形',()=>{
  const editor=readFileSync(new URL('../src/components/portal/AnnouncementEditor.vue',import.meta.url),'utf8');
  const css=readFileSync(new URL('../src/styles/core.css',import.meta.url),'utf8');
  assert.match(editor,/@mousedown\.prevent="saveSelection" @click\.prevent="exec\('italic'\)"/);
  assert.match(css,/rich-editor-content[^\n]*portal-rich-content/);
  assert.match(css,/font-synthesis:\s*style/);
});
