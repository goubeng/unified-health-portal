import {createApp} from 'vue';
import TDesign from 'tdesign-vue-next';
import 'tdesign-vue-next/es/style/index.css';
import './styles/index.css';
import App from './App.vue';
import router from './router.js';
import {initializeRuntime} from './services/runtime.js';
initializeRuntime().finally(()=>createApp(App).use(TDesign).use(router).mount('#app'));
