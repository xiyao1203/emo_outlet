from __future__ import annotations

import json

from fastapi import APIRouter, Depends, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user
from app.database import get_db
from app.models.support import SupportFeedbackModel, UserPreferenceModel
from app.models.user import UserModel
from app.schemas.support import (
    SupportFeedbackCreateRequest,
    SupportFeedbackResponse,
    SupportOverviewResponse,
    UserPreferenceResponse,
    UserPreferenceUpdateRequest,
)

router = APIRouter(prefix="/api/support", tags=["support"])


async def _get_or_create_preferences(
    user_id: str,
    db: AsyncSession,
) -> UserPreferenceModel:
    result = await db.execute(
        select(UserPreferenceModel).where(UserPreferenceModel.user_id == user_id)
    )
    preference = result.scalar_one_or_none()
    if preference is None:
        preference = UserPreferenceModel(user_id=user_id)
        db.add(preference)
        await db.flush()
        await db.refresh(preference)
    return preference


def _preference_response(preference: UserPreferenceModel) -> UserPreferenceResponse:
    return UserPreferenceResponse(
        save_history=preference.save_history,
        allow_posters=preference.allow_posters,
        private_only=preference.private_only,
        auto_clear_session=preference.auto_clear_session,
        session_reminder=preference.session_reminder,
        report_reminder=preference.report_reminder,
        poster_reminder=preference.poster_reminder,
        activity_notification=preference.activity_notification,
        system_notification=preference.system_notification,
        dialect=preference.dialect,
        wechat_bound=preference.wechat_bound,
    )


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
            {"title": "常见问题", "subtitle": "快速找到最常被问到的答案"},
            {"title": "使用教程", "subtitle": "从第一次使用到进阶操作都能查到"},
            {"title": "问题反馈", "subtitle": "把你遇到的问题直接告诉我们"},
            {"title": "联系客服", "subtitle": "需要人工协助时可以从这里进入"},
        ],
        preview_messages=[
            {"role": "assistant", "content": "你好呀，我是小心管家，很高兴为你服务。"},
            {"role": "user", "content": "我想咨询一下情绪记录相关的问题。"},
            {"role": "assistant", "content": "没问题，你告诉我具体情况，我来帮你一起梳理。"},
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
        message="反馈已提交，我们会尽快联系你。",
        created_at=feedback.created_at,
    )


@router.get("/preferences", response_model=UserPreferenceResponse)
async def get_preferences(
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    preference = await _get_or_create_preferences(current_user.id, db)
    return _preference_response(preference)


@router.put("/preferences", response_model=UserPreferenceResponse)
async def update_preferences(
    req: UserPreferenceUpdateRequest,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    preference = await _get_or_create_preferences(current_user.id, db)
    for field in req.model_fields:
        value = getattr(req, field)
        if value is not None:
            setattr(preference, field, value)
    db.add(preference)
    await db.flush()
    await db.refresh(preference)
    return _preference_response(preference)
