"""
macOS特化的FastAPI依赖项
用户认证和权限检查
"""
from typing import Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import verify_token
from app.models.user import User
from app.schemas.user import TokenData

# HTTP Bearer认证
security = HTTPBearer(auto_error=False)

async def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
    db: Session = Depends(get_db)
) -> User:
    """获取当前用户"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="无效的认证凭证",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    if credentials is None:
        raise credentials_exception
    
    # 验证令牌
    token_data = verify_token(credentials.credentials)
    if token_data is None:
        raise credentials_exception
    
    # 查询用户
    user = db.query(User).filter(User.username == token_data.username).first()
    if user is None:
        raise credentials_exception
    
    # 检查用户状态
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="用户已被禁用"
        )
    
    return user

async def get_current_active_user(
    current_user: User = Depends(get_current_user)
) -> User:
    """获取当前活跃用户"""
    if not current_user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="用户已被禁用"
        )
    return current_user

async def get_current_admin_user(
    current_user: User = Depends(get_current_user)
) -> User:
    """获取当前管理员用户"""
    if not current_user.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="需要管理员权限"
        )
    return current_user

async def get_current_teacher_or_admin(
    current_user: User = Depends(get_current_user)
) -> User:
    """获取当前老师或管理员"""
    if not (current_user.is_teacher or current_user.is_admin):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="需要老师或管理员权限"
        )
    return current_user

async def optional_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security),
    db: Session = Depends(get_db)
) -> Optional[User]:
    """可选的当前用户（未登录返回None）"""
    if credentials is None:
        return None
    
    try:
        token_data = verify_token(credentials.credentials)
        if token_data is None:
            return None
        
        user = db.query(User).filter(User.username == token_data.username).first()
        if user and user.is_active:
            return user
        return None
        
    except Exception:
        return None