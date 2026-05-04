from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, Field


class SessionCreateRequest(BaseModel):
    target_id: str = Field(..., description="Target ID")
    mode: str = Field(default="single", description="single or dual")
    chat_style: str = Field(default="apologetic", description="Conversation style")
    dialect: str = Field(default="mandarin", description="Response dialect")
    duration_minutes: int = Field(default=3, ge=1, le=10, description="Session duration")


class SessionResponse(BaseModel):
    id: str
    user_id: str
    target_id: str
    target_name: str = ""
    target_avatar_url: str | None = None
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
    force: bool = Field(default=False, description="Force interrupt")


class SessionSummaryResponse(BaseModel):
    session: SessionResponse
    messages: list = Field(default_factory=list)
    emotion_analysis: dict = Field(default_factory=dict)

    class Config:
        from_attributes = True
