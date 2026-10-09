<template>
 <div class="mobile-shell">
  <main class="mobile-shell__content"><router-view :key="route.fullPath+'|'+actor?.id" /></main>
  <nav class="mobile-shell__navigation" aria-label="移动端主导航">
   <MobileTabBar :value="activeTab" :fixed="false" :split="false" :safe-area-inset-bottom="true" @change="navigate">
    <MobileTabBarItem v-for="item in tabs" :key="item.path" :value="item.path">
     <template #icon><component :is="item.icon" /></template>
     {{item.label}}
    </MobileTabBarItem>
   </MobileTabBar>
  </nav>
 </div>
</template>

<script setup lang="ts">
import {computed} from 'vue';
import {useRoute,useRouter} from 'vue-router';
import {TabBar as MobileTabBar,TabBarItem as MobileTabBarItem} from 'tdesign-mobile-vue';
import {HomeIcon,TaskIcon,AppIcon,MailIcon,UserIcon} from 'tdesign-icons-vue-next';
import {mobileActor as actor} from './mobileActor';
import './mobile.css';

const route=useRoute();
const router=useRouter();
const tabs=[
 {path:'/m/home',label:'首页',icon:HomeIcon},
 {path:'/m/todos',label:'待办事项',icon:TaskIcon},
 {path:'/m/apps',label:'全部应用',icon:AppIcon},
 {path:'/m/messages',label:'消息中心',icon:MailIcon},
 {path:'/m/profile',label:'我的',icon:UserIcon}
] as const;
const activeTab=computed(()=>{
 const path=route.path;
 if(path.startsWith('/m/announcements'))return '/m/home';
 if(path.startsWith('/m/applications'))return '/m/profile';
 return tabs.find(item=>path===item.path)?.path||'/m/home';
});
function navigate(path:string|number){
 if(typeof path==='string'&&path!==route.path)router.push(path);
}
</script>
