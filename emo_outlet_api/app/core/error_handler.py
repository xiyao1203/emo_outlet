"""全局异常处理器"""
from __future__ import annotations

from fastapi import Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException


async def global_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """捕获所有未处理的异常，返回统一格式的错误响应"""
    return JSONResponse(
        status_code=500,
        content={
            "detail": "服务器内部错误",
            "code": "INTERNAL_ERROR",
        },
    )


async def http_exception_handler(
    request: Request, exc: StarletteHTTPException
) -> JSONResponse:
    """HTTP 异常（如 404/403/401）"""
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "detail": exc.detail,
            "code": f"HTTP_{exc.status_code}",
        },
    )


async def validation_exception_handler(
    request: Request, exc: RequestValidationError
) -> JSONResponse:
    """请求参数校验失败"""
    errors = []
    for error in exc.errors():
        field = ".".join(str(loc) for loc in error.get("loc", []))
        msg = error.get("msg", "无效参数")
        errors.append({"field": field, "message": msg})

    return JSONResponse(
        status_code=422,
        content={
            "detail": "请求参数校验失败",
            "code": "VALIDATION_ERROR",
            "errors": errors,
        },
    )


def register_exception_handlers(app):
    """注册所有异常处理器到 FastAPI 应用"""
    app.add_exception_handler(Exception, global_exception_handler)
    app.add_exception_handler(StarletteHTTPException, http_exception_handler)
    app.add_exception_handler(RequestValidationError, validation_exception_handler)
