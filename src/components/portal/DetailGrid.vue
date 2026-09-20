<template>
  <dl class="portal-detail-grid">
    <div v-for="item in items" :key="item.key" class="portal-detail-item" :class="{'is-wide':item.wide}">
      <dt>{{item.label}}</dt><dd><slot :name="item.key" :item="item">{{item.value}}</slot></dd>
    </div>
  </dl>
</template>
<script setup>
defineProps({items:{type:Array,default:()=>[]}});
</script>
