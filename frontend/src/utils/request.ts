/**
 * axios HTTP请求工具
 * 封装请求拦截、响应拦截、错误处理
 */
import axios, {
  type AxiosInstance,
  type AxiosRequestConfig,
  type AxiosResponse,
  type InternalAxiosRequestConfig
} from 'axios'
import { useUserStore } from '@/stores/user'
import { ElMessage, ElMessageBox } from 'element-plus'
import router from '@/router'

// 环境配置
const isDevelopment = import.meta.env.MODE === 'development'
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000'

// 创建axios实例
const service: AxiosInstance = axios.create({
  baseURL: 'http://localhost:8000',
  timeout: 15000, // 15秒超时
  headers: {
    'Content-Type': 'application/json;charset=utf-8'
  }
})

// 请求拦截器
service.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    // 在发送请求之前做些什么
    const userStore = useUserStore()
    
    // 添加token
    if (userStore.token) {
      config.headers.Authorization = `Bearer ${userStore.token}`
    }
    
    // 开发环境日志
    if (isDevelopment) {
      console.log(`📤 请求: ${config.method?.toUpperCase()} ${config.url}`, config.data || '')
    }
    
    return config
  },
  (error: any) => {
    // 对请求错误做些什么
    console.error('❌ 请求错误:', error)
    return Promise.reject(error)
  }
)

// 响应拦截器
service.interceptors.response.use(
  (response: AxiosResponse) => {
    // 对响应数据做点什么
    const res = response.data
    
    // 开发环境日志
    if (isDevelopment) {
      console.log(`📥 响应: ${response.config.url}`, res)
    }
    
    // 业务状态码处理（根据后端API设计调整）
    if (response.status === 200) {
      return res
    } else {
      // 业务错误处理
      handleBusinessError(res)
      return Promise.reject(new Error(res.message || 'Error'))
    }
  },
  (error: any) => {
    // 对响应错误做点什么
    console.error('❌ 响应错误:', error)
    
    // 网络错误处理
    if (!error.response) {
      ElMessage.error('网络错误，请检查网络连接')
      return Promise.reject(error)
    }
    
    // HTTP状态码处理
    handleHttpError(error)
    
    return Promise.reject(error)
  }
)

// 业务错误处理
function handleBusinessError(response: any) {
  const { code, message } = response
  
  // 根据业务状态码处理
  switch (code) {
    case 400:
      ElMessage.warning(message || '请求参数错误')
      break
    case 401:
      handleUnauthorized()
      break
    case 403:
      ElMessage.warning(message || '没有权限')
      break
    case 404:
      ElMessage.warning(message || '资源不存在')
      break
    case 500:
      ElMessage.error(message || '服务器错误')
      break
    default:
      ElMessage.warning(message || '未知错误')
  }
}

// HTTP错误处理
function handleHttpError(error: any) {
  const { response } = error
  const userStore = useUserStore()
  
  if (!response) return
  
  switch (response.status) {
    case 400:
      ElMessage.error(response.data?.message || '请求错误')
      break
    case 401:
      handleUnauthorized()
      break
    case 403:
      ElMessage.error('没有权限访问')
      if (userStore.token) {
        // 有token但没权限，可能是token过期
        userStore.logout()
        router.push('/login')
      }
      break
    case 404:
      ElMessage.error('请求的资源不存在')
      break
    case 408:
      ElMessage.error('请求超时')
      break
    case 500:
      ElMessage.error('服务器内部错误')
      break
    case 502:
      ElMessage.error('网关错误')
      break
    case 503:
      ElMessage.error('服务不可用')
      break
    case 504:
      ElMessage.error('网关超时')
      break
    default:
      ElMessage.error(`请求失败: ${response.status}`)
  }
}

// 未授权处理
function handleUnauthorized() {
  const userStore = useUserStore()
  
  // 清除用户信息
  userStore.logout()
  
  // 显示登录提示
  ElMessageBox.confirm(
    '登录已过期，请重新登录',
    '提示',
    {
      confirmButtonText: '重新登录',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    router.push('/login')
  }).catch(() => {
    // 用户取消
  })
}

// 封装GET请求
export function get<T = any>(url: string, config?: AxiosRequestConfig): Promise<T> {
  return service.get(url, config)
}

// 封装POST请求
export function post<T = any>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
  return service.post(url, data, config)
}

// 封装PUT请求
export function put<T = any>(url: string, data?: any, config?: AxiosRequestConfig): Promise<T> {
  return service.put(url, data, config)
}

// 封装DELETE请求
export function del<T = any>(url: string, config?: AxiosRequestConfig): Promise<T> {
  return service.delete(url, config)
}

// 文件上传
export function uploadFile(url: string, file: File, onProgress?: (progress: number) => void) {
  const formData = new FormData()
  formData.append('file', file)
  
  return service.post(url, formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    },
    onUploadProgress: (progressEvent) => {
      if (onProgress && progressEvent.total) {
        const progress = Math.round((progressEvent.loaded * 100) / progressEvent.total)
        onProgress(progress)
      }
    }
  })
}

export default service
