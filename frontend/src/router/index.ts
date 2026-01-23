import { createRouter, createWebHistory } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { ElMessage } from 'element-plus'

// 路由组件（使用懒加载）
const Login = () => import('@/views/auth/Login.vue')
const Register = () => import('@/views/auth/Register.vue')
const Layout = () => import('@/layouts/MainLayout.vue')
const Dashboard = () => import('@/views/dashboard/Dashboard.vue')
const ProblemList = () => import('@/views/problem/ProblemList.vue')
const ProblemEdit = () => import('@/views/problem/ProblemEdit.vue')
const ProblemCreate = () => import('@/views/problem/ProblemCreate.vue')
const ProblemDetail = () => import('@/views/problem/ProblemDetail.vue')
const Profile = () => import('@/views/user/Profile.vue')
const NotFound = () => import('@/views/error/NotFound.vue')

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes: [
    {
      path: '/',
      redirect: '/dashboard',
    },
    {
      path: '/login',
      name: 'Login',
      component: Login,
      meta: {
        title: '登录',
        requiresAuth: false,
        hideNavbar: true,
      },
    },
    {
      path: '/register',
      name: 'Register',
      component: Register,
      meta: {
        title: '注册',
        requiresAuth: false,
        hideNavbar: true,
      },
    },
    {
      path: '/',
      component: Layout,
      meta: {
        requiresAuth: true,
      },
      children: [
        {
          path: 'dashboard',
          name: 'Dashboard',
          component: Dashboard,
          meta: {
            title: '仪表板',
            icon: 'Odometer',
            requiresAuth: true,
          },
        },
        {
          path: 'problems',
          name: 'ProblemList',
          component: ProblemList,
          meta: {
            title: '题库管理',
            icon: 'Collection',
            requiresAuth: true,
          },
        },
        {
          path: 'problems/create',
          name: 'ProblemCreate',
          component: ProblemCreate,
          meta: {
            title: '创建题目',
            requiresAuth: true,
            requiresTeacherOrAdmin: true,
          },
        },
        {
          path: 'problems/:id',
          name: 'ProblemDetail',
          component: ProblemDetail,
          props: true, // 启用 props 传递路由参数
          meta: {
            title: '题目详情',
            requiresAuth: true,
          },
        },
        {
          path: 'problems/:id/edit',
          name: 'ProblemEdit',
          component: ProblemEdit,
          props: true, // 启用 props 传递路由参数
          meta: {
            title: '编辑题目',
            requiresAuth: true,
            requiresTeacherOrAdmin: true,
          },
        },
        {
          path: 'profile',
          name: 'Profile',
          component: Profile,
          meta: {
            title: '个人中心',
            icon: 'User',
            requiresAuth: true,
          },
        },
      ],
    },
    {
      path: '/:pathMatch(.*)*',
      name: 'NotFound',
      component: NotFound,
      meta: {
        title: '页面不存在',
        hideNavbar: true,
      },
    },
  ],
})

// 全局前置守卫
router.beforeEach(async (to, from, next) => {
  const userStore = useUserStore()
  
  // 设置页面标题
  const title = to.meta.title as string || 'AI平台'
  document.title = `${title} - AI平台`
  
  // 检查是否需要认证
  if (to.meta.requiresAuth) {
    if (!userStore.isLoggedIn) {
      ElMessage.warning('请先登录')
      next('/login')
      return
    }
    
    // 检查是否需要老师或管理员权限
    if (to.meta.requiresTeacherOrAdmin) {
      if (!userStore.isTeacher && !userStore.isAdmin) {
        ElMessage.warning('需要老师或管理员权限')
        next('/dashboard')
        return
      }
    }
    
    // 检查是否需要管理员权限
    if (to.meta.requiresAdmin) {
      if (!userStore.isAdmin) {
        ElMessage.warning('需要管理员权限')
        next('/dashboard')
        return
      }
    }
    
    // 如果用户信息未加载，尝试加载
    if (!userStore.userInfo) {
      try {
        await userStore.fetchUserInfo()
      } catch (error) {
        console.error('加载用户信息失败:', error)
        // 如果加载失败，可能是token过期，清除状态
        userStore.logout()
        ElMessage.error('登录已过期，请重新登录')
        next('/login')
        return
      }
    }
  }
  
  // 如果已登录，访问登录/注册页则重定向到首页
  if ((to.path === '/login' || to.path === '/register') && userStore.isLoggedIn) {
    next('/dashboard')
    return
  }
  
  next()
})

// 全局后置钩子
router.afterEach((to, from) => {
  // 回到页面顶部
  window.scrollTo(0, 0)
  
  // 开发环境日志
  if (import.meta.env.DEV) {
    console.log(`🛣️  路由跳转: ${from.path} -> ${to.path}`)
  }
})

export default router