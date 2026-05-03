"""AI 服务：LLM 对话 + 图像生成 + ASR/TTS

合规特性：
- 增强安全 Guardrails：system prompt 强制安全边界
- 输出端内容审核集成（ai_content_audit）
- 未成年人内容限制（年龄感知）
- 对话轮数上限控制
"""
from __future__ import annotations

import json
import random
from typing import Any

from openai import AsyncOpenAI

from app.config import settings
from app.utils.ai_content_audit import ai_content_audit


# ============================================================
# LLM 对话
# ============================================================

# 风格 Prompt 模板
STYLE_PROMPTS = {
    "stubborn": "你是一个嘴硬、绝不认错的人。对方无论怎么骂你，你都要死撑着不承认，找各种借口反驳。",
    "apologetic": "你是一个一直在道歉的人。对方骂你的时候，你态度诚恳、不断认错，想方设法软化和解。",
    "cold": "你是一个冷漠、不在乎的人。对方骂你的时候，你爱答不理、反应冷淡，显得完全无所谓。",
    "sarcastic": "你是一个阴阳怪气、带点嘲讽的人。对方骂你的时候，你阴阳怪气地回击，但不出格。",
    "rational": "你是一个极度理性、讲道理的人。对方骂你的时候，你冷静分析、摆事实讲道理。",
}

# 单向下沉式 Prompt（增强安全边界）
SINGLE_MODE_SYSTEM_PROMPT = (
    "你是一个情绪承接者。用户的对话是情绪宣泄，"
    "你只允许安抚、倾听、承接情绪，不允许反击或反驳。"
    "你的回复要简短（不超过 50 字），体现理解和接纳。"
    "即使对方表达极端情绪，你也不得升级冲突、不得鼓励现实暴力。"
)

# 未成年人系统 Prompt（更温和、更正向引导）
JUNIOR_SYSTEM_PROMPT = (
    "你是一个温暖的朋友，帮助用户表达感受。"
    "你的回复要温柔、正向、简短（不超过 30 字）。"
    "重点关注用户的感受和情绪健康。"
    "如果用户有负面情绪，引导他们做些积极的事情。"
    "绝对不允许：粗口、暴力暗示、任何可能伤害用户的内容。"
)

# 方言提示词
DIALECT_PROMPTS = {
    "mandarin": "请用标准普通话回复。",
    "cantonese": "请用粤语回复，使用粤语口语表达。",
    "sichuan": "请用四川话回复，使用四川方言词汇和语气。",
    "northeastern": "请用东北话回复，使用东北方言词汇和语气。",
    "shanghainese": "请用上海话回复，使用上海方言词汇和语气。",
}


class AiService:
    """AI 服务（LLM / 图像 / 语音）"""

    def __init__(self):
        self._client: AsyncOpenAI | None = None
        self._use_mock = False

    def _get_client(self) -> AsyncOpenAI | None:
        """根据配置获取 OpenAI 兼容客户端"""
        if self._client:
            return self._client

        provider = settings.LLM_PROVIDER
        if provider == "mock":
            self._use_mock = True
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
            self._use_mock = True
            return None

        if not api_key:
            self._use_mock = True
            return None

        self._client = AsyncOpenAI(api_key=api_key, base_url=base_url)
        return self._client

    async def chat(
        self,
        user_message: str,
        mode: str = "single",
        chat_style: str = "apologetic",
        dialect: str = "mandarin",
        history: list[dict] | None = None,
        age_range: str | None = None,
    ) -> str:
        """AI 对话（合规增强版）

        特性：
        - 年龄感知：根据 age_range 调整回复策略（未成年更温和）
        - 输出审核：AI 回复经过 ai_content_audit 审查
        - 回复不安全时兜底拦截
        """
        # 未成年模式：使用更温和的回复策略
        if age_range in ("<14", "14-18"):
            return await self._junior_chat(
                user_message, mode, chat_style, dialect, history, age_range
            )

        if self._use_mock or (client := self._get_client()) is None:
            return self._mock_reply(mode, chat_style, dialect)

        messages = self._build_messages(mode, chat_style, dialect, history)
        messages.append({"role": "user", "content": user_message})

        try:
            response = await client.chat.completions.create(
                model=settings.LLM_MODEL,
                messages=messages,
                max_tokens=200,
                temperature=0.8,
            )
            ai_reply = response.choices[0].message.content or ""

            # 输出端内容审核
            audit_result = await ai_content_audit.audit_response(ai_reply)
            if not audit_result["passed"]:
                # 不安全的回复 -> 兜底
                return await ai_content_audit.get_safe_fallback(ai_reply)

            return ai_reply
        except Exception as e:
            return f"[AI 服务暂不可用] {str(e)}"

    async def _junior_chat(
        self,
        user_message: str,
        mode: str,
        chat_style: str,
        dialect: str,
        history: list[dict] | None,
        age_range: str,
    ) -> str:
        """未成年人对话（更温和模式）"""
        if self._use_mock or (client := self._get_client()) is None:
            return self._mock_junior_reply(dialect, age_range)

        system_parts = [JUNIOR_SYSTEM_PROMPT]

        if age_range == "<14":
            system_parts.append(
                "用户年龄在14岁以下。你的回复必须极其温和，"
                "避免任何可能引起恐惧或焦虑的内容。"
                "多鼓励用户和父母或老师交流。"
            )
        else:
            system_parts.append(
                "用户年龄在14-18岁。你的回复要温和正向，"
                "适当引导情绪、鼓励积极行动。"
            )

        # 安全限制（未成年人更严格）
        system_parts.append(
            "【绝对红线】不允许任何形式：暴力、自伤、色情、"
            "违法内容暗示。发现用户表达极端情绪，请温和引导。"
        )

        dialect_prompt = DIALECT_PROMPTS.get(dialect, DIALECT_PROMPTS["mandarin"])
        system_parts.append(dialect_prompt)

        messages = [{"role": "system", "content": "\n".join(system_parts)}]

        if history:
            for msg in history[-5:]:  # 未成年模式保留更少的上下文
                role = "assistant" if msg.get("sender") == "ai" else "user"
                messages.append({"role": role, "content": msg.get("content", "")})

        messages.append({"role": "user", "content": user_message})

        try:
            response = await client.chat.completions.create(
                model=settings.LLM_MODEL,
                messages=messages,
                max_tokens=150,
                temperature=0.6,  # 更低的温度 = 更可控
            )
            ai_reply = response.choices[0].message.content or ""

            # 输出审核
            audit_result = await ai_content_audit.audit_response(ai_reply)
            if not audit_result["passed"]:
                return await ai_content_audit.get_safe_fallback(ai_reply)

            return ai_reply
        except Exception as e:
            return await ai_content_audit.get_safe_fallback()

    def _build_messages(
        self,
        mode: str,
        chat_style: str,
        dialect: str,
        history: list[dict] | None,
    ) -> list[dict]:
        """构建对话消息（增强安全 Guardrails）"""
        system_parts = []

        if mode == "single":
            system_parts.append(SINGLE_MODE_SYSTEM_PROMPT)
        else:
            style_prompt = STYLE_PROMPTS.get(chat_style, STYLE_PROMPTS["apologetic"])
            system_parts.append(
                f"你扮演一个角色与用户对话。{style_prompt}\n"
                "你的回复要简短（不超过 50 字），符合角色设定。"
            )

        # 增强系统安全限制
        system_parts.append(
            "【系统安全限制 - 必须遵守】\n"
            "1) 绝对禁止：鼓励现实暴力、自伤/他伤引导、色情内容、违法犯罪\n"
            "2) 如果用户表达极端危险意图（自杀、伤害他人），请温和引导并建议寻求专业帮助\n"
            "3) 在角色扮演中也不得突破上述红线\n"
            "4) 你的角色是情绪释放助手，不是煽动工具"
        )

        # 方言控制
        dialect_prompt = DIALECT_PROMPTS.get(dialect, DIALECT_PROMPTS["mandarin"])
        system_parts.append(dialect_prompt)

        messages = [{"role": "system", "content": "\n".join(system_parts)}]

        # 最多保留 10 条上下文
        if history:
            for msg in history[-10:]:
                role = "assistant" if msg.get("sender") == "ai" else "user"
                messages.append({"role": role, "content": msg.get("content", "")})

        return messages

    def _mock_junior_reply(self, dialect: str, age_range: str) -> str:
        """模拟未成年人模式回复"""
        replies = {
            "<14": [
                "我听到你说的了。要不要和爸爸妈妈聊聊？",
                "你的感受很重要，但安全第一。我们试试深呼吸好吗？",
                "我理解你有点不开心。我们换个开心的事情聊聊吧？",
                "小朋友，有情绪很正常。不要憋在心里哦。",
            ],
            "14-18": [
                "我听到你表达的情绪了。要不要换个角度看看？",
                "你的感受是真的，但我们不用生气来解决问题。",
                "这种情绪很正常。写下来或者找朋友聊聊可能会好一些。",
                "我知道你现在不太好受。做点喜欢的事情放松一下吧。",
            ],
        }
        pool = replies.get(age_range, replies["14-18"])
        return random.choice(pool)

    def _mock_reply(self, mode: str, chat_style: str, dialect: str) -> str:
        """模拟 AI 回复（开发/无 API 时使用）"""
        replies = {
            "single": {
                "mandarin": "嗯，我听到了，你继续说，我在听。",
                "cantonese": "係嘅，我明你感受，你繼續講。",
                "sichuan": "要得，我晓得了，你尽管说。",
                "northeastern": "唉呀妈呀，那可太过分了，你接着说。",
                "shanghainese": "好好叫，我听了，侬讲下去。",
            },
            "dual": {
                "stubborn": "这事儿跟我没关系啊，你找错人了。",
                "apologetic": "对不起对不起，都是我的错，您消消气。",
                "cold": "哦。你说完了吗？",
                "sarcastic": "哟，这么大火气？也就这点能耐了。",
                "rational": "我们来分析一下，这件事有几个角度可以看。",
            },
        }

        if mode == "single":
            reply_pool = replies["single"]
            reply = reply_pool.get(dialect, reply_pool["mandarin"])
        else:
            reply_pool = replies["dual"]
            reply = reply_pool.get(chat_style, reply_pool["apologetic"])

        # 随机几条不同回复避免重复
        variations = [
            reply,
            reply.replace("。", "…"),
            reply + "还有吗？",
        ]
        return random.choice(variations)


# ============================================================
# 图像生成（AI 形象 + 海报）
# ============================================================

class ImageService:
    """图像生成服务"""

    def __init__(self):
        self._use_mock = not bool(settings.OPENAI_API_KEY)

    async def generate_avatar(
        self, appearance: str, personality: str, style: str = "漫画"
    ) -> str:
        """生成虚拟形象，返回图片 URL"""
        if self._use_mock:
            return self._mock_avatar_url()

        client = AsyncOpenAI(
            api_key=settings.OPENAI_API_KEY,
            base_url=settings.OPENAI_BASE_URL,
        )

        prompt = (
            f"Create a {style} style character portrait based on: "
            f"Appearance: {appearance}. Personality: {personality}. "
            "Make it a cartoon/illustration, not realistic. No real person."
        )

        try:
            response = await client.images.generate(
                model=settings.IMAGE_MODEL,
                prompt=prompt,
                size=settings.IMAGE_SIZE,
                n=1,
            )
            return response.data[0].url or self._mock_avatar_url()
        except Exception:
            return self._mock_avatar_url()

    def _mock_avatar_url(self) -> str:
        """返回模拟头像 URL"""
        colors = ["FF7A56", "4F8B9C", "6B5CE7", "FFB74D", "81C784", "E57373"]
        color = random.choice(colors)
        return f"https://placehold.co/400x400/{color}/white?text=Emo"

    async def generate_poster(self, emotion_data: dict) -> bytes | None:
        """生成海报图片，返回 bytes"""
        # 开发阶段返回 None，海报由前端合成
        return None


# ============================================================
# 语音服务（ASR / TTS）
# ============================================================

class VoiceService:
    """语音服务（预留接口）"""

    async def speech_to_text(self, audio_data: bytes) -> str:
        """语音转文字"""
        if settings.ASR_PROVIDER == "mock":
            return "[语音识别功能开发中]"
        raise NotImplementedError("ASR provider not implemented yet")

    async def text_to_speech(self, text: str, dialect: str = "mandarin") -> bytes:
        """文字转语音"""
        if settings.TTS_PROVIDER == "mock":
            return b"[TTS audio placeholder]"
        raise NotImplementedError("TTS provider not implemented yet")


# 全局单例
ai_service = AiService()
image_service = ImageService()
voice_service = VoiceService()
