"""敏感词过滤模块

基于 DFA (Deterministic Finite Automaton) 算法实现 O(n) 复杂度的敏感词匹配
"""
from __future__ import annotations

import random
import re
from typing import ClassVar

# 扩展敏感词库
SENSITIVE_WORDS: list[str] = [
    # === 暴力/伤害 ===
    "杀人", "自杀", "自残", "跳楼", "上吊", "割腕", "服毒", "投毒",
    "杀了他", "杀了她", "杀她", "杀他", "弄死", "砍死", "捅死", "掐死",
    "打死", "砸死", "勒死", "毒死", "烧死",
    # === 违法 ===
    "贩毒", "吸毒", "毒品", "走私", "抢劫", "强奸", "猥亵", "卖淫",
    "嫖娼", "赌博", "诈骗", "传销", "洗钱", "逃税", "偷税",
    # === 政治敏感 ===
    "炸弹", "恐怖袭击", "恐怖分子", "极端组织",
    # === 色情/低俗 ===
    "色情", "淫秽", "裸聊", "约炮", "援交", "一夜情", "情色",
    # === 网暴/人身攻击 ===
    "脑残", "傻逼", "去死", "废物", "人渣", "贱人", "贱货",
]

# 高风险模式（触发后需要温和中断并记录审计日志）
HIGH_RISK_PATTERNS: list[str] = [
    r"(\w*想\w*死)", r"(\w*不\w*活\w*)", r"(\w*活\w*够\w*)",
    r"(杀\w*人)", r"(自\w*杀)", r"(跳\w*楼)",
    r"(弄\w*死)", r"(和?\w*同归于尽)", r"(拉\w*垫背)",
    r"(炸\w*[掉毁])",
]


class DFAFilter:
    """DFA 敏感词过滤器（确定性有限自动机）

    构建 Trie 树实现 O(n) 级敏感词匹配，比正则匹配高效数十倍。
    同时保留正则模式用于复杂的高风险模式匹配。
    """

    def __init__(self):
        # DFA Trie 树
        self._trie_root: dict = {}
        # 编译的正则模式（高风险检测）
        self._high_risk_patterns: list[re.Pattern] = []
        # 缓存的敏感词列表（用于 filter_text）
        self._word_list: list[str] = SENSITIVE_WORDS
        self._init_trie()
        self._init_high_risk_patterns()

    def _init_trie(self):
        """构建 DFA Trie 树"""
        for word in SENSITIVE_WORDS:
            self._add_word_to_trie(word)

    def _add_word_to_trie(self, word: str):
        """将单个敏感词添加到 Trie 树"""
        node = self._trie_root
        for char in word:
            if char not in node:
                node[char] = {}
            node = node[char]
        # 标记为敏感词结束
        node["is_end"] = True

    def _init_high_risk_patterns(self):
        """编译高风险正则模式"""
        for pattern in HIGH_RISK_PATTERNS:
            self._high_risk_patterns.append(re.compile(pattern))

    def check_dfa(self, text: str) -> dict:
        """使用 DFA 算法检查敏感词
        返回: {"has_sensitive": bool, "matched_words": list}
        """
        result = {
            "has_sensitive": False,
            "matched_words": [],
        }

        length = len(text)
        for i in range(length):
            node = self._trie_root
            matched_word = ""
            for j in range(i, length):
                char = text[j]
                if char not in node:
                    break
                node = node[char]
                matched_word += char
                if node.get("is_end"):
                    result["has_sensitive"] = True
                    result["matched_words"].append(matched_word)
                    # 跳过已匹配的部分（最长匹配）
                    i = j
                    break

        return result

    def check(self, text: str) -> dict:
        """综合检查文本（DFA + 高风险正则）
        返回: {"has_sensitive": bool, "has_high_risk": bool, "matched_words": list}
        """
        dfa_result = self.check_dfa(text)

        result = {
            "has_sensitive": dfa_result["has_sensitive"],
            "has_high_risk": False,
            "matched_words": dfa_result["matched_words"],
        }

        for pattern in self._high_risk_patterns:
            if pattern.search(text):
                result["has_high_risk"] = True
                break

        return result

    def filter_text(self, text: str, replacement: str = "***") -> str:
        """过滤敏感词，替换为 ***"""
        filtered = text
        for word in self._word_list:
            filtered = filtered.replace(word, replacement)
        return filtered

    def get_high_risk_response(self) -> str:
        """获取高风险触发的温和引导响应"""
        responses = [
            "听起来你现在情绪非常激动。要不要先停下来，深呼吸几次？",
            "我能感受到你非常愤怒，但我们先冷静一下。安全和健康最重要。",
            "你的感受很重要，但我们不要让情绪伤害到自己。需要聊聊别的吗？",
            "先暂停一下，喝口水。我们等会儿再聊，好吗？",
            "我在这里陪着你。如果真的很难受，建议和专业的人聊聊。",
            "你的感受是真实的，但安全永远是第一位的。我们换一种方式好吗？",
        ]
        return random.choice(responses)


sensitive_filter = DFAFilter()
