<template>
  <PortalTooltip :content="content" :placement="placement" :disabled="!overflow || !content">
    <span
      ref="root"
      class="portal-app-overflow-tooltip"
      :class="'portal-app-overflow-tooltip--' + kind"
      @mouseenter="syncOverflow"
      @focusin="syncOverflow"
    >
      <slot>{{ content }}</slot>
    </span>
  </PortalTooltip>
</template>

<script setup>
import {nextTick,onBeforeUnmount,onMounted,onUpdated,ref} from 'vue';
import PortalTooltip from './PortalTooltip.vue';

defineProps({
  content:{type:String,default:''},
  placement:{type:String,default:'top'},
  kind:{type:String,default:'name'}
});

const root=ref(null);
const overflow=ref(false);
let observer=null;

function textElement(){
  return root.value?.querySelector('[data-overflow-text]') || root.value;
}

function syncOverflow(){
  const target=textElement();
  overflow.value=Boolean(target&&(target.scrollWidth>target.clientWidth+1||target.scrollHeight>target.clientHeight+1));
}

onMounted(()=>{
  nextTick(()=>{
    syncOverflow();
    if(typeof ResizeObserver==='undefined'||!root.value)return;
    observer=new ResizeObserver(syncOverflow);
    observer.observe(root.value);
    const target=textElement();
    if(target&&target!==root.value)observer.observe(target);
  });
});
onUpdated(()=>nextTick(syncOverflow));
onBeforeUnmount(()=>observer?.disconnect());
</script>
