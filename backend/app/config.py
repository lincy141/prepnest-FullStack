from pathlib import Path
from typing import List

from pydantic_settings import BaseSettings, SettingsConfigDict

BACKEND_DIR = Path(__file__).resolve().parent.parent


class Settings(BaseSettings):
    """Backend settings, read from backend/.env (or real environment variables).

    SUPABASE_SERVICE_ROLE_KEY is a secret. It lives ONLY here, on the server.
    It must never be placed in the React app or in any VITE_* variable.
    """

    supabase_url: str = ""
    supabase_service_role_key: str = ""
    # One origin, or several separated by commas (e.g. local + deployed frontend).
    frontend_url: str = "http://localhost:5173"
    backend_host: str = "127.0.0.1"
    backend_port: int = 8000

    model_config = SettingsConfigDict(env_file=BACKEND_DIR / ".env", extra="ignore")

    @property
    def supabase_configured(self) -> bool:
        return bool(self.supabase_url.strip() and self.supabase_service_role_key.strip())

    @property
    def cors_origins(self) -> List[str]:
        origins = {o.strip().rstrip("/") for o in self.frontend_url.split(",") if o.strip()}
        origins |= {"http://localhost:5173", "http://127.0.0.1:5173"}
        return sorted(origins)


settings = Settings()
