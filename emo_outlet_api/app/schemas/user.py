from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, Field


class UserRegisterRequest(BaseModel):
    nickname: str = Field(default="", max_length=50)
    phone: str | None = Field(default=None, pattern=r"^1\d{10}$")
    email: str | None = None
    password: str = Field(..., min_length=6, max_length=50)
    device_uuid: str | None = None
    consent_version: str | None = None
    age_range: str | None = None


class UserLoginRequest(BaseModel):
    account: str
    password: str


class VisitorLoginRequest(BaseModel):
    device_uuid: str
    nickname: str = Field(default="匿名用户", max_length=50)


class UserResponse(BaseModel):
    id: str
    nickname: str
    phone: str | None = None
    email: str | None = None
    avatar_url: str | None = None
    is_visitor: bool = False
    daily_session_count: int = 0
    age_range: str | None = None
    is_banned: bool = False
    is_admin: bool = False
    created_at: datetime | None = None

    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserResponse


class UserUpdateRequest(BaseModel):
    nickname: str | None = Field(default=None, max_length=50)
    avatar_url: str | None = None


class UserProfileDetailResponse(BaseModel):
    user_id: str
    nickname: str
    avatar_url: str | None = None
    phone: str | None = None
    email: str | None = None
    signature: str | None = None
    gender: str | None = None
    birthday: str | None = None
    region: str | None = None


class UserProfileDetailUpdateRequest(BaseModel):
    nickname: str | None = Field(default=None, max_length=50)
    avatar_url: str | None = None
    phone: str | None = Field(default=None, pattern=r"^1\d{10}$")
    email: str | None = None
    signature: str | None = Field(default=None, max_length=120)
    gender: str | None = Field(default=None, max_length=20)
    birthday: str | None = Field(default=None, max_length=20)
    region: str | None = Field(default=None, max_length=60)
