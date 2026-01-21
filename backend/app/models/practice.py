"""
练习和答题模型
对应Day 2的practice_sessions, answer_records等表设计
"""
from sqlalchemy import Column, Integer, String, Boolean, Float, DateTime, JSON, ForeignKey, func, ARRAY
from sqlalchemy.orm import relationship, validates
from sqlalchemy.dialects.postgresql import INET
from datetime import datetime, timezone

from app.core.database import Base

class PracticeSession(Base):
    """练习会话表模型"""
    
    __tablename__ = "practice_sessions"
    
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    
    # 练习配置
    session_type = Column(String(50), default="random", nullable=False)  # random, knowledge_point, difficulty, exam
    config = Column(JSON, default=dict, server_default="{}")
    
    # 状态
    status = Column(String(20), default="in_progress", nullable=False)  # in_progress, completed, abandoned
    
    # 统计信息
    total_questions = Column(Integer, default=0)
    completed_questions = Column(Integer, default=0)
    correct_questions = Column(Integer, default=0)
    
    # 时间跟踪
    started_at = Column(DateTime(timezone=True), server_default=func.now())
    completed_at = Column(DateTime(timezone=True), nullable=True)
    total_duration = Column(Integer, nullable=True)  # 秒
    
    # 性能指标
    average_time_per_question = Column(Float, nullable=True)
    accuracy_rate = Column(Float, nullable=True)
    
    # 元数据
    device_info = Column(JSON, default=dict, server_default="{}")
    ip_address = Column(INET, nullable=True)
    
    # 关系
    user = relationship("User", backref="practice_sessions", lazy="select")
    answer_records = relationship("AnswerRecord", backref="session", cascade="all, delete-orphan", lazy="select")
    
    def __repr__(self):
        return f"<PracticeSession(id={self.id}, user={self.user_id}, status={self.status})>"
    
    @property
    def is_completed(self):
        """检查是否完成"""
        return self.status == "completed"
    
    @property
    def completion_rate(self):
        """计算完成率"""
        if self.total_questions == 0:
            return 0.0
        return self.completed_questions / self.total_questions * 100
    
    def complete_session(self):
        """完成练习会话"""
        if not self.is_completed:
            self.status = "completed"
            self.completed_at = datetime.now(timezone.utc)
            
            # 计算总时长
            if self.started_at and self.completed_at:
                self.total_duration = int((self.completed_at - self.started_at).total_seconds())
            
            # 计算平均每题用时
            if self.completed_questions > 0 and self.total_duration:
                self.average_time_per_question = self.total_duration / self.completed_questions
            
            # 计算正确率
            if self.completed_questions > 0:
                self.accuracy_rate = self.correct_questions / self.completed_questions * 100
    
    def to_dict(self, include_answers=False):
        """转换为字典"""
        data = {
            "id": self.id,
            "user_id": self.user_id,
            "session_type": self.session_type,
            "status": self.status,
            "total_questions": self.total_questions,
            "completed_questions": self.completed_questions,
            "correct_questions": self.correct_questions,
            "completion_rate": round(self.completion_rate, 2),
            "started_at": self.started_at.isoformat() if self.started_at else None,
            "completed_at": self.completed_at.isoformat() if self.completed_at else None,
            "total_duration": self.total_duration,
            "average_time_per_question": round(self.average_time_per_question, 2) if self.average_time_per_question else None,
            "accuracy_rate": round(self.accuracy_rate, 2) if self.accuracy_rate else None,
            "config": self.config,
        }
        
        if include_answers and self.answer_records:
            data["answer_records"] = [record.to_dict() for record in self.answer_records]
        
        return data

class AnswerRecord(Base):
    """答题记录表模型"""
    
    __tablename__ = "answer_records"
    
    id = Column(Integer, primary_key=True, index=True)
    session_id = Column(Integer, ForeignKey("practice_sessions.id", ondelete="CASCADE"), nullable=False)
    problem_id = Column(Integer, ForeignKey("problems.id"), nullable=False)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    
    # 答题详情
    user_answer = Column(String(10), nullable=True)
    is_correct = Column(Boolean, nullable=True)
    confidence_level = Column(Integer, nullable=True)  # 1-5
    
    # 时间分析
    time_spent = Column(Integer, nullable=False)  # 秒
    first_response_time = Column(Integer, nullable=True)  # 秒
    review_count = Column(Integer, default=0)
    
    # 步骤数据
    steps = Column(JSON, default=list, server_default="[]")
    hesitation_points = Column(JSON, default=list, server_default="[]")
    
    # 反馈
    user_feedback = Column(String(20), nullable=True)  # too_easy, appropriate, too_hard, unclear
    note = Column(String(500), nullable=True)
    
    # 时间戳
    answered_at = Column(DateTime(timezone=True), server_default=func.now())
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # 知识点数组（优化查询）
    knowledge_point_ids = Column(ARRAY(Integer), default=[], server_default="{}")
    
    # 关系
    problem = relationship("Problem", backref="answer_records", lazy="select")
    user = relationship("User", backref="answer_records", lazy="select")
    
    def __repr__(self):
        return f"<AnswerRecord(id={self.id}, session={self.session_id}, correct={self.is_correct})>"
    
    def to_dict(self, include_problem=False):
        """转换为字典"""
        data = {
            "id": self.id,
            "session_id": self.session_id,
            "problem_id": self.problem_id,
            "user_answer": self.user_answer,
            "is_correct": self.is_correct,
            "confidence_level": self.confidence_level,
            "time_spent": self.time_spent,
            "first_response_time": self.first_response_time,
            "review_count": self.review_count,
            "user_feedback": self.user_feedback,
            "note": self.note,
            "answered_at": self.answered_at.isoformat() if self.answered_at else None,
            "knowledge_point_ids": self.knowledge_point_ids,
        }
        
        if include_problem and self.problem:
            data["problem"] = {
                "id": self.problem.id,
                "title": self.problem.title,
                "difficulty": self.problem.difficulty,
                "options": self.problem.options,
                "correct_answer": self.problem.correct_answer,
            }
        
        return data

# 错题本模型（后面创建）