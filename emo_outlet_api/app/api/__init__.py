from __future__ import annotations

# 导出所有路由
from app.api import auth
from app.api import targets
from app.api import sessions
from app.api import messages
from app.api import posters

__all__ = [
    "auth",
    "targets",
    "sessions",
    "messages",
    "posters",
]
