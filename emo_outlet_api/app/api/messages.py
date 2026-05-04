from __future__ import annotations

from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.config import settings
from app.core.dependencies import get_current_user
from app.database import get_db
from app.models.compliance import ContentAuditLog
from app.models.message import MessageModel
from app.models.session import SessionModel
from app.models.user import UserModel
from app.schemas.message import MessageListResponse, MessageResponse, MessageSendRequest
from app.services.ai_service import ai_service
from app.services.emotion_service import emotion_service
from app.utils.sensitive_filter import sensitive_filter

router = APIRouter(prefix="/api/sessions", tags=["messages"])


def _as_utc(value: datetime | None) -> datetime | None:
    if value is None:
        return None
    if value.tzinfo is None:
        return value.replace(tzinfo=timezone.utc)
    return value.astimezone(timezone.utc)


@router.get("/{session_id}/messages", response_model=MessageListResponse)
async def get_messages(
    session_id: str,
    page: int = 1,
    page_size: int = 50,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    session = await _get_owned_session(db, session_id, current_user.id)

    count_result = await db.execute(
        select(func.count(MessageModel.id)).where(MessageModel.session_id == session_id)
    )
    total = count_result.scalar() or 0

    msg_result = await db.execute(
        select(MessageModel)
        .where(MessageModel.session_id == session_id)
        .order_by(MessageModel.sequence.asc())
        .offset((page - 1) * page_size)
        .limit(page_size)
    )
    messages = msg_result.scalars().all()

    remaining = 0
    if session.status == "active" and session.start_time:
        elapsed = (datetime.now(timezone.utc) - _as_utc(session.start_time)).total_seconds()
        remaining = max(0, int(session.duration_minutes * 60 - elapsed))

    return MessageListResponse(
        messages=[MessageResponse.model_validate(item) for item in messages],
        total=total,
        session_status=session.status,
        remaining_seconds=remaining,
    )


@router.post("/{session_id}/messages", response_model=MessageResponse, status_code=status.HTTP_201_CREATED)
async def send_message(
    session_id: str,
    req: MessageSendRequest,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    session = await _get_owned_session(db, session_id, current_user.id)
    if session.is_completed:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Session already completed")

    sensitive_result = sensitive_filter.check(req.content)
    sequence = await _get_next_sequence(db, session_id)
    message_emotion = await emotion_service.analyze_messages([{"sender": "user", "content": req.content}])

    user_msg = MessageModel(
        session_id=session_id,
        content=req.content,
        sender="user",
        dialect=session.dialect,
        emotion_type=message_emotion.primary_emotion,
        emotion_intensity=message_emotion.intensity,
        is_sensitive=sensitive_result["has_sensitive"],
        sequence=sequence,
    )
    db.add(user_msg)

    if sensitive_result["has_sensitive"] and settings.ENABLE_AUDIT_LOG:
        db.add(
            ContentAuditLog(
                user_id=current_user.id,
                session_id=session_id,
                audit_type="user_input",
                risk_level="high" if sensitive_result["has_high_risk"] else "medium",
                matched_keywords=",".join(sensitive_result["matched_words"]),
                original_content=req.content[:500],
                action_taken="interrupted" if sensitive_result["has_high_risk"] else "observed",
            )
        )

    if sensitive_result["has_high_risk"]:
        session.status = "interrupted"
        session.is_completed = True
        db.add(session)

        ai_msg = MessageModel(
            session_id=session_id,
            content=sensitive_filter.get_high_risk_response(),
            sender="ai",
            dialect=session.dialect,
            emotion_type="平静",
            emotion_intensity=20,
            sequence=sequence + 1,
        )
        db.add(ai_msg)
        await db.flush()
        await db.refresh(ai_msg)
        return MessageResponse.model_validate(ai_msg)

    history_result = await db.execute(
        select(MessageModel)
        .where(
            MessageModel.session_id == session_id,
            MessageModel.sender != "system",
        )
        .order_by(MessageModel.sequence.asc())
        .limit(24)
    )
    history_messages = history_result.scalars().all()
    history = [{"sender": item.sender, "content": item.content} for item in history_messages]

    max_turns = settings.MAX_CONVERSATION_TURNS
    if current_user.age_range == "<14":
        max_turns = settings.MAX_CONVERSATION_TURNS_UNDER_14
    elif current_user.age_range == "14-18":
        max_turns = settings.MAX_CONVERSATION_TURNS_14_TO_18

    if len([item for item in history if item["sender"] == "user"]) >= max_turns:
        session.status = "completed"
        session.is_completed = True
        db.add(session)

        ai_msg = MessageModel(
            session_id=session_id,
            content="这次对话已经到达上限了，先休息一下。准备好了再开始下一次也可以。",
            sender="ai",
            dialect=session.dialect,
            emotion_type="平静",
            emotion_intensity=25,
            sequence=sequence + 1,
        )
        db.add(ai_msg)
        await db.flush()
        await db.refresh(ai_msg)
        return MessageResponse.model_validate(ai_msg)

    ai_content = await ai_service.chat(
        user_message=req.content,
        mode=session.mode,
        chat_style=session.chat_style or "apologetic",
        dialect=session.dialect,
        history=history,
        age_range=current_user.age_range,
    )
    ai_emotion = await emotion_service.analyze_messages([{"sender": "user", "content": ai_content}])

    ai_msg = MessageModel(
        session_id=session_id,
        content=ai_content,
        sender="ai",
        dialect=session.dialect,
        emotion_type=ai_emotion.primary_emotion,
        emotion_intensity=ai_emotion.intensity,
        sequence=sequence + 1,
    )
    db.add(ai_msg)

    if session.start_time:
        elapsed = (datetime.now(timezone.utc) - _as_utc(session.start_time)).total_seconds()
        if elapsed >= session.duration_minutes * 60:
            session.status = "completed"
            session.is_completed = True
            db.add(session)

    await db.flush()
    await db.refresh(ai_msg)
    return MessageResponse.model_validate(ai_msg)


async def _get_owned_session(db: AsyncSession, session_id: str, user_id: str) -> SessionModel:
    result = await db.execute(
        select(SessionModel).where(
            SessionModel.id == session_id,
            SessionModel.user_id == user_id,
        )
    )
    session = result.scalar_one_or_none()
    if session is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Session not found")
    return session


async def _get_next_sequence(db: AsyncSession, session_id: str) -> int:
    result = await db.execute(
        select(func.max(MessageModel.sequence)).where(MessageModel.session_id == session_id)
    )
    return (result.scalar() or 0) + 1
