from __future__ import annotations

import os
import unittest
from contextlib import ExitStack
from pathlib import Path

TEST_DB = Path(__file__).resolve().parent / "test_emo_outlet.db"
os.environ["SQLITE_URL"] = f"sqlite+aiosqlite:///{TEST_DB.as_posix()}"
os.environ["DATABASE_URL"] = ""
os.environ["LLM_PROVIDER"] = "mock"

from fastapi.testclient import TestClient

from app.main import app


class ApiSmokeTest(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        if TEST_DB.exists():
            TEST_DB.unlink()
        cls._stack = ExitStack()
        cls.client = cls._stack.enter_context(TestClient(app))

    @classmethod
    def tearDownClass(cls) -> None:
        cls._stack.close()
        if TEST_DB.exists():
            TEST_DB.unlink()

    def test_full_backend_flow(self) -> None:
        register_response = self.client.post(
            "/api/auth/register",
            json={
                "phone": "13800000001",
                "password": "secret123",
                "nickname": "测试用户",
                "age_range": ">18",
                "consent_version": "1.0.0",
            },
        )
        self.assertEqual(register_response.status_code, 200, register_response.text)
        token = register_response.json()["access_token"]
        headers = {"Authorization": f"Bearer {token}"}

        profile_response = self.client.get("/api/auth/profile-detail", headers=headers)
        self.assertEqual(profile_response.status_code, 200, profile_response.text)
        self.assertEqual(profile_response.json()["nickname"], "测试用户")

        target_response = self.client.post(
            "/api/targets",
            headers=headers,
            json={
                "name": "老板",
                "type": "boss",
                "appearance": "穿西装，表情严肃",
                "personality": "强势，容易甩锅",
                "relationship": "直属领导",
                "style": "漫画",
            },
        )
        self.assertEqual(target_response.status_code, 201, target_response.text)
        target_id = target_response.json()["id"]

        avatar_response = self.client.post(
            f"/api/targets/{target_id}/generate-avatar",
            headers=headers,
        )
        self.assertEqual(avatar_response.status_code, 200, avatar_response.text)
        self.assertTrue(avatar_response.json()["avatar_url"].startswith("data:image/svg+xml;base64,"))

        session_response = self.client.post(
            "/api/sessions",
            headers=headers,
            json={
                "target_id": target_id,
                "mode": "dual",
                "chat_style": "rational",
                "dialect": "mandarin",
                "duration_minutes": 3,
            },
        )
        self.assertEqual(session_response.status_code, 201, session_response.text)
        session_id = session_response.json()["id"]

        message_response = self.client.post(
            f"/api/sessions/{session_id}/messages",
            headers=headers,
            json={"content": "我真的被加班和甩锅气到了，整个人都很烦。"},
        )
        self.assertEqual(message_response.status_code, 201, message_response.text)
        self.assertEqual(message_response.json()["sender"], "ai")

        messages_response = self.client.get(
            f"/api/sessions/{session_id}/messages",
            headers=headers,
        )
        self.assertEqual(messages_response.status_code, 200, messages_response.text)
        self.assertEqual(messages_response.json()["total"], 2)

        end_response = self.client.post(
            f"/api/sessions/{session_id}/end",
            headers=headers,
            json={"force": False},
        )
        self.assertEqual(end_response.status_code, 200, end_response.text)
        emotion_analysis = end_response.json()["emotion_analysis"]
        self.assertIn("primary_emotion", emotion_analysis)

        poster_response = self.client.post(
            "/api/posters/generate",
            headers=headers,
            json={"session_id": session_id},
        )
        self.assertEqual(poster_response.status_code, 200, poster_response.text)
        poster_id = poster_response.json()["id"]

        poster_detail_response = self.client.get(
            f"/api/posters/detail/{poster_id}",
            headers=headers,
        )
        self.assertEqual(poster_detail_response.status_code, 200, poster_detail_response.text)
        self.assertTrue(poster_detail_response.json()["poster_data"].startswith("data:image/svg+xml;base64,"))

        posters_response = self.client.get("/api/posters", headers=headers)
        self.assertEqual(posters_response.status_code, 200, posters_response.text)
        self.assertEqual(len(posters_response.json()), 1)

        report_response = self.client.get(
            "/api/posters/report/overview",
            headers=headers,
            params={"period": "weekly"},
        )
        self.assertEqual(report_response.status_code, 200, report_response.text)
        self.assertEqual(report_response.json()["total_sessions"], 1)

        detail_report_response = self.client.get(
            "/api/posters/report/detail",
            headers=headers,
            params={"period": "monthly"},
        )
        self.assertEqual(detail_report_response.status_code, 200, detail_report_response.text)
        self.assertEqual(len(detail_report_response.json()["trend_points"]), 1)

        feedback_response = self.client.post(
            "/api/support/feedback",
            headers=headers,
            json={
                "content": "海报详情页想增加一键保存提示。",
                "image_urls": ["https://example.com/a.png"],
                "source": "help_feedback",
            },
        )
        self.assertEqual(feedback_response.status_code, 201, feedback_response.text)

        delete_poster_response = self.client.delete(
            f"/api/posters/{poster_id}",
            headers=headers,
        )
        self.assertEqual(delete_poster_response.status_code, 204, delete_poster_response.text)


if __name__ == "__main__":
    unittest.main()
