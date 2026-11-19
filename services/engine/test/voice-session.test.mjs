import {test} from 'node:test';
import assert from 'node:assert/strict';
import {VoiceSession} from '../src/voice-session.mjs';
test('voice session emits ordered transcript, reply and audio',async()=>{
 const s=new VoiceSession(),events=[];
 await s.run({audio:Buffer.from('test'),recognize:async()=> 'hello',reason:async()=> 'reply',synthesize:async function*(){yield Buffer.from('audio');},emit:e=>events.push(e)});
 assert.deepEqual(events.map(e=>e.type),['transcript','reply','audio','complete']);
 assert.equal(s.state,'idle');
});
test('interruption prevents stale audio delivery',async()=>{
 const s=new VoiceSession(),events=[];
 await s.run({audio:null,recognize:async()=> 'hello',reason:async()=> 'reply',synthesize:async function*(){yield 'first';s.interrupt();yield 'stale';},emit:e=>events.push(e)});
 assert.deepEqual(events.filter(e=>e.type==='audio').map(e=>e.chunk),['first']);
 assert.equal(s.state,'idle');
});
