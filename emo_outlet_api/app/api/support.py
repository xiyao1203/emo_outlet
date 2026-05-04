from __future__ import annotations

import json

from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user
from app.database import get_db
from app.models.support import SupportFeedbackModel
from app.models.user import UserModel
from app.schemas.support import (
    SupportFeedbackCreateRequest,
    SupportFeedbackResponse,
    SupportOverviewResponse,
)

router = APIRouter(prefix="/api/support", tags=["support"])


@router.get("/overview", response_model=SupportOverviewResponse)
async def get_support_overview(
    current_user: UserModel = Depends(get_current_user),
):
    return SupportOverviewResponse(
        online_status="online",
        service_hours="周一至周日 09:00 - 21:00",
        email="support@emo-outlet.local",
        community_name="Emo Outlet 用户社群",
        common_entries=[
            {"title": "常见问题", "subtitle": "解答你最关心的问题"},
            {"title": "使用教程", "subtitle": "快速上手，轻松使用"},
            {"title": "问题反馈", "subtitle": "告诉我们你遇到的问题"},
            {"title": "联系客服", "subtitle": "专业客服为你服务"},
        ],
        preview_messages=[
            {"role": "assistant", "content": "你好呀，我是小心管家，很高兴为你服务！"},
            {"role": "user", "content": "我想咨询一下情绪记录的问题。"},
            {"role": "assistant", "content": "没问题呢，请告诉我你遇到的具体情况，我会尽力帮助你～"},
        ],
    )


@router.post(
    "/feedback",
    response_model=SupportFeedbackResponse,
    status_code=status.HTTP_201_CREATED,
)
async def submit_feedback(
    req: SupportFeedbackCreateRequest,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    feedback = SupportFeedbackModel(
        user_id=current_user.id,
        content=req.content,
        image_urls=json.dumps(req.image_urls, ensure_ascii=False),
        source=req.source,
        status="submitted",
    )
    db.add(feedback)
    await db.flush()
    await db.refresh(feedback)

    return SupportFeedbackResponse(
        id=feedback.id,
        status=feedback.status,
        message="反馈已提交，我们会尽快与你联系",
        created_at=feedback.created_at,
    )
