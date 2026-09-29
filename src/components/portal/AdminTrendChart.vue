<template>
  <section class="panel admin-trend-card">
    <div class="section-head">
      <h2>{{title}}</h2>
      <span class="admin-trend-subtitle">近7日</span>
    </div>
    <div ref="chartEl" class="admin-trend-chart" role="img" :aria-label="title"></div>
  </section>
</template>

<script setup>
import {computed,nextTick,onBeforeUnmount,onMounted,ref,watch} from 'vue';
import * as echarts from 'echarts/core';
import {LineChart} from 'echarts/charts';
import {GridComponent,TooltipComponent} from 'echarts/components';
import {CanvasRenderer} from 'echarts/renderers';

echarts.use([LineChart,GridComponent,TooltipComponent,CanvasRenderer]);

const props=defineProps({
  title:{type:String,required:true},
  rows:{type:Array,default:()=>[]},
  seriesName:{type:String,default:'次数'}
});

const chartEl=ref(null);
let chart=null;
let resizeObserver=null;

const chinaDay=value=>{
  const date=new Date(value);
  if(!Number.isFinite(date.getTime()))return '';
  const parts=Object.fromEntries(new Intl.DateTimeFormat('zh-CN',{timeZone:'Asia/Shanghai',year:'numeric',month:'2-digit',day:'2-digit'}).formatToParts(date).filter(part=>part.type!=='literal').map(part=>[part.type,part.value]));
  return `${parts.year}-${parts.month}-${parts.day}`;
};

const trend=computed(()=>{
  const valid=props.rows.map(row=>({row,time:Date.parse(row.createdAt)})).filter(item=>Number.isFinite(item.time));
  const base=valid.length?new Date(Math.max(...valid.map(item=>item.time))):new Date();
  const baseKey=chinaDay(base);
  const baseDate=new Date(baseKey+'T00:00:00+08:00');
  const days=Array.from({length:7},(_,index)=>{
    const date=new Date(baseDate.getTime()-(6-index)*86400000);
    const key=chinaDay(date);
    return {key,label:`${Number(key.slice(5,7))}/${Number(key.slice(8,10))}`,value:0};
  });
  const byKey=new Map(days.map(item=>[item.key,item]));
  valid.forEach(({row})=>{const item=byKey.get(chinaDay(row.createdAt));if(item)item.value+=1;});
  return days;
});

function render(){
  if(!chartEl.value)return;
  if(!chart)chart=echarts.init(chartEl.value,null,{renderer:'canvas'});
  const values=trend.value.map(item=>item.value);
  chart.setOption({
    animationDuration:350,
    grid:{left:42,right:18,top:18,bottom:30},
    tooltip:{trigger:'axis',confine:true},
    xAxis:{
      type:'category',
      boundaryGap:false,
      data:trend.value.map(item=>item.label),
      axisLine:{lineStyle:{color:'#d9dde5'}},
      axisTick:{show:false},
      axisLabel:{color:'#86909c',fontSize:11}
    },
    yAxis:{
      type:'value',
      min:0,
      minInterval:1,
      splitNumber:4,
      axisLine:{show:false},
      axisTick:{show:false},
      axisLabel:{color:'#86909c',fontSize:11},
      splitLine:{lineStyle:{color:'#eef0f4'}}
    },
    series:[{
      name:props.seriesName,
      type:'line',
      smooth:true,
      showSymbol:true,
      symbol:'circle',
      symbolSize:6,
      data:values,
      lineStyle:{width:2,color:'#2454ff'},
      itemStyle:{color:'#2454ff'},
      areaStyle:{color:'rgba(36,84,255,.08)'}
    }]
  },true);
}

onMounted(async()=>{
  await nextTick();
  render();
  if(typeof ResizeObserver!=='undefined'){
    resizeObserver=new ResizeObserver(()=>chart?.resize());
    if(chartEl.value)resizeObserver.observe(chartEl.value);
  }else{
    window.addEventListener('resize',render);
  }
});
watch(()=>[props.rows,props.title],async()=>{await nextTick();render();},{deep:true});
onBeforeUnmount(()=>{
  resizeObserver?.disconnect();
  window.removeEventListener('resize',render);
  chart?.dispose();
  chart=null;
});
</script>
