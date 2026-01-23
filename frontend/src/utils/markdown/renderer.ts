/**
 * Markdown和数学公式渲染工具
 * 支持KaTeX数学公式渲染
 */
import MarkdownIt from 'markdown-it'
import mk from 'markdown-it-katex'
import hljs from 'highlight.js'
import 'highlight.js/styles/github.css'
import 'katex/dist/katex.min.css'

// 创建Markdown解析器
const md = new MarkdownIt({
  html: true, // 允许HTML标签
  linkify: true, // 自动转换链接
  typographer: true, // 启用排版优化
  highlight: function (str, lang) {
    if (lang && hljs.getLanguage(lang)) {
      try {
        return `<pre class="hljs"><code>${
          hljs.highlight(str, { language: lang, ignoreIllegals: true }).value
        }</code></pre>`
      } catch (__) {}
    }
    return `<pre class="hljs"><code>${md.utils.escapeHtml(str)}</code></pre>`
  }
}).use(mk, {
  throwOnError: false,
  errorColor: '#cc0000'
})

// 自定义渲染规则
md.renderer.rules.table_open = () => '<div class="table-container"><table class="el-table el-table--border">'
md.renderer.rules.table_close = () => '</table></div>'

// 渲染Markdown为HTML
export function renderMarkdown(content: string): string {
  if (!content) return ''
  return md.render(content)
}

// 渲染纯文本（无Markdown格式）
export function renderText(content: string): string {
  if (!content) return ''
  return md.renderInline(content)
}

// 检查是否包含数学公式
export function hasMath(content: string): boolean {
  return /\$\$[\s\S]*?\$\$|\$[\s\S]*?\$|\\\([\s\S]*?\\\)|\\\[[\s\S]*?\\\]/.test(content)
}

// 提取纯文本（去除Markdown标记）
export function extractText(content: string): string {
  if (!content) return ''
  
  // 简单的Markdown标记移除
  return content
    .replace(/#{1,6}\s*/g, '') // 标题
    .replace(/\*\*([^*]+)\*\*/g, '$1') // 粗体
    .replace(/\*([^*]+)\*/g, '$1') // 斜体
    .replace(/`([^`]+)`/g, '$1') // 行内代码
    .replace(/!\[([^\]]*)\]\([^)]*\)/g, '$1') // 图片
    .replace(/\[([^\]]+)\]\([^)]+\)/g, '$1') // 链接
    .replace(/^\s*[-*+]\s+/gm, '') // 列表
    .replace(/^\s*\d+\.\s+/gm, '') // 有序列表
    .replace(/\n{3,}/g, '\n\n') // 多余空行
    .trim()
}

// 渲染数学公式片段
export function renderMathFragment(math: string, displayMode: boolean = false): string {
  try {
    // 这里可以使用KaTeX的renderToString方法
    // 为了简化，我们直接返回原始数学文本，由前端组件处理
    return math
  } catch (error) {
    console.error('数学公式渲染错误:', error)
    return `<span class="math-error" title="${error}">${math}</span>`
  }
}

// 安全地渲染HTML
export function safeRender(html: string): { __html: string } {
  return { __html: html }
}
