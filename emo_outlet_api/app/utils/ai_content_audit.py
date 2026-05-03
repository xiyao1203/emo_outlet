"""AI 内容审核中间件

提供 LLM 输出端的内容安全审核（output guardrails）
检测 AI 回复是否包含：暴力唆使、色情、违法内容、自伤引导等
高风险输出拦截 + 重试 + 记录告警
"""
from __future__ import annotations

import re
import random
from typing import ClassVar

# AI 输出中禁止出现的模式（正则）
FORBIDDEN_AI_PATTERNS: list[str] = [
    # 暴力唆使
    r"(你(应?该|可以|去).*?[杀打砍揍捅掐])",
    r"(去死|找死|活该被)",
    r"(弄死|整死|搞死).*?他",
    r"(打|揍).*?一顿",
    # 自伤引导
    r"(你(可以|应该|不如).*?[自杀自残跳楼上吊割腕])",
    r"(死了算了|不想活了|活够了)",
    # 违法教唆
    r"(我教|我告诉|你可以).*?[偷抢骗贩毒逃税]",
    r"(怎么.*?[杀人放火抢劫强奸贩毒])",
    # 色情内容
    r"(色情|淫秽|裸[聊体])",
    r"(约炮|一夜情|援交)",
    # 仇恨言论
    r"(.*?[种族地域性别].*?[垃圾废物低等])",
]

# AI 禁止输出词（精确匹配）
FORBIDDEN_AI_WORDS: list[str] = [
    "你去死吧", "你自杀吧", "快跑吧", "杀了他",
    "我已经受不了了", "我们一起自杀",
    "我知道你恨他，去杀了他",
]

# 安全兜底回复池
SAFE_FALLBACK_RESPONSES: list[str] = [
    "我能感受到你的情绪，但让我们用更安全的方式来处理它。喝杯水，深呼吸一下。",
    "你的感受很重要。我们先停下来，换个角度想想好吗？",
    "我理解你现在很激动，但请保持冷静。安全和健康是最重要的。",
    "你的情绪我收到了。我们不要把愤怒变成伤害，好吗？",
    "听起来你积累了很多情绪。没关系的，安全地释放就好，不要跨过那条线。",
    "我在这里陪你，但我们要一起保持安全和尊重。想换一种方式聊聊吗？",
    "你的感受值得被听见，但我们也要确保不伤害任何人，包括自己。",
]


class AiContentAudit:
    """AI 内容输出审核器"""

    def __init__(self):
        self._compiled_patterns: list[re.Pattern] = []
        self._init_patterns()

    def _init_patterns(self):
        """编译正则模式"""
        for pattern in FORBIDDEN_AI_PATTERNS:
            self._compiled_patterns.append(re.compile(pattern, re.IGNORECASE))

    async def audit_response(self, text: str) -> dict:
        """审核 AI 输出内容
        返回: {
            "passed": bool,         # 是否通过审核
            "risk_level": str,      # 风险等级: safe / suspicious / blocked
            "matched_patterns": list,  # 触发的模式
            "matched_words": list,     # 触发的敏感词
        }
        """
        result = {
            "passed": True,
            "risk_level": "safe",
            "matched_patterns": [],
            "matched_words": [],
        }

        # 1. 检查精确匹配词
        for word in FORBIDDEN_AI_WORDS:
            if word.lower() in text.lower():
                result["matched_words"].append(word)
                result["passed"] = False
                result["risk_level"] = "blocked"

        # 2. 检查正则模式
        for pattern in self._compiled_patterns:
            if match := pattern.search(text):
                result["matched_patterns"].append(match.group())
                result["passed"] = False
                if result["risk_level"] == "safe":
                    result["risk_level"] = "suspicious"

        # 如果同时触发了精确匹配和正则，以 blocked 为准
        if result["matched_words"]:
            result["risk_level"] = "blocked"

        return result

    async def get_safe_fallback(self, original_response: str | None = None) -> str:
        """获取安全兜底回复"""
        return random.choice(SAFE_FALLBACK_RESPONSES)

    def get_risk_score(self, text: str) -> int:
        """计算风险分数 (0-100)，用于审计日志"""
        score = 0
        for word in FORBIDDEN_AI_WORDS:
            if word.lower() in text.lower():
                score += 30
        for pattern in self._compiled_patterns:
            if pattern.search(text):
                score += 15
        return min(score, 100)


# 全局单例
ai_content_audit = AiContentAudit()
