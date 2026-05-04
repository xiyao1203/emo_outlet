from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import Boolean, DateTime, ForeignKey, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base


class PosterModel(Base):
    __tablename__ = "poster"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    session_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("session.id"), nullable=False, unique=True
    )
    user_id: Mapped[str] = mapped_column(
        String(36), ForeignKey("user.id"), nullable=False
    )
    title: Mapped[str | None] = mapped_column(String(200), nullable=True)
    emotion_type: Mapped[str | None] = mapped_column(String(30), nullable=True)
    emotion_intensity: Mapped[int | None] = mapped_column(nullable=True)
    keywords: Mapped[str | None] = mapped_column(Text, nullable=True)
    suggestion: Mapped[str | None] = mapped_column(Text, nullable=True)
    poster_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    poster_data: Mapped[str | None] = mapped_column(Text, nullable=True)
    is_favorite: Mapped[bool] = mapped_column(Boolean, default=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )

    session = relationship("SessionModel")
    user = relationship("UserModel")

    def __repr__(self) -> str:
        return f"<Poster {self.id[:8]} emotion={self.emotion_type}>"
