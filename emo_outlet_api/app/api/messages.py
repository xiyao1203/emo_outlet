"""消息 API 路由"""
from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user
from app.database import get_db
from app.models.message import MessageModel
from app.models.session import SessionModel
from app.models.user import UserModel
from app.schemas.message import (
    MessageListResponse,
    MessageResponse,
    MessageSendRequest,
)
from app.services.ai_service import ai_service
from app.utils.sensitive_filter import sensitive_filter

router = APIRouter(prefix="/api/sessions", tags=["消息"])


@router.get("/{session_id}/messages", response_model=MessageListResponse)
async def get_messages(
    session_id: str,
    page: int = 1,
    page_size: int = 50,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """获取会话消息列表"""
    # 验证会话归属
    result = await db.execute(
        select(SessionModel).where(
            SessionModel.id == session_id,
            SessionModel.user_id == current_user.id,
        )
    )
    session = result.scalar_one_or_none()
    if not session:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="会话不存在")

    # 获取消息总数
    count_result = await db.execute(
        select(func.count(MessageModel.id)).where(
            MessageModel.session_id == session_id
        )
    )
    total = count_result.scalar() or 0

    # 获取消息
    msg_result = await db.execute(
        select(MessageModel)
        .where(MessageModel.session_id == session_id)
        .order_by(MessageModel.sequence)
        .offset((page - 1) * page_size)
        .limit(page_size)
    )
    messages = msg_result.scalars().all()

    # 计算剩余时间
    remaining = 0
    if session.status == "active" and session.start_time:
        import datetime

        elapsed = (datetime.datetime.now(datetime.timezone.utc) - session.start_time).total_seconds()
        remaining = max(0, int(session.duration_minutes * 60 - elapsed))

    return MessageListResponse(
        messages=[MessageResponse.model_validate(m) for m in messages],
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
    """发送消息（用户 → AI）"""
    # 验证会话
    result = await db.execute(
        select(SessionModel).where(
            SessionModel.id == session_id,
            SessionModel.user_id == current_user.id,
        )
    )
    session = result.scalar_one_or_none()
    if not session:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="会话不存在")

    if session.is_completed:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="会话已结束")

    # 敏感词检查
    sensitive_result = sensitive_filter.check(req.content)
    is_sensitive = sensitive_result["has_sensitive"]

    if sensitive_result["has_high_risk"]:
        # 高风险：中断对话
        session.status = "interrupted"
        session.is_completed = True
        db.add(session)

        risk_response = sensitive_filter.get_high_risk_response()
        msg = MessageModel(
            session_id=session_id,
            content=req.content,
            sender="user",
            dialect=session.dialect,
            is_sensitive=True,
            sequence=await _get_next_sequence(db, session_id),
        )
        db.add(msg)

        ai_msg = MessageModel(
            session_id=session_id,
            content=risk_response,
            sender="ai",
            dialect=session.dialect,
            sequence=await _get_next_sequence(db, session_id),
        )
        db.add(ai_msg)
        await db.flush()

        return MessageResponse.model_validate(ai_msg)

    # 获取消息序号
    sequence = await _get_next_sequence(db, session_id)

    # 保存用户消息
    user_msg = MessageModel(
        session_id=session_id,
        content=req.content,
        sender="user",
        dialect=session.dialect,
        is_sensitive=is_sensitive,
        sequence=sequence,
    )
    db.add(user_msg)

    # 获取历史消息作为上下文
    history_result = await db.execute(
        select(MessageModel)
        .where(
            MessageModel.session_id == session_id,
            MessageModel.sender != "system",
        )
        .order_by(MessageModel.sequence)
        .limit(20)
    )
    history_messages = history_result.scalars().all()
    history = [
        {"sender": m.sender, "content": m.content} for m in history_messages
    ]

    # 调用 AI 回复
    ai_content = await ai_service.chat(
        user_message=req.content,
        mode=session.mode,
        chat_style=session.chat_style or "apologetic",
        dialect=session.dialect,
        history=history,
    )

    # 保存 AI 消息
    ai_msg = MessageModel(
        session_id=session_id,
        content=ai_content,
        sender="ai",
        dialect=session.dialect,
        sequence=sequence + 1,
    )
    db.add(ai_msg)
    await db.flush()
    await db.refresh(ai_msg)

    # 检查是否超时
    import datetime
    if session.start_time:
        elapsed = (datetime.datetime.now(datetime.timezone.utc) - session.start_time).total_seconds()
        if elapsed >= session.duration_minutes * 60:
            session.status = "completed"
            session.is_completed = True
            db.add(session)

    return MessageResponse.model_validate(ai_msg)


async def _get_next_sequence(db: AsyncSession, session_id: str) -> int:
    """获取下一条消息序号"""
    result = await db.execute(
        select(func.max(MessageModel.sequence)).where(
            MessageModel.session_id == session_id
        )
    )
    max_seq = result.scalar() or 0
    return max_seq + 1
