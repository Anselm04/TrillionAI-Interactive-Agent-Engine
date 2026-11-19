export class VoiceSession {
  #generation=0; #controller; #state='idle';
  get state(){return this.#state;}
  interrupt(){this.#generation++;this.#controller?.abort();this.#state='idle';}
  async run({audio,recognize,reason,synthesize,emit}){
    this.interrupt();
    const generation=this.#generation, controller=new AbortController();
    this.#controller=controller;
    const signal=controller.signal;
    const current=()=>generation===this.#generation&&!signal.aborted;
    const publish=(event)=>{if(current())emit(event);};
    try{
      this.#state='listening';
      const text=await recognize(audio,{signal});
      if(!current())return;
      publish({type:'transcript',text});
      this.#state='thinking';
      const reply=await reason(text,{signal});
      if(!current())return;
      publish({type:'reply',text:reply});
      this.#state='speaking';
      for await(const chunk of synthesize(reply,{signal})){
        if(!current())return;
        publish({type:'audio',chunk});
      }
      publish({type:'complete'});
    }finally{if(current())this.#state='idle';}
  }
}
