import logging
import os
import sys
from typing import Optional

from fastapi import FastAPI
from pydantic import BaseModel


class Settings(BaseModel):
    app_name: str = os.getenv("APP_NAME", "secure-fastapi")
    app_version: str = os.getenv("APP_VERSION", "0.1.0")
    log_level: str = os.getenv("LOG_LEVEL", "INFO")
    log_json: bool = os.getenv("LOG_JSON", "false").lower() == "true"


settings = Settings()


def _setup_logging() -> None:
    level = getattr(logging, settings.log_level.upper(), logging.INFO)
    handler = logging.StreamHandler(sys.stdout)
    if settings.log_json:
        formatter = logging.Formatter(
            '{"time":"%(asctime)s","level":"%(levelname)s","name":"%(name)s","message":"%(message)s"}'
        )
    else:
        formatter = logging.Formatter(
            "%(asctime)s %(levelname)s %(name)s %(message)s"
        )
    handler.setFormatter(formatter)
    root = logging.getLogger()
    root.handlers = [handler]
    root.setLevel(level)


_setup_logging()
logger = logging.getLogger(__name__)

app = FastAPI(title=settings.app_name, version=settings.app_version)


class HealthResponse(BaseModel):
    status: str


class VersionResponse(BaseModel):
    version: str
    name: Optional[str] = None


@app.get("/health", response_model=HealthResponse)
def health() -> HealthResponse:
    logger.debug("healthcheck")
    return HealthResponse(status="ok")


@app.get("/version", response_model=VersionResponse)
def version() -> VersionResponse:
    logger.debug("version check")
    return VersionResponse(version=settings.app_version, name=settings.app_name)
