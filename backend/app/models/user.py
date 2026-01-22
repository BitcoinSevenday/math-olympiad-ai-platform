"""
用户模型
对应Day 2的users表设计
"""
from sqlalchemy import Column, Integer, String, Boolean, DateTime, JSON, Text, func
from sqlalchemy.sql import expression
from datetime import datetime, timezone
import uuid

from app.core.database import Base

class User(Base):
    """用户表模型"""
    
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    
    # 账户信息
    username = Column(String(50), unique=True, index=True, nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=True)
    hashed_password = Column(String(255), nullable=False)
    full_name = Column(String(100), nullable=True)
    
    # 角色和状态
    role = Column(String(20), default="student", nullable=False)
    grade = Column(String(20), nullable=True)  # 年级
    school = Column(String(100), nullable=True)  # 学校
    
    is_active = Column(Boolean, default=True, server_default=expression.true())
    is_verified = Column(Boolean, default=False, server_default=expression.false())
    
    # 时间戳
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    last_login_at = Column(DateTime(timezone=True), nullable=True)
    
    # 元数据
    user_metadata = Column(JSON, default=dict, server_default="{}")
    
    def __repr__(self):
        return f"<User(id={self.id}, username={self.username}, role={self.role})>"
    
    @property
    def is_admin(self):
        """检查是否是管理员"""
        return self.role == "admin"
    
    @property
    def is_student(self):
        """检查是否是学生"""
        return self.role == "student"
    
    @property
    def is_teacher(self):
        """检查是否是老师"""
        return self.role == "teacher"
    
    def update_last_login(self):
        """更新最后登录时间"""
        self.last_login_at = datetime.now(timezone.utc)
    
    def to_dict(self, include_sensitive=False):
        """转换为字典（用于API响应）"""
        data = {
            "id": self.id,
            "username": self.username,
            "email": self.email,
            "full_name": self.full_name,
            "role": self.role,
            "grade": self.grade,
            "school": self.school,
            "is_active": self.is_active,
            "is_verified": self.is_verified,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "last_login_at": self.last_login_at.isoformat() if self.last_login_at else None,
        }
        
        if include_sensitive:
            data["metadata"] = self.user_metadata
            
        return data