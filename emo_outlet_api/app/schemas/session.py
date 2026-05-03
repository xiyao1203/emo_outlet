"""会话相关 Pydantic Schema"""
from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, Field


class SessionCreateRequest(BaseModel):
    """创建会话请求"""
    target_id: str = Field(..., description="泄愤对象 ID")
    mode: str = Field(default="single", description="single=单向, dual=双向")
    chat_style: str = Field(
        default="apologetic",
        description="对话风格: stubborn/apologetic/cold/sarcastic/rational"
    )
    dialect: str = Field(
        default="mandarin",
        description="方言: mandarin/cantonese/sichuan/northeastern/shanghainese"
    )
    duration_minutes: int = Field(
        default=3, ge=1, le=10, description="时长(分钟): 1/3/5/10"
    )


class SessionResponse(BaseModel):
    """会话响应"""
    id: str
    user_id: str
    target_id: str
    mode: str
    chat_style: str | None = None
    dialect: str
    duration_minutes: int
    start_time: datetime | None = None
    end_time: datetime | None = None
    status: str
    is_completed: bool = False
    emotion_summary: str | None = None
    summary_text: str | None = None
    created_at: datetime | None = None

    class Config:
        from_attributes = True


class SessionEndRequest(BaseModel):
    """结束会话请求"""
    force: bool = Field(default=False, description="是否强制中断")


class SessionSummaryResponse(BaseModel):
    """会话总结响应（含消息）"""
    session: SessionResponse
    messages: list = []
    emotion_analysis: dict = {}

    class Config:
        from_attributes = True
