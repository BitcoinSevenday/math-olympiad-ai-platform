#!/bin/bash
# macOS数据库管理脚本



set -e

case "$1" in
    "start")
        echo "🚀 启动数据库服务..."
        docker-compose up -d postgres pgadmin redis
        echo "✅ 服务已启动"
        echo "   PostgreSQL: localhost:5432"
        echo "   pgAdmin:    http://localhost:5050"
        echo "   Redis:      localhost:6379"
        ;;
        
    "stop")
        echo "🛑 停止数据库服务..."
        docker-compose down
        echo "✅ 服务已停止"
        ;;
        
    "restart")
        echo "🔄 重启数据库服务..."
        docker-compose restart
        echo "✅ 服务已重启"
        ;;
        
    "status")
        echo "📊 服务状态:"
        docker-compose ps
        ;;
        
    "logs")
        echo "📝 查看日志..."
        docker-compose logs -f postgres
        ;;
        
    "reset")
        read -p "⚠️  确定要重置数据库吗？所有数据将被清除！(y/N): " confirm
        if [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]]; then
            echo "🗑️  重置数据库..."
            docker-compose down -v
            docker-compose up -d postgres
            sleep 5
            echo "✅ 数据库已重置"
        else
            echo "❌ 取消重置"
        fi
        ;;
        
    "backup")
        echo "💾 备份数据库..."
        BACKUP_FILE="backup_$(date +%Y%m%d_%H%M%S).sql"
        docker-compose exec -T postgres pg_dump -U admin olympiad > "database/backups/${BACKUP_FILE}"
        echo "✅ 备份完成: database/backups/${BACKUP_FILE}"
        ;;
        
    "restore")
        if [ -z "$2" ]; then
            echo "❌ 请指定备份文件: $0 restore <backup_file>"
            exit 1
        fi
        echo "🔄 恢复数据库..."
        docker-compose exec -T postgres psql -U admin -d olympiad < "$2"
        echo "✅ 恢复完成"
        ;;
        
    "shell")
        echo "🐚 进入PostgreSQL命令行..."
        docker-compose exec postgres psql -U admin -d olympiad
        ;;
        
    *)
        echo "📖 用法: $0 {start|stop|restart|status|logs|reset|backup|restore|shell}"
        echo ""
        echo "命令说明:"
        echo "  start    启动数据库服务"
        echo "  stop     停止数据库服务"
        echo "  restart  重启数据库服务"
        echo "  status   查看服务状态"
        echo "  logs     查看日志"
        echo "  reset    重置数据库（危险！）"
        echo "  backup   备份数据库"
        echo "  restore  恢复数据库"
        echo "  shell    进入PostgreSQL命令行"
        exit 1
        ;;
esac
