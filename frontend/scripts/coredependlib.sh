echo "pnpm 安装依赖"
pnpm add element-plus @element-plus/icons-vue
pnpm add axios
pnpm add pinia-plugin-persistedstate  
pnpm add vue-i18n  

echo "pnpm 安装 开发依赖"
pnpm add -D sass sass-loader
pnpm add -D @types/node
pnpm add -D unplugin-auto-import unplugin-vue-components
pnpm add -D @iconify-json/ep

echo "依赖全部安装完成"
