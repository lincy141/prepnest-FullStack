from collections import Counter
from typing import Optional

from fastapi import APIRouter

from .. import supabase

router = APIRouter(tags=["categories"])


@router.get("/categories")
async def list_categories(module: Optional[str] = None, kind: Optional[str] = None, counts: bool = False):
    """Categories and their topics, straight from the `categories` table.

    counts=true adds `topic_counts` (questions per topic) for question modules,
    or `item_count` (problems per category) for the coding module.
    """
    params = {"select": "*", "is_active": "eq.true", "order": "sort_order.asc,id.asc"}
    if module:
        params["module"] = f"eq.{module}"
    if kind:
        params["kind"] = f"eq.{kind}"
    categories = await supabase.select("categories", params)

    if counts and categories:
        modules = {c["module"] for c in categories}
        topic_counts: Counter = Counter()
        problem_counts: Counter = Counter()

        if "coding" in modules:
            problems = await supabase.select_all("coding_problems", {"select": "category_id", "is_active": "eq.true"})
            problem_counts.update(p["category_id"] for p in problems)

        question_modules = modules - {"coding"}
        if question_modules:
            q_params = {"select": "category_id,topic", "is_active": "eq.true"}
            if module and module != "coding":
                q_params["module"] = f"eq.{module}"
            questions = await supabase.select_all("questions", q_params)
            topic_counts.update((q["category_id"], q["topic"]) for q in questions)

        for category in categories:
            if category["module"] == "coding":
                category["item_count"] = problem_counts.get(category["id"], 0)
                category["topic_counts"] = {}
            else:
                per_topic = {t: topic_counts.get((category["id"], t), 0) for t in category.get("topics") or []}
                category["topic_counts"] = per_topic
                category["item_count"] = sum(per_topic.values())

    return categories
