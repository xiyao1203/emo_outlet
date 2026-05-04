from __future__ import annotations

from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker, create_async_engine
from sqlalchemy.orm import DeclarativeBase

from app.config import settings

database_url = settings.db_url if settings.DATABASE_URL else settings.SQLITE_URL

engine = create_async_engine(database_url, echo=settings.DEBUG, future=True)
async_session_factory = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False,
)


class Base(DeclarativeBase):
    pass


async def get_db() -> AsyncSession:  # type: ignore
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
    async with engine.begin() as conn:
        from app.models import compliance, message, poster, session, support, target, user  # noqa: F401

        await conn.run_sync(Base.metadata.create_all)


async def close_db():
    await engine.dispose()
