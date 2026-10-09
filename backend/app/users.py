"""PrepNest has no login yet, so the browser sends an anonymous per-device user id (a UUID).

Rows in test_attempts / interview_results / bookmarks reference profiles(id), so the profile
row is created the first time a user id writes anything. When real authentication is added
(e.g. Supabase Auth), the id from the verified token replaces this anonymous id.
"""
from typing import Set
from uuid import UUID

from . import supabase

_known: Set[str] = set()


async def ensure_profile(user_id: UUID) -> str:
    uid = str(user_id)
    if uid not in _known:
        await supabase.upsert("profiles", {"id": uid}, on_conflict="id", ignore_duplicates=True)
        _known.add(uid)
    return uid
