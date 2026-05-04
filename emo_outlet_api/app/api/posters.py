from __future__ import annotations

import json
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, Response, status
from sqlalchemy import delete, select
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
    PosterFavoriteUpdateRequest,
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


def _period_start(period: str) -> datetime:
    now = datetime.now(timezone.utc)
    mapping = {
        "daily": timedelta(days=1),
        "weekly": timedelta(days=7),
        "monthly": timedelta(days=30),
        "yearly": timedelta(days=365),
        "all": timedelta(days=3650),
    }
    return now - mapping.get(period, timedelta(days=7))


def _time_bucket(hour: int) -> str:
    if 6 <= hour < 12:
        return "上午"
    if 12 <= hour < 18:
        return "下午"
    if 18 <= hour < 24:
        return "晚上"
    return "深夜"


def _detail_level(score: int) -> str:
    if score >= 75:
        return "高"
    if score >= 45:
        return "中"
    if score >= 20:
        return "低"
    return "平静"


@router.post("/generate", response_model=PosterResponse)
async def generate_poster(
    req: PosterGenerateRequest,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    session_result = await db.execute(
        select(SessionModel).where(
            SessionModel.id == req.session_id,
            SessionModel.user_id == current_user.id,
            SessionModel.is_completed == True,
        )
    )
    session = session_result.scalar_one_or_none()
    if session is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Completed session not found")

    existing_result = await db.execute(
        select(PosterModel).where(PosterModel.session_id == req.session_id)
    )
    existing = existing_result.scalar_one_or_none()
    if existing is not None:
        return PosterResponse.model_validate(existing)

    emotion_data = _safe_json(session.emotion_summary)
    target_result = await db.execute(select(TargetModel).where(TargetModel.id == session.target_id))
    target = target_result.scalar_one_or_none()
    target_name = target.name if target else ""

    if emotion_data:
        emotion_result = EmotionAnalysisResult(
            primary_emotion=emotion_data.get("primary_emotion", "平静"),
            emotions=emotion_data.get("emotions", {"平静": 100.0}),
            intensity=emotion_data.get("intensity", 20),
            keywords=emotion_data.get("keywords", []),
            summary=emotion_data.get("summary", ""),
            suggestion=emotion_data.get("suggestion", ""),
        )
    else:
        msg_result = await db.execute(
            select(MessageModel)
            .where(MessageModel.session_id == req.session_id)
            .order_by(MessageModel.sequence.asc())
        )
        messages = msg_result.scalars().all()
        emotion_result = await emotion_service.analyze_messages(
            [{"content": item.content, "sender": item.sender} for item in messages]
        )

    poster_content = await poster_service.generate_poster_content(emotion_result, target_name)
    poster_data = await poster_service.generate_mock_poster_base64(poster_content)

    poster = PosterModel(
        session_id=req.session_id,
        user_id=current_user.id,
        title=poster_content["title"],
        emotion_type=poster_content["emotion_type"],
        emotion_intensity=poster_content["emotion_intensity"],
        keywords=poster_content["keywords"],
        suggestion=poster_content["summary"],
        poster_data=poster_data,
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
    return [PosterResponse.model_validate(item) for item in result.scalars().all()]


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
    if poster is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Poster not found")

    session_result = await db.execute(
        select(SessionModel).where(SessionModel.id == poster.session_id)
    )
    session = session_result.scalar_one_or_none()

    emotion_type = poster.emotion_type or "平静"
    title = poster.title or "把情绪装进瓶子里"
    return PosterDetailResponse(
        id=poster.id,
        session_id=poster.session_id,
        title=title,
        date=poster.created_at.strftime("%Y.%m.%d") if poster.created_at else "",
        tag=f"释放·{emotion_type}",
        summary=poster.suggestion or "每一次释放，都是向内在温柔地靠近。",
        created_at_label=poster.created_at.strftime("%Y年%m月%d日 %H:%M") if poster.created_at else "",
        source_session_title=session.summary_text if session and session.summary_text else title,
        poster_data=poster.poster_data,
        is_favorite=poster.is_favorite,
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
    if poster is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Poster not found")
    return PosterResponse.model_validate(poster)


@router.put("/{poster_id}/favorite", response_model=PosterResponse)
async def update_poster_favorite(
    poster_id: str,
    req: PosterFavoriteUpdateRequest,
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
    if poster is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Poster not found")
    poster.is_favorite = req.is_favorite
    db.add(poster)
    await db.flush()
    await db.refresh(poster)
    return PosterResponse.model_validate(poster)


@router.delete("/{poster_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_poster(
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
    if poster is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Poster not found")
    await db.execute(delete(PosterModel).where(PosterModel.id == poster_id))
    return Response(status_code=status.HTTP_204_NO_CONTENT)


@router.get("/report/overview", response_model=EmotionReportResponse)
async def get_emotion_report(
    period: str = "weekly",
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    start_date = _period_start(period)
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
        return EmotionReportResponse(
            dominant_emotion="暂无数据",
            suggestion="先开始一次新的情绪释放，报告会随着记录慢慢长出来。",
        )

    emotion_counts: dict[str, int] = {}
    trend: list[dict] = []
    total_duration = 0
    total_intensity = 0

    for item in sessions:
        total_duration += item.duration_minutes
        data = _safe_json(item.emotion_summary)
        emotion = data.get("primary_emotion", "平静")
        intensity = int(data.get("intensity", 20))
        emotion_counts[emotion] = emotion_counts.get(emotion, 0) + 1
        total_intensity += intensity
        trend.append(
            {
                "date": item.created_at.strftime("%m-%d") if item.created_at else "",
                "score": intensity,
                "emotion": emotion,
            }
        )

    dominant = max(emotion_counts, key=emotion_counts.get)
    total = sum(emotion_counts.values())
    distribution = {
        key: round(value / total * 100, 1)
        for key, value in sorted(emotion_counts.items(), key=lambda pair: pair[1], reverse=True)
    }
    average_intensity = round(total_intensity / total, 1) if total else 0

    suggestion_map = {
        "愤怒": "最近最常见的是愤怒型释放，适合在起火前先做一次短暂停顿，把火气和诉求分开。",
        "委屈": "这段时间你更需要被理解，先照顾感受，再处理关系里的问题。",
        "焦虑": "焦虑占比偏高，试试把压力拆小，优先完成最具体的一步。",
        "疲惫": "疲惫感比较明显，报告更建议你先补休息，而不是继续硬顶。",
        "无奈": "无奈感偏多时，先把注意力收回到自己能掌控的小事上。",
        "平静": "你的情绪波动正在变稳，继续保持这种可表达、可觉察的节奏就很好。",
    }

    return EmotionReportResponse(
        total_sessions=len(sessions),
        total_duration_minutes=total_duration,
        dominant_emotion=dominant,
        emotion_distribution=distribution,
        daily_trend=trend,
        suggestion=f"{suggestion_map.get(dominant, '继续稳定表达自己的情绪。')} 当前平均波动强度约 {average_intensity} 分。",
    )


@router.get("/report/detail", response_model=EmotionReportDetailResponse)
async def get_emotion_report_detail(
    period: str = "monthly",
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    start_date = _period_start(period)
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
            mode_distribution={"single": 0.0, "dual": 0.0},
            target_distribution=[],
            time_distribution=[],
            keyword_counts=[],
        )

    targets_result = await db.execute(
        select(TargetModel).where(TargetModel.user_id == current_user.id, TargetModel.is_deleted == False)
    )
    target_names = {item.id: item.name for item in targets_result.scalars().all()}

    single_count = 0
    dual_count = 0
    target_count: dict[str, int] = {}
    keyword_count: dict[str, int] = {}
    time_count = {"上午": 0, "下午": 0, "晚上": 0, "深夜": 0}
    trend_points: list[dict] = []

    for item in sessions:
        if item.mode == "single":
            single_count += 1
        else:
            dual_count += 1

        target_name = target_names.get(item.target_id, "未命名对象")
        target_count[target_name] = target_count.get(target_name, 0) + 1

        data = _safe_json(item.emotion_summary)
        intensity = int(data.get("intensity", 20))
        trend_points.append(
            {
                "date": item.created_at.strftime("%m-%d") if item.created_at else "",
                "score": intensity,
                "level": _detail_level(intensity),
                "emotion": data.get("primary_emotion", "平静"),
            }
        )

        for keyword in data.get("keywords", [])[:6]:
            keyword_count[keyword] = keyword_count.get(keyword, 0) + 1

        bucket = _time_bucket(item.created_at.hour if item.created_at else 12)
        time_count[bucket] += 1

    total_sessions = len(sessions)
    return EmotionReportDetailResponse(
        period=period,
        trend_points=trend_points,
        mode_distribution={
            "single": round(single_count / total_sessions * 100, 1),
            "dual": round(dual_count / total_sessions * 100, 1),
        },
        target_distribution=[
            {"name": key, "percent": round(value / total_sessions * 100, 1)}
            for key, value in sorted(target_count.items(), key=lambda item: item[1], reverse=True)
        ],
        time_distribution=[
            {"name": key, "percent": round(value / total_sessions * 100, 1)}
            for key, value in time_count.items()
        ],
        keyword_counts=[
            {"name": key, "count": value}
            for key, value in sorted(keyword_count.items(), key=lambda item: item[1], reverse=True)
        ],
    )
