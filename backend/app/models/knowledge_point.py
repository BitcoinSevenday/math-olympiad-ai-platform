"""
知识点模型
对应Day 2的knowledge_points表设计
支持树形结构
"""
from sqlalchemy import Column, Integer, String, Text, Float, DateTime, func, ForeignKey
from sqlalchemy.orm import relationship, validates
from sqlalchemy.ext.hybrid import hybrid_property

from app.core.database import Base

class KnowledgePoint(Base):
    """知识点表模型（树形结构）"""
    
    __tablename__ = "knowledge_points"
    
    id = Column(Integer, primary_key=True, index=True)
    
    # 知识点信息
    name = Column(String(100), nullable=False, index=True)
    code = Column(String(50), unique=True, nullable=False, index=True)
    
    # 树形结构
    parent_id = Column(Integer, ForeignKey("knowledge_points.id", ondelete="CASCADE"), nullable=True)
    level = Column(Integer, default=1, nullable=False)  # 层级
    
    # 描述和排序
    description = Column(Text, nullable=True)
    sort_order = Column(Integer, default=0)
    weight = Column(Float, default=1.0)  # 权重
    
    # 统计信息
    problem_count = Column(Integer, default=0)
    
    # 时间戳
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())
    
    # 关系
    parent = relationship(
        "KnowledgePoint", 
        remote_side=[id],
        backref="children",
        lazy="select",
    )
    
    def __repr__(self):
        return f"<KnowledgePoint(id={self.id}, code={self.code}, name={self.name})>"
    
    @validates('code')
    def validate_code(self, key, code):
        """验证知识点编码格式"""
        if not code.replace('.', '').replace('_', '').isalnum():
            raise ValueError("知识点编码只能包含字母、数字、点和下划线")
        return code
    
    @hybrid_property
    def full_path(self):
        """获取完整路径（如：algebra.equation.quadratic）"""
        if self.parent:
            return f"{self.parent.full_path}.{self.code}"
        return self.code
    
    def to_dict(self, include_children=False, max_depth=2):
        """转换为字典"""
        data = {
            "id": self.id,
            "name": self.name,
            "code": self.code,
            "parent_id": self.parent_id,
            "level": self.level,
            "description": self.description,
            "weight": self.weight,
            "problem_count": self.problem_count,
            "full_path": self.full_path,
            "created_at": self.created_at.isoformat() if self.created_at else None,
        }
        
        if include_children and max_depth > 0 and self.children:
            data["children"] = [
                child.to_dict(include_children=True, max_depth=max_depth-1)
                for child in self.children
            ]
        
        return data
    
    def get_ancestors(self):
        """获取所有祖先节点"""
        ancestors = []
        current = self.parent
        while current:
            ancestors.insert(0, current.to_dict())
            current = current.parent
        return ancestors
    
    def get_descendants(self, include_self=False):
        """获取所有后代节点"""
        descendants = []
        
        if include_self:
            descendants.append(self.to_dict())
        
        for child in self.children:
            descendants.append(child.to_dict(include_children=False))
            descendants.extend(child.get_descendants())
        
        return descendants