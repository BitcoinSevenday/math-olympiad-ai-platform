"""
macOS特化的日志配置
彩色输出，文件日志，结构化日志
"""
import logging
import sys
from pathlib import Path
from logging.handlers import RotatingFileHandler
from typing import Optional
from app.core.config import settings

class ColorFormatter(logging.Formatter):
    """macOS终端彩色日志格式化器"""
    
    COLORS = {
        'DEBUG': '\033[94m',    # 蓝色
        'INFO': '\033[92m',     # 绿色
        'WARNING': '\033[93m',  # 黄色
        'ERROR': '\033[91m',    # 红色
        'CRITICAL': '\033[95m', # 紫色
        'RESET': '\033[0m',     # 重置
    }
    
    def format(self, record):
        # 添加颜色
        color = self.COLORS.get(record.levelname, self.COLORS['RESET'])
        record.levelname = f"{color}{record.levelname}{self.COLORS['RESET']}"
        record.name = f"\033[90m{record.name}{self.COLORS['RESET']}"
        return super().format(record)

def setup_logging(log_file: Optional[Path] = None):
    """配置日志系统"""
    
    # 确保日志目录存在
    if log_file:
        log_file.parent.mkdir(parents=True, exist_ok=True)
    
    # 获取根日志器
    logger = logging.getLogger()
    logger.setLevel(getattr(logging, settings.LOG_LEVEL))
    
    # 清除现有处理器
    logger.handlers.clear()
    
    # 控制台处理器（彩色输出）
    console_handler = logging.StreamHandler(sys.stdout)
    console_format = ColorFormatter(
        '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    console_handler.setFormatter(console_format)
    logger.addHandler(console_handler)
    
    # 文件处理器（JSON格式，便于分析）
    if log_file:
        file_handler = RotatingFileHandler(
            log_file,
            maxBytes=10 * 1024 * 1024,  # 10MB
            backupCount=5,
            encoding='utf-8'
        )
        file_format = logging.Formatter(
            '{"time": "%(asctime)s", "name": "%(name)s", '
            '"level": "%(levelname)s", "message": "%(message)s", '
            '"module": "%(module)s", "func": "%(funcName)s", "line": %(lineno)d}',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        file_handler.setFormatter(file_format)
        logger.addHandler(file_handler)
    
    # SQLAlchemy日志（开发时查看SQL）
    sqlalchemy_logger = logging.getLogger('sqlalchemy.engine')
    sqlalchemy_logger.setLevel(logging.WARNING)  # 开发时可设为INFO查看SQL
    
    # Uvicorn访问日志
    uvicorn_access = logging.getLogger("uvicorn.access")
    uvicorn_access.setLevel(logging.INFO)
    
    # Uvicorn错误日志
    uvicorn_error = logging.getLogger("uvicorn.error")
    uvicorn_error.setLevel(logging.INFO)
    
    logger.info(f"✅ 日志系统初始化完成，级别: {settings.LOG_LEVEL}")
    if log_file:
        logger.info(f"📝 日志文件: {log_file.absolute()}")
    
    return logger

# 全局日志器
logger = setup_logging(settings.LOG_FILE)
