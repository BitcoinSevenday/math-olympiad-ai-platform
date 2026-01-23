import { fileURLToPath, URL } from 'node:url'
import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import vueJsx from '@vitejs/plugin-vue-jsx'
import AutoImport from 'unplugin-auto-import/vite'
import Components from 'unplugin-vue-components/vite'
import { ElementPlusResolver } from 'unplugin-vue-components/resolvers'
import Icons from 'unplugin-icons/vite'
import IconsResolver from 'unplugin-icons/resolver'

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  // 加载环境变量
  const env = loadEnv(mode, process.cwd(), '')
  
  return {
    // macOS特化：开发服务器配置
    server: {
      port: 5173,
      host: true,  // 监听所有地址
      open: true,  // 自动打开浏览器
      cors: true,
      
      // macOS开发优化：热更新配置
      watch: {
        usePolling: false,  // macOS文件系统通知更高效
        interval: 100,      // 轮询间隔（如果需要）
      },
      
      // 代理配置，解决跨域
      proxy: {
        '/v1': {
          //target: env.VITE_API_BASE_URL || 'http://localhost:8000',
          target: 'http://localhost:8000',
          changeOrigin: true,
          //rewrite: (path) => path.replace(/^\/api/, ''),
          secure: false,
        },
      },
    },
    
    // 构建配置
    build: {
      target: 'esnext',
      minify: 'esbuild',
      sourcemap: mode === 'development',  // 开发环境生成sourcemap
      chunkSizeWarningLimit: 1000,  // 加大chunk大小警告限制
      
      // macOS特化：构建优化
      rollupOptions: {
        output: {
          manualChunks: {
            'vue-vendor': ['vue', 'vue-router', 'pinia'],
            'element-plus': ['element-plus', '@element-plus/icons-vue'],
            'axios-vendor': ['axios'],
          },
        },
      },
    },
    
    // 插件配置
    plugins: [
      vue(),
      vueJsx(),
      
      // 自动导入Element Plus组件
      AutoImport({
        imports: ['vue', 'vue-router', 'pinia'],
        resolvers: [
          ElementPlusResolver(),
          // 自动导入图标
          IconsResolver({
            prefix: 'Icon',
          }),
        ],
        dts: 'src/auto-imports.d.ts',
      }),
      
      Components({
        resolvers: [
          ElementPlusResolver(),
          // 自动注册图标组件
          IconsResolver({
            enabledCollections: ['ep'],
          }),
        ],
        dts: 'src/components.d.ts',
      }),
      
      // 图标自动导入
      Icons({
        autoInstall: true,
      }),
    ],
    
    // 路径别名
    resolve: {
      alias: {
        '@': fileURLToPath(new URL('./src', import.meta.url)),
        '@components': fileURLToPath(new URL('./src/components', import.meta.url)),
        '@views': fileURLToPath(new URL('./src/views', import.meta.url)),
        '@utils': fileURLToPath(new URL('./src/utils', import.meta.url)),
        '@stores': fileURLToPath(new URL('./src/stores', import.meta.url)),
        '@api': fileURLToPath(new URL('./src/api', import.meta.url)),
      },
    },
    
    // CSS预处理器配置
    css: {
      preprocessorOptions: {
        scss: {
          additionalData: `@use "@/styles/element/index.scss" as *;`,
        },
      },
    },
    
    // 环境变量前缀
    envPrefix: 'VITE_',
  }
})
