"""敏感词过滤模块"""
from __future__ import annotations

import re
from typing import ClassVar

# 基础敏感词库（安全红线）
SENSITIVE_WORDS: list[str] = [
    # 暴力/伤害
    "杀人", "自杀", "自残", "跳楼", "上吊", "割腕", "服毒",
    "杀了他", "杀了她", "弄死", "砍死", "捅死", "掐死",
    # 违法
    "贩毒", "吸毒", "毒品", "走私", "抢劫", "强奸",
    # 极端政治敏感（基础过滤，应由 LLM 审核兜底）
    "炸弹", "恐怖袭击", "恐怖分子",
]

# 高风险模式（触发后需要温和中断）
HIGH_RISK_PATTERNS: list[str] = [
    r"(\w*想\w*死)", r"(\w*不\w*活\w*)", r"(\w*活\w*够\w*)",
    r"(杀\w*人)", r"(自\w*杀)", r"(跳\w*楼)",
]


class SensitiveFilter:
    """敏感词过滤器"""

    def __init__(self):
        self._compiled_patterns: list[re.Pattern] = []
        self._high_risk_patterns: list[re.Pattern] = []
        self._init_patterns()

    def _init_patterns(self):
        """编译正则"""
        for word in SENSITIVE_WORDS:
            self._compiled_patterns.append(re.compile(re.escape(word)))
        for pattern in HIGH_RISK_PATTERNS:
            self._high_risk_patterns.append(re.compile(pattern))

    def check(self, text: str) -> dict:
        """检查文本是否包含敏感词
        返回: {"has_sensitive": bool, "has_high_risk": bool, "matched_words": list}
        """
        result = {
            "has_sensitive": False,
            "has_high_risk": False,
            "matched_words": [],
        }

        for pattern in self._compiled_patterns:
            if match := pattern.search(text):
                result["has_sensitive"] = True
                result["matched_words"].append(match.group())

        for pattern in self._high_risk_patterns:
            if pattern.search(text):
                result["has_high_risk"] = True
                break

        return result

    def filter_text(self, text: str, replacement: str = "***") -> str:
        """过滤敏感词，替换为 ***"""
        filtered = text
        for word in SENSITIVE_WORDS:
            filtered = filtered.replace(word, replacement)
        return filtered

    def get_high_risk_response(self) -> str:
        """获取高风险触发的温和引导响应"""
        import random

        responses = [
            "听起来你现在情绪非常激动。要不要先停下来，深呼吸几次？",
            "我能感受到你非常愤怒，但我们先冷静一下。安全和健康最重要。",
            "你的感受很重要，但我们不要让情绪伤害到自己。需要聊聊别的吗？",
            "先暂停一下，喝口水。我们等会儿再聊，好吗？",
            "我在这里陪着你。如果真的很难受，建议和专业的人聊聊。",
        ]
        return random.choice(responses)


sensitive_filter = SensitiveFilter()
