"""举报 API 路由"""
from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import func, select, delete
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_admin_user, get_current_user
from app.database import get_db
from app.models.compliance import ContentReport
from app.models.user import UserModel
from app.models.session import SessionModel
from app.schemas.report import (
    CreateReportRequest,
    ReportResponse,
    ReportListResponse,
    ResolveReportRequest,
)
import datetime

router = APIRouter(prefix="/api/reports", tags=["举报"])


@router.post("", response_model=ReportResponse, status_code=status.HTTP_201_CREATED)
async def create_report(
    req: CreateReportRequest,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """用户举报内容"""
    report = ContentReport(
        reporter_user_id=current_user.id,
        session_id=req.session_id,
        message_id=req.message_id,
        report_type=req.report_type,
        description=req.description,
        status="pending",
    )
    db.add(report)
    await db.flush()
    await db.refresh(report)
    return ReportResponse.model_validate(report)


@router.get("", response_model=ReportListResponse)
async def list_reports(
    page: int = Query(1, ge=1),
    page_size: int = Query(20, ge=1, le=100),
    status_filter: str | None = Query(None, alias="status"),
    current_user: UserModel = Depends(get_admin_user),
    db: AsyncSession = Depends(get_db),
):
    """管理员查看举报列表"""
    query = select(ContentReport).order_by(ContentReport.created_at.desc())

    if status_filter:
        query = query.where(ContentReport.status == status_filter)

    # 总数
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar() or 0

    # 分页
    offset = (page - 1) * page_size
    result = await db.execute(query.offset(offset).limit(page_size))
    reports = result.scalars().all()

    return ReportListResponse(
        reports=[ReportResponse.model_validate(r) for r in reports],
        total=total,
        page=page,
        page_size=page_size,
    )


@router.put("/{report_id}/resolve", response_model=ReportResponse)
async def resolve_report(
    report_id: str,
    req: ResolveReportRequest,
    current_user: UserModel = Depends(get_admin_user),
    db: AsyncSession = Depends(get_db),
):
    """管理员处理举报"""
    result = await db.execute(
        select(ContentReport).where(ContentReport.id == report_id)
    )
    report = result.scalar_one_or_none()
    if not report:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="举报不存在")

    report.status = "resolved" if req.action == "dismiss" else req.action
    report.resolved_at = datetime.datetime.now(datetime.timezone.utc)
    db.add(report)

    # 如果处理动作是 ban，封禁被举报用户
    if req.action == "ban" and report.session_id:
        session_result = await db.execute(
            select(SessionModel).where(SessionModel.id == report.session_id)
        )
        session = session_result.scalar_one_or_none()
        if session:
            user_result = await db.execute(
                select(UserModel).where(UserModel.id == session.user_id)
            )
            target_user = user_result.scalar_one_or_none()
            if target_user:
                target_user.is_banned = True
                target_user.ban_reason = f"举报违规: {report.report_type}"
                db.add(target_user)

    await db.flush()
    await db.refresh(report)
    return ReportResponse.model_validate(report)
