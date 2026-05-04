from __future__ import annotations

import base64
import hashlib
import html
from typing import Any

from openai import AsyncOpenAI

from app.config import settings
from app.utils.ai_content_audit import ai_content_audit

STYLE_TRAITS: dict[str, dict[str, str]] = {
    "stubborn": {
        "tone": "嘴硬但克制",
        "lead": "这件事我有自己的理由，",
        "tail": "不过我听见你真的很在意。",
    },
    "apologetic": {
        "tone": "柔和道歉",
        "lead": "是我让你难受了，",
        "tail": "谢谢你把情绪说出来。",
    },
    "cold": {
        "tone": "冷静疏离",
        "lead": "我知道你现在不舒服，",
        "tail": "先把最刺耳的那一口气吐出来吧。",
    },
    "sarcastic": {
        "tone": "轻微讽刺但不攻击",
        "lead": "这事听着确实离谱，",
        "tail": "你能忍到现在也不容易。",
    },
    "rational": {
        "tone": "理性分析",
        "lead": "先把事实和感受分开看，",
        "tail": "你现在最需要的是把重点说清楚。",
    },
}

DIALECT_MARKERS: dict[str, tuple[str, str]] = {
    "mandarin": ("", ""),
    "cantonese": ("我喺度听住，", "慢慢讲啦。"),
    "sichuan": ("我晓得你现在窝火，", "慢慢摆哈子。"),
    "northeastern": ("我在这儿听着呢，", "你接着唠。"),
    "shanghainese": ("我听见侬个情绪了，", "阿拉慢慢讲。"),
}

EMOTION_CUES: dict[str, list[str]] = {
    "anger": ["气", "烦", "火", "讨厌", "崩溃", "受不了"],
    "sadness": ["难过", "委屈", "想哭", "失望", "心累", "心痛"],
    "anxiety": ["焦虑", "担心", "害怕", "不安", "紧张", "压力"],
    "exhaustion": ["累", "疲惫", "撑不住", "困", "麻木", "没劲"],
}


def _svg_data_url(svg: str) -> str:
    payload = base64.b64encode(svg.encode("utf-8")).decode("ascii")
    return f"data:image/svg+xml;base64,{payload}"


class AiService:
    def __init__(self) -> None:
        self._client: AsyncOpenAI | None = None
        self._mock_mode = False

    def _get_client(self) -> AsyncOpenAI | None:
        if self._client is not None:
            return self._client

        provider = settings.LLM_PROVIDER.lower().strip()
        if provider == "mock":
            self._mock_mode = True
            return None

        api_key = ""
        base_url = ""
        if provider == "openai":
            api_key = settings.OPENAI_API_KEY
            base_url = settings.OPENAI_BASE_URL
        elif provider == "deepseek":
            api_key = settings.DEEPSEEK_API_KEY
            base_url = settings.DEEPSEEK_BASE_URL
        elif provider == "qwen":
            api_key = settings.QWEN_API_KEY
            base_url = settings.QWEN_BASE_URL
        else:
            self._mock_mode = True
            return None

        if not api_key:
            self._mock_mode = True
            return None

        self._client = AsyncOpenAI(api_key=api_key, base_url=base_url)
        return self._client

    async def chat(
        self,
        user_message: str,
        mode: str = "single",
        chat_style: str = "apologetic",
        dialect: str = "mandarin",
        history: list[dict[str, Any]] | None = None,
        age_range: str | None = None,
    ) -> str:
        if age_range in ("<14", "14-18"):
            return await self._junior_chat(user_message, dialect, age_range)

        client = self._get_client()
        if self._mock_mode or client is None:
            return await self._local_chat(user_message, mode, chat_style, dialect, history)

        messages = self._build_messages(mode, chat_style, dialect, history)
        messages.append({"role": "user", "content": user_message})

        try:
            response = await client.chat.completions.create(
                model=settings.LLM_MODEL,
                messages=messages,
                max_tokens=180,
                temperature=0.7,
            )
            content = (response.choices[0].message.content or "").strip()
            if not content:
                return await self._local_chat(user_message, mode, chat_style, dialect, history)

            audit = await ai_content_audit.audit_response(content)
            if not audit["passed"]:
                return await ai_content_audit.get_safe_fallback(content)
            return content
        except Exception:
            return await self._local_chat(user_message, mode, chat_style, dialect, history)

    async def _junior_chat(
        self,
        user_message: str,
        dialect: str,
        age_range: str,
    ) -> str:
        mood = self._infer_mood(user_message)
        prefix, suffix = DIALECT_MARKERS.get(dialect, DIALECT_MARKERS["mandarin"])

        if mood == "anger":
            body = "你现在一定很憋屈，我们先慢一点，不把气撒到自己身上。"
        elif mood == "sadness":
            body = "难受也没有关系，你已经很努力了。"
        elif mood == "anxiety":
            body = "先照顾好呼吸，我们把最担心的一件事说出来。"
        else:
            body = "我在听，你可以把心里的话慢慢说出来。"

        if age_range == "<14":
            body += "要是方便，也可以找信任的大人陪你。"
        else:
            body += "你不需要一个人扛着。"

        reply = f"{prefix}{body}{suffix}".strip()
        return reply[:80]

    async def _local_chat(
        self,
        user_message: str,
        mode: str,
        chat_style: str,
        dialect: str,
        history: list[dict[str, Any]] | None,
    ) -> str:
        style = STYLE_TRAITS.get(chat_style, STYLE_TRAITS["apologetic"])
        prefix, suffix = DIALECT_MARKERS.get(dialect, DIALECT_MARKERS["mandarin"])
        mood = self._infer_mood(user_message)
        summary = self._summarize_message(user_message)
        continuity = self._history_hint(history)

        if mode == "single":
            body = self._single_mode_reply(mood, summary, continuity)
        else:
            body = self._dual_mode_reply(style, mood, summary, continuity)

        reply = " ".join(part for part in [prefix, body, suffix] if part).strip()
        audit = await ai_content_audit.audit_response(reply)
        if not audit["passed"]:
            return await ai_content_audit.get_safe_fallback(reply)
        return reply[:120]

    def _single_mode_reply(self, mood: str, summary: str, continuity: str) -> str:
        if mood == "anger":
            core = f"你把那股火说出来已经很重要了，{summary}。"
        elif mood == "sadness":
            core = f"这份难受我接住了，{summary}。"
        elif mood == "anxiety":
            core = f"听起来你一直绷着，{summary}。"
        elif mood == "exhaustion":
            core = f"你像是已经撑了很久，{summary}。"
        else:
            core = f"我在认真听，{summary}。"
        return f"{core}{continuity}继续说，我陪你把这口气顺出来。"

    def _dual_mode_reply(
        self,
        style: dict[str, str],
        mood: str,
        summary: str,
        continuity: str,
    ) -> str:
        if mood == "anger":
            bridge = "你这么生气，说明这件事真的踩到线了。"
        elif mood == "sadness":
            bridge = "听得出来你不是闹情绪，是真的受伤了。"
        elif mood == "anxiety":
            bridge = "你现在紧绷得很明显。"
        else:
            bridge = "我听见你的重点了。"

        return (
            f"{style['lead']}{bridge} {summary}。"
            f"{continuity}{style['tail']}"
        )

    def _build_messages(
        self,
        mode: str,
        chat_style: str,
        dialect: str,
        history: list[dict[str, Any]] | None,
    ) -> list[dict[str, str]]:
        style = STYLE_TRAITS.get(chat_style, STYLE_TRAITS["apologetic"])
        dialect_prompt = {
            "mandarin": "使用简体中文回复。",
            "cantonese": "使用口语化粤语回复。",
            "sichuan": "使用四川话语气回复。",
            "northeastern": "使用东北口语回复。",
            "shanghainese": "使用上海话语气回复。",
        }.get(dialect, "使用简体中文回复。")

        if mode == "single":
            system_prompt = (
                "你是情绪释放陪伴助手。"
                "只做倾听、接纳、安抚，不反击，不升级冲突。"
                "回复保持简短、温和、具体。"
            )
        else:
            system_prompt = (
                f"你在角色对话中保持{style['tone']}风格，但绝不辱骂、威胁、鼓励现实伤害。"
                "回复保持简短，帮助用户完成安全的情绪表达。"
            )

        messages: list[dict[str, str]] = [
            {"role": "system", "content": f"{system_prompt}\n{dialect_prompt}"}
        ]
        for item in (history or [])[-10:]:
            role = "assistant" if item.get("sender") == "ai" else "user"
            content = str(item.get("content", "")).strip()
            if content:
                messages.append({"role": role, "content": content})
        return messages

    def _infer_mood(self, text: str) -> str:
        lowered = text.lower()
        best_label = "neutral"
        best_score = 0
        for label, words in EMOTION_CUES.items():
            score = sum(lowered.count(word) for word in words)
            if score > best_score:
                best_score = score
                best_label = label
        return best_label

    def _summarize_message(self, text: str) -> str:
        clean = " ".join(text.strip().split())
        if not clean:
            return "你还没来得及把事情说完整"
        if len(clean) <= 18:
            return f"你在反复咬着“{clean}”这件事"
        return f"你最在意的是“{clean[:18]}...”"

    def _history_hint(self, history: list[dict[str, Any]] | None) -> str:
        if not history:
            return ""
        user_turns = [item for item in history if item.get("sender") == "user"]
        if len(user_turns) >= 4:
            return "你已经憋了好一会儿，"
        if len(user_turns) >= 2:
            return "我记得你前面也提过这点，"
        return ""


class ImageService:
    async def generate_avatar(
        self,
        appearance: str,
        personality: str,
        style: str = "漫画",
    ) -> str:
        seed = hashlib.md5(f"{appearance}|{personality}|{style}".encode("utf-8")).hexdigest()
        palette = [
            ("#FF7A66", "#FFB07A"),
            ("#7C8CFF", "#B68CFF"),
            ("#56C8A6", "#9BE7D0"),
            ("#FFB14A", "#FFD28B"),
        ]
        left, right = palette[int(seed[:2], 16) % len(palette)]
        initial = html.escape((appearance or personality or "E")[:1].upper())
        style_label = html.escape(style[:4] or "角色")
        svg = f"""
<svg xmlns="http://www.w3.org/2000/svg" width="400" height="400" viewBox="0 0 400 400">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="{left}"/>
      <stop offset="100%" stop-color="{right}"/>
    </linearGradient>
  </defs>
  <rect width="400" height="400" rx="120" fill="url(#bg)"/>
  <circle cx="200" cy="160" r="78" fill="#FFF3EE"/>
  <path d="M110 332c18-62 62-96 90-96s72 34 90 96" fill="#FFF7F4"/>
  <circle cx="170" cy="150" r="9" fill="#43302B"/>
  <circle cx="230" cy="150" r="9" fill="#43302B"/>
  <path d="M170 196c18 18 42 18 60 0" stroke="#FF8D80" stroke-width="10" fill="none" stroke-linecap="round"/>
  <text x="200" y="318" font-size="44" font-family="Arial, sans-serif" text-anchor="middle" fill="#7A4D45">{initial}</text>
  <text x="200" y="360" font-size="24" font-family="Arial, sans-serif" text-anchor="middle" fill="#7A4D45">{style_label}</text>
</svg>
""".strip()
        return _svg_data_url(svg)

    async def generate_poster(self, emotion_data: dict[str, Any]) -> bytes | None:
        svg = f"""
<svg xmlns="http://www.w3.org/2000/svg" width="1080" height="1920" viewBox="0 0 1080 1920">
  <rect width="1080" height="1920" fill="#FFF7F1"/>
  <text x="540" y="300" text-anchor="middle" font-size="88" fill="#2E2A2A">Emo Outlet</text>
  <text x="540" y="420" text-anchor="middle" font-size="54" fill="#6C6663">{html.escape(str(emotion_data.get("title", "情绪海报")))}</text>
</svg>
""".strip()
        return svg.encode("utf-8")


class VoiceService:
    async def speech_to_text(self, audio_data: bytes) -> str:
        if not audio_data:
            return ""
        if settings.ASR_PROVIDER == "mock":
            return "语音内容已接收，当前环境使用本地占位转写。"
        return "语音服务暂未配置，已保留音频等待后续处理。"

    async def text_to_speech(self, text: str, dialect: str = "mandarin") -> bytes:
        payload = f"[{dialect}] {text}".encode("utf-8")
        if settings.TTS_PROVIDER == "mock":
            return payload
        return payload


ai_service = AiService()
image_service = ImageService()
voice_service = VoiceService()
