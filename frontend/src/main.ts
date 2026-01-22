import { createApp } from 'vue'
import { createPinia } from 'pinia'
import piniaPluginPersistedstate from 'pinia-plugin-persistedstate'
import ElementPlus from 'element-plus'
import zhCn from 'element-plus/dist/locale/zh-cn.mjs'
import * as ElementPlusIconsVue from '@element-plus/icons-vue'
import 'element-plus/dist/index.css'
import '@/styles/global.scss'

import App from './App.vue'
import router from './router'

// 创建应用
const app = createApp(App)

// 配置Pinia
const pinia = createPinia()
pinia.use(piniaPluginPersistedstate)

// 注册Element Plus
app.use(ElementPlus, {
  locale: zhCn,
})

// 注册所有图标
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component)
}

// 使用插件
app.use(pinia)
app.use(router)

// 挂载应用
app.mount('#app')

// macOS开发环境日志
if (import.meta.env.DEV) {
  console.log('🚀 Vue 3前端应用已启动')
  console.log('📦 环境:', import.meta.env.MODE)
  console.log('🌐 API基础URL:', import.meta.env.VITE_API_BASE_URL)
  console.log('🔗 路由模式:', router.history.base)
}
EOF

# 更新App.vue
$ cat > src/App.vue << 'EOF'
<template>
  <router-view />
</template>

<script setup lang="ts">
import { onMounted } from 'vue'

onMounted(() => {
  // 在macOS上优化滚动性能
  if (navigator.userAgent.includes('Mac')) {
    document.body.style.webkitOverflowScrolling = 'touch'
  }
})
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  height: 100%;
}
</style>
