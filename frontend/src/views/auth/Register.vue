<template>
  <div class="register-container">
    <div class="register-wrapper">
      <!-- 左侧表单 -->
      <div class="register-left">
        <div class="register-form-wrapper">
          <div class="register-header">
            <div class="back-link" @click="$router.push('/login')">
              <el-icon><ArrowLeft /></el-icon>
              <span>返回登录</span>
            </div>
            <h2>创建新账号</h2>
            <p>加入奥赛AI平台，开启智能学习之旅</p>
          </div>
          
          <el-form
            ref="registerFormRef"
            :model="registerForm"
            :rules="registerRules"
            class="register-form"
            @keyup.enter="handleRegister"
          >
            <!-- 用户名 -->
            <el-form-item prop="username">
              <el-input
                v-model="registerForm.username"
                placeholder="用户名"
                size="large"
                :prefix-icon="User"
                @blur="checkUsername"
              >
                <template #append>
                  <el-button
                    v-if="usernameChecked === false"
                    type="danger"
                    text
                    size="small"
                  >
                    已存在
                  </el-button>
                  <el-button
                    v-else-if="usernameChecked === true"
                    type="success"
                    text
                    size="small"
                  >
                    可用
                  </el-button>
                </template>
              </el-input>
            </el-form-item>
            
            <!-- 邮箱 -->
            <el-form-item prop="email">
              <el-input
                v-model="registerForm.email"
                placeholder="邮箱（可选）"
                size="large"
                :prefix-icon="Message"
                @blur="checkEmail"
              >
                <template #append>
                  <el-button
                    v-if="emailChecked === false"
                    type="danger"
                    text
                    size="small"
                  >
                    已使用
                  </el-button>
                  <el-button
                    v-else-if="emailChecked === true && registerForm.email"
                    type="success"
                    text
                    size="small"
                  >
                    可用
                  </el-button>
                </template>
              </el-input>
            </el-form-item>
            
            <!-- 密码 -->
            <el-form-item prop="password">
              <el-input
                v-model="registerForm.password"
                type="password"
                placeholder="密码"
                size="large"
                :prefix-icon="Lock"
                show-password
              />
              <div class="password-strength">
                <div class="strength-bar" :class="passwordStrengthClass"></div>
                <div class="strength-text">{{ passwordStrengthText }}</div>
              </div>
            </el-form-item>
            
            <!-- 确认密码 -->
            <el-form-item prop="confirmPassword">
              <el-input
                v-model="registerForm.confirmPassword"
                type="password"
                placeholder="确认密码"
                size="large"
                :prefix-icon="Lock"
                show-password
              />
            </el-form-item>
            
            <!-- 姓名 -->
            <el-form-item prop="fullName">
              <el-input
                v-model="registerForm.fullName"
                placeholder="姓名（可选）"
                size="large"
                :prefix-icon="UserFilled"
              />
            </el-form-item>
            
            <!-- 角色选择 -->
            <el-form-item prop="role">
              <el-radio-group v-model="registerForm.role">
                <el-radio-button value="student">学生</el-radio-button>
                <el-radio-button value="teacher">老师</el-radio-button>
                <el-radio-button value="parent">家长</el-radio-button>
              </el-radio-group>
            </el-form-item>
            
            <!-- 学生额外信息 -->
            <template v-if="registerForm.role === 'student'">
              <el-form-item prop="grade">
                <el-select
                  v-model="registerForm.grade"
                  placeholder="选择年级"
                  size="large"
                  style="width: 100%"
                >
                  <el-option label="小学" value="primary">
                    <div class="grade-option">
                      <span class="grade-label">小学</span>
                      <span class="grade-years">1-6年级</span>
                    </div>
                  </el-option>
                  <el-option label="初中" value="junior">
                    <div class="grade-option">
                      <span class="grade-label">初中</span>
                      <span class="grade-years">7-9年级</span>
                    </div>
                  </el-option>
                  <el-option label="高中" value="senior">
                    <div class="grade-option">
                      <span class="grade-label">高中</span>
                      <span class="grade-years">10-12年级</span>
                    </div>
                  </el-option>
                </el-select>
              </el-form-item>
              
              <el-form-item prop="school">
                <el-input
                  v-model="registerForm.school"
                  placeholder="学校（可选）"
                  size="large"
                  :prefix-icon="School"
                />
              </el-form-item>
            </template>
            
            <!-- 服务条款 -->
            <el-form-item>
              <el-checkbox v-model="agreedTerms" :required="true">
                我已阅读并同意
                <el-link type="primary" :underline="false" @click="showTerms = true">
                  《服务条款》
                </el-link>
                和
                <el-link type="primary" :underline="false" @click="showPrivacy = true">
                  《隐私政策》
                </el-link>
              </el-checkbox>
            </el-form-item>
            
            <!-- 注册按钮 -->
            <el-form-item>
              <el-button
                type="primary"
                size="large"
                :loading="loading"
                :disabled="!agreedTerms"
                @click="handleRegister"
                class="register-btn"
              >
                立即注册
              </el-button>
            </el-form-item>
            
            <!-- 登录链接 -->
            <div class="login-link">
              已有账号？
              <el-link type="primary" :underline="false" @click="$router.push('/login')">
                立即登录
              </el-link>
            </div>
          </el-form>
        </div>
      </div>
      
      <!-- 右侧说明 -->
      <div class="register-right">
        <div class="register-info">
          <div class="info-icon">🎓</div>
          <h3 class="info-title">为什么加入我们？</h3>
          
          <div class="info-list">
            <div class="info-item">
              <el-icon><Trophy /></el-icon>
              <div>
                <h4>专业奥赛题库</h4>
                <p>收录AMC8、迎春杯、华杯赛等历年真题</p>
              </div>
            </div>
            
            <div class="info-item">
              <el-icon><TrendCharts /></el-icon>
              <div>
                <h4>智能学习分析</h4>
                <p>基于AI分析学习弱点，个性化推荐题目</p>
              </div>
            </div>
            
            <div class="info-item">
              <el-icon><Timer /></el-icon>
              <div>
                <h4>实时学习报告</h4>
                <p>生成详细的学习报告，随时掌握进度</p>
              </div>
            </div>
            
            <div class="info-item">
              <el-icon><User /></el-icon>
              <div>
                <h4>个性化学习路径</h4>
                <p>根据你的水平和目标制定学习计划</p>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    
    <!-- 服务条款对话框 -->
    <el-dialog
      v-model="showTerms"
      title="服务条款"
      width="600px"
    >
      <div class="terms-content">
        <!-- 服务条款内容 -->
        <p>这里放置服务条款内容...</p>
      </div>
      <template #footer>
        <el-button type="primary" @click="showTerms = false">已阅读</el-button>
      </template>
    </el-dialog>
    
    <!-- 隐私政策对话框 -->
    <el-dialog
      v-model="showPrivacy"
      title="隐私政策"
      width="600px"
    >
      <div class="privacy-content">
        <!-- 隐私政策内容 -->
        <p>这里放置隐私政策内容...</p>
      </div>
      <template #footer>
        <el-button type="primary" @click="showPrivacy = false">已阅读</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import {
  User,
  Lock,
  Message,
  UserFilled,
  School,
  Trophy,
  TrendCharts,
  Timer,
  ArrowLeft
} from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()

// 表单引用
const registerFormRef = ref<FormInstance>()

// 表单数据
const registerForm = reactive({
  username: '',
  email: '',
  password: '',
  confirmPassword: '',
  fullName: '',
  role: 'student',
  grade: '',
  school: '',
})

// 状态
const loading = ref(false)
const agreedTerms = ref(false)
const showTerms = ref(false)
const showPrivacy = ref(false)
const usernameChecked = ref<boolean | null>(null)
const emailChecked = ref<boolean | null>(null)

// 密码强度计算
const passwordStrength = computed(() => {
  const password = registerForm.password
  if (!password) return 0
  
  let strength = 0
  if (password.length >= 8) strength++
  if (/[a-z]/.test(password)) strength++
  if (/[A-Z]/.test(password)) strength++
  if (/[0-9]/.test(password)) strength++
  if (/[^a-zA-Z0-9]/.test(password)) strength++
  
  return strength
})

const passwordStrengthClass = computed(() => {
  const strength = passwordStrength.value
  if (strength <= 2) return 'weak'
  if (strength <= 4) return 'medium'
  return 'strong'
})

const passwordStrengthText = computed(() => {
  const strength = passwordStrength.value
  if (strength <= 2) return '弱'
  if (strength <= 4) return '中'
  return '强'
})

// 表单验证规则
const registerRules: FormRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 50, message: '用户名长度在 3 到 50 个字符', trigger: 'blur' },
    { pattern: /^[a-zA-Z0-9_]+$/, message: '用户名只能包含字母、数字和下划线', trigger: 'blur' },
  ],
  email: [
    { type: 'email', message: '请输入正确的邮箱地址', trigger: 'blur' },
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 100, message: '密码长度在 6 到 100 个字符', trigger: 'blur' },
    {
      validator: (_, value, callback) => {
        if (value && passwordStrength.value < 3) {
          callback(new Error('密码强度不足，请包含大小写字母和数字'))
        } else {
          callback()
        }
      },
      trigger: 'blur',
    },
  ],
  confirmPassword: [
    { required: true, message: '请确认密码', trigger: 'blur' },
    {
      validator: (_, value, callback) => {
        if (value !== registerForm.password) {
          callback(new Error('两次输入密码不一致'))
        } else {
          callback()
        }
      },
      trigger: 'blur',
    },
  ],
  role: [
    { required: true, message: '请选择角色', trigger: 'change' },
  ],
}

// 检查用户名是否可用
const checkUsername = async () => {
  if (!registerForm.username || registerForm.username.length < 3) return
  
  try {
    const available = await userStore.checkUsernameAvailable(registerForm.username)
    usernameChecked.value = available
  } catch (error) {
    console.error('检查用户名失败:', error)
  }
}

// 检查邮箱是否可用
const checkEmail = async () => {
  if (!registerForm.email || !registerForm.email.includes('@')) return
  
  try {
    const available = await userStore.checkEmailAvailable(registerForm.email)
    emailChecked.value = available
  } catch (error) {
    console.error('检查邮箱失败:', error)
  }
}

// 处理注册
const handleRegister = async () => {
  if (!registerFormRef.value) return
  
  try {
    await registerFormRef.value.validate()
    
    if (!agreedTerms.value) {
      ElMessage.warning('请同意服务条款和隐私政策')
      return
    }
    
    if (usernameChecked.value === false) {
      ElMessage.warning('用户名已被使用')
      return
    }
    
    if (registerForm.email && emailChecked.value === false) {
      ElMessage.warning('邮箱已被使用')
      return
    }
    
    loading.value = true
    
    const success = await userStore.register({
      username: registerForm.username,
      password: registerForm.password,
      email: registerForm.email || undefined,
      full_name: registerForm.fullName || undefined,
      role: registerForm.role as any,
      grade: registerForm.grade || undefined,
      school: registerForm.school || undefined,
    })
    
    if (success) {
      ElMessage.success('注册成功！')
      router.push('/dashboard')
    }
  } catch (error: any) {
    if (error?.errors) {
      // 表单验证错误，不需要处理
    } else {
      console.error('注册错误:', error)
    }
  } finally {
    loading.value = false
  }
}

// 监听用户名变化，重置检查状态
watch(() => registerForm.username, () => {
  usernameChecked.value = null
})

// 监听邮箱变化，重置检查状态
watch(() => registerForm.email, () => {
  emailChecked.value = null
})
</script>

<style lang="scss" scoped>
.register-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.register-wrapper {
  width: 100%;
  max-width: 1200px;
  background: white;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.1);
  display: flex;
  min-height: 700px;
}

.register-left {
  flex: 1.2;
  padding: 60px 40px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.register-form-wrapper {
  width: 100%;
  max-width: 500px;
  
  .register-header {
    margin-bottom: 40px;
    
    .back-link {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      color: #6b7280;
      font-size: 14px;
      margin-bottom: 20px;
      cursor: pointer;
      transition: color 0.2s;
      
      &:hover {
        color: #3b82f6;
      }
    }
    
    h2 {
      font-size: 32px;
      font-weight: 700;
      color: #1f2937;
      margin-bottom: 8px;
    }
    
    p {
      color: #6b7280;
      font-size: 16px;
    }
  }
  
  .register-form {
    .password-strength {
      margin-top: 8px;
      
      .strength-bar {
        height: 4px;
        border-radius: 2px;
        margin-bottom: 4px;
        transition: all 0.3s;
        
        &.weak {
          width: 33%;
          background: #ef4444;
        }
        
        &.medium {
          width: 66%;
          background: #f59e0b;
        }
        
        &.strong {
          width: 100%;
          background: #10b981;
        }
      }
      
      .strength-text {
        font-size: 12px;
        color: #6b7280;
        text-align: right;
      }
    }
    
    .grade-option {
      display: flex;
      justify-content: space-between;
      width: 100%;
      
      .grade-label {
        font-weight: 500;
      }
      
      .grade-years {
        color: #6b7280;
        font-size: 12px;
      }
    }
    
    .register-btn {
      width: 100%;
      height: 48px;
      font-size: 16px;
      font-weight: 500;
    }
    
    .login-link {
      text-align: center;
      color: #6b7280;
      font-size: 14px;
      margin-top: 24px;
      
      .el-link {
        margin-left: 4px;
      }
    }
  }
}

.register-right {
  flex: 0.8;
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
  padding: 60px 40px;
  color: white;
  display: flex;
  align-items: center;
}

.register-info {
  max-width: 400px;
  
  .info-icon {
    font-size: 80px;
    margin-bottom: 24px;
    text-align: center;
  }
  
  .info-title {
    font-size: 28px;
    font-weight: 700;
    margin-bottom: 40px;
    text-align: center;
  }
  
  .info-list {
    .info-item {
      display: flex;
      align-items: flex-start;
      gap: 16px;
      margin-bottom: 32px;
      
      .el-icon {
        font-size: 24px;
        color: #93c5fd;
        margin-top: 4px;
        flex-shrink: 0;
      }
      
      h4 {
        font-size: 18px;
        font-weight: 600;
        margin-bottom: 4px;
      }
      
      p {
        color: rgba(255, 255, 255, 0.8);
        font-size: 14px;
        line-height: 1.5;
      }
    }
  }
}

.terms-content,
.privacy-content {
  max-height: 400px;
  overflow-y: auto;
  padding: 20px;
  line-height: 1.6;
}

// 响应式设计
@media (max-width: 992px) {
  .register-wrapper {
    flex-direction: column;
    max-width: 600px;
  }
  
  .register-left {
    padding: 40px 20px;
  }
  
  .register-right {
    padding: 40px 20px;
  }
}

@media (max-width: 576px) {
  .register-form {
    :deep(.el-radio-group) {
      display: flex;
      flex-direction: column;
      gap: 8px;
      
      .el-radio-button {
        width: 100%;
        
        .el-radio-button__inner {
          width: 100%;
        }
      }
    }
  }
}
</style>
