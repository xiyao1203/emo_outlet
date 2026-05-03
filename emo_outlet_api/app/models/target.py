"""泄愤对象模型"""
from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class TargetModel(Base):
    __tablename__ = "target"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("user.id"), nullable=False
    )
    name: Mapped[str] = mapped_column(String(100), nullable=False, comment="对象名称")
    type: Mapped[str] = mapped_column(
        String(50), default="custom", comment="类型: boss/spouse/colleague/客户/custom"
    )
    appearance: Mapped[str | None] = mapped_column(
        Text, nullable=True, comment="外貌描述"
    )
    personality: Mapped[str | None] = mapped_column(
        Text, nullable=True, comment="性格特征"
    )
    relation: Mapped[str | None] = mapped_column(
        "relationship", String(100), nullable=True, comment="关系: 直属领导/同事/伴侣..."
    )
    style: Mapped[str] = mapped_column(
        String(50), default="漫画", comment="形象风格"
    )
    avatar_url: Mapped[str | None] = mapped_column(
        String(500), nullable=True, comment="AI 生成的虚拟形象 URL"
    )
    is_hidden: Mapped[bool] = mapped_column(default=False)
    is_deleted: Mapped[bool] = mapped_column(default=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    # 关系
    user = relationship("UserModel", back_populates="targets")
    sessions = relationship("SessionModel", back_populates="target", lazy="selectin")

    def __repr__(self) -> str:
        return f"<Target {self.name}>"
