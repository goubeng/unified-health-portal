<template>
  <PortalTooltip :content="content" :placement="placement" :disabled="!overflow||!content">
    <span ref="root" class="table-cell-tooltip-content">
      <slot>{{content}}</slot>
    </span>
  </PortalTooltip>
</template>

<script setup>
import {computed,nextTick,onBeforeUnmount,onMounted,onUpdated,ref} from 'vue';
import PortalTooltip from './PortalTooltip.vue';

const props=defineProps({
  text:{type:[String,Number],default:''},
  placement:{type:String,default:'top'}
});

const root=ref(null);
const overflow=ref(false);
const content=computed(()=>props.text===null||props.text===undefined?'':String(props.text));
let observer=null;

function syncOverflow(){
  nextTick(()=>{
    const element=root.value;
    if(!element){overflow.value=false;return;}
    const child=element.firstElementChild;
    overflow.value=[element,child].filter(Boolean).some(target=>
      target.scrollWidth>target.clientWidth+1||target.scrollHeight>target.clientHeight+1
    );
  });
}

onMounted(()=>{
  syncOverflow();
  if(typeof ResizeObserver!=='undefined'&&root.value){
    observer=new ResizeObserver(syncOverflow);
    observer.observe(root.value);
  }
});
onUpdated(syncOverflow);
onBeforeUnmount(()=>observer?.disconnect());
</script>
