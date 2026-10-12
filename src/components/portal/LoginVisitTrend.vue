<template>
  <section class="panel admin-trend-card login-visit-trend">
    <div class="section-head admin-trend-head login-visit-trend-head">
      <h2>门户访问量趋势</h2>
      <div class="admin-trend-controls">
        <div class="admin-trend-range login-visit-trend-presets" aria-label="门户访问量时间范围">
          <button v-for="item in periods" :key="item.value" type="button" :class="{active:period===item.value}" :aria-pressed="period===item.value" @click="choosePeriod(item.value)">{{item.label}}</button>
        </div>
        <t-date-range-picker v-if="period==='custom'" v-model="customRange" class="login-visit-trend-dates" format="YYYY-MM-DD" value-type="YYYY-MM-DD" :disable-date="disableFutureDay" clearable :placeholder="['开始日期','结束日期']"/>
      </div>
    </div>
    <p v-if="error" class="error-note" role="alert">{{error}}</p>
    <div class="login-visit-trend-chart-wrap">
      <div ref="chartEl" class="admin-trend-chart" role="img" aria-label="按北京时间统计的每日成功门户访问量趋势"></div>
      <span v-if="loading" class="login-visit-trend-loading">正在加载访问趋势…</span>
    </div>
  </section>
</template>

<script setup>
import {computed,nextTick,onBeforeUnmount,onMounted,ref,watch} from 'vue';
import * as echarts from 'echarts/core';
import {LineChart} from 'echarts/charts';
import {GridComponent,TooltipComponent} from 'echarts/components';
import {CanvasRenderer} from 'echarts/renderers';
import {portal} from '../../services/runtime.js';
import {chinaDayKey} from '../../utils/chinaCalendar.mjs';
import {visitTrendPreset,validateVisitTrendRange} from '../../utils/portalVisitTrend.mjs';

echarts.use([LineChart,GridComponent,TooltipComponent,CanvasRenderer]);

const periods=[
  {label:'本月',value:'thisMonth'},
  {label:'上月',value:'lastMonth'},
  {label:'近7天',value:'7d'},
  {label:'近30天',value:'30d'},
  {label:'自定义',value:'custom'}
];
const period=ref('30d');
const now=ref(new Date());
const customRange=ref(visitTrendPreset('30d',now.value));
const chartEl=ref(null),loading=ref(false),error=ref(''),rows=ref([]);
const activeRange=computed(()=>period.value==='custom'?customRange.value:visitTrendPreset(period.value,now.value));
let chart=null,resizeObserver=null,clockTimer=null,requestVersion=0;

function choosePeriod(value){period.value=value;}
function disableFutureDay(value){
 const key=chinaDayKey(value);
 return Boolean(key&&key>chinaDayKey(now.value));
}
function render(){
 if(!chartEl.value)return;
 if(!chart)chart=echarts.init(chartEl.value,null,{renderer:'canvas'});
 const dates=rows.value.map(item=>item.date);
 const values=rows.value.map(item=>Number(item.count)||0);
 chart.setOption({
  animationDuration:350,
  grid:{left:18,right:18,top:18,bottom:18,containLabel:true},
  tooltip:{trigger:'axis',confine:true,formatter:params=>{
   const point=params?.[0];if(!point)return '';
   return `${dates[point.dataIndex]||'-'}<br/>门户访问量：${Number(point.value)||0}`;
  }},
  xAxis:{
   type:'category',boundaryGap:false,data:dates.map(x=>`${Number(x.slice(5,7))}/${Number(x.slice(8,10))}`),
   axisLine:{show:true,lineStyle:{color:'#86909c',width:1}},
   axisTick:{show:true,alignWithLabel:true,length:4,lineStyle:{color:'#86909c'}},
   axisLabel:{show:true,color:'#4e5969',fontSize:11,interval:Math.max(0,Math.ceil(dates.length/8)-1),rotate:0,margin:10}
  },
  yAxis:{
   type:'value',min:0,minInterval:1,splitNumber:4,
   axisLine:{show:true,lineStyle:{color:'#86909c',width:1}},
   axisTick:{show:true,length:4,lineStyle:{color:'#86909c'}},
   axisLabel:{show:true,color:'#4e5969',fontSize:11,margin:8},
   splitLine:{show:true,lineStyle:{color:'#eef0f4',type:'dashed'}}
  },
  series:[{
   name:'门户访问量',type:'line',smooth:true,showSymbol:true,symbol:'circle',symbolSize:5,
   data:values,lineStyle:{width:2,color:'#2454ff'},itemStyle:{color:'#2454ff'},
   areaStyle:{color:'rgba(36,84,255,.10)'}
  }]
 },true);
}
async function load(){
 const version=++requestVersion;
 const range=activeRange.value;
 if(!Array.isArray(range)||range.length!==2||!range[0]||!range[1]){
  loading.value=false;error.value=period.value==='custom'?'请选择完整的开始日期和结束日期':'';
  rows.value=[];await nextTick();render();return;
 }
 let startDate,endDate;
 try{
  [startDate,endDate]=range;
  validateVisitTrendRange(startDate,endDate,now.value);
 }catch(cause){loading.value=false;error.value=cause.message;rows.value=[];await nextTick();render();return;}
 loading.value=true;error.value='';
 const query=new URLSearchParams({startDate,endDate}).toString();
 try{
  const result=await portal.read(`auditVisitTrend?${query}`);
  if(version!==requestVersion)return;
  if(!result.ok)throw new Error(result.error?.message||'访问趋势加载失败');
  rows.value=Array.isArray(result.data)?result.data:[];
 }catch(cause){
  if(version!==requestVersion)return;
  rows.value=[];error.value=cause.message;
 }finally{
  if(version===requestVersion){loading.value=false;await nextTick();render();}
 }
}
function refreshDay(){
 const current=new Date();
 if(chinaDayKey(current)!==chinaDayKey(now.value))now.value=current;
}
onMounted(async()=>{
 await nextTick();render();
 clockTimer=window.setInterval(refreshDay,30000);
 document.addEventListener('visibilitychange',refreshDay);
 if(typeof ResizeObserver!=='undefined'){
  resizeObserver=new ResizeObserver(()=>chart?.resize());
  if(chartEl.value)resizeObserver.observe(chartEl.value);
 }else window.addEventListener('resize',render);
});
watch([period,customRange,now],load,{deep:true,immediate:true});
onBeforeUnmount(()=>{
 requestVersion++;
 window.clearInterval(clockTimer);
 document.removeEventListener('visibilitychange',refreshDay);
 resizeObserver?.disconnect();
 window.removeEventListener('resize',render);
 chart?.dispose();chart=null;
});
</script>
