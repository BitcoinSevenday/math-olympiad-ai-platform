"""
用户认证API路由
注册、登录、令牌刷新等
"""
from datetime import timedelta
from typing import Any
from fastapi import APIRouter, Depends, HTTPException, status, Body, Request
from fastapi.security import OAuth2PasswordRequestForm
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.database import get_db
from app.core.security import create_access_token, verify_token
from app.crud.user import (
    create_user, authenticate_user, get_user_by_username,
    change_password as crud_change_password
)
from app.schemas.user import (
    UserCreate, UserResponse, Token, UserLogin,
    ChangePassword
)
from app.api.dependencies import get_current_user, optional_current_user
from app.models.user import User

router = APIRouter()

@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(
    user_in: UserCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(optional_current_user)
):
    """
    注册新用户
    
    - **username**: 用户名（3-50字符，只能包含字母数字和下划线）
    - **password**: 密码（至少6位）
    - **email**: 邮箱（可选）
    - **full_name**: 姓名（可选）
    - **role**: 角色（student, teacher, admin, parent），默认student
    """
    # 检查是否允许开放注册，或者当前用户是管理员
    if not settings.USERS_OPEN_REGISTRATION:
        if not current_user or not current_user.is_admin:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="注册功能已关闭"
            )
    
    try:
        user = create_user(db, user_in)
        return user
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.post("/login", response_model=Token)
async def login(
    request: Request,
    login_json_data: UserLogin,
    db: Session = Depends(get_db)
):
    """
    用户登录
    
    使用OAuth2标准格式：
    - **username**: 用户名
    - **password**: 密码
    """


    print(f"收到登录数据: username={login_json_data.username}, password={login_json_data.password}")

    user = authenticate_user(db, login_json_data.username, login_json_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="用户名或密码错误",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="用户已被禁用"
        )
    
    # 创建访问令牌
    access_token = create_access_token(
        data={
            "sub": user.username,
            "user_id": user.id,
            "role": user.role
        }
    )
    
    # 更新最后登录时间
    user.update_last_login()
    db.commit()
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "expires_in": settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60
    }

@router.post("/login/json", response_model=Token)
async def login_json(
    user_in: UserLogin,
    db: Session = Depends(get_db)
):
    """
    用户登录（JSON格式）
    
    - **username**: 用户名
    - **password**: 密码
    """
    user = authenticate_user(db, user_in.username, user_in.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="用户名或密码错误",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="用户已被禁用"
        )
    
    # 创建访问令牌
    access_token = create_access_token(
        data={
            "sub": user.username,
            "user_id": user.id,
            "role": user.role
        }
    )
    
    # 更新最后登录时间
    user.update_last_login()
    db.commit()
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "expires_in": settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60
    }

@router.post("/refresh", response_model=Token)
async def refresh_token(
    refresh_token: str = Body(..., embed=True),
    db: Session = Depends(get_db)
):
    """
    刷新访问令牌
    
    - **refresh_token**: 刷新令牌（当前使用访问令牌）
    """
    # 验证令牌
    token_data = verify_token(refresh_token)
    if not token_data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="无效的令牌"
        )
    
    # 获取用户
    user = get_user_by_username(db, token_data.username)
    if not user or not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="用户不存在或已被禁用"
        )
    
    # 创建新的访问令牌
    access_token = create_access_token(
        data={
            "sub": user.username,
            "user_id": user.id,
            "role": user.role
        }
    )
    
    return {
        "access_token": access_token,
        "token_type": "bearer",
        "expires_in": settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60
    }

@router.post("/change-password")
async def change_password(
    password_data: ChangePassword,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    修改密码
    
    - **current_password**: 当前密码
    - **new_password**: 新密码
    """
    success = crud_change_password(
        db,
        current_user,
        password_data.current_password,
        password_data.new_password
    )
    
    if not success:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="当前密码错误"
        )
    
    return {"message": "密码修改成功"}

@router.get("/me", response_model=UserResponse)
async def get_current_user_info(
    current_user: User = Depends(get_current_user)
):
    """
    获取当前用户信息
    """
    return current_user

@router.post("/logout")
async def logout():
    """
    用户登出（客户端需删除令牌）
    """
    # JWT是无状态的，客户端删除令牌即可
    return {"message": "登出成功"}

@router.get("/check-username/{username}")
async def check_username_available(
    username: str,
    db: Session = Depends(get_db)
):
    """
    检查用户名是否可用
    
    - **username**: 要检查的用户名
    """
    user = get_user_by_username(db, username)
    return {"available": user is None}

@router.get("/check-email/{email}")
async def check_email_available(
    email: str,
    db: Session = Depends(get_db)
):
    """
    检查邮箱是否可用
    
    - **email**: 要检查的邮箱
    """
    user = get_user_by_email(db, email)
    return {"available": user is None}

@router.get("/health")
async def health_check():
    """
    健康检查端点
    """
    import platform
    import psutil
    
    # 获取系统信息
    system_info = {
        "system": platform.system(),
        "machine": platform.machine(),
        "processor": platform.processor(),
        "python_version": platform.python_version(),
        "memory_usage": psutil.virtual_memory().percent,
        "cpu_usage": psutil.cpu_percent(interval=1),
    }
    
    return {
        "status": "healthy",
        "service": "auth",
        "timestamp": datetime.now().isoformat(),
        "system": system_info,
    }