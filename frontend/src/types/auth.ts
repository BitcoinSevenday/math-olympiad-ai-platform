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
EOF

$ cat > src/types/problem.ts << 'EOF'
/**
 * 题目相关类型定义
 */

// 题目选项
export interface ProblemOptions {
  A: string
  B: string
  C: string
  D: string
}

// 知识点
export interface KnowledgePoint {
  id: number
  name: string
  code: string
  parent_id?: number
  level: number
  description?: string
  weight: number
  problem_count: number
  created_at: string
}

// 题目
export interface Problem {
  id: number
  title: string
  content: string
  content_type: 'text' | 'markdown' | 'latex'
  options: ProblemOptions
  correct_answer: string
  solution?: string
  solution_type?: string
  difficulty: number
  source_type?: string
  source_year?: number
  source_detail?: string
  estimated_time?: number
  success_rate?: number
  is_published: boolean
  is_deleted: boolean
  review_status: 'pending' | 'approved' | 'rejected'
  total_attempts: number
  correct_attempts: number
  accuracy_rate: number
  created_by: number
  created_at: string
  updated_at?: string
  knowledge_points?: KnowledgePoint[]
  creator?: {
    id: number
    username: string
    full_name?: string
  }
}

// 创建题目请求
export interface ProblemCreateRequest {
  title: string
  content: string
  content_type?: string
  options: ProblemOptions
  correct_answer: string
  solution?: string
  solution_type?: string
  difficulty?: number
  source_type?: string
  source_year?: number
  source_detail?: string
  estimated_time?: number
  knowledge_point_ids?: number[]
  is_published?: boolean
}

// 更新题目请求
export interface ProblemUpdateRequest {
  title?: string
  content?: string
  content_type?: string
  options?: ProblemOptions
  correct_answer?: string
  solution?: string
  solution_type?: string
  difficulty?: number
  source_type?: string
  source_year?: number
  source_detail?: string
  estimated_time?: number
  knowledge_point_ids?: number[]
  is_published?: boolean
}

// 题目过滤条件
export interface ProblemFilter {
  difficulty?: number[]
  source_type?: string
  source_year?: number
  knowledge_point_id?: number
  is_published?: boolean
  search?: string
  skip?: number
  limit?: number
  sort_by?: string
  sort_order?: 'asc' | 'desc'
}

// 题目列表响应
export interface ProblemListResponse {
  problems: Problem[]
  total: number
  page: number
  page_size: number
}

// 题目统计
export interface ProblemStats {
  total_problems: number
  published_problems: number
  by_difficulty: Record<number, number>
  by_source: Record<string, number>
  avg_accuracy: number
}

// 练习题目（隐藏答案）
export interface PracticeProblem {
  id: number
  title: string
  content: string
  content_type: string
  options: ProblemOptions
  difficulty: number
  estimated_time?: number
  knowledge_points?: KnowledgePoint[]
}
