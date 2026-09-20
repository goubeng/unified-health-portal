import {createRepository,sqlQuery,dbId,schema} from '../../server/repository.mjs';
import {addMonitorScenarios,auditScenarios} from '../../src/mock/scenarios.js';
const repository=createRepository(),{state,version}=await repository.load(),next=structuredClone(state);
const unlinked=[...state.todos,...state.messages.filter(x=>x.appId)].filter(x=>!state.mappings.some(m=>m.userId===x.userId&&m.appId===x.appId&&m.status==='BOUND'));
if(unlinked.length)throw Error('存在无有效关联的业务记录，请先人工核查：'+unlinked.map(x=>x.id).join(','));
addMonitorScenarios(next);
const existingMonitors=JSON.parse(await sqlQuery(`SELECT coalesce(json_agg(row_to_json(m)),'[]'::json) FROM (SELECT id,target_key,service_type FROM "${schema}".monitor_status) m;`));
for(const sample of next.monitorSamples){const existing=existingMonitors.find(x=>x.target_key===dbId(sample.appId)&&x.service_type===sample.kind);if(!existing)continue;if(!existing.id.startsWith('P4FIX_'))throw Error('监控存在非本轮样本记录，停止覆盖：'+existing.id);sample.id=existing.id.slice('P4FIX_'.length);}
for(const item of next.integrations){item.enabled??='DISABLED';item.status=item.enabled==='DISABLED'&&item.status==='DISABLED'?'DISABLED':'UNCONFIGURED';item.connectionStatus='UNCONFIGURED';item.valueMapping??={};}
const quote=v=>v==null?'NULL':"'"+String(typeof v==='object'?JSON.stringify(v):v).replaceAll("'","''")+"'";
const qtable=name=>`"${schema}"."${name}"`;
if(!process.argv.includes('--apply')){console.log(JSON.stringify({mode:'preview',version,counts:{apps:next.apps.length,integrations:next.integrations.length,mappings:next.mappings.length,monitor:next.monitorSamples.length,auditScenarios:auditScenarios.length},unlinked:0}));process.exit(0);}
await sqlQuery(`INSERT INTO ${qtable('system_config')}(id,created_at,updated_at,version,code,value,unit,status,description) VALUES ('P4BACKUP_20260919',now(),now(),1,'P4BACKUP_20260919',${quote(state)},'json','CONFIGURED','Backup before 20260919 native sync') ON CONFLICT(id) DO NOTHING;`);
// Force synchronization of these known P4-prefixed rows only; preserve all other table rows.
const before={...state,categories:[],apps:[],mappings:[],integrations:[],monitorSamples:[]};
await repository.commit(before,next,version,null);
const sql=auditScenarios.map(([kind,code,result,summary],i)=>{
 const mapping=next.mappings.filter(m=>m.status==='BOUND')[i%next.mappings.filter(m=>m.status==='BOUND').length],user=next.users.find(x=>x.id===mapping.userId),app=next.apps.find(x=>x.id===mapping.appId),id='P4SC_AUDIT_'+code;
 const row={id,created_at:'2026-09-19T01:00:00.000Z',updated_at:'2026-09-19T01:00:00.000Z',version:1,kind,event_code:code,request_id:'P4SC_REQUEST_'+code,actor_user_id:dbId(user.id),actor_kind:'USER',application_id:dbId(app.id),object_type:'application',object_id:app.id,result,summary,details:{dataSource:'FIXTURE',actorName:user.name,applicationName:app.name,scenario:code,realExternalCall:false}};
 return `INSERT INTO ${qtable('audit_event')} (${Object.keys(row).map(k=>'"'+k+'"').join(',')}) VALUES (${Object.values(row).map(quote).join(',')}) ON CONFLICT(id) DO NOTHING;`;
}).join('\n');
await sqlQuery('BEGIN;'+sql+'COMMIT;');
const latest=await repository.load();
console.log(JSON.stringify({mode:'applied',version:latest.version,backup:'P4BACKUP_20260919',apps:latest.state.apps.length,mappings:latest.state.mappings.length,todos:latest.state.todos.length,messages:latest.state.messages.length,integrations:latest.state.integrations.length,monitorSamples:latest.state.monitorSamples.length,unlinked:0,auditScenarios:auditScenarios.length}));
