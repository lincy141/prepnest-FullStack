import random
from typing import List

from fastapi import APIRouter, HTTPException, Query

from .. import supabase
from ..supabase import pg_in
from .questions import QUESTION_COLUMNS

router = APIRouter(tags=["companies"])


@router.get("/companies")
async def list_companies():
    return await supabase.select(
        "companies", {"select": "*", "is_active": "eq.true", "order": "sort_order.asc,name.asc"}
    )


async def _get_company(company_id: str) -> dict:
    rows = await supabase.select("companies", {"select": "*", "id": f"eq.{company_id}", "limit": "1"})
    if not rows:
        raise HTTPException(404, "Company not found")
    return rows[0]


@router.get("/companies/{company_id}")
async def get_company(company_id: str):
    return await _get_company(company_id)


@router.get("/companies/{company_id}/mock-questions")
async def company_mock_questions(company_id: str, limit: int = Query(10, ge=1, le=50)):
    """Mock test for a company, built from that company's focus topics (stored in Supabase)."""
    company = await _get_company(company_id)
    focus = company.get("focus_topics") or {}

    pools: List[List[dict]] = []
    for module in ("aptitude", "technical"):
        topics = focus.get(module) or []
        if not topics:
            continue
        rows = await supabase.select_all(
            "questions",
            {"select": QUESTION_COLUMNS, "module": f"eq.{module}", "topic": pg_in(topics), "is_active": "eq.true"},
        )
        random.shuffle(rows)
        pools.append(rows)

    mixed: List[dict] = []
    while len(mixed) < limit and any(pools):
        for pool in pools:
            if pool and len(mixed) < limit:
                mixed.append(pool.pop())
    return mixed
