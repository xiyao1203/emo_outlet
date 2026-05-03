"""会话模型"""
from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, Enum, ForeignKey, Integer, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class SessionModel(Base):
    __tablename__ = "session"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("user.id"), nullable=False
    )
    target_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("target.id"), nullable=False
    )

    # 会话模式
    mode: Mapped[str] = mapped_column(
        String(20), default="single", comment="single=单向, dual=双向"
    )
    chat_style: Mapped[str | None] = mapped_column(
        String(30), default="apologetic",
        comment="对话风格: stubborn/apologetic/cold/sarcastic/rational"
    )
    dialect: Mapped[str] = mapped_column(
        String(20), default="mandarin",
        comment="方言: mandarin/cantonese/sichuan/northeastern/shanghainese"
    )

    # 时间控制
    duration_minutes: Mapped[int] = mapped_column(
        Integer, default=3, comment="设定时长(分钟)"
    )
    start_time: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )
    end_time: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )

    # 状态
    status: Mapped[str] = mapped_column(
        String(20), default="pending",
        comment="pending=待开始, active=进行中, completed=正常结束, interrupted=中断"
    )
    is_completed: Mapped[bool] = mapped_column(Boolean, default=False)

    # 情绪总结
    emotion_summary: Mapped[str | None] = mapped_column(
        Text, nullable=True, comment="情绪分析结果(JSON)"
    )
    summary_text: Mapped[str | None] = mapped_column(
        Text, nullable=True, comment="会话总结文案"
    )

    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    # 关系
    user = relationship("UserModel", back_populates="sessions")
    target = relationship("TargetModel", back_populates="sessions")
    messages = relationship("MessageModel", back_populates="session", lazy="selectin")

    def __repr__(self) -> str:
        return f"<Session {self.id[:8]} mode={self.mode}>"
