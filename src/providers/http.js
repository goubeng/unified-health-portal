// Future server boundary. Never configure a NocoDB management token in a browser.
export function createHttpProvider(base='/api/portal'){
 return {kind:'http',async request(path,options={}){const r=await fetch(base+path,{credentials:'same-origin',...options,headers:{'Content-Type':'application/json',...options.headers}});if(!r.ok)throw new Error('服务请求失败：'+r.status);return r.json();}};
}
