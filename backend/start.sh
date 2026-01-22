#!/bin/bash
# macOS特化的FastAPI启动脚本

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印彩色信息
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

# 检查虚拟环境
check_venv() {
    if [[ -z "$VIRTUAL_ENV" ]]; then
        print_error "未检测到虚拟环境，请先激活虚拟环境"
        echo "激活命令: source venv/bin/activate"
        exit 1
    fi
    print_info "虚拟环境: $(which python)"
}

# 添加一个诊断函数
diagnose_environment() {
    echo ""
    print_info "环境诊断:"
    echo "1. 当前目录: $(pwd)"
    echo "2. 虚拟环境: ${VIRTUAL_ENV:-未设置}"
    echo "3. which python: $(which python)"
    echo "4. python路径: $(python -c "import sys; print(sys.executable)" 2>/dev/null || echo "无法获取")"
    echo "5. Python版本: $(python --version 2>&1 || echo "无法获取")"
    echo "6. pip路径: $(which pip)"
    echo ""
    
    # 检查SQLAlchemy的具体情况
    print_info "检查SQLAlchemy安装情况:"
    
    # 方式1: pip检查
    echo "pip检查:"
    pip show sqlalchemy 2>&1 | head -5 || echo "  pip show失败"
    
    # 方式2: 直接检查site-packages
    echo ""
    echo "site-packages检查:"
    local site_packages=$(python -c "import site; print(site.getsitepackages()[0])" 2>/dev/null)
    if [ -n "$site_packages" ]; then
        ls "$site_packages" | grep -i sqlalchemy || echo "  未找到SQLAlchemy"
    fi
    
    # 方式3: 直接导入测试
    echo ""
    echo "直接导入测试:"
    python -c "
try:
    import sqlalchemy
    print('✅ 可以导入')
    print(f'版本: {sqlalchemy.__version__}')
    print(f'路径: {sqlalchemy.__file__}')
except ImportError as e:
    print(f'❌ 导入失败: {e}')
except Exception as e:
    print(f'⚠️ 其他错误: {e}')
"
}

# 检查依赖
check_dependencies() {
    print_info "检查Python依赖..."
    
    # 检查关键包
    for package in fastapi uvicorn sqlalchemy pydantic; do
        if ! python -c "import $package" 2>/dev/null; then
            print_error "缺少依赖: $package"
            echo "安装命令: pip install -r requirements.txt"
            exit 1
        fi
    done
    
    print_success "所有依赖检查通过"
}



check_database() {
    print_info "检查数据库连接...新"
    
    # 检查 Docker 服务状态
    if docker-compose ps postgres 2>/dev/null | grep -q "Up"; then
        print_success "PostgreSQL 容器运行中"
    else
        print_error "PostgreSQL 容器未运行"
        print_info "启动数据库: docker-compose up -d postgres"
        sleep 5  # 等待容器启动
    fi
    
    # 使用你的测试脚本
    if python3 scripts/test_db_connection.py > /dev/null 2>&1; then
        print_success "数据库连接正常"
        return 0
    else
        print_error "数据库连接失败"
        
        # 显示更多错误信息
        print_info "详细错误信息:"
        python3 ./scripts/test_db_connection.py
        
        print_info "启动数据库: docker-compose up -d postgres"
        return 1
    fi
}

# 清理缓存
clean_cache() {
    print_info "清理缓存文件..."
    
    # 清理Python缓存
    find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
    find . -name "*.pyc" -delete 2>/dev/null || true
    find . -name ".pytest_cache" -type d -exec rm -rf {} + 2>/dev/null || true
    
    # 清理日志文件（保留最新的）
    if [[ -d "logs" ]]; then
        find logs -name "*.log" -mtime +7 -delete 2>/dev/null || true
    fi
    
    print_success "缓存清理完成"
}

# 设置环境变量
setup_env() {
    print_info "设置环境变量..."
    
    # 确保.env文件存在
    if [[ ! -f ".env" ]]; then
        print_warning ".env文件不存在，使用默认配置"
        cat > .env << 'ENVFILE'
# macOS开发环境配置
DB_HOST=localhost
DB_PORT=5432
DB_NAME=olympiad
DB_USER=admin
DB_PASSWORD=olympiad123

APP_ENV=development
MACOS_DEV_MODE=true
HOT_RELOAD=true
ENVFILE
    fi
    
    # 加载环境变量
    export $(grep -v '^#' .env | xargs)
    print_success "环境变量设置完成"
}

# 启动应用
start_app() {
    print_info "正在启动FastAPI应用..."
    
    # 参数解析
    MODE="dev"
    PORT=8000
    HOST="0.0.0.0"
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --prod)
                MODE="prod"
                shift
                ;;
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
    
    # 根据模式设置参数
    if [[ "$MODE" == "dev" ]]; then
        print_info "开发模式启动"
        RELOAD="--reload"
        LOG_LEVEL="debug"
    else
        print_info "生产模式启动"
        RELOAD=""
        LOG_LEVEL="info"
    fi
    
    # 显示启动信息
    echo ""
    echo "╔══════════════════════════════════════╗"
    echo "║      Math Olympiad AI Platform      ║"
    echo "║          FastAPI Backend            ║"
    echo "╚══════════════════════════════════════╝"
    echo ""
    echo "📊 模式: $MODE"
    echo "🌐 地址: http://$HOST:$PORT"
    echo "📚 文档: http://$HOST:$PORT/api/docs"
    echo "🔧 热重载: $([[ -n "$RELOAD" ]] && echo "启用" || echo "禁用")"
    echo ""
    
    # 启动命令
    uvicorn app.main:app \
        --host "$HOST" \
        --port "$PORT" \
        $RELOAD \
        --log-level "$LOG_LEVEL" \
        --access-log \
        --use-colors \
        --timeout-keep-alive 30
}

# 主函数
main() {
    echo "🚀 FastAPI macOS启动脚本"
    echo "════════════════════════════════════════"
    
    # 检查是否在backend目录
    if [[ ! -f "app/main.py" ]]; then
        cd "$(dirname "$0")"
        if [[ ! -f "app/main.py" ]]; then
            print_error "请在backend目录下运行此脚本"
            exit 1
        fi
    fi
    
    # 执行检查
    check_venv
    diagnose_environment
    check_dependencies
    setup_env
    check_database
    clean_cache
    
    # 启动应用
    start_app "$@"
}

# 运行主函数
main "$@"
