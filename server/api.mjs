import {createServer} from 'node:http';
import {randomUUID,randomBytes,createHash,timingSafeEqual} from 'node:crypto';
import {pathToFileURL} from 'node:url';
import {createPortalService} from '../src/services/portal.js';
import {archiveExpired} from '../src/config/rules.js';
import {can} from '../src/config/pages.js';
import {createRepository,createMemoryRepository,makeEvent} from './repository.mjs';

const resultError=(code,message)=>({ok:false,error:{code,message,retryable:false}});
export {appContract as contract} from '../src/config/integration-contract.js';
import {appContract as contract,publicContract,integrationFields} from '../src/config/integration-contract.js';
const statusFor=r=>r.ok?200:({UNAUTHENTICATED:401,FORBIDDEN:403,NOT_FOUND:404,IDEMPOTENCY_CONFLICT:409,STALE_EVENT:409,INVALID_TRANSITION:409,VERSION_CONFLICT:409})[r.error?.code]||400;
const hash=v=>createHash('sha256').update(v).digest();
function stateProvider(state){let current=structuredClone(state);return {kind:'mock',read:()=>structuredClone(current),transact(fn){const next=structuredClone(current),out=fn(next);current=next;return structuredClone(out);}};}
async function body(req){let data='';for await(const chunk of req){data+=chunk;if(data.length>12*1024*1024)throw Error('请求内容过大');}return data?JSON.parse(data):{};}
export function createPortalApi({repository=null,env=process.env}={}){
 repository??=String(env.PORTAL_REPOSITORY||'memory').toLowerCase()==='db'?createRepository():createMemoryRepository();
 const sessions=new Map();let queue=Promise.resolve();
 const serial=fn=>{const next=queue.then(fn,fn);queue=next.catch(()=>{});return next;};
 const send=(res,status,data)=>{res.writeHead(status,{'Content-Type':'application/json; charset=utf-8','Cache-Control':'no-store','X-Content-Type-Options':'nosniff'});res.end(JSON.stringify({...data,requestId:data.requestId||randomUUID()}));};
 const resolveActor=(req,state)=>{const sid=(req.headers.cookie||'').split(';').map(x=>x.trim()).find(x=>x.startsWith('wj_portal='))?.slice(10),session=sessions.get(sid);if(!session||session.expires<Date.now()){if(sid)sessions.delete(sid);return null;}return state.users.find(x=>x.id===session.userId&&x.status!=='DISABLED')||null;};
 const handle=async(req,res)=>{
  try{
   if(!/^((127\.0\.0\.1|localhost)(:380[01])?)$/.test(req.headers.host||''))return send(res,403,resultError('FORBIDDEN','仅允许本机入口'));
   const url=new URL(req.url,'http://127.0.0.1:3801'),path=url.pathname;
   const external=path.startsWith('/api/portal/ingest/');
   if(req.method!=='GET'&&!external&&!/^http:\/\/(127\.0\.0\.1|localhost):380[01]$/.test(req.headers.origin||''))return send(res,403,resultError('FORBIDDEN','请求来源不允许'));
   const payload=req.method==='POST'?await body(req):{};
   await serial(async()=>{
    const {state,version}=await repository.load();const actor=resolveActor(req,state);
    if(path==='/api/portal/health')return send(res,200,{ok:true,data:{repository:repository.mode||'UNKNOWN',database:repository.database||null,schema:repository.schema||null,phase:repository.mode==='DATABASE'?'0.3.0-B/C':'0.3.0-A',version}});
    if(path==='/api/portal/session'&&req.method==='GET')return send(res,200,{ok:true,data:{actor,users:state.users.filter(x=>x.status!=='DISABLED')}});
    if(path==='/api/portal/session'&&req.method==='POST'){
     const next=state.users.find(x=>x.id===payload.userId&&x.status!=='DISABLED');if(!next)return send(res,403,resultError('FORBIDDEN','用户已停用或不存在'));
     const event=makeEvent({actor:next,action:actor?'SWITCH_USER':'LOGIN',payload:{previousActor:actor?.id},state,result:{ok:true},kind:'LOGIN'});
     await repository.commit(state,state,version,event);
     const sid=randomBytes(32).toString('hex'),ttl=Number(state.settings.find(x=>x.code==='auth.session_ttl_seconds')?.value)||7200;
     const old=(req.headers.cookie||'').match(/wj_portal=([^;]+)/)?.[1];if(old)sessions.delete(old);sessions.set(sid,{userId:next.id,expires:Date.now()+ttl*1000});
     res.setHeader('Set-Cookie',`wj_portal=${sid}; HttpOnly; SameSite=Strict; Path=/api/portal; Max-Age=${ttl}`);return send(res,200,{ok:true,data:next});
    }
    if(path==='/api/portal/logout'&&req.method==='POST'){
     if(actor)await repository.commit(state,state,version,makeEvent({actor,action:'LOGOUT',state,result:{ok:true},kind:'LOGIN'}));
     const sid=(req.headers.cookie||'').match(/wj_portal=([^;]+)/)?.[1];if(sid)sessions.delete(sid);res.setHeader('Set-Cookie','wj_portal=; HttpOnly; SameSite=Strict; Path=/api/portal; Max-Age=0');return send(res,200,{ok:true});
    }
    const provider=stateProvider(state),service=createPortalService(provider,()=>actor);
    if(external&&req.method==='POST'){
     const match=path.match(/^\/api\/portal\/ingest\/([^/]+)\/(todos|messages)$/);if(!match)return send(res,404,resultError('NOT_FOUND','接口不存在'));
     const appId=decodeURIComponent(match[1]),kind=match[2]==='todos'?'TODO':'MESSAGE',config=state.integrations.find(x=>x.appId===appId&&x.kind===kind);
     const rejectPush=async(code,message,status)=>{const result=resultError(code,message);const event=makeEvent({action:'PUSH_REJECTED',payload:{appId},state,result,kind:'API'});event.actorKind='APPLICATION';await repository.commit(state,state,version,event);return send(res,status,result);};
     if(!config||config.enabled!=='ENABLED'||state.apps.find(x=>x.id===appId)?.status!=='ENABLED')return rejectPush('FORBIDDEN','来源接入未启用',403);
     const key=env[config.credentialRef],supplied=(req.headers.authorization||'').replace(/^Bearer /,'');
     if(!key||!supplied||!timingSafeEqual(hash(key),hash(supplied)))return rejectPush('UNAUTHENTICATED','接入凭据不匹配',401);
     const fields=integrationFields[kind];
     const input=Object.fromEntries(fields.map(k=>[k,payload[config.fieldMapping?.[k]||k]]));input.appId=appId;
     if(kind==='TODO')input.status=config.valueMapping?.status?.[input.status]||input.status;
     if(fields.some(key=>key==='sourceRevision'?!Number.isSafeInteger(input[key]):typeof input[key]!=='string'||!input[key].trim())){const result=resultError('VALIDATION_ERROR','请求字段缺失或类型不符合接口规范');await repository.commit(state,state,version,makeEvent({action:'PUSH_REJECTED',payload:{appId},state,result,kind:'API'}));return send(res,400,result);}
     const principal=state.users.find(x=>x.status!=='DISABLED'&&x.scopes.includes('super'));const machineService=createPortalService(provider,()=>principal);
     const action=kind==='TODO'?'pushTodo':'pushMessage',result=await machineService.command(action,input);
     const event=makeEvent({action,payload:input,state,result,kind:'API'});event.actorKind='APPLICATION';event.details.source='BEARER_PUSH';
     await repository.commit(state,provider.read(),version,event);return send(res,statusFor(result),result);
    }
    if(!actor)return send(res,401,resultError('UNAUTHENTICATED','请先登录'));
    if(path==='/api/portal/contracts/public'&&req.method==='GET'){
     if(!can(actor,'application'))return send(res,403,resultError('FORBIDDEN','需要应用管理权限'));
     await repository.commit(state,state,version,makeEvent({actor,action:'DOWNLOAD_CONTRACT',state,result:{ok:true}}));return send(res,200,{ok:true,data:publicContract()});
    }
    if(path.startsWith('/api/portal/contracts/')&&req.method==='GET'){
     if(!can(actor,'application'))return send(res,403,resultError('FORBIDDEN','需要集成管理权限'));
     const [,kind,appId]=path.match(/^\/api\/portal\/contracts\/(TODO|MESSAGE)\/([^/]+)$/)||[];
     if(!kind||!state.apps.some(x=>x.id===appId))return send(res,404,resultError('NOT_FOUND','接入对象不存在'));
     const doc=contract(kind,appId),config=state.integrations.find(x=>x.kind===kind&&x.appId===appId);doc['x-field-mapping']=config?.fieldMapping||{};doc['x-value-mapping']=config?.valueMapping||{};
     await repository.commit(state,state,version,makeEvent({actor,action:'DOWNLOAD_CONTRACT',payload:{appId},state,result:{ok:true}}));return send(res,200,{ok:true,data:doc});
    }
    if(path==='/api/portal/read'&&req.method==='GET'){
     const resource=url.searchParams.get('resource')||'';const result=await service.read(resource);
     if(result.ok&&resource.startsWith('logs:'))result.data=await repository.logs(resource.slice(5));return send(res,statusFor(result),result);
    }
    if(path==='/api/portal/command'&&req.method==='POST'){
     const action=String(payload.action||''),input=payload.payload||{},result=await service.command(action,input);
     await repository.commit(state,provider.read(),version,makeEvent({actor,action,payload:input,state:provider.read(),result}));return send(res,statusFor(result),result);
    }
    send(res,404,resultError('NOT_FOUND','接口不存在'));
   });
  }catch(error){console.error('[portal-api]',error.message);if(!res.headersSent)send(res,503,resultError('SERVICE_UNAVAILABLE','服务或数据库暂不可用，请联系管理员'));else res.end();}
 };
 const cleanup=()=>serial(async()=>{const {state,version}=await repository.load(),next=structuredClone(state),removed=archiveExpired(next);if(!removed.length)return 0;const event=makeEvent({action:'ANNOUNCEMENT_RETENTION',state,result:{ok:true}});event.details.ids=removed.map(x=>x.id);event.summary=`过期公告清理 ${removed.length} 条（已保留回收档案）`;await repository.commit(state,next,version,event);return removed.length;});
 return {handle,cleanup};
}
if(process.argv[1]&&import.meta.url===pathToFileURL(process.argv[1]).href){
 const dbRequested=process.argv.includes('--db');
 const env={...process.env,PORTAL_REPOSITORY:dbRequested?'db':'memory'};
 const api=createPortalApi({env});
 createServer(api.handle).listen(3801,'127.0.0.1',()=>console.log(`Portal local API ready: http://127.0.0.1:3801 · repository=${String(env.PORTAL_REPOSITORY).toUpperCase()}`));
 setInterval(()=>api.cleanup().catch(e=>console.error('[retention]',e.message)),60000).unref();
}
