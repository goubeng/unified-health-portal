import test from 'node:test';
import assert from 'node:assert/strict';
import {
  chinaDayKey,chinaDayWindow,chinaWindowBounds,countRowsByChinaDay,normalizeChinaDayCounts
} from '../src/utils/chinaCalendar.mjs';

test('近7天和近30天始终以北京时间今天结束，跨月和跨年连续',()=>{
  const now=new Date('2027-01-01T02:00:00Z'); // 北京时间 1 月 1 日 10:00
  const week=chinaDayWindow(7,now);
  assert.deepEqual(week.map(day=>day.key),[
    '2026-12-26','2026-12-27','2026-12-28','2026-12-29',
    '2026-12-30','2026-12-31','2027-01-01'
  ]);
  const month=chinaDayWindow(30,now);
  assert.equal(month.length,30);
  assert.equal(month[0].key,'2026-12-03');
  assert.equal(month.at(-1).key,'2027-01-01');
  assert.ok(month.every(day=>day.value===0));
  assert.deepEqual(chinaWindowBounds(7,now),{
    startAt:'2026-12-25T16:00:00.000Z',endAt:'2027-01-01T02:00:00.000Z'
  });
});

test('历史日志不能把结束日锁在旧日期，无数据日补零且未来日志排除',()=>{
  const now=new Date('2026-10-08T04:00:00Z');
  const days=countRowsByChinaDay([
    {createdAt:'2026-09-28T10:00:00Z'},
    {createdAt:'2026-10-01T15:59:59Z'},
    {createdAt:'2026-10-01T16:00:00Z'},
    {createdAt:'2026-10-07T16:00:00Z'},
    {createdAt:'2026-10-08T04:00:01Z'},
    {createdAt:'bad-date'}
  ],7,now);
  assert.equal(days[0].key,'2026-10-02');
  assert.equal(days.at(-1).key,'2026-10-08');
  assert.deepEqual(days.map(day=>day.value),[1,0,0,0,0,0,1]);
});

test('数据库逐日计数窗口推进后自动舍弃旧日并补新日零值',()=>{
  const rows=[{date:'2026-10-07',count:3},{date:'2026-10-08',count:2}];
  const before=normalizeChinaDayCounts(rows,7,'2026-10-08T15:59:59Z');
  const after=normalizeChinaDayCounts(rows,7,'2026-10-08T16:00:01Z');
  assert.equal(chinaDayKey('2026-10-08T15:59:59Z'),'2026-10-08');
  assert.equal(chinaDayKey('2026-10-08T16:00:01Z'),'2026-10-09');
  assert.equal(before.at(-1).value,2);
  assert.deepEqual(after.slice(-3).map(day=>[day.key,day.value]),[
    ['2026-10-07',3],['2026-10-08',2],['2026-10-09',0]
  ]);
});
