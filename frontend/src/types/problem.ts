/**
 * 题目内容类型
 */
export type ContentType = 'text' | 'markdown' | 'latex';

/**
 * 题目来源类型
 */
export type SourceType = 'AMC8' | '迎春杯' | '华杯赛' | string; // 允许其他自定义来源

/**
 * 审核状态
 */
export type ReviewStatus = 'pending' | 'approved' | 'rejected';


/**
 * 题目选项接口（JSONB 格式）
 */
export interface ProblemOptions {
  [key: string]: string; // 例如: { "A": "选项A的内容", "B": "选项B的内容" }
}

/**
 * 题目统计信息
 */
export interface ProblemStatistics {
  total_attempts: number;
  correct_attempts: number;
  success_rate?: number; // 计算字段，可根据前两个字段计算
}

/**
 * 题目基础接口
 */
export interface ProblemBase {
  // 基本信息
  id: number;
  title: string;
  content: string;
  content_type: ContentType;
  
  // 选项
  options: ProblemOptions;
  
  // 答案和解析
  correct_answer: string; // 'A', 'B', 'C', 'D'
  solution?: string;
  solution_type?: ContentType;
  
  // 难度和分类
  difficulty: number; // 1-5
  source_type?: SourceType;
  source_year?: number;
  source_detail?: string;
  
  // 预估属性
  estimated_time?: number; // 秒
  success_rate?: number; // 0-1 的小数
  
  // 状态控制
  is_published: boolean;
  is_deleted: boolean;
  
  // 审核信息
  reviewed_by?: number;
  reviewed_at?: Date;
  review_status: ReviewStatus;
  
  // 统计信息
  total_attempts: number;
  correct_attempts: number;
  
  // 创建信息
  created_by?: number;
  created_at: Date;
  updated_at: Date;
  
  // 全文搜索字段（PostgreSQL 特有）
  search_vector?: any;
}

/**
 * 题目完整接口（包含关联的用户信息）
 */
export interface Problem extends ProblemBase {
  // 关联的用户信息（可选，根据需要扩展）
  creator_name?: string;
  reviewer_name?: string;
}

/**
 * 创建题目请求接口
 */
export interface CreateProblemRequest {
  title: string;
  content: string;
  content_type?: ContentType;
  options: ProblemOptions;
  correct_answer: string;
  solution?: string;
  solution_type?: ContentType;
  difficulty: number;
  source_type?: SourceType;
  source_year?: number;
  source_detail?: string;
  estimated_time?: number;
  is_published?: boolean;
}

/**
 * 更新题目请求接口
 */
export interface UpdateProblemRequest extends Partial<CreateProblemRequest> {
  review_status?: ReviewStatus;
  is_deleted?: boolean;
}

/**
 * 题目查询参数接口
 */
export interface ProblemQueryParams {
  // 分页参数
  page?: number;
  limit?: number;
  
  // 筛选参数
  difficulty?: number | number[];
  source_type?: SourceType | SourceType[];
  source_year?: number | number[];
  is_published?: boolean;
  review_status?: ReviewStatus | ReviewStatus[];
  created_by?: number;
  
  // 搜索参数
  search?: string; // 全文搜索关键词
  title?: string; // 标题模糊搜索
  
  // 排序参数
  sort_by?: 'id' | 'title' | 'difficulty' | 'created_at' | 'updated_at' | 'success_rate';
  sort_order?: 'asc' | 'desc';
}

/**
 * 题目列表响应接口
 */
export interface ProblemListResponse {
  problems: Problem[];
  total: number;
  page: number;
  limit: number;
  total_pages: number;
}

/**
 * 题目统计响应接口
 */
export interface ProblemStats {
  total: number;
  published: number;
  pending_review: number;
  by_difficulty: {
    [difficulty: number]: number;
  };
  by_source_type: {
    [sourceType: string]: number;
  };
}

/**
 * 题目难度枚举（前端显示用）
 */
export const DIFFICULTY_LABELS: Record<number, string> = {
  1: '非常简单',
  2: '简单',
  3: '中等',
  4: '困难',
  5: '非常困难'
};

/**
 * 审核状态枚举（前端显示用）
 */
export const REVIEW_STATUS_LABELS: Record<ReviewStatus, string> = {
  pending: '待审核',
  approved: '已通过',
  rejected: '已拒绝'
};

/**
 * 题目来源类型枚举（前端显示用）
 */
export const SOURCE_TYPE_LABELS: Record<string, string> = {
  'AMC8': '美国数学竞赛8',
  '迎春杯': '迎春杯数学竞赛',
  '华杯赛': '华罗庚金杯数学竞赛'
};

/**
 * 计算题目的正确率
 */
export function calculateSuccessRate(
  correctAttempts: number, 
  totalAttempts: number
): number {
  if (totalAttempts === 0) return 0;
  return Math.round((correctAttempts / totalAttempts) * 10000) / 10000; // 保留4位小数
}

/**
 * 获取难度文本
 */
export function getDifficultyText(difficulty: number): string {
  return DIFFICULTY_LABELS[difficulty] || `难度 ${difficulty}`;
}

/**
 * 获取审核状态文本
 */
export function getReviewStatusText(status: ReviewStatus): string {
  return REVIEW_STATUS_LABELS[status] || status;
}

/**
 * 获取来源类型文本
 */
export function getSourceTypeText(sourceType?: string): string {
  if (!sourceType) return '未知来源';
  return SOURCE_TYPE_LABELS[sourceType] || sourceType;
}

/**
 * 题目过滤器类型
 */
export interface ProblemFilter {
  difficulties?: number[];
  sourceTypes?: string[];
  years?: number[];
  searchText?: string;
  onlyPublished?: boolean;
}

/**
 * 题目答案提交接口
 */
export interface SubmitAnswerRequest {
  problemId: number;
  answer: string;
  timeSpent?: number; // 秒
}

/**
 * 题目答案响应接口
 */
export interface SubmitAnswerResponse {
  is_correct: boolean;
  correct_answer: string;
  solution?: string;
  solution_type?: ContentType;
  explanation?: string;
  statistics?: {
    current_success_rate: number;
    total_attempts: number;
    correct_attempts: number;
  };
}

/**
 * 题目详情扩展接口（包含用户尝试记录）
 */
export interface ProblemWithAttempt extends Problem {
  user_attempt?: {
    attempted: boolean;
    is_correct?: boolean;
    user_answer?: string;
    attempted_at?: Date;
    time_spent?: number;
  };
}

/**
 * 题目导入/导出格式
 */
export interface ProblemExportFormat {
  version: string;
  exported_at: string;
  problems: Array<{
    title: string;
    content: string;
    content_type: ContentType;
    options: ProblemOptions;
    correct_answer: string;
    solution?: string;
    solution_type?: ContentType;
    difficulty: number;
    source_type?: string;
    source_year?: number;
    source_detail?: string;
    estimated_time?: number;
  }>;
}