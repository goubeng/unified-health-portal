import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';

const source=file=>fs.readFileSync(file,'utf8');

test('管理端顶部不再提供用户身份切换入口',()=>{
 const app=source('src/App.vue');
 const topbar=app.split('<header class="topbar">')[1]?.split('</header>')[0]||'';
 assert(topbar.includes('class="account-entry"'));
 assert(topbar.includes('个人信息'));
 assert(!topbar.includes('切换用户'));
 assert(!topbar.includes('切换身份'));
 assert(!topbar.includes('UserSwitcher'));
 assert(!app.includes('switchActor('));
});

 test('公众门户首页和二级页顶部消息图标与管理端一致',()=>{
  const app=source('src/App.vue');
  const adminMessage=app.match(/aria-label="(?:消息中心|我的消息)"[^>]*>[\s\S]*?<template #icon><(\w+Icon) size="([^"]+)"\/><\/template>/);
  assert(adminMessage,'管理端消息按钮应保留图标');
  for(const file of ['src/views/PortalHomePreview.vue','src/views/PortalPreviewLayout.vue']){
   const publicPage=source(file);
   const publicMessage=publicPage.match(/aria-label="(?:消息中心|我的消息)"[^>]*>[\s\S]*?<(\w+Icon) size="([^"]+)"\s*\/>/);
  assert(publicMessage,`${file} 顶部消息按钮应保留图标`);
  assert.deepEqual(publicMessage.slice(1),adminMessage.slice(1),`${file} 顶部消息图标和尺寸应与管理端一致`);
  assert.match(publicPage, /import\s*\{[^}]*\bMailIcon\b[^}]*\}\s*from\s*['"]tdesign-icons-vue-next['"]/, `${file} 应显式导入 MailIcon，确保二级页面实际渲染`);
 }
});

test('管理端个人信息留在管理框架内且公众端继续使用独立布局',()=>{
 const app=source('src/App.vue');
 const router=source('src/router.js');
 const page=source('src/views/PortalPage.vue');
 assert(app.includes("router.push(admin.value?'/admin/profile':'/portal/profile')"));
 assert(router.includes("{path:'/admin/profile',name:'PG-ADMIN-PROFILE',component:PortalPage"));
 assert(!router.match(/path:'\/admin\/profile'[^\n]*layout:'public-portal'/));
 assert(router.includes("{path:'profile',name:'PG-108',component:PortalPage,meta:portalMeta('profile')}"));
 assert(app.includes("['portal-preview','public-portal'].includes(route.meta.layout)"));
 assert(app.includes('class="app-shell"'));
 assert(page.includes('<PersonalProfile v-else-if="resource===\'profile\'" :user="actor"/>'));
});

test('个人信息区分本地管理账号与公众身份资料来源',()=>{
 const profile=source('src/components/portal/PersonalProfile.vue');
 const presentation=source('src/components/portal/presentation.js');
 assert(profile.includes("const localAccount=computed(()=>props.user.authType==='LOCAL')"));
 assert(profile.includes("localAccount?'本地管理账号':label(user.userType)"));
 assert(profile.includes("label:localAccount.value?'账号类型':'用户类别'"));
 assert(profile.includes("value:localAccount.value?'本地管理账号':label(props.user.userType)"));
 assert(profile.includes("localAccount?'本地管理账号资料由平台管理员维护。':`个人身份资料由${source(user)}提供。如需更新，请前往对应平台维护。`"));
 assert(presentation.includes("user?.authType==='LOCAL'?'门户本地':user?.userType==='CITIZEN'?'闽政通':'闽政务'"));
});
