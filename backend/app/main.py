"""
macOS特化的FastAPI主应用
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager
import time

from app.core.config import settings
from app.core.logging_config import logger
from app.core.database import init_db
from app.api.routes import auth, problems

# 应用生命周期管理
@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    应用生命周期管理
    启动时和关闭时的操作
    """
    # 启动时
    startup_time = time.time()
    logger.info(f"🚀 正在启动 {settings.PROJECT_NAME} v{settings.VERSION}")
    
    # 初始化数据库
    try:
        init_db()
        logger.info("✅ 数据库初始化完成")
    except Exception as e:
        logger.error(f"❌ 数据库初始化失败: {e}")
        raise
    
    # macOS特化：开发环境信息
    if settings.MACOS_DEV_MODE:
        import platform
        import psutil
        
        logger.info(f"💻 系统: {platform.system()} {platform.machine()}")
        logger.info(f"🐍 Python: {platform.python_version()}")
        logger.info(f"🧠 内存使用: {psutil.virtual_memory().percent}%")
        logger.info(f"⚡ CPU使用: {psutil.cpu_percent()}%")
    
    yield
    
    # 关闭时
    shutdown_time = time.time()
    uptime = shutdown_time - startup_time
    logger.info(f"🛑 应用关闭，运行时间: {uptime:.2f}秒")

# 创建FastAPI应用
app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="奥赛AI平台 - 智能数学奥赛学习系统",
    lifespan=lifespan,
    docs_url="/api/docs" if settings.MACOS_DEV_MODE else None,
    redoc_url="/api/redoc" if settings.MACOS_DEV_MODE else None,
    openapi_url="/api/openapi.json" if settings.MACOS_DEV_MODE else None,
)

# 配置CORS（跨域资源共享）
if settings.BACKEND_CORS_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
        expose_headers=["*"],
    )

# 挂载静态文件（用于上传的文件）
app.mount("/uploads", StaticFiles(directory="uploads"), name="uploads")

# 健康检查端点
@app.get("/")
async def root():
    """根端点"""
    return {
        "message": f"欢迎使用{settings.PROJECT_NAME} API",
        "version": settings.VERSION,
        "docs": "/api/docs" if settings.MACOS_DEV_MODE else "disabled",
        "status": "running"
    }

@app.get("/health")
async def health_check():
    """健康检查"""
    import psutil
    import platform
    
    return {
        "status": "healthy",
        "service": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "timestamp": time.time(),
        "system": {
            "platform": platform.system(),
            "machine": platform.machine(),
            "python": platform.python_version(),
            "memory_usage": psutil.virtual_memory().percent,
        }
    }

# 注册API路由
app.include_router(
    auth.router,
    prefix="/api/v1/auth",
    tags=["认证"]
)

app.include_router(
    problems.router,
    prefix="/api/v1/problems",
    tags=["题目管理"]
)

# 全局异常处理器
@app.exception_handler(404)
async def not_found_exception_handler(request, exc):
    """404异常处理"""
    return JSONResponse(
        status_code=404,
        content={"message": "请求的资源不存在"},
    )

@app.exception_handler(500)
async def internal_exception_handler(request, exc):
    """500异常处理"""
    logger.error(f"服务器内部错误: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"message": "服务器内部错误"},
    )

# macOS开发模式特化中间件
if settings.MACOS_DEV_MODE:
    from fastapi import Request
    from fastapi.responses import JSONResponse
    
    @app.middleware("http")
    async def log_requests(request: Request, call_next):
        """记录请求日志（开发环境）"""
        start_time = time.time()
        
        # 记录请求
        logger.info(f"🌐 {request.method} {request.url.path} - 开始")
        
        try:
            response = await call_next(request)
        except Exception as e:
            logger.error(f"❌ 请求处理失败: {e}", exc_info=True)
            raise
        
        # 计算处理时间
        process_time = time.time() - start_time
        response.headers["X-Process-Time"] = str(process_time)
        
        # 记录响应
        logger.info(
            f"✅ {request.method} {request.url.path} - "
            f"状态: {response.status_code} - "
            f"耗时: {process_time:.3f}秒"
        )
        
        return response

# 启动信息
logger.info(f"🎉 {settings.PROJECT_NAME} 应用创建完成")
logger.info(f"📚 API文档: http://localhost:8000/api/docs")
logger.info(f"🔗 健康检查: http://localhost:8000/health")