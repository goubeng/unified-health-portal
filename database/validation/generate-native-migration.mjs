import fs from 'node:fs';
import {createHash} from 'node:crypto';
const s=JSON.parse(fs.readFileSync('docs/development/nocodb-schema.json','utf8'));
const schema='pb3gir75kkooyea';
const q=x=>{if(!/^[a-z0-9_]+$/.test(x))throw Error('Invalid identifier');return `"${x}"`;};
const lit=x=>`'${x.replaceAll("'","''")}'`;
const hash=x=>createHash('sha256').update(x).digest('hex');
const out=['-- Only the existing native project schema; no external source or platform metadata changes.','BEGIN;',"SET LOCAL lock_timeout='5s';",`SET LOCAL search_path=${q(schema)},pg_catalog;`];
let count=0;
function constraint(table,definition){
 const digest=hash(table+definition),name='p3_'+table.slice(0,28)+'_'+digest.slice(0,12),rel=`${q(schema)}.${q(table)}`;
 out.push(`DO $p3$ DECLARE found_oid oid; actual text; BEGIN
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid=${lit(rel)}::regclass AND c.conname=${lit(name)};
 IF found_oid IS NULL THEN
 ALTER TABLE ${rel} ADD CONSTRAINT ${q(name)} ${definition};
 SELECT c.oid INTO found_oid FROM pg_constraint c WHERE c.conrelid=${lit(rel)}::regclass AND c.conname=${lit(name)};
 EXECUTE format('COMMENT ON CONSTRAINT %I ON ${rel} IS %L',${lit(name)},${lit('P3|'+digest+'|')}||pg_get_constraintdef(found_oid));
 ELSE
 actual:=obj_description(found_oid,'pg_constraint');
 IF actual IS DISTINCT FROM ${lit('P3|'+digest+'|')}||pg_get_constraintdef(found_oid) THEN RAISE EXCEPTION 'Constraint drift: ${name}'; END IF;
 END IF; END $p3$;`);count++;
}
for(const t of s.tables){
 for(const f of t.fields.filter(x=>x.required))out.push(`ALTER TABLE ${q(schema)}.${q(t.name)} ALTER COLUMN ${q(f.name)} SET NOT NULL;`);
 constraint(t.name,'UNIQUE ("id")');
 for(const key of t.unique)constraint(t.name,`UNIQUE (${key.map(q).join(',')})`);
}
for(const t of s.tables){
 for(const f of t.fields){
  if(f.references)constraint(t.name,`FOREIGN KEY (${q(f.name)}) REFERENCES ${q(schema)}.${q(f.references)} ("id") ON DELETE RESTRICT`);
  const values=f.enum?s.enums[f.enum]:f.values;
  if(values)constraint(t.name,`CHECK (${q(f.name)} IN (${values.map(lit).join(',')}))`);
  if(f.min!==undefined)constraint(t.name,`CHECK (${q(f.name)} >= ${f.min})`);
  if(f.type==='json')constraint(t.name,`CHECK (${q(f.name)} IS NULL OR jsonb_typeof(${q(f.name)}::jsonb) IS NOT NULL)`);
 }
 for(let check of t.checks){
  for(const f of t.fields.filter(x=>x.type==='json'))check=check.replace(new RegExp(`\\b${f.name}\\b(?!::jsonb)`,'g'),`${f.name}::jsonb`);
  constraint(t.name,`CHECK (${check})`);
 }
 const indexes=[...t.indexes.map(fields=>({fields,where:null})),...(t.partialUniqueIndexes||[]).map(x=>({...x,unique:true}))];
 for(const idx of indexes){
  const digest=hash(t.name+JSON.stringify(idx)),name='p3i_'+t.name.slice(0,27)+'_'+digest.slice(0,12),rel=`${q(schema)}.${q(t.name)}`;
  out.push(`DO $p3$ DECLARE found_oid oid; BEGIN
 found_oid:=to_regclass(${lit(schema+'.'+name)});
 IF found_oid IS NULL THEN
 CREATE ${idx.unique?'UNIQUE ':''}INDEX ${q(name)} ON ${rel} (${idx.fields.map(q).join(',')})${idx.where?' WHERE '+idx.where:''};
 found_oid:=to_regclass(${lit(schema+'.'+name)});
 EXECUTE format('COMMENT ON INDEX ${q(schema)}.%I IS %L',${lit(name)},${lit('P3|'+digest+'|')}||pg_get_indexdef(found_oid));
 ELSIF obj_description(found_oid,'pg_class') IS DISTINCT FROM ${lit('P3|'+digest+'|')}||pg_get_indexdef(found_oid) THEN RAISE EXCEPTION 'Index drift: ${name}';
 END IF; END $p3$;`);
 }
}
out.push(`-- ${count} constraints plus supporting indexes; repeated execution verifies definitions.`,`COMMIT;`);
console.log(out.join('\n'));
