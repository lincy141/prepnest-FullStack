"""Pure functions that turn stored attempts / interview results into dashboard numbers.

Nothing here talks to the network, so it is easy to test.
"""
import re
from collections import defaultdict
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Iterable, List, Optional, Tuple

MCQ_MODULES = {"aptitude", "technical", "hr", "company"}
STANDARD_MODULES = ("aptitude", "technical", "coding", "hr")


def parse_ts(value: str) -> datetime:
    """Parse a PostgREST timestamp (fractional seconds can have 1-6 digits)."""
    text = value.replace("Z", "+00:00")
    text = re.sub(r"\.(\d+)", lambda m: "." + m.group(1).ljust(6, "0")[:6], text)
    dt = datetime.fromisoformat(text)
    return dt if dt.tzinfo else dt.replace(tzinfo=timezone.utc)


def _avg(values: List[float]) -> Optional[int]:
    return round(sum(values) / len(values)) if values else None


def _local_day(dt: datetime, tz_offset: int):
    # tz_offset follows JavaScript's Date.getTimezoneOffset(): minutes UTC is ahead of local time.
    return (dt - timedelta(minutes=tz_offset)).date()


def _streaks(days: Iterable, today) -> Tuple[int, int]:
    ordered = sorted(set(days))
    if not ordered:
        return 0, 0
    best = run = 1
    for prev, cur in zip(ordered, ordered[1:]):
        run = run + 1 if (cur - prev).days == 1 else 1
        best = max(best, run)
    # Current streak: consecutive days ending today (or yesterday, so it isn't "lost" until a day is missed).
    day_set = set(ordered)
    cursor = today if today in day_set else today - timedelta(days=1)
    current = 0
    while cursor in day_set:
        current += 1
        cursor -= timedelta(days=1)
    return current, best


def _module_stats(rows: List[dict]) -> Dict[str, Any]:
    solved = sum(r["correct"] + r["wrong"] for r in rows)
    correct = sum(r["correct"] for r in rows)
    return {
        "tests": len(rows),
        "avg_score": _avg([r["score"] for r in rows]),
        "best_score": max((r["score"] for r in rows), default=None),
        "questions_solved": solved,
        "accuracy": round(100 * correct / solved) if solved else None,
    }


def build_dashboard(attempts: List[dict], interviews: List[dict], tz_offset: int = 0, now: Optional[datetime] = None) -> Dict[str, Any]:
    now = now or datetime.now(timezone.utc)
    today = _local_day(now, tz_offset)
    rows = [{**a, "_ts": parse_ts(a["created_at"])} for a in attempts]
    ivs = [{**i, "_ts": parse_ts(i["created_at"])} for i in interviews]

    week_ago, month_ago, two_months_ago = now - timedelta(days=7), now - timedelta(days=30), now - timedelta(days=60)
    recent_scores = [r["score"] for r in rows if r["_ts"] >= month_ago]
    previous_scores = [r["score"] for r in rows if two_months_ago <= r["_ts"] < month_ago]
    avg_change = None
    if recent_scores and previous_scores:
        avg_change = round(sum(recent_scores) / len(recent_scores) - sum(previous_scores) / len(previous_scores))

    active_days = [_local_day(r["_ts"], tz_offset) for r in rows] + [_local_day(i["_ts"], tz_offset) for i in ivs]
    streak, best_streak = _streaks(active_days, today)

    mcq_rows = [r for r in rows if r["module"] in MCQ_MODULES]
    mcq_answered = sum(r["correct"] + r["wrong"] for r in mcq_rows)

    by_module: Dict[str, List[dict]] = defaultdict(list)
    for r in rows:
        by_module[r["module"]].append(r)
    modules = {m: _module_stats(by_module.get(m, [])) for m in STANDARD_MODULES}
    for m, items in by_module.items():
        modules.setdefault(m, _module_stats(items))

    # Topic-wise results come from normal practice tests only (full / company mocks mix topics).
    topic_groups: Dict[Tuple[str, str, str], List[dict]] = defaultdict(list)
    for r in rows:
        if r.get("mode", "practice") == "practice" and r.get("topic"):
            topic_groups[(r["module"], r.get("category_id") or "", r["topic"])].append(r)
    topics = []
    for (module, category_id, topic), items in topic_groups.items():
        topics.append({
            "module": module,
            "category_id": category_id,
            "topic": topic,
            "attempts": len(items),
            "best_score": max(i["score"] for i in items),
            "avg_score": _avg([i["score"] for i in items]),
            "last_attempt": max(i["_ts"] for i in items).isoformat(),
        })
    topics.sort(key=lambda t: (t["module"], t["category_id"], t["topic"]))

    coding_rows = by_module.get("coding", [])
    solved_problems: Dict[Tuple[str, str], Optional[str]] = {}
    for r in coding_rows:
        if r["correct"] > 0:
            solved_problems[(r.get("category_id") or "", r.get("topic") or "")] = r.get("difficulty")
    difficulty_counts = {"Easy": 0, "Medium": 0, "Hard": 0}
    for diff in solved_problems.values():
        if diff in difficulty_counts:
            difficulty_counts[diff] += 1

    interview_scores = [i["overall"] for i in ivs]
    recent = [
        {
            "module": r["module"], "category_id": r.get("category_id"), "topic": r.get("topic"),
            "mode": r.get("mode"), "score": r["score"], "correct": r["correct"], "total": r["total"],
            "duration_seconds": r.get("duration_seconds"), "created_at": r["created_at"],
        }
        for r in rows[:10]
    ]

    return {
        "totals": {
            "tests": len(rows),
            "avg_score": _avg([r["score"] for r in rows]),
            "avg_change": avg_change,
            "questions_solved": sum(r["correct"] + r["wrong"] for r in rows),
            "accuracy": round(100 * sum(r["correct"] for r in mcq_rows) / mcq_answered) if mcq_answered else None,
            "tests_this_week": sum(1 for r in rows if r["_ts"] >= week_ago),
            "streak": streak,
            "best_streak": best_streak,
            "interviews": len(ivs),
            "technical_interviews": sum(1 for i in ivs if (i.get("interview_type") or "").startswith("Technical")),
        },
        "modules": modules,
        "topics": topics,
        "coding": {
            "solved": len(solved_problems),
            "by_difficulty": difficulty_counts,
            "accuracy": _avg([r["score"] for r in coding_rows]),
        },
        "interviews": {"count": len(ivs), "avg_score": _avg(interview_scores)},
        "recent": recent,
    }


def build_performance(attempts: List[dict], interviews: List[dict], tz_offset: int = 0, now: Optional[datetime] = None) -> Dict[str, Any]:
    now = now or datetime.now(timezone.utc)
    dash = build_dashboard(attempts, interviews, tz_offset, now)
    ivs = [{**i, "_ts": parse_ts(i["created_at"])} for i in interviews]
    rows = [{**a, "_ts": parse_ts(a["created_at"])} for a in attempts]

    hr_scores = [i["overall"] for i in ivs if i.get("interview_type") == "HR Interview"]
    ai_scores = [i["overall"] for i in ivs if i.get("interview_type") != "HR Interview"]
    communication = [
        i["categories"]["Communication"] for i in ivs
        if isinstance(i.get("categories"), dict) and isinstance(i["categories"].get("Communication"), (int, float))
    ]
    modules = dash["modules"]
    # GD and Presentation sessions are not scored by anything yet, so they report no data (None).
    categories = [
        {"name": "Aptitude", "score": modules["aptitude"]["avg_score"]},
        {"name": "Technical", "score": modules["technical"]["avg_score"]},
        {"name": "Coding", "score": modules["coding"]["avg_score"]},
        {"name": "AI Interview", "score": _avg(ai_scores)},
        {"name": "HR Interview", "score": _avg(hr_scores)},
        {"name": "GD", "score": None},
        {"name": "Presentation", "score": None},
        {"name": "Communication", "score": _avg(communication)},
    ]
    available = [c["score"] for c in categories if c["score"] is not None]

    weekly = []
    for index in range(8):  # W1 = oldest 7-day window ... W8 = most recent
        end = now - timedelta(days=7 * (7 - index))
        start = end - timedelta(days=7)
        scores = [r["score"] for r in rows if start < r["_ts"] <= end] + [i["overall"] for i in ivs if start < i["_ts"] <= end]
        weekly.append({"week": f"W{index + 1}", "score": _avg(scores)})

    history = [
        {"name": "Aptitude", "tests": modules["aptitude"]["tests"]},
        {"name": "Technical", "tests": modules["technical"]["tests"]},
        {"name": "Coding", "tests": modules["coding"]["tests"]},
        {"name": "AI Int.", "tests": len(ai_scores)},
        {"name": "HR Int.", "tests": len(hr_scores)},
        {"name": "GD", "tests": 0},
    ]

    scored_topics = [t for t in dash["topics"] if t["module"] in ("aptitude", "technical") and t["avg_score"] is not None]
    strong = sorted((t for t in scored_topics if t["avg_score"] >= 70), key=lambda t: -t["avg_score"])[:3]
    weak = sorted((t for t in scored_topics if t["avg_score"] < 70), key=lambda t: t["avg_score"])[:3]
    strengths = [f"Strong in {t['topic']} ({t['avg_score']}% average)" for t in strong]
    improve = [f"{t['topic']} needs more practice ({t['avg_score']}% average)" for t in weak]

    interview_categories: Dict[str, List[float]] = defaultdict(list)
    for i in ivs:
        if isinstance(i.get("categories"), dict):
            for name, value in i["categories"].items():
                if isinstance(value, (int, float)):
                    interview_categories[name].append(value)
    averaged = {name: sum(v) / len(v) for name, v in interview_categories.items() if v}
    if averaged:
        best_name = max(averaged, key=averaged.get)
        worst_name = min(averaged, key=averaged.get)
        if averaged[best_name] >= 70:
            strengths.append(f"Interview {best_name.lower()} ({round(averaged[best_name])}% average)")
        if averaged[worst_name] < 70:
            improve.append(f"Interview {worst_name.lower()} ({round(averaged[worst_name])}% average)")

    return {
        "has_data": bool(rows or ivs),
        "overall": _avg(available),
        "categories": categories,
        "weekly": weekly,
        "history": history,
        "strengths": strengths,
        "improve": improve,
        "weak_topics": [
            {"module": t["module"], "category_id": t["category_id"], "topic": t["topic"], "avg_score": t["avg_score"]}
            for t in weak
        ],
        "totals": dash["totals"],
    }
