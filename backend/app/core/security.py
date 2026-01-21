"""
macOS特化的安全工具
密码加密和JWT令牌处理
"""
from datetime import datetime, timedelta, timezone
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import HTTPException, status

from app.core.config import settings
from app.schemas.user import TokenData

# 密码加密上下文
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

# macOS特化：检查安全设置
def check_macos_security():
    """检查macOS安全设置（开发环境提醒）"""
    import subprocess
    import platform
    
    if platform.system() == "Darwin":
        try:
            # 检查Gatekeeper设置
            result = subprocess.run(
                ["spctl", "--status"],
                capture_output=True,
                text=True
            )
            if "assessments enabled" in result.stdout:
                print("🔒 macOS Gatekeeper已启用 - 安全设置正常")
            else:
                print("⚠️  macOS Gatekeeper未启用 - 建议启用安全设置")
        except Exception:
            pass

check_macos_security()

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """验证密码"""
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """生成密码哈希"""
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None) -> str:
    """创建JWT访问令牌"""
    to_encode = data.copy()
    
    # 设置过期时间
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(
            minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
        )
    
    to_encode.update({"exp": expire})
    
    # 生成令牌
    encoded_jwt = jwt.encode(
        to_encode, 
        settings.SECRET_KEY, 
        algorithm=settings.ALGORITHM
    )
    
    return encoded_jwt

def verify_token(token: str) -> Optional[TokenData]:
    """验证JWT令牌"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="无效的认证凭证",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        # 解码令牌
        payload = jwt.decode(
            token, 
            settings.SECRET_KEY, 
            algorithms=[settings.ALGORITHM]
        )
        
        # 获取用户信息
        username: str = payload.get("sub")
        user_id: int = payload.get("user_id")
        role: str = payload.get("role")
        
        if username is None:
            raise credentials_exception
        
        return TokenData(username=username, user_id=user_id, role=role)
        
    except JWTError:
        raise credentials_exception

def generate_password_reset_token(email: str) -> str:
    """生成密码重置令牌"""
    expires_delta = timedelta(hours=24)  # 24小时有效
    return create_access_token(
        data={"sub": email, "type": "reset_password"},
        expires_delta=expires_delta
    )

def verify_password_reset_token(token: str) -> Optional[str]:
    """验证密码重置令牌"""
    try:
        payload = jwt.decode(
            token,
            settings.SECRET_KEY,
            algorithms=[settings.ALGORITHM]
        )
        
        email: str = payload.get("sub")
        token_type: str = payload.get("type")
        
        if email is None or token_type != "reset_password":
            return None
        
        return email
        
    except JWTError:
        return None

# macOS特化：密钥安全检查
def check_security_keys():
    """检查安全密钥设置"""
    if settings.SECRET_KEY == "changeme_in_production":
        print("⚠️  WARNING: 请在生产环境中修改SECRET_KEY！")
    
    # 检查密钥长度
    if len(settings.SECRET_KEY) < 32:
        print("⚠️  WARNING: SECRET_KEY长度不足，建议至少32字符")

# 启动时检查
check_security_keys()