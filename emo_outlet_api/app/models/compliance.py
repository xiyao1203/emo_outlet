"""合规相关模型"""
from __future__ import annotations

import uuid
from datetime import datetime, timezone

from sqlalchemy import Boolean, DateTime, Integer, String, Text, func
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class ConsentRecord(Base):
    """用户同意记录"""
    __tablename__ = "consent_record"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    user_id: Mapped[str] = mapped_column(String(36), index=True)
    consent_type: Mapped[str] = mapped_column(
        String(20), comment="同意类型: privacy / terms"
    )
    consent_version: Mapped[str] = mapped_column(String(20), comment="协议版本号")
    ip_address: Mapped[str | None] = mapped_column(String(45), nullable=True)
    user_agent: Mapped[str | None] = mapped_column(String(500), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )


class ContentReport(Base):
    """内容举报记录"""
    __tablename__ = "content_report"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    reporter_user_id: Mapped[str] = mapped_column(String(36), index=True)
    session_id: Mapped[str | None] = mapped_column(String(36), nullable=True)
    message_id: Mapped[str | None] = mapped_column(String(36), nullable=True)
    report_type: Mapped[str] = mapped_column(
        String(30), comment="举报类型: inappropriate / harmful / spam / other"
    )
    description: Mapped[str | None] = mapped_column(Text, nullable=True)
    status: Mapped[str] = mapped_column(
        String(20), default="pending", comment="状态: pending / resolved / dismissed"
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
    resolved_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), nullable=True
    )


class ContentAuditLog(Base):
    """内容安全审计日志"""
    __tablename__ = "content_audit_log"

    id: Mapped[str] = mapped_column(
        String(36), primary_key=True, default=lambda: str(uuid.uuid4())
    )
    user_id: Mapped[str] = mapped_column(String(36), index=True, nullable=False)
    session_id: Mapped[str | None] = mapped_column(String(36), nullable=True)
    audit_type: Mapped[str] = mapped_column(
        String(20), comment="审计类型: user_input / ai_output / report"
    )
    risk_level: Mapped[str] = mapped_column(
        String(10), default="low", comment="风险等级: low / medium / high / critical"
    )
    matched_keywords: Mapped[str | None] = mapped_column(
        String(500), nullable=True, comment="触发的敏感词列表(逗号分隔)"
    )
    original_content: Mapped[str | None] = mapped_column(
        Text, nullable=True, comment="原始内容(截取前500字)"
    )
    action_taken: Mapped[str] = mapped_column(
        String(30), default="passed", comment="处理动作: passed / filtered / blocked / interrupted / reported"
    )
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
