from __future__ import annotations

import json
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.core.dependencies import check_daily_session_limit, get_current_user
from app.database import get_db
from app.models.message import MessageModel
from app.models.session import SessionModel
from app.models.target import TargetModel
from app.models.user import UserModel
from app.schemas.message import MessageResponse
from app.schemas.session import (
    SessionCreateRequest,
    SessionEndRequest,
    SessionResponse,
    SessionSummaryResponse,
)
from app.services.emotion_service import emotion_service

router = APIRouter(prefix="/api/sessions", tags=["sessions"])


def _session_to_response(session: SessionModel) -> SessionResponse:
    return SessionResponse(
        id=session.id,
        user_id=session.user_id,
        target_id=session.target_id,
        target_name=session.target.name if session.target else "",
        target_avatar_url=session.target.avatar_url if session.target else None,
        mode=session.mode,
        chat_style=session.chat_style,
        dialect=session.dialect,
        duration_minutes=session.duration_minutes,
        start_time=session.start_time,
        end_time=session.end_time,
        status=session.status,
        is_completed=session.is_completed,
        emotion_summary=session.emotion_summary,
        summary_text=session.summary_text,
        created_at=session.created_at,
    )


@router.post("", response_model=SessionResponse, status_code=status.HTTP_201_CREATED)
async def create_session(
    req: SessionCreateRequest,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    target_result = await db.execute(
        select(TargetModel).where(
            TargetModel.id == req.target_id,
            TargetModel.user_id == current_user.id,
            TargetModel.is_deleted == False,
        )
    )
    target = target_result.scalar_one_or_none()
    if target is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Target not found")

    if not await check_daily_session_limit(current_user):
        limit = settings.MAX_DAILY_SESSIONS_ADULT
        if current_user.is_visitor:
            limit = settings.MAX_DAILY_SESSIONS_VISITOR
        elif current_user.age_range == "<14":
            limit = settings.MAX_DAILY_SESSIONS_UNDER_14
        elif current_user.age_range == "14-18":
            limit = settings.MAX_DAILY_SESSIONS_14_TO_18
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=f"Daily session limit reached ({limit})",
        )

    today = datetime.now(timezone.utc).date().isoformat()
    current_user.daily_session_count += 1
    current_user.last_active_date = today
    db.add(current_user)

    session = SessionModel(
        user_id=current_user.id,
        target_id=req.target_id,
        mode=req.mode,
        chat_style=req.chat_style,
        dialect=req.dialect,
        duration_minutes=req.duration_minutes,
        status="active",
        start_time=datetime.now(timezone.utc),
    )
    db.add(session)
    await db.flush()
    await db.refresh(session)
    await db.refresh(session, ["target"])
    return _session_to_response(session)


@router.get("", response_model=list[SessionResponse])
async def list_sessions(
    page: int = 1,
    page_size: int = 20,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(SessionModel)
        .where(
            SessionModel.user_id == current_user.id,
            SessionModel.is_completed == True,
        )
        .order_by(SessionModel.created_at.desc())
        .offset((page - 1) * page_size)
        .limit(page_size)
    )
    sessions = result.scalars().all()
    return [_session_to_response(item) for item in sessions]


@router.get("/active", response_model=SessionResponse | None)
async def get_active_session(
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(SessionModel).where(
            SessionModel.user_id == current_user.id,
            SessionModel.status == "active",
        )
    )
    session = result.scalar_one_or_none()
    return _session_to_response(session) if session else None


@router.get("/{session_id}", response_model=SessionResponse)
async def get_session(
    session_id: str,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(SessionModel).where(
            SessionModel.id == session_id,
            SessionModel.user_id == current_user.id,
        )
    )
    session = result.scalar_one_or_none()
    if session is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Session not found")
    return _session_to_response(session)


@router.post("/{session_id}/end", response_model=SessionSummaryResponse)
async def end_session(
    session_id: str,
    req: SessionEndRequest = SessionEndRequest(),
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(SessionModel).where(
            SessionModel.id == session_id,
            SessionModel.user_id == current_user.id,
        )
    )
    session = result.scalar_one_or_none()
    if session is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Session not found")
    if session.is_completed:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Session already completed")

    session.status = "interrupted" if req.force else "completed"
    session.is_completed = True
    session.end_time = datetime.now(timezone.utc)
    db.add(session)

    msg_result = await db.execute(
        select(MessageModel)
        .where(MessageModel.session_id == session_id)
        .order_by(MessageModel.sequence.asc())
    )
    messages = msg_result.scalars().all()

    raw_messages = [
        {
            "content": item.content,
            "sender": item.sender,
            "emotion_type": item.emotion_type,
            "emotion_intensity": item.emotion_intensity,
        }
        for item in messages
    ]
    emotion_result = await emotion_service.analyze_messages(raw_messages)

    session.emotion_summary = json.dumps(
        {
            "primary_emotion": emotion_result.primary_emotion,
            "emotions": emotion_result.emotions,
            "intensity": emotion_result.intensity,
            "keywords": emotion_result.keywords,
            "summary": emotion_result.summary,
            "suggestion": emotion_result.suggestion,
        },
        ensure_ascii=False,
    )
    session.summary_text = emotion_result.summary
    db.add(session)

    await db.flush()
    await db.refresh(session)

    return SessionSummaryResponse(
        session=_session_to_response(session),
        messages=[MessageResponse.model_validate(item) for item in messages],
        emotion_analysis=emotion_result.model_dump(),
    )
