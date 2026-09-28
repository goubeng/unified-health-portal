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

const previewMeta=resource=>{
 const source=pages.find(page=>page.path.startsWith('/portal/')&&page.resource===resource);
 return {...source,group:'门户预览',layout:'portal-preview'};
};

const routes=[
 {path:'/portal-preview/home',name:'PG-PREVIEW-HOME',component:PortalHomePreview,meta:{title:'门户首页预览',group:'门户预览',resource:'portalHomePreview',layout:'portal-preview'}},
 {path:'/portal-preview',component:PortalPreviewLayout,meta:{group:'门户预览',layout:'portal-preview'},children:[
  {path:'todos',name:'PG-PREVIEW-TODOS',component:PortalPage,meta:previewMeta('todos')},
  {path:'messages',name:'PG-PREVIEW-MESSAGES',component:PortalPage,meta:previewMeta('messages')},
  {path:'announcements',name:'PG-PREVIEW-ANNOUNCEMENTS',component:PortalPage,meta:previewMeta('announcements')},
  {path:'announcements/:id',name:'PG-PREVIEW-ANNOUNCEMENT-DETAIL',component:PortalPage,meta:previewMeta('announcementDetail')},
  {path:'apps',name:'PG-PREVIEW-APPS',component:PortalPage,meta:previewMeta('apps')},
  {path:'applications',name:'PG-PREVIEW-APPLICATIONS',component:PortalPage,meta:previewMeta('myApplicationRequests')}
 ]},
 {path:'/',redirect:'/portal/home'},
 ...compatibilityRedirects,
 ...pages.filter(page=>!page.hidden).map(page=>({
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
