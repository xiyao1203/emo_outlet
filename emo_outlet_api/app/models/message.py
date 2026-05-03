"""消息模型"""
from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, Integer, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class MessageModel(Base):
    __tablename__ = "message"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    session_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("session.id"), nullable=False
    )
    content: Mapped[str] = mapped_column(Text, nullable=False, comment="消息内容")
    sender: Mapped[str] = mapped_column(
        String(10), nullable=False, comment="user=用户, ai=AI, system=系统"
    )
    dialect: Mapped[str | None] = mapped_column(
        String(20), nullable=True, comment="方言类型"
    )
    emotion_type: Mapped[str | None] = mapped_column(
        String(30), nullable=True, comment="情绪类型(愤怒/悲伤/焦虑等)"
    )
    emotion_intensity: Mapped[int | None] = mapped_column(
        Integer, nullable=True, comment="情绪强度 1-100"
    )
    is_sensitive: Mapped[bool] = mapped_column(default=False, comment="是否触发敏感词")
    sequence: Mapped[int] = mapped_column(Integer, default=0, comment="消息序号")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )

    # 关系
    session = relationship("SessionModel", back_populates="messages")

    def __repr__(self) -> str:
        return f"<Message {self.sender}:{self.content[:30]}>"
