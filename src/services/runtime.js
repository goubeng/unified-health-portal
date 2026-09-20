import {ref,computed} from 'vue';
export const actor=ref(null),revision=ref(0),startupError=ref('');
const users=ref([]);
export const availableUsers=computed(()=>users.value.filter(x=>x.status!=='DISABLED'));
async function request(path,body){
 try{const response=await fetch('/api/portal/'+path,{credentials:'same-origin',...(body===undefined?{}:{method:'POST',headers:{'Content-Type':'application/json'},body:JSON.stringify(body)})});const result=await response.json();if(!result||typeof result.ok!=='boolean')throw Error();return result;}
 catch{return {ok:false,error:{code:'SERVICE_UNAVAILABLE',message:'门户服务暂不可用，请确认本地接口服务已启动'}};}
}
export async function initializeRuntime(){const result=await request('session');if(result.ok){actor.value=result.data.actor;users.value=result.data.users;startupError.value='';}else startupError.value=result.error.message;}
export const portal={read:resource=>request('read?resource='+encodeURIComponent(resource))};
export async function login(id){const result=await request('session',{userId:id});if(!result.ok)throw new Error(result.error.message);actor.value=result.data;await initializeRuntime();revision.value++;}
export async function logout(){const result=await request('logout',{});if(!result.ok)throw new Error(result.error.message);actor.value=null;revision.value++;}
export async function command(action,payload={}){const result=await request('command',{action,payload});if(result.ok){await initializeRuntime();revision.value++;}return result;}
export async function downloadContract(kind,appId){const result=await request(`contracts/${kind}/${encodeURIComponent(appId)}`);if(!result.ok)throw Error(result.error.message);const url=URL.createObjectURL(new Blob([JSON.stringify(result.data,null,2)],{type:'application/json'}));const a=document.createElement('a');a.href=url;a.download=`${kind.toLowerCase()}-${appId}-openapi.json`;a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);}

export async function downloadAccessContract(){
 const result=await request('contracts/public');if(!result.ok)throw Error(result.error.message);
 const url=URL.createObjectURL(new Blob([JSON.stringify(result.data,null,2)],{type:'application/json;charset=utf-8'}));const a=document.createElement('a');a.href=url;a.download='卫健XC统一门户_公共接入规范_OpenAPI.json';a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);
}
