import {createSeed} from '../../src/mock/seed.js';
import {dbId,schema,sqlQuery} from '../../server/repository.mjs';

const table=`"${schema}"."audit_event"`;
const lit=value=>"'"+String(typeof value==='object'?JSON.stringify(value):value).replaceAll("'","''")+"'";
const raw=await sqlQuery(`SELECT coalesce(json_agg(x),'[]'::json) FROM (SELECT id,version,kind,request_id,actor_user_id,application_id,result,summary,details,resolution_status FROM ${table} WHERE id LIKE 'P4FIX_LOG_%') x;`);
const rows=JSON.parse(raw),seed=new Map(createSeed().logs.map(row=>[dbId(row.id),row]));
const fields=['userName','account','userType','actorType','authType','identitySource','loginSource','loginMethod','failureReason','ip','client','accessMode','accessMethod','moduleName','pageName','actionName','objectType','interfaceName','httpMethod','statusCode','durationMs','errorCode','errorMessage','severity'];
const requestGroups={LOGIN:0,ACCESS:2,OPERATION:3,API:4,ERROR:5};
const changes=[];
for(const row of rows){
 const source=seed.get(row.id);
 if(!source)continue;
 const before=typeof row.details==='string'?JSON.parse(row.details):row.details;
 if(before?.fixture!==true||before.source!=='P4 offline dataset')continue;
 const expectedRequest=`P4FIX_P4_REQUEST_${requestGroups[row.kind]}_${row.id.split('_').at(-1)}`;
 if(row.kind!==source.kind.toUpperCase()||row.actor_user_id!==dbId(source.userId)||row.application_id!==dbId(source.appId)||row.request_id!==expectedRequest)throw new Error(`审计样本身份/应用/请求不匹配: ${row.id}`);
 if(row.result!==source.status&&row.id!=='P4FIX_LOG_login_3')throw new Error(`非预期审计结果差异: ${row.id}`);
 const recovered=Object.fromEntries(fields.filter(key=>source[key]!==undefined).map(key=>[key,source[key]]));
 const after={...before,...recovered,dataSource:'FIXTURE',realExternalCall:false};
 const resolutionStatus=row.kind==='ERROR'?source.resolutionStatus:row.resolution_status;
 if(resolutionStatus==='RESOLVED')Object.assign(after,{resolutionNote:source.resolutionNote||null,resolvedAt:source.resolvedAt||null,resolvedBy:source.resolvedBy||null});
 if(JSON.stringify(before)===JSON.stringify(after)&&row.summary===source.description&&row.resolution_status===resolutionStatus&&row.result===source.status)continue;
 changes.push({id:row.id,version:Number(row.version),before,after,summaryBefore:row.summary,summaryAfter:source.description,resultBefore:row.result,resultAfter:source.status,resolutionBefore:row.resolution_status,resolutionAfter:resolutionStatus});
}
const summary={mode:process.argv.includes('--apply')?'apply':'preview',existing:rows.length,matched:changes.length,ids:changes.map(row=>row.id)};
if(!process.argv.includes('--apply')){console.log(JSON.stringify(summary));process.exit(0);}
if(!changes.length){console.log(JSON.stringify({...summary,applied:false,alreadyComplete:true}));process.exit(0);}
if(changes.length!==20)throw new Error(`目标不是预期的 20 条历史 Mock 审计样本: ${changes.length}`);
const updates=changes.map(row=>`DO $$ BEGIN UPDATE ${table} SET details=${lit(row.after)},summary=${lit(row.summaryAfter)},result=${lit(row.resultAfter)},resolution_status=${row.resolutionAfter==null?'NULL':lit(row.resolutionAfter)},version=version+1,updated_at=now() WHERE id=${lit(row.id)} AND version=${row.version} AND details::jsonb=${lit(row.before)}::jsonb AND summary=${lit(row.summaryBefore)} AND result=${lit(row.resultBefore)} AND resolution_status IS NOT DISTINCT FROM ${row.resolutionBefore==null?'NULL':lit(row.resolutionBefore)}; IF NOT FOUND THEN RAISE EXCEPTION 'AUDIT_FIXTURE_DRIFT'; END IF; END $$;`).join('\n');
await sqlQuery(`BEGIN; SET LOCAL lock_timeout='5s'; ${updates} COMMIT;`);
console.log(JSON.stringify({...summary,applied:true}));
