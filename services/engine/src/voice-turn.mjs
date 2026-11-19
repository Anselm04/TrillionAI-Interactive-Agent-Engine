import {randomUUID} from 'node:crypto';
/** Transport-independent single active turn controller. */
export class VoiceTurn {
  #active=null;
  begin(){
    this.interrupt('superseded');
    const controller=new AbortController(),id=randomUUID();
    this.#active={id,controller};
    return {id,signal:controller.signal};
  }
  current(id){return this.#active?.id===id&&!this.#active.controller.signal.aborted;}
  interrupt(reason='interrupted'){
    const turn=this.#active;
    this.#active=null;
    if(turn)turn.controller.abort(new Error(reason));
    return turn?.id??null;
  }
  finish(id){if(!this.current(id))return false;this.#active=null;return true;}
}
