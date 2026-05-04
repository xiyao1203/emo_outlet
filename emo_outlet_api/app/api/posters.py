from __future__ import annotations

import datetime
import json

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
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
    EmotionReportDetailResponse,
    EmotionReportResponse,
    PosterDetailResponse,
    PosterGenerateRequest,
    PosterResponse,
)
from app.services.emotion_service import emotion_service
from app.services.poster_service import poster_service

router = APIRouter(prefix="/api/posters", tags=["posters"])


def _safe_json(value: str | None) -> dict:
    if not value:
        return {}
    try:
        return json.loads(value)
    except json.JSONDecodeError:
        return {}


@router.post("/generate", response_model=PosterResponse)
async def generate_poster(
    req: PosterGenerateRequest,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(SessionModel).where(
            SessionModel.id == req.session_id,
            SessionModel.user_id == current_user.id,
            SessionModel.is_completed == True,
        )
    )
    session = result.scalar_one_or_none()
    if not session:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="会话不存在或未结束")

    result = await db.execute(
        select(PosterModel).where(PosterModel.session_id == req.session_id)
    )
    existing = result.scalar_one_or_none()
    if existing:
        return PosterResponse.model_validate(existing)

    emotion_data = _safe_json(session.emotion_summary)
    target_result = await db.execute(
        select(TargetModel).where(TargetModel.id == session.target_id)
    )
    target = target_result.scalar_one_or_none()
    target_name = target.name if target else ""

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
        msg_result = await db.execute(
            select(MessageModel)
            .where(MessageModel.session_id == req.session_id)
            .order_by(MessageModel.sequence)
        )
        messages = msg_result.scalars().all()
        emotion_result = await emotion_service.analyze_messages(
            [{"content": item.content, "sender": item.sender} for item in messages]
        )

    poster_content = await poster_service.generate_poster_content(
        emotion_result,
        target_name,
    )
    mock_poster_data = await poster_service.generate_mock_poster_base64()

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


@router.get("", response_model=list[PosterResponse])
async def list_posters(
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(PosterModel)
        .where(PosterModel.user_id == current_user.id)
        .order_by(PosterModel.created_at.desc())
    )
    posters = result.scalars().all()
    return [PosterResponse.model_validate(item) for item in posters]


@router.get("/detail/{poster_id}", response_model=PosterDetailResponse)
async def get_poster_detail(
    poster_id: str,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(PosterModel).where(
            PosterModel.id == poster_id,
            PosterModel.user_id == current_user.id,
        )
    )
    poster = result.scalar_one_or_none()
    if not poster:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="海报不存在")

    session_result = await db.execute(
        select(SessionModel).where(SessionModel.id == poster.session_id)
    )
    session = session_result.scalar_one_or_none()

    title = poster.title or "把情绪装进瓶子里"
    return PosterDetailResponse(
        id=poster.id,
        session_id=poster.session_id,
        title=title,
        date=poster.created_at.strftime("%Y.%m.%d") if poster.created_at else "",
        tag=f"释放 · {poster.emotion_type or '释放心情'}",
        summary=poster.suggestion or "每一次释放，都是向内在温柔的靠近",
        created_at_label=poster.created_at.strftime("%Y年%-m月%-d日 %H:%M")
        if poster.created_at
        else "",
        source_session_title=(session.summary_text if session and session.summary_text else title),
        poster_data=poster.poster_data,
    )


@router.get("/session/{session_id}", response_model=PosterResponse)
async def get_poster_by_session(
    session_id: str,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
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
    now = datetime.datetime.now(datetime.timezone.utc)
    if period == "monthly":
        start_date = now - datetime.timedelta(days=30)
    elif period == "yearly":
        start_date = now - datetime.timedelta(days=365)
    else:
        start_date = now - datetime.timedelta(days=7)

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
            dominant_emotion="暂无数据",
            suggestion="开始你的第一次情绪释放吧。",
        )

    emotion_counts: dict[str, float] = {}
    trend: list[dict] = []
    total_duration = 0
    for item in sessions:
        total_duration += item.duration_minutes
        data = _safe_json(item.emotion_summary)
        primary = data.get("primary_emotion", "平静")
        intensity = data.get("intensity", 50)
        emotion_counts[primary] = emotion_counts.get(primary, 0) + 1
        trend.append(
            {
                "date": item.created_at.strftime("%m-%d") if item.created_at else "",
                "score": intensity,
            }
        )

    dominant = max(emotion_counts, key=emotion_counts.get)
    total = sum(emotion_counts.values())
    distribution = {
        key: round(value / total * 100, 1) for key, value in emotion_counts.items()
    }
    suggestion_map = {
        "愤怒": "你的愤怒值较高，建议结合运动或深呼吸来释放压力。",
        "悲伤": "最近情绪偏低，可以先从规律作息和简单表达开始。",
        "焦虑": "试着把高压事件拆小，一次只处理一件事。",
        "疲惫": "你最近很累，给自己留一点真正休息的时间。",
        "无奈": "对无力改变的事，先照顾好自己的感受。",
    }
    return EmotionReportResponse(
        total_sessions=len(sessions),
        total_duration_minutes=total_duration,
        dominant_emotion=dominant,
        emotion_distribution=distribution,
        daily_trend=trend,
        suggestion=suggestion_map.get(dominant, "继续保持良好的表达习惯。"),
    )


@router.get("/report/detail", response_model=EmotionReportDetailResponse)
async def get_emotion_report_detail(
    period: str = "monthly",
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    now = datetime.datetime.now(datetime.timezone.utc)
    days = 30 if period == "monthly" else 7 if period == "weekly" else 1
    start_date = now - datetime.timedelta(days=days)

    result = await db.execute(
        select(SessionModel)
        .where(
            SessionModel.user_id == current_user.id,
            SessionModel.is_completed == True,
            SessionModel.created_at >= start_date,
        )
        .order_by(SessionModel.created_at.asc())
    )
    sessions = result.scalars().all()

    if not sessions:
        return EmotionReportDetailResponse(
            period=period,
            trend_points=[],
            mode_distribution={"single": 0, "dual": 0},
            target_distribution=[],
            time_distribution=[],
            keyword_counts=[],
        )

    single_count = 0
    dual_count = 0
    target_count: dict[str, int] = {}
    keyword_count: dict[str, int] = {}
    time_count = {"上午": 0, "下午": 0, "晚上": 0, "深夜": 0}
    trend_points: list[dict] = []

    target_names: dict[str, str] = {}
    target_result = await db.execute(
        select(TargetModel).where(TargetModel.user_id == current_user.id)
    )
    for target in target_result.scalars().all():
        target_names[target.id] = target.name

    for item in sessions:
        if item.mode == "single":
            single_count += 1
        else:
            dual_count += 1

        if item.target_id in target_names:
            name = target_names[item.target_id]
            target_count[name] = target_count.get(name, 0) + 1

        data = _safe_json(item.emotion_summary)
        trend_points.append(
            {
                "date": item.created_at.strftime("%m-%d") if item.created_at else "",
                "level": data.get("intensity", 50),
                "emotion": data.get("primary_emotion", "平静"),
            }
        )

        for keyword in data.get("keywords", [])[:5]:
            keyword_count[keyword] = keyword_count.get(keyword, 0) + 1

        hour = item.created_at.hour if item.created_at else 12
        if 6 <= hour < 12:
            time_count["上午"] += 1
        elif 12 <= hour < 18:
            time_count["下午"] += 1
        elif 18 <= hour < 24:
            time_count["晚上"] += 1
        else:
            time_count["深夜"] += 1

    total_sessions = max(len(sessions), 1)
    return EmotionReportDetailResponse(
        period=period,
        trend_points=trend_points,
        mode_distribution={
            "single": round(single_count / total_sessions * 100, 1),
            "dual": round(dual_count / total_sessions * 100, 1),
        },
        target_distribution=[
            {
                "name": key,
                "percent": round(value / total_sessions * 100, 1),
            }
            for key, value in sorted(target_count.items(), key=lambda item: item[1], reverse=True)
        ],
        time_distribution=[
            {
                "name": key,
                "percent": round(value / total_sessions * 100, 1),
            }
            for key, value in time_count.items()
        ],
        keyword_counts=[
            {"name": key, "count": value}
            for key, value in sorted(keyword_count.items(), key=lambda item: item[1], reverse=True)
        ],
    )
