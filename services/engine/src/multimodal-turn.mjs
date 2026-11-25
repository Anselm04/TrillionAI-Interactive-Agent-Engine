export class MultimodalTurn{
 #id=null;#next=0;#bytes=0;
 start(id){if(this.#id!==null||typeof id!=='string'||!/^[a-zA-Z0-9_-]{1,64}$/.test(id))throw Error('invalid turn');this.#id=id;this.#next=0;this.#bytes=0;}
 accept({turn,sequence,kind,payload}){if(this.#id===null||turn!==this.#id||sequence!==this.#next||!['text','audio','image'].includes(kind))throw Error('invalid frame');
 const valid=kind==='text'?typeof payload==='string'&&payload.trim().length>0:Buffer.isBuffer(payload)&&payload.length>0;
 if(!valid)throw Error('invalid payload');const size=typeof payload==='string'?Buffer.byteLength(payload):payload.length;
 const limit=kind==='text'?8000:kind==='audio'?6400:1000000;
 if(size>limit||this.#bytes+size>2000000||this.#next>=1000)throw Error('turn budget exceeded');
 this.#bytes+=size;this.#next++;return {turn,sequence,kind,bytes:size,providerExecuted:false};}
 interrupt(){this.#id=null;this.#next=0;this.#bytes=0;}
}
