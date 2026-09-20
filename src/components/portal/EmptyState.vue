<template><div class="portal-empty" role="status"><img :src="nopic" alt=""/><p>{{description}}</p></div></template>
<script setup>
import nopic from '../../assets/nopic.svg';
defineProps({description:{type:String,default:'暂无数据'}});
</script>
