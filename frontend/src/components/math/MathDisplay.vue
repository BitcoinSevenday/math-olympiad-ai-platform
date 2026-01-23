<template>
  <div class="math-display" ref="mathContainer">
    <!-- LaTeX模式显示 -->
    <div v-if="showRaw && content" class="math-raw">
      <pre><code>{{ content }}</code></pre>
      <el-button
        type="text"
        size="small"
        @click="showRaw = false"
        class="toggle-raw-btn"
      >
        隐藏源代码
      </el-button>
    </div>
    
    <!-- 渲染后显示 -->
    <div
      v-else
      class="math-rendered"
      :class="{ 'has-error': hasError }"
      v-html="renderedContent"
    />
    
    <!-- 操作按钮 -->
    <div v-if="content" class="math-actions">
      <el-tooltip content="复制公式" placement="top">
        <el-button
          type="text"
          size="small"
          @click="copyToClipboard"
          class="action-btn"
        >
          <el-icon><DocumentCopy /></el-icon>
        </el-button>
      </el-tooltip>
      
      <el-tooltip v-if="isLatex" content="查看源代码" placement="top">
        <el-button
          type="text"
          size="small"
          @click="showRaw = !showRaw"
          class="action-btn"
        >
          <el-icon><Code /></el-icon>
        </el-button>
      </el-tooltip>
      
      <el-tooltip v-if="hasError" content="渲染错误" placement="top">
        <el-button
          type="text"
          size="small"
          class="action-btn error"
        >
          <el-icon><Warning /></el-icon>
        </el-button>
      </el-tooltip>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, onMounted, watch, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import { DocumentCopy, Code, Warning } from '@element-plus/icons-vue'
import katex from 'katex'
import 'katex/dist/katex.min.css'

const props = withDefaults(defineProps<{
  content: string
  type?: 'text' | 'markdown' | 'latex'
  displayMode?: boolean
  throwOnError?: boolean
}>(), {
  type: 'text',
  displayMode: false,
  throwOnError: false,
})

const emit = defineEmits<{
  'rendered': [success: boolean]
  'error': [error: Error]
}>()

const mathContainer = ref<HTMLElement>()
const showRaw = ref(false)
const hasError = ref(false)

// 检查是否是LaTeX内容
const isLatex = computed(() => {
  if (!props.content) return false
  const content = props.content.trim()
  return (
    content.startsWith('$') && content.endsWith('$') ||
    content.startsWith('\\(') && content.endsWith('\\)') ||
    content.startsWith('\\[') && content.endsWith('\\]') ||
    content.includes('\\frac') ||
    content.includes('\\sqrt') ||
    content.includes('\\sum') ||
    content.includes('\\int')
  )
})

// 渲染后的内容
const renderedContent = computed(() => {
  if (!props.content) return ''
  
  try {
    const content = props.content.trim()
    
    switch (props.type) {
      case 'latex':
        // 处理LaTeX数学公式
        return katex.renderToString(content, {
          displayMode: props.displayMode,
          throwOnError: props.throwOnError,
          errorColor: '#ff0000',
          macros: {
            '\\RR': '\\mathbb{R}',
            '\\NN': '\\mathbb{N}',
            '\\ZZ': '\\mathbb{Z}',
            '\\QQ': '\\mathbb{Q}',
            '\\CC': '\\mathbb{C}',
          }
        })
        
      case 'markdown':
        // 处理Markdown中的数学公式
        let html = content
        // 处理行内公式：$...$
        html = html.replace(/\$([^$]+)\$/g, (match, math) => {
          try {
            return katex.renderToString(math, {
              displayMode: false,
              throwOnError: false,
            })
          } catch {
            return match
          }
        })
        // 处理块公式：$$...$$
        html = html.replace(/\$\$([^$]+)\$\$/g, (match, math) => {
          try {
            return katex.renderToString(math, {
              displayMode: true,
              throwOnError: false,
            })
          } catch {
            return match
          }
        })
        return html
        
      default:
        // 纯文本，尝试检测并渲染数学公式
        if (isLatex.value) {
          const cleanContent = content
            .replace(/^\$|\$$/g, '')
            .replace(/^\\\(|\\\)$/g, '')
            .replace(/^\\\[|\\\]$/g, '')
          
          return katex.renderToString(cleanContent, {
            displayMode: props.displayMode,
            throwOnError: false,
          })
        }
        return props.content
    }
  } catch (error: any) {
    hasError.value = true
    emit('error', error)
    console.error('数学公式渲染失败:', error)
    
    // 返回错误信息
    return `<div class="math-error">
      <div class="error-message">公式渲染失败</div>
      <div class="error-content">${props.content}</div>
    </div>`
  }
})

// 复制到剪贴板
const copyToClipboard = async () => {
  try {
    await navigator.clipboard.writeText(props.content)
    ElMessage.success('公式已复制到剪贴板')
  } catch (error) {
    console.error('复制失败:', error)
    ElMessage.error('复制失败')
  }
}

// 监听内容变化
watch(() => props.content, () => {
  hasError.value = false
  showRaw.value = false
  
  nextTick(() => {
    emit('rendered', !hasError.value)
  })
})

// 组件挂载时
onMounted(() => {
  nextTick(() => {
    emit('rendered', !hasError.value)
  })
})
</script>

<style lang="scss" scoped>
.math-display {
  position: relative;
  margin: 8px 0;
  padding: 12px;
  background: var(--el-fill-color-lighter);
  border-radius: 8px;
  border: 1px solid var(--el-border-color);
  transition: all 0.3s ease;
  
  &:hover {
    border-color: var(--el-color-primary);
    background: var(--el-fill-color);
    
    .math-actions {
      opacity: 1;
    }
  }
  
  &.has-error {
    border-color: var(--el-color-error);
    background: var(--el-color-error-light-9);
  }
}

.math-raw {
  pre {
    margin: 0;
    padding: 12px;
    background: var(--el-fill-color-darker);
    border-radius: 4px;
    overflow-x: auto;
    
    code {
      font-family: 'Monaco', 'Menlo', 'Consolas', monospace;
      font-size: 14px;
      color: var(--el-text-color-primary);
    }
  }
  
  .toggle-raw-btn {
    margin-top: 8px;
  }
}

.math-rendered {
  :deep(.katex) {
    font-size: 1.1em;
    
    .katex-html {
      overflow-x: auto;
      overflow-y: hidden;
    }
  }
  
  :deep(.math-error) {
    color: var(--el-color-error);
    font-family: monospace;
    font-size: 14px;
    
    .error-message {
      font-weight: 500;
      margin-bottom: 4px;
    }
    
    .error-content {
      background: var(--el-fill-color);
      padding: 8px;
      border-radius: 4px;
      border-left: 3px solid var(--el-color-error);
    }
  }
}

.math-actions {
  position: absolute;
  top: 8px;
  right: 8px;
  display: flex;
  gap: 4px;
  opacity: 0.6;
  transition: opacity 0.3s ease;
  
  .action-btn {
    padding: 4px;
    min-width: auto;
    
    &:hover {
      opacity: 1;
    }
    
    &.error {
      color: var(--el-color-error);
    }
  }
}

// 暗色模式适配
:global(.dark) {
  .math-display {
    background: var(--el-bg-color-page);
  }
  
  .math-raw {
    pre {
      background: var(--el-bg-color);
    }
  }
}
</style>
