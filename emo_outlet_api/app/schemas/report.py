"""举报相关 Schema"""
from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, Field


class CreateReportRequest(BaseModel):
    """创建举报请求"""
    session_id: str | None = Field(default=None, description="会话ID")
    message_id: str | None = Field(default=None, description="消息ID")
    report_type: str = Field(
        ..., description="举报类型: inappropriate / harmful / spam / violence / sexual / other"
    )
    description: str = Field(default="", max_length=1000, description="举报描述")


class ReportResponse(BaseModel):
    """举报响应"""
    id: str
    reporter_user_id: str
    session_id: str | None = None
    message_id: str | None = None
    report_type: str
    description: str | None = None
    status: str
    created_at: datetime | None = None

    class Config:
        from_attributes = True


class ReportListResponse(BaseModel):
    """举报列表响应"""
    reports: list[ReportResponse]
    total: int
    page: int
    page_size: int


class ResolveReportRequest(BaseModel):
    """处理举报请求"""
    action: str = Field(..., description="处理动作: dismiss / warn / ban")
    note: str = Field(default="", description="处理备注")
