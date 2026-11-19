import {test} from 'node:test';
import assert from 'node:assert/strict';
import {ReasoningRegistry} from '../src/providers.mjs';
test('explicit provider selection and duplicate rejection',async()=>{
 const r=new ReasoningRegistry();
 r.register('a',{complete:async t=>'a:'+t});r.register('b',{complete:async t=>'b:'+t});
 assert.equal(await r.complete('b','hello'),'b:hello');
 assert.throws(()=>r.register('a',{complete:async()=>''}));
 await assert.rejects(r.complete('missing','hello'));
});
test('aborted provider calls reject',async()=>{
 const r=new ReasoningRegistry();r.register('local',{complete:async()=> 'reply'});
 const c=new AbortController();c.abort();
 await assert.rejects(r.complete('local','hello',{signal:c.signal}));
});
