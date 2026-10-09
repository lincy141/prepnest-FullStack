from typing import Optional

from fastapi import APIRouter, HTTPException, Query

from .. import supabase

router = APIRouter(tags=["coding"])

# `solution` is intentionally left out of the list endpoint.
LIST_COLUMNS = "id,category_id,title,difficulty,statement,input,output,examples,constraints,starter_code,sort_order"


@router.get("/coding/problems")
async def list_problems(
    category_id: Optional[str] = None,
    difficulty: Optional[str] = None,
    limit: int = Query(20, ge=1, le=100),
):
    """GET /api/coding/problems?category_id=arrays"""
    params = {
        "select": LIST_COLUMNS,
        "is_active": "eq.true",
        "order": "sort_order.asc,created_at.asc,id.asc",
        "limit": str(limit),
    }
    if category_id:
        params["category_id"] = f"eq.{category_id}"
    if difficulty and difficulty != "All":
        params["difficulty"] = f"eq.{difficulty}"
    return await supabase.select("coding_problems", params)


@router.get("/coding/problems/{problem_id}")
async def get_problem(problem_id: str):
    rows = await supabase.select("coding_problems", {"select": "*", "id": f"eq.{problem_id}", "limit": "1"})
    if not rows:
        raise HTTPException(404, "Coding problem not found")
    return rows[0]
