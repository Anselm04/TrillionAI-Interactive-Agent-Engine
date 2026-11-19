// Transport-neutral PCM16 frame protocol. No device or network transport is implied.
export class AudioProtocol {
 #turn=null; #next=0; #samples=0;
 start(id){if(typeof id!=='string'||!id||id.length>64)throw new Error('Invalid turn');this.#turn=id;this.#next=0;this.#samples=0;}
 accept({turn,sequence,pcm}){
  if(turn!==this.#turn||this.#turn===null||sequence!==this.#next||!Buffer.isBuffer(pcm)||pcm.length===0||pcm.length>6400||pcm.length%2)throw new Error('Invalid audio frame');
  if(this.#samples+pcm.length/2>16000*60)throw new Error('Audio budget exceeded');
  const offsetMs=this.#samples/16;this.#samples+=pcm.length/2;this.#next++;
  return {turn,sequence,offsetMs,pcm:Buffer.from(pcm)};
 }
 interrupt(){this.#turn=null;this.#next=0;this.#samples=0;}
}
