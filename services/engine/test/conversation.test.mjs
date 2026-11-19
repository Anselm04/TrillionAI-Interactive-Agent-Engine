import {test} from 'node:test';
import assert from 'node:assert/strict';
import {MemoryStore} from '../src/memory.mjs';
import {contextualProvider} from '../src/conversation.mjs';
test('conversation context stays within configured principal',async()=>{
 const memory=new MemoryStore(':memory:');
 try{
  memory.add('other','private');
  const provider=contextualProvider({memory,principal:'owner',provider:async prompt=>{
   const data=JSON.parse(prompt);assert.ok(!prompt.includes('private'));return data.history.length?'remembered':'first';
  }});
  assert.equal(await provider('hello'),'first');
  assert.equal(await provider('again'),'remembered');
  assert.equal(memory.list('owner').length,2);
  assert.equal(memory.list('other').length,1);
 }finally{memory.close();}
});
test('cancelled conversation is not stored',async()=>{
 const memory=new MemoryStore(':memory:');const c=new AbortController();
 try{
  const provider=contextualProvider({memory,principal:'owner',provider:async()=>{c.abort();return 'late';}});
  await assert.rejects(provider('hello',{signal:c.signal}));
  assert.equal(memory.list('owner').length,0);
 }finally{memory.close();}
});
