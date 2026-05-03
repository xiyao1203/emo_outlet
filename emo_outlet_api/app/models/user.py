"""用户模型"""
from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlalchemy import Boolean, DateTime, String, Text, func
from sqlalchemy.dialects.mysql import VARCHAR
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class UserModel(Base):
    __tablename__ = "user"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    nickname: Mapped[str] = mapped_column(String(50), default="匿名用户")
    phone: Mapped[str | None] = mapped_column(String(20), nullable=True, unique=True)
    email: Mapped[str | None] = mapped_column(String(100), nullable=True, unique=True)
    password_hash: Mapped[str | None] = mapped_column(String(128), nullable=True)
    avatar_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    is_visitor: Mapped[bool] = mapped_column(Boolean, default=False)
    device_uuid: Mapped[str | None] = mapped_column(String(100), nullable=True)
    daily_session_count: Mapped[int] = mapped_column(default=0)
    last_active_date: Mapped[str | None] = mapped_column(String(10), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    is_deleted: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    # 关系
    targets = relationship("TargetModel", back_populates="user", lazy="selectin")
    sessions = relationship("SessionModel", back_populates="user", lazy="selectin")

    def __repr__(self) -> str:
        return f"<User {self.nickname}>"
