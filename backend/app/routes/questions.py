import random
from typing import Optional

from fastapi import APIRouter, Query

from .. import supabase
from ..topics import resolve_topic

router = APIRouter(tags=["questions"])

QUESTION_COLUMNS = "id,module,category_id,topic,question,options,correct_index,explanation,difficulty"


async def _filters(module: str, category_id: Optional[str], topic: Optional[str], difficulty: Optional[str]) -> dict:
    params = {"module": f"eq.{module}", "is_active": "eq.true"}
    if category_id:
        params["category_id"] = f"eq.{category_id}"
    if topic:
        # Exact topic filter: only rows stored under this one topic are ever returned.
        params["topic"] = f"eq.{await resolve_topic(module, category_id, topic)}"
    if difficulty and difficulty != "All":
        params["difficulty"] = f"eq.{difficulty}"
    return params


@router.get("/questions")
async def list_questions(
    module: str,
    category_id: Optional[str] = None,
    topic: Optional[str] = None,
    difficulty: Optional[str] = None,
    limit: int = Query(15, ge=1, le=200),
    shuffle: bool = False,
):
    """GET /api/questions?module=aptitude&category_id=quant&topic=Percentage"""
    params = await _filters(module, category_id, topic, difficulty)
    params["select"] = QUESTION_COLUMNS
    params["order"] = "sort_order.asc,created_at.asc,id.asc"
    if shuffle:
        rows = await supabase.select_all("questions", params, max_rows=2000)
        random.shuffle(rows)
        return rows[:limit]
    params["limit"] = str(limit)
    return await supabase.select("questions", params)


@router.get("/questions/count")
async def count_questions(
    module: str,
    category_id: Optional[str] = None,
    topic: Optional[str] = None,
    difficulty: Optional[str] = None,
):
    params = await _filters(module, category_id, topic, difficulty)
    return {"count": await supabase.count("questions", params)}
