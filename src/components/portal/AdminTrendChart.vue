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
import {chinaDayKey,normalizeChinaDayCounts} from '../../utils/chinaCalendar.mjs';

echarts.use([LineChart,GridComponent,TooltipComponent,CanvasRenderer]);

const props=defineProps({
  accessRows:{type:Array,default:()=>[]},
  apiRows:{type:Array,default:()=>[]}
});
const emit=defineEmits(['day-change']);

const chartEl=ref(null);
const metric=ref('access');
const period=ref(7);
const now=ref(new Date());
let chart=null;
let resizeObserver=null;
let clockTimer=null;

const currentRows=computed(()=>metric.value==='api'?props.apiRows:props.accessRows);
const currentSeriesName=computed(()=>metric.value==='api'?'接口调用量':'门户访问量');

const trend=computed(()=>normalizeChinaDayCounts(currentRows.value,period.value,now.value));

function refreshClock(){
  const current=new Date();
  if(chinaDayKey(current)===chinaDayKey(now.value))return;
  now.value=current;
  emit('day-change');
}

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
        interval:period.value===30?4:0,
        rotate:0,
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
      smooth:true,
      showSymbol:true,
      symbol:'circle',
      symbolSize:5,
      data:trend.value.map(item=>item.value),
      lineStyle:{width:2,color:'#2454ff'},
      itemStyle:{color:'#2454ff'},
      areaStyle:{color:'rgba(36,84,255,.10)'}
    }]
  },true);
}

onMounted(async()=>{
  await nextTick();
  refreshClock();
  render();
  clockTimer=window.setInterval(refreshClock,30000);
  document.addEventListener('visibilitychange',refreshClock);
  if(typeof ResizeObserver!=='undefined'){
    resizeObserver=new ResizeObserver(()=>chart?.resize());
    if(chartEl.value)resizeObserver.observe(chartEl.value);
  }else{
    window.addEventListener('resize',render);
  }
});
watch(()=>[props.accessRows,props.apiRows,metric.value,period.value,now.value],async()=>{await nextTick();render();},{deep:true});
onBeforeUnmount(()=>{
  window.clearInterval(clockTimer);
  document.removeEventListener('visibilitychange',refreshClock);
  resizeObserver?.disconnect();
  window.removeEventListener('resize',render);
  chart?.dispose();
  chart=null;
});
</script>
