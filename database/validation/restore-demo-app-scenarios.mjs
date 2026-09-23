import {fileURLToPath} from 'node:url';
import {resolve} from 'node:path';
import {createSeed} from '../../src/mock/seed.js';
import {sqlQuery} from '../../server/repository.mjs';

const table='"pb3gir75kkooyea"."application"';
const fields=['accessMode','accountBindingMode','postGrantMode','accountOpeningMode','mockScenario'];
const literal=value=>"'"+String(value).replaceAll("'","''")+"'";

export const scenarioFixtures=createSeed().apps.map(app=>({
 runtime_id:app.id,
 code:'P4FIX_'+app.code,
 patch:Object.fromEntries(fields.map(field=>[field,app[field]]))
}));

export function mergeMissingScenarioFields(existing,patch){
 const next={...existing};
 for(const field of fields)if(next[field]==null||next[field]==='')next[field]=patch[field];
 return next;
}

const fixtureSql=()=>`SELECT runtime_id,code,patch FROM jsonb_to_recordset(${literal(JSON.stringify(scenarioFixtures))}::jsonb) AS fixture(runtime_id text,code text,patch jsonb)`;
const candidatesSql=()=>`WITH fixture AS (${fixtureSql()}), candidate AS (
 SELECT a.id,a.runtime_id,a.runtime_payload,
  (SELECT coalesce(jsonb_object_agg(entry.key,entry.value),'{}'::jsonb)
   FROM jsonb_each(fixture.patch) entry
   WHERE a.runtime_payload->>entry.key IS NULL OR btrim(a.runtime_payload->>entry.key)='') AS missing
 FROM ${table} a JOIN fixture ON a.runtime_id=fixture.runtime_id AND a.code=fixture.code
 WHERE a.deleted_at IS NULL AND jsonb_typeof(a.runtime_payload)='object'
)`;

export const buildScenarioReadSql=()=>`${candidatesSql()}
 SELECT coalesce(json_agg(json_build_object('runtimeId',runtime_id,'missing',missing) ORDER BY runtime_id)
  FILTER (WHERE missing<>'{}'::jsonb),'[]'::json) FROM candidate;`;

export const buildScenarioIntegritySql=()=>`SELECT json_build_object(
 'activeApps',count(*),
 'completeScenarios',count(*) FILTER (WHERE ${fields.map(field=>`nullif(btrim(a.runtime_payload->>${literal(field)}),'') IS NOT NULL`).join(' AND ')}),
 'preservedDigest',md5(coalesce(string_agg(a.id||':'||a.status||':'||a.version||':'||
  (a.runtime_payload-ARRAY[${fields.map(literal).join(',')}])::text,'|' ORDER BY a.id),''))
) FROM ${table} a WHERE a.deleted_at IS NULL AND a.runtime_id LIKE 'MOCK_APP_%';`;

export const buildScenarioPatchSql=()=>`BEGIN;
SELECT pg_advisory_xact_lock(38013800);
${candidatesSql()}, updated AS (
 UPDATE ${table} a SET runtime_payload=a.runtime_payload||candidate.missing
 FROM candidate WHERE a.id=candidate.id AND candidate.missing<>'{}'::jsonb
 RETURNING a.runtime_id
)
SELECT coalesce(json_agg(runtime_id ORDER BY runtime_id),'[]'::json) FROM updated;
COMMIT;`;

if(process.argv[1]&&fileURLToPath(import.meta.url)===resolve(process.argv[1])){
 const integrityBefore=JSON.parse(await sqlQuery(buildScenarioIntegritySql()));
 const before=JSON.parse(await sqlQuery(buildScenarioReadSql()));
 console.log(JSON.stringify({mode:process.argv.includes('--apply')?'apply':'preview',...integrityBefore,patchableApps:before.length,missingFields:before.reduce((sum,row)=>sum+Object.keys(row.missing).length,0)}));
 if(process.argv.includes('--apply')){
  const updated=JSON.parse(await sqlQuery(buildScenarioPatchSql()));
  const integrityAfter=JSON.parse(await sqlQuery(buildScenarioIntegritySql()));
  const after=JSON.parse(await sqlQuery(buildScenarioReadSql()));
  console.log(JSON.stringify({updatedApps:updated.length,remainingPatchableApps:after.length,...integrityAfter,preserved:integrityAfter.preservedDigest===integrityBefore.preservedDigest}));
 }
}
