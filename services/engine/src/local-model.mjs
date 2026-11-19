/** Opt-in Ollama-compatible inference; never falls back to a cloud endpoint. */
export function createLocalModel({model,port=11434,fetcher=fetch}={}){
 if(typeof model!=='string'||!/^[a-zA-Z0-9][a-zA-Z0-9._:/-]{0,127}$/.test(model))throw new Error('Invalid model');
 if(!Number.isInteger(port)||port<1||port>65535)throw new Error('Invalid port');
 return async (text,{signal}={})=>{
  if(typeof text!=='string'||!text.trim()||text.length>8000)throw new Error('Invalid prompt');
  const deadline=AbortSignal.timeout(9000), combined=signal?AbortSignal.any([signal,deadline]):deadline;
  combined.throwIfAborted();
  const res=await fetcher('http://127.0.0.1:'+port+'/api/generate',{method:'POST',redirect:'error',signal:combined,headers:{'Content-Type':'application/json'},body:JSON.stringify({model,prompt:text,stream:false,options:{num_predict:512}})});
  if(!res.ok){await res.body?.cancel();throw new Error('Local model rejected request');}
  const reader=res.body?.getReader();if(!reader)throw new Error('Missing response');
  const decoder=new TextDecoder();let bytes=0,body='';
  try{while(true){const {done,value}=await reader.read();if(done)break;bytes+=value.byteLength;if(bytes>65536)throw new Error('Model response too large');body+=decoder.decode(value,{stream:true});}body+=decoder.decode();}
  finally{await reader.cancel().catch(()=>{});reader.releaseLock();}
  const data=JSON.parse(body);if(typeof data.response!=='string'||!data.response.trim()||data.response.length>8000||data.done!==true)throw new Error('Invalid local model output');
  combined.throwIfAborted();return data.response;
 };
}
