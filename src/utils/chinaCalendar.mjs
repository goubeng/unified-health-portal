const DAY_MS=86400000;
const chinaFormatter=new Intl.DateTimeFormat('en-CA',{
  timeZone:'Asia/Shanghai',year:'numeric',month:'2-digit',day:'2-digit'
});

export function chinaDayKey(value){
  const date=new Date(value);
  if(!Number.isFinite(date.getTime()))return '';
  const parts=Object.fromEntries(chinaFormatter.formatToParts(date)
    .filter(part=>part.type!=='literal').map(part=>[part.type,part.value]));
  return `${parts.year}-${parts.month}-${parts.day}`;
}

export function chinaDayWindow(length,now=new Date()){
  if(!Number.isInteger(length)||length<1)throw new RangeError('length must be a positive integer');
  const today=chinaDayKey(now);
  if(!today)throw new RangeError('now must be a valid date');
  const midnight=Date.parse(`${today}T00:00:00+08:00`);
  return Array.from({length},(_,index)=>{
    const key=chinaDayKey(new Date(midnight-(length-1-index)*DAY_MS));
    return {key,label:`${Number(key.slice(5,7))}/${Number(key.slice(8,10))}`,value:0};
  });
}

export function chinaWindowBounds(length,now=new Date()){
  const days=chinaDayWindow(length,now);
  return {
    startAt:new Date(`${days[0].key}T00:00:00+08:00`).toISOString(),
    endAt:new Date(now).toISOString()
  };
}

export function normalizeChinaDayCounts(rows,length,now=new Date()){
  const days=chinaDayWindow(length,now);
  const byKey=new Map(days.map(day=>[day.key,day]));
  for(const row of rows||[]){
    const day=byKey.get(row?.date);
    if(day)day.value+=Number(row.count)||0;
  }
  return days;
}

export function countRowsByChinaDay(rows,length,now=new Date()){
  const window=chinaDayWindow(length,now);
  const byKey=new Map(window.map(day=>[day.key,day]));
  const nowTime=new Date(now).getTime();
  for(const row of rows||[]){
    const time=Date.parse(row?.createdAt);
    if(!Number.isFinite(time)||time>nowTime)continue;
    const day=byKey.get(chinaDayKey(time));
    if(day)day.value+=1;
  }
  return window;
}
