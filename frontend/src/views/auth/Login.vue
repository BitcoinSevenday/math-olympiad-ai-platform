<template>
  <div class="login-container">
    <div class="login-wrapper">
      <!-- 左侧背景 -->
      <div class="login-left">
        <div class="login-hero">
          <div class="hero-icon">🧮</div>
          <h1 class="hero-title">奥赛AI平台</h1>
          <p class="hero-subtitle">智能数学奥赛学习系统</p>
          <div class="hero-features">
            <div class="feature-item">
              <el-icon><Reading /></el-icon>
              <span>海量奥赛题库</span>
            </div>
            <div class="feature-item">
              <el-icon><TrendCharts /></el-icon>
              <span>智能学习分析</span>
            </div>
            <div class="feature-item">
              <el-icon><MagicStick /></el-icon>
              <span>个性化推荐</span>
            </div>
          </div>
        </div>
      </div>
      
      <!-- 右侧登录表单 -->
      <div class="login-right">
        <div class="login-form-wrapper">
          <div class="login-header">
            <h2>欢迎回来</h2>
            <p>请输入您的账号密码登录</p>
          </div>
          
          <el-form
            ref="loginFormRef"
            :model="loginForm"
            :rules="loginRules"
            class="login-form"
            @keyup.enter="handleLogin"
          >
            <el-form-item prop="username">
              <el-input
                v-model="loginForm.username"
                placeholder="用户名"
                size="large"
                :prefix-icon="User"
              />
            </el-form-item>
            
            <el-form-item prop="password">
              <el-input
                v-model="loginForm.password"
                type="password"
                placeholder="密码"
                size="large"
                :prefix-icon="Lock"
                show-password
              />
            </el-form-item>
            
            <div class="form-options">
              <el-checkbox v-model="rememberMe">记住我</el-checkbox>
              <el-link type="primary" :underline="false" @click="$router.push('/forgot-password')">
                忘记密码？
              </el-link>
            </div>
            
            <el-form-item>
              <el-button
                type="primary"
                size="large"
                :loading="loading"
                @click="handleLogin"
                class="login-btn"
              >
                登录
              </el-button>
            </el-form-item>
            
            <div class="login-divider">
              <span>其他登录方式</span>
            </div>
            
            <div class="social-login">
              <el-tooltip content="开发中" placement="top">
                <el-button class="social-btn" circle>
                  <el-icon><ChatDotRound /></el-icon>
                </el-button>
              </el-tooltip>
              <el-tooltip content="开发中" placement="top">
                <el-button class="social-btn" circle>
                  <svg-icon name="wechat" />
                </el-button>
              </el-tooltip>
              <el-tooltip content="开发中" placement="top">
                <el-button class="social-btn" circle>
                  <el-icon><Message /></el-icon>
                </el-button>
              </el-tooltip>
            </div>
            
            <div class="register-link">
              还没有账号？
              <el-link type="primary" :underline="false" @click="$router.push('/register')">
                立即注册
              </el-link>
            </div>
          </el-form>
          
          <!-- 演示账号提示 -->
          <el-alert
            v-if="showDemoTips"
            title="演示账号"
            type="info"
            :closable="false"
            show-icon
            class="demo-alert"
          >
            <p>用户名: <code>demo_student</code> 密码: <code>password</code></p>
            <p>用户名: <code>demo_teacher</code> 密码: <code>password</code></p>
            <p>用户名: <code>admin</code> 密码: <code>admin123</code></p>
          </el-alert>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { User, Lock, Reading, TrendCharts, MagicStick, ChatDotRound, Message } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'

const router = useRouter()
const userStore = useUserStore()

// 表单引用
const loginFormRef = ref<FormInstance>()

// 表单数据
const loginForm = reactive({
  username: '',
  password: '',
})

// 表单验证规则
const loginRules: FormRules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { min: 3, max: 50, message: '用户名长度在 3 到 50 个字符', trigger: 'blur' },
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, max: 100, message: '密码长度在 6 到 100 个字符', trigger: 'blur' },
  ],
}

// 状态
const loading = ref(false)
const rememberMe = ref(false)
const showDemoTips = computed(() => import.meta.env.DEV)

// 处理登录
const handleLogin = async () => {
  if (!loginFormRef.value) return
  
  try {
    await loginFormRef.value.validate()
    
    loading.value = true
    
    const success = await userStore.login(loginForm.username, loginForm.password)
    
    if (success) {
      ElMessage.success('登录成功')
      router.push('/dashboard')
    }
  } catch (error: any) {
    if (error?.errors) {
      // 表单验证错误，不需要处理
    } else {
      console.error('登录错误:', error)
    }
  } finally {
    loading.value = false
  }
}

// 加载记住的账号
const loadRememberedAccount = () => {
  const remembered = localStorage.getItem('remembered_account')
  if (remembered) {
    try {
      const account = JSON.parse(remembered)
      loginForm.username = account.username || ''
      rememberMe.value = true
    } catch (error) {
      console.error('加载记住的账号失败:', error)
    }
  }
}

// 保存记住的账号
const saveRememberedAccount = () => {
  if (rememberMe.value && loginForm.username) {
    localStorage.setItem('remembered_account', JSON.stringify({
      username: loginForm.username,
    }))
  } else {
    localStorage.removeItem('remembered_account')
  }
}

// 页面加载时
onMounted(() => {
  loadRememberedAccount()
  
  // 如果已登录，跳转到首页
  if (userStore.isLoggedIn) {
    router.push('/dashboard')
  }
})

// 监听记住我变化
watch(rememberMe, saveRememberedAccount)
</script>

<style lang="scss" scoped>
.login-container {
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 20px;
}

.login-wrapper {
  width: 100%;
  max-width: 1000px;
  background: white;
  border-radius: 20px;
  overflow: hidden;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.1);
  display: flex;
  min-height: 600px;
}

.login-left {
  flex: 1;
  background: linear-gradient(135deg, #3b82f6 0%, #1d4ed8 100%);
  padding: 60px 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  
  .login-hero {
    text-align: center;
    max-width: 400px;
    
    .hero-icon {
      font-size: 80px;
      margin-bottom: 24px;
      animation: float 3s ease-in-out infinite;
    }
    
    .hero-title {
      font-size: 36px;
      font-weight: 700;
      margin-bottom: 12px;
      background: linear-gradient(to right, #fff, #e0e7ff);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }
    
    .hero-subtitle {
      font-size: 18px;
      color: rgba(255, 255, 255, 0.8);
      margin-bottom: 40px;
    }
    
    .hero-features {
      .feature-item {
        display: flex;
        align-items: center;
        justify-content: center;
        gap: 12px;
        margin: 16px 0;
        font-size: 16px;
        
        .el-icon {
          font-size: 20px;
          color: #93c5fd;
        }
      }
    }
  }
}

.login-right {
  flex: 1;
  padding: 60px 40px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.login-form-wrapper {
  width: 100%;
  max-width: 400px;
  
  .login-header {
    text-align: center;
    margin-bottom: 40px;
    
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
  
  .login-form {
    .form-options {
      display: flex;
      align-items: center;
      justify-content: space-between;
      margin-bottom: 24px;
      
      :deep(.el-checkbox__label) {
        color: #6b7280;
      }
    }
    
    .login-btn {
      width: 100%;
      height: 48px;
      font-size: 16px;
      font-weight: 500;
    }
    
    .login-divider {
      position: relative;
      text-align: center;
      margin: 32px 0;
      color: #9ca3af;
      
      &::before,
      &::after {
        content: '';
        position: absolute;
        top: 50%;
        width: 45%;
        height: 1px;
        background: #e5e7eb;
      }
      
      &::before {
        left: 0;
      }
      
      &::after {
        right: 0;
      }
    }
    
    .social-login {
      display: flex;
      justify-content: center;
      gap: 16px;
      margin-bottom: 32px;
      
      .social-btn {
        width: 48px;
        height: 48px;
        border: 1px solid #e5e7eb;
        background: white;
        
        &:hover {
          border-color: #3b82f6;
          color: #3b82f6;
          background: #eff6ff;
        }
        
        .el-icon {
          font-size: 20px;
        }
      }
    }
    
    .register-link {
      text-align: center;
      color: #6b7280;
      font-size: 14px;
      
      .el-link {
        margin-left: 4px;
      }
    }
  }
  
  .demo-alert {
    margin-top: 24px;
    border-radius: 8px;
    
    p {
      margin: 4px 0;
      font-size: 13px;
      
      code {
        background: #f3f4f6;
        padding: 2px 6px;
        border-radius: 4px;
        font-family: monospace;
      }
    }
  }
}

@keyframes float {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-10px);
  }
}

// 响应式设计
@media (max-width: 768px) {
  .login-wrapper {
    flex-direction: column;
    max-width: 400px;
  }
  
  .login-left {
    padding: 40px 20px;
    
    .login-hero {
      .hero-icon {
        font-size: 60px;
      }
      
      .hero-title {
        font-size: 28px;
      }
      
      .hero-subtitle {
        font-size: 16px;
      }
    }
  }
  
  .login-right {
    padding: 40px 20px;
  }
}
</style>
