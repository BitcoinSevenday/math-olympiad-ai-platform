/**
 * 题目管理相关API
 */
import { get, post, put, del } from '@/utils/request'
import type {
  Problem,
  ProblemCreateRequest,
  ProblemUpdateRequest,
  ProblemListResponse,
  ProblemFilter,
  ProblemStats,
  PracticeProblem
} from '@/types/problem'

// 获取题目列表
export function getProblems(params?: ProblemFilter): Promise<ProblemListResponse> {
  return get('/api/v1/problems/', { params })
}

// 获取题目详情
export function getProblem(id: number): Promise<Problem> {
  return get(`/api/v1/problems/${id}`)
}

// 创建题目
export function createProblem(data: ProblemCreateRequest): Promise<Problem> {
  return post('/api/v1/problems/', data)
}

// 更新题目
export function updateProblem(id: number, data: ProblemUpdateRequest): Promise<Problem> {
  return put(`/api/v1/problems/${id}`, data)
}

// 删除题目
export function deleteProblem(id: number): Promise<void> {
  return del(`/api/v1/problems/${id}`)
}

// 发布/取消发布题目
export function publishProblem(id: number, publish: boolean = true): Promise<void> {
  return post(`/api/v1/problems/${id}/publish`, { publish })
}

// 获取题目统计
export function getProblemStats(): Promise<ProblemStats> {
  return get('/api/v1/problems/stats/summary')
}

// 获取随机练习题目
export function getRandomProblems(params: {
  count?: number
  difficulty?: number[]
  knowledge_point_ids?: number[]
}): Promise<PracticeProblem[]> {
  return get('/api/v1/problems/practice/random', { params })
}

// 记录题目答题
export function recordProblemAttempt(id: number, isCorrect: boolean): Promise<void> {
  return post(`/api/v1/problems/${id}/attempt`, { is_correct: isCorrect })
}

// 搜索题目
export function searchProblems(keyword: string, params?: {
  skip?: number
  limit?: number
}): Promise<Problem[]> {
  return get(`/api/v1/problems/search/${keyword}`, { params })
}
