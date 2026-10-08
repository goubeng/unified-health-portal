import {createHash} from 'node:crypto';
import {readFileSync} from 'node:fs';

const sourceFiles=[
 ['server/api.mjs',new URL('./api.mjs',import.meta.url)],
 ['server/repository.mjs',new URL('./repository.mjs',import.meta.url)],
 ['src/services/portal.js',new URL('../src/services/portal.js',import.meta.url)],
 ['src/utils/chinaCalendar.mjs',new URL('../src/utils/chinaCalendar.mjs',import.meta.url)]
];

export function portalApiCodeRevision(files=sourceFiles){
 const hash=createHash('sha256');
 for(const [name,url] of files){
  hash.update(name).update('\0').update(readFileSync(url)).update('\0');
 }
 return hash.digest('hex');
}

export const isCompatibleApi=(health,mode,revision)=>
 health?.repository===mode&&health.codeRevision===revision;
