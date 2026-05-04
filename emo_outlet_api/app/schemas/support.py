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


class UserPreferenceResponse(BaseModel):
    save_history: bool = True
    allow_posters: bool = True
    private_only: bool = False
    auto_clear_session: bool = True
    session_reminder: bool = True
    report_reminder: bool = True
    poster_reminder: bool = True
    activity_notification: bool = False
    system_notification: bool = True
    dialect: str = "mandarin"
    wechat_bound: bool = False


class UserPreferenceUpdateRequest(BaseModel):
    save_history: bool | None = None
    allow_posters: bool | None = None
    private_only: bool | None = None
    auto_clear_session: bool | None = None
    session_reminder: bool | None = None
    report_reminder: bool | None = None
    poster_reminder: bool | None = None
    activity_notification: bool | None = None
    system_notification: bool | None = None
    dialect: str | None = None
    wechat_bound: bool | None = None
