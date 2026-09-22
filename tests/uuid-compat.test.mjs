import test from 'node:test';
import assert from 'node:assert/strict';
import {createUUID} from '../src/utils/uuid.js';

const UUID_V4=/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

test('createUUID prefers native randomUUID when available',()=>{
  assert.equal(createUUID({randomUUID:()=> 'native-uuid'}),'native-uuid');
});

test('createUUID works when randomUUID is unavailable but getRandomValues exists',()=>{
  const cryptoApi={getRandomValues(bytes){for(let i=0;i<bytes.length;i++)bytes[i]=i;return bytes;}};
  const value=createUUID(cryptoApi);
  assert.equal(value,'00010203-0405-4607-8809-0a0b0c0d0e0f');
  assert.match(value,UUID_V4);
});

test('createUUID keeps a UUID v4 shaped fallback without Web Crypto',()=>{
  assert.match(createUUID(null),UUID_V4);
});
