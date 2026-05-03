"""通用 Schema"""
from __future__ import annotations

from pydantic import BaseModel


class ApiResponse(BaseModel):
    """通用 API 响应"""
    code: int = 200
    message: str = "success"
    data: dict | list | None = None


class PaginationParams(BaseModel):
    """分页参数"""
    page: int = 1
    page_size: int = 20


class ErrorResponse(BaseModel):
    """错误响应"""
    detail: str
    error_code: str | None = None
