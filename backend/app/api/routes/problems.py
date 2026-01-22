"""
题目管理API路由
"""
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.api.dependencies import get_current_user, get_current_admin_user, get_current_teacher_or_admin
from app.crud.problem import (
    get_problem, get_problems, create_problem, update_problem,
    delete_problem, publish_problem, get_problem_stats,
    get_random_problems, search_problems
)
from app.schemas.problem import (
    ProblemCreate, ProblemUpdate, ProblemResponse,
    ProblemDetail, ProblemFilter, ProblemStats, PracticeProblem
)
from app.models.user import User

router = APIRouter()

@router.get("/", response_model=List[ProblemResponse])
async def read_problems(
    skip: int = 0,
    limit: int = 100,
    difficulty: Optional[List[int]] = Query(None),
    source_type: Optional[str] = None,
    knowledge_point_id: Optional[int] = None,
    search: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    获取题目列表
    
    权限：需要登录
    - **skip**: 跳过多少条记录（分页）
    - **limit**: 返回多少条记录（分页）
    - **difficulty**: 难度过滤（可以多个）
    - **source_type**: 来源类型过滤
    - **knowledge_point_id**: 知识点ID过滤
    - **search**: 搜索关键词
    """
    # 构建过滤条件
    filter_params = ProblemFilter(
        difficulty=difficulty,
        source_type=source_type,
        knowledge_point_id=knowledge_point_id,
        search=search,
        is_published=True  # 普通用户只能看到已发布的题目
    )
    
    if current_user.is_admin or current_user.is_teacher:
        # 管理员和老师可以看到所有题目（包括未发布的）
        filter_params.is_published = None
    
    problems = get_problems(db, skip=skip, limit=limit, filter_params=filter_params)
    return problems

@router.get("/{problem_id}", response_model=ProblemDetail)
async def read_problem(
    problem_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    获取题目详情
    
    权限：需要登录
    - **problem_id**: 题目ID
    """
    problem = get_problem(db, problem_id)
    if not problem:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="题目不存在"
        )
    
    # 检查权限
    if not problem.is_published and not (current_user.is_admin or current_user.is_teacher):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="没有权限查看此题目"
        )
    
    return problem

@router.post("/", response_model=ProblemResponse, status_code=status.HTTP_201_CREATED)
async def create_new_problem(
    problem_in: ProblemCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_teacher_or_admin)
):
    """
    创建新题目
    
    权限：需要老师或管理员权限
    """
    try:
        problem = create_problem(db, problem_in, created_by=current_user.id)
        return problem
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.put("/{problem_id}", response_model=ProblemResponse)
async def update_existing_problem(
    problem_id: int,
    problem_in: ProblemUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_teacher_or_admin)
):
    """
    更新题目
    
    权限：需要老师或管理员权限
    - **problem_id**: 题目ID
    """
    problem = get_problem(db, problem_id)
    if not problem:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="题目不存在"
        )
    
    # 检查权限（只有创建者或管理员可以修改）
    if problem.created_by != current_user.id and not current_user.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="没有权限修改此题目"
        )
    
    try:
        updated_problem = update_problem(db, problem, problem_in)
        return updated_problem
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )

@router.delete("/{problem_id}")
async def delete_existing_problem(
    problem_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_admin_user)
):
    """
    删除题目
    
    权限：需要管理员权限
    - **problem_id**: 题目ID
    """
    success = delete_problem(db, problem_id)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="题目不存在"
        )
    
    return {"message": "题目删除成功"}

@router.post("/{problem_id}/publish")
async def publish_existing_problem(
    problem_id: int,
    publish: bool = True,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_teacher_or_admin)
):
    """
    发布或取消发布题目
    
    权限：需要老师或管理员权限
    - **problem_id**: 题目ID
    - **publish**: 是否发布（True=发布，False=取消发布）
    """
    success = publish_problem(db, problem_id, publish)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="题目不存在"
        )
    
    action = "发布" if publish else "取消发布"
    return {"message": f"题目{action}成功"}

@router.get("/stats/summary", response_model=ProblemStats)
async def get_problems_stats(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    获取题目统计信息
    
    权限：需要登录
    """
    stats = get_problem_stats(db)
    return stats

@router.get("/practice/random", response_model=List[PracticeProblem])
async def get_random_problems_for_practice(
    count: int = Query(default=10, ge=1, le=50),
    difficulty: Optional[List[int]] = Query(None),
    knowledge_point_ids: Optional[List[int]] = Query(None),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    获取随机题目用于练习
    
    权限：需要登录
    - **count**: 题目数量（1-50）
    - **difficulty**: 难度范围
    - **knowledge_point_ids**: 知识点ID列表
    """
    problems = get_random_problems(
        db,
        count=count,
        difficulty_range=difficulty,
        knowledge_point_ids=knowledge_point_ids
    )
    
    # 转换为练习模式（隐藏答案）
    practice_problems = []
    for problem in problems:
        practice_problems.append({
            "id": problem.id,
            "title": problem.title,
            "content": problem.content,
            "content_type": problem.content_type,
            "options": problem.options,
            "difficulty": problem.difficulty,
            "estimated_time": problem.estimated_time,
            "knowledge_points": [
                {"id": kp.id, "name": kp.name, "code": kp.code}
                for kp in problem.knowledge_points
            ] if problem.knowledge_points else []
        })
    
    return practice_problems

@router.get("/search/{keyword}", response_model=List[ProblemResponse])
async def search_problems_by_keyword(
    keyword: str,
    skip: int = 0,
    limit: int = 50,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    搜索题目
    
    权限：需要登录
    - **keyword**: 搜索关键词
    - **skip**: 分页跳过
    - **limit**: 分页限制
    """
    problems = search_problems(db, keyword, skip=skip, limit=limit)
    return problems

@router.post("/{problem_id}/attempt")
async def record_problem_attempt(
    problem_id: int,
    is_correct: bool,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    记录题目答题尝试
    
    权限：需要登录
    - **problem_id**: 题目ID
    - **is_correct**: 是否正确
    """
    success = increment_attempts(db, problem_id, is_correct)
    if not success:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="题目不存在"
        )
    
    return {"message": "答题记录已更新"}