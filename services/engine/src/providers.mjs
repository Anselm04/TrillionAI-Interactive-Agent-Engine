export class ReasoningRegistry {
  #providers=new Map();
  register(id,provider){
    if(!/^[a-z][a-z0-9-]{0,63}$/.test(id)||typeof provider?.complete!=='function'||this.#providers.has(id))throw new Error('Invalid or duplicate provider');
    this.#providers.set(id,provider);
  }
  async complete(id,text,{signal}={}){
    const provider=this.#providers.get(id);
    if(!provider)throw new Error('Unknown provider');
    if(typeof text!=='string'||!text.trim()||text.length>8000)throw new Error('Invalid input');
    const deadline=AbortSignal.timeout(10000);
    const combined=signal?AbortSignal.any([signal,deadline]):deadline;
    combined.throwIfAborted();
    let abort;
    try{
      const result=await Promise.race([Promise.resolve().then(()=>provider.complete(text,{signal:combined})),new Promise((_,reject)=>{abort=()=>reject(combined.reason);combined.addEventListener('abort',abort,{once:true});if(combined.aborted)abort();})]);
      combined.throwIfAborted();
      if(typeof result!=='string'||result.length>16000)throw new Error('Invalid provider response');
      return result;
    }finally{if(abort)combined.removeEventListener('abort',abort);}
  }
}
