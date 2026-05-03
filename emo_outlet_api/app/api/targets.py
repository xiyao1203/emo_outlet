"""泄愤对象 API 路由"""
from __future__ import annotations

import random

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.dependencies import get_current_user
from app.database import get_db
from app.models.target import TargetModel
from app.models.user import UserModel
from app.schemas.target import (
    TargetAiCompleteRequest,
    TargetAiCompleteResponse,
    TargetCreateRequest,
    TargetResponse,
    TargetUpdateRequest,
)
from app.services.ai_service import image_service

router = APIRouter(prefix="/api/targets", tags=["泄愤对象"])


@router.get("", response_model=list[TargetResponse])
async def list_targets(
    include_hidden: bool = False,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """获取用户的泄愤对象列表"""
    query = select(TargetModel).where(
        TargetModel.user_id == current_user.id,
        TargetModel.is_deleted == False,
    )
    if not include_hidden:
        query = query.where(TargetModel.is_hidden == False)

    query = query.order_by(TargetModel.updated_at.desc())
    result = await db.execute(query)
    targets = result.scalars().all()

    return [TargetResponse.model_validate(t) for t in targets]


@router.post("", response_model=TargetResponse, status_code=status.HTTP_201_CREATED)
async def create_target(
    req: TargetCreateRequest,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """创建泄愤对象"""
    target = TargetModel(
        user_id=current_user.id,
        name=req.name,
        type=req.type,
        appearance=req.appearance or "",
        personality=req.personality or "",
        relation=req.relationship or "",
        style=req.style,
    )
    db.add(target)
    await db.flush()
    await db.refresh(target)
    return TargetResponse.model_validate(target)


@router.get("/{target_id}", response_model=TargetResponse)
async def get_target(
    target_id: str,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """获取泄愤对象详情"""
    result = await db.execute(
        select(TargetModel).where(
            TargetModel.id == target_id,
            TargetModel.user_id == current_user.id,
            TargetModel.is_deleted == False,
        )
    )
    target = result.scalar_one_or_none()
    if not target:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="对象不存在",
        )
    return TargetResponse.model_validate(target)


@router.put("/{target_id}", response_model=TargetResponse)
async def update_target(
    target_id: str,
    req: TargetUpdateRequest,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """更新泄愤对象"""
    result = await db.execute(
        select(TargetModel).where(
            TargetModel.id == target_id,
            TargetModel.user_id == current_user.id,
        )
    )
    target = result.scalar_one_or_none()
    if not target:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    if req.name is not None:
        target.name = req.name
    if req.type is not None:
        target.type = req.type
    if req.appearance is not None:
        target.appearance = req.appearance
    if req.personality is not None:
        target.personality = req.personality
    if req.relationship is not None:
        target.relation = req.relationship
    if req.style is not None:
        target.style = req.style
    if req.is_hidden is not None:
        target.is_hidden = req.is_hidden

    db.add(target)
    await db.flush()
    await db.refresh(target)
    return TargetResponse.model_validate(target)


@router.delete("/{target_id}")
async def delete_target(
    target_id: str,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """删除泄愤对象（软删除）"""
    result = await db.execute(
        select(TargetModel).where(
            TargetModel.id == target_id,
            TargetModel.user_id == current_user.id,
        )
    )
    target = result.scalar_one_or_none()
    if not target:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    target.is_deleted = True
    db.add(target)
    return {"message": "对象已删除"}


@router.post("/{target_id}/generate-avatar", response_model=TargetResponse)
async def generate_avatar(
    target_id: str,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """为泄愤对象生成 AI 虚拟形象"""
    result = await db.execute(
        select(TargetModel).where(
            TargetModel.id == target_id,
            TargetModel.user_id == current_user.id,
        )
    )
    target = result.scalar_one_or_none()
    if not target:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND)

    # 调用 AI 生成头像
    avatar_url = await image_service.generate_avatar(
        appearance=target.appearance or "默认形象",
        personality=target.personality or "普通",
        style=target.style,
    )
    target.avatar_url = avatar_url
    db.add(target)
    await db.flush()
    await db.refresh(target)

    return TargetResponse.model_validate(target)


@router.post("/ai-complete", response_model=TargetAiCompleteResponse)
async def ai_complete_target(req: TargetAiCompleteRequest):
    """AI 补全泄愤对象信息（建议 2：AI 自动补全）"""
    # 模拟 AI 补全（实际应调用 LLM）
    type_map = {
        "老板": ("boss", "中年男性，西装革履", "爱甩锅、推责任", "漫画"),
        "领导": ("boss", "中年男性，严肃表情", "严格、挑剔、不近人情", "写实"),
        "同事": ("colleague", "同龄人打扮", "爱算计、两面派", "漫画"),
        "伴侣": ("spouse", "日常休闲装扮", "爱唠叨、不理解自己", "漫画"),
        "客户": ("客户", "商务装扮", "挑剔、难缠、要求多", "写实"),
        "朋友": ("friend", "随意装扮", "爱炫耀、不靠谱", "Q版"),
    }

    default_info = ("custom", "自定义形象", "自定义性格", "漫画")

    for key, info in type_map.items():
        if key in req.relationship:
            _, appearance, personality, style = info
            return TargetAiCompleteResponse(
                appearance=appearance,
                personality=personality,
                style=style,
            )

    return TargetAiCompleteResponse(
        appearance=default_info[1],
        personality=default_info[2],
        style=default_info[3],
    )
