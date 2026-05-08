from __future__ import annotations

import base64
import hashlib
import html
import json
from pathlib import Path
from urllib.parse import quote

import httpx
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
    "cantonese": ("我喺度听住你。", "慢慢讲啦。"),
    "sichuan": ("我晓得你现在心头冒火。", "慢慢摆哈。"),
    "northeastern": ("我在这儿听着呢。", "你接着唠。"),
    "shanghainese": ("我听得出侬心里蛮堵。", "阿拉慢慢讲。"),
}

EMOTION_CUES: dict[str, list[str]] = {
    "anger": ["气死", "火大", "烦死", "讨厌", "崩溃", "受不了", "恶心", "炸了"],
    "sadness": ["难过", "委屈", "想哭", "失望", "心累", "心痛", "伤心"],
    "anxiety": ["焦虑", "担心", "害怕", "不安", "紧张", "压力", "睡不着"],
    "exhaustion": ["累", "疲惫", "撑不住", "困", "麻木", "没劲", "好烦"],
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

        api_key = self._resolve_api_key(api_key, base_url)
        if not api_key:
            self._mock_mode = True
            return None

        self._client = AsyncOpenAI(
            api_key=api_key,
            base_url=base_url,
            http_client=httpx.AsyncClient(
                trust_env=False,
                timeout=httpx.Timeout(45.0, connect=20.0),
                follow_redirects=True,
            ),
        )
        return self._client

    def _resolve_api_key(self, api_key: str, base_url: str) -> str:
        key = api_key.strip().strip('"').strip("'")
        if "xiaomimimo.com" not in base_url or key.startswith("tp-"):
            return key

        env_path = Path(__file__).resolve().parents[2] / ".env"
        try:
            for line in env_path.read_text(encoding="utf-8").splitlines():
                if not line.startswith("OPENAI_API_KEY="):
                    continue
                candidate = line.split("=", 1)[1].strip().strip('"').strip("'")
                if candidate.startswith("tp-"):
                    return candidate
        except OSError:
            pass
        return key

    def _preferred_voice_prompt(self, dialect: str) -> str:
        prompts = {
            "mandarin": "用自然、温柔、像朋友陪伴一样的普通话朗读，语速平稳。",
            "cantonese": "用自然亲切的粤语口语风格朗读，保持清晰、温柔、像真人在说话。",
            "sichuan": "用带一点四川话语气的方式朗读，保持轻松自然，不要过度夸张。",
            "northeastern": "用自然东北口语语气朗读，像熟人聊天一样接地气，但不要喊叫。",
            "shanghainese": "用温和的上海话口吻朗读，优先保证自然和可听懂。",
        }
        return prompts.get(dialect, prompts["mandarin"])

    def _image_style_prompt(self, style: str) -> str:
        prompts = {
            "Q版": "Q版治愈漫画头像，头身比偏可爱，表情生动，适合情绪陪伴类 App。",
            "手绘": "细腻手绘插画头像，线条柔和，质感温暖，像高质量角色设定图。",
            "温和": "温柔治愈系半写实头像，色彩柔和，氛围轻暖，亲和力强。",
            "夸张": "夸张漫画头像，表情和动作更有戏剧性，但仍然要可爱、精致、可用。",
        }
        return prompts.get(style, prompts["Q版"])

    async def chat(
        self,
        user_message: str,
        mode: str = "single",
        chat_style: str = "apologetic",
        dialect: str = "mandarin",
        history: list[dict[str, str]] | None = None,
        age_range: str | None = None,
        target_context: dict[str, str] | None = None,
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
                max_tokens=220,
                temperature=0.78,
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
        except Exception as exc:
            print(f"LLM chat failed: {type(exc).__name__}: {exc}")
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
            "返回严格 JSON，字段只包含 appearance、personality、style。"
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
        except Exception as exc:
            print(f"LLM ai-complete failed: {type(exc).__name__}: {exc}")
            return self._local_complete_target_profile(clean_name, clean_relationship)

    async def synthesize_speech(
        self,
        text: str,
        dialect: str = "mandarin",
        voice: str = "alloy",
        user_id: str | None = None,
    ) -> dict[str, str]:
        if settings.TTS_PROVIDER.lower().strip() in {"none", "disabled", "mock"}:
            raise RuntimeError("当前后端语音服务不可用，请使用设备语音播放")

        client = self._get_client()
        if client is None:
            raise RuntimeError("当前后端语音服务不可用，请使用设备语音播放")

        content = text.strip()
        if not content:
            raise RuntimeError("语音播报内容不能为空")

        try:
            response = await client.audio.speech.create(
                model=settings.TTS_MODEL,
                voice=voice or settings.TTS_VOICE,
                input=content[:1200],
                response_format=settings.TTS_FORMAT,
                instructions=self._preferred_voice_prompt(dialect),
            )
            audio_bytes = await response.aread()
            if not audio_bytes:
                raise RuntimeError("语音服务没有返回音频数据")
            return {
                "audio_base64": base64.b64encode(audio_bytes).decode("ascii"),
                "mime_type": "audio/mpeg",
                "voice": voice or settings.TTS_VOICE,
                "dialect": dialect,
            }
        except Exception as exc:
            raise RuntimeError(
                f"语音播报服务调用失败: {type(exc).__name__}"
            ) from exc

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
            body = "难受也没关系，你已经很努力了。"
        elif mood == "anxiety":
            body = "先照顾好呼吸，我们把最担心的一件事说出来。"
        else:
            body = "我在听，你可以把心里的话慢慢说出来。"

        if age_range == "<14":
            body += "要是方便，也可以找信任的大人陪你。"
        else:
            body += "你不用一个人扛着。"

        return f"{prefix}{body}{suffix}".strip()[:90]

    async def _local_chat(
        self,
        user_message: str,
        mode: str,
        chat_style: str,
        dialect: str,
        history: list[dict[str, str]] | None,
        target_context: dict[str, str] | None,
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
        return reply[:140]

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
            bridge = "听得出来你不是闹情绪，是真的被伤到了。"
        elif mood == "anxiety":
            bridge = "你现在绷得很明显。"
        else:
            bridge = "我听见你的重点了。"

        return (
            f"{context_hint}{style['lead']}{bridge} "
            f"{summary}。{continuity}{style['tail']}"
        )

    def _build_messages(
        self,
        mode: str,
        chat_style: str,
        dialect: str,
        history: list[dict[str, str]] | None,
        target_context: dict[str, str] | None,
    ) -> list[dict[str, str]]:
        style = STYLE_TRAITS.get(chat_style, STYLE_TRAITS["apologetic"])
        dialect_prompt = {
            "mandarin": "使用简体中文回复。",
            "cantonese": "使用口语化粤语回复，保持自然易懂，不要堆砌生僻字。",
            "sichuan": "使用四川话语气回复，保持自然、克制、可读。",
            "northeastern": "使用东北口语回复，保持自然，不要过度夸张。",
            "shanghainese": "使用上海话语气回复，优先保证可读性和温和感。",
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

    def _target_prompt(self, target_context: dict[str, str] | None) -> str:
        if not target_context:
            return ""

        parts: list[str] = []
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
        payload: dict[str, str],
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
        best_label = "neutral"
        best_score = 0
        for label, words in EMOTION_CUES.items():
            score = sum(text.count(word) for word in words)
            if score > best_score:
                best_score = score
                best_label = label
        return best_label

    def _summarize_message(self, text: str) -> str:
        clean = " ".join(text.strip().split())
        if not clean:
            return "你好像还没来得及把事情说完整"
        if len(clean) <= 18:
            return f"你一直在咬着“{clean}”这件事"
        return f"你最在意的是“{clean[:18]}...”"

    def _history_hint(self, history: list[dict[str, str]] | None) -> str:
        if not history:
            return ""
        user_turns = [item for item in history if item.get("sender") == "user"]
        if len(user_turns) >= 4:
            return "你已经憋了好一会儿，"
        if len(user_turns) >= 2:
            return "我记得你前面也提过这一点，"
        return ""

    def _target_hint(self, target_context: dict[str, str] | None) -> str:
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
    def _fallback_avatar(
        self,
        appearance: str,
        personality: str,
        style: str,
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
  <rect width="400" height="400" rx="92" fill="url(#bg)"/>
  <circle cx="200" cy="158" r="72" fill="#FFFFFF" fill-opacity="0.90"/>
  <path d="M98 330c14-58 60-92 102-92s88 34 102 92" fill="#FFFFFF" fill-opacity="0.92"/>
  <text x="200" y="180" text-anchor="middle" font-size="64" font-family="Arial, sans-serif" fill="#4A3E3A">{initial}</text>
  <rect x="106" y="292" width="188" height="40" rx="20" fill="#FFFFFF" fill-opacity="0.88"/>
  <text x="200" y="319" text-anchor="middle" font-size="20" font-family="Arial, sans-serif" fill="#594F4B">{style_label}</text>
</svg>
""".strip()
        return _svg_data_url(svg)

    async def _generate_with_openai(
        self,
        appearance: str,
        personality: str,
        style: str,
    ) -> str:
        client = ai_service._get_client()
        if client is None:
            raise RuntimeError("image client unavailable")

        prompt = (
            "请生成一张情绪陪伴类 App 角色头像，单人、正面、背景干净、构图居中。"
            f"{ai_service._image_style_prompt(style)}"
            f"外貌与气质：{appearance or '亲和、柔软、带一点漫画感'}。"
            f"性格感觉：{personality or '温柔、愿意倾听、容易让人放松'}。"
            "要求高质感、可爱、适合移动端头像展示，不要文字，不要水印，不要多角色。"
        )

        response = await client.images.generate(
            model=settings.IMAGE_MODEL,
            prompt=prompt,
            size=settings.IMAGE_SIZE,
            quality=settings.IMAGE_QUALITY,
            style=settings.IMAGE_STYLE,
            output_format="png",
            response_format="b64_json",
        )
        item = response.data[0] if response.data else None
        if item is None:
            raise RuntimeError("image service returned empty data")
        if getattr(item, "b64_json", None):
            return f"data:image/png;base64,{item.b64_json}"
        if getattr(item, "url", None):
            return item.url
        raise RuntimeError("unsupported image response")

    async def _generate_with_pollinations(
        self,
        appearance: str,
        personality: str,
        style: str,
    ) -> str:
        prompt = (
            "cute emotional companion app avatar, single character portrait, centered composition, "
            "soft cinematic lighting, premium mobile app mascot, no text, no watermark, "
            f"{ai_service._image_style_prompt(style)} "
            f"appearance: {appearance or 'warm smile, soft pink cloud'}; "
            f"personality: {personality or 'gentle, healing, patient listener'}"
        )
        url = (
            "https://image.pollinations.ai/prompt/"
            f"{quote(prompt)}?width=768&height=768&model=flux&nologo=true&safe=true"
        )
        async with httpx.AsyncClient(
            trust_env=False,
            timeout=httpx.Timeout(90.0, connect=20.0),
            follow_redirects=True,
        ) as client:
            response = await client.get(url)
            response.raise_for_status()
            content_type = response.headers.get("content-type", "image/jpeg").split(";")[0]
            if not content_type.startswith("image/"):
                raise RuntimeError("pollinations returned non-image content")
            encoded = base64.b64encode(response.content).decode("ascii")
            return f"data:{content_type};base64,{encoded}"

    async def generate_avatar(
        self,
        appearance: str,
        personality: str,
        style: str = "Q版",
    ) -> str:
        provider = settings.IMAGE_PROVIDER.lower().strip()
        errors: list[str] = []

        if provider in {"auto", "openai", "openai_compatible"}:
            try:
                return await self._generate_with_openai(appearance, personality, style)
            except Exception as exc:
                errors.append(f"openai:{type(exc).__name__}")
                if provider == "openai":
                    if settings.DEBUG:
                        return self._fallback_avatar(appearance, personality, style)
                    raise RuntimeError("图像生成服务暂时不可用") from exc

        if provider in {"auto", "pollinations"}:
            try:
                return await self._generate_with_pollinations(appearance, personality, style)
            except Exception as exc:
                errors.append(f"pollinations:{type(exc).__name__}")

        if settings.DEBUG:
            return self._fallback_avatar(appearance, personality, style)
        raise RuntimeError("图像生成失败，请稍后重试：" + ", ".join(errors))


ai_service = AiService()
image_service = ImageService()
