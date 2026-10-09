from fastapi import APIRouter

from .. import supabase

router = APIRouter(tags=["presentation"])


@router.get("/presentation/topics")
async def presentation_topics():
    return await supabase.select(
        "presentation_topics", {"select": "*", "is_active": "eq.true", "order": "sort_order.asc"}
    )
