from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, Field


class SupportOverviewResponse(BaseModel):
    online_status: str
    service_hours: str
    email: str
    community_name: str
    preview_messages: list[dict]
    common_entries: list[dict]


class SupportFeedbackCreateRequest(BaseModel):
    content: str = Field(..., min_length=1, max_length=500)
    image_urls: list[str] = Field(default_factory=list)
    source: str = Field(default="help_feedback", max_length=40)


class SupportFeedbackResponse(BaseModel):
    id: str
    status: str
    message: str
    created_at: datetime | None = None
