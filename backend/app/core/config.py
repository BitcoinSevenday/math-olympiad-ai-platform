from typing import Optional, List
from pydantic_settings import BaseSettings
from pydantic import PostgresDsn, validator, field_validator
import secrets
from pathlib import Path

class Settings(BaseSettings):
    """应用配置"""
    
    # 基础配置
    PROJECT_NAME: str = "Math Olympiad AI Platform"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    
    # 安全配置
    SECRET_KEY: str = secrets.token_urlsafe(32)
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7天
    
    # CORS配置
    BACKEND_CORS_ORIGINS: List[str] = [
        "http://localhost:5173",  # Vue前端
        "http://127.0.0.1:5173",
        "http://localhost:8000",
    ]
    
    # 数据库配置
    POSTGRES_SERVER: str = "localhost"
    POSTGRES_USER: str = "admin"
    POSTGRES_PASSWORD: str = "olympiad123"
    POSTGRES_DB: str = "olympiad"
    POSTGRES_PORT: str = "5432"
    
    # 构建数据库URL
    SQLALCHEMY_DATABASE_URL: Optional[PostgresDsn] = None
    
    @field_validator("SQLALCHEMY_DATABASE_URL", mode="before")
    @classmethod
    def assemble_db_connection(cls, v: Optional[str], info):
        """构建数据库连接字符串"""
        if isinstance(v, str):
            return v
        
        values = info.data
        return PostgresDsn.build(
            scheme="postgresql+psycopg2",
            username=values.get("POSTGRES_USER"),
            password=values.get("POSTGRES_PASSWORD"),
            host=values.get("POSTGRES_SERVER"),
            port=int(values.get("POSTGRES_PORT")),
            path=f"{values.get('POSTGRES_DB') or ''}",
        )
    
    # Redis配置
    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6379
    REDIS_PASSWORD: str = "redis123"
    REDIS_DB: int = 0
    
    # macOS特化配置
    MACOS_DEV_MODE: bool = True
    HOT_RELOAD: bool = True
    DEBUG_PORT: int = 5678  # VS Code调试端口
    
    # 文件上传配置
    UPLOAD_DIR: Path = Path("uploads")
    MAX_UPLOAD_SIZE: int = 10 * 1024 * 1024  # 10MB
    
    # 日志配置
    LOG_LEVEL: str = "DEBUG"
    LOG_FILE: Path = Path("logs/backend.log")
    
    # 应用行为
    FIRST_SUPERUSER: str = "admin"
    FIRST_SUPERUSER_PASSWORD: str = "admin123"
    USERS_OPEN_REGISTRATION: bool = True
    
    class Config:
        case_sensitive = True
        env_file = ".env"
        env_file_encoding = "utf-8"

# 全局配置实例
settings = Settings()

# macOS特化的开发配置检查
if settings.MACOS_DEV_MODE:
    print(f"🚀 {settings.PROJECT_NAME} v{settings.VERSION}")
    print(f"💻 macOS开发模式已启用")
    print(f"🔗 数据库: {settings.POSTGRES_SERVER}:{settings.POSTGRES_PORT}/{settings.POSTGRES_DB}")
    print(f"⚡ 热重载: {'已启用' if settings.HOT_RELOAD else '已禁用'}")
