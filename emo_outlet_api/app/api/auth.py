"""认证 API 路由"""
from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user
from app.core.security import (
    create_access_token,
    hash_password,
    verify_password,
)
from app.database import get_db
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
    user = UserModel(
        nickname=req.nickname or f"用户{UserModel.id}",
        phone=req.phone,
        email=req.email,
        password_hash=hash_password(req.password),
        device_uuid=req.device_uuid,
    )
    db.add(user)
    await db.flush()
    await db.refresh(user)

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
    """注销账号（软删除）"""
    current_user.is_deleted = True
    current_user.is_active = False
    db.add(current_user)
    return {"message": "账号已注销"}
