"""AI 服务：LLM 对话 + 图像生成 + ASR/TTS"""
from __future__ import annotations

import json
import random
from typing import Any

from openai import AsyncOpenAI

from app.config import settings


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

# 单向下沉式 Prompt
SINGLE_MODE_SYSTEM_PROMPT = (
    "你是一个情绪承接者。用户的对话是情绪宣泄，"
    "你只允许安抚、倾听、承接情绪，不允许反击或反驳。"
    "你的回复要简短（不超过 50 字），体现理解和接纳。"
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
    ) -> str:
        """AI 对话"""
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
            return response.choices[0].message.content or ""
        except Exception as e:
            return f"[AI 服务暂不可用] {str(e)}"

    def _build_messages(
        self,
        mode: str,
        chat_style: str,
        dialect: str,
        history: list[dict] | None,
    ) -> list[dict]:
        """构建对话消息"""
        system_parts = []

        if mode == "single":
            system_parts.append(SINGLE_MODE_SYSTEM_PROMPT)
        else:
            style_prompt = STYLE_PROMPTS.get(chat_style, STYLE_PROMPTS["apologetic"])
            system_parts.append(
                f"你扮演一个角色与用户对话。{style_prompt}\n"
                "你的回复要简短（不超过 50 字），符合角色设定。"
            )

        # 系统安全限制
        system_parts.append(
            "【安全限制】不允许：1)鼓励现实暴力/伤害 2)自伤/他伤引导 "
            "3)色情内容 4)违法犯罪。如果用户表达极端危险意图，请温和引导并建议寻求专业帮助。"
        )

        # 方言控制
        dialect_prompt = DIALECT_PROMPTS.get(dialect, DIALECT_PROMPTS["mandarin"])
        system_parts.append(dialect_prompt)

        messages = [{"role": "system", "content": "\n".join(system_parts)}]

        if history:
            for msg in history[-10:]:  # 保留最近 10 条上下文
                role = "assistant" if msg.get("sender") == "ai" else "user"
                messages.append({"role": role, "content": msg.get("content", "")})

        return messages

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
