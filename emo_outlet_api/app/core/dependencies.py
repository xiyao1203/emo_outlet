from __future__ import annotations

from datetime import date

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.core.security import decode_access_token
from app.database import get_db
from app.models.user import UserModel

security_scheme = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(security_scheme),
    db: AsyncSession = Depends(get_db),
) -> UserModel:
    if credentials is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="未提供认证令牌")

    payload = decode_access_token(credentials.credentials)
    if payload is None or payload.get("sub") is None:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="令牌无效或已过期")

    result = await db.execute(
        select(UserModel).where(
            UserModel.id == payload["sub"],
            UserModel.is_deleted == False,
        )
    )
    user = result.scalar_one_or_none()
    if user is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="用户不存在")

    if user.is_banned:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"账号已被封禁: {user.ban_reason or '违反服务条款'}",
        )

    today = date.today().isoformat()
    if user.last_active_date != today:
        user.daily_session_count = 0
        user.last_active_date = today

    return user


async def check_daily_session_limit(user: UserModel) -> bool:
    today = date.today().isoformat()
    if user.last_active_date != today:
        user.daily_session_count = 0
        user.last_active_date = today
        return True

    if user.is_visitor:
        return user.daily_session_count < settings.MAX_DAILY_SESSIONS_VISITOR
    if user.age_range == "<14":
        return user.daily_session_count < settings.MAX_DAILY_SESSIONS_UNDER_14
    if user.age_range == "14-18":
        return user.daily_session_count < settings.MAX_DAILY_SESSIONS_14_TO_18
    return user.daily_session_count < settings.MAX_DAILY_SESSIONS_ADULT
