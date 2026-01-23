// src/types/problem-knowledge-point.ts

import type { Problem } from "./problem";

/**
 * 题目-知识点关联接口
 */
export interface ProblemKnowledgePoint {
  problem_id: number;
  knowledge_point_id: number;
  is_primary: boolean;
  weight: number; // 0-1 的小数，默认 1.0
  created_at: Date;
}

/**
 * 知识点基础信息（从 knowledge_points 表）
 */
export interface KnowledgePointBase {
  id: number;
  name: string;
  description?: string;
  parent_id?: number; // 上级知识点ID
  level: number; // 层级，如 1,2,3
  order_index: number; // 排序索引
  is_active: boolean;
}

/**
 * 带题目关联的知识点
 */
export interface KnowledgePointWithRelation extends KnowledgePointBase {
  problem_relation?: {
    is_primary: boolean;
    weight: number;
  };
}

/**
 * 带知识点信息的题目
 */
export interface ProblemWithKnowledgePoints extends Problem {
  knowledge_points: KnowledgePointWithRelation[];
  primary_knowledge_points?: KnowledgePointWithRelation[];
}

/**
 * 创建题目-知识点关联请求
 */
export interface CreateProblemKnowledgePointRequest {
  problem_id: number;
  knowledge_point_id: number;
  is_primary?: boolean;
  weight?: number;
}

/**
 * 批量关联知识点请求
 */
export interface BatchLinkKnowledgePointsRequest {
  problem_id: number;
  knowledge_points: Array<{
    knowledge_point_id: number;
    is_primary?: boolean;
    weight?: number;
  }>;
  replace_existing?: boolean; // 是否替换现有关联
}

/**
 * 更新题目-知识点关联请求
 */
export interface UpdateProblemKnowledgePointRequest {
  is_primary?: boolean;
  weight?: number;
}

/**
 * 题目知识点查询参数
 */
export interface ProblemKnowledgePointQueryParams {
  problem_id?: number | number[];
  knowledge_point_id?: number | number[];
  is_primary?: boolean;
  min_weight?: number;
  max_weight?: number;
  
  // 关联查询参数
  with_knowledge_point_details?: boolean;
  with_problem_details?: boolean;
  
  // 分页
  page?: number;
  limit?: number;
}

/**
 * 根据知识点筛选题目参数
 */
export interface ProblemsByKnowledgePointParams {
  knowledge_point_ids: number[]; // 知识点ID数组
  require_all?: boolean; // 是否要求包含所有知识点
  is_primary_only?: boolean; // 是否只包含主要知识点
  min_weight?: number; // 最小权重
  
  // 分页和排序
  page?: number;
  limit?: number;
  sort_by?: 'difficulty' | 'created_at' | 'total_attempts' | 'success_rate';
  sort_order?: 'asc' | 'desc';
}

/**
 * 知识点统计信息
 */
export interface KnowledgePointStats {
  knowledge_point_id: number;
  total_problems: number;
  primary_problems: number; // 作为主要知识点的题目数量
  average_difficulty: number;
  average_success_rate: number;
  total_attempts: number;
  correct_attempts: number;
}

/**
 * 题目知识点分析结果
 */
export interface ProblemKnowledgeAnalysis {
  problem_id: number;
  knowledge_point_coverage: number; // 知识点覆盖率 0-1
  primary_knowledge_points: KnowledgePointBase[];
  secondary_knowledge_points: KnowledgePointBase[];
  suggested_knowledge_points: KnowledgePointBase[]; // 建议关联的知识点
}

/**
 * 知识点树形结构
 */
export interface KnowledgePointTree extends KnowledgePointBase {
  children?: KnowledgePointTree[];
  problem_count?: number; // 关联题目数量
  primary_problem_count?: number; // 作为主要知识点的题目数量
}

/**
 * 批量操作结果
 */
export interface BatchOperationResult {
  success: number;
  failed: number;
  errors?: Array<{
    knowledge_point_id: number;
    error: string;
  }>;
}

/**
 * 知识点题目分布统计
 */
export interface KnowledgePointDistribution {
  knowledge_point_id: number;
  knowledge_point_name: string;
  by_difficulty: {
    [difficulty: number]: number;
  };
  by_source_type: {
    [sourceType: string]: number;
  };
  by_year: {
    [year: number]: number;
  };
}

/**
 * 题目知识点操作响应
 */
export interface ProblemKnowledgePointResponse {
  success: boolean;
  data?: ProblemKnowledgePoint | ProblemKnowledgePoint[];
  message?: string;
  stats?: KnowledgePointStats;
}

/**
 * 工具函数
 */

/**
 * 计算题目知识点权重总和
 */
export function calculateTotalWeight(
  knowledgePoints: KnowledgePointWithRelation[]
): number {
  return knowledgePoints.reduce((sum, kp) => {
    const weight = kp.problem_relation?.weight || 1.0;
    return sum + weight;
  }, 0);
}

/**
 * 获取主要知识点
 */
export function getPrimaryKnowledgePoints(
  knowledgePoints: KnowledgePointWithRelation[]
): KnowledgePointWithRelation[] {
  return knowledgePoints.filter(kp => kp.problem_relation?.is_primary);
}

/**
 * 根据权重排序知识点
 */
export function sortByWeight(
  knowledgePoints: KnowledgePointWithRelation[],
  order: 'asc' | 'desc' = 'desc'
): KnowledgePointWithRelation[] {
  return [...knowledgePoints].sort((a, b) => {
    const weightA = a.problem_relation?.weight || 0;
    const weightB = b.problem_relation?.weight || 0;
    return order === 'desc' ? weightB - weightA : weightA - weightB;
  });
}

/**
 * 格式化知识点显示
 */
export function formatKnowledgePointDisplay(
  knowledgePoints: KnowledgePointWithRelation[],
  options?: {
    showWeight?: boolean;
    showPrimary?: boolean;
    maxLength?: number;
  }
): string {
  const { showWeight = false, showPrimary = true, maxLength } = options || {};
  
  const primary = knowledgePoints.filter(kp => kp.problem_relation?.is_primary);
  const secondary = knowledgePoints.filter(kp => !kp.problem_relation?.is_primary);
  
  let result = '';
  
  if (showPrimary && primary.length > 0) {
    const primaryText = primary.map(kp => {
      let text = kp.name;
      if (showWeight && kp.problem_relation?.weight) {
        text += `(${kp.problem_relation.weight.toFixed(1)})`;
      }
      return text;
    }).join('、');
    result += `主要: ${primaryText}`;
  }
  
  if (secondary.length > 0) {
    if (result) result += '; ';
    const secondaryText = secondary.map(kp => kp.name).join('、');
    result += `相关: ${secondaryText}`;
  }
  
  if (maxLength && result.length > maxLength) {
    return result.substring(0, maxLength) + '...';
  }
  
  return result || '暂无知识点';
}

/**
 * 验证知识点关联数据
 */
export function validateProblemKnowledgePoint(
  data: CreateProblemKnowledgePointRequest
): { isValid: boolean; errors: string[] } {
  const errors: string[] = [];
  
  if (!data.problem_id || data.problem_id <= 0) {
    errors.push('题目ID无效');
  }
  
  if (!data.knowledge_point_id || data.knowledge_point_id <= 0) {
    errors.push('知识点ID无效');
  }
  
  if (data.weight !== undefined && (data.weight < 0 || data.weight > 2)) {
    errors.push('权重必须在0-2之间');
  }
  
  return {
    isValid: errors.length === 0,
    errors
  };
}