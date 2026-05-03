"""消息相关 Pydantic Schema"""
from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, Field


class MessageSendRequest(BaseModel):
    """发送消息请求"""
    content: str = Field(
        ..., min_length=1, max_length=5000, description="消息内容"
    )


class MessageResponse(BaseModel):
    """消息响应"""
    id: str
    session_id: str
    content: str
    sender: str
    dialect: str | None = None
    emotion_type: str | None = None
    emotion_intensity: int | None = None
    is_sensitive: bool = False
    sequence: int = 0
    created_at: datetime | None = None

    class Config:
        from_attributes = True


class MessageListResponse(BaseModel):
    """消息列表响应"""
    messages: list[MessageResponse] = []
    total: int = 0
    session_status: str = "active"
    remaining_seconds: int = 0
