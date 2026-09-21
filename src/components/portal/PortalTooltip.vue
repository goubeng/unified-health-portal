<template>
  <t-tooltip :content="content" :placement="placement" :disabled="disabled">
    <slot/>
  </t-tooltip>
</template>

<script setup>
defineProps({
  content:{type:String,default:''},
  placement:{type:String,default:'right'},
  disabled:{type:Boolean,default:false}
});
</script>
