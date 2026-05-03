"""会话 API 路由"""
from __future__ import annotations

from datetime import datetime, timezone
import json

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user
from app.database import get_db
from app.models.message import MessageModel
from app.models.session import SessionModel
from app.models.target import TargetModel
from app.models.user import UserModel
from app.config import settings
from app.schemas.message import MessageListResponse, MessageResponse
from app.schemas.session import (
    SessionCreateRequest,
    SessionEndRequest,
    SessionResponse,
    SessionSummaryResponse,
)
from app.services.emotion_service import emotion_service


# 辅助：将 Session ORM 对象转为响应，附带 target 关联信息
def _session_to_response(session: SessionModel) -> SessionResponse:
    """将 Session ORM 转为响应，填充 target_name / target_avatar_url"""
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

router = APIRouter(prefix="/api/sessions", tags=["会话"])


@router.post("", response_model=SessionResponse, status_code=status.HTTP_201_CREATED)
async def create_session(
    req: SessionCreateRequest,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """创建新会话"""
    # 验证目标存在
    result = await db.execute(
        select(TargetModel).where(
            TargetModel.id == req.target_id,
            TargetModel.user_id == current_user.id,
        )
    )
    target = result.scalar_one_or_none()
    if not target:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="目标不存在")

    # 检查每日限制
    today = datetime.now(timezone.utc).date()
    if current_user.last_active_date != str(today):
        # 新的一天，重置计数
        current_user.daily_session_count = 0
        current_user.last_active_date = str(today)

    if current_user.daily_session_count >= settings.MAX_DAILY_FREE_SESSIONS:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=f"每日会话上限（{settings.MAX_DAILY_FREE_SESSIONS}次）已到，明天再来吧",
        )

    # 更新用户计数
    current_user.daily_session_count += 1
    current_user.last_active_date = str(today)
    db.add(current_user)

    # 创建会话
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

    # 重新加载 target 关系
    await db.refresh(session, ["target"])
    return _session_to_response(session)


@router.get("", response_model=list[SessionResponse])
async def list_sessions(
    page: int = 1,
    page_size: int = 20,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """获取会话历史列表"""
    query = (
        select(SessionModel)
        .where(
            SessionModel.user_id == current_user.id,
            SessionModel.is_completed == True,
        )
        .order_by(SessionModel.created_at.desc())
        .offset((page - 1) * page_size)
        .limit(page_size)
    )
    result = await db.execute(query)
    sessions = result.scalars().all()

    return [_session_to_response(s) for s in sessions]


@router.get("/active", response_model=SessionResponse | None)
async def get_active_session(
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """获取当前活跃的会话"""
    result = await db.execute(
        select(SessionModel).where(
            SessionModel.user_id == current_user.id,
            SessionModel.status == "active",
        )
    )
    session = result.scalar_one_or_none()
    if not session:
        return None
    return _session_to_response(session)


@router.get("/{session_id}", response_model=SessionResponse)
async def get_session(
    session_id: str,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """获取会话详情"""
    result = await db.execute(
        select(SessionModel).where(
            SessionModel.id == session_id,
            SessionModel.user_id == current_user.id,
        )
    )
    session = result.scalar_one_or_none()
    if not session:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    return _session_to_response(session)


@router.post("/{session_id}/end", response_model=SessionSummaryResponse)
async def end_session(
    session_id: str,
    req: SessionEndRequest = SessionEndRequest(),
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """结束会话 + 情绪分析"""
    result = await db.execute(
        select(SessionModel).where(
            SessionModel.id == session_id,
            SessionModel.user_id == current_user.id,
        )
    )
    session = result.scalar_one_or_none()
    if not session:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    if session.is_completed:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="会话已结束")

    # 结束会话
    session.status = "interrupted" if req.force else "completed"
    session.is_completed = True
    session.end_time = datetime.now(timezone.utc)
    db.add(session)

    # 获取消息
    msg_result = await db.execute(
        select(MessageModel)
        .where(MessageModel.session_id == session_id)
        .order_by(MessageModel.sequence)
    )
    messages = msg_result.scalars().all()

    # 情绪分析
    msg_dicts = [
        {
            "content": m.content,
            "sender": m.sender,
            "emotion_type": m.emotion_type,
            "emotion_intensity": m.emotion_intensity,
        }
        for m in messages
    ]
    emotion_result = await emotion_service.analyze_messages(msg_dicts)

    # 保存分析结果
    session.emotion_summary = json.dumps(
        {
            "primary_emotion": emotion_result.primary_emotion,
            "emotions": emotion_result.emotions,
            "intensity": emotion_result.intensity,
            "keywords": emotion_result.keywords,
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
        messages=[MessageResponse.model_validate(m) for m in messages],
        emotion_analysis=emotion_result.model_dump(),
    )
