from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, Field


class EmotionAnalysisResult(BaseModel):
    primary_emotion: str = ""
    emotions: dict[str, float] = Field(default_factory=dict)
    intensity: int = Field(default=0, ge=0, le=100)
    keywords: list[str] = Field(default_factory=list)
    summary: str = ""
    suggestion: str = ""


class PosterGenerateRequest(BaseModel):
    session_id: str


class PosterResponse(BaseModel):
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


class PosterDetailResponse(BaseModel):
    id: str
    session_id: str
    title: str
    date: str
    tag: str
    summary: str
    created_at_label: str
    source_session_title: str
    poster_data: str | None = None


class EmotionReportResponse(BaseModel):
    total_sessions: int = 0
    total_duration_minutes: int = 0
    dominant_emotion: str = ""
    emotion_distribution: dict[str, float] = Field(default_factory=dict)
    daily_trend: list[dict] = Field(default_factory=list)
    suggestion: str = ""


class EmotionReportDetailResponse(BaseModel):
    period: str
    trend_points: list[dict]
    mode_distribution: dict[str, float]
    target_distribution: list[dict]
    time_distribution: list[dict]
    keyword_counts: list[dict]
