"""
题目相关的Pydantic模式
"""
from typing import Optional, List, Dict, Any
from pydantic import BaseModel, Field, validator
from datetime import datetime

# 题目基础模式
class ProblemBase(BaseModel):
    """题目基础模式"""
    title: str = Field(..., min_length=1, max_length=200, description="题目标题")
    content: str = Field(..., description="题目内容")
    content_type: str = Field(default="text", description="内容类型: text, markdown, latex")
    options: Dict[str, str] = Field(..., description="题目选项，如{'A': '选项A', 'B': '选项B'}")
    correct_answer: str = Field(..., pattern='^[A-D]$', description="正确答案: A, B, C, D")
    solution: Optional[str] = None
    solution_type: str = Field(default="text", description="解析类型: text, markdown")
    difficulty: int = Field(default=3, ge=1, le=5, description="难度等级: 1-5")
    source_type: Optional[str] = None
    source_year: Optional[int] = None
    source_detail: Optional[str] = None
    estimated_time: Optional[int] = Field(None, ge=1, description="预估时间（秒）")
    
    @validator('options')
    def validate_options(cls, v):
        """验证选项格式"""
        required_keys = {'A', 'B', 'C', 'D'}
        if not required_keys.issubset(v.keys()):
            missing = required_keys - set(v.keys())
            raise ValueError(f"缺少选项: {', '.join(missing)}")
        return v

# 创建题目
class ProblemCreate(ProblemBase):
    """创建题目模式"""
    knowledge_point_ids: List[int] = Field(default=[], description="关联的知识点ID列表")
    is_published: bool = Field(default=False, description="是否立即发布")

# 更新题目
class ProblemUpdate(BaseModel):
    """更新题目模式"""
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    content: Optional[str] = None
    content_type: Optional[str] = None
    options: Optional[Dict[str, str]] = None
    correct_answer: Optional[str] = Field(None, pattern='^[A-D]$')
    solution: Optional[str] = None
    solution_type: Optional[str] = None
    difficulty: Optional[int] = Field(None, ge=1, le=5)
    source_type: Optional[str] = None
    source_year: Optional[int] = None
    source_detail: Optional[str] = None
    estimated_time: Optional[int] = Field(None, ge=1)
    is_published: Optional[bool] = None
    knowledge_point_ids: Optional[List[int]] = None
    
    @validator('options')
    def validate_options(cls, v):
        if v is not None:
            required_keys = {'A', 'B', 'C', 'D'}
            if not required_keys.issubset(v.keys()):
                missing = required_keys - set(v.keys())
                raise ValueError(f"缺少选项: {', '.join(missing)}")
        return v

# 题目响应
class ProblemResponse(ProblemBase):
    """题目响应模式"""
    id: int
    is_published: bool
    review_status: str
    total_attempts: int
    correct_attempts: int
    accuracy_rate: float
    created_by: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True

# 题目详情
class ProblemDetail(ProblemResponse):
    """题目详情模式"""
    knowledge_points: Optional[List[Dict[str, Any]]] = None
    creator: Optional[Dict[str, Any]] = None

# 题目列表查询
class ProblemFilter(BaseModel):
    """题目过滤条件"""
    difficulty: Optional[List[int]] = None
    source_type: Optional[str] = None
    source_year: Optional[int] = None
    knowledge_point_id: Optional[int] = None
    is_published: Optional[bool] = True
    search: Optional[str] = None
    sort_by: str = "created_at"
    sort_order: str = "desc"

# 题目统计
class ProblemStats(BaseModel):
    """题目统计模式"""
    total_problems: int
    published_problems: int
    by_difficulty: Dict[int, int]
    by_source: Dict[str, int]
    avg_accuracy: float

# 练习题目（不包含答案）
class PracticeProblem(BaseModel):
    """练习用题目模式（隐藏答案）"""
    id: int
    title: str
    content: str
    content_type: str
    options: Dict[str, str]
    difficulty: int
    estimated_time: Optional[int] = None
    knowledge_points: Optional[List[Dict[str, Any]]] = None