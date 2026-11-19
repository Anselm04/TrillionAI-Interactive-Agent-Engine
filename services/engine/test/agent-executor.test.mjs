import {test} from 'node:test';
import assert from 'node:assert/strict';
import {AgentExecutor} from '../src/agent-executor.mjs';
test('tool authorization, approval, principal binding and single use',async()=>{
 const e=new AgentExecutor();let calls=0;
 e.register('example',async input=>{calls++;return input;});
 assert.throws(()=>e.propose({principal:'a',tool:'example',input:1,allowedTools:[]}));
 const {id}=e.propose({principal:'a',tool:'example',input:1,allowedTools:['example']});
 await assert.rejects(e.execute(id,'a',{allowedTools:['example']}));
 assert.throws(()=>e.approve(id,'b'));e.approve(id,'a');
 await assert.rejects(e.execute(id,'a',{allowedTools:[]}));
 assert.equal(await e.execute(id,'a',{allowedTools:['example']}),1);
 await assert.rejects(e.execute(id,'a',{allowedTools:['example']}));
 assert.equal(calls,1);
});
