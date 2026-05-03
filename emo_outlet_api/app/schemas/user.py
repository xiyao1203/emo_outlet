"""用户相关 Pydantic Schema"""
from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, Field


class UserRegisterRequest(BaseModel):
    """用户注册请求"""
    nickname: str = Field(default="", max_length=50, description="昵称")
    phone: str | None = Field(default=None, pattern=r"^1\d{10}$", description="手机号")
    email: str | None = Field(default=None, description="邮箱")
    password: str = Field(..., min_length=6, max_length=50, description="密码")
    device_uuid: str | None = Field(default=None, description="设备 UUID")
    consent_version: str | None = Field(
        default=None, description="用户同意的协议版本号"
    )
    age_range: str | None = Field(
        default=None, description="年龄段: <14 / 14-18 / >18"
    )


class UserLoginRequest(BaseModel):
    """用户登录请求"""
    account: str = Field(..., description="手机号或邮箱")
    password: str = Field(..., description="密码")


class VisitorLoginRequest(BaseModel):
    """游客登录请求"""
    device_uuid: str = Field(..., description="设备 UUID")
    nickname: str = Field(default="匿名用户", max_length=50, description="昵称")


class TokenResponse(BaseModel):
    """令牌响应"""
    access_token: str
    token_type: str = "bearer"
    user: "UserResponse"


class UserResponse(BaseModel):
    """用户信息响应"""
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


class UserUpdateRequest(BaseModel):
    """用户信息更新请求"""
    nickname: str | None = Field(default=None, max_length=50)
    avatar_url: str | None = None
