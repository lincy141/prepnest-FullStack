from typing import Optional

from fastapi import APIRouter

from .. import supabase

router = APIRouter(tags=["gd"])


@router.get("/gd/categories")
async def gd_categories():
    categories = await supabase.select(
        "gd_categories", {"select": "*", "is_active": "eq.true", "order": "sort_order.asc"}
    )
    topics = await supabase.select_all("gd_topics", {"select": "category_id", "is_active": "eq.true"})
    totals: dict = {}
    for row in topics:
        totals[row["category_id"]] = totals.get(row["category_id"], 0) + 1
    for category in categories:
        category["topic_count"] = totals.get(category["id"], 0)
    return categories


@router.get("/gd/topics")
async def gd_topics(category_id: Optional[str] = None):
    """GET /api/gd/topics?category_id=tech"""
    params = {"select": "*", "is_active": "eq.true", "order": "sort_order.asc,created_at.asc"}
    if category_id:
        params["category_id"] = f"eq.{category_id}"
    return await supabase.select("gd_topics", params)
