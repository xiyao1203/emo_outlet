"""海报相关 Pydantic Schema"""
from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, Field


class EmotionAnalysisResult(BaseModel):
    """情绪分析结果"""
    primary_emotion: str = Field(default="", description="主导情绪")
    emotions: dict[str, float] = Field(default_factory=dict, description="情绪分布")
    intensity: int = Field(default=0, ge=0, le=100, description="整体强度")
    keywords: list[str] = Field(default_factory=list, description="高频关键词")
    summary: str = Field(default="", description="总结文案")
    suggestion: str = Field(default="", description="调节建议")


class PosterGenerateRequest(BaseModel):
    """生成海报请求"""
    session_id: str = Field(..., description="会话 ID")


class PosterResponse(BaseModel):
    """海报响应"""
    id: str
    session_id: str
    title: str | None = None
    emotion_type: str | None = None
    emotion_intensity: int | None = None
    keywords: str | None = None
    suggestion: str | None = None
    poster_url: str | None = None
    poster_data: str | None = None
    created_at: datetime | None = None

    class Config:
        from_attributes = True


class EmotionReportResponse(BaseModel):
    """情绪报告响应"""
    total_sessions: int = 0
    total_duration_minutes: int = 0
    dominant_emotion: str = ""
    emotion_distribution: dict[str, float] = {}
    daily_trend: list[dict] = []
    suggestion: str = ""
