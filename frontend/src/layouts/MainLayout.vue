<template>
  <div class="main-layout">
    <!-- 侧边栏导航 -->
    <el-container class="layout-container">
      <!-- 侧边栏 -->
      <el-aside :width="sidebarWidth" class="sidebar">
        <div class="sidebar-header">
          <div class="logo" @click="$router.push('/dashboard')">
            <span class="logo-icon">🧮</span>
            <span class="logo-text" v-show="!isCollapsed">奥赛AI平台</span>
          </div>
          <el-button
            type="text"
            class="collapse-btn"
            @click="toggleSidebar"
          >
            <el-icon>
              <component :is="isCollapsed ? 'Expand' : 'Fold'" />
            </el-icon>
          </el-button>
        </div>
        
        <!-- 导航菜单 -->
        <el-menu
          :default-active="activeMenu"
          class="sidebar-menu"
          :collapse="isCollapsed"
          :collapse-transition="false"
          router
        >
          <template v-for="route in sidebarRoutes" :key="route.name">
            <el-menu-item :index="route.path">
              <el-icon>
                <component :is="route.meta.icon" />
              </el-icon>
              <template #title>{{ route.meta.title }}</template>
            </el-menu-item>
          </template>
        </el-menu>
        
        <!-- 用户信息 -->
        <div class="sidebar-footer" v-show="!isCollapsed">
          <div class="user-info">
            <el-avatar :size="36" :src="userStore.userInfo?.avatar">
              {{ userStore.userInfo?.username?.charAt(0).toUpperCase() }}
            </el-avatar>
            <div class="user-details">
              <div class="username">{{ userStore.userInfo?.username }}</div>
              <div class="role">{{ roleText }}</div>
            </div>
            <el-dropdown @command="handleUserCommand">
              <el-button type="text" class="user-menu-btn">
                <el-icon><More /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="profile">
                    <el-icon><User /></el-icon>
                    个人中心
                  </el-dropdown-item>
                  <el-dropdown-item command="logout" divided>
                    <el-icon><SwitchButton /></el-icon>
                    退出登录
                  </el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </div>
        </div>
      </el-aside>
      
      <!-- 主内容区 -->
      <el-container class="main-container">
        <!-- 顶部栏 -->
        <el-header class="main-header">
          <div class="header-left">
            <el-breadcrumb separator="/">
              <el-breadcrumb-item :to="{ path: '/dashboard' }">首页</el-breadcrumb-item>
              <el-breadcrumb-item v-for="item in breadcrumb" :key="item.path">
                {{ item.meta.title }}
              </el-breadcrumb-item>
            </el-breadcrumb>
          </div>
          <div class="header-right">
            <!-- 全局搜索 -->
            <el-input
              v-model="searchKeyword"
              placeholder="搜索题目、知识点..."
              class="search-input"
              :style="{ width: isSearchExpanded ? '200px' : '120px' }"
              @focus="isSearchExpanded = true"
              @blur="isSearchExpanded = false"
              @keyup.enter="handleSearch"
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
            
            <!-- 通知 -->
            <el-dropdown class="notification-dropdown">
              <el-badge :value="3" class="notification-badge">
                <el-button type="text">
                  <el-icon :size="20"><Bell /></el-icon>
                </el-button>
              </el-badge>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item>你有新的练习推荐</el-dropdown-item>
                  <el-dropdown-item>错题需要复习</el-dropdown-item>
                  <el-dropdown-item>系统更新通知</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
            
            <!-- 主题切换 -->
            <el-tooltip content="切换主题">
              <el-button type="text" @click="toggleTheme">
                <el-icon :size="20">
                  <component :is="isDarkTheme ? 'Sunny' : 'Moon'" />
                </el-icon>
              </el-button>
            </el-tooltip>
          </div>
        </el-header>
        
        <!-- 页面内容 -->
        <el-main class="main-content">
          <router-view v-slot="{ Component }">
            <transition name="fade-slide" mode="out-in">
              <component :is="Component" />
            </transition>
          </router-view>
        </el-main>
        
        <!-- 页脚 -->
        <el-footer class="main-footer">
          <div class="footer-content">
            <span>© 2024 奥赛AI平台 v{{ appVersion }}</span>
            <div class="footer-links">
              <el-link type="info" :underline="false" @click="$router.push('/about')">关于我们</el-link>
              <el-link type="info" :underline="false" @click="$router.push('/privacy')">隐私政策</el-link>
              <el-link type="info" :underline="false" @click="$router.push('/terms')">使用条款</el-link>
            </div>
          </div>
        </el-footer>
      </el-container>
    </el-container>
  </div>
</template>

<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useUserStore } from '@/stores/user'
import {
  Odometer,
  Collection,
  User as UserIcon,
  More,
  SwitchButton,
  Search,
  Bell,
  Sunny,
  Moon,
  Expand,
  Fold
} from '@element-plus/icons-vue'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()

// 侧边栏状态
const isCollapsed = ref(false)
const sidebarWidth = computed(() => isCollapsed.value ? '64px' : '220px')

// 搜索相关
const searchKeyword = ref('')
const isSearchExpanded = ref(false)

// 主题相关
const isDarkTheme = ref(false)

// 应用版本
const appVersion = import.meta.env.VITE_APP_VERSION || '1.0.0'

// 当前激活的菜单
const activeMenu = computed(() => route.path)

// 面包屑导航
const breadcrumb = computed(() => {
  const matched = route.matched.filter(item => item.meta && item.meta.title)
  return matched.slice(1) // 去掉根路由
})

// 侧边栏路由（过滤掉没有图标的）
const sidebarRoutes = computed(() => {
  const routes = router.getRoutes()
  return routes.filter(route => 
    route.meta?.icon && 
    !route.meta?.hideNavbar &&
    route.meta?.requiresAuth
  )
})

// 用户角色文本
const roleText = computed(() => {
  const role = userStore.userInfo?.role
  const roleMap: Record<string, string> = {
    student: '学生',
    teacher: '老师',
    admin: '管理员',
    parent: '家长'
  }
  return roleMap[role || 'student']
})

// 切换侧边栏
const toggleSidebar = () => {
  isCollapsed.value = !isCollapsed.value
}

// 处理用户菜单命令
const handleUserCommand = (command: string) => {
  switch (command) {
    case 'profile':
      router.push('/profile')
      break
    case 'logout':
      userStore.logout()
      router.push('/login')
      break
  }
}

// 处理搜索
const handleSearch = () => {
  if (searchKeyword.value.trim()) {
    router.push({
      path: '/problems',
      query: { search: searchKeyword.value.trim() }
    })
    searchKeyword.value = ''
  }
}

// 切换主题
const toggleTheme = () => {
  isDarkTheme.value = !isDarkTheme.value
  const html = document.documentElement
  if (isDarkTheme.value) {
    html.classList.add('dark')
  } else {
    html.classList.remove('dark')
  }
}

// 监听路由变化，收起搜索框
watch(() => route.path, () => {
  isSearchExpanded.value = false
})
</script>

<style lang="scss" scoped>
.main-layout {
  height: 100vh;
  overflow: hidden;
}

.layout-container {
  height: 100%;
}

// 侧边栏样式
.sidebar {
  background: linear-gradient(180deg, #304156 0%, #263445 100%);
  border-right: 1px solid var(--el-border-color);
  transition: width 0.3s ease;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  
  .sidebar-header {
    height: 60px;
    padding: 0 20px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid rgba(255, 255, 255, 0.1);
    
    .logo {
      display: flex;
      align-items: center;
      gap: 12px;
      cursor: pointer;
      user-select: none;
      
      .logo-icon {
        font-size: 24px;
      }
      
      .logo-text {
        color: white;
        font-size: 18px;
        font-weight: 600;
        white-space: nowrap;
      }
    }
    
    .collapse-btn {
      color: rgba(255, 255, 255, 0.7);
      padding: 8px;
      
      &:hover {
        color: white;
        background: rgba(255, 255, 255, 0.1);
      }
    }
  }
  
  .sidebar-menu {
    flex: 1;
    border-right: none;
    background: transparent;
    
    :deep(.el-menu-item) {
      color: rgba(255, 255, 255, 0.7);
      height: 56px;
      margin: 4px 12px;
      border-radius: 8px;
      
      &:hover {
        background: rgba(255, 255, 255, 0.1);
        color: white;
      }
      
      &.is-active {
        background: var(--el-color-primary);
        color: white;
        
        &:hover {
          background: var(--el-color-primary-light-3);
        }
      }
      
      .el-icon {
        font-size: 18px;
        margin-right: 12px;
      }
    }
  }
  
  .sidebar-footer {
    padding: 20px;
    border-top: 1px solid rgba(255, 255, 255, 0.1);
    
    .user-info {
      display: flex;
      align-items: center;
      gap: 12px;
      
      .user-details {
        flex: 1;
        
        .username {
          color: white;
          font-weight: 500;
          font-size: 14px;
          margin-bottom: 2px;
        }
        
        .role {
          color: rgba(255, 255, 255, 0.6);
          font-size: 12px;
        }
      }
      
      .user-menu-btn {
        color: rgba(255, 255, 255, 0.7);
        padding: 4px;
        
        &:hover {
          color: white;
        }
      }
    }
  }
}

// 主内容区样式
.main-container {
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.main-header {
  height: 60px;
  padding: 0 24px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  border-bottom: 1px solid var(--el-border-color);
  background: white;
  
  .header-left {
    .el-breadcrumb {
      font-size: 14px;
    }
  }
  
  .header-right {
    display: flex;
    align-items: center;
    gap: 16px;
    
    .search-input {
      transition: width 0.3s ease;
      
      :deep(.el-input__wrapper) {
        border-radius: 16px;
        padding-left: 12px;
        padding-right: 12px;
      }
    }
    
    .notification-dropdown {
      .notification-badge {
        :deep(.el-badge__content) {
          transform: translate(50%, -50%);
        }
      }
    }
    
    .el-button {
      color: var(--el-text-color-regular);
      
      &:hover {
        color: var(--el-color-primary);
      }
    }
  }
}

.main-content {
  flex: 1;
  padding: 24px;
  background: var(--el-bg-color-page);
  overflow-y: auto;
}

.main-footer {
  height: 48px;
  padding: 0 24px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-top: 1px solid var(--el-border-color);
  background: white;
  font-size: 12px;
  color: var(--el-text-color-secondary);
  
  .footer-content {
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: space-between;
    
    .footer-links {
      display: flex;
      gap: 24px;
      
      .el-link {
        font-size: 12px;
      }
    }
  }
}

// 过渡动画
.fade-slide-enter-active,
.fade-slide-leave-active {
  transition: all 0.3s ease;
}

.fade-slide-enter-from {
  opacity: 0;
  transform: translateY(10px);
}

.fade-slide-leave-to {
  opacity: 0;
  transform: translateY(-10px);
}

// 暗色模式适配
:global(.dark) {
  .main-header,
  .main-footer {
    background: var(--el-bg-color);
  }
}
</style>
