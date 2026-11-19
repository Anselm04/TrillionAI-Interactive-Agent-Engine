import {test} from 'node:test';
import assert from 'node:assert/strict';
import {AudioProtocol} from '../src/audio-protocol.mjs';
test('PCM offsets and interrupted turns',()=>{
 const p=new AudioProtocol();p.start('a');
 assert.equal(p.accept({turn:'a',sequence:0,pcm:Buffer.alloc(640)}).offsetMs,0);
 assert.equal(p.accept({turn:'a',sequence:1,pcm:Buffer.alloc(640)}).offsetMs,20);
 assert.throws(()=>p.accept({turn:'a',sequence:1,pcm:Buffer.alloc(640)}));
 p.interrupt();assert.throws(()=>p.accept({turn:'a',sequence:2,pcm:Buffer.alloc(640)}));
 p.start('b');assert.throws(()=>p.accept({turn:'a',sequence:0,pcm:Buffer.alloc(640)}));
});
