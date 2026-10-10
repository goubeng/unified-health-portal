import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

test('mobile announcement detail uses consistent icons and separates attachments heading',()=>{
  const notice=fs.readFileSync('src/mobile/MobileAnnouncements.vue','utf8');
  const css=fs.readFileSync('src/mobile/mobile-announcements.css','utf8');
  assert.match(notice,/TagIcon[^>]*aria-hidden="true"/);
  assert.match(notice,/UserIcon[^>]*aria-hidden="true"/);
  assert.match(notice,/CalendarIcon[^>]*aria-hidden="true"/);
  assert.match(notice,/<AttachIcon \/>\{\{ file.name \}\}<DownloadIcon \/>/);
  assert.match(css,/\.mobile-notices-files\{margin-top:24px;padding-top:16px;border-top:/);
  assert.match(notice,/function download\(file: Attachment\)/);
  assert.match(notice,/markSelectedRead/);
});
