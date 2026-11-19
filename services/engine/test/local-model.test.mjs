import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createLocalModel} from '../src/local-model.mjs';
test('local adapter sends real protocol request to loopback only',async()=>{
 const provider=createLocalModel({model:'example:latest',fetcher:async(url,options)=>{
  assert.equal(url,'http://127.0.0.1:11434/api/generate');assert.equal(options.redirect,'error');
  assert.equal(JSON.parse(options.body).prompt,'hello');
  return new Response(JSON.stringify({response:'answer',done:true}));
 }});
 assert.equal(await provider('hello'),'answer');
});
test('adapter rejects failed and incomplete responses',async()=>{
 for(const response of [new Response('bad',{status:503}),new Response('{"response":"x","done":false}')]){
  await assert.rejects(createLocalModel({model:'example',fetcher:async()=>response})('hello'));
 }
});
test('cancelled request never starts',async()=>{
 const controller=new AbortController();controller.abort();
 await assert.rejects(createLocalModel({model:'example',fetcher:async()=>assert.fail('unexpected network')})('hello',{signal:controller.signal}));
});
