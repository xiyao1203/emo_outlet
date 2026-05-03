"""情绪分析服务"""
from __future__ import annotations

import json
import random
from typing import Any

from app.schemas.poster import EmotionAnalysisResult


# 情绪关键词映射
EMOTION_KEYWORDS = {
    "愤怒": [
        "气死", "混蛋", "烦死了", "受不了", "可恶", "滚", "恶心",
        "去死", "垃圾", "废物", "操", "他妈的", "王八蛋",
    ],
    "悲伤": [
        "难过", "伤心", "哭", "委屈", "想哭", "心痛", "绝望",
        "孤独", "失落", "失望", "无助",
    ],
    "焦虑": [
        "担心", "害怕", "紧张", "不安", "焦虑", "恐慌", "压力",
        "睡不着", "烦躁",
    ],
    "疲惫": [
        "累", "累了", "疲惫", "不想动", "没劲", "困", "乏",
        "精疲力尽",
    ],
    "无奈": [
        "算了", "随便", "无所谓", "就这样吧", "没办法", "认了",
        "懒得说", "凑合",
    ],
}


class EmotionService:
    """情绪分析服务"""

    async def analyze_messages(self, messages: list[dict]) -> EmotionAnalysisResult:
        """分析会话中的消息，输出情绪分析结果"""
        if not messages:
            return EmotionAnalysisResult(
                primary_emotion="平静",
                emotions={"平静": 100.0},
                intensity=0,
                keywords=[],
                summary="没有检测到明显的情绪波动。",
                suggestion="找个时间聊聊你的心情吧。",
            )

        # 提取用户消息
        user_messages = [
            m["content"] for m in messages if m.get("sender") == "user"
        ]
        text = " ".join(user_messages)

        if not text.strip():
            return EmotionAnalysisResult(
                primary_emotion="平静",
                emotions={"平静": 100.0},
                intensity=0,
                keywords=[],
                summary="对话中没有留下文字内容。",
                suggestion="试试说出你的感受。",
            )

        # 情绪检测
        emotion_scores = self._detect_emotions(text)
        primary = max(emotion_scores, key=emotion_scores.get)
        intensity = int(emotion_scores[primary])

        # 关键词提取
        keywords = self._extract_keywords(text)

        # 生成总结和建议
        summary = self._generate_summary(primary, intensity, keywords)
        suggestion = self._generate_suggestion(primary)

        return EmotionAnalysisResult(
            primary_emotion=primary,
            emotions=emotion_scores,
            intensity=intensity,
            keywords=keywords[:8],
            summary=summary,
            suggestion=suggestion,
        )

    def _detect_emotions(self, text: str) -> dict[str, float]:
        """检测文本中的情绪分布"""
        scores: dict[str, float] = {}
        total_score = 0.0

        for emotion, keywords in EMOTION_KEYWORDS.items():
            score = 0.0
            for keyword in keywords:
                count = text.count(keyword)
                score += count * 10
            if score > 0:
                scores[emotion] = min(score, 100)
                total_score += score

        # 归一化
        if scores:
            max_score = max(scores.values())
            if max_score > 0:
                for k in scores:
                    scores[k] = round((scores[k] / max_score) * 100, 1)

        # 添加"平静"基线
        if not scores:
            scores["平静"] = 100.0
        else:
            calm = max(0, 100 - max(scores.values()))
            scores["平静"] = round(calm, 1)

        # 按强度排序
        return dict(sorted(scores.items(), key=lambda x: x[1], reverse=True))

    def _extract_keywords(self, text: str) -> list[str]:
        """提取高频情绪关键词"""
        found = []
        for emotion, keywords in EMOTION_KEYWORDS.items():
            for kw in keywords:
                if kw in text and kw not in found:
                    found.append(kw)
        return found

    def _generate_summary(self, emotion: str, intensity: int, keywords: list[str]) -> str:
        """生成情绪总结文案"""
        templates = {
            "愤怒": [
                f"你表达了强烈的愤怒情绪（{intensity}%），看起来有些事情让你非常不满。",
                "愤怒是正常的情绪，重要的是你选择了安全的释放方式。",
                f"你用了「{keywords[0] if keywords else '强烈'}」这样的词汇来表达不满。",
            ],
            "悲伤": [
                f"你流露出悲伤的情绪（{intensity}%），似乎有些事情让你感到难过。",
                "允许自己难过也是一种勇气。",
            ],
            "焦虑": [
                f"你感到明显的焦虑（{intensity}%），压力和不安在影响着你。",
                "识别焦虑是管理焦虑的第一步。",
            ],
            "疲惫": [
                f"你表达了疲惫感（{intensity}%），身心需要休息。",
                "累了就歇一歇，不必总是坚强。",
            ],
            "无奈": [
                f"你透露出一些无奈（{intensity}%），有些事情可能暂时无法改变。",
                "接受不能改变的，改变能改变的。",
            ],
        }

        pool = templates.get(emotion, ["你完成了一次情绪释放。"])
        return random.choice(pool)

    def _generate_suggestion(self, emotion: str) -> str:
        """生成情绪调节建议"""
        suggestions = {
            "愤怒": "试试深呼吸 5 次，喝杯水。如果需要，出去走走换个环境。",
            "悲伤": "允许自己难过，但不要沉浸在情绪里太久了。听点喜欢的音乐吧。",
            "焦虑": "把担心的事情写下来，分清楚哪些是可以控制的，哪些不是。",
            "疲惫": "今天就到这里吧。泡杯热茶，早点休息。",
            "无奈": "有些事情需要时间，不必急于解决。照顾好自己。",
        }
        return suggestions.get(emotion, "照顾好自己，情绪总会过去的。")


emotion_service = EmotionService()
