<template>
  <dl class="portal-detail-grid">
    <div v-for="item in normalizedItems" :key="item.key" class="portal-detail-item" :class="{'is-wide':item.resolvedWide}">
      <dt>{{item.label}}</dt><dd><slot :name="item.key" :item="item">{{item.value}}</slot></dd>
    </div>
  </dl>
</template>
<script setup>
import {computed} from 'vue';

const props=defineProps({items:{type:Array,default:()=>[]}});

const normalizedItems=computed(()=>{
  const source=props.items||[];
  let column=0;
  return source.map((item,index)=>{
    if(item.wide){
      column=0;
      return {...item,resolvedWide:true};
    }
    if(column===1){
      column=0;
      return {...item,resolvedWide:false};
    }
    const next=source[index+1];
    const resolvedWide=!next||Boolean(next.wide);
    column=resolvedWide?0:1;
    return {...item,resolvedWide};
  });
});
</script>
