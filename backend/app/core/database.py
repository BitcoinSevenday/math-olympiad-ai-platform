"""
macOS特化的数据库连接管理
使用SQLAlchemy 2.0+异步API
"""
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, Session
from sqlalchemy.pool import QueuePool
from contextlib import contextmanager
import threading
import time
from typing import Generator

from app.core.config import settings
from app.core.logging_config import logger

# 创建数据库引擎（macOS特化：使用连接池提高性能）
engine = create_engine(
    str(settings.SQLALCHEMY_DATABASE_URL),
    poolclass=QueuePool,  # 连接池
    pool_size=20,         # 连接池大小
    max_overflow=30,      # 最大溢出连接
    pool_pre_ping=True,   # 连接前ping，防止连接失效
    pool_recycle=3600,    # 1小时后回收连接
    echo=False,           # 开发时可设为True查看SQL
    echo_pool=False,      # 连接池日志
)

# 创建会话工厂
SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine,
    class_=Session,
    expire_on_commit=False,  # macOS开发优化
)

# 声明基类
Base = declarative_base()

def get_db() -> Generator[Session, None, None]:
    """
    获取数据库会话（依赖注入）
    macOS特化：添加连接监控
    """
    db = SessionLocal()
    start_time = time.time()
    
    try:
        yield db
        db.commit()
    except Exception as e:
        db.rollback()
        logger.error(f"数据库操作失败: {e}", exc_info=True)
        raise
    finally:
        db.close()
        # macOS开发监控：记录慢查询
        elapsed = time.time() - start_time
        if elapsed > 1.0:  # 超过1秒的查询
            logger.warning(f"⏰ 慢数据库会话: {elapsed:.2f}秒")

@contextmanager
def db_context():
    """
    上下文管理器方式使用数据库
    macOS开发友好：自动资源管理
    """
    db = SessionLocal()
    try:
        yield db
        db.commit()
    except Exception as e:
        db.rollback()
        raise
    finally:
        db.close()

def init_db() -> None:
    """
    初始化数据库（创建所有表）
    macOS特化：检查Apple Silicon兼容性
    """
    import platform
    
    logger.info("🔄 开始初始化数据库...")
    logger.info(f"💻 系统架构: {platform.machine()}")
    
    try:
        # 导入所有模型，确保SQLAlchemy知道它们
        from app.models import user, problem, knowledge_point  # noqa
        
        # 创建所有表
        Base.metadata.create_all(bind=engine)
        
        logger.info("✅ 数据库表创建成功！")
        
        # 验证数据库连接
        with engine.connect() as conn:
            result = conn.execute("SELECT version();")
            db_version = result.fetchone()[0]
            logger.info(f"📊 数据库版本: {db_version}")
            
            # 检查表数量
            result = conn.execute("""
                SELECT COUNT(*) 
                FROM information_schema.tables 
                WHERE table_schema = 'public'
            """)
            table_count = result.fetchone()[0]
            logger.info(f"📈 数据表数量: {table_count}")
            
    except Exception as e:
        logger.error(f"❌ 数据库初始化失败: {e}", exc_info=True)
        raise

# macOS开发助手：连接池监控
class ConnectionPoolMonitor(threading.Thread):
    """监控数据库连接池状态"""
    
    def __init__(self, engine, interval=60):
        super().__init__(daemon=True)
        self.engine = engine
        self.interval = interval
        self.running = True
        
    def run(self):
        logger.info("🔍 数据库连接池监控已启动")
        while self.running:
            try:
                pool = self.engine.pool
                logger.debug(
                    f"连接池状态: 使用中={pool.checkedin()}, "
                    f"空闲={pool.checkedout()}, "
                    f"总大小={pool.size()}"
                )
            except Exception as e:
                logger.warning(f"连接池监控错误: {e}")
            
            time.sleep(self.interval)
    
    def stop(self):
        self.running = False

# macOS开发环境：启动连接池监控
if settings.MACOS_DEV_MODE:
    pool_monitor = ConnectionPoolMonitor(engine)
    pool_monitor.start()
    logger.info("👁️  数据库连接池监控已启用")
