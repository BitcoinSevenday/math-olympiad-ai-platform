#!/bin/bash
# macOS前端开发环境脚本

set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查Node.js版本
check_node_version() {
    local required="18.0.0"
    local current=$(node -v | cut -d'v' -f2)
    
    print_info "检查Node.js版本..."
    
    if [ "$(printf '%s\n' "$required" "$current" | sort -V | head -n1)" != "$required" ]; then
        print_error "Node.js版本过低，需要 >= $required，当前: $current"
        echo "建议使用nvm管理Node.js版本:"
        echo "  nvm install 18"
        echo "  nvm use 18"
        exit 1
    fi
    
    print_success "Node.js版本: $current"
}

# 检查包管理器
check_package_manager() {
    print_info "检查包管理器..."
    
    if command -v pnpm &> /dev/null; then
        print_success "使用pnpm (推荐)"
        PM="pnpm"
    elif command -v yarn &> /dev/null; then
        print_warning "使用yarn"
        PM="yarn"
    elif command -v npm &> /dev/null; then
        print_warning "使用npm"
        PM="npm"
    else
        print_error "未找到包管理器"
        echo "请安装pnpm: npm install -g pnpm"
        exit 1
    fi
}

# 检查端口占用
check_port() {
    local port=${1:-5173}
    
    print_info "检查端口 $port 占用..."
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null ; then
        print_warning "端口 $port 被占用"
        
        # 显示占用进程
        local pid=$(lsof -ti:$port)
        local process=$(ps -p $pid -o comm= 2>/dev/null || echo "unknown")
        
        echo "占用进程: $process (PID: $pid)"
        read -p "是否终止进程？(y/N): " -n 1 -r
        echo
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kill -9 $pid 2>/dev/null
            print_success "已终止进程"
        else
            read -p "使用其他端口 (默认: 5174): " new_port
            new_port=${new_port:-5174}
            PORT=$new_port
        fi
    else
        print_success "端口 $port 可用"
    fi
}

# 安装依赖
install_dependencies() {
    print_info "安装依赖..."
    
    if [ ! -d "node_modules" ]; then
        $PM install
    else
        print_info "node_modules已存在，跳过安装"
    fi
}

# 清理缓存
clean_cache() {
    print_info "清理缓存..."
    
    # 清理构建缓存
    rm -rf dist 2>/dev/null || true
    rm -rf node_modules/.vite 2>/dev/null || true
    rm -rf node_modules/.cache 2>/dev/null || true
    
    # 清理日志
    find . -name "*.log" -delete 2>/dev/null || true
    
    print_success "缓存清理完成"
}

# 启动开发服务器
start_dev_server() {
    local port=${PORT:-5173}
    local host=${HOST:-localhost}
    
    print_info "启动开发服务器..."
    
    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║      Math Olympiad AI Platform      ║"
    echo "║           Vue 3 Frontend            ║"
    echo "╚══════════════════════════════════════╝"
    echo ""
    echo "📦 包管理器: $PM"
    echo "🌐 开发服务器: http://$host:$port"
    echo "🔗 API代理: http://localhost:8000"
    echo "⚡ 热重载: 已启用"
    echo "🐛 调试模式: 已启用"
    echo ""
    echo "📝 日志输出:"
    echo "════════════════════════════════════════"
    
    # 设置环境变量
    export PORT=$port
    export HOST=$host
    
    # 启动Vite开发服务器
    $PM run dev -- --port $port --host $host
}

# 主函数
main() {
    echo "🚀 Vue 3 macOS前端开发脚本"
    echo "════════════════════════════════════════"
    
    # 检查是否在前端目录
    if [[ ! -f "vite.config.ts" ]]; then
        print_error "请在前端项目目录(frontend)中运行此脚本"
        exit 1
    fi
    
    # 执行检查
    check_node_version
    check_package_manager
    check_port "${1:-5173}"
    install_dependencies
    clean_cache
    
    # 启动开发服务器
    start_dev_server
}

# 处理参数
PORT=""
HOST=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --port)
            PORT="$2"
            shift 2
            ;;
        --host)
            HOST="$2"
            shift 2
            ;;
        *)
            print_warning "未知参数: $1"
            shift
            ;;
    esac
done

# 运行主函数
main "$PORT"
