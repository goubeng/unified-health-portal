import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync,writeFileSync,rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {Readable} from 'node:stream';
import {createPortalApi} from '../server/api.mjs';
import {isCompatibleApi,portalApiCodeRevision} from '../server/code-revision.mjs';

test('API source revision changes with source content and rejects missing or stale revisions',()=>{
 const directory=mkdtempSync(join(tmpdir(),'portal-revision-'));
 try{
  const file=join(directory,'source.mjs');
  writeFileSync(file,'export const value=1;');
  const revision=portalApiCodeRevision([['source.mjs',file]]);
  assert.equal(revision.length,64);
  assert.equal(isCompatibleApi({repository:'DATABASE',codeRevision:revision},'DATABASE',revision),true);
  assert.equal(isCompatibleApi({repository:'MEMORY_A',codeRevision:revision},'DATABASE',revision),false);
  assert.equal(isCompatibleApi({repository:'DATABASE'},'DATABASE',revision),false);
  writeFileSync(file,'export const value=2;');
  assert.notEqual(portalApiCodeRevision([['source.mjs',file]]),revision);
 }finally{rmSync(directory,{recursive:true,force:true});}
});

test('health exposes the API source revision captured at startup',async()=>{
 const api=createPortalApi();
 const request=Readable.from([]);
 Object.assign(request,{url:'/api/portal/health',method:'GET',headers:{host:'localhost:4011'}});
 let result;
 const response={writeHead(){this.headersSent=true;},end(value){result=JSON.parse(value);}};
 await api.handle(request,response);
 assert.equal(result.ok,true);
 assert.equal(result.data.repository,'MEMORY_A');
 assert.equal(result.data.codeRevision,portalApiCodeRevision());
});
