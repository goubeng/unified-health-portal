import type {RouteRecordRaw} from 'vue-router';

const mobileMeta = (title: string, resource: string) => ({group:'个人事务',layout:'mobile',title,resource});

const routes: RouteRecordRaw[] = [
 {path:'/m',component:()=>import('./MobileShell.vue'),meta:{layout:'mobile',group:'个人事务'},children:[
  {path:'',redirect:'/m/home'},
  {path:'home',name:'MOBILE-HOME',component:()=>import('./MobileHome.vue'),meta:mobileMeta('首页','home')},
  {path:'todos',name:'MOBILE-TODOS',component:()=>import('./MobileTodos.vue'),meta:mobileMeta('待办事项','todos')},
  {path:'apps',name:'MOBILE-APPS',component:()=>import('./MobileApps.vue'),meta:mobileMeta('全部应用','apps')},
  {path:'messages',name:'MOBILE-MESSAGES',component:()=>import('./MobileMessages.vue'),meta:mobileMeta('消息','messages')},
  {path:'profile',name:'MOBILE-PROFILE',component:()=>import('./MobileProfile.vue'),meta:mobileMeta('我的','profile')},
  {path:'announcements',name:'MOBILE-ANNOUNCEMENTS',component:()=>import('./MobileAnnouncements.vue'),meta:mobileMeta('通知公告','announcements')},
  {path:'announcements/:id',name:'MOBILE-ANNOUNCEMENT-DETAIL',component:()=>import('./MobileAnnouncements.vue'),meta:mobileMeta('公告详情','announcementDetail')},
  {path:'applications',name:'MOBILE-APPLICATIONS',component:()=>import('./MobileApplications.vue'),meta:mobileMeta('我的申请','myApplicationRequests')}
 ]}
];

export default routes;
