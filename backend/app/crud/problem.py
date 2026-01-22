"""
题目CRUD操作
"""
from typing import Optional, List, Dict, Any
from sqlalchemy.orm import Session
from sqlalchemy import func, or_, and_

from app.models.problem import Problem, ProblemKnowledgePoint
from app.models.knowledge_point import KnowledgePoint
from app.schemas.problem import ProblemCreate, ProblemUpdate, ProblemFilter

def get_problem(db: Session, problem_id: int) -> Optional[Problem]:
    """根据ID获取题目"""
    return db.query(Problem).filter(Problem.id == problem_id).first()

def get_problems(
    db: Session,
    skip: int = 0,
    limit: int = 100,
    filter_params: Optional[ProblemFilter] = None
) -> List[Problem]:
    """获取题目列表（带过滤）"""
    query = db.query(Problem)
    
    if filter_params:
        # 难度过滤
        if filter_params.difficulty:
            query = query.filter(Problem.difficulty.in_(filter_params.difficulty))
        
        # 来源过滤
        if filter_params.source_type:
            query = query.filter(Problem.source_type == filter_params.source_type)
        
        if filter_params.source_year:
            query = query.filter(Problem.source_year == filter_params.source_year)
        
        # 知识点过滤
        if filter_params.knowledge_point_id:
            query = query.join(Problem.knowledge_points).filter(
                KnowledgePoint.id == filter_params.knowledge_point_id
            )
        
        # 发布状态过滤
        if filter_params.is_published is not None:
            query = query.filter(Problem.is_published == filter_params.is_published)
        
        # 搜索
        if filter_params.search:
            search_term = f"%{filter_params.search}%"
            query = query.filter(
                or_(
                    Problem.title.ilike(search_term),
                    Problem.content.ilike(search_term),
                    Problem.solution.ilike(search_term)
                )
            )
        
        # 排序
        sort_column = getattr(Problem, filter_params.sort_by, Problem.created_at)
        if filter_params.sort_order == "desc":
            query = query.order_by(sort_column.desc())
        else:
            query = query.order_by(sort_column.asc())
    
    # 排除已删除的题目
    query = query.filter(Problem.is_deleted == False)
    
    return query.offset(skip).limit(limit).all()

def create_problem(
    db: Session,
    problem_create: ProblemCreate,
    created_by: int
) -> Problem:
    """创建新题目"""
    # 创建题目对象
    db_problem = Problem(
        title=problem_create.title,
        content=problem_create.content,
        content_type=problem_create.content_type,
        options=problem_create.options,
        correct_answer=problem_create.correct_answer,
        solution=problem_create.solution,
        solution_type=problem_create.solution_type,
        difficulty=problem_create.difficulty,
        source_type=problem_create.source_type,
        source_year=problem_create.source_year,
        source_detail=problem_create.source_detail,
        estimated_time=problem_create.estimated_time,
        is_published=problem_create.is_published,
        created_by=created_by,
    )
    
    db.add(db_problem)
    db.commit()
    db.refresh(db_problem)
    
    # 关联知识点
    if problem_create.knowledge_point_ids:
        for kp_id in problem_create.knowledge_point_ids:
            # 验证知识点是否存在
            knowledge_point = db.query(KnowledgePoint).filter(
                KnowledgePoint.id == kp_id
            ).first()
            
            if knowledge_point:
                association = ProblemKnowledgePoint(
                    problem_id=db_problem.id,
                    knowledge_point_id=kp_id,
                    is_primary=True if kp_id == problem_create.knowledge_point_ids[0] else False
                )
                db.add(association)
        
        db.commit()
        db.refresh(db_problem)
    
    return db_problem

def update_problem(
    db: Session,
    db_problem: Problem,
    problem_update: ProblemUpdate
) -> Problem:
    """更新题目"""
    update_data = problem_update.model_dump(exclude_unset=True)
    
    # 处理知识点更新
    knowledge_point_ids = update_data.pop("knowledge_point_ids", None)
    
    # 更新其他字段
    for field, value in update_data.items():
        setattr(db_problem, field, value)
    
    # 更新知识点关联
    if knowledge_point_ids is not None:
        # 删除现有关联
        db.query(ProblemKnowledgePoint).filter(
            ProblemKnowledgePoint.problem_id == db_problem.id
        ).delete()
        
        # 添加新关联
        for kp_id in knowledge_point_ids:
            knowledge_point = db.query(KnowledgePoint).filter(
                KnowledgePoint.id == kp_id
            ).first()
            
            if knowledge_point:
                association = ProblemKnowledgePoint(
                    problem_id=db_problem.id,
                    knowledge_point_id=kp_id,
                    is_primary=True if kp_id == knowledge_point_ids[0] else False
                )
                db.add(association)
    
    db.commit()
    db.refresh(db_problem)
    
    return db_problem

def delete_problem(db: Session, problem_id: int) -> bool:
    """删除题目（软删除）"""
    problem = get_problem(db, problem_id)
    if not problem:
        return False
    
    problem.is_deleted = True
    db.commit()
    
    return True

def publish_problem(db: Session, problem_id: int, publish: bool = True) -> bool:
    """发布或取消发布题目"""
    problem = get_problem(db, problem_id)
    if not problem:
        return False
    
    problem.is_published = publish
    problem.review_status = "approved" if publish else "pending"
    
    if publish:
        problem.reviewed_at = func.now()
    
    db.commit()
    return True

def get_problem_stats(db: Session) -> Dict[str, Any]:
    """获取题目统计信息"""
    # 总数
    total = db.query(func.count(Problem.id)).filter(
        Problem.is_deleted == False
    ).scalar()
    
    # 已发布数量
    published = db.query(func.count(Problem.id)).filter(
        Problem.is_deleted == False,
        Problem.is_published == True
    ).scalar()
    
    # 按难度统计
    difficulty_stats = db.query(
        Problem.difficulty,
        func.count(Problem.id).label("count")
    ).filter(
        Problem.is_deleted == False,
        Problem.is_published == True
    ).group_by(
        Problem.difficulty
    ).all()
    
    difficulty_dict = {row.difficulty: row.count for row in difficulty_stats}
    
    # 按来源统计
    source_stats = db.query(
        Problem.source_type,
        func.count(Problem.id).label("count")
    ).filter(
        Problem.is_deleted == False,
        Problem.is_published == True,
        Problem.source_type.isnot(None)
    ).group_by(
        Problem.source_type
    ).all()
    
    source_dict = {row.source_type: row.count for row in source_stats}
    
    # 平均正确率
    avg_accuracy = db.query(
        func.avg(
            func.cast(Problem.correct_attempts, func.FLOAT) /
            func.nullif(func.cast(Problem.total_attempts, func.FLOAT), 0)
        ).label("avg_accuracy")
    ).filter(
        Problem.is_deleted == False,
        Problem.total_attempts > 0
    ).scalar() or 0.0
    
    return {
        "total_problems": total or 0,
        "published_problems": published or 0,
        "by_difficulty": difficulty_dict,
        "by_source": source_dict,
        "avg_accuracy": round(avg_accuracy * 100, 2),
    }

def get_random_problems(
    db: Session,
    count: int = 10,
    difficulty_range: Optional[List[int]] = None,
    knowledge_point_ids: Optional[List[int]] = None
) -> List[Problem]:
    """获取随机题目"""
    query = db.query(Problem).filter(
        Problem.is_deleted == False,
        Problem.is_published == True
    )
    
    # 难度过滤
    if difficulty_range:
        query = query.filter(Problem.difficulty.in_(difficulty_range))
    
    # 知识点过滤
    if knowledge_point_ids:
        query = query.join(Problem.knowledge_points).filter(
            KnowledgePoint.id.in_(knowledge_point_ids)
        )
    
    # 随机排序并限制数量
    query = query.order_by(func.random()).limit(count)
    
    return query.all()

def increment_attempts(db: Session, problem_id: int, is_correct: bool) -> bool:
    """增加题目答题统计"""
    problem = get_problem(db, problem_id)
    if not problem:
        return False
    
    problem.increment_attempts(is_correct)
    db.commit()
    
    return True

def search_problems(
    db: Session,
    keyword: str,
    skip: int = 0,
    limit: int = 50
) -> List[Problem]:
    """搜索题目"""
    search_term = f"%{keyword}%"
    
    query = db.query(Problem).filter(
        Problem.is_deleted == False,
        Problem.is_published == True
    ).filter(
        or_(
            Problem.title.ilike(search_term),
            Problem.content.ilike(search_term),
            Problem.solution.ilike(search_term)
        )
    )
    
    return query.order_by(Problem.created_at.desc()).offset(skip).limit(limit).all()
