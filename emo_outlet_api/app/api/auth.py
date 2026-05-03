"""认证 API 路由"""
from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import delete, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user
from app.core.security import (
    create_access_token,
    hash_password,
    verify_password,
)
from app.database import get_db
from app.models.compliance import ConsentRecord
from app.models.message import MessageModel
from app.models.poster import PosterModel
from app.models.session import SessionModel
from app.models.target import TargetModel
from app.models.user import UserModel
from app.schemas.user import (
    TokenResponse,
    UserLoginRequest,
    UserRegisterRequest,
    UserResponse,
    UserUpdateRequest,
    VisitorLoginRequest,
)

router = APIRouter(prefix="/api/auth", tags=["认证"])


@router.post("/register", response_model=TokenResponse)
async def register(req: UserRegisterRequest, db: AsyncSession = Depends(get_db)):
    """用户注册"""
    # 检查账号是否已存在
    if req.phone:
        result = await db.execute(
            select(UserModel).where(UserModel.phone == req.phone)
        )
        if result.scalar_one_or_none():
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="该手机号已注册",
            )

    if req.email:
        result = await db.execute(
            select(UserModel).where(UserModel.email == req.email)
        )
        if result.scalar_one_or_none():
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="该邮箱已注册",
            )

    # 创建用户
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

    # 记录用户同意
    if req.consent_version:
        for ctype in ["privacy", "terms"]:
            record = ConsentRecord(
                user_id=user.id,
                consent_type=ctype,
                consent_version=req.consent_version,
            )
            db.add(record)
        await db.flush()

    # 生成令牌
    token = create_access_token({"sub": user.id})

    return TokenResponse(
        access_token=token,
        user=UserResponse.model_validate(user),
    )


@router.post("/login", response_model=TokenResponse)
async def login(req: UserLoginRequest, db: AsyncSession = Depends(get_db)):
    """用户登录"""
    # 通过手机号或邮箱查找
    result = await db.execute(
        select(UserModel).where(
            (UserModel.phone == req.account) | (UserModel.email == req.account)
        )
    )
    user = result.scalar_one_or_none()

    if not user or not user.password_hash:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="账号或密码错误",
        )

    if not verify_password(req.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="账号或密码错误",
        )

    token = create_access_token({"sub": user.id})

    return TokenResponse(
        access_token=token,
        user=UserResponse.model_validate(user),
    )


@router.post("/visitor", response_model=TokenResponse)
async def visitor_login(req: VisitorLoginRequest, db: AsyncSession = Depends(get_db)):
    """游客登录"""
    # 查找是否已有此设备游客
    result = await db.execute(
        select(UserModel).where(
            UserModel.device_uuid == req.device_uuid,
            UserModel.is_visitor == True,
        )
    )
    user = result.scalar_one_or_none()

    if not user:
        # 创建新游客
        user = UserModel(
            nickname=req.nickname,
            is_visitor=True,
            device_uuid=req.device_uuid,
        )
        db.add(user)
        await db.flush()
        await db.refresh(user)

    token = create_access_token({"sub": user.id})

    return TokenResponse(
        access_token=token,
        user=UserResponse.model_validate(user),
    )


@router.get("/me", response_model=UserResponse)
async def get_profile(current_user: UserModel = Depends(get_current_user)):
    """获取当前用户信息"""
    return UserResponse.model_validate(current_user)


@router.put("/me", response_model=UserResponse)
async def update_profile(
    req: UserUpdateRequest,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """更新用户信息"""
    if req.nickname is not None:
        current_user.nickname = req.nickname
    if req.avatar_url is not None:
        current_user.avatar_url = req.avatar_url

    db.add(current_user)
    await db.flush()
    await db.refresh(current_user)

    return UserResponse.model_validate(current_user)


@router.delete("/account")
async def delete_account(
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """注销账号（匿名化处理）"""
    # 获取用户所有会话 ID
    session_ids_subq = select(SessionModel.id).where(
        SessionModel.user_id == current_user.id
    )

    # 级联删除用户数据
    await db.execute(
        delete(MessageModel).where(
            MessageModel.session_id.in_(session_ids_subq)
        )
    )
    await db.execute(
        delete(PosterModel).where(PosterModel.user_id == current_user.id)
    )
    await db.execute(
        delete(SessionModel).where(SessionModel.user_id == current_user.id)
    )
    await db.execute(
        delete(TargetModel).where(TargetModel.user_id == current_user.id)
    )
    await db.execute(
        delete(ConsentRecord).where(ConsentRecord.user_id == current_user.id)
    )

    # 匿名化用户记录
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
    """导出用户所有数据（数据可携带权）"""
    # 获取会话
    result = await db.execute(
        select(SessionModel).where(
            SessionModel.user_id == current_user.id
        ).order_by(SessionModel.created_at)
    )
    sessions = result.scalars().all()

    # 获取每个会话的消息
    session_ids = [s.id for s in sessions]
    messages_data = []
    if session_ids:
        result = await db.execute(
            select(MessageModel).where(
                MessageModel.session_id.in_(session_ids)
            ).order_by(MessageModel.sequence)
        )
        messages = result.scalars().all()
        messages_data = [
            {
                "id": m.id,
                "session_id": m.session_id,
                "content": m.content,
                "sender": m.sender,
                "created_at": m.created_at.isoformat() if m.created_at else None,
            }
            for m in messages
        ]

    # 获取目标
    result = await db.execute(
        select(TargetModel).where(
            TargetModel.user_id == current_user.id,
            TargetModel.is_deleted == False,
        )
    )
    targets = result.scalars().all()

    # 获取海报
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
                "id": t.id,
                "name": t.name,
                "type": t.type,
                "created_at": t.created_at.isoformat() if t.created_at else None,
            }
            for t in targets
        ],
        "sessions": [
            {
                "id": s.id,
                "target_id": s.target_id,
                "mode": s.mode,
                "duration_minutes": s.duration_minutes,
                "status": s.status,
                "start_time": s.start_time.isoformat() if s.start_time else None,
                "end_time": s.end_time.isoformat() if s.end_time else None,
                "created_at": s.created_at.isoformat() if s.created_at else None,
            }
            for s in sessions
        ],
        "messages": messages_data,
        "posters": [
            {
                "id": p.id,
                "session_id": p.session_id,
                "title": p.title,
                "emotion_type": p.emotion_type,
                "created_at": p.created_at.isoformat() if p.created_at else None,
            }
            for p in posters
        ],
        "export_time": datetime.now(timezone.utc).isoformat(),
    }
