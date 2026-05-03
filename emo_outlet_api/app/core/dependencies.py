"""依赖注入"""
from __future__ import annotations

from datetime import date, datetime, timezone

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import decode_access_token
from app.database import get_db
from app.models.user import UserModel
from app.models.session import SessionModel
from app.config import settings

security_scheme = HTTPBearer(auto_error=False)


async def get_current_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(security_scheme),
    db: AsyncSession = Depends(get_db),
) -> UserModel:
    """获取当前登录用户（依赖注入）"""
    if credentials is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="未提供认证令牌",
        )

    payload = decode_access_token(credentials.credentials)
    if payload is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="令牌无效或已过期",
        )

    user_id = payload.get("sub")
    if user_id is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="令牌中缺少用户信息",
        )

    result = await db.execute(
        select(UserModel).where(
            UserModel.id == user_id,
            UserModel.is_deleted == False,
        )
    )
    user = result.scalar_one_or_none()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="用户不存在",
        )

    if user.is_banned:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"账号已被封禁: {user.ban_reason or '违反服务条款'}",
        )

    # 防沉迷检查：重置每日计数（如果日期变了）
    today = date.today().isoformat()
    if user.last_active_date != today:
        user.daily_session_count = 0
        user.last_active_date = today

    return user


async def check_daily_session_limit(user: UserModel) -> bool:
    """检查用户是否达到每日会话上限
    返回 True 表示可以继续，False 表示已达上限
    """
    today = date.today().isoformat()
    if user.last_active_date != today:
        # 新的一天，重置计数
        user.daily_session_count = 0
        user.last_active_date = today
        return True

    if user.is_visitor:
        return user.daily_session_count < settings.MAX_DAILY_SESSIONS_VISITOR
    elif user.age_range == "<14":
        return user.daily_session_count < settings.MAX_DAILY_SESSIONS_UNDER_14
    elif user.age_range == "14-18":
        return user.daily_session_count < settings.MAX_DAILY_SESSIONS_14_TO_18
    else:
        return user.daily_session_count < settings.MAX_DAILY_SESSIONS_ADULT


async def get_admin_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(security_scheme),
    db: AsyncSession = Depends(get_db),
) -> UserModel:
    """管理员权限依赖注入"""
    user = await get_current_user(credentials, db)
    if not user.is_admin:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="需要管理员权限",
        )
    return user


async def get_optional_user(
    credentials: HTTPAuthorizationCredentials | None = Depends(security_scheme),
    db: AsyncSession = Depends(get_db),
) -> UserModel | None:
    """可选地获取当前用户（未登录返回 None）"""
    if credentials is None:
        return None

    payload = decode_access_token(credentials.credentials)
    if payload is None:
        return None

    user_id = payload.get("sub")
    if user_id is None:
        return None

    result = await db.execute(
        select(UserModel).where(
            UserModel.id == user_id,
            UserModel.is_deleted == False,
        )
    )
    return result.scalar_one_or_none()
