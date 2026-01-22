import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { login as loginApi, logout as logoutApi, getCurrentUser } from '@/api/auth'
import type { LoginForm, User } from '@/types/auth'

export const useAuthStore = defineStore('auth', () => {
  // 状态
  const token = ref<string | null>(localStorage.getItem('token'))
  const user = ref<User | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  // 计算属性
  const isAuthenticated = computed(() => !!token.value)
  const username = computed(() => user.value?.username || '')
  const role = computed(() => user.value?.role || 'user')

  // Actions
  const setToken = (newToken: string | null) => {
    token.value = newToken
    if (newToken) {
      localStorage.setItem('token', newToken)
    } else {
      localStorage.removeItem('token')
    }
  }

  const setUser = (userData: User | null) => {
    user.value = userData
  }

  const login = async (loginData: LoginForm) => {
    loading.value = true
    error.value = null
    try {
      const response = await loginApi(loginData)
      setToken(response.data.token)
      await fetchCurrentUser()
      return response
    } catch (err: any) {
      error.value = err.message || '登录失败'
      throw err
    } finally {
      loading.value = false
    }
  }

  const logout = async () => {
    try {
      await logoutApi()
    } catch (err) {
      console.error('登出失败:', err)
    } finally {
      clearAuth()
    }
  }

  const fetchCurrentUser = async () => {
    try {
      const response = await getCurrentUser()
      setUser(response.data)
    } catch (err) {
      console.error('获取用户信息失败:', err)
      clearAuth()
    }
  }

  const clearAuth = () => {
    setToken(null)
    setUser(null)
  }

  // 初始化时尝试获取用户信息
  if (token.value) {
    fetchCurrentUser()
  }

  return {
    token,
    user,
    loading,
    error,
    isAuthenticated,
    username,
    role,
    login,
    logout,
    fetchCurrentUser,
    clearAuth
  }
})
