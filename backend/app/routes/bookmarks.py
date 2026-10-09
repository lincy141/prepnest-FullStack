from typing import Any, Dict, Optional
from uuid import UUID

from fastapi import APIRouter, Query
from pydantic import BaseModel, Field

from .. import supabase
from ..users import ensure_profile

router = APIRouter(tags=["bookmarks"])


class BookmarkIn(BaseModel):
    user_id: UUID
    item_type: str = Field(min_length=1, max_length=40)
    item_id: str = Field(min_length=1, max_length=200)
    module: Optional[str] = None
    label: Optional[str] = Field(default=None, max_length=300)
    meta: Dict[str, Any] = {}


@router.post("/bookmarks")
async def save_bookmark(body: BookmarkIn):
    payload = body.model_dump(mode="json")
    payload["user_id"] = await ensure_profile(body.user_id)
    rows = await supabase.upsert("bookmarks", payload, on_conflict="user_id,item_type,item_id")
    return rows[0] if rows else payload


@router.get("/bookmarks")
async def list_bookmarks(user_id: UUID):
    return await supabase.select(
        "bookmarks", {"select": "*", "user_id": f"eq.{user_id}", "order": "created_at.desc"}
    )


@router.delete("/bookmarks")
async def delete_bookmark(user_id: UUID, item_type: str = Query(...), item_id: str = Query(...)):
    removed = await supabase.delete(
        "bookmarks",
        {"user_id": f"eq.{user_id}", "item_type": f"eq.{item_type}", "item_id": f"eq.{item_id}"},
    )
    return {"deleted": len(removed)}
