import {createRouter,createWebHistory} from 'vue-router';
import {pages,can} from './config/pages.js';
import {actor} from './services/runtime.js';
import Login from './views/Login.vue';
import AuthResult from './views/AuthResult.vue';
import PortalPage from './views/PortalPage.vue';
import PortalHomePreview from './views/PortalHomePreview.vue';
import PortalPreviewLayout from './views/PortalPreviewLayout.vue';

const compatibilityRedirects=[
 {path:'/admin/app-categories',redirect:'/admin/dictionaries'},
 {path:'/admin/permissions',redirect:'/admin/roles'}
];

const portalMeta=(resource,preview=false)=>{
 const source=pages.find(page=>page.path.startsWith('/portal/')&&page.resource===resource);
 return {...source,group:preview?'门户预览':source?.group,layout:preview?'portal-preview':'public-portal'};
};

const routes=[
 {path:'/portal/home',name:'PG-101',component:PortalHomePreview,meta:portalMeta('home')},
 {path:'/portal',component:PortalPreviewLayout,meta:{group:'个人事务',layout:'public-portal'},children:[
  {path:'todos',name:'PG-104',component:PortalPage,meta:portalMeta('todos')},
  {path:'messages',name:'PG-105',component:PortalPage,meta:portalMeta('messages')},
  {path:'announcements',name:'PG-106',component:PortalPage,meta:portalMeta('announcements')},
  {path:'announcements/:id',name:'PG-107',component:PortalPage,meta:portalMeta('announcementDetail')},
  {path:'apps/all',name:'PG-103',component:PortalPage,meta:portalMeta('apps')},
  {path:'applications',name:'PG-109',component:PortalPage,meta:portalMeta('myApplicationRequests')},
  {path:'profile',name:'PG-108',component:PortalPage,meta:portalMeta('profile')}
 ]},
 {path:'/portal/apps/mine',redirect:'/portal/apps/all'},
 {path:'/portal-preview/home',name:'PG-PREVIEW-HOME',component:PortalHomePreview,meta:{...portalMeta('home',true),title:'门户首页预览',resource:'portalHomePreview'}},
 {path:'/portal-preview',component:PortalPreviewLayout,meta:{group:'门户预览',layout:'portal-preview'},children:[
  {path:'todos',name:'PG-PREVIEW-TODOS',component:PortalPage,meta:portalMeta('todos',true)},
  {path:'messages',name:'PG-PREVIEW-MESSAGES',component:PortalPage,meta:portalMeta('messages',true)},
  {path:'announcements',name:'PG-PREVIEW-ANNOUNCEMENTS',component:PortalPage,meta:portalMeta('announcements',true)},
  {path:'announcements/:id',name:'PG-PREVIEW-ANNOUNCEMENT-DETAIL',component:PortalPage,meta:portalMeta('announcementDetail',true)},
  {path:'apps',name:'PG-PREVIEW-APPS',component:PortalPage,meta:portalMeta('apps',true)},
  {path:'applications',name:'PG-PREVIEW-APPLICATIONS',component:PortalPage,meta:portalMeta('myApplicationRequests',true)},
  {path:'profile',name:'PG-PREVIEW-PROFILE',component:PortalPage,meta:portalMeta('profile',true)}
 ]},
 {path:'/',redirect:'/portal/home'},
 ...compatibilityRedirects,
 {path:'/admin/profile',name:'PG-ADMIN-PROFILE',component:PortalPage,meta:{group:'系统管理',title:'个人信息',resource:'profile',scope:'any'}},
 ...pages.filter(page=>!page.hidden&&!page.path.startsWith('/portal')).map(page=>({
   path:page.path,
   name:page.id,
   component:page.group==='登录'?(page.path==='/login'?Login:AuthResult):PortalPage,
   meta:page
 })),
 {path:'/:pathMatch(.*)*',redirect:'/portal/home'}
];

const router=createRouter({history:createWebHistory(),routes});
router.beforeEach(to=>{
 if(to.meta.group==='登录')return true;
 if(!actor.value)return '/login';
 if(!can(actor.value,to.meta.scope))return '/portal/home';
 return true;
});
export default router;
