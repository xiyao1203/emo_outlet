from __future__ import annotations

from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user
from app.core.security import create_access_token, hash_password, verify_password
from app.database import get_db
from app.models.compliance import ConsentRecord
from app.models.message import MessageModel
from app.models.poster import PosterModel
from app.models.session import SessionModel
from app.models.support import UserProfileDetailModel
from app.models.target import TargetModel
from app.models.user import UserModel
from app.schemas.user import (
    TokenResponse,
    UserLoginRequest,
    UserProfileDetailResponse,
    UserProfileDetailUpdateRequest,
    UserRegisterRequest,
    UserResponse,
    UserUpdateRequest,
    VisitorLoginRequest,
)

router = APIRouter(prefix="/api/auth", tags=["auth"])


@router.post("/register", response_model=TokenResponse)
async def register(
    req: UserRegisterRequest,
    db: AsyncSession = Depends(get_db),
):
    if req.phone:
        result = await db.execute(select(UserModel).where(UserModel.phone == req.phone))
        if result.scalar_one_or_none():
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="手机号已注册")

    if req.email:
        result = await db.execute(select(UserModel).where(UserModel.email == req.email))
        if result.scalar_one_or_none():
            raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="邮箱已注册")

    import uuid

    user = UserModel(
        nickname=req.nickname or f"用户{uuid.uuid4().hex[:8]}",
        phone=req.phone,
        email=req.email,
        password_hash=hash_password(req.password),
        device_uuid=req.device_uuid,
        consent_version=req.consent_version,
        age_range=req.age_range,
    )
    db.add(user)
    await db.flush()
    await db.refresh(user)

    if req.consent_version:
        for consent_type in ["privacy", "terms"]:
            db.add(
                ConsentRecord(
                    user_id=user.id,
                    consent_type=consent_type,
                    consent_version=req.consent_version,
                )
            )
        await db.flush()

    token = create_access_token({"sub": user.id})
    return TokenResponse(access_token=token, user=UserResponse.model_validate(user))


@router.post("/login", response_model=TokenResponse)
async def login(
    req: UserLoginRequest,
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(UserModel).where(
            (UserModel.phone == req.account) | (UserModel.email == req.account)
        )
    )
    user = result.scalar_one_or_none()
    if not user or not user.password_hash or not verify_password(req.password, user.password_hash):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="账号或密码错误")

    token = create_access_token({"sub": user.id})
    return TokenResponse(access_token=token, user=UserResponse.model_validate(user))


@router.post("/visitor", response_model=TokenResponse)
async def visitor_login(
    req: VisitorLoginRequest,
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(UserModel).where(
            UserModel.device_uuid == req.device_uuid,
            UserModel.is_visitor == True,
        )
    )
    user = result.scalar_one_or_none()

    if not user:
        user = UserModel(
            nickname=req.nickname,
            is_visitor=True,
            device_uuid=req.device_uuid,
        )
        db.add(user)
        await db.flush()
        await db.refresh(user)

    token = create_access_token({"sub": user.id})
    return TokenResponse(access_token=token, user=UserResponse.model_validate(user))


@router.get("/me", response_model=UserResponse)
async def get_profile(current_user: UserModel = Depends(get_current_user)):
    return UserResponse.model_validate(current_user)


@router.put("/me", response_model=UserResponse)
async def update_profile(
    req: UserUpdateRequest,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if req.nickname is not None:
        current_user.nickname = req.nickname
    if req.avatar_url is not None:
        current_user.avatar_url = req.avatar_url

    db.add(current_user)
    await db.flush()
    await db.refresh(current_user)
    return UserResponse.model_validate(current_user)


@router.get("/profile-detail", response_model=UserProfileDetailResponse)
async def get_profile_detail(
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(UserProfileDetailModel).where(
            UserProfileDetailModel.user_id == current_user.id
        )
    )
    detail = result.scalar_one_or_none()
    return UserProfileDetailResponse(
        user_id=current_user.id,
        nickname=current_user.nickname,
        avatar_url=current_user.avatar_url,
        phone=current_user.phone,
        signature=detail.signature if detail else "拥抱情绪，遇见更好的自己",
        gender=detail.gender if detail else "女",
        birthday=detail.birthday if detail else "1998-05-20",
        region=detail.region if detail else "中国 · 上海",
    )


@router.put("/profile-detail", response_model=UserProfileDetailResponse)
async def update_profile_detail(
    req: UserProfileDetailUpdateRequest,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(UserProfileDetailModel).where(
            UserProfileDetailModel.user_id == current_user.id
        )
    )
    detail = result.scalar_one_or_none()
    if not detail:
        detail = UserProfileDetailModel(user_id=current_user.id)

    if req.nickname is not None:
        current_user.nickname = req.nickname
    if req.avatar_url is not None:
        current_user.avatar_url = req.avatar_url
    if req.signature is not None:
        detail.signature = req.signature
    if req.gender is not None:
        detail.gender = req.gender
    if req.birthday is not None:
        detail.birthday = req.birthday
    if req.region is not None:
        detail.region = req.region

    db.add(current_user)
    db.add(detail)
    await db.flush()

    return UserProfileDetailResponse(
      user_id=current_user.id,
      nickname=current_user.nickname,
      avatar_url=current_user.avatar_url,
      phone=current_user.phone,
      signature=detail.signature,
      gender=detail.gender,
      birthday=detail.birthday,
      region=detail.region,
    )


@router.delete("/account")
async def delete_account(
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    session_ids_subq = select(SessionModel.id).where(SessionModel.user_id == current_user.id)

    await db.execute(delete(MessageModel).where(MessageModel.session_id.in_(session_ids_subq)))
    await db.execute(delete(PosterModel).where(PosterModel.user_id == current_user.id))
    await db.execute(delete(SessionModel).where(SessionModel.user_id == current_user.id))
    await db.execute(delete(TargetModel).where(TargetModel.user_id == current_user.id))
    await db.execute(delete(ConsentRecord).where(ConsentRecord.user_id == current_user.id))
    await db.execute(
        delete(UserProfileDetailModel).where(UserProfileDetailModel.user_id == current_user.id)
    )

    current_user.nickname = "已注销用户"
    current_user.phone = None
    current_user.email = None
    current_user.avatar_url = None
    current_user.device_uuid = None
    current_user.password_hash = None
    current_user.is_active = False
    current_user.is_deleted = True
    current_user.daily_session_count = 0
    db.add(current_user)
    await db.flush()
    return {"message": "账号已注销，所有数据已清除"}


@router.get("/data/export")
async def export_user_data(
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(SessionModel)
        .where(SessionModel.user_id == current_user.id)
        .order_by(SessionModel.created_at)
    )
    sessions = result.scalars().all()
    session_ids = [item.id for item in sessions]

    messages_data: list[dict] = []
    if session_ids:
        result = await db.execute(
            select(MessageModel)
            .where(MessageModel.session_id.in_(session_ids))
            .order_by(MessageModel.sequence)
        )
        messages = result.scalars().all()
        messages_data = [
            {
                "id": item.id,
                "session_id": item.session_id,
                "content": item.content,
                "sender": item.sender,
                "created_at": item.created_at.isoformat() if item.created_at else None,
            }
            for item in messages
        ]

    result = await db.execute(
        select(TargetModel).where(
            TargetModel.user_id == current_user.id,
            TargetModel.is_deleted == False,
        )
    )
    targets = result.scalars().all()

    result = await db.execute(
        select(PosterModel).where(PosterModel.user_id == current_user.id)
    )
    posters = result.scalars().all()

    return {
        "user": {
            "id": current_user.id,
            "nickname": current_user.nickname,
            "phone": current_user.phone,
            "email": current_user.email,
            "is_visitor": current_user.is_visitor,
            "age_range": current_user.age_range,
            "created_at": current_user.created_at.isoformat() if current_user.created_at else None,
        },
        "targets": [
            {
                "id": item.id,
                "name": item.name,
                "type": item.type,
                "created_at": item.created_at.isoformat() if item.created_at else None,
            }
            for item in targets
        ],
        "sessions": [
            {
                "id": item.id,
                "target_id": item.target_id,
                "mode": item.mode,
                "duration_minutes": item.duration_minutes,
                "status": item.status,
                "start_time": item.start_time.isoformat() if item.start_time else None,
                "end_time": item.end_time.isoformat() if item.end_time else None,
                "created_at": item.created_at.isoformat() if item.created_at else None,
            }
            for item in sessions
        ],
        "messages": messages_data,
        "posters": [
            {
                "id": item.id,
                "session_id": item.session_id,
                "title": item.title,
                "emotion_type": item.emotion_type,
                "created_at": item.created_at.isoformat() if item.created_at else None,
            }
            for item in posters
        ],
        "export_time": datetime.now(timezone.utc).isoformat(),
    }
