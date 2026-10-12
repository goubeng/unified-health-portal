import {chinaDayKey,chinaDayWindow} from './chinaCalendar.mjs';

const DAY_MS=86400000;
export const MAX_VISIT_TREND_DAYS=366;
const midnight=key=>Date.parse(`${key}T00:00:00+08:00`);
const validDay=key=>typeof key==='string'&&/^\d{4}-\d{2}-\d{2}$/.test(key)&&chinaDayKey(midnight(key))===key;

export function visitTrendPreset(period,now=new Date()){
 const today=chinaDayKey(now);
 if(!today)throw new RangeError('当前日期无效');
 if(period==='7d'||period==='30d'){
  const days=chinaDayWindow(period==='7d'?7:30,now);
  return [days[0].key,today];
 }
 const [year,month]=today.split('-').map(Number);
 if(period==='thisMonth')return [`${today.slice(0,7)}-01`,today];
 if(period==='lastMonth'){
  const first=new Date(Date.UTC(year,month-2,1));
  const last=new Date(Date.UTC(year,month-1,0));
  return [first.toISOString().slice(0,10),last.toISOString().slice(0,10)];
 }
 throw new RangeError('不支持的时间范围');
}

export function validateVisitTrendRange(startDate,endDate,now=new Date()){
 const today=chinaDayKey(now);
 if(!validDay(startDate)||!validDay(endDate))throw new RangeError('请选择有效的开始日期和结束日期');
 if(startDate>endDate)throw new RangeError('开始日期不能晚于结束日期');
 if(endDate>today)throw new RangeError('结束日期不能超过今天');
 const length=Math.round((midnight(endDate)-midnight(startDate))/DAY_MS)+1;
 if(length>MAX_VISIT_TREND_DAYS)throw new RangeError('时间跨度不能超过366天');
 return {startDate,endDate,length};
}

export function visitTrendDays(startDate,endDate,now=new Date()){
 const {length}=validateVisitTrendRange(startDate,endDate,now);
 const first=midnight(startDate);
 return Array.from({length},(_,index)=>({date:chinaDayKey(first+index*DAY_MS),count:0}));
}

export function visitTrendBounds(startDate,endDate,now=new Date()){
 validateVisitTrendRange(startDate,endDate,now);
 const today=chinaDayKey(now);
 return {
  startAt:new Date(midnight(startDate)).toISOString(),
  endAt:endDate===today?new Date(now).toISOString():new Date(midnight(endDate)+DAY_MS).toISOString()
 };
}

export function visitTrendSeries(startDate,endDate,rows,now=new Date()){
 const days=visitTrendDays(startDate,endDate,now);
 const byDate=new Map(days.map(x=>[x.date,x]));
 for(const item of rows||[]){
  const date=item.date||item.day;
  const day=byDate.get(date);
  if(day)day.count+=Number(item.count)||0;
 }
 return days;
}

/** 按北京时间统计每日接口调用次数，与管理首页 API 趋势的计数口径一致（包含成功与失败）。 */
export function apiTrendFromLogs(startDate,endDate,logs,now=new Date()){
 const days=visitTrendDays(startDate,endDate,now);
 const byDate=new Map(days.map(item=>[item.date,item]));
 const cutoff=new Date(now).getTime();
 for(const log of logs||[]){
  if(String(log?.kind||'').toLowerCase()!=='api')continue;
  const time=Date.parse(log.createdAt);
  if(!Number.isFinite(time)||time>cutoff)continue;
  const day=byDate.get(chinaDayKey(time));
  if(day)day.count++;
 }
 return days;
}

export function visitTrendFromLogs(startDate,endDate,logs,now=new Date()){
 const days=visitTrendDays(startDate,endDate,now);
 const byDate=new Map(days.map(x=>[x.date,x]));
 const cutoff=new Date(now).getTime();
 for(const log of logs||[]){
  if(String(log?.kind||'').toLowerCase()!=='login'||log.status!=='SUCCESS'||!['LOGIN','身份登录'].includes(log.name))continue;
  const time=Date.parse(log.createdAt);
  if(!Number.isFinite(time)||time>cutoff)continue;
  const day=byDate.get(chinaDayKey(time));
  if(day)day.count++;
 }
 return days;
}
