"""海报 / 情绪报告 API 路由"""
from __future__ import annotations

import json
import datetime

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user
from app.database import get_db
from app.models.message import MessageModel
from app.models.poster import PosterModel
from app.models.session import SessionModel
from app.models.target import TargetModel
from app.models.user import UserModel
from app.schemas.poster import (
    EmotionAnalysisResult,
    EmotionReportResponse,
    PosterGenerateRequest,
    PosterResponse,
)
from app.services.emotion_service import emotion_service
from app.services.poster_service import poster_service

router = APIRouter(prefix="/api/posters", tags=["海报与报告"])


@router.post("/generate", response_model=PosterResponse)
async def generate_poster(
    req: PosterGenerateRequest,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """生成情绪海报"""
    # 验证会话
    result = await db.execute(
        select(SessionModel).where(
            SessionModel.id == req.session_id,
            SessionModel.user_id == current_user.id,
            SessionModel.is_completed == True,
        )
    )
    session = result.scalar_one_or_none()
    if not session:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="会话不存在或未结束",
        )

    # 检查海报是否已存在
    result = await db.execute(
        select(PosterModel).where(PosterModel.session_id == req.session_id)
    )
    existing = result.scalar_one_or_none()
    if existing:
        return PosterResponse.model_validate(existing)

    # 解析情绪分析结果
    emotion_data = {}
    if session.emotion_summary:
        try:
            emotion_data = json.loads(session.emotion_summary)
        except json.JSONDecodeError:
            pass

    # 获取目标名称
    target_result = await db.execute(
        select(TargetModel).where(TargetModel.id == session.target_id)
    )
    target = target_result.scalar_one_or_none()
    target_name = target.name if target else ""

    # 生成海报内容
    if emotion_data:
        emotion_result = EmotionAnalysisResult(
            primary_emotion=emotion_data.get("primary_emotion", "平静"),
            emotions=emotion_data.get("emotions", {"平静": 100}),
            intensity=emotion_data.get("intensity", 0),
            keywords=emotion_data.get("keywords", []),
            summary=emotion_data.get("summary", ""),
            suggestion=emotion_data.get("suggestion", ""),
        )
    else:
        # 没有情绪分析，用会话消息做简单分析
        msg_result = await db.execute(
            select(MessageModel)
            .where(MessageModel.session_id == req.session_id)
            .order_by(MessageModel.sequence)
        )
        messages = msg_result.scalars().all()
        msg_dicts = [
            {"content": m.content, "sender": m.sender} for m in messages
        ]
        emotion_result = await emotion_service.analyze_messages(msg_dicts)

    poster_content = await poster_service.generate_poster_content(
        emotion_result, target_name
    )

    # 生成模拟海报 Base64
    mock_poster_data = await poster_service.generate_mock_poster_base64()

    # 保存海报
    poster = PosterModel(
        session_id=req.session_id,
        user_id=current_user.id,
        title=poster_content["title"],
        emotion_type=poster_content["emotion_type"],
        emotion_intensity=poster_content["emotion_intensity"],
        keywords=poster_content["keywords"],
        suggestion=poster_content["suggestion"],
        poster_data=mock_poster_data,
    )
    db.add(poster)
    await db.flush()
    await db.refresh(poster)

    return PosterResponse.model_validate(poster)


@router.get("/{session_id}", response_model=PosterResponse)
async def get_poster(
    session_id: str,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """获取海报"""
    result = await db.execute(
        select(PosterModel).where(
            PosterModel.session_id == session_id,
            PosterModel.user_id == current_user.id,
        )
    )
    poster = result.scalar_one_or_none()
    if not poster:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="海报不存在")

    return PosterResponse.model_validate(poster)


@router.get("/report/overview", response_model=EmotionReportResponse)
async def get_emotion_report(
    period: str = "weekly",
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """获取情绪报告（周/月/年）"""
    now = datetime.datetime.now(datetime.timezone.utc)

    # 计算时间范围
    if period == "weekly":
        start_date = now - datetime.timedelta(days=7)
    elif period == "monthly":
        start_date = now - datetime.timedelta(days=30)
    elif period == "yearly":
        start_date = now - datetime.timedelta(days=365)
    else:
        start_date = now - datetime.timedelta(days=7)

    # 查询完成会话
    result = await db.execute(
        select(SessionModel).where(
            SessionModel.user_id == current_user.id,
            SessionModel.is_completed == True,
            SessionModel.created_at >= start_date,
        )
    )
    sessions = result.scalars().all()

    if not sessions:
        return EmotionReportResponse(
            total_sessions=0,
            total_duration_minutes=0,
            dominant_emotion="暂无数据",
            suggestion="开始你的第一次情绪释放吧！",
        )

    # 统计数据
    total_sessions = len(sessions)
    total_duration = sum(s.duration_minutes for s in sessions)

    # 情绪分布统计
    emotion_counts: dict[str, float] = {}
    for s in sessions:
        if s.emotion_summary:
            try:
                data = json.loads(s.emotion_summary)
                primary = data.get("primary_emotion", "未知")
                emotion_counts[primary] = emotion_counts.get(primary, 0) + 1
            except json.JSONDecodeError:
                pass

    # 计算占比
    if emotion_counts:
        dominant = max(emotion_counts, key=emotion_counts.get)
        total = sum(emotion_counts.values())
        distribution = {
            k: round(v / total * 100, 1) for k, v in emotion_counts.items()
        }
    else:
        dominant = "未知"
        distribution = {}

    # 生成建议
    suggestion_map = {
        "愤怒": "你的愤怒值较高，建议结合运动或深呼吸来释放压力。",
        "悲伤": "你近期情绪偏低，试试和信任的朋友聊聊，或者做些喜欢的事。",
        "焦虑": "你近期焦虑指数较高，可以试试冥想或规律作息来缓解。",
        "疲惫": "你近期疲惫感明显，身体需要更多休息和营养。",
        "无奈": "有些事情暂时无法改变，试着关注自己能控制的方面。",
    }
    suggestion = suggestion_map.get(dominant, "继续保持良好的情绪释放习惯！")

    return EmotionReportResponse(
        total_sessions=total_sessions,
        total_duration_minutes=total_duration,
        dominant_emotion=dominant,
        emotion_distribution=distribution,
        daily_trend=[],
        suggestion=suggestion,
    )
