from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, Field


class MessageSendRequest(BaseModel):
    content: str = Field(..., min_length=1, max_length=5000, description="Message content")


class MessageResponse(BaseModel):
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
    messages: list[MessageResponse] = Field(default_factory=list)
    total: int = 0
    session_status: str = "active"
    remaining_seconds: int = 0
