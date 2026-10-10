<template>
  <div class="mobile-loading-state" role="status" aria-live="polite">
    <span class="mobile-loading-ring" aria-hidden="true"></span>
    <span class="mobile-loading-label">{{ message }}</span>
  </div>
</template>

<script setup lang="ts">
withDefaults(defineProps<{ message?: string }>(), {
  message: '正在加载…',
});
</script>

<style scoped>
.mobile-loading-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 12px;
  width: 100%;
  min-height: 84px;
  padding: 12px 0;
  box-sizing: border-box;
  text-align: center;
  color: var(--mobile-ink-muted, #728198);
  font-size: 13px;
  line-height: 1.5;
}

.mobile-loading-ring {
  display: block;
  width: 26px;
  height: 26px;
  box-sizing: border-box;
  border: 2px solid #dbe6f4;
  border-top-color: var(--mobile-brand, #0052d9);
  border-radius: 50%;
  animation: mobile-loading-rotate 0.8s linear infinite;
}

@keyframes mobile-loading-rotate {
  to { transform: rotate(360deg); }
}

@media (prefers-reduced-motion: reduce) {
  .mobile-loading-ring { animation-duration: 2s; }
}
</style>
