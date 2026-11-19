import {test} from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync,rmSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {MemoryStore} from '../src/memory.mjs';
test('memory persists across reopen and prevents cross-tenant deletion',()=>{
 const dir=mkdtempSync(join(tmpdir(),'memory-'));let store;
 try{
  const path=join(dir,'memory.db');store=new MemoryStore(path);
  const id=store.add('a','remember this');store.add('b','private');
  assert.equal(store.delete('b',id),false);
  store.close();store=new MemoryStore(path);
  assert.equal(store.list('a')[0].content,'remember this');
  assert.equal(store.list('b')[0].content,'private');
  assert.equal(store.clear('a'),1);assert.equal(store.list('a').length,0);assert.equal(store.list('b').length,1);
 }finally{store?.close();rmSync(dir,{recursive:true,force:true});}
});
