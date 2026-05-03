"""应用配置"""
from __future__ import annotations

import os
from datetime import timedelta
from pathlib import Path
from typing import ClassVar

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    # 应用基础
    APP_NAME: str = "情绪出口 API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True

    # 服务端口
    HOST: str = "0.0.0.0"
    PORT: int = 8000

    # MySQL 数据库
    DB_HOST: str = "localhost"
    DB_PORT: int = 3306
    DB_USER: str = "root"
    DB_PASSWORD: str = "root"
    DB_NAME: str = "emo_outlet"
    DATABASE_URL: str | None = None

    @property
    def db_url(self) -> str:
        if self.DATABASE_URL:
            return self.DATABASE_URL
        return (
            f"mysql+aiomysql://{self.DB_USER}:{self.DB_PASSWORD}"
            f"@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}?charset=utf8mb4"
        )

    # SQLite 用于开发（无需安装 MySQL）
    SQLITE_URL: str = "sqlite+aiosqlite:///./emo_outlet.db"

    # Redis
    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6379
    REDIS_DB: int = 0
    REDIS_URL: str | None = None

    @property
    def redis_url(self) -> str:
        if self.REDIS_URL:
            return self.REDIS_URL
        return f"redis://{self.REDIS_HOST}:{self.REDIS_PORT}/{self.REDIS_DB}"

    # JWT 认证
    SECRET_KEY: str = "emo-outlet-secret-key-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7  # 7 天

    @property
    def access_token_expire_delta(self) -> timedelta:
        return timedelta(minutes=self.ACCESS_TOKEN_EXPIRE_MINUTES)

    # AI 服务（LLM）
    LLM_PROVIDER: str = "openai"  # openai / deepseek / qwen / mock
    OPENAI_API_KEY: str = ""
    OPENAI_BASE_URL: str = "https://api.openai.com/v1"
    DEEPSEEK_API_KEY: str = ""
    DEEPSEEK_BASE_URL: str = "https://api.deepseek.com/v1"
    QWEN_API_KEY: str = ""
    QWEN_BASE_URL: str = "https://dashscope.aliyuncs.com/compatible-mode/v1"

    # AI 模型
    LLM_MODEL: str = "gpt-4o-mini"
    IMAGE_MODEL: str = "dall-e-3"
    IMAGE_SIZE: str = "1024x1024"

    # ASR / TTS
    ASR_PROVIDER: str = "mock"  # mock / xunfei / aliyun / whisper
    TTS_PROVIDER: str = "mock"

    # 阿里云 OSS
    OSS_ENABLED: bool = False
    OSS_ACCESS_KEY: str = ""
    OSS_SECRET_KEY: str = ""
    OSS_BUCKET: str = ""
    OSS_ENDPOINT: str = ""

    # 安全设置
    MAX_MESSAGE_LENGTH: int = 5000
    MAX_SESSION_DURATION_MINUTES: int = 10
    MAX_DAILY_FREE_SESSIONS: int = 3
    SENSITIVE_WORD_FILE: str = ""

    # 方言词库路径
    DIALECT_DATA_DIR: str = ""

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True


settings = Settings()

# 项目根目录
BASE_DIR = Path(__file__).resolve().parent.parent.parent
