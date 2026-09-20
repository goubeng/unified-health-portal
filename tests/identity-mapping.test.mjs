import test from 'node:test';
import assert from 'node:assert/strict';
import {createMockProvider} from '../src/providers/mock.js';
import {createPortalService} from '../src/services/portal.js';
import {actors} from '../src/mock/seed.js';

// All fixtures and transactions stay in memory; no browser, storage or database.
function setup(prepare = () => {}) {
  const provider = createMockProvider();
  provider.transact(prepare);
  let actor = actors[2];
  const service = createPortalService(provider, () => actor);
  const success = result => { assert.equal(result.ok, true, JSON.stringify(result)); return result.data; };
  return {provider, service, success, switchActor: index => { actor = actors[index]; },
    read: async resource => success(await service.read(resource)),
    run: async (action, payload) => success(await service.command(action, payload))};
}

function mapping(id, userId, appId, status) {
  return {id, userId, appId, status, externalAccount: `account-${id}`, version: 1};
}

test('identityOverview按用户聚合所有子系统映射，区分来源/有效绑定/异常且保留零映射用户', async () => {
  const h = setup(d => {
    d.mappings = [
      mapping('I_BOUND_1', actors[0].id, 'MOCK_APP_1', 'BOUND'),
      mapping('I_BOUND_2', actors[0].id, 'MOCK_APP_2', 'BOUND'),
      mapping('I_CONFLICT', actors[0].id, 'MOCK_APP_3', 'CONFLICT'),
      mapping('I_FAILED', actors[0].id, 'MOCK_APP_4', 'FAILED'),
      mapping('I_UNBOUND', actors[0].id, 'MOCK_APP_5', 'UNBOUND'),
      mapping('I_GOV', actors[1].id, 'MOCK_APP_1', 'BOUND')
    ];
  });
  const before = h.provider.read();
  const rows = await h.read('identityOverview');
  assert.equal(rows.length, before.users.length, '每个用户只占一行，零映射用户仍保留');
  assert.equal(new Set(rows.map(row => row.id)).size, before.users.length);
  for (const user of before.users) {
    const row = rows.find(x => x.id === user.id);
    assert(row, `缺少用户 ${user.id}`);
    assert.equal(row.name, user.name);
    assert.equal(row.source, user.userType === 'GOV' ? '闽政务' : '闽政通');
    assert(Array.isArray(row.mappings), 'mappings必须为数组');
    const expected = before.mappings.filter(m => m.userId === user.id);
    assert.deepEqual(row.mappings.map(m => m.id).sort(), expected.map(m => m.id).sort());
    for (const entry of row.mappings) {
      const original = expected.find(m => m.id === entry.id);
      for (const key of ['userId', 'appId', 'status', 'externalAccount']) assert.equal(entry[key], original[key]);
    }
    assert.equal(row.boundCount, expected.filter(m => m.status === 'BOUND').length);
    assert.equal(row.exceptionCount, expected.filter(m => ['CONFLICT', 'FAILED'].includes(m.status)).length);
  }
  assert.equal(rows.find(x => x.id === actors[0].id).boundCount, 2);
  assert.equal(rows.find(x => x.id === actors[0].id).exceptionCount, 2);
  assert.deepEqual(h.provider.read(), before, '聚合读取不得修改底层映射');
});

test('identityOverview供身份管理员读取，普通用户和仅公告管理员不可读取', async () => {
  const h = setup(d => {
    const user = d.users.find(x => x.id === actors[3].id);
    user.scopes = ['identity'];
    user.roleIds = ['ROLE_IDENTITY'];
  });
  h.switchActor(3);
  assert.equal((await h.read('identityOverview')).length, h.provider.read().users.length);
  h.switchActor(0);
  assert.equal((await h.service.read('identityOverview')).error?.code, 'FORBIDDEN');
  const editor = setup();
  editor.switchActor(3);
  assert.equal((await editor.service.read('identityOverview')).error?.code, 'FORBIDDEN');
});

test('identityOverview解绑后更新聚合计数，保留映射历史且不影响其他用户', async () => {
  const h = setup();
  const before = await h.read('identityOverview');
  const user = before.find(x => x.id === actors[0].id);
  assert(user && Array.isArray(user.mappings));
  const bound = user.mappings.find(m => m.status === 'BOUND');
  assert(bound);
  await h.run('unbind', {id: bound.id, version: bound.version});
  const after = await h.read('identityOverview');
  const updated = after.find(x => x.id === user.id);
  assert.equal(updated.boundCount, user.boundCount - 1);
  assert.equal(updated.exceptionCount, user.exceptionCount);
  assert.equal(updated.mappings.length, user.mappings.length);
  assert.equal(updated.mappings.find(m => m.id === bound.id).status, 'UNBOUND');
  assert.deepEqual(after.filter(x => x.id !== user.id), before.filter(x => x.id !== user.id));
});

for (const action of ['pushTodo', 'pushMessage']) {
  const payload = {appId: 'MOCK_APP_1', userId: actors[0].id, eventId: `identity-${action}`,
    title: '身份门禁测试', ...(action === 'pushTodo'
      ? {sourceTodoId: 'identity-todo', sourceRevision: 1, status: 'PENDING'}
      : {sourceMessageId: 'identity-message', content: '仅内存测试'})};

  for (const status of ['ABSENT', 'UNBOUND', 'CONFLICT', 'FAILED']) {
    test(`${action}拒绝${status}映射；他人同应用/本人其他应用BOUND不能代替`, async () => {
      const h = setup(d => {
        d.mappings = [
          mapping('OTHER_USER', actors[1].id, payload.appId, 'BOUND'),
          mapping('OTHER_APP', payload.userId, 'MOCK_APP_2', 'BOUND'),
          ...(status === 'ABSENT' ? [] : [mapping('TARGET', payload.userId, payload.appId, status)])
        ];
      });
      const before = h.provider.read();
      const result = await h.service.command(action, payload);
      assert.equal(result.ok, false, `${status}不得新增业务记录`);
      assert.equal(result.error.code, 'IDENTITY_UNRESOLVED');
      assert.deepEqual(h.provider.read(), before, '拒绝后业务/映射/幂等凭据均不改变');
    });
  }

  test(`${action}本人本应用BOUND允许新增且重试只保留一份记录`, async () => {
    const h = setup(d => { d.mappings = [mapping('TARGET', payload.userId, payload.appId, 'BOUND')]; });
    const resource = action === 'pushTodo' ? 'todos' : 'messages';
    const before = h.provider.read();
    const receipt = await h.run(action, payload);
    assert.deepEqual(await h.run(action, payload), receipt);
    const after = h.provider.read();
    assert.equal(after[resource].length, before[resource].length + 1);
    assert.equal(after.receipts.length, before.receipts.length + 1);
    const row = after[resource].find(x => x.id === receipt.entityId);
    assert.equal(row.userId, payload.userId);
    assert.equal(row.appId, payload.appId);
    assert.deepEqual(after.mappings, before.mappings);
  });

  test(`${action}不存在的统一身份即使有孤立BOUND记录仍拒绝`, async () => {
    const userId = 'IDENTITY_MISSING_USER';
    const h = setup(d => { d.mappings = [mapping('ORPHAN', userId, payload.appId, 'BOUND')]; });
    const before = h.provider.read();
    const result = await h.service.command(action, {...payload, userId});
    assert.equal(result.error?.code, 'IDENTITY_UNRESOLVED');
    assert.deepEqual(h.provider.read(), before);
  });
}
