import {randomUUID} from 'node:crypto';
export class AgentExecutor {
  #tools=new Map(); #pending=new Map();
  register(id,handler,{requiresApproval=true}={}){
    if(!/^[a-z][a-z0-9-]{0,63}$/.test(id)||typeof handler!=='function'||this.#tools.has(id))throw new Error('Invalid tool');
    this.#tools.set(id,{handler,requiresApproval});
  }
  propose({principal,tool,input,allowedTools}){
    const entry=this.#tools.get(tool);
    if(typeof principal!=='string'||!principal||!entry||!Array.isArray(allowedTools)||!allowedTools.includes(tool))throw new Error('Denied');
    if(this.#pending.size>=1000)throw new Error('Queue full');
    const id=randomUUID(), snapshot=structuredClone(input);
    this.#pending.set(id,{principal,tool,input:snapshot,approved:!entry.requiresApproval,expires:Date.now()+60000});
    return {id,requiresApproval:entry.requiresApproval};
  }
  approve(id,principal){
    const task=this.#pending.get(id);
    if(!task||task.principal!==principal||task.expires<Date.now())throw new Error('Denied');
    task.approved=true;
  }
  async execute(id,principal,{allowedTools}={}){
    const task=this.#pending.get(id);
    if(!task||task.principal!==principal||!task.approved||task.expires<Date.now()||!allowedTools?.includes(task.tool))throw new Error('Denied');
    this.#pending.delete(id);
    const signal=AbortSignal.timeout(10000);
    let abort;
    try{return await Promise.race([Promise.resolve().then(()=>this.#tools.get(task.tool).handler(task.input,{signal,principal})),new Promise((_,reject)=>{abort=()=>reject(signal.reason);signal.addEventListener('abort',abort,{once:true});})]);}
    finally{if(abort)signal.removeEventListener('abort',abort);}
  }
  prune(){for(const [id,task] of this.#pending)if(task.expires<Date.now())this.#pending.delete(id);}
}
