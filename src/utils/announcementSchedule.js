// 定时发布时间须晚于当前本地时间；日期选择与时间选择使用相同规则。
function parseDate(value){
  if(value instanceof Date)return new Date(value.getTime());
  if(typeof value==='string'){
    const dateOnly=value.trim().match(/^(\d{4})-(\d{2})-(\d{2})$/);
    if(dateOnly)return new Date(Number(dateOnly[1]),Number(dateOnly[2])-1,Number(dateOnly[3]));
    return new Date(value.trim().replace(' ','T'));
  }
  return new Date(value);
}
const sameDay=(a,b)=>a.getFullYear()===b.getFullYear()&&a.getMonth()===b.getMonth()&&a.getDate()===b.getDate();
const earlierValues=count=>Array.from({length:count},(_,index)=>index);

export function disablePastPublishDate(value){
  const date=parseDate(value);
  if(!Number.isFinite(date.getTime()))return false;
  const today=new Date();
  date.setHours(0,0,0,0);
  today.setHours(0,0,0,0);
  return date.getTime()<today.getTime();
}

export function disablePastPublishTime(value){
  const selected=parseDate(value);
  const now=new Date();
  if(!Number.isFinite(selected.getTime())||!sameDay(selected,now))return {};
  const sameHour=selected.getHours()===now.getHours();
  const sameMinute=sameHour&&selected.getMinutes()===now.getMinutes();
  return {
    hour:earlierValues(now.getHours()),
    minute:sameHour?earlierValues(now.getMinutes()):[],
    second:sameMinute?earlierValues(now.getSeconds()+1):[]
  };
}

export function isFuturePublishTime(value){
  if(!value)return false;
  const time=parseDate(value).getTime();
  return Number.isFinite(time)&&time>Date.now();
}
