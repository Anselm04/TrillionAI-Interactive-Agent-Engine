import {DatabaseSync} from 'node:sqlite';
import {randomUUID} from 'node:crypto';
export class MemoryStore {
  #db;
  constructor(path){
    this.#db=new DatabaseSync(path);
    this.#db.exec('PRAGMA busy_timeout=5000; CREATE TABLE IF NOT EXISTS memory (tenant TEXT NOT NULL, id TEXT NOT NULL, content TEXT NOT NULL, created INTEGER NOT NULL, PRIMARY KEY(tenant,id));');
  }
  #tenant(tenant){if(typeof tenant!=='string'||!tenant.trim()||tenant.length>128)throw new Error('Invalid tenant');return tenant;}
  add(tenant,content){
    this.#tenant(tenant);
    if(typeof content!=='string'||!content.trim()||content.length>8000)throw new Error('Invalid memory');
    const id=randomUUID();
    this.#db.prepare('INSERT INTO memory VALUES(?,?,?,?)').run(tenant,id,content,Date.now());
    return id;
  }
  list(tenant,limit=50){
    this.#tenant(tenant);
    if(!Number.isInteger(limit)||limit<1||limit>100)throw new Error('Invalid limit');
    return this.#db.prepare('SELECT id,content,created FROM memory WHERE tenant=? ORDER BY created DESC,id LIMIT ?').all(tenant,limit);
  }
  delete(tenant,id){return this.#db.prepare('DELETE FROM memory WHERE tenant=? AND id=?').run(this.#tenant(tenant),id).changes===1;}
  clear(tenant){return this.#db.prepare('DELETE FROM memory WHERE tenant=?').run(this.#tenant(tenant)).changes;}
  close(){this.#db.close();}
}
