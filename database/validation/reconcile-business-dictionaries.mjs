import {createRepository} from '../../server/repository.mjs';
import {reconcileBusinessDictionaries} from '../../src/config/dictionary-catalog.js';

const repository=createRepository();
const {state,version}=await repository.load();
const {state:next,added}=reconcileBusinessDictionaries(state);
const result={mode:process.argv.includes('--apply')?'APPLY':'PREVIEW',version,added,
 counts:{typesBefore:(state.dictTypes||[]).length,typesAfter:next.dictTypes.length,itemsBefore:(state.dictItems||[]).length,itemsAfter:next.dictItems.length}};
if(process.argv.includes('--apply')&&(added.types.length||added.items.length)){
 await repository.commit(state,next,version);
 const readback=(await repository.load()).state;
 const missingTypes=added.types.filter(code=>!readback.dictTypes.some(type=>type.code===code));
 const missingItems=added.items.filter(key=>!readback.dictItems.some(item=>`${item.typeCode}:${item.value}`===key));
 if(missingTypes.length||missingItems.length)throw new Error(`字典回读缺失：${[...missingTypes,...missingItems].join(', ')}`);
 result.readback='OK';
}
console.log(JSON.stringify(result,null,2));
