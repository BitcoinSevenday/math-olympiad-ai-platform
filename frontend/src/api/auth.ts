/**
 * 用户认证相关API
 */
import { post, get } from '@/utils/request'
import type {
  LoginRequest,
  RegisterRequest,
  UserInfo,
  TokenResponse,
  ChangePasswordRequest
} from '@/types/auth'

// 用户登录
export function login(data: LoginRequest): Promise<TokenResponse> {
  return post('/api/v1/auth/login', data)
}

// 用户注册
export function register(data: RegisterRequest): Promise<UserInfo> {
  return post('/api/v1/auth/register', data)
}

// 获取当前用户信息
export function getCurrentUser(): Promise<UserInfo> {
  return get('/api/v1/auth/me')
}

// 刷新token
export function refreshToken(refreshToken: string): Promise<TokenResponse> {
  return post('/api/v1/auth/refresh', { refresh_token: refreshToken })
}

// 修改密码
export function changePassword(data: ChangePasswordRequest): Promise<void> {
  return post('/api/v1/auth/change-password', data)
}

// 登出
export function logout(): Promise<void> {
  return post('/api/v1/auth/logout')
}

// 检查用户名是否可用
export function checkUsername(username: string): Promise<{ available: boolean }> {
  return get(`/api/v1/auth/check-username/${username}`)
}

// 检查邮箱是否可用
export function checkEmail(email: string): Promise<{ available: boolean }> {
  return get(`/api/v1/auth/check-email/${email}`)
}

// 健康检查
export function healthCheck(): Promise<{
  status: string
  service: string
  timestamp: number
}> {
  return get('/health')
}
