<template>
  <section class="panel admin-trend-card">
    <div class="section-head admin-trend-head">
      <h2>访问与调用趋势</h2>
      <div class="admin-trend-controls">
        <div class="admin-trend-range" aria-label="趋势指标">
          <button type="button" :class="{active:metric==='access'}" :aria-pressed="metric==='access'" @click="metric='access'">门户访问量</button>
          <button type="button" :class="{active:metric==='api'}" :aria-pressed="metric==='api'" @click="metric='api'">接口调用量</button>
        </div>
        <div class="admin-trend-range" aria-label="趋势时间范围">
          <button type="button" :class="{active:period===7}" :aria-pressed="period===7" @click="period=7">近7天</button>
          <button type="button" :class="{active:period===30}" :aria-pressed="period===30" @click="period=30">近30天</button>
        </div>
      </div>
    </div>
    <div ref="chartEl" class="admin-trend-chart" role="img" :aria-label="currentSeriesName+'趋势'"></div>
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
  accessRows:{type:Array,default:()=>[]},
  apiRows:{type:Array,default:()=>[]}
});

const chartEl=ref(null);
const metric=ref('access');
const period=ref(7);
let chart=null;
let resizeObserver=null;

const currentRows=computed(()=>metric.value==='api'?props.apiRows:props.accessRows);
const currentSeriesName=computed(()=>metric.value==='api'?'接口调用量':'门户访问量');

const chinaDay=value=>{
  const date=new Date(value);
  if(!Number.isFinite(date.getTime()))return '';
  const parts=Object.fromEntries(new Intl.DateTimeFormat('zh-CN',{timeZone:'Asia/Shanghai',year:'numeric',month:'2-digit',day:'2-digit'}).formatToParts(date).filter(part=>part.type!=='literal').map(part=>[part.type,part.value]));
  return `${parts.year}-${parts.month}-${parts.day}`;
};

const trend=computed(()=>{
  const allRows=[...props.accessRows,...props.apiRows];
  const allValid=allRows.map(row=>Date.parse(row.createdAt)).filter(Number.isFinite);
  const valid=currentRows.value.map(row=>({row,time:Date.parse(row.createdAt)})).filter(item=>Number.isFinite(item.time));
  const base=allValid.length?new Date(Math.max(...allValid)):new Date();
  const baseKey=chinaDay(base);
  const baseDate=new Date(baseKey+'T00:00:00+08:00');
  const days=Array.from({length:period.value},(_,index)=>{
    const date=new Date(baseDate.getTime()-(period.value-1-index)*86400000);
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
  chart.setOption({
    animationDuration:350,
    grid:{
      left:18,
      right:18,
      top:18,
      bottom:period.value===30?18:12,
      containLabel:true
    },
    tooltip:{trigger:'axis',confine:true},
    xAxis:{
      type:'category',
      boundaryGap:false,
      data:trend.value.map(item=>item.label),
      axisLine:{show:true,lineStyle:{color:'#86909c',width:1}},
      axisTick:{show:true,alignWithLabel:true,length:4,lineStyle:{color:'#86909c'}},
      axisLabel:{
        show:true,
        color:'#4e5969',
        fontSize:11,
        interval:0,
        rotate:period.value===30?45:0,
        margin:10
      }
    },
    yAxis:{
      type:'value',
      min:0,
      minInterval:1,
      splitNumber:4,
      axisLine:{show:true,lineStyle:{color:'#86909c',width:1}},
      axisTick:{show:true,length:4,lineStyle:{color:'#86909c'}},
      axisLabel:{show:true,color:'#4e5969',fontSize:11,margin:8},
      splitLine:{show:true,lineStyle:{color:'#eef0f4',type:'dashed'}}
    },
    series:[{
      name:currentSeriesName.value,
      type:'line',
      smooth:false,
      showSymbol:true,
      symbol:'circle',
      symbolSize:5,
      data:trend.value.map(item=>item.value),
      lineStyle:{width:2,color:'#2454ff'},
      itemStyle:{color:'#2454ff'}
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
watch(()=>[props.accessRows,props.apiRows,metric.value,period.value],async()=>{await nextTick();render();},{deep:true});
onBeforeUnmount(()=>{
  resizeObserver?.disconnect();
  window.removeEventListener('resize',render);
  chart?.dispose();
  chart=null;
});
</script>
