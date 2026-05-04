from __future__ import annotations

import time
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.core.error_handler import register_exception_handlers
from app.database import close_db, init_db


@asynccontextmanager
async def lifespan(app: FastAPI):
    await init_db()
    print(f"{settings.APP_NAME} v{settings.APP_VERSION} started")
    yield
    await close_db()
    print("Application stopped")


app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="Emo Outlet backend API",
    lifespan=lifespan,
)

register_exception_handlers(app)


@app.middleware("http")
async def log_requests(request: Request, call_next):
    started = time.time()
    response = await call_next(request)
    elapsed = time.time() - started
    print(f"{request.method} {request.url.path} -> {response.status_code} ({elapsed:.3f}s)")
    return response


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


from app.api.auth import router as auth_router
from app.api.messages import router as messages_router
from app.api.posters import router as posters_router
from app.api.sessions import router as sessions_router
from app.api.support import router as support_router
from app.api.targets import router as targets_router

app.include_router(auth_router)
app.include_router(targets_router)
app.include_router(sessions_router)
app.include_router(messages_router)
app.include_router(posters_router)
app.include_router(support_router)


@app.get("/health")
async def health_check():
    return {
        "status": "ok",
        "app": settings.APP_NAME,
        "version": settings.APP_VERSION,
    }


@app.get("/")
async def root():
    return {
        "message": "Emo Outlet API",
        "docs": "/docs",
        "health": "/health",
    }
