"""数据库配置与连接"""
from __future__ import annotations

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from app.config import settings

# 判断使用 MySQL 还是 SQLite
if settings.DATABASE_URL:
    database_url = settings.db_url
else:
    database_url = settings.SQLITE_URL

engine = create_async_engine(database_url, echo=settings.DEBUG, future=True)

async_session_factory = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)


class Base(DeclarativeBase):
    pass


async def get_db() -> AsyncSession:  # type: ignore
    """获取数据库会话的依赖注入"""
    async with async_session_factory() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


async def init_db():
    """创建所有表"""
    async with engine.begin() as conn:
        from app.models import user, target, session, message, poster  # noqa: F401
        await conn.run_sync(Base.metadata.create_all)


async def close_db():
    """关闭数据库连接"""
    await engine.dispose()
