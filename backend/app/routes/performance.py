from typing import List, Literal, Optional
from uuid import UUID

from fastapi import APIRouter, HTTPException, Query
from pydantic import BaseModel, Field

from .. import supabase
from ..stats import build_dashboard, build_performance
from ..users import ensure_profile

router = APIRouter(tags=["performance"])

ATTEMPT_COLUMNS = "module,category_id,topic,difficulty,mode,score,correct,wrong,unanswered,total,duration_seconds,created_at"


class AttemptIn(BaseModel):
    user_id: UUID
    module: str = Field(min_length=1, max_length=40)          # aptitude | technical | coding | hr | company
    category_id: Optional[str] = Field(default=None, max_length=80)
    topic: Optional[str] = Field(default=None, max_length=200)
    difficulty: Optional[str] = Field(default=None, max_length=20)
    mode: Literal["practice", "full-mock", "company-mock"] = "practice"
    correct: int = Field(default=0, ge=0)
    wrong: int = Field(default=0, ge=0)
    unanswered: int = Field(default=0, ge=0)
    total: int = Field(default=0, ge=0)
    score: Optional[int] = Field(default=None, ge=0, le=100)  # computed from correct/total when omitted
    duration_seconds: int = Field(default=0, ge=0, le=86400)


@router.post("/attempts")
async def create_attempt(body: AttemptIn):
    if body.correct > body.total:
        raise HTTPException(422, "correct cannot be greater than total")
    payload = body.model_dump(mode="json")
    if payload["score"] is None:
        payload["score"] = round(100 * body.correct / body.total) if body.total else 0
    payload["user_id"] = await ensure_profile(body.user_id)
    rows = await supabase.insert("test_attempts", payload)
    return rows[0] if rows else payload


async def _load(user_id: UUID):
    attempts = await supabase.select_all(
        "test_attempts", {"select": ATTEMPT_COLUMNS, "user_id": f"eq.{user_id}", "order": "created_at.desc"}, max_rows=3000
    )
    interviews = await supabase.select_all(
        "interview_results",
        {"select": "interview_type,overall,categories,created_at", "user_id": f"eq.{user_id}", "order": "created_at.desc"},
        max_rows=1000,
    )
    return attempts, interviews


@router.get("/performance")
async def performance(user_id: UUID, tz_offset: int = Query(0, ge=-900, le=900)):
    """Charts and category scores for the Performance page, computed from test_attempts + interview_results."""
    attempts, interviews = await _load(user_id)
    result = build_performance(attempts, interviews, tz_offset)
    result["attempts"] = attempts[:100]
    return result


@router.get("/dashboard")
async def dashboard(user_id: UUID, tz_offset: int = Query(0, ge=-900, le=900)):
    """Totals, per-module numbers and topic-wise results used across the dashboard and module pages."""
    attempts, interviews = await _load(user_id)
    return build_dashboard(attempts, interviews, tz_offset)
