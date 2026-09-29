<template>
  <div ref="chartEl" class="admin-runtime-ring-chart" role="img" :aria-label="`${kind} 接入运行状态`"></div>
</template>

<script setup>
import {computed,nextTick,onBeforeUnmount,onMounted,ref,watch} from 'vue';
import * as echarts from 'echarts/core';
import {PieChart} from 'echarts/charts';
import {GraphicComponent} from 'echarts/components';
import {CanvasRenderer} from 'echarts/renderers';

echarts.use([PieChart,GraphicComponent,CanvasRenderer]);

const props=defineProps({
  kind:{type:String,required:true},
  normal:{type:Number,default:0},
  abnormal:{type:Number,default:0},
  inactive:{type:Number,default:0}
});

const chartEl=ref(null);
let chart=null;
let resizeObserver=null;

const normalRate=computed(()=>{
  const configured=Number(props.normal||0)+Number(props.abnormal||0);
  return configured?Math.round(Number(props.normal||0)/configured*100):0;
});

function render(){
  if(!chartEl.value)return;
  if(!chart)chart=echarts.init(chartEl.value,null,{renderer:'canvas'});
  chart.setOption({
    animationDuration:300,
    series:[{
      type:'pie',
      silent:true,
      radius:['66%','82%'],
      center:['50%','50%'],
      startAngle:90,
      clockwise:true,
      avoidLabelOverlap:true,
      label:{show:false},
      labelLine:{show:false},
      itemStyle:{
        borderColor:'#fff',
        borderWidth:5,
        borderRadius:6
      },
      data:[
        {name:'正常',value:Number(props.normal||0),itemStyle:{color:'#2ba471'}},
        {name:'异常',value:Number(props.abnormal||0),itemStyle:{color:'#d54941'}},
        {name:'未配置/停用',value:Number(props.inactive||0),itemStyle:{color:'#d9deea'}}
      ]
    }],
    graphic:[{
      type:'text',
      left:'center',
      top:'middle',
      silent:true,
      style:{
        text:`${normalRate.value}%`,
        fill:'#1d2129',
        font:'600 22px Arial, sans-serif',
        textAlign:'center',
        textVerticalAlign:'middle'
      }
    }]
  },true);
}

onMounted(async()=>{
  await nextTick();
  render();
  if(typeof ResizeObserver!=='undefined'){
    resizeObserver=new ResizeObserver(()=>chart?.resize());
    resizeObserver.observe(chartEl.value);
  }else{
    window.addEventListener('resize',render);
  }
});
watch(()=>[props.normal,props.abnormal,props.inactive],async()=>{await nextTick();render();});
onBeforeUnmount(()=>{
  resizeObserver?.disconnect();
  window.removeEventListener('resize',render);
  chart?.dispose();
  chart=null;
});
</script>
