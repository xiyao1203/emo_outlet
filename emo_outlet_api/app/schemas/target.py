"""泄愤对象相关 Pydantic Schema"""
from __future__ import annotations

from datetime import datetime

from pydantic import BaseModel, Field


class TargetCreateRequest(BaseModel):
    """创建泄愤对象请求"""
    name: str = Field(..., max_length=100, description="对象名称")
    type: str = Field(default="custom", description="类型")
    appearance: str | None = Field(default=None, description="外貌描述")
    personality: str | None = Field(default=None, description="性格特征")
    relationship: str | None = Field(default=None, max_length=100, description="关系")
    style: str = Field(default="漫画", description="形象风格")


class TargetUpdateRequest(BaseModel):
    """更新泄愤对象请求"""
    name: str | None = Field(default=None, max_length=100)
    type: str | None = None
    appearance: str | None = None
    personality: str | None = None
    relationship: str | None = None
    style: str | None = None
    is_hidden: bool | None = None


class TargetResponse(BaseModel):
    """泄愤对象响应"""
    id: str
    user_id: str
    name: str
    type: str
    appearance: str | None = None
    personality: str | None = None
    relationship: str | None = Field(
        default=None, validation_alias="relation", description="关系"
    )
    style: str
    avatar_url: str | None = None
    is_hidden: bool = False
    created_at: datetime | None = None
    updated_at: datetime | None = None

    class Config:
        from_attributes = True
        populate_by_name = True


class TargetAiCompleteRequest(BaseModel):
    """AI 补全对象请求"""
    name: str = Field(..., max_length=100, description="对象名称")
    relationship: str = Field(..., max_length=100, description="关系")


class TargetAiCompleteResponse(BaseModel):
    """AI 补全对象响应"""
    appearance: str
    personality: str
    style: str
