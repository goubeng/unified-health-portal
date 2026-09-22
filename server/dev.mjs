import {spawn} from 'node:child_process';
import {fileURLToPath} from 'node:url';

const root=fileURLToPath(new URL('../',import.meta.url));
const viteBin=fileURLToPath(new URL('../node_modules/vite/bin/vite.js',import.meta.url));
const apiBin=fileURLToPath(new URL('./api.mjs',import.meta.url));
const children=[];
let closing=false;

async function apiReady(){
 try{
  const response=await fetch('http://127.0.0.1:4011/api/portal/health');
  const json=await response.json();
  return Boolean(response.ok&&json?.ok);
 }catch{return false;}
}

async function waitForApi(timeoutMs=5000){
 const started=Date.now();
 while(Date.now()-started<timeoutMs){
  if(await apiReady())return true;
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
 for(const child of children){
  if(!child.killed)child.kill();
 }
 setTimeout(()=>process.exit(code),50).unref();
}

if(await apiReady()){
 console.log('[dev] Reusing local Mock API on http://127.0.0.1:4011');
}else{
 start('Mock API',[apiBin]);
 if(!(await waitForApi())){
  console.error('[dev] Mock API did not become ready on http://127.0.0.1:4011');
  shutdown(1);
 }else{
  console.log('[dev] Mock API ready on http://127.0.0.1:4011');
 }
}

if(!closing)start('Vite',[viteBin,'--host','0.0.0.0','--port','4010','--strictPort']);

process.on('SIGINT',()=>shutdown(0));
process.on('SIGTERM',()=>shutdown(0));
