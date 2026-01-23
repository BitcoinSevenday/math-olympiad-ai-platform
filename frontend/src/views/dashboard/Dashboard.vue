<template>
  <div class="dashboard-container">
    <!-- 欢迎横幅 -->
    <el-card class="welcome-banner">
      <div class="banner-content">
        <div class="banner-left">
          <h1 class="welcome-title">
            欢迎回来，{{ userStore.userInfo?.username || '同学' }}！👋
          </h1>
          <p class="welcome-subtitle">
            {{ getGreeting() }}，今天也要努力练习哦！
          </p>
          <div class="banner-stats">
            <div class="stat-item">
              <div class="stat-value">{{ stats.totalPracticeDays || 0 }}</div>
              <div class="stat-label">学习天数</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ stats.totalQuestions || 0 }}</div>
              <div class="stat-label">答题总数</div>
            </div>
            <div class="stat-item">
              <div class="stat-value">{{ stats.accuracyRate || 0 }}%</div>
              <div class="stat-label">正确率</div>
            </div>
          </div>
        </div>
        <div class="banner-right">
          <div class="motivation-quote">
            <p>"数学不是关于数字，而是关于理解。"</p>
            <span class="quote-author">— 威廉·保罗·瑟斯顿</span>
          </div>
          <el-button
            type="primary"
            size="large"
            @click="startQuickPractice"
            class="quick-practice-btn"
          >
            <el-icon><VideoPlay /></el-icon>
            快速练习
          </el-button>
        </div>
      </div>
    </el-card>

    <!-- 主要统计卡片 -->
    <div class="stats-grid">
      <!-- 学习进度 -->
      <el-card class="stat-card progress-card">
        <template #header>
          <div class="card-header">
            <h3 class="card-title">
              <el-icon><TrendCharts /></el-icon>
              学习进度
            </h3>
            <el-tag type="success" size="small">
              {{ getProgressLevel() }}
            </el-tag>
          </div>
        </template>
        <div class="progress-content">
          <div class="progress-chart">
            <div class="progress-ring">
              <vue-echarts
                :option="progressChartOption"
                style="height: 200px"
              />
            </div>
          </div>
          <div class="progress-details">
            <div class="progress-item">
              <div class="progress-label">今日练习</div>
              <div class="progress-value">{{ stats.todayPractice || 0 }} 题</div>
              <el-progress
                :percentage="(stats.todayPractice || 0) / 20 * 100"
                :show-text="false"
                :stroke-width="8"
                color="#409EFF"
              />
            </div>
            <div class="progress-item">
              <div class="progress-label">本周目标</div>
              <div class="progress-value">{{ stats.weeklyGoal || 100 }} 题</div>
              <el-progress
                :percentage="((stats.weeklyCompleted || 0) / (stats.weeklyGoal || 100)) * 100"
                :show-text="false"
                :stroke-width="8"
                color="#67C23A"
              />
            </div>
            <div class="progress-item">
              <div class="progress-label">连续学习</div>
              <div class="progress-value">{{ stats.streakDays || 0 }} 天</div>
              <el-progress
                :percentage="Math.min((stats.streakDays || 0) / 30 * 100, 100)"
                :show-text="false"
                :stroke-width="8"
                color="#E6A23C"
              />
            </div>
          </div>
        </div>
      </el-card>

      <!-- 知识点掌握 -->
      <el-card class="stat-card knowledge-card">
        <template #header>
          <div class="card-header">
            <h3 class="card-title">
              <el-icon><Collection /></el-icon>
              知识点掌握
            </h3>
            <el-link type="primary" :underline="false" @click="goToKnowledge">
              查看详情
            </el-link>
          </div>
        </template>
        <div class="knowledge-content">
          <vue-echarts
            :option="knowledgeChartOption"
            style="height: 300px"
          />
          <div class="knowledge-summary">
            <div class="summary-item mastered">
              <div class="summary-icon">
                <el-icon><SuccessFilled /></el-icon>
              </div>
              <div class="summary-info">
                <div class="summary-value">{{ stats.masteredPoints || 0 }}</div>
                <div class="summary-label">已掌握</div>
              </div>
            </div>
            <div class="summary-item learning">
              <div class="summary-icon">
                <el-icon><Clock /></el-icon>
              </div>
              <div class="summary-info">
                <div class="summary-value">{{ stats.learningPoints || 0 }}</div>
                <div class="summary-label">学习中</div>
              </div>
            </div>
            <div class="summary-item weak">
              <div class="summary-icon">
                <el-icon><WarningFilled /></el-icon>
              </div>
              <div class="summary-info">
                <div class="summary-value">{{ stats.weakPoints || 0 }}</div>
                <div class="summary-label">需加强</div>
              </div>
            </div>
          </div>
        </div>
      </el-card>

      <!-- 近期活动 -->
      <el-card class="stat-card activity-card">
        <template #header>
          <div class="card-header">
            <h3 class="card-title">
              <el-icon><AlarmClock /></el-icon>
              近期活动
            </h3>
            <el-link type="primary" :underline="false" @click="showAllActivities">
              查看全部
            </el-link>
          </div>
        </template>
        <div class="activity-content">
          <div class="activity-list">
            <div
              v-for="activity in recentActivities"
              :key="activity.id"
              class="activity-item"
            >
              <div class="activity-icon" :class="activity.type">
                <el-icon>
                  <component :is="getActivityIcon(activity.type)" />
                </el-icon>
              </div>
              <div class="activity-details">
                <div class="activity-title">{{ activity.title }}</div>
                <div class="activity-time">{{ formatTime(activity.time) }}</div>
                <div class="activity-description">{{ activity.description }}</div>
              </div>
              <el-tag
                v-if="activity.status"
                :type="getActivityTagType(activity.status)"
                size="small"
              >
                {{ activity.status }}
              </el-tag>
            </div>
          </div>
          <div v-if="recentActivities.length === 0" class="no-activities">
            <el-empty description="暂无活动记录" :image-size="80">
              <el-button type="primary" @click="startQuickPractice">
                开始第一次练习
              </el-button>
            </el-empty>
          </div>
        </div>
      </el-card>

      <!-- 推荐练习 -->
      <el-card class="stat-card recommendation-card">
        <template #header>
          <div class="card-header">
            <h3 class="card-title">
              <el-icon><MagicStick /></el-icon>
              推荐练习
            </h3>
            <el-button type="text" size="small" @click="refreshRecommendations">
              <el-icon><Refresh /></el-icon>
              换一批
            </el-button>
          </div>
        </template>
        <div class="recommendation-content">
          <div class="recommendation-list">
            <div
              v-for="problem in recommendedProblems"
              :key="problem.id"
              class="recommendation-item"
              @click="$router.push(`/problems/${problem.id}`)"
            >
              <div class="problem-info">
                <div class="problem-title">{{ problem.title }}</div>
                <div class="problem-meta">
                  <el-rate
                    v-model="problem.difficulty"
                    disabled
                    :max="5"
                    size="small"
                  />
                  <span class="problem-accuracy">
                    {{ problem.accuracy_rate?.toFixed(1) || '0.0' }}%
                  </span>
                </div>
                <div class="problem-tags">
                  <el-tag
                    v-for="point in problem.knowledge_points"
                    :key="point.id"
                    size="small"
                    type="info"
                  >
                    {{ point.name }}
                  </el-tag>
                </div>
              </div>
              <div class="recommendation-reason">
                <el-tag type="warning" size="small">
                  {{ getRecommendationReason(problem) }}
                </el-tag>
              </div>
            </div>
          </div>
          <div v-if="recommendedProblems.length === 0" class="no-recommendations">
            <el-empty description="暂无推荐题目" :image-size="80" />
          </div>
          <div class="recommendation-footer">
            <el-button type="primary" @click="startCustomPractice">
              <el-icon><Setting /></el-icon>
              定制练习
            </el-button>
            <el-button @click="goToRandomPractice">
              <el-icon><Pointer /></el-icon>
              随机练习
            </el-button>
          </div>
        </div>
      </el-card>
    </div>

    <!-- 学习统计图表 -->
    <el-card class="chart-card">
      <template #header>
        <div class="card-header">
          <h3 class="card-title">
            <el-icon><DataLine /></el-icon>
            学习趋势
          </h3>
          <div class="chart-controls">
            <el-radio-group v-model="chartPeriod" size="small">
              <el-radio-button label="week">本周</el-radio-button>
              <el-radio-button label="month">本月</el-radio-button>
              <el-radio-button label="quarter">本季</el-radio-button>
            </el-radio-group>
          </div>
        </div>
      </template>
      <div class="chart-content">
        <vue-echarts
          :option="trendChartOption"
          style="height: 400px"
        />
      </div>
    </el-card>

    <!-- 成就系统 -->
    <el-card class="achievement-card" v-if="achievements.length > 0">
      <template #header>
        <div class="card-header">
          <h3 class="card-title">
            <el-icon><Trophy /></el-icon>
            我的成就
          </h3>
          <el-link type="primary" :underline="false" @click="showAllAchievements">
            查看全部
          </el-link>
        </div>
      </template>
      <div class="achievement-content">
        <div class="achievement-list">
          <div
            v-for="achievement in achievements.slice(0, 6)"
            :key="achievement.id"
            class="achievement-item"
            :class="{ unlocked: achievement.unlocked }"
          >
            <div class="achievement-icon">
              <el-icon v-if="achievement.unlocked">
                <Trophy />
              </el-icon>
              <el-icon v-else>
                <Lock />
              </el-icon>
            </div>
            <div class="achievement-info">
              <div class="achievement-title">{{ achievement.title }}</div>
              <div class="achievement-description">{{ achievement.description }}</div>
              <div class="achievement-progress" v-if="!achievement.unlocked">
                <el-progress
                  :percentage="achievement.progress"
                  :stroke-width="6"
                  :show-text="false"
                />
                <span class="progress-text">{{ achievement.progress }}%</span>
              </div>
            </div>
            <div class="achievement-date" v-if="achievement.unlocked">
              {{ achievement.unlockedAt ? formatDate(achievement.unlockedAt) : '' }}
            </div>
          </div>
        </div>
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import { use } from 'echarts/core'
import { CanvasRenderer } from 'echarts/renderers'
import { PieChart, LineChart, BarChart } from 'echarts/charts'
import {
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent
} from 'echarts/components'
import VChart from 'vue-echarts'
import {
  TrendCharts,
  Collection,
  AlarmClock,
  MagicStick,
  DataLine,
  Trophy,
  VideoPlay,
  SuccessFilled,
  Clock,
  WarningFilled,
  Refresh,
  Setting,
  Pointer,
  Lock,
  Check,
  Close,
  Star,
  Timer
} from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'

// 注册ECharts组件
use([
  CanvasRenderer,
  PieChart,
  LineChart,
  BarChart,
  TitleComponent,
  TooltipComponent,
  LegendComponent,
  GridComponent
])

const router = useRouter()
const userStore = useUserStore()

// 状态
const loading = ref(false)
const chartPeriod = ref('week')

// 统计数据
const stats = ref({
  totalPracticeDays: 12,
  totalQuestions: 345,
  accuracyRate: 78.5,
  todayPractice: 8,
  weeklyGoal: 100,
  weeklyCompleted: 65,
  streakDays: 7,
  masteredPoints: 18,
  learningPoints: 12,
  weakPoints: 6
})

// 近期活动
const recentActivities = ref([
  {
    id: 1,
    type: 'practice',
    title: '完成几何专题练习',
    description: '正确率85%，用时25分钟',
    time: new Date(Date.now() - 2 * 60 * 60 * 1000), // 2小时前
    status: '已完成'
  },
  {
    id: 2,
    type: 'achievement',
    title: '获得"七日连胜"成就',
    description: '连续7天完成练习',
    time: new Date(Date.now() - 1 * 24 * 60 * 60 * 1000), // 1天前
    status: '已获得'
  },
  {
    id: 3,
    type: 'problem',
    title: '提交题目解析',
    description: '为"圆的面积计算"题目添加了解析',
    time: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000), // 2天前
    status: '已审核'
  },
  {
    id: 4,
    type: 'exam',
    title: '完成模拟考试',
    description: '得分92/100，用时60分钟',
    time: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000), // 3天前
    status: '优秀'
  }
])

// 推荐题目
const recommendedProblems = ref([
  {
    id: 1,
    title: '平面几何中的角度计算',
    difficulty: 3,
    accuracy_rate: 65.2,
    knowledge_points: [
      { id: 1, name: '几何' },
      { id: 2, name: '角度计算' }
    ],
    reason: '薄弱知识点'
  },
  {
    id: 2,
    title: '代数方程求解',
    difficulty: 2,
    accuracy_rate: 82.1,
    knowledge_points: [
      { id: 3, name: '代数' },
      { id: 4, name: '方程' }
    ],
    reason: '近期错题'
  },
  {
    id: 3,
    title: '概率计算问题',
    difficulty: 4,
    accuracy_rate: 45.8,
    knowledge_points: [
      { id: 5, name: '组合数学' },
      { id: 6, name: '概率' }
    ],
    reason: '挑战题目'
  }
])

// 成就
const achievements = ref([
  {
    id: 1,
    title: '初出茅庐',
    description: '完成第一次练习',
    unlocked: true,
    unlockedAt: new Date('2024-05-10'),
    progress: 100
  },
  {
    id: 2,
    title: '七日连胜',
    description: '连续7天完成练习',
    unlocked: true,
    unlockedAt: new Date('2024-05-20'),
    progress: 100
  },
  {
    id: 3,
    title: '解题高手',
    description: '正确率超过90%',
    unlocked: false,
    progress: 78
  },
  {
    id: 4,
    title: '知识大师',
    description: '掌握20个知识点',
    unlocked: false,
    progress: 65
  },
  {
    id: 5,
    title: '勤奋之星',
    description: '完成1000道题目',
    unlocked: false,
    progress: 34
  },
  {
    id: 6,
    title: '挑战者',
    description: '完成50道难度5的题目',
    unlocked: false,
    progress: 12
  }
])

// 图表选项
const progressChartOption = computed(() => ({
  tooltip: {
    trigger: 'item'
  },
  series: [
    {
      name: '学习进度',
      type: 'pie',
      radius: ['50%', '70%'],
      avoidLabelOverlap: false,
      itemStyle: {
        borderRadius: 10,
        borderColor: '#fff',
        borderWidth: 2
      },
      label: {
        show: false
      },
      emphasis: {
        label: {
          show: true,
          fontSize: 18,
          fontWeight: 'bold'
        }
      },
      data: [
        { value: stats.value.masteredPoints, name: '已掌握', itemStyle: { color: '#67C23A' } },
        { value: stats.value.learningPoints, name: '学习中', itemStyle: { color: '#409EFF' } },
        { value: stats.value.weakPoints, name: '需加强', itemStyle: { color: '#E6A23C' } }
      ]
    }
  ]
}))

const knowledgeChartOption = computed(() => ({
  tooltip: {
    trigger: 'axis',
    axisPointer: {
      type: 'shadow'
    }
  },
  grid: {
    left: '3%',
    right: '4%',
    bottom: '10%',
    top: '10%',
    containLabel: true
  },
  xAxis: {
    type: 'category',
    data: ['算术', '代数', '几何', '组合', '数论'],
    axisLabel: {
      interval: 0,
      rotate: 0
    }
  },
  yAxis: {
    type: 'value',
    max: 100,
    axisLabel: {
      formatter: '{value}%'
    }
  },
  series: [
    {
      name: '掌握度',
      type: 'bar',
      data: [85, 72, 65, 45, 38],
      itemStyle: {
        color: function(params: any) {
          const colorList = ['#5470C6', '#91CC75', '#FAC858', '#EE6666', '#73C0DE']
          return colorList[params.dataIndex % colorList.length]
        },
        borderRadius: [4, 4, 0, 0]
      },
      label: {
        show: true,
        position: 'top',
        formatter: '{c}%'
      }
    }
  ]
}))

const trendChartOption = computed(() => {
  const periodData = {
    week: {
      dates: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
      accuracy: [72, 75, 80, 78, 85, 82, 79],
      questions: [15, 18, 20, 16, 22, 25, 18]
    },
    month: {
      dates: Array.from({ length: 30 }, (_, i) => `${i + 1}日`),
      accuracy: Array.from({ length: 30 }, () => Math.floor(Math.random() * 20) + 70),
      questions: Array.from({ length: 30 }, () => Math.floor(Math.random() * 15) + 10)
    },
    quarter: {
      dates: ['1月', '2月', '3月'],
      accuracy: [75, 78, 82],
      questions: [450, 520, 600]
    }
  }

  const data = periodData[chartPeriod.value as keyof typeof periodData] || periodData.week

  return {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'cross',
        crossStyle: {
          color: '#999'
        }
      }
    },
    legend: {
      data: ['正确率', '练习数量']
    },
    xAxis: [
      {
        type: 'category',
        data: data.dates,
        axisPointer: {
          type: 'shadow'
        }
      }
    ],
    yAxis: [
      {
        type: 'value',
        name: '正确率(%)',
        min: 0,
        max: 100,
        interval: 20,
        axisLabel: {
          formatter: '{value}%'
        }
      },
      {
        type: 'value',
        name: '练习数量',
        min: 0,
        axisLabel: {
          formatter: '{value}题'
        }
      }
    ],
    series: [
      {
        name: '正确率',
        type: 'line',
        yAxisIndex: 0,
        data: data.accuracy,
        smooth: true,
        lineStyle: {
          color: '#67C23A',
          width: 3
        },
        itemStyle: {
          color: '#67C23A'
        },
        areaStyle: {
          color: {
            type: 'linear',
            x: 0,
            y: 0,
            x2: 0,
            y2: 1,
            colorStops: [{
              offset: 0, color: 'rgba(103, 194, 58, 0.3)'
            }, {
              offset: 1, color: 'rgba(103, 194, 58, 0.1)'
            }]
          }
        }
      },
      {
        name: '练习数量',
        type: 'bar',
        yAxisIndex: 1,
        data: data.questions,
        itemStyle: {
          color: '#409EFF',
          borderRadius: [4, 4, 0, 0]
        }
      }
    ]
  }
})

// 方法
const getGreeting = () => {
  const hour = new Date().getHours()
  if (hour < 6) return '深夜好'
  if (hour < 12) return '上午好'
  if (hour < 14) return '中午好'
  if (hour < 18) return '下午好'
  return '晚上好'
}

const getProgressLevel = () => {
  const progress = (stats.value.weeklyCompleted / stats.value.weeklyGoal) * 100
  if (progress >= 100) return '超额完成'
  if (progress >= 80) return '优秀'
  if (progress >= 60) return '良好'
  return '继续努力'
}

const getActivityIcon = (type: string) => {
  const iconMap: Record<string, string> = {
    practice: 'VideoPlay',
    achievement: 'Trophy',
    problem: 'Document',
    exam: 'EditPen'
  }
  return iconMap[type] || 'Bell'
}

const getActivityTagType = (status: string) => {
  const typeMap: Record<string, any> = {
    '已完成': 'success',
    '已获得': 'warning',
    '已审核': 'info',
    '优秀': 'success'
  }
  return typeMap[status] || 'info'
}

const getRecommendationReason = (problem: any) => {
  return problem.reason || '智能推荐'
}

const formatTime = (time: Date) => {
  const now = new Date()
  const diff = now.getTime() - time.getTime()
  const diffMinutes = Math.floor(diff / (1000 * 60))
  const diffHours = Math.floor(diff / (1000 * 60 * 60))
  const diffDays = Math.floor(diff / (1000 * 60 * 60 * 24))

  if (diffMinutes < 60) {
    return `${diffMinutes}分钟前`
  } else if (diffHours < 24) {
    return `${diffHours}小时前`
  } else if (diffDays < 7) {
    return `${diffDays}天前`
  } else {
    return time.toLocaleDateString('zh-CN')
  }
}

const formatDate = (date: Date) => {
  return date.toLocaleDateString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
  })
}

// 操作函数
const startQuickPractice = () => {
  ElMessage.info('开始快速练习')
  // 这里可以跳转到练习页面
}

const startCustomPractice = () => {
  ElMessage.info('定制练习功能开发中')
}

const goToRandomPractice = () => {
  ElMessage.info('随机练习功能开发中')
}

const goToKnowledge = () => {
  router.push('/knowledge')
}

const showAllActivities = () => {
  ElMessage.info('查看所有活动')
}

const showAllAchievements = () => {
  ElMessage.info('查看所有成就')
}

const refreshRecommendations = () => {
  ElMessage.success('推荐已刷新')
  // 这里可以重新加载推荐题目
}

// 页面加载
onMounted(() => {
  // 可以在这里加载真实的统计数据
  console.log('仪表板加载完成')
})

// 监听图表周期变化
watch(chartPeriod, () => {
  // 这里可以重新加载对应周期的数据
})
</script>

<style lang="scss" scoped>
.dashboard-container {
  padding: 20px;
  max-width: 1400px;
  margin: 0 auto;
}

.welcome-banner {
  margin-bottom: 24px;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  
  :deep(.el-card__body) {
    padding: 32px;
  }
  
  .banner-content {
    display: flex;
    align-items: center;
    justify-content: space-between;
    
    @media (max-width: 768px) {
      flex-direction: column;
      gap: 24px;
      text-align: center;
    }
    
    .banner-left {
      .welcome-title {
        font-size: 32px;
        font-weight: 700;
        margin: 0 0 12px;
      }
      
      .welcome-subtitle {
        font-size: 18px;
        opacity: 0.9;
        margin: 0 0 24px;
      }
      
      .banner-stats {
        display: flex;
        gap: 32px;
        
        .stat-item {
          .stat-value {
            font-size: 32px;
            font-weight: 700;
            line-height: 1;
            margin-bottom: 4px;
          }
          
          .stat-label {
            font-size: 14px;
            opacity: 0.8;
          }
        }
      }
    }
    
    .banner-right {
      display: flex;
      flex-direction: column;
      align-items: flex-end;
      gap: 20px;
      
      @media (max-width: 768px) {
        align-items: center;
      }
      
      .motivation-quote {
        text-align: right;
        max-width: 300px;
        
        p {
          font-size: 16px;
          font-style: italic;
          margin: 0 0 8px;
          line-height: 1.5;
        }
        
        .quote-author {
          font-size: 14px;
          opacity: 0.8;
        }
      }
      
      .quick-practice-btn {
        background: white;
        color: #667eea;
        border: none;
        font-weight: 600;
        
        &:hover {
          background: rgba(255, 255, 255, 0.9);
        }
      }
    }
  }
}

.stats-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
  margin-bottom: 24px;
  
  @media (max-width: 1200px) {
    grid-template-columns: 1fr;
  }
  
  .stat-card {
    .card-header {
      display: flex;
      align-items: center;
      justify-content: space-between;
      padding: 16px 20px 0;
      
      .card-title {
        margin: 0;
        font-size: 18px;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 8px;
      }
    }
    
    // 学习进度卡片
    &.progress-card {
      .progress-content {
        display: grid;
        grid-template-columns: 200px 1fr;
        gap: 24px;
        padding: 20px;
        
        @media (max-width: 768px) {
          grid-template-columns: 1fr;
        }
        
        .progress-chart {
          display: flex;
          align-items: center;
          justify-content: center;
        }
        
        .progress-details {
          .progress-item {
            margin-bottom: 20px;
            
            &:last-child {
              margin-bottom: 0;
            }
            
            .progress-label {
              font-size: 14px;
              color: var(--el-text-color-secondary);
              margin-bottom: 4px;
            }
            
            .progress-value {
              font-size: 18px;
              font-weight: 600;
              margin-bottom: 8px;
            }
          }
        }
      }
    }
    
    // 知识点卡片
    &.knowledge-card {
      .knowledge-content {
        padding: 20px;
        
        .knowledge-summary {
          display: grid;
          grid-template-columns: repeat(3, 1fr);
          gap: 16px;
          margin-top: 20px;
          
          .summary-item {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 12px;
            border-radius: 8px;
            background: var(--el-fill-color-lighter);
            
            &.mastered {
              border-left: 4px solid var(--el-color-success);
            }
            
            &.learning {
              border-left: 4px solid var(--el-color-primary);
            }
            
            &.weak {
              border-left: 4px solid var(--el-color-warning);
            }
            
            .summary-icon {
              width: 40px;
              height: 40px;
              display: flex;
              align-items: center;
              justify-content: center;
              border-radius: 8px;
              font-size: 20px;
              
              .mastered & {
                background: var(--el-color-success-light-9);
                color: var(--el-color-success);
              }
             
              .learning & {
                background: var(--el-color-primary-light-9);
                color: var(--el-color-primary);
              }
              
              .weak & {
                background: var(--el-color-warning-light-9);
                color: var(--el-color-warning);
              }
            }
            
            .summary-info {
              .summary-value {
                font-size: 20px;
                font-weight: 600;
                line-height: 1;
                margin-bottom: 4px;
              }
              
              .summary-label {
                font-size: 12px;
                color: var(--el-text-color-secondary);
              }
            }
          }
        }
      }
    }
    
    // 活动卡片
    &.activity-card {
      .activity-content {
        padding: 0;
        
        .activity-list {
          .activity-item {
            display: flex;
            align-items: flex-start;
            gap: 16px;
            padding: 16px 20px;
            border-bottom: 1px solid var(--el-border-color);
            
            &:last-child {
              border-bottom: none;
            }
            
            &:hover {
              background: var(--el-fill-color-lighter);
            }
            
            .activity-icon {
              width: 40px;
              height: 40px;
              display: flex;
              align-items: center;
              justify-content: center;
              border-radius: 8px;
              flex-shrink: 0;
              
              &.practice {
                background: var(--el-color-primary-light-9);
                color: var(--el-color-primary);
              }
              
              &.achievement {
                background: var(--el-color-warning-light-9);
                color: var(--el-color-warning);
              }
              
              &.problem {
                background: var(--el-color-success-light-9);
                color: var(--el-color-success);
              }
              
              &.exam {
                background: var(--el-color-info-light-9);
                color: var(--el-color-info);
              }
            }
            
            .activity-details {
              flex: 1;
              min-width: 0;
              
              .activity-title {
                font-size: 16px;
                font-weight: 500;
                margin-bottom: 4px;
              }
              
              .activity-time {
                font-size: 12px;
                color: var(--el-text-color-secondary);
                margin-bottom: 4px;
              }
              
              .activity-description {
                font-size: 14px;
                color: var(--el-text-color-regular);
              }
            }
          }
        }
        
        .no-activities {
          padding: 40px 20px;
        }
      }
    }
    
    // 推荐卡片
    &.recommendation-card {
      .recommendation-content {
        padding: 20px;
        
        .recommendation-list {
          .recommendation-item {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 16px;
            margin-bottom: 12px;
            border: 1px solid var(--el-border-color);
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            
            &:hover {
              border-color: var(--el-color-primary);
              background: var(--el-color-primary-light-9);
              transform: translateX(4px);
            }
            
            &:last-child {
              margin-bottom: 20px;
            }
            
            .problem-info {
              flex: 1;
              min-width: 0;
              
              .problem-title {
                font-size: 16px;
                font-weight: 500;
                margin-bottom: 8px;
                line-height: 1.4;
              }
              
              .problem-meta {
                display: flex;
                align-items: center;
                gap: 12px;
                margin-bottom: 8px;
                
                .problem-accuracy {
                  font-size: 14px;
                  color: var(--el-text-color-secondary);
                }
              }
              
              .problem-tags {
                display: flex;
                flex-wrap: wrap;
                gap: 4px;
              }
            }
          }
        }
        
        .no-recommendations {
          padding: 40px 20px;
        }
        
        .recommendation-footer {
          display: flex;
          gap: 12px;
          justify-content: center;
          margin-top: 20px;
        }
      }
    }
  }
}

.chart-card,
.achievement-card {
  margin-bottom: 24px;
  
  .card-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 20px 0;
    
    .card-title {
      margin: 0;
      font-size: 18px;
      font-weight: 600;
      display: flex;
      align-items: center;
      gap: 8px;
    }
    
    .chart-controls {
      display: flex;
      gap: 8px;
    }
  }
  
  .chart-content,
  .achievement-content {
    padding: 20px;
  }
}

.achievement-card {
  .achievement-list {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
    
    @media (max-width: 768px) {
      grid-template-columns: 1fr;
    }
    
    .achievement-item {
      display: flex;
      align-items: center;
      gap: 16px;
      padding: 16px;
      border: 1px solid var(--el-border-color);
      border-radius: 8px;
      transition: all 0.3s ease;
      
      &.unlocked {
        border-color: var(--el-color-primary);
        background: var(--el-color-primary-light-9);
      }
      
      &:hover {
        transform: translateY(-2px);
        box-shadow: var(--el-box-shadow-light);
      }
      
      .achievement-icon {
        width: 48px;
        height: 48px;
        display: flex;
        align-items: center;
        justify-content: center;
        border-radius: 50%;
        font-size: 24px;
        flex-shrink: 0;
        
        .unlocked & {
          background: var(--el-color-primary);
          color: white;
        }
        
        &:not(.unlocked) & {
          background: var(--el-fill-color-light);
          color: var(--el-text-color-placeholder);
        }
      }
      
      .achievement-info {
        flex: 1;
        min-width: 0;
        
        .achievement-title {
          font-size: 16px;
          font-weight: 500;
          margin-bottom: 4px;
        }
        
        .achievement-description {
          font-size: 14px;
          color: var(--el-text-color-secondary);
          margin-bottom: 8px;
        }
        
        .achievement-progress {
          display: flex;
          align-items: center;
          gap: 8px;
          
          .progress-text {
            font-size: 12px;
            color: var(--el-text-color-secondary);
            min-width: 40px;
          }
        }
      }
      
      .achievement-date {
        font-size: 12px;
        color: var(--el-text-color-secondary);
        flex-shrink: 0;
      }
    }
  }
}
</style>