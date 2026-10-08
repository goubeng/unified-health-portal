import {spawn} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {isCompatibleApi,portalApiCodeRevision} from './code-revision.mjs';

const root=fileURLToPath(new URL('../',import.meta.url));
const viteBin=fileURLToPath(new URL('../node_modules/vite/bin/vite.js',import.meta.url));
const apiBin=fileURLToPath(new URL('./api.mjs',import.meta.url));
const children=[];
let closing=false;
const mockMode=process.argv.includes('--mock');
const expectedMode=mockMode?'MEMORY_A':'DATABASE';
const expectedRevision=portalApiCodeRevision();

async function apiReady(){
 try{
  const response=await fetch('http://127.0.0.1:4011/api/portal/health');
  const json=await response.json();
  return response.ok&&json?.ok?json.data||null:null;
 }catch{return null;}
}

async function waitForApi(timeoutMs=5000){
 const started=Date.now();
 while(Date.now()-started<timeoutMs){
  const running=await apiReady();
  if(isCompatibleApi(running,expectedMode,expectedRevision))return true;
  await new Promise(resolve=>setTimeout(resolve,120));
 }
 return false;
}

function start(label,args){
 const child=spawn(process.execPath,args,{cwd:root,stdio:'inherit',windowsHide:false});
 children.push(child);
 child.on('exit',code=>{
  if(!closing&&code&&code!==0){
   console.error(`[dev] ${label} exited with code ${code}`);
   shutdown(code);
  }
 });
 return child;
}

function shutdown(code=0){
 if(closing)return;
 closing=true;
 process.exitCode=code;
 for(const child of children){
  if(!child.killed)child.kill();
 }
 setTimeout(()=>process.exit(code),50).unref();
}

const existing=await apiReady();
if(isCompatibleApi(existing,expectedMode,expectedRevision)){
 console.log(`[dev] Reusing local ${expectedMode} API on http://127.0.0.1:4011`);
}else if(existing){
 console.error(existing.repository!==expectedMode
  ?`[dev] Port 4011 already runs ${existing.repository}; expected ${expectedMode}. Stop the old API before starting this mode.`
  :'[dev] Port 4011 already runs an API with an older or unknown source revision. Stop that API and restart npm run dev; the existing process was not changed.');
 process.exitCode=1;
}else{
 start(expectedMode+' API',['--watch',apiBin,...(mockMode?[]:['--db'])]);
 if(!(await waitForApi())){
  console.error(`[dev] ${expectedMode} API did not become ready on http://127.0.0.1:4011`);
  shutdown(1);
 }else{
  console.log(`[dev] ${expectedMode} API ready on http://127.0.0.1:4011`);
 }
}

if(!closing&&!process.exitCode)start('Vite',[viteBin,'--host','0.0.0.0','--port','4010','--strictPort']);

process.on('SIGINT',()=>shutdown(0));
process.on('SIGTERM',()=>shutdown(0));
