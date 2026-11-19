import {test} from 'node:test';
import assert from 'node:assert/strict';
import {VoiceTurn} from '../src/voice-turn.mjs';
test('new speech cancels previous turn and rejects stale output',()=>{
 const t=new VoiceTurn(),a=t.begin(),b=t.begin();
 assert.equal(a.signal.aborted,true);
 assert.equal(t.current(a.id),false);
 assert.equal(t.finish(a.id),false);
 assert.equal(t.current(b.id),true);
 assert.equal(t.interrupt(),b.id);
 assert.equal(b.signal.aborted,true);
 assert.equal(t.finish(b.id),false);
});
test('successful turn completes once',()=>{
 const t=new VoiceTurn(),a=t.begin();
 assert.equal(t.finish(a.id),true);
 assert.equal(t.finish(a.id),false);
 assert.equal(t.interrupt(),null);
});
