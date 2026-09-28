import {createRouter,createWebHistory} from 'vue-router';
import {pages,can} from './config/pages.js';
import {actor} from './services/runtime.js';
import Login from './views/Login.vue';
import AuthResult from './views/AuthResult.vue';
import PortalPage from './views/PortalPage.vue';
import PortalHomePreview from './views/PortalHomePreview.vue';

const compatibilityRedirects=[
 {path:'/admin/app-categories',redirect:'/admin/dictionaries'},
 {path:'/admin/permissions',redirect:'/admin/roles'}
];

const routes=[
 {path:'/portal-preview/home',name:'PG-PREVIEW-HOME',component:PortalHomePreview,meta:{title:'门户首页预览',group:'门户预览',resource:'portalHomePreview',layout:'portal-preview'}},
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
