"""Thin async client for the Supabase REST API (PostgREST).

The backend talks to Supabase PostgreSQL only through this module, using the
service-role key that is configured on the server.
"""
from typing import Any, Dict, Iterable, List, Optional

import httpx

from .config import settings


class SupabaseError(Exception):
    """Raised for any failure talking to Supabase; carries an HTTP status for the API response."""

    def __init__(self, status_code: int, message: str):
        super().__init__(message)
        self.status_code = status_code
        self.message = message


_client: Optional[httpx.AsyncClient] = None


def _base_url() -> str:
    if not settings.supabase_configured:
        raise SupabaseError(
            503,
            "Supabase is not configured. Set SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY in backend/.env.",
        )
    return settings.supabase_url.rstrip("/") + "/rest/v1"


def _get_client() -> httpx.AsyncClient:
    global _client
    if _client is None:
        _client = httpx.AsyncClient(timeout=20)
    return _client


async def close_client() -> None:
    global _client
    if _client is not None:
        await _client.aclose()
        _client = None


def _headers(extra: Optional[Dict[str, str]] = None) -> Dict[str, str]:
    key = settings.supabase_service_role_key
    headers = {
        "apikey": key,
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
    }
    if extra:
        headers.update(extra)
    return headers


def _error_from(response: httpx.Response) -> SupabaseError:
    message = f"Supabase returned HTTP {response.status_code}"
    code = ""
    try:
        body = response.json()
        message = body.get("message") or message
        code = body.get("code") or ""
        if body.get("hint"):
            message = f"{message} ({body['hint']})"
    except Exception:  # noqa: BLE001 - body is not JSON
        if response.text:
            message = response.text[:300]

    if response.status_code in (401, 403):
        return SupabaseError(502, "Supabase rejected the credentials. Check SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY.")
    if code.startswith("PGRST2") or code in ("42P01", "42703"):
        return SupabaseError(500, f"{message}. Did you run backend/sql/schema.sql and seed.sql in the Supabase SQL Editor?")
    if response.status_code == 409:
        return SupabaseError(409, message)
    if response.status_code in (400, 404, 406, 416, 422):
        return SupabaseError(400, message)
    return SupabaseError(502, message)


async def _request(
    method: str,
    table: str,
    *,
    params: Optional[Dict[str, str]] = None,
    json: Any = None,
    prefer: Optional[str] = None,
    extra_headers: Optional[Dict[str, str]] = None,
) -> httpx.Response:
    url = f"{_base_url()}/{table}"
    headers = _headers(extra_headers)
    if prefer:
        headers["Prefer"] = prefer
    try:
        response = await _get_client().request(method, url, params=params or {}, json=json, headers=headers)
    except httpx.TimeoutException as exc:
        raise SupabaseError(504, "Supabase took too long to respond.") from exc
    except httpx.HTTPError as exc:
        raise SupabaseError(502, f"Could not reach Supabase: {exc}") from exc
    if response.status_code >= 400:
        raise _error_from(response)
    return response


def pg_in(values: Iterable[str]) -> str:
    """Build a PostgREST `in.(...)` filter, quoting values that contain commas, quotes, etc."""
    quoted = []
    for value in values:
        escaped = str(value).replace("\\", "\\\\").replace('"', '\\"')
        quoted.append(f'"{escaped}"')
    return f"in.({','.join(quoted)})"


async def select(table: str, params: Optional[Dict[str, str]] = None) -> List[Dict[str, Any]]:
    response = await _request("GET", table, params=params)
    return response.json()


async def select_all(table: str, params: Optional[Dict[str, str]] = None, max_rows: int = 5000) -> List[Dict[str, Any]]:
    """Fetch every matching row, paging through Supabase's 1000-row response cap."""
    page_size = 1000
    rows: List[Dict[str, Any]] = []
    offset = 0
    while offset < max_rows:
        page_params = dict(params or {})
        page_params["limit"] = str(min(page_size, max_rows - offset))
        page_params["offset"] = str(offset)
        page = await select(table, page_params)
        rows.extend(page)
        if len(page) < page_size:
            break
        offset += page_size
    return rows


async def count(table: str, params: Optional[Dict[str, str]] = None) -> int:
    query = dict(params or {})
    query.update({"select": "id", "limit": "1"})
    response = await _request("GET", table, params=query, prefer="count=exact")
    content_range = response.headers.get("content-range", "")
    total = content_range.split("/")[-1]
    return int(total) if total.isdigit() else 0


async def insert(table: str, payload: Any) -> List[Dict[str, Any]]:
    response = await _request("POST", table, json=payload, prefer="return=representation")
    return response.json()


async def upsert(
    table: str,
    payload: Any,
    on_conflict: Optional[str] = None,
    ignore_duplicates: bool = False,
) -> List[Dict[str, Any]]:
    resolution = "ignore-duplicates" if ignore_duplicates else "merge-duplicates"
    params = {"on_conflict": on_conflict} if on_conflict else None
    response = await _request(
        "POST", table, params=params, json=payload, prefer=f"resolution={resolution},return=representation"
    )
    return response.json()


async def delete(table: str, params: Dict[str, str]) -> List[Dict[str, Any]]:
    response = await _request("DELETE", table, params=params, prefer="return=representation")
    return response.json()
