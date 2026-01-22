"""
题目模型
对应Day 2的problems表设计
"""
from sqlalchemy import Column, Integer, String, Text, Boolean, Float, DateTime, JSON, ForeignKey, func, Index
from sqlalchemy.orm import relationship, validates
from sqlalchemy.sql import expression
import json

from app.core.database import Base

class Problem(Base):
    """题目表模型"""
    
    __tablename__ = "problems"
    
    id = Column(Integer, primary_key=True, index=True)
    
    # 题目基本信息
    title = Column(String(200), nullable=False, index=True)
    content = Column(Text, nullable=False)
    content_type = Column(String(20), default="text", nullable=False)  # text, markdown, latex
    
    # 选项和答案
    options = Column(JSON, nullable=False, default=dict)
    correct_answer = Column(String(10), nullable=False)
    solution = Column(Text, nullable=True)
    solution_type = Column(String(20), default="text", nullable=True)
    
    # 分类和难度
    difficulty = Column(Integer, default=3, nullable=False)  # 1-5
    source_type = Column(String(50), nullable=True)  # AMC8, 迎春杯, 华杯赛
    source_year = Column(Integer, nullable=True)
    source_detail = Column(String(100), nullable=True)
    
    # 预估属性
    estimated_time = Column(Integer, nullable=True)  # 秒
    success_rate = Column(Float, nullable=True)  # 历史正确率
    
    # 状态控制
    is_published = Column(Boolean, default=False, server_default=expression.false())
    is_deleted = Column(Boolean, default=False, server_default=expression.false())
    
    # 审核信息
    reviewed_by = Column(Integer, ForeignKey("users.id"), nullable=True)
    reviewed_at = Column(DateTime(timezone=True), nullable=True)
    review_status = Column(String(20), default="pending", nullable=False)
    
    # 统计信息
    total_attempts = Column(Integer, default=0)
    correct_attempts = Column(Integer, default=0)
    
    # 创建者
    created_by = Column(Integer, ForeignKey("users.id"), nullable=False)
    
    # 时间戳
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # 关系
    creator = relationship("User", foreign_keys=[created_by], lazy="select")
    reviewer = relationship("User", foreign_keys=[reviewed_by], lazy="select")
    knowledge_points = relationship(
        "KnowledgePoint",
        secondary="problem_knowledge_points",
        backref="problems",
        lazy="select",
    )
    
    # 全文搜索索引（在数据库层面实现）
    __table_args__ = (
        Index('ix_problems_search', 'title', 'content', postgresql_using='gin'),
    )
    
    def __repr__(self):
        return f"<Problem(id={self.id}, title={self.title}, difficulty={self.difficulty})>"
    
    @validates('options')
    def validate_options(self, key, options):
        """验证选项格式"""
        if isinstance(options, str):
            try:
                options = json.loads(options)
            except json.JSONDecodeError:
                raise ValueError("options必须是有效的JSON字符串")
        
        if not isinstance(options, dict):
            raise ValueError("options必须是字典格式")
        
        # 确保有A-D选项
        for option in ['A', 'B', 'C', 'D']:
            if option not in options:
                raise ValueError(f"缺少选项{option}")
        
        return options
    
    @validates('difficulty')
    def validate_difficulty(self, key, difficulty):
        """验证难度范围"""
        if not 1 <= difficulty <= 5:
            raise ValueError("难度必须在1-5之间")
        return difficulty
    
    @property
    def accuracy_rate(self):
        """计算正确率"""
        if self.total_attempts == 0:
            return 0.0
        return self.correct_attempts / self.total_attempts * 100
    
    def to_dict(self, include_solution=False, include_creator=False):
        """转换为字典"""
        data = {
            "id": self.id,
            "title": self.title,
            "content": self.content,
            "content_type": self.content_type,
            "options": self.options,
            "correct_answer": self.correct_answer,
            "difficulty": self.difficulty,
            "source_type": self.source_type,
            "source_year": self.source_year,
            "estimated_time": self.estimated_time,
            "is_published": self.is_published,
            "review_status": self.review_status,
            "total_attempts": self.total_attempts,
            "correct_attempts": self.correct_attempts,
            "accuracy_rate": round(self.accuracy_rate, 2),
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }
        
        if include_solution and self.solution:
            data["solution"] = self.solution
            data["solution_type"] = self.solution_type
        
        if include_creator and self.creator:
            data["creator"] = {
                "id": self.creator.id,
                "username": self.creator.username,
                "full_name": self.creator.full_name,
            }
        
        if self.knowledge_points:
            data["knowledge_points"] = [
                {"id": kp.id, "name": kp.name, "code": kp.code}
                for kp in self.knowledge_points
            ]
        
        return data
    
    def increment_attempts(self, is_correct: bool):
        """增加答题统计"""
        self.total_attempts += 1
        if is_correct:
            self.correct_attempts += 1

# 题目-知识点关联表（多对多）
class ProblemKnowledgePoint(Base):
    """题目-知识点关联表"""
    
    __tablename__ = "problem_knowledge_points"
    
    problem_id = Column(Integer, ForeignKey("problems.id", ondelete="CASCADE"), primary_key=True)
    knowledge_point_id = Column(Integer, ForeignKey("knowledge_points.id", ondelete="CASCADE"), primary_key=True)
    is_primary = Column(Boolean, default=False)
    weight = Column(Float, default=1.0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 关系
    problem = relationship("Problem", backref="problem_knowledge_associations", lazy="select")
    knowledge_point = relationship("KnowledgePoint", backref="knowledge_point_problem_associations", lazy="select")
    
    def __repr__(self):
        return f"<ProblemKnowledgePoint(problem={self.problem_id}, knowledge={self.knowledge_point_id})>"
