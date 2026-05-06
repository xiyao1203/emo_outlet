from __future__ import annotations

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
from app.services.ai_service import ai_service, image_service

router = APIRouter(prefix="/api/targets", tags=["targets"])


@router.get("", response_model=list[TargetResponse])
async def list_targets(
    include_hidden: bool = False,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    query = select(TargetModel).where(
        TargetModel.user_id == current_user.id,
        TargetModel.is_deleted == False,
    )
    if not include_hidden:
        query = query.where(TargetModel.is_hidden == False)

    result = await db.execute(query.order_by(TargetModel.updated_at.desc()))
    return [TargetResponse.model_validate(item) for item in result.scalars().all()]


@router.post("", response_model=TargetResponse, status_code=status.HTTP_201_CREATED)
async def create_target(
    req: TargetCreateRequest,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
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
    result = await db.execute(
        select(TargetModel).where(
            TargetModel.id == target_id,
            TargetModel.user_id == current_user.id,
            TargetModel.is_deleted == False,
        )
    )
    target = result.scalar_one_or_none()
    if target is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Target not found")
    return TargetResponse.model_validate(target)


@router.put("/{target_id}", response_model=TargetResponse)
async def update_target(
    target_id: str,
    req: TargetUpdateRequest,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(TargetModel).where(
            TargetModel.id == target_id,
            TargetModel.user_id == current_user.id,
        )
    )
    target = result.scalar_one_or_none()
    if target is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Target not found")

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
    result = await db.execute(
        select(TargetModel).where(
            TargetModel.id == target_id,
            TargetModel.user_id == current_user.id,
        )
    )
    target = result.scalar_one_or_none()
    if target is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Target not found")

    target.is_deleted = True
    db.add(target)
    return {"message": "Target deleted"}


@router.post("/{target_id}/generate-avatar", response_model=TargetResponse)
async def generate_avatar(
    target_id: str,
    current_user: UserModel = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(TargetModel).where(
            TargetModel.id == target_id,
            TargetModel.user_id == current_user.id,
        )
    )
    target = result.scalar_one_or_none()
    if target is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Target not found")

    try:
        target.avatar_url = await image_service.generate_avatar(
            appearance=target.appearance or "柔和、亲切、让人有安全感",
            personality=target.personality or "温和、愿意倾听",
            style=target.style or "Q版",
        )
    except RuntimeError as exc:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=str(exc),
        ) from exc

    db.add(target)
    await db.flush()
    await db.refresh(target)
    return TargetResponse.model_validate(target)


@router.post("/ai-complete", response_model=TargetAiCompleteResponse)
async def ai_complete_target(req: TargetAiCompleteRequest):
    payload = await ai_service.complete_target_profile(
        name=req.name,
        relationship=req.relationship,
    )
    return TargetAiCompleteResponse(**payload)
