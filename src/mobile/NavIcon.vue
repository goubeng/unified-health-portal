<template>
  <svg class="mobile-nav-icon" viewBox="0 0 24 24" width="24" height="24" fill="currentColor" aria-hidden="true">
    <!-- 首页：标准经典房屋/主页图标 -->
    <template v-if="name === 'home'">
      <path d="M12 2.6L2.5 11.2l1.3 1.5L5 11.6V20.5c0 .6.4 1 1 1h4.5v-6h3v6H18c.6 0 1-.4 1-1v-8.9l1.2 1.1 1.3-1.5L12 2.6z"/>
    </template>

    <!-- 待办：标准任务记事板与完成对勾图标 -->
    <template v-else-if="name === 'todo'">
      <path d="M19 3h-4.18C14.4 1.84 13.3 1 12 1s-2.4.84-2.82 2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm-2 14.2l-3.8-3.8 1.4-1.4 2.4 2.4 6-6 1.4 1.4-7.4 7.4z"/>
    </template>

    <!-- 全部应用：标准圆角应用网格矩阵 -->
    <template v-else-if="name === 'apps'">
      <rect x="3.2" y="3.2" width="7.6" height="7.6" rx="2.2" />
      <rect x="13.2" y="3.2" width="7.6" height="7.6" rx="2.2" />
      <rect x="3.2" y="13.2" width="7.6" height="7.6" rx="2.2" />
      <rect x="13.2" y="13.2" width="7.6" height="7.6" rx="2.2" />
    </template>

    <!-- 消息中心：标准消息对话气泡与信息横线 -->
    <template v-else-if="name === 'message'">
      <path d="M20 2H4c-1.1 0-2 .9-2 2v17l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-3 10H7v-2h10v2zm0-3.2H7V6.8h10V8.8z"/>
    </template>

    <!-- 我的/个人中心：标准用户头像与圆角肩身轮廓 -->
    <template v-else-if="name === 'profile'">
      <path d="M12 12c2.8 0 5-2.2 5-5s-2.2-5-5-5-5 2.2-5 5 2.2 5 5 5zm0 2.2c-3.3 0-10 1.7-10 5V21c0 .6.4 1 1 1h18c.6 0 1-.4 1-1v-1.8c0-3.3-6.7-5-10-5z"/>
    </template>
  </svg>
</template>

<script setup lang="ts">
export type NavIconName = 'home' | 'todo' | 'apps' | 'message' | 'profile';

defineProps<{
  name: NavIconName;
}>();
</script>

<style scoped>
.mobile-nav-icon {
  display: block;
  width: 24px;
  height: 24px;
  margin: 0 auto;
}
</style>
