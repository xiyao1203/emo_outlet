"""后台管理 API 路由"""
from __future__ import annotations

from datetime import date, datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_admin_user
from app.database import get_db
from app.models.compliance import ContentAuditLog, ContentReport
from app.models.session import SessionModel
from app.models.user import UserModel
from app.schemas.user import UserResponse

router = APIRouter(prefix="/api/admin", tags=["后台管理"])


# ============================================================
# 用户管理
# ============================================================

@router.get("/users", response_model=dict)
async def list_users(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    is_banned: bool | None = Query(None),
    current_user: UserModel = Depends(get_admin_user),
    db: AsyncSession = Depends(get_db),
):
    """管理员查看用户列表"""
    query = select(UserModel)

    if is_banned is not None:
        query = query.where(UserModel.is_banned == is_banned)

    query = query.order_by(UserModel.created_at.desc())

    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar() or 0

    offset = (page - 1) * page_size
    result = await db.execute(query.offset(offset).limit(page_size))
    users = result.scalars().all()

    return {
        "users": [UserResponse.model_validate(u) for u in users],
        "total": total,
        "page": page,
        "page_size": page_size,
    }


@router.put("/users/{user_id}/ban", response_model=UserResponse)
async def ban_user(
    user_id: str,
    reason: str = Query(default="违反服务条款", description="封禁原因"),
    current_user: UserModel = Depends(get_admin_user),
    db: AsyncSession = Depends(get_db),
):
    """管理员封禁用户"""
    result = await db.execute(
        select(UserModel).where(UserModel.id == user_id)
    )
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="用户不存在")

    user.is_banned = True
    user.ban_reason = reason
    db.add(user)
    await db.flush()
    await db.refresh(user)
    return UserResponse.model_validate(user)


@router.put("/users/{user_id}/unban", response_model=UserResponse)
async def unban_user(
    user_id: str,
    current_user: UserModel = Depends(get_admin_user),
    db: AsyncSession = Depends(get_db),
):
    """管理员解封用户"""
    result = await db.execute(
        select(UserModel).where(UserModel.id == user_id)
    )
    user = result.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="用户不存在")

    user.is_banned = False
    user.ban_reason = None
    db.add(user)
    await db.flush()
    await db.refresh(user)
    return UserResponse.model_validate(user)


# ============================================================
# 审计日志
# ============================================================

@router.get("/audit-logs", response_model=dict)
async def list_audit_logs(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    risk_level: str | None = Query(None),
    current_user: UserModel = Depends(get_admin_user),
    db: AsyncSession = Depends(get_db),
):
    """管理员查看审计日志"""
    query = select(ContentAuditLog).order_by(ContentAuditLog.created_at.desc())

    if risk_level:
        query = query.where(ContentAuditLog.risk_level == risk_level)

    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar() or 0

    offset = (page - 1) * page_size
    result = await db.execute(query.offset(offset).limit(page_size))
    logs = result.scalars().all()

    return {
        "logs": [
            {
                "id": log.id,
                "user_id": log.user_id,
                "audit_type": log.audit_type,
                "risk_level": log.risk_level,
                "matched_keywords": log.matched_keywords,
                "action_taken": log.action_taken,
                "created_at": log.created_at.isoformat() if log.created_at else None,
            }
            for log in logs
        ],
        "total": total,
        "page": page,
        "page_size": page_size,
    }


# ============================================================
# 仪表盘统计
# ============================================================

@router.get("/dashboard", response_model=dict)
async def get_dashboard(
    current_user: UserModel = Depends(get_admin_user),
    db: AsyncSession = Depends(get_db),
):
    """管理员仪表盘统计"""
    today = date.today().isoformat()

    # 用户总数
    result = await db.execute(select(func.count(UserModel.id)))
    total_users = result.scalar() or 0

    # 今日活跃用户
    result = await db.execute(
        select(func.count(UserModel.id)).where(
            UserModel.last_active_date == today
        )
    )
    today_active = result.scalar() or 0

    # 今日会话数
    result = await db.execute(
        select(func.count(SessionModel.id)).where(
            func.date(SessionModel.created_at) == today
        )
    )
    today_sessions = result.scalar() or 0

    # 待处理举报数
    result = await db.execute(
        select(func.count(ContentReport.id)).where(
            ContentReport.status == "pending"
        )
    )
    pending_reports = result.scalar() or 0

    # 封禁用户数
    result = await db.execute(
        select(func.count(UserModel.id)).where(UserModel.is_banned == True)
    )
    banned_users = result.scalar() or 0

    return {
        "total_users": total_users,
        "today_active_users": today_active,
        "today_sessions": today_sessions,
        "pending_reports": pending_reports,
        "banned_users": banned_users,
        "date": today,
    }
