from __future__ import annotations

import base64
import hashlib
import html
import json
from typing import Any

from openai import AsyncOpenAI

from app.config import settings
from app.utils.ai_content_audit import ai_content_audit

STYLE_TRAITS: dict[str, dict[str, str]] = {
    "stubborn": {
        "tone": "嘴硬但克制",
        "lead": "这件事我也有自己的理由，",
        "tail": "不过我听得出来，你是真的很在意。",
    },
    "apologetic": {
        "tone": "柔和道歉",
        "lead": "是我让你难受了，",
        "tail": "谢谢你愿意把情绪说出来。",
    },
    "cold": {
        "tone": "冷静疏离",
        "lead": "我知道你现在不舒服，",
        "tail": "先把最刺耳的话说出来吧。",
    },
    "sarcastic": {
        "tone": "轻微阴阳但不攻击",
        "lead": "这事听起来确实离谱，",
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
    "cantonese": ("我喺度听住你，", "慢慢讲啦。"),
    "sichuan": ("我晓得你现在窝火，", "慢慢摆哈子。"),
    "northeastern": ("我在这儿听着呢，", "你接着唠。"),
    "shanghainese": ("我听出来你情绪蛮重，", "阿拉慢慢讲。"),
}

EMOTION_CUES: dict[str, list[str]] = {
    "anger": ["气", "火", "烦", "讨厌", "崩溃", "受不了"],
    "sadness": ["难过", "委屈", "想哭", "失望", "心累", "心痛"],
    "anxiety": ["焦虑", "担心", "害怕", "不安", "紧张", "压力"],
    "exhaustion": ["累", "疲惫", "撑不住", "困", "麻木", "没劲"],
}

STYLE_CANDIDATES = ("Q版", "手绘", "温和", "夸张")


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
        target_context: dict[str, Any] | None = None,
    ) -> str:
        if age_range in ("<14", "14-18"):
            return await self._junior_chat(user_message, dialect, age_range)

        client = self._get_client()
        if self._mock_mode or client is None:
            return await self._local_chat(
                user_message,
                mode,
                chat_style,
                dialect,
                history,
                target_context,
            )

        messages = self._build_messages(
            mode=mode,
            chat_style=chat_style,
            dialect=dialect,
            history=history,
            target_context=target_context,
        )
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
                return await self._local_chat(
                    user_message,
                    mode,
                    chat_style,
                    dialect,
                    history,
                    target_context,
                )

            audit = await ai_content_audit.audit_response(content)
            if not audit["passed"]:
                return await ai_content_audit.get_safe_fallback(content)
            return content
        except Exception:
            return await self._local_chat(
                user_message,
                mode,
                chat_style,
                dialect,
                history,
                target_context,
            )

    async def complete_target_profile(
        self,
        name: str,
        relationship: str,
    ) -> dict[str, str]:
        clean_name = name.strip() or "Ta"
        clean_relationship = relationship.strip()
        client = self._get_client()

        if self._mock_mode or client is None:
            return self._local_complete_target_profile(clean_name, clean_relationship)

        prompt = (
            "你是角色设定助手。请根据对象称呼和关系，补全一个适合情绪倾诉场景的对象画像。"
            "返回严格 JSON，字段只有 appearance、personality、style。"
            "appearance 用 16 到 28 个汉字描述外貌或气质；"
            "personality 用 18 到 34 个汉字描述性格与相处特征；"
            f"style 只能从 {', '.join(STYLE_CANDIDATES)} 中选择一个。"
            "不要输出 markdown，不要解释。"
        )

        user_input = json.dumps(
            {"name": clean_name, "relationship": clean_relationship},
            ensure_ascii=False,
        )

        try:
            response = await client.chat.completions.create(
                model=settings.LLM_MODEL,
                messages=[
                    {"role": "system", "content": prompt},
                    {"role": "user", "content": user_input},
                ],
                max_tokens=220,
                temperature=0.8,
                response_format={"type": "json_object"},
            )
            raw = (response.choices[0].message.content or "").strip()
            payload = json.loads(raw)
            return self._normalize_profile_payload(payload, clean_name, clean_relationship)
        except Exception:
            return self._local_complete_target_profile(clean_name, clean_relationship)

    async def _junior_chat(
        self,
        user_message: str,
        dialect: str,
        age_range: str,
    ) -> str:
        mood = self._infer_mood(user_message)
        prefix, suffix = DIALECT_MARKERS.get(dialect, DIALECT_MARKERS["mandarin"])

        if mood == "anger":
            body = "你现在一定很委屈，我们先慢一点，不把气撒到自己身上。"
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

        return f"{prefix}{body}{suffix}".strip()[:80]

    async def _local_chat(
        self,
        user_message: str,
        mode: str,
        chat_style: str,
        dialect: str,
        history: list[dict[str, Any]] | None,
        target_context: dict[str, Any] | None,
    ) -> str:
        style = STYLE_TRAITS.get(chat_style, STYLE_TRAITS["apologetic"])
        prefix, suffix = DIALECT_MARKERS.get(dialect, DIALECT_MARKERS["mandarin"])
        mood = self._infer_mood(user_message)
        summary = self._summarize_message(user_message)
        continuity = self._history_hint(history)
        context_hint = self._target_hint(target_context)

        if mode == "single":
            body = self._single_mode_reply(mood, summary, continuity, context_hint)
        else:
            body = self._dual_mode_reply(style, mood, summary, continuity, context_hint)

        reply = " ".join(part for part in [prefix, body, suffix] if part).strip()
        audit = await ai_content_audit.audit_response(reply)
        if not audit["passed"]:
            return await ai_content_audit.get_safe_fallback(reply)
        return reply[:120]

    def _single_mode_reply(
        self,
        mood: str,
        summary: str,
        continuity: str,
        context_hint: str,
    ) -> str:
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
        return f"{context_hint}{core}{continuity}继续说吧，我陪你把这口气顺出来。"

    def _dual_mode_reply(
        self,
        style: dict[str, str],
        mood: str,
        summary: str,
        continuity: str,
        context_hint: str,
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
            f"{context_hint}{style['lead']}{bridge}"
            f" {summary}。{continuity}{style['tail']}"
        )

    def _build_messages(
        self,
        mode: str,
        chat_style: str,
        dialect: str,
        history: list[dict[str, Any]] | None,
        target_context: dict[str, Any] | None,
    ) -> list[dict[str, str]]:
        style = STYLE_TRAITS.get(chat_style, STYLE_TRAITS["apologetic"])
        dialect_prompt = {
            "mandarin": "使用简体中文回复。",
            "cantonese": "使用口语化粤语回复。",
            "sichuan": "使用四川话语气回复。",
            "northeastern": "使用东北口语回复。",
            "shanghainese": "使用上海话语气回复。",
        }.get(dialect, "使用简体中文回复。")

        target_prompt = self._target_prompt(target_context)
        common_rules = (
            "回复保持 1 到 3 句话，优先短句。"
            "不要输出说教、法律判断、医疗诊断、威胁、羞辱或鼓励现实伤害。"
            "如果用户表达的是情绪，不要急着给方案，先接住再回应。"
        )

        if mode == "single":
            system_prompt = (
                "你是情绪释放陪伴助手。"
                "只做倾听、接纳、安抚，不反驳，不升级冲突。"
                "你的目标是帮助用户把情绪安全说出来，而不是解决现实纠纷。"
            )
        else:
            system_prompt = (
                f"你在角色对话中保持“{style['tone']}”风格，"
                "但绝不辱骂、威胁、PUA、鼓励报复或现实伤害。"
                "你要像这个对象本人在回应，但要控制在安全、可继续对话的范围里。"
            )

        system_content = "\n".join(
            part
            for part in [system_prompt, common_rules, dialect_prompt, target_prompt]
            if part
        )

        messages: list[dict[str, str]] = [{"role": "system", "content": system_content}]
        for item in (history or [])[-12:]:
            role = "assistant" if item.get("sender") == "ai" else "user"
            content = str(item.get("content", "")).strip()
            if content:
                messages.append({"role": role, "content": content})
        return messages

    def _target_prompt(self, target_context: dict[str, Any] | None) -> str:
        if not target_context:
            return ""

        parts = []
        name = str(target_context.get("name") or "").strip()
        target_type = str(target_context.get("type") or "").strip()
        relationship = str(target_context.get("relationship") or "").strip()
        appearance = str(target_context.get("appearance") or "").strip()
        personality = str(target_context.get("personality") or "").strip()
        style = str(target_context.get("style") or "").strip()

        if name:
            parts.append(f"对象名：{name}")
        if target_type:
            parts.append(f"对象类型：{target_type}")
        if relationship:
            parts.append(f"关系：{relationship}")
        if personality:
            parts.append(f"性格：{personality}")
        if appearance:
            parts.append(f"外貌/气质：{appearance}")
        if style:
            parts.append(f"形象风格：{style}")

        return "对象背景：\n" + "\n".join(parts) if parts else ""

    def _local_complete_target_profile(
        self,
        name: str,
        relationship: str,
    ) -> dict[str, str]:
        presets = [
            (
                ("老板", "领导", "上司"),
                {
                    "appearance": "穿着利落，表情克制，带一点压迫感",
                    "personality": "强势直接，标准高，沟通时容易让人紧张",
                    "style": "手绘",
                },
            ),
            (
                ("同事", "搭档"),
                {
                    "appearance": "日常通勤打扮，神情紧绷，动作干练",
                    "personality": "较真敏感，爱比较，边界感偏强",
                    "style": "Q版",
                },
            ),
            (
                ("前任", "伴侣"),
                {
                    "appearance": "熟悉的日常穿搭，气质温和但带距离感",
                    "personality": "忽冷忽热，回避沟通，容易翻旧账",
                    "style": "温和",
                },
            ),
            (
                ("客户",),
                {
                    "appearance": "商务风穿着，神情认真，节奏很快",
                    "personality": "要求细，反馈直接，推进感很强",
                    "style": "手绘",
                },
            ),
            (
                ("家人", "妈妈", "爸爸"),
                {
                    "appearance": "熟悉的居家气质，看起来亲近但带期待",
                    "personality": "关心很多，表达直接，偶尔容易唠叨",
                    "style": "温和",
                },
            ),
        ]

        for keywords, payload in presets:
            if any(keyword in relationship for keyword in keywords):
                return payload

        return {
            "appearance": f"{name}有清晰记忆点，气质让你一想到就会有情绪波动",
            "personality": "相处里有让你在意的习惯和说话方式，容易牵动你的感受",
            "style": "Q版",
        }

    def _normalize_profile_payload(
        self,
        payload: dict[str, Any],
        name: str,
        relationship: str,
    ) -> dict[str, str]:
        fallback = self._local_complete_target_profile(name, relationship)
        appearance = str(payload.get("appearance") or fallback["appearance"]).strip()
        personality = str(payload.get("personality") or fallback["personality"]).strip()
        style = str(payload.get("style") or fallback["style"]).strip()
        if style not in STYLE_CANDIDATES:
            style = fallback["style"]
        return {
            "appearance": appearance[:40],
            "personality": personality[:48],
            "style": style,
        }

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
            return "我记得你前面也提过这一点，"
        return ""

    def _target_hint(self, target_context: dict[str, Any] | None) -> str:
        if not target_context:
            return ""
        relationship = str(target_context.get("relationship") or "").strip()
        personality = str(target_context.get("personality") or "").strip()
        if relationship:
            return f"这段关系里有“{relationship}”的压力，"
        if personality:
            return f"面对这样“{personality}”的人，"
        return ""


class ImageService:
    async def generate_avatar(
        self,
        appearance: str,
        personality: str,
        style: str = "漫画",
    ) -> str:
        seed = hashlib.md5(
            f"{appearance}|{personality}|{style}".encode("utf-8")
        ).hexdigest()
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
