import {createSeed} from '../mock/seed.js';
import {ensureRules} from '../config/rules.js';
// v3 adds system-role data and account-scoped application visibility.
const key='wj-portal-p4-demo-v3';
export function createMockProvider(storage){
 let data=createSeed();
 try{const saved=JSON.parse(storage?.getItem(key)||'null');if(saved?.schemaVersion===3&&Array.isArray(saved.apps)&&Array.isArray(saved.users)&&Array.isArray(saved.roles))data=saved;}catch{ /* Invalid local demo cache resets to explicit seed. */ }
 ensureRules(data);
 return {kind:'mock',read:()=>structuredClone(data),transact(fn){const next=structuredClone(data);const value=fn(next);storage?.setItem(key,JSON.stringify(next));data=next;return structuredClone(value);},reset(){data=ensureRules(createSeed());storage?.removeItem(key);}};
}
