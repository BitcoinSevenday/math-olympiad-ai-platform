<template>
  <div
    class="markdown-viewer"
    :class="{
      'readonly': readonly,
      'editing': editing,
      [size]: true
    }"
    ref="viewerRef"
  >
    <!-- 编辑模式 -->
    <div v-if="editing" class="markdown-editor">
      <div class="editor-toolbar">
        <div class="toolbar-left">
          <el-button-group>
            <el-tooltip content="加粗" placement="top">
              <el-button size="small" @click="insertText('**', '**')">
                <span class="toolbar-icon">B</span>
              </el-button>
            </el-tooltip>
            <el-tooltip content="斜体" placement="top">
              <el-button size="small" @click="insertText('*', '*')">
                <span class="toolbar-icon"><i>I</i></span>
              </el-button>
            </el-tooltip>
            <el-tooltip content="标题" placement="top">
              <el-button size="small" @click="insertText('# ', '')">
                <span class="toolbar-icon">H</span>
              </el-button>
            </el-tooltip>
          </el-button-group>
          
          <el-button-group>
            <el-tooltip content="行内公式" placement="top">
              <el-button size="small" @click="insertText('$', '$')">
                <span class="toolbar-icon">∑</span>
              </el-button>
            </el-tooltip>
            <el-tooltip content="块公式" placement="top">
              <el-button size="small" @click="insertText('$$\\n', '\\n$$')">
                <span class="toolbar-icon">∑∑</span>
              </el-button>
            </el-tooltip>
            <el-tooltip content="分数" placement="top">
              <el-button size="small" @click="insertText('\\frac{}{}', '', 6)">
                <span class="toolbar-icon">a/b</span>
              </el-button>
            </el-tooltip>
          </el-button-group>
          
          <el-button-group>
            <el-tooltip content="链接" placement="top">
              <el-button size="small" @click="insertText('[', '](url)')">
                <el-icon><Link /></el-icon>
              </el-button>
            </el-tooltip>
            <el-tooltip content="图片" placement="top">
              <el-button size="small" @click="insertText('![', '](url)')">
                <el-icon><Picture /></el-icon>
              </el-button>
            </el-tooltip>
            <el-tooltip content="代码" placement="top">
              <el-button size="small" @click="insertText('`', '`')">
                <el-icon><CPU /></el-icon>
              </el-button>
            </el-tooltip>
          </el-button-group>
        </div>
        
        <div class="toolbar-right">
          <el-button
            size="small"
            @click="togglePreview"
          >
            {{ showPreview ? '编辑' : '预览' }}
          </el-button>
        </div>
      </div>
      
      <div class="editor-content">
        <!-- 编辑区域 -->
        <div v-show="!showPreview" class="editor-textarea">
          <el-input
            ref="textareaRef"
            v-model="editContent"
            type="textarea"
            :rows="rows"
            :placeholder="placeholder"
            resize="none"
            @input="handleInput"
            @keydown.tab.prevent="handleTab"
            class="markdown-textarea"
          />
        </div>
        
        <!-- 预览区域 -->
        <div v-show="showPreview" class="editor-preview">
          <div
            class="preview-content"
            v-html="renderedContent"
          />
        </div>
      </div>
      
      <div class="editor-footer">
        <div class="footer-left">
          <span class="char-count">
            字数: {{ charCount }} | 行数: {{ lineCount }}
          </span>
        </div>
        <div class="footer-right">
          <el-button size="small" @click="cancelEdit">
            取消
          </el-button>
          <el-button type="primary" size="small" @click="saveEdit">
            保存
          </el-button>
        </div>
      </div>
    </div>
    
    <!-- 只读模式 -->
    <div v-else class="markdown-preview">
      <div
        class="preview-content"
        :class="{ 'empty': !content }"
        v-html="renderedContent"
        @dblclick="handleDoubleClick"
      />
      
      <div v-if="!content" class="empty-prompt" @click="startEdit">
        <el-icon><EditPen /></el-icon>
        <span>双击此处编辑内容</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, computed, watch, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import { Link, Picture, CPU, EditPen } from '@element-plus/icons-vue'
import { renderMarkdown } from '@/utils/markdown/renderer'

const props = withDefaults(defineProps<{
  content: string
  placeholder?: string
  readonly?: boolean
  editable?: boolean
  size?: 'small' | 'medium' | 'large'
  rows?: number
}>(), {
  placeholder: '请输入Markdown内容...',
  readonly: false,
  editable: true,
  size: 'medium',
  rows: 6,
})

const emit = defineEmits<{
  'update:content': [content: string]
  'save': [content: string]
  'cancel': []
  'edit': []
}>()

// 引用
const viewerRef = ref<HTMLElement>()
const textareaRef = ref<any>()

// 状态
const editing = ref(false)
const showPreview = ref(false)
const editContent = ref('')

// 计算属性
const renderedContent = computed(() => {
  return renderMarkdown(props.content || '')
})

const charCount = computed(() => {
  return editContent.value.length
})

const lineCount = computed(() => {
  return editContent.value.split('\n').length
})

// 开始编辑
const startEdit = () => {
  if (props.readonly || !props.editable) return
  
  editing.value = true
  editContent.value = props.content
  showPreview.value = false
  
  nextTick(() => {
    if (textareaRef.value) {
      textareaRef.value.focus()
    }
  })
  
  emit('edit')
}

// 取消编辑
const cancelEdit = () => {
  editing.value = false
  editContent.value = ''
  showPreview.value = false
  emit('cancel')
}

// 保存编辑
const saveEdit = () => {
  const newContent = editContent.value.trim()
  emit('update:content', newContent)
  emit('save', newContent)
  editing.value = false
  ElMessage.success('内容已保存')
}

// 切换预览
const togglePreview = () => {
  showPreview.value = !showPreview.value
}

// 处理输入
const handleInput = () => {
  // 可以在这里添加实时保存或自动完成功能
}

// 处理Tab键
const handleTab = (event: KeyboardEvent) => {
  const textarea = event.target as HTMLTextAreaElement
  const start = textarea.selectionStart
  const end = textarea.selectionEnd
  
  // 插入两个空格
  editContent.value = editContent.value.substring(0, start) + '  ' + editContent.value.substring(end)
  
  nextTick(() => {
    textarea.selectionStart = textarea.selectionEnd = start + 2
  })
}

// 插入文本
const insertText = (before: string, after: string, cursorOffset: number = before.length) => {
  if (!textareaRef.value) return
  
  const textarea = textareaRef.value.textarea
  const start = textarea.selectionStart
  const end = textarea.selectionEnd
  const selectedText = editContent.value.substring(start, end)
  
  const newText = before + selectedText + after
  editContent.value = editContent.value.substring(0, start) + newText + editContent.value.substring(end)
  
  nextTick(() => {
    const newCursorPos = start + (selectedText ? before.length + selectedText.length : cursorOffset)
    textarea.selectionStart = textarea.selectionEnd = newCursorPos
    textarea.focus()
  })
}

// 双击开始编辑
const handleDoubleClick = () => {
  if (props.editable && !props.readonly) {
    startEdit()
  }
}

// 监听内容变化
watch(() => props.content, (newContent) => {
  if (!editing.value) {
    editContent.value = newContent
  }
})

// 初始化
if (!props.content && props.editable && !props.readonly) {
  editing.value = true
}
</script>

<style lang="scss" scoped>
.markdown-viewer {
  &.small {
    font-size: 14px;
  }
  
  &.medium {
    font-size: 16px;
  }
  
  &.large {
    font-size: 18px;
  }
}

.markdown-editor {
  border: 1px solid var(--el-border-color);
  border-radius: 8px;
  overflow: hidden;
  background: var(--el-bg-color);
  
  .editor-toolbar {
    padding: 8px 12px;
    background: var(--el-fill-color-light);
    border-bottom: 1px solid var(--el-border-color);
    display: flex;
    align-items: center;
    justify-content: space-between;
    
    .toolbar-left {
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
      
      .el-button-group {
        .el-button {
          padding: 4px 8px;
          
          .toolbar-icon {
            font-weight: 600;
            
            i {
              font-style: italic;
            }
          }
        }
      }
    }
  }
  
  .editor-content {
    display: flex;
    min-height: 200px;
    
    .editor-textarea,
    .editor-preview {
      flex: 1;
      min-width: 0;
    }
    
    .editor-textarea {
      padding: 12px;
      
      .markdown-textarea {
        :deep(.el-textarea__inner) {
          font-family: 'Monaco', 'Menlo', 'Consolas', monospace;
          font-size: 14px;
          line-height: 1.6;
          border: none;
          resize: none;
          
          &:focus {
            box-shadow: none;
          }
        }
      }
    }
    
    .editor-preview {
      padding: 12px;
      overflow-y: auto;
      border-left: 1px solid var(--el-border-color);
      
      .preview-content {
        min-height: 100%;
      }
    }
  }
  
  .editor-footer {
    padding: 8px 12px;
    background: var(--el-fill-color-lighter);
    border-top: 1px solid var(--el-border-color);
    display: flex;
    align-items: center;
    justify-content: space-between;
    
    .char-count {
      font-size: 12px;
      color: var(--el-text-color-secondary);
    }
  }
}

.markdown-preview {
  position: relative;
  min-height: 60px;
  
  .preview-content {
    line-height: 1.6;
    
    &.empty {
      opacity: 0.5;
    }
    
    // Markdown内容样式
    :deep() {
      h1, h2, h3, h4, h5, h6 {
        margin: 1.2em 0 0.6em;
        font-weight: 600;
        line-height: 1.25;
        
        &:first-child {
          margin-top: 0;
        }
      }
      
      h1 { font-size: 2em; }
      h2 { font-size: 1.5em; }
      h3 { font-size: 1.25em; }
      h4 { font-size: 1em; }
      h5 { font-size: 0.875em; }
      h6 { font-size: 0.85em; color: var(--el-text-color-secondary); }
      
      p {
        margin: 0.8em 0;
        
        &:first-child {
          margin-top: 0;
        }
        
        &:last-child {
          margin-bottom: 0;
        }
      }
      
      a {
        color: var(--el-color-primary);
        text-decoration: none;
        
        &:hover {
          text-decoration: underline;
        }
      }
      
      code {
        font-family: 'Monaco', 'Menlo', 'Consolas', monospace;
        background: var(--el-fill-color-light);
        padding: 2px 6px;
        border-radius: 4px;
        font-size: 0.9em;
      }
      
      pre {
        margin: 1em 0;
        padding: 1em;
        background: var(--el-fill-color-light);
        border-radius: 8px;
        overflow-x: auto;
        
        code {
          background: transparent;
          padding: 0;
          font-size: 0.9em;
        }
      }
      
      blockquote {
        margin: 1em 0;
        padding: 0.5em 1em;
        border-left: 4px solid var(--el-border-color);
        color: var(--el-text-color-secondary);
        background: var(--el-fill-color-lighter);
        
        p {
          margin: 0.5em 0;
        }
      }
      
      ul, ol {
        margin: 1em 0;
        padding-left: 2em;
        
        li {
          margin: 0.4em 0;
        }
      }
      
      table {
        width: 100%;
        border-collapse: collapse;
        margin: 1em 0;
        
        th, td {
          padding: 0.75em 1em;
          border: 1px solid var(--el-border-color);
        }
        
        th {
          background: var(--el-fill-color-light);
          font-weight: 600;
        }
        
        tr:hover {
          background: var(--el-fill-color-lighter);
        }
      }
      
      img {
        max-width: 100%;
        height: auto;
        border-radius: 4px;
      }
      
      .katex-display {
        margin: 1em 0;
        overflow-x: auto;
        overflow-y: hidden;
      }
    }
  }
  
  .empty-prompt {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    color: var(--el-text-color-placeholder);
    cursor: pointer;
    transition: all 0.3s ease;
    
    .el-icon {
      font-size: 24px;
      margin-bottom: 8px;
    }
    
    span {
      font-size: 14px;
    }
    
    &:hover {
      color: var(--el-color-primary);
      background: var(--el-fill-color-light);
      border-radius: 8px;
    }
  }
}

// 暗色模式适配
:global(.dark) {
  .markdown-editor {
    background: var(--el-bg-color);
    
    .editor-toolbar {
      background: var(--el-bg-color-page);
    }
    
    .editor-footer {
      background: var(--el-bg-color-page);
    }
  }
}
</style>
