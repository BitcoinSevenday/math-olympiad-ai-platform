/**
 * 用户状态管理
 */
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import type { UserInfo } from '@/types/auth'
import * as authApi from '@/api/auth'
import { ElMessage } from 'element-plus'

export const useUserStore = defineStore('user', () => {
  // 状态
  const token = ref<string>('')
  const userInfo = ref<UserInfo | null>(null)
  const isLoggedIn = computed(() => !!token.value)
  const isAdmin = computed(() => userInfo.value?.role === 'admin')
  const isTeacher = computed(() => userInfo.value?.role === 'teacher')
  const isStudent = computed(() => userInfo.value?.role === 'student')

  // 从本地存储加载状态
  function loadFromStorage() {
    const savedToken = localStorage.getItem('access_token')
    const savedUser = localStorage.getItem('user_info')
    
    if (savedToken) {
      token.value = savedToken
    }
    
    if (savedUser) {
      try {
        userInfo.value = JSON.parse(savedUser)
      } catch (error) {
        console.error('解析用户信息失败:', error)
        localStorage.removeItem('user_info')
      }
    }
  }

  // 保存到本地存储
  function saveToStorage() {
    if (token.value) {
      localStorage.setItem('access_token', token.value)
    }
    
    if (userInfo.value) {
      localStorage.setItem('user_info', JSON.stringify(userInfo.value))
    }
  }

  // 清除本地存储
  function clearStorage() {
    localStorage.removeItem('access_token')
    localStorage.removeItem('user_info')
  }

  // 登录
  async function login(username: string, password: string) {
    try {
      const response = await authApi.login({ username, password })
      
      token.value = response.access_token
      await fetchUserInfo()
      
      ElMessage.success('登录成功')
      return true
    } catch (error: any) {
      ElMessage.error(error.message || '登录失败')
      return false
    }
  }

  // 注册
  async function register(data: {
    username: string
    password: string
    email?: string
    full_name?: string
    role?: string
    grade?: string
    school?: string
  }) {
    try {
      const user = await authApi.register(data)
      userInfo.value = user
      saveToStorage()
      
      ElMessage.success('注册成功')
      return true
    } catch (error: any) {
      ElMessage.error(error.message || '注册失败')
      return false
    }
  }

  // 获取用户信息
  async function fetchUserInfo() {
    try {
      const user = await authApi.getCurrentUser()
      userInfo.value = user
      saveToStorage()
    } catch (error) {
      console.error('获取用户信息失败:', error)
      // 获取失败时不清理token，可能是网络问题
    }
  }

  // 登出
  function logout() {
    token.value = ''
    userInfo.value = null
    clearStorage()
    
    // 调用后端登出API（可选）
    authApi.logout().catch(() => {
      // 忽略登出API错误
    })
  }

  // 修改密码
  async function changePassword(currentPassword: string, newPassword: string) {
    try {
      await authApi.changePassword({
        current_password: currentPassword,
        new_password: newPassword
      })
      
      ElMessage.success('密码修改成功')
      return true
    } catch (error: any) {
      ElMessage.error(error.message || '密码修改失败')
      return false
    }
  }

  // 检查用户名是否可用
  async function checkUsernameAvailable(username: string): Promise<boolean> {
    try {
      const response = await authApi.checkUsername(username)
      return response.available
    } catch (error) {
      console.error('检查用户名失败:', error)
      return false
    }
  }

  // 检查邮箱是否可用
  async function checkEmailAvailable(email: string): Promise<boolean> {
    try {
      const response = await authApi.checkEmail(email)
      return response.available
    } catch (error) {
      console.error('检查邮箱失败:', error)
      return false
    }
  }

  // 初始化
  loadFromStorage()
  
  // 如果已有token，尝试获取用户信息
  if (token.value && !userInfo.value) {
    fetchUserInfo().catch(() => {
      // 如果获取失败，可能是token过期，清除token
      logout()
    })
  }

  return {
    // 状态
    token,
    userInfo,
    isLoggedIn,
    isAdmin,
    isTeacher,
    isStudent,
    
    // 操作
    login,
    register,
    logout,
    fetchUserInfo,
    changePassword,
    checkUsernameAvailable,
    checkEmailAvailable,
  }
}, {
  persist: {
    key: 'user-store',
    paths: ['token', 'userInfo'],
  },
})
