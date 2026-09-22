import test from 'node:test';
import assert from 'node:assert/strict';
import {Readable} from 'node:stream';
import {createMockProvider} from '../src/providers/mock.js';
import {createPortalApi} from '../server/api.mjs';
import {actors} from '../src/mock/seed.js';
import {rules} from '../src/config/rules.js';

// Invoke the real handler without a socket; repository and credentials are test-only.
function setup(prepare = () => {}) {
  let state = createMockProvider().read(), version = 1, cookie = '';
  prepare(state);
  const events = [];
  const repository = {
    async load() { return {state: structuredClone(state), version}; },
    async commit(before, after, expectedVersion, event) {
      assert.equal(expectedVersion, version);
      assert.deepEqual(before, state);
      state = structuredClone(after);
      events.push(structuredClone(event));
      version++;
    },
    async logs(kind) { return structuredClone(events.filter(e => e.kind.toLowerCase() === kind)); }
  };
  const api = createPortalApi({repository, env: {PORTAL_P5_TEST: 'memory-only'}});
  async function request(path, payload, headers = {}) {
    const req = Readable.from(payload === undefined ? [] : [JSON.stringify(payload)]);
    Object.assign(req, {url: '/api/portal/' + path, method: payload === undefined ? 'GET' : 'POST',
      headers: {host: 'localhost:4011', origin: 'http://localhost:4010', cookie, ...headers}});
    let status, result;
    const responseHeaders = {};
    const res = {
      setHeader(k, v) { responseHeaders[k] = v; },
      writeHead(code) { status = code; this.headersSent = true; },
      end(text) { result = JSON.parse(text); }
    };
    await api.handle(req, res);
    if (responseHeaders['Set-Cookie']) cookie = responseHeaders['Set-Cookie'].split(';')[0];
    assert.notEqual(status, 503, JSON.stringify(result));
    assert.equal(typeof result?.ok, 'boolean');
    return result;
  }
  const success = result => { assert.equal(result.ok, true, JSON.stringify(result)); return result.data; };
  const command = (action, payload) => request('command', {action, payload});
  return {
    events, snapshot: () => structuredClone(state), request, command, success,
    login: async index => success(await request('session', {userId: actors[index].id})),
    read: async resource => success(await request('read?resource=' + encodeURIComponent(resource))),
    run: async (action, payload) => success(await command(action, payload)),
    async reject(action, payload, code) {
      const before = structuredClone(state);
      const result = await command(action, payload);
      assert.equal(result.ok, false);
      assert.equal(result.error.code, code);
      assert.deepEqual(state, before, '失败操作不得修改业务状态');
    }
  };
}

test('P5 公众/政务应用范围、当前会话与审计身份随切换更新', async () => {
  const h = setup();
  for (const index of [0, 1]) {
    await h.login(index);
    const actor = actors[index];
    const expected = h.snapshot().apps.filter(a => a.enabled !== false && ['BOTH', actor.userType].includes(a.userType));
    assert.deepEqual((await h.read('apps')).map(a => a.id), expected.map(a => a.id));
    assert.equal((await h.read('profile')).id, actor.id);
    const app = (await h.read('mine')).find(a => a.mappingStatus === 'BOUND' && a.ssoRuntimeStatus === 'NORMAL');
    await h.run('enterApp', {id: app.id});
    const event = h.events.at(-1);
    assert.equal(event.actorId, actor.id);
    assert.equal(event.actorKind, 'USER');
    assert.equal(event.appId, app.id);
    assert.equal(event.objectId, app.id);
    assert.equal(event.kind, 'ACCESS');
    assert.equal(event.result, 'SUCCESS');
  }
  const switchEvent = h.events.find(e => e.action === 'SWITCH_USER');
  assert.equal(switchEvent.actorId, actors[1].id);
  assert.equal(switchEvent.details.previousActor, actors[0].id);
  await h.login(2);
  assert.equal((await h.read('adminApps')).length, h.snapshot().apps.length);
  assert.equal((await h.read('logs:access')).length, 2);
});

test('P5 未关联应用关联后进入并出现在我的应用，跨范围关联被拒绝', async () => {
  const h = setup();
  await h.login(0);
  const app = (await h.read('apps')).find(a => a.mappingStatus === 'UNBOUND' && a.ssoRuntimeStatus === 'NORMAL');
  assert(app, '必须存在未关联应用测试样本');
  await h.reject('enterApp', {id: app.id}, 'ACCOUNT_BINDING_REQUIRED');
  const mapping = await h.run('bind', {appId: app.id, externalAccount: 'p5-citizen-account'});
  assert.equal(mapping.userId, actors[0].id);
  assert.equal(mapping.status, 'BOUND');
  const entered = await h.run('enterApp', {id: app.id});
  assert.equal(entered.url, app.url);
  assert.equal(entered.mode, 'MOCK');
  assert((await h.read('mine')).some(a => a.id === app.id));
  assert(h.snapshot().visits.some(v => v.appId === app.id && v.userId === actors[0].id));
  const govApp = h.snapshot().apps.find(a => a.userType === 'GOV' && a.enabled !== false);
  await h.reject('bind', {appId: govApp.id, externalAccount: 'p5-forbidden'}, 'FORBIDDEN');
});

async function enablePush(h, kind, appId='MOCK_APP_1') {
  await h.login(2);
  const config = h.snapshot().integrations.find(c => c.kind === kind && c.appId === appId);
  assert(config);
  await h.run('saveIntegration', {...config, enabled: 'ENABLED', mode: 'PUSH', credentialRef: 'PORTAL_P5_TEST', fieldMapping: {title: 'subject'}});
  return payload => h.request(`ingest/${config.appId}/${kind === 'TODO' ? 'todos' : 'messages'}`, payload,
    {authorization: 'Bearer memory-only', cookie: ''});
}

test('P5 接入保存→消息推送→本人读取→重复推送保持已读及应用审计', async () => {
  const h = setup(), push = await enablePush(h, 'MESSAGE');
  await h.login(0);
  const before = (await h.read('home')).unreadCount;
  const payload = {eventId: 'p5-message-event', sourceMessageId: 'p5-message', userId: actors[0].id, subject: 'P5消息', content: '内存闭环'};
  const receipt = h.success(await push(payload));
  assert.equal(h.events.at(-1).actorKind, 'APPLICATION');
  assert.equal(h.events.at(-1).actorId, null);
  assert.equal(h.events.at(-1).appId, 'MOCK_APP_1');
  assert.equal((await h.read('home')).unreadCount, before + 1);
  const message = (await h.read('messages')).find(m => m.id === receipt.entityId);
  assert.equal(message.title, payload.subject);
  const read = await h.run('markRead', {id: message.id});
  assert.equal(read.status, 'READ');
  assert(read.readAt);
  assert.deepEqual(await h.run('markRead', {id: message.id}), read);
  assert.deepEqual(h.success(await push(payload)), receipt);
  assert.equal((await h.read('home')).unreadCount, before);
  assert.equal((await h.read('messages')).filter(m => m.sourceMessageId === payload.sourceMessageId).length, 1);
  await h.login(1);
  assert(!(await h.read('messages')).some(m => m.id === message.id));
  await h.reject('markRead', {id: message.id}, 'NOT_FOUND');
});

for (const terminal of ['COMPLETED', 'WITHDRAWN']) {
  test(`P5 待办推送→去处理→${terminal}终态与重试/回退保护`, async () => {
    const h = setup(d => {
      const sso=d.integrations.find(item=>item.appId==='MOCK_APP_1'&&item.kind==='SSO');
      Object.assign(sso,{runtimeStatus:'NORMAL',configStatus:'CONFIGURED',enabled:'ENABLED'});
    }), push = await enablePush(h, 'TODO');
    await h.login(0);
    const before = (await h.read('home')).todoCount;
    const payload = {eventId: 'p5-todo-1', sourceTodoId: 'p5-todo', userId: actors[0].id, status: 'PENDING', subject: 'P5待办'};
    const receipt = h.success(await push(payload));
    assert.equal((await h.read('home')).todoCount, before + 1);
    await h.run('openTodo', {id: receipt.entityId});
    assert.equal((await h.read('todos')).find(t => t.id === receipt.entityId).status, 'PENDING');
    const finalPayload = {...payload, eventId: 'p5-todo-2', status: terminal};
    const finalReceipt = h.success(await push(finalPayload));
    assert.deepEqual(h.success(await push(finalPayload)), finalReceipt);
    assert.equal((await h.read('todos')).find(t => t.id === receipt.entityId).status, terminal);
    assert.equal((await h.read('home')).todoCount, before);
    await h.reject('openTodo', {id: receipt.entityId}, 'INVALID_TRANSITION');
    const snapshot = h.snapshot();
    assert.equal((await push({...payload, eventId: 'p5-todo-3'})).error.code, 'INVALID_TRANSITION');
    assert.deepEqual(h.snapshot(), snapshot);
    await h.login(1);
    assert(!(await h.read('todos')).some(t => t.id === receipt.entityId));
  });
}

test('P5 公告创建/发布/本人阅读/撤回/删除闭环', async () => {
  const h = setup();
  await h.login(2);
  const input = {title: 'P5公告', content: '测试正文', scope: 'CITIZEN'};
  const draft = await h.run('saveAnnouncement', input);
  assert.equal(draft.status, 'DRAFT');
  await h.login(0);
  assert(!(await h.read('announcements')).some(a => a.id === draft.id));
  await h.login(2);
  const published = await h.run('publish', {id: draft.id, version: draft.version});
  assert.equal(published.status, 'PUBLISHED');
  await h.reject('removeAnnouncement', published, 'INVALID_TRANSITION');
  await h.login(0);
  assert.equal((await h.read('announcements')).find(a => a.id === draft.id).readStatus, 'UNREAD');
  const unread = (await h.read('home')).unreadAnnouncementCount;
  const receipt = await h.run('markAnnouncementRead', {id: draft.id});
  assert.equal(receipt.userId, actors[0].id);
  assert.deepEqual(await h.run('markAnnouncementRead', {id: draft.id}), receipt);
  assert.equal((await h.read('home')).unreadAnnouncementCount, unread - 1);
  await h.login(1);
  assert(!(await h.read('announcements')).some(a => a.id === draft.id));
  await h.reject('markAnnouncementRead', {id: draft.id}, 'NOT_FOUND');
  await h.login(2);
  const withdrawn = await h.run('withdraw', {id: draft.id, version: published.version});
  assert.equal(withdrawn.status, 'WITHDRAWN');
  await h.run('removeAnnouncement', withdrawn);
  assert(!(await h.read('adminAnnouncements')).some(a => a.id === withdrawn.id));
  assert(h.snapshot().announcementTrash.some(a => a.id === withdrawn.id && a.status === 'WITHDRAWN'));
  const disposable = await h.run('saveAnnouncement', {...input, title: 'P5待删除草稿'});
  await h.run('removeAnnouncement', disposable);
  assert(!(await h.read('adminAnnouncements')).some(a => a.id === disposable.id));
  assert(h.snapshot().announcementTrash.some(a => a.id === disposable.id && a.deletedBy === actors[2].id));
  await h.login(0);
  assert(!(await h.read('announcements')).some(a => a.id === draft.id));
  await h.reject('markAnnouncementRead', {id: draft.id}, 'NOT_FOUND');
});

test('P5 全量规则保存读回与非法值原子回滚，接入配置保存读回', async () => {
  const h = setup();
  await h.login(2);
  const settings = await h.read('settings');
  const items = rules.map(rule => ({...settings.find(s => s.code === rule.code), value: rule.default}));
  await h.run('saveRules', {items});
  const saved = await h.read('settings');
  for (const item of items) assert.equal(saved.find(s => s.code === item.code).value, item.value);
  await h.reject('saveRules', {items}, 'VERSION_CONFLICT');
  const current = rules.map(rule => saved.find(s => s.code === rule.code));
  await h.reject('saveRules', {items: current.map((item, i) => ({...item,
    value: i === current.length - 1 ? rules[i].min - 1 : rules[i].max}))}, 'VALIDATION_ERROR');
  await h.reject('saveRules', {items: current.slice(1)}, 'VALIDATION_ERROR');
  await h.reject('saveRules', {items: current.map((item, i) => i === current.length - 1 ? current[0] : item)}, 'VALIDATION_ERROR');
  const config = (await h.read('sso'))[0];
  const updated = await h.run('saveIntegration', {...config, enabled: 'DISABLED', protocol: 'OIDC', clientId: 'p5-prototype', credentialRef: '', fieldMapping: {}});
  assert.equal(updated.runtimeStatus, 'DISABLED');
  assert.equal((await h.read('sso')).find(c => c.id === config.id).clientId, 'p5-prototype');
  assert.equal(h.events.at(-1).actorId, actors[2].id);
  await h.login(0);
  await h.reject('saveRules', {items}, 'FORBIDDEN');
  await h.reject('saveIntegration', updated, 'FORBIDDEN');
});

test('P5 消息批量已读/全部已读/删除仅影响本人，混入他人或不存在ID原子拒绝', async () => {
  const h = setup();
  await h.login(0);
  const own = await h.read('messages');
  const unread = own.filter(m => m.status === 'UNREAD');
  assert(unread.length >= 3, '需要至少三条未读消息覆盖选择与剩余消息');
  const foreign = h.snapshot().messages.filter(m => m.userId !== actors[0].id);
  assert(foreign.length);
  const selected = unread.slice(0, 2).map(m => m.id);
  const before = (await h.read('home')).unreadCount;
  for (const action of ['markMessagesRead', 'deleteMessages']) {
    await h.reject(action, {ids: []}, 'VALIDATION_ERROR');
    await h.reject(action, {ids: [selected[0], foreign[0].id]}, 'NOT_FOUND');
    await h.reject(action, {ids: [selected[0], 'P5_MISSING_MESSAGE']}, 'NOT_FOUND');
  }
  assert.equal((await h.run('markMessagesRead', {ids: [...selected, selected[0]]})).count, 2);
  assert.equal((await h.read('home')).unreadCount, before - 2);
  const read = (await h.read('messages')).filter(m => selected.includes(m.id));
  assert(read.every(m => m.status === 'READ' && m.readAt));
  assert.equal((await h.run('markMessagesRead', {ids: selected})).count, 0);
  assert.deepEqual((await h.read('messages')).filter(m => selected.includes(m.id)), read);
  assert.equal((await h.run('markAllMessagesRead')).count, before - 2);
  assert.equal((await h.read('home')).unreadCount, 0);
  assert.equal((await h.run('markAllMessagesRead')).count, 0);
  assert.deepEqual((await h.read('messages')).filter(m => selected.includes(m.id)), read);
  assert.equal((await h.run('deleteMessages', {ids: [...selected, selected[0]]})).count, 2);
  assert.deepEqual((await h.read('messages')).map(m => m.id), own.filter(m => !selected.includes(m.id)).map(m => m.id));
  await h.reject('markRead', {id: selected[0]}, 'NOT_FOUND');
  assert.deepEqual(h.snapshot().messages.filter(m => m.userId !== actors[0].id), foreign);
  await h.login(1);
  assert.deepEqual(await h.read('messages'), foreign.filter(m => m.userId === actors[1].id));
});

test('P5 我的应用与待办按当前用户可用范围隔离，客户端userId不能改变会话身份', async () => {
  const h = setup(d => { d.visits = []; });
  for (const index of [0, 1]) {
    await h.login(index);
    const actor = actors[index], d = h.snapshot();
    const mine = await h.read('mine');
    assert(mine.length>0);
    assert(mine.every(app=>app.enabled&&app.applicable&&['BOTH',actor.userType].includes(app.userType)));
    const directIds=d.apps.filter(app=>app.enabled!==false&&['BOTH',actor.userType].includes(app.userType)&&app.accessMode==='DIRECT').map(app=>app.id);
    for(const id of directIds)assert(mine.some(app=>app.id===id),'DIRECT应用应进入我的应用');
    assert.deepEqual(await h.read('todos'), d.todos.filter(t => t.userId === actor.id));
    const foreign = d.todos.find(t => t.userId !== actor.id && t.status === 'PENDING');
    assert(foreign);
    await h.reject('openTodo', {id: foreign.id, userId: foreign.userId}, 'NOT_FOUND');
    const forbidden = await h.request('read?resource=adminApps');
    assert.equal(forbidden.error?.code, 'FORBIDDEN');
  }
});

test('P5 全范围公告阅读凭据按用户独立，未生效/过期公告不可读', async () => {
  const h = setup(d => {
    const base = {version: 1, title: '时间范围公告', content: '测试', scope: 'ALL', status: 'PUBLISHED'};
    d.announcements.push(
      {...base, id: 'P5_FUTURE', effectiveStart: '2999-01-01T00:00:00Z'},
      {...base, id: 'P5_EXPIRED', effectiveEnd: '2000-01-01T00:00:00Z'});
  });
  await h.login(2);
  const draft = await h.run('saveAnnouncement', {title: '全范围阅读隔离', content: '正文', scope: 'ALL'});
  await h.run('publish', {id: draft.id, version: draft.version});
  for (const index of [0, 1]) {
    await h.login(index);
    assert.equal((await h.read('announcements')).find(a => a.id === draft.id).readStatus, 'UNREAD');
    const before = (await h.read('home')).unreadAnnouncementCount;
    const receipt = await h.run('markAnnouncementRead', {id: draft.id});
    assert.equal(receipt.userId, actors[index].id);
    assert.equal((await h.read('home')).unreadAnnouncementCount, before - 1);
    for (const id of ['P5_FUTURE', 'P5_EXPIRED']) {
      assert(!(await h.read('announcements')).some(a => a.id === id));
      await h.reject('markAnnouncementRead', {id}, 'NOT_FOUND');
    }
    await h.reject('publish', {id: draft.id}, 'FORBIDDEN');
  }
  assert.equal(h.snapshot().announcementReads.filter(r => r.announcementId === draft.id).length, 2);
});

for (const kind of ['TODO', 'MESSAGE']) {
  test(`P5 ${kind} PUSH对需绑定应用执行映射门禁，绑定后同一事件可新增`, async () => {
    const appId='MOCK_APP_3';
    const h = setup(d => { d.mappings = d.mappings.filter(m => !(m.userId === actors[0].id && m.appId === appId)); });
    const push = await enablePush(h, kind, appId);
    const payload = {eventId: `p5-unmapped-${kind}`, userId: actors[0].id, subject: '映射门禁',
      ...(kind === 'TODO' ? {sourceTodoId: 'p5-unmapped-todo', status: 'PENDING'}
        : {sourceMessageId: 'p5-unmapped-message', content: '映射门禁消息'})};
    const before = h.snapshot();
    const rejected = await push(payload);
    assert.equal(rejected.ok, false, '需绑定应用没有本应用BOUND映射时不得新增');
    assert.equal(rejected.error.code, 'IDENTITY_UNRESOLVED');
    assert.deepEqual(h.snapshot(), before, '拒绝推送不得写业务记录或幂等凭据');
    assert.equal(h.events.at(-1).result, 'FAILURE');
    await h.login(0);
    await h.run('bind', {appId, externalAccount: `p5-bound-${kind}`});
    const receipt = h.success(await push(payload));
    const resource = kind === 'TODO' ? 'todos' : 'messages';
    const row = (await h.read(resource)).find(x => x.id === receipt.entityId);
    assert.equal(row.userId, actors[0].id);
    assert.equal(row.appId, appId);
    assert.deepEqual(h.success(await push(payload)), receipt);
    assert.equal((await h.read(resource)).filter(x => x.id === receipt.entityId).length, 1);
  });
}