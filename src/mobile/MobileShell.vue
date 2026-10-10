<template>
  <div class="mobile-shell" :class="{ 'mobile-shell--applications-list': isApplicationsList }">
    <main class="mobile-shell__content">
      <router-view :key="route.path + '|' + actor?.id" />
    </main>
    <nav v-if="!isDetailView && !isApplicationsList" class="mobile-shell__navigation" aria-label="移动端主导航">
      <MobileTabBar
        :value="activeTab"
        :fixed="false"
        :split="false"
        :safe-area-inset-bottom="true"
        @change="navigate"
      >
        <MobileTabBarItem v-for="item in tabs" :key="item.path" :value="item.path">
          <template #icon>
            <span class="nav-tab-icon-wrap">
              <NavIcon :name="item.iconName" />
              <span v-if="hasBadge(item.path)" class="nav-badge-dot" aria-label="未读提示"></span>
            </span>
          </template>
          {{ item.label }}
        </MobileTabBarItem>
      </MobileTabBar>
    </nav>
  </div>
</template>

<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue';
import { useRoute, useRouter } from 'vue-router';
import { TabBar as MobileTabBar, TabBarItem as MobileTabBarItem } from 'tdesign-mobile-vue';
import NavIcon, { type NavIconName } from './NavIcon.vue';
import { mobileActor as actor } from './mobileActor';
import { portal, revision } from '../services/runtime.js';
import './mobile.css';

const route = useRoute();
const router = useRouter();

const tabs = [
  { path: '/m/home', label: '首页', iconName: 'home' as NavIconName },
  { path: '/m/todos', label: '待办事项', iconName: 'todo' as NavIconName },
  { path: '/m/messages', label: '消息', iconName: 'message' as NavIconName },
  { path: '/m/apps', label: '全部应用', iconName: 'apps' as NavIconName },
  { path: '/m/profile', label: '我的', iconName: 'profile' as NavIconName },
] as const;

const isDetailView = computed(() => {
  return (route.path === '/m/messages' && Boolean(route.query.messageId))
    || (route.path.startsWith('/m/announcements/') && route.query.from === 'messages');
});

// “我的申请”由顶部返回按钮导航，列表与申请详情弹窗均不需要底部主导航。
const isApplicationsList = computed(() => route.path === '/m/applications');

const activeTab = computed(() => {
  const path = route.path;
  if (path.startsWith('/m/announcements')) return route.query.from === 'messages' ? '/m/messages' : '/m/home';
  if (path.startsWith('/m/applications')) return '/m/profile';
  return tabs.find((item) => path === item.path)?.path || '/m/home';
});

const pendingTodoCount = ref(0);
const unreadMessageCount = ref(0);
const unreadAnnouncementCount = ref(0);

async function refreshBadges() {
  try {
    const result = await portal.read('home');
    if (result.ok && result.data) {
      pendingTodoCount.value = Number(result.data.todoCount) || 0;
      unreadMessageCount.value = Number(result.data.unreadCount) || 0;
      unreadAnnouncementCount.value = Number(result.data.unreadAnnouncementCount) || 0;
    }
  } catch {
    // 忽略网络或服务异常
  }
}

function hasBadge(path: string): boolean {
  if (path === '/m/todos') {
    return pendingTodoCount.value > 0;
  }
  if (path === '/m/messages') {
    return unreadMessageCount.value > 0 || unreadAnnouncementCount.value > 0;
  }
  return false;
}

function navigate(path: string | number) {
  if (typeof path === 'string' && path !== route.path) router.push(path);
}

onMounted(refreshBadges);
watch(revision, refreshBadges);
watch(() => actor.value?.id, refreshBadges);
watch(() => route.path, refreshBadges);
</script>


