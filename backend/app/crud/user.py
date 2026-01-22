"""
用户CRUD操作
"""
from typing import Optional, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import func

from app.models.user import User
from app.schemas.user import UserCreate, UserUpdate
from app.core.security import get_password_hash, verify_password

def get_user(db: Session, user_id: int) -> Optional[User]:
    """根据ID获取用户"""
    return db.query(User).filter(User.id == user_id).first()

def get_user_by_username(db: Session, username: str) -> Optional[User]:
    """根据用户名获取用户"""
    return db.query(User).filter(User.username == username).first()

def get_user_by_email(db: Session, email: str) -> Optional[User]:
    """根据邮箱获取用户"""
    return db.query(User).filter(User.email == email).first()

def get_users(
    db: Session,
    skip: int = 0,
    limit: int = 100,
    role: Optional[str] = None,
    is_active: Optional[bool] = None
) -> list[User]:
    """获取用户列表（带过滤）"""
    query = db.query(User)
    
    if role:
        query = query.filter(User.role == role)
    
    if is_active is not None:
        query = query.filter(User.is_active == is_active)
    
    return query.order_by(User.created_at.desc()).offset(skip).limit(limit).all()

def create_user(db: Session, user_create: UserCreate) -> User:
    """创建新用户"""
    # 检查用户名是否已存在
    existing_user = get_user_by_username(db, user_create.username)
    if existing_user:
        raise ValueError("用户名已存在")
    
    # 检查邮箱是否已存在（如果提供了邮箱）
    if user_create.email:
        existing_email = get_user_by_email(db, user_create.email)
        if existing_email:
            raise ValueError("邮箱已存在")
    
    # 创建用户对象
    db_user = User(
        username=user_create.username,
        email=user_create.email,
        hashed_password=get_password_hash(user_create.password),
        full_name=user_create.full_name,
        role=user_create.role,
        grade=user_create.grade,
        school=user_create.school,
        is_verified=False,  # 默认未验证
        is_active=True,     # 默认激活
    )
    
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    return db_user

def update_user(
    db: Session,
    db_user: User,
    user_update: UserUpdate
) -> User:
    """更新用户信息"""
    update_data = user_update.model_dump(exclude_unset=True)
    
    # 如果需要更新邮箱，检查是否重复
    if 'email' in update_data and update_data['email']:
        existing_user = get_user_by_email(db, update_data['email'])
        if existing_user and existing_user.id != db_user.id:
            raise ValueError("邮箱已被使用")
    
    # 更新字段
    for field, value in update_data.items():
        setattr(db_user, field, value)
    
    db.commit()
    db.refresh(db_user)
    
    return db_user

def delete_user(db: Session, user_id: int) -> bool:
    """删除用户（软删除）"""
    user = get_user(db, user_id)
    if not user:
        return False
    
    user.is_active = False
    db.commit()
    
    return True

def authenticate_user(
    db: Session,
    username: str,
    password: str
) -> Optional[User]:
    """用户认证"""
    user = get_user_by_username(db, username)
    if not user:
        return None
    
    if not verify_password(password, user.hashed_password):
        return None
    
    return user

def change_password(
    db: Session,
    user: User,
    current_password: str,
    new_password: str
) -> bool:
    """修改密码"""
    # 验证当前密码
    if not verify_password(current_password, user.hashed_password):
        return False
    
    # 更新密码
    user.hashed_password = get_password_hash(new_password)
    db.commit()
    
    return True

def get_user_stats(db: Session, user_id: int) -> Dict[str, Any]:
    """获取用户统计信息"""
    from app.models.practice import PracticeSession
    from app.models.answer import AnswerRecord
    
    # 练习会话统计
    session_stats = db.query(
        func.count(PracticeSession.id).label("total_sessions"),
        func.sum(PracticeSession.total_duration).label("total_duration"),
        func.avg(PracticeSession.total_duration).label("avg_duration"),
    ).filter(
        PracticeSession.user_id == user_id,
        PracticeSession.status == "completed"
    ).first()
    
    # 答题统计
    answer_stats = db.query(
        func.count(AnswerRecord.id).label("total_answers"),
        func.sum(func.cast(AnswerRecord.is_correct, Integer)).label("correct_answers"),
    ).filter(AnswerRecord.user_id == user_id).first()
    
    total_answers = answer_stats.total_answers or 0
    correct_answers = answer_stats.correct_answers or 0
    
    return {
        "total_practice_sessions": session_stats.total_sessions or 0,
        "total_questions_attempted": total_answers,
        "overall_accuracy": round(correct_answers / total_answers * 100, 2) if total_answers > 0 else 0,
        "total_practice_time": session_stats.total_duration or 0,
        "average_session_duration": round(session_stats.avg_duration or 0, 2),
    }

def search_users(
    db: Session,
    keyword: str,
    skip: int = 0,
    limit: int = 50
) -> list[User]:
    """搜索用户（根据用户名、姓名、学校）"""
    query = db.query(User).filter(
        User.is_active == True
    ).filter(
        (User.username.ilike(f"%{keyword}%")) |
        (User.full_name.ilike(f"%{keyword}%")) |
        (User.school.ilike(f"%{keyword}%"))
    )
    
    return query.order_by(User.username).offset(skip).limit(limit).all()

def count_users(db: Session) -> Dict[str, int]:
    """统计用户数量（按角色）"""
    result = db.query(
        User.role,
        func.count(User.id).label("count")
    ).filter(
        User.is_active == True
    ).group_by(
        User.role
    ).all()
    
    stats = {row.role: row.count for row in result}
    
    # 确保所有角色都有值
    for role in ["student", "teacher", "admin", "parent"]:
        if role not in stats:
            stats[role] = 0
    
    stats["total"] = sum(stats.values())
    
    return stats