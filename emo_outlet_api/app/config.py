"""应用配置。"""
from __future__ import annotations

import os
from datetime import timedelta
from pathlib import Path

from pydantic_settings import BaseSettings, PydanticBaseSettingsSource, SettingsConfigDict

API_BASE_DIR = Path(__file__).resolve().parent.parent
ENV_FILE_PATH = Path(
    os.getenv("EMO_OUTLET_ENV_FILE", str(API_BASE_DIR / ".env"))
).resolve()


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=str(ENV_FILE_PATH),
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",
    )

    APP_NAME: str = "情绪释放 API"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = True

    HOST: str = "0.0.0.0"
    PORT: int = 8000

    DB_HOST: str = "localhost"
    DB_PORT: int = 3306
    DB_USER: str = "root"
    DB_PASSWORD: str = "root"
    DB_NAME: str = "emo_outlet"
    DATABASE_URL: str | None = None

    SQLITE_URL: str = "sqlite+aiosqlite:///./emo_outlet.db"

    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6379
    REDIS_DB: int = 0
    REDIS_URL: str | None = None

    SECRET_KEY: str = "emo-outlet-secret-key-change-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 * 7

    LLM_PROVIDER: str = "openai"
    OPENAI_API_KEY: str = ""
    OPENAI_BASE_URL: str = "https://api.openai.com/v1"
    DEEPSEEK_API_KEY: str = ""
    DEEPSEEK_BASE_URL: str = "https://api.deepseek.com/v1"
    QWEN_API_KEY: str = ""
    QWEN_BASE_URL: str = "https://dashscope.aliyuncs.com/compatible-mode/v1"

    LLM_MODEL: str = "gpt-4o-mini"
    IMAGE_MODEL: str = "dall-e-3"
    IMAGE_SIZE: str = "1024x1024"

    ASR_PROVIDER: str = "mock"
    TTS_PROVIDER: str = "mock"

    OSS_ENABLED: bool = False
    OSS_ACCESS_KEY: str = ""
    OSS_SECRET_KEY: str = ""
    OSS_BUCKET: str = ""
    OSS_ENDPOINT: str = ""

    MAX_MESSAGE_LENGTH: int = 5000
    MAX_SESSION_DURATION_MINUTES: int = 10
    MAX_DAILY_FREE_SESSIONS: int = 3
    SENSITIVE_WORD_FILE: str = ""

    COMPLIANCE_VERSION: str = "1.0.0"
    MAX_DAILY_SESSIONS_UNDER_14: int = 1
    MAX_DAILY_SESSIONS_14_TO_18: int = 2
    MAX_DAILY_SESSIONS_ADULT: int = 3
    MAX_DAILY_SESSIONS_VISITOR: int = 1

    MAX_CONVERSATION_TURNS: int = 50
    MAX_CONVERSATION_TURNS_UNDER_14: int = 10
    MAX_CONVERSATION_TURNS_14_TO_18: int = 25

    ENABLE_AUDIT_LOG: bool = True
    AUDIT_LOG_SAMPLE_RATE: float = 1.0
    DIALECT_DATA_DIR: str = ""

    @classmethod
    def settings_customise_sources(
        cls,
        settings_cls: type[BaseSettings],
        init_settings: PydanticBaseSettingsSource,
        env_settings: PydanticBaseSettingsSource,
        dotenv_settings: PydanticBaseSettingsSource,
        file_secret_settings: PydanticBaseSettingsSource,
    ) -> tuple[PydanticBaseSettingsSource, ...]:
        return (
            init_settings,
            dotenv_settings,
            env_settings,
            file_secret_settings,
        )

    @property
    def db_url(self) -> str:
        if self.DATABASE_URL:
            return self.DATABASE_URL
        return (
            f"mysql+aiomysql://{self.DB_USER}:{self.DB_PASSWORD}"
            f"@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}?charset=utf8mb4"
        )

    @property
    def redis_url(self) -> str:
        if self.REDIS_URL:
            return self.REDIS_URL
        return f"redis://{self.REDIS_HOST}:{self.REDIS_PORT}/{self.REDIS_DB}"

    @property
    def access_token_expire_delta(self) -> timedelta:
        return timedelta(minutes=self.ACCESS_TOKEN_EXPIRE_MINUTES)


settings = Settings()
BASE_DIR = Path(__file__).resolve().parent.parent.parent
