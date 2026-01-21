"""
用户相关的Pydantic模式
用于API请求/响应验证
"""
from typing import Optional, List
from pydantic import BaseModel, EmailStr, validator, constr
from datetime import datetime

# 基础模式
class UserBase(BaseModel):
    """用户基础模式"""
    username: constr(min_length=3, max_length=50, pattern=r'^[a-zA-Z0-9_]+$')
    email: Optional[EmailStr] = None
    full_name: Optional[str] = None
    role: Optional[str] = "student"
    grade: Optional[str] = None
    school: Optional[str] = None

# 创建用户
class UserCreate(UserBase):
    """创建用户模式"""
    password: constr(min_length=6, max_length=100)
    
    @validator('role')
    def validate_role(cls, v):
        allowed_roles = ['student', 'teacher', 'admin', 'parent']
        if v not in allowed_roles:
            raise ValueError(f'角色必须是: {", ".join(allowed_roles)}')
        return v

# 更新用户
class UserUpdate(BaseModel):
    """更新用户模式"""
    email: Optional[EmailStr] = None
    full_name: Optional[str] = None
    grade: Optional[str] = None
    school: Optional[str] = None
    is_active: Optional[bool] = None
    metadata: Optional[dict] = None

# 用户响应
class UserResponse(UserBase):
    """用户响应模式"""
    id: int
    is_active: bool
    is_verified: bool
    created_at: datetime
    last_login_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True

# 登录
class UserLogin(BaseModel):
    """用户登录模式"""
    username: str
    password: str

# Token响应
class Token(BaseModel):
    """Token响应模式"""
    access_token: str
    token_type: str = "bearer"
    expires_in: int

# Token数据
class TokenData(BaseModel):
    """Token数据模式"""
    username: Optional[str] = None
    user_id: Optional[int] = None
    role: Optional[str] = None

# 修改密码
class ChangePassword(BaseModel):
    """修改密码模式"""
    current_password: str
    new_password: constr(min_length=6, max_length=100)

# 用户统计
class UserStats(BaseModel):
    """用户统计模式"""
    total_practice_sessions: int
    total_questions_attempted: int
    overall_accuracy: float
    total_practice_time: int  # 秒
    average_session_duration: float

# 用户详情（包含统计）
class UserDetail(UserResponse):
    """用户详情模式"""
    stats: Optional[UserStats] = None