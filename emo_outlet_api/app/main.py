"""情绪出口 API - 主入口"""
from __future__ import annotations

from contextlib import asynccontextmanager
import time

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.database import close_db, init_db
from app.core.error_handler import register_exception_handlers

# ============================================================
# 应用生命周期
# ============================================================

@asynccontextmanager
async def lifespan(app: FastAPI):
    """应用启动/关闭事件"""
    # 启动时：初始化数据库
    await init_db()
    print(f"✅ {settings.APP_NAME} v{settings.APP_VERSION} 已启动")
    print(f"📍 文档地址: http://{settings.HOST}:{settings.PORT}/docs")
    yield
    # 关闭时：清理资源
    await close_db()
    print("👋 应用已关闭")


# ============================================================
# 创建应用
# ============================================================

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="情绪出口（Emo Outlet）后端 API\n\n"
    "基于 AI 的安全情绪释放工具后端服务\n\n"
    "## 功能模块\n"
    "- 用户系统：注册/登录/游客/注销\n"
    "- 泄愤对象：CRUD + AI 生成形象\n"
    "- 会话管理：创建/结束/情绪分析\n"
    "- 实时对话：单向/双向 + 方言 + 多风格\n"
    "- 情绪分析：关键词 + 情绪分布 + 建议\n"
    "- 海报生成：情绪可视化海报\n"
    "- 情绪报告：周/月/年度统计\n"
    "- 安全过滤：敏感词 + 高风险中断",
    lifespan=lifespan,
)

# 注册全局异常处理器
register_exception_handlers(app)


# 请求日志中间件
@app.middleware("http")
async def log_requests(request: Request, call_next):
    """记录每个请求的方法、路径、耗时"""
    start = time.time()
    response = await call_next(request)
    elapsed = time.time() - start
    print(f"  {request.method} {request.url.path} -> {response.status_code} ({elapsed:.3f}s)")
    return response


# CORS 配置（允许 Flutter 客户端跨域）
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 生产环境应限制具体域名
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# 注册路由
# ============================================================

from app.api.auth import router as auth_router
from app.api.targets import router as targets_router
from app.api.sessions import router as sessions_router
from app.api.messages import router as messages_router
from app.api.posters import router as posters_router
from app.api.reports import router as reports_router
from app.api.admin import router as admin_router

app.include_router(auth_router)
app.include_router(targets_router)
app.include_router(sessions_router)
app.include_router(messages_router)
app.include_router(posters_router)
app.include_router(reports_router)
app.include_router(admin_router)


# ============================================================
# 健康检查
# ============================================================

@app.get("/health")
async def health_check():
    """健康检查接口"""
    return {
        "status": "ok",
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
    }


@app.get("/")
async def root():
    """根路径"""
    return {
        "message": "情绪出口 API",
        "docs": "/docs",
        "health": "/health",
    }
