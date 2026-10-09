from contextlib import asynccontextmanager

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from . import supabase
from .config import settings
from .routes import (
    bookmarks,
    categories,
    coding,
    companies,
    gd,
    interviews,
    performance,
    presentation,
    questions,
)


@asynccontextmanager
async def lifespan(_: FastAPI):
    yield
    await supabase.close_client()


app = FastAPI(title="PrepNest API", version="2.0.0", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(supabase.SupabaseError)
async def supabase_error_handler(_: Request, exc: supabase.SupabaseError):
    return JSONResponse(status_code=exc.status_code, content={"detail": exc.message})


@app.get("/")
async def root():
    return {"service": "PrepNest API", "docs": "/docs", "health": "/api/health"}


@app.get("/api/health")
async def health():
    database, detail = "not_configured", None
    if settings.supabase_configured:
        try:
            await supabase.select("categories", {"select": "id", "limit": "1"})
            database = "connected"
        except supabase.SupabaseError as exc:
            database, detail = "error", exc.message
    return {"status": "ok", "service": "PrepNest API", "database": database, "detail": detail}


for module in (categories, questions, coding, companies, gd, presentation, performance, bookmarks, interviews):
    app.include_router(module.router, prefix="/api")
