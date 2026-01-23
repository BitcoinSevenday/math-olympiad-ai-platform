/**
 * 用户认证相关类型定义
 */

// 登录请求
export interface LoginRequest {
  username: string
  password: string
}

// 注册请求
export interface RegisterRequest {
  username: string
  password: string
  email?: string
  full_name?: string
  role?: 'student' | 'teacher' | 'admin' | 'parent'
  grade?: string
  school?: string
}

// 修改密码请求
export interface ChangePasswordRequest {
  current_password: string
  new_password: string
}

// Token响应
export interface TokenResponse {
  access_token: string
  token_type: string
  expires_in: number
}

// 用户信息
export interface UserInfo {
  id: number
  username: string
  email?: string
  full_name?: string
  role: 'student' | 'teacher' | 'admin' | 'parent'
  grade?: string
  school?: string
  is_active: boolean
  is_verified: boolean
  created_at: string
  last_login_at?: string
}

// 用户统计
export interface UserStats {
  total_practice_sessions: number
  total_questions_attempted: number
  overall_accuracy: number
  total_practice_time: number
  average_session_duration: number
}
