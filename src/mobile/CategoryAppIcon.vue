<template>
  <div class="category-app-icon" :class="iconToneClass" :title="category || '应用'">
    <!-- 1. 公众服务：爱心与医疗守护十字（便民健康服务） -->
    <svg
      v-if="matchedCategory === '公众服务'"
      class="svg-icon"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="1.9"
      stroke-linecap="round"
      stroke-linejoin="round"
      aria-hidden="true"
    >
      <path d="M19.5 12.572l-7.5 7.428l-7.5 -7.428a5 5 0 1 1 7.5 -6.566a5 5 0 1 1 7.5 6.572" />
      <path d="M12 8v4" />
      <path d="M10 10h4" />
    </svg>

    <!-- 2. 政务协同：政务机关建筑与立柱协同 -->
    <svg
      v-else-if="matchedCategory === '政务协同'"
      class="svg-icon"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="1.9"
      stroke-linecap="round"
      stroke-linejoin="round"
      aria-hidden="true"
    >
      <path d="M3 21h18" />
      <path d="M5 21V10l7-5 7 5v11" />
      <path d="M9 21v-4a2 2 0 0 1 2-2h2a2 2 0 0 1 2 2v4" />
      <line x1="9" y1="10" x2="9" y2="12" />
      <line x1="15" y1="10" x2="15" y2="12" />
    </svg>

    <!-- 3. 行业监管：天平法治与合规质控 -->
    <svg
      v-else-if="matchedCategory === '行业监管'"
      class="svg-icon"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="1.9"
      stroke-linecap="round"
      stroke-linejoin="round"
      aria-hidden="true"
    >
      <line x1="12" y1="3" x2="12" y2="21" />
      <path d="M4 7l8-3 8 3" />
      <path d="M6 10l-3 6h6l-3-6z" />
      <path d="M18 10l-3 6h6l-3-6z" />
      <line x1="9" y1="21" x2="15" y2="21" />
    </svg>

    <!-- 4. 培训考试：学术博士帽与知识认证 -->
    <svg
      v-else-if="matchedCategory === '培训考试'"
      class="svg-icon"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="1.9"
      stroke-linecap="round"
      stroke-linejoin="round"
      aria-hidden="true"
    >
      <path d="M22 10v6" />
      <path d="M2 10l10-5 10 5-10 5z" />
      <path d="M6 12v5c0 2 3 3 6 3s6-1 6-3v-5" />
    </svg>

    <!-- 5. 卫生监督：卫监执法盾牌与检视视镜 -->
    <svg
      v-else-if="matchedCategory === '卫生监督'"
      class="svg-icon"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="1.9"
      stroke-linecap="round"
      stroke-linejoin="round"
      aria-hidden="true"
    >
      <path d="M12 3a12 12 0 0 0 8.5 3A12 12 0 0 1 12 21 12 12 0 0 1 3.5 6 12 12 0 0 0 12 3z" />
      <circle cx="12" cy="11" r="3" />
      <path d="M14.2 13.2l2.3 2.3" />
    </svg>

    <!-- 6. 疾病防控：防疫阻断与生命脉搏波 -->
    <svg
      v-else-if="matchedCategory === '疾病防控'"
      class="svg-icon"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="1.9"
      stroke-linecap="round"
      stroke-linejoin="round"
      aria-hidden="true"
    >
      <path d="M3 12h4l3 8l4 -16l3 8h4" />
      <circle cx="12" cy="12" r="9" />
    </svg>

    <!-- 默认应用：微质感应用网格四宫格 -->
    <svg
      v-else
      class="svg-icon"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="1.9"
      stroke-linecap="round"
      stroke-linejoin="round"
      aria-hidden="true"
    >
      <rect x="3" y="3" width="7" height="7" rx="2" />
      <rect x="14" y="3" width="7" height="7" rx="2" />
      <rect x="14" y="14" width="7" height="7" rx="2" />
      <rect x="3" y="14" width="7" height="7" rx="2" />
    </svg>
  </div>
</template>

<script setup lang="ts">
import { computed } from 'vue';

const props = defineProps<{
  category?: string;
}>();

const KNOWN_CATEGORIES = [
  '公众服务',
  '政务协同',
  '行业监管',
  '培训考试',
  '卫生监督',
  '疾病防控',
] as const;

type KnownCategory = (typeof KNOWN_CATEGORIES)[number];

const matchedCategory = computed<KnownCategory | '其他'>(() => {
  const cat = (props.category || '').trim();
  if (KNOWN_CATEGORIES.includes(cat as KnownCategory)) {
    return cat as KnownCategory;
  }
  return '其他';
});

const iconToneClass = computed(() => {
  switch (matchedCategory.value) {
    case '公众服务':
      return 'tone-public';
    case '政务协同':
      return 'tone-gov';
    case '行业监管':
      return 'tone-supervision';
    case '培训考试':
      return 'tone-training';
    case '卫生监督':
      return 'tone-health-inspect';
    case '疾病防控':
      return 'tone-disease-control';
    default:
      return 'tone-default';
  }
});
</script>

<style scoped>
.category-app-icon {
  display: grid;
  place-items: center;
  width: 100%;
  height: 100%;
  border-radius: inherit;
  color: #ffffff;
  transition: transform 0.15s ease, box-shadow 0.15s ease;
}

.svg-icon {
  width: 22px;
  height: 22px;
  flex: none;
}

/* 1. 公众服务：活力暖橙，严格同色系光晕投影 */
.category-app-icon.tone-public {
  background: linear-gradient(135deg, #ff9f43 0%, #ff6b35 100%);
  box-shadow: 0 3px 8px rgba(255, 107, 53, 0.32);
}

/* 2. 政务协同：品牌政务蓝，严格同色系光晕投影 */
.category-app-icon.tone-gov {
  background: linear-gradient(135deg, #2b70f5 0%, #0052d9 100%);
  box-shadow: 0 3px 8px rgba(0, 82, 217, 0.32);
}

/* 3. 行业监管：质控青绿，严格同色系光晕投影 */
.category-app-icon.tone-supervision {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  box-shadow: 0 3px 8px rgba(5, 150, 105, 0.32);
}

/* 4. 培训考试：学识紫罗兰，严格同色系光晕投影 */
.category-app-icon.tone-training {
  background: linear-gradient(135deg, #8b5cf6 0%, #6d28d9 100%);
  box-shadow: 0 3px 8px rgba(109, 40, 217, 0.32);
}

/* 5. 卫生监督：执法青蓝天霁，严格同色系光晕投影 */
.category-app-icon.tone-health-inspect {
  background: linear-gradient(135deg, #06b6d4 0%, #0891b2 100%);
  box-shadow: 0 3px 8px rgba(8, 145, 178, 0.32);
}

/* 6. 疾病防控：防线玫红生命，严格同色系光晕投影 */
.category-app-icon.tone-disease-control {
  background: linear-gradient(135deg, #f43f5e 0%, #e11d48 100%);
  box-shadow: 0 3px 8px rgba(225, 29, 72, 0.32);
}

/* 默认通用与严格同色系光晕投影 */
.category-app-icon.tone-default {
  background: linear-gradient(135deg, #64748b 0%, #475569 100%);
  box-shadow: 0 3px 8px rgba(71, 85, 105, 0.25);
}
</style>
