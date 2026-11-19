import http from 'node:http';
import {MemoryStore} from './memory.mjs';
import {contextualProvider} from './conversation.mjs';
import {createLocalModel} from './local-model.mjs';
import {randomUUID, timingSafeEqual} from 'node:crypto';
import {pathToFileURL} from 'node:url';

export const localProvider = async (text) => 'Local demonstration (no AI provider): ' + text;
export function createEngine({token, origin='http://localhost:8080', provider=localProvider}={}) {
  if(typeof token !== 'string' || token.length < 32) throw new Error('Set a local token of at least 32 characters');
  const mode=provider===localProvider?'local-demo':'custom-provider';
  const sessions = new Map();
  const authorized = value => {
    const a=Buffer.from(value ?? ''), b=Buffer.from('Bearer '+token);
    return a.length===b.length && timingSafeEqual(a,b);
  };
  const server=http.createServer(async(req,res)=>{
    const send=(status,data)=>{if(!res.destroyed && !res.writableEnded){res.writeHead(status,{'Content-Type':'application/json','Cache-Control':'no-store'});res.end(JSON.stringify(data));}};
    if(req.headers.origin && req.headers.origin!==origin) return send(403,{error:'origin denied'});
    res.setHeader('Access-Control-Allow-Origin',origin);
    res.setHeader('Vary','Origin');
    if(req.method==='OPTIONS'){res.setHeader('Access-Control-Allow-Headers','authorization, content-type');res.setHeader('Access-Control-Allow-Methods','GET, POST, DELETE');res.writeHead(204);return res.end();}
    if(!authorized(req.headers.authorization))return send(401,{error:'unauthorized'});
    const path=new URL(req.url,'http://localhost').pathname;
    for(const [id,s] of sessions) if(Date.now()-s.updated>1800000 && !s.busy) sessions.delete(id);
    try{
      if(path==='/v1/health' && req.method==='GET')return send(200,{status:'ok',mode});
      if(path==='/v1/sessions' && req.method==='POST'){
        if(sessions.size>=100)return send(429,{error:'session limit'});
        const id=randomUUID();sessions.set(id,{updated:Date.now(),busy:false,sequence:0});
        return send(201,{id,mode});
      }
      const match=/^\/v1\/sessions\/([0-9a-f-]+)(\/messages)?$/.exec(path);
      if(!match || !sessions.has(match[1]))return send(404,{error:'not found'});
      const s=sessions.get(match[1]);
      if(req.method==='DELETE' && !match[2]){if(s.busy)return send(409,{error:'busy'});sessions.delete(match[1]);return send(200,{deleted:true});}
      if(req.method!=='POST'||!match[2])return send(405,{error:'method'});
      if(s.busy)return send(409,{error:'busy'});
      s.busy=true;s.updated=Date.now();
      try{
        let body='',size=0;
        for await(const chunk of req){size+=chunk.length;if(size>16384){send(413,{error:'too large'});return;}body+=chunk.toString('utf8');}
        let data;try{data=JSON.parse(body);}catch{return send(400,{error:'invalid JSON'});}
        if(typeof data?.text!=='string'||!data.text.trim()||data.text.length>2000)return send(400,{error:'invalid text'});
        const signal=AbortSignal.timeout(10000);
        const text=await Promise.race([provider(data.text.trim(),{signal}),new Promise((_,reject)=>signal.addEventListener('abort',()=>reject(new Error('timeout')),{once:true}))]);
        if(typeof text!=='string'||text.length>8000)throw new Error('invalid provider response');
        return send(200,{version:1,sessionId:match[1],sequence:++s.sequence,type:'assistant.message',text,mode});
      }finally{s.busy=false;s.updated=Date.now();}
    }catch{return send(502,{error:'engine request failed'});}
  });
  server.requestTimeout=15000;server.headersTimeout=10000;
  return server;
}
if(process.argv[1] && import.meta.url===pathToFileURL(process.argv[1]).href){
  let provider=process.env.ENGINE_LOCAL_MODEL?createLocalModel({model:process.env.ENGINE_LOCAL_MODEL}):localProvider;
  if(process.env.ENGINE_MEMORY_PATH&&!process.env.ENGINE_LOCAL_MODEL)throw new Error('Memory requires explicit local model selection');
  const memory=process.env.ENGINE_MEMORY_PATH?new MemoryStore(process.env.ENGINE_MEMORY_PATH):null;
  if(memory)provider=contextualProvider({provider,memory,principal:'local-owner'});
  const server=createEngine({token:process.env.ENGINE_TOKEN,origin:process.env.CLIENT_ORIGIN,provider});
  if(memory)server.once('close',()=>memory.close());
  server.listen(3000,'127.0.0.1',()=>console.log('Local engine on 127.0.0.1:3000'));
}
