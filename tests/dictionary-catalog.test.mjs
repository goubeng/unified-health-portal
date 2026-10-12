import test from 'node:test';
import assert from 'node:assert/strict';
import { createMockProvider } from '../src/providers/mock.js';
import { createPortalService } from '../src/services/portal.js';
import { actors } from '../src/mock/seed.js';
import { createSeed } from '../src/mock/seed.js';
import { businessDictionaryCatalog, reconcileBusinessDictionaries } from '../src/config/dictionary-catalog.js';
import { publicContract } from '../src/config/integration-contract.js';
import { dictionaryLookups } from '../src/services/runtime.js';
import { label, dictionaryOptions } from '../src/components/portal/presentation.js';

const requiredItems = {
  todo_status: ['PENDING', 'COMPLETED', 'WITHDRAWN', 'EXPIRED'],
  todo_task_type: ['服务事项', '材料补正', '审核审批', '结果确认'],
  message_type: ['SYSTEM', 'BUSINESS', 'TODO_REMINDER'],
  message_read_status: ['UNREAD', 'READ'],
  announcement_status: ['DRAFT', 'PUBLISHED', 'WITHDRAWN', 'SCHEDULED', 'EXPIRED'],
  application_request_status: ['PENDING', 'APPROVED', 'REJECTED', 'WITHDRAWN'],
  account_opening_status: ['PENDING', 'PROCESSING', 'COMPLETED'],
  mapping_status: ['UNBOUND', 'VERIFYING', 'REVIEWING', 'BOUND', 'FAILED', 'CONFLICT']
};

async function lookup(actorIndex) {
  const service = createPortalService(createMockProvider(), () => actors[actorIndex]);
  const result = await service.read('lookupDictionaries');
  assert.equal(result.ok, true, JSON.stringify(result));
  return { service, data: result.data };
}

test('常用业务字典有稳定编码，公众和管理员读取同一查询目录', async () => {
  const publicLookup = (await lookup(0)).data;
  const adminLookup = (await lookup(2)).data;
  assert.deepEqual(publicLookup, adminLookup);

  for (const [code, values] of Object.entries(requiredItems)) {
    const type = publicLookup.types.find(item => item.code === code);
    assert(type, `缺少字典类型 ${code}`);
    const items = publicLookup.items.filter(item => item.typeCode === code);
    assert.deepEqual(new Set(items.map(item => item.value)), new Set(values), `${code} 编码变化`);
    assert(items.every(item => typeof item.label === 'string' && item.label.length > 0));
  }
  assert.equal(publicLookup.items.find(item => item.typeCode === 'todo_status' && item.value === 'EXPIRED').status, 'ENABLED');
  assert.equal(publicLookup.items.find(item => item.typeCode === 'announcement_status' && item.value === 'SCHEDULED').status, 'ENABLED');
  assert.equal(publicLookup.items.find(item => item.typeCode === 'announcement_status' && item.value === 'EXPIRED').status, 'ENABLED');
});

test('字典展示条目不能扩充待办 PUSH 状态机', async () => {
  const { service, data } = await lookup(2);
  assert(data.items.some(item => item.typeCode === 'todo_status' && item.value === 'EXPIRED'));
  const rejected = await service.command('pushTodo', {
    appId: 'MOCK_APP_1', userId: 'MOCK_USER_1', sourceTodoId: 'DICT_EXPIRED',
    eventId: 'DICT_EXPIRED_EVENT', status: 'EXPIRED', title: '历史状态不可推送'
  });
  assert.equal(rejected.ok, false);
});

test('历史数据库按业务键补缺，不覆盖已维护的标签和状态，重跑幂等', () => {
  const state = createSeed();
  state.dictTypes = state.dictTypes.filter(type => type.code !== 'todo_status');
  state.dictItems = state.dictItems.filter(item => item.typeCode !== 'todo_status');
  const edited = state.dictItems.find(item => item.typeCode === 'todo_task_type' && item.value === '服务事项');
  edited.label = '本地业务事项';
  edited.status = 'DISABLED';
  const added = reconcileBusinessDictionaries(state);
  assert(added.added.types.includes('todo_status'));
  assert(added.added.items.includes('todo_status:PENDING'));
  assert.equal(added.state.dictItems.find(item => item.typeCode === 'todo_task_type' && item.value === '服务事项').label, '本地业务事项');
  assert.equal(added.state.dictItems.find(item => item.typeCode === 'todo_task_type' && item.value === '服务事项').status, 'DISABLED');
  assert.equal(state.dictTypes.some(type => type.code === 'todo_status'), false, '不应原地修改输入状态');
  const again = reconcileBusinessDictionaries(added.state);
  assert.deepEqual(again.added, { types: [], items: [] });
  assert.deepEqual(again.state, added.state);
  assert.equal(new Set(businessDictionaryCatalog.map(type => type.code)).size, businessDictionaryCatalog.length);
});

test('调和历史数据时恢复系统状态，并精确修正旧定时发布标签', () => {
  const state = createSeed();
  const systemType = state.dictTypes.find(type => type.code === 'todo_status');
  const systemItem = state.dictItems.find(item => item.typeCode === 'todo_status' && item.value === 'PENDING');
  const scheduled = state.dictItems.find(item => item.typeCode === 'announcement_status' && item.value === 'SCHEDULED');
  const customized = state.dictItems.find(item => item.typeCode === 'announcement_status' && item.value === 'DRAFT');
  const customTaskType = state.dictItems.find(item => item.typeCode === 'todo_task_type' && item.value === '材料补正');
  systemType.status = 'DISABLED';
  systemItem.status = 'DISABLED';
  scheduled.label = '定时发布(展示)';
  scheduled.status = 'DISABLED';
  customized.label = '本地草稿';
  customTaskType.status = 'DISABLED';

  const { state: reconciled } = reconcileBusinessDictionaries(state);
  assert.equal(reconciled.dictTypes.find(type => type.code === 'todo_status').status, 'ENABLED');
  assert.equal(reconciled.dictItems.find(item => item.typeCode === 'todo_status' && item.value === 'PENDING').status, 'ENABLED');
  assert.equal(reconciled.dictItems.find(item => item.typeCode === 'announcement_status' && item.value === 'SCHEDULED').label, '定时发布');
  assert.equal(reconciled.dictItems.find(item => item.typeCode === 'announcement_status' && item.value === 'SCHEDULED').status, 'ENABLED');
  assert.equal(reconciled.dictItems.find(item => item.typeCode === 'announcement_status' && item.value === 'DRAFT').label, '本地草稿');
  assert.equal(reconciled.dictItems.find(item => item.typeCode === 'todo_task_type' && item.value === '材料补正').status, 'DISABLED');
  assert.equal(systemType.status, 'DISABLED', '调和不应原地修改输入');
  assert.deepEqual(reconcileBusinessDictionaries(reconciled).state, reconciled);
});

test('系统受控类型和状态项不可停用，非法启用状态被拒绝', async () => {
  const service = createPortalService(createMockProvider(), () => actors[2]);
  const dictionary = await service.read('dictionaries');
  const systemType = dictionary.data.types.find(type => type.code === 'todo_status');
  const systemItem = dictionary.data.items.find(item => item.typeCode === 'todo_status' && item.value === 'PENDING');
  const historicalItem = dictionary.data.items.find(item => item.typeCode === 'todo_status' && item.value === 'EXPIRED');
  const customItem = dictionary.data.items.find(item => item.typeCode === 'todo_task_type' && item.value === '材料补正');

  assert.equal((await service.command('saveDictionaryType', { ...systemType, status: 'DISABLED' })).error?.code, 'INVALID_TRANSITION');
  assert.equal((await service.command('saveDictionaryItem', { ...systemItem, status: 'DISABLED' })).error?.code, 'INVALID_TRANSITION');
  assert.equal((await service.command('saveDictionaryItem', { ...historicalItem, status: 'DISABLED' })).error?.code, 'INVALID_TRANSITION');
  assert.equal((await service.command('saveDictionaryType', { ...systemType, status: 'UNKNOWN' })).error?.code, 'VALIDATION_ERROR');
  assert.equal((await service.command('saveDictionaryItem', { ...customItem, status: 'UNKNOWN' })).error?.code, 'VALIDATION_ERROR');

  const renamed = await service.command('saveDictionaryItem', { ...systemItem, label: '待我处理', sortOrder: 42 });
  assert.equal(renamed.ok, true, JSON.stringify(renamed));
  assert.equal(renamed.data.status, 'ENABLED');
  const disabled = await service.command('saveDictionaryItem', { ...customItem, status: 'DISABLED' });
  assert.equal(disabled.ok, true, JSON.stringify(disabled));
});

test('已被待办引用的任务类型不得改值、转类或删除', async () => {
  const service = createPortalService(createMockProvider(), () => actors[2]);
  const dictionary = await service.read('dictionaries');
  assert.equal(dictionary.ok, true);
  const item = dictionary.data.items.find(row => row.typeCode === 'todo_task_type' && row.value === '服务事项');
  assert(item);
  const modified = await service.command('saveDictionaryItem', { ...item, value: 'OTHER' });
  assert.equal(modified.error?.code, 'INVALID_TRANSITION');
  const moved = await service.command('saveDictionaryItem', { ...item, typeCode: 'announcement_type' });
  assert.equal(moved.error?.code, 'INVALID_TRANSITION');
  const removed = await service.command('removeDictionaryItem', { id: item.id, version: item.version });
  assert.equal(removed.error?.code, 'INVALID_TRANSITION');
});

test('受控状态项不能转入或转出自定义任务类型，任务类型改名可在公众侧读回', async () => {
  const provider = createMockProvider();
  let actor = actors[2];
  const service = createPortalService(provider, () => actor);
  const admin = await service.read('dictionaries');
  const todoState = admin.data.items.find(item => item.typeCode === 'todo_status' && item.value === 'PENDING');
  const taskType = admin.data.items.find(item => item.typeCode === 'todo_task_type' && item.value === '服务事项');
  assert.equal((await service.command('saveDictionaryItem', { ...todoState, typeCode: 'todo_task_type' })).error?.code, 'INVALID_TRANSITION');
  assert.equal((await service.command('saveDictionaryItem', { ...taskType, typeCode: 'todo_status' })).error?.code, 'INVALID_TRANSITION');
  const updated = await service.command('saveDictionaryItem', { ...taskType, label: '服务办理任务' });
  assert.equal(updated.ok, true, JSON.stringify(updated));
  actor = actors[0];
  const publicLookup = await service.read('lookupDictionaries');
  assert.equal(publicLookup.ok, true);
  assert.equal(publicLookup.data.items.find(item => item.typeCode === 'todo_task_type' && item.value === '服务事项').label, '服务办理任务');
});

test('页面按字典显示，停用自定义项仍可读，但不进入可选状态', () => {
  const previous = dictionaryLookups.value;
  try {
    dictionaryLookups.value = { types: [], items: [
      { typeCode: 'todo_status', value: 'PENDING', label: '待我处理', status: 'ENABLED', sortOrder: 2 },
      { typeCode: 'todo_status', value: 'COMPLETED', label: '已办结', status: 'ENABLED', sortOrder: 1 },
      { typeCode: 'todo_status', value: 'EXPIRED', label: '历史过期', status: 'ENABLED', sortOrder: 3 },
      { typeCode: 'todo_task_type', value: '服务事项', label: '业务服务', status: 'ENABLED', sortOrder: 1 },
      { typeCode: 'todo_task_type', value: '材料补正', label: '旧材料类型', status: 'DISABLED', sortOrder: 2 }
    ] };
    assert.equal(label('PENDING', 'todo_status'), '待我处理');
    assert.equal(label('EXPIRED', 'todo_status'), '历史过期');
    assert.equal(label('服务事项', 'todo_task_type'), '业务服务');
    assert.equal(label('材料补正', 'todo_task_type'), '旧材料类型');
    assert.deepEqual(dictionaryOptions('todo_status', ['PENDING', 'COMPLETED', 'EXPIRED', 'UNKNOWN']), [
      { value: 'COMPLETED', label: '已办结' },
      { value: 'PENDING', label: '待我处理' },
      { value: 'EXPIRED', label: '历史过期' }
    ]);
    assert.deepEqual(dictionaryOptions('todo_task_type', ['服务事项', '材料补正']), [{ value: '服务事项', label: '业务服务' }]);
    assert.deepEqual(dictionaryOptions('unloaded_type', ['PENDING']), [{ value: 'PENDING', label: '待处理' }]);
  } finally {
    dictionaryLookups.value = previous;
  }
});

test('待办推送任务类型缺省为服务事项，启用的字典类型可持久保留', async () => {
  const provider = createMockProvider();
  const service = createPortalService(provider, () => actors[2]);
  const base = { appId: 'MOCK_APP_1', userId: 'MOCK_USER_1', status: 'PENDING', title: '字典任务类型' };
  const legacy = await service.command('pushTodo', { ...base, sourceTodoId: 'DICT_DEFAULT', eventId: 'DICT_DEFAULT_E1' });
  assert.equal(legacy.ok, true, JSON.stringify(legacy));
  assert.equal(provider.read().todos.find(row => row.id === legacy.data.entityId).businessType, '服务事项');
  const custom = await service.command('pushTodo', { ...base, sourceTodoId: 'DICT_CUSTOM', eventId: 'DICT_CUSTOM_E1', businessType: '材料补正' });
  assert.equal(custom.ok, true, JSON.stringify(custom));
  assert.equal(provider.read().todos.find(row => row.id === custom.data.entityId).businessType, '材料补正');
});

test('未知或停用的待办任务类型不能用于新推送，同源事项不能改类型', async () => {
  const provider = createMockProvider();
  const service = createPortalService(provider, () => actors[2]);
  const base = { appId: 'MOCK_APP_1', userId: 'MOCK_USER_1', status: 'PENDING', title: '字典校验' };
  const unknown = await service.command('pushTodo', { ...base, sourceTodoId: 'DICT_UNKNOWN', eventId: 'DICT_UNKNOWN_E1', businessType: '不存在的类型' });
  assert.equal(unknown.error?.code, 'VALIDATION_ERROR');
  const dictionary = await service.read('dictionaries');
  const type = dictionary.data.items.find(row => row.typeCode === 'todo_task_type' && row.value === '材料补正');
  const disabled = await service.command('saveDictionaryItem', { ...type, status: 'DISABLED' });
  assert.equal(disabled.ok, true, JSON.stringify(disabled));
  const rejected = await service.command('pushTodo', { ...base, sourceTodoId: 'DICT_DISABLED', eventId: 'DICT_DISABLED_E1', businessType: '材料补正' });
  assert.equal(rejected.error?.code, 'VALIDATION_ERROR');
  const created = await service.command('pushTodo', { ...base, sourceTodoId: 'DICT_SAME', eventId: 'DICT_SAME_E1' });
  assert.equal(created.ok, true, JSON.stringify(created));
  const changed = await service.command('pushTodo', { ...base, sourceTodoId: 'DICT_SAME', eventId: 'DICT_SAME_E2', businessType: '审核审批' });
  assert.equal(changed.error?.code, 'INVALID_TRANSITION');
});

test('旧版未记录 businessType 的接收凭据可幂等重放，显式缺省类型等价', async () => {
  const provider = createMockProvider();
  const service = createPortalService(provider, () => actors[2]);
  const payload = { appId: 'MOCK_APP_1', userId: 'MOCK_USER_1', sourceTodoId: 'DICT_RECEIPT', eventId: 'DICT_RECEIPT_E1', status: 'PENDING', title: '旧凭据' };
  const first = await service.command('pushTodo', payload);
  assert.equal(first.ok, true, JSON.stringify(first));
  provider.transact(state => {
    const receipt = state.receipts.find(row => row.kind === 'TODO' && row.eventId === payload.eventId);
    const original = JSON.parse(receipt.payload);
    delete original.businessType;
    receipt.payload = JSON.stringify(original);
    return null;
  });
  const repeated = await service.command('pushTodo', { ...payload, businessType: '服务事项' });
  assert.equal(repeated.ok, true, JSON.stringify(repeated));
  assert.deepEqual(repeated.data, first.data);
  assert.equal(provider.read().todos.filter(row => row.sourceTodoId === payload.sourceTodoId).length, 1);
});

test('待办接入契约将任务类型设为可选字段，仍只允许三种 PUSH 状态', () => {
  const schema = publicContract().components.schemas.TODO;
  assert(schema.properties.businessType);
  assert.equal(schema.required.includes('businessType'), false);
  assert.deepEqual(schema.properties.status.enum, ['PENDING', 'COMPLETED', 'WITHDRAWN']);
});
