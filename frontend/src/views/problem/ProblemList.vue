<template>
  <div class="problem-list-container">
    <!-- 页面标题和操作 -->
    <div class="page-header">
      <div class="header-left">
        <h1 class="page-title">题库管理</h1>
        <p class="page-subtitle">共 {{ pagination.total }} 道题目</p>
      </div>
      <div class="header-right">
        <el-button
          v-if="userStore.isTeacher || userStore.isAdmin"
          type="primary"
          @click="$router.push('/problems/create')"
        >
          <el-icon><Plus /></el-icon>
          创建题目
        </el-button>
        <el-button type="info" @click="refreshList">
          <el-icon><Refresh /></el-icon>
          刷新
        </el-button>
      </div>
    </div>
    
    <!-- 筛选条件 -->
    <el-card class="filter-card">
      <div class="filter-form">
        <el-form :model="filterForm" inline>
          <!-- 搜索 -->
          <el-form-item>
            <el-input
              v-model="filterForm.search"
              placeholder="搜索题目..."
              clearable
              @keyup.enter="handleFilter"
              @clear="handleFilter"
            >
              <template #prefix>
                <el-icon><Search /></el-icon>
              </template>
            </el-input>
          </el-form-item>
          
          <!-- 难度筛选 -->
          <el-form-item>
            <el-select
              v-model="filterForm.difficulty"
              placeholder="难度"
              multiple
              collapse-tags
              collapse-tags-tooltip
              @change="handleFilter"
            >
              <el-option label="入门" :value="1" />
              <el-option label="基础" :value="2" />
              <el-option label="中等" :value="3" />
              <el-option label="困难" :value="4" />
              <el-option label="挑战" :value="5" />
            </el-select>
          </el-form-item>
          
          <!-- 来源筛选 -->
          <el-form-item>
            <el-select
              v-model="filterForm.source_type"
              placeholder="来源"
              clearable
              @change="handleFilter"
            >
              <el-option label="AMC8" value="AMC8" />
              <el-option label="迎春杯" value="迎春杯" />
              <el-option label="华杯赛" value="华杯赛" />
              <el-option label="其他" value="其他" />
            </el-select>
          </el-form-item>
          
          <!-- 知识点筛选 -->
          <el-form-item>
            <el-select
              v-model="filterForm.knowledge_point_id"
              placeholder="知识点"
              clearable
              filterable
              @change="handleFilter"
            >
              <el-option
                v-for="point in knowledgePoints"
                :key="point.id"
                :label="point.name"
                :value="point.id"
              />
            </el-select>
          </el-form-item>
          
          <!-- 状态筛选 -->
          <el-form-item v-if="userStore.isTeacher || userStore.isAdmin">
            <el-select
              v-model="filterForm.is_published"
              placeholder="状态"
              clearable
              @change="handleFilter"
            >
              <el-option label="已发布" :value="true" />
              <el-option label="未发布" :value="false" />
            </el-select>
          </el-form-item>
          
          <!-- 筛选按钮 -->
          <el-form-item>
            <el-button type="primary" @click="handleFilter">
              筛选
            </el-button>
            <el-button @click="resetFilter">
              重置
            </el-button>
          </el-form-item>
        </el-form>
      </div>
    </el-card>
    
    <!-- 题目列表 -->
    <el-card class="list-card">
      <!-- 表格 -->
      <el-table
        v-loading="loading"
        :data="problems"
        style="width: 100%"
        @row-click="handleRowClick"
      >
        <!-- ID列 -->
        <el-table-column prop="id" label="ID" width="80" sortable />
        
        <!-- 标题列 -->
        <el-table-column prop="title" label="标题" min-width="200">
          <template #default="{ row }">
            <div class="problem-title">
              <span class="title-text">{{ row.title }}</span>
              <el-tag
                v-if="!row.is_published"
                type="info"
                size="small"
              >
                未发布
              </el-tag>
            </div>
          </template>
        </el-table-column>
        
        <!-- 难度列 -->
        <el-table-column prop="difficulty" label="难度" width="100">
          <template #default="{ row }">
            <el-rate
              v-model="row.difficulty"
              disabled
              :max="5"
              :colors="['#99A9BF', '#F7BA2A', '#FF9900']"
            />
          </template>
        </el-table-column>
        
        <!-- 来源列 -->
        <el-table-column prop="source_type" label="来源" width="120">
          <template #default="{ row }">
            <span v-if="row.source_type">
              {{ row.source_type }}<span v-if="row.source_year">{{ row.source_year }}</span>
            </span>
            <span v-else class="text-muted">-</span>
          </template>
        </el-table-column>
        
        <!-- 知识点列 -->
        <el-table-column prop="knowledge_points" label="知识点" min-width="150">
          <template #default="{ row }">
            <div class="knowledge-tags">
              <el-tag
                v-for="point in row.knowledge_points"
                :key="point.id"
                size="small"
                class="knowledge-tag"
              >
                {{ point.name }}
              </el-tag>
              <span v-if="!row.knowledge_points?.length" class="text-muted">-</span>
            </div>
          </template>
        </el-table-column>
        
        <!-- 统计列 -->
        <el-table-column prop="accuracy_rate" label="正确率" width="100">
          <template #default="{ row }">
            <div class="accuracy-cell">
              <span :class="getAccuracyClass(row.accuracy_rate)">
                {{ row.accuracy_rate.toFixed(1) }}%
              </span>
              <div class="accuracy-bar">
                <div
                  class="accuracy-fill"
                  :class="getAccuracyClass(row.accuracy_rate)"
                  :style="{ width: row.accuracy_rate + '%' }"
                />
              </div>
            </div>
          </template>
        </el-table-column>
        
        <!-- 创建时间列 -->
        <el-table-column prop="created_at" label="创建时间" width="180" sortable>
          <template #default="{ row }">
            {{ formatDate(row.created_at) }}
          </template>
        </el-table-column>
        
        <!-- 操作列 -->
        <el-table-column label="操作" width="180" fixed="right">
          <template #default="{ row }">
            <div class="action-buttons">
              <el-button
                type="primary"
                size="small"
                link
                @click.stop="$router.push(`/problems/${row.id}`)"
              >
                查看
              </el-button>
              
              <el-button
                v-if="userStore.isTeacher || userStore.isAdmin"
                type="warning"
                size="small"
                link
                @click.stop="$router.push(`/problems/${row.id}/edit`)"
              >
                编辑
              </el-button>
              
              <el-button
                v-if="userStore.isAdmin"
                type="danger"
                size="small"
                link
                @click.stop="handleDelete(row)"
              >
                删除
              </el-button>
              
              <el-dropdown
                v-if="userStore.isTeacher || userStore.isAdmin"
                @command="(command) => handleAction(command, row)"
              >
                <el-button type="info" size="small" link>
                  更多
                </el-button>
                <template #dropdown>
                  <el-dropdown-menu>
                    <el-dropdown-item
                      v-if="!row.is_published"
                      command="publish"
                    >
                      <el-icon><Promotion /></el-icon>
                      发布
                    </el-dropdown-item>
                    <el-dropdown-item
                      v-else
                      command="unpublish"
                    >
                      <el-icon><Remove /></el-icon>
                      取消发布
                    </el-dropdown-item>
                    <el-dropdown-item
                      command="copy"
                      divided
                    >
                      <el-icon><DocumentCopy /></el-icon>
                      复制题目
                    </el-dropdown-item>
                    <el-dropdown-item
                      command="stats"
                    >
                      <el-icon><DataAnalysis /></el-icon>
                      查看统计
                    </el-dropdown-item>
                  </el-dropdown-menu>
                </template>
              </el-dropdown>
            </div>
          </template>
        </el-table-column>
      </el-table>
      
      <!-- 分页 -->
      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.page_size"
          :total="pagination.total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>
    
    <!-- 统计卡片 -->
    <div class="stats-cards" v-if="problemStats">
      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon total">
            <el-icon><Document /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ problemStats.total_problems }}</div>
            <div class="stat-label">总题目数</div>
          </div>
        </div>
      </el-card>
      
      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon published">
            <el-icon><Check /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ problemStats.published_problems }}</div>
            <div class="stat-label">已发布</div>
          </div>
        </div>
      </el-card>
      
      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon accuracy">
            <el-icon><TrendCharts /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">{{ problemStats.avg_accuracy }}%</div>
            <div class="stat-label">平均正确率</div>
          </div>
        </div>
      </el-card>
      
      <el-card class="stat-card">
        <div class="stat-content">
          <div class="stat-icon difficulty">
            <el-icon><Star /></el-icon>
          </div>
          <div class="stat-info">
            <div class="stat-value">
              {{ Object.keys(problemStats.by_difficulty).length }}
            </div>
            <div class="stat-label">难度等级</div>
          </div>
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import {
  Plus,
  Refresh,
  Search,
  Promotion,
  Remove,
  DocumentCopy,
  DataAnalysis,
  Document,
  Check,
  TrendCharts,
  Star
} from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import * as problemApi from '@/api/problem'
import type { Problem, ProblemFilter, ProblemStats } from '@/types/problem'

const router = useRouter()
const userStore = useUserStore()

// 状态
const loading = ref(false)
const problems = ref<Problem[]>([])
const knowledgePoints = ref<any[]>([])
const problemStats = ref<ProblemStats | null>(null)

// 分页
const pagination = reactive({
  page: 1,
  page_size: 20,
  total: 0,
})

// 筛选表单
const filterForm = reactive({
  search: '',
  difficulty: [] as number[],
  source_type: '',
  knowledge_point_id: undefined as number | undefined,
  is_published: userStore.isTeacher || userStore.isAdmin ? undefined : true,
})

// 加载题目列表
const loadProblems = async () => {
  loading.value = true
  
  try {
    const params: ProblemFilter = {
      skip: (pagination.page - 1) * pagination.page_size,
      limit: pagination.page_size,
      ...filterForm,
    }
    
    // 移除空值
    Object.keys(params).forEach(key => {
      const value = (params as any)[key]
      if (value === '' || value === undefined || (Array.isArray(value) && value.length === 0)) {
        delete (params as any)[key]
      }
    })
    
    const response = await problemApi.getProblems(params)
    problems.value = response.problems || response
    pagination.total = response.total || response.length || 0
  } catch (error) {
    console.error('加载题目列表失败:', error)
    ElMessage.error('加载题目列表失败')
  } finally {
    loading.value = false
  }
}

// 加载题目统计
const loadProblemStats = async () => {
  try {
    const stats = await problemApi.getProblemStats()
    problemStats.value = stats
  } catch (error) {
    console.error('加载题目统计失败:', error)
  }
}

// 加载知识点
const loadKnowledgePoints = async () => {
  try {
    // 这里需要实现知识点API
    // knowledgePoints.value = await knowledgeApi.getKnowledgePoints()
  } catch (error) {
    console.error('加载知识点失败:', error)
  }
}

// 处理筛选
const handleFilter = () => {
  pagination.page = 1
  loadProblems()
}

// 重置筛选
const resetFilter = () => {
  filterForm.search = ''
  filterForm.difficulty = []
  filterForm.source_type = ''
  filterForm.knowledge_point_id = undefined
  filterForm.is_published = userStore.isTeacher || userStore.isAdmin ? undefined : true
  
  handleFilter()
}

// 处理行点击
const handleRowClick = (row: Problem) => {
  router.push(`/problems/${row.id}`)
}

// 处理删除
const handleDelete = async (problem: Problem) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除题目 "${problem.title}" 吗？`,
      '确认删除',
      {
        type: 'warning',
        confirmButtonText: '删除',
        cancelButtonText: '取消',
      }
    )
    
    await problemApi.deleteProblem(problem.id)
    ElMessage.success('删除成功')
    loadProblems()
  } catch (error) {
    // 用户取消或删除失败
  }
}

// 处理更多操作
const handleAction = async (command: string, problem: Problem) => {
  switch (command) {
    case 'publish':
      await problemApi.publishProblem(problem.id, true)
      ElMessage.success('发布成功')
      loadProblems()
      break
      
    case 'unpublish':
      await problemApi.publishProblem(problem.id, false)
      ElMessage.success('取消发布成功')
      loadProblems()
      break
      
    case 'copy':
      // 复制题目逻辑
      ElMessage.info('复制功能开发中')
      break
      
    case 'stats':
      // 查看统计逻辑
      ElMessage.info('统计功能开发中')
      break
  }
}

// 处理分页大小变化
const handleSizeChange = (size: number) => {
  pagination.page_size = size
  loadProblems()
}

// 处理页码变化
const handleCurrentChange = (page: number) => {
  pagination.page = page
  loadProblems()
}

// 刷新列表
const refreshList = () => {
  loadProblems()
  loadProblemStats()
}

// 格式化日期
const formatDate = (dateString: string) => {
  const date = new Date(dateString)
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
  })
}

// 获取正确率颜色类
const getAccuracyClass = (accuracy: number) => {
  if (accuracy >= 80) return 'accuracy-high'
  if (accuracy >= 60) return 'accuracy-medium'
  return 'accuracy-low'
}

// 页面加载时
onMounted(() => {
  loadProblems()
  loadProblemStats()
  loadKnowledgePoints()
})
</script>

<style lang="scss" scoped>
.problem-list-container {
  .page-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 24px;
    
    .header-left {
      .page-title {
        font-size: 24px;
        font-weight: 600;
        color: var(--el-text-color-primary);
        margin-bottom: 8px;
      }
      
      .page-subtitle {
        color: var(--el-text-color-secondary);
        font-size: 14px;
      }
    }
  }
  
  .filter-card {
    margin-bottom: 20px;
    
    .filter-form {
      :deep(.el-form-item) {
        margin-bottom: 0;
        margin-right: 16px;
      }
    }
  }
  
  .list-card {
    .problem-title {
      display: flex;
      align-items: center;
      gap: 8px;
      
      .title-text {
        flex: 1;
        min-width: 0;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }
    }
    
    .knowledge-tags {
      display: flex;
      flex-wrap: wrap;
      gap: 4px;
      
      .knowledge-tag {
        max-width: 120px;
        overflow: hidden;
        text-overflow: ellipsis;
        white-space: nowrap;
      }
    }
    
    .accuracy-cell {
      display: flex;
      flex-direction: column;
      gap: 4px;
      
      .accuracy-high {
        color: var(--el-color-success);
      }
      
      .accuracy-medium {
        color: var(--el-color-warning);
      }
      
      .accuracy-low {
        color: var(--el-color-error);
      }
      
      .accuracy-bar {
        width: 100%;
        height: 4px;
        background: var(--el-border-color-lighter);
        border-radius: 2px;
        overflow: hidden;
        
        .accuracy-fill {
          height: 100%;
          transition: width 0.3s;
          
          &.accuracy-high {
            background: var(--el-color-success);
          }
          
          &.accuracy-medium {
            background: var(--el-color-warning);
          }
          
          &.accuracy-low {
            background: var(--el-color-error);
          }
        }
      }
    }
    
    .action-buttons {
      display: flex;
      align-items: center;
      gap: 8px;
      
      :deep(.el-button) {
        padding: 0 4px;
      }
    }
    
    .pagination-wrapper {
      margin-top: 24px;
      display: flex;
      justify-content: center;
    }
  }
  
  .stats-cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 16px;
    margin-top: 24px;
    
    .stat-card {
      .stat-content {
        display: flex;
        align-items: center;
        gap: 16px;
        
        .stat-icon {
          width: 48px;
          height: 48px;
          border-radius: 12px;
          display: flex;
          align-items: center;
          justify-content: center;
          font-size: 24px;
          
          &.total {
            background: #e3f2fd;
            color: #1976d2;
          }
          
          &.published {
            background: #e8f5e9;
            color: #388e3c;
          }
          
          &.accuracy {
            background: #fff3e0;
            color: #f57c00;
          }
          
          &.difficulty {
            background: #f3e5f5;
            color: #7b1fa2;
          }
        }
        
        .stat-info {
          .stat-value {
            font-size: 24px;
            font-weight: 600;
            color: var(--el-text-color-primary);
            line-height: 1;
            margin-bottom: 4px;
          }
          
          .stat-label {
            font-size: 14px;
            color: var(--el-text-color-secondary);
          }
        }
      }
    }
  }
}

.text-muted {
  color: var(--el-text-color-placeholder);
  font-style: italic;
}

// 响应式设计
@media (max-width: 768px) {
  .page-header {
    flex-direction: column;
    align-items: flex-start !important;
    gap: 16px;
    
    .header-right {
      width: 100%;
      
      .el-button {
        width: 100%;
      }
    }
  }
  
  .filter-form {
    :deep(.el-form-item) {
      width: 100%;
      margin-right: 0 !important;
      margin-bottom: 12px !important;
      
      &:last-child {
        margin-bottom: 0 !important;
      }
    }
  }
  
  .stats-cards {
    grid-template-columns: 1fr;
  }
}
</style>
