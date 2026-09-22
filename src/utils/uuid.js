const hex=byte=>byte.toString(16).padStart(2,'0');

export function createUUID(cryptoApi=globalThis.crypto){
  if(typeof cryptoApi?.randomUUID==='function')return cryptoApi.randomUUID();

  const bytes=new Uint8Array(16);
  if(typeof cryptoApi?.getRandomValues==='function'){
    cryptoApi.getRandomValues(bytes);
  }else{
    // Final compatibility fallback for non-security identifiers only.
    const seed=Date.now()+(globalThis.performance?.now?.()||0);
    for(let i=0;i<bytes.length;i++)bytes[i]=Math.floor((Math.random()*256+seed+i*17)%256);
  }

  bytes[6]=(bytes[6]&0x0f)|0x40;
  bytes[8]=(bytes[8]&0x3f)|0x80;
  const value=Array.from(bytes,hex).join('');
  return `${value.slice(0,8)}-${value.slice(8,12)}-${value.slice(12,16)}-${value.slice(16,20)}-${value.slice(20)}`;
}
