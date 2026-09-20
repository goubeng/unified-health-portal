import {createRouter,createWebHistory} from 'vue-router';
import {pages,can} from './config/pages.js';
import {actor} from './services/runtime.js';
import Login from './views/Login.vue';
import AuthResult from './views/AuthResult.vue';
import PortalPage from './views/PortalPage.vue';
const router=createRouter({history:createWebHistory(),routes:[{path:'/',redirect:'/portal/home'},...pages.map(p=>({path:p.path,name:p.id,component:p.group==='登录'?(p.path==='/login'?Login:AuthResult):PortalPage,meta:p})),{path:'/:pathMatch(.*)*',redirect:'/portal/home'}]});
router.beforeEach(to=>{if(to.meta.group==='登录')return true;if(!actor.value)return '/login';if(!can(actor.value,to.meta.scope))return '/portal/home';return true;});
export default router;
