eclare module '*.vue' {
  import type { DefineComponent } from 'vue'
  const component: DefineComponent<{}, {}, any>
  export default component
}

// 环境变量类型声明
interface ImportMetaEnv {
  readonly VITE_APP_TITLE: string
  readonly VITE_API_BASE_URL: string
  readonly VITE_BASE_URL: string
  readonly VITE_NODE_ENV: 'development' | 'production' | 'test'
  // 更多环境变量...
}

interface ImportMeta {
  readonly env: ImportMetaEnv
}
