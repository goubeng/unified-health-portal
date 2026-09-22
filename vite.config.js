import {defineConfig} from 'vite';
import vue from '@vitejs/plugin-vue';
export default defineConfig({plugins:[vue()],server:{proxy:{'/api/portal':{target:'http://127.0.0.1:4011'}}},build:{rollupOptions:{output:{manualChunks:{ui:['tdesign-vue-next'],vue:['vue','vue-router']}}}}});