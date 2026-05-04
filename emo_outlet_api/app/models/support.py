from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import DateTime, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class UserProfileDetailModel(Base):
    __tablename__ = "user_profile_detail"

    user_id: Mapped[str] = mapped_column(String(36), primary_key=True)
    signature: Mapped[str | None] = mapped_column(String(120), nullable=True)
    gender: Mapped[str | None] = mapped_column(String(20), nullable=True)
    birthday: Mapped[str | None] = mapped_column(String(20), nullable=True)
    region: Mapped[str | None] = mapped_column(String(60), nullable=True)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
    )


class SupportFeedbackModel(Base):
    __tablename__ = "support_feedback"

    id: Mapped[str] = mapped_column(
        String(36),
        primary_key=True,
        default=lambda: str(uuid.uuid4()),
    )
    user_id: Mapped[str] = mapped_column(String(36), index=True)
    content: Mapped[str] = mapped_column(Text)
    image_urls: Mapped[str | None] = mapped_column(Text, nullable=True)
    source: Mapped[str] = mapped_column(String(40), default="help_feedback")
    status: Mapped[str] = mapped_column(String(20), default="submitted")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
    )


class UserPreferenceModel(Base):
    __tablename__ = "user_preference"

    user_id: Mapped[str] = mapped_column(String(36), primary_key=True)
    save_history: Mapped[bool] = mapped_column(default=True)
    allow_posters: Mapped[bool] = mapped_column(default=True)
    private_only: Mapped[bool] = mapped_column(default=False)
    auto_clear_session: Mapped[bool] = mapped_column(default=True)
    session_reminder: Mapped[bool] = mapped_column(default=True)
    report_reminder: Mapped[bool] = mapped_column(default=True)
    poster_reminder: Mapped[bool] = mapped_column(default=True)
    activity_notification: Mapped[bool] = mapped_column(default=False)
    system_notification: Mapped[bool] = mapped_column(default=True)
    dialect: Mapped[str] = mapped_column(String(20), default="mandarin")
    wechat_bound: Mapped[bool] = mapped_column(default=False)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
    )
