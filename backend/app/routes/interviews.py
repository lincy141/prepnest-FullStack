from typing import Any, Dict, List, Optional
from uuid import UUID

from fastapi import APIRouter, Query
from pydantic import BaseModel, Field

from .. import supabase
from ..users import ensure_profile

router = APIRouter(tags=["interviews"])


class InterviewResultIn(BaseModel):
    user_id: UUID
    interview_type: Optional[str] = None
    role: Optional[str] = None
    difficulty: Optional[str] = None
    overall: int = Field(ge=0, le=100)
    categories: Dict[str, Any] = {}
    strengths: List[str] = []
    improve: List[str] = []
    duration_seconds: int = Field(default=0, ge=0, le=86400)
    transcript: List[Dict[str, Any]] = []


@router.post("/interview-results")
async def save_interview_result(body: InterviewResultIn):
    payload = body.model_dump(mode="json")
    payload["user_id"] = await ensure_profile(body.user_id)
    rows = await supabase.insert("interview_results", payload)
    return rows[0] if rows else payload


@router.get("/interview-results")
async def list_interview_results(user_id: UUID, limit: int = Query(20, ge=1, le=100)):
    return await supabase.select(
        "interview_results",
        {
            "select": "id,interview_type,role,difficulty,overall,categories,strengths,improve,duration_seconds,created_at",
            "user_id": f"eq.{user_id}",
            "order": "created_at.desc",
            "limit": str(limit),
        },
    )
