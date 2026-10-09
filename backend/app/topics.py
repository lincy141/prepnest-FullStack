"""Exact-topic resolution.

The database stores each question under one canonical topic name (e.g. "Percentage").
Requests may spell it slightly differently ("Percentages", "percentage",
"Coding-Decoding", "Time Speed Distance"). `resolve_topic` maps the request onto the
canonical name from the categories table so the query that follows is an exact `eq`
filter - topics are never mixed or fuzzily matched.
"""
import re
import time
from typing import Dict, List, Optional

from . import supabase

_TTL_SECONDS = 60
_cache: Dict[str, tuple] = {}


def normalize(value: str) -> str:
    key = re.sub(r"[^a-z0-9+#]", "", value.lower())
    if len(key) > 3 and key.endswith("s"):
        key = key[:-1]
    return key


async def categories_for(module: Optional[str]) -> List[dict]:
    cache_key = module or "*"
    hit = _cache.get(cache_key)
    if hit and time.monotonic() - hit[0] < _TTL_SECONDS:
        return hit[1]
    params = {"select": "*", "is_active": "eq.true", "order": "sort_order.asc,id.asc"}
    if module:
        params["module"] = f"eq.{module}"
    rows = await supabase.select("categories", params)
    _cache[cache_key] = (time.monotonic(), rows)
    return rows


def clear_cache() -> None:
    _cache.clear()


async def resolve_topic(module: str, category_id: Optional[str], topic: str) -> str:
    wanted = normalize(topic)
    for category in await categories_for(module):
        if category_id and category["id"] != category_id:
            continue
        for known in category.get("topics") or []:
            if normalize(known) == wanted:
                return known
    return topic
