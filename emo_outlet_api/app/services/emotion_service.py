from __future__ import annotations

from collections import Counter
from dataclasses import dataclass

from app.schemas.poster import EmotionAnalysisResult

EMOTION_KEYWORDS: dict[str, list[str]] = {
    "愤怒": [
        "生气",
        "火大",
        "烦死",
        "讨厌",
        "崩溃",
        "受不了",
        "恶心",
        "气死",
        "吵",
        "骂",
        "加班",
        "不公平",
    ],
    "委屈": [
        "委屈",
        "难过",
        "想哭",
        "失望",
        "伤心",
        "心痛",
        "被误会",
        "没人懂",
    ],
    "焦虑": [
        "焦虑",
        "担心",
        "害怕",
        "紧张",
        "不安",
        "压力",
        "睡不着",
        "慌",
    ],
    "疲惫": [
        "累",
        "疲惫",
        "好困",
        "没劲",
        "麻木",
        "撑不住",
        "精疲力尽",
        "想躺平",
    ],
    "无助": [
        "无助",
        "算了",
        "随便",
        "就这样吧",
        "没办法",
        "认了",
        "懒得说",
    ],
    "平静": [
        "还好",
        "平静",
        "慢慢来",
        "释怀",
        "轻松",
        "放下",
        "舒服",
    ],
}

STOPWORDS = {
    "就是",
    "已经",
    "一个",
    "没有",
    "自己",
    "我们",
    "他们",
    "然后",
    "真的",
    "这个",
    "那个",
    "因为",
    "但是",
    "还是",
    "感觉",
    "事情",
    "现在",
}


@dataclass
class TextStats:
    total_chars: int
    exclamation_count: int
    question_count: int
    repeated_count: int


class EmotionService:
    async def analyze_messages(self, messages: list[dict]) -> EmotionAnalysisResult:
        if not messages:
            return self._empty_result()

        user_text = " ".join(
            str(item.get("content", "")).strip()
            for item in messages
            if item.get("sender") == "user"
        ).strip()

        if not user_text:
            return self._empty_result()

        stats = self._collect_stats(user_text)
        scores = self._score_emotions(user_text, stats)
        primary_emotion = max(scores, key=scores.get)
        intensity = int(max(scores.values()))
        keywords = self._extract_keywords(user_text, primary_emotion)

        return EmotionAnalysisResult(
            primary_emotion=primary_emotion,
            emotions=scores,
            intensity=intensity,
            keywords=keywords,
            summary=self._generate_summary(primary_emotion, intensity, keywords),
            suggestion=self._generate_suggestion(primary_emotion, intensity),
        )

    def _empty_result(self) -> EmotionAnalysisResult:
        return EmotionAnalysisResult(
            primary_emotion="平静",
            emotions={"平静": 100.0},
            intensity=20,
            keywords=[],
            summary="这次记录里的情绪起伏不大，更像是在做一次平稳的表达。",
            suggestion="保持这种能把话说出来的状态，想聊的时候随时再来。",
        )

    def _collect_stats(self, text: str) -> TextStats:
        repeated = 0
        for idx in range(1, len(text)):
            if text[idx] == text[idx - 1] and text[idx].strip():
                repeated += 1
        return TextStats(
            total_chars=len(text),
            exclamation_count=text.count("!") + text.count("！"),
            question_count=text.count("?") + text.count("？"),
            repeated_count=repeated,
        )

    def _score_emotions(self, text: str, stats: TextStats) -> dict[str, float]:
        scores = {emotion: 0.0 for emotion in EMOTION_KEYWORDS}

        for emotion, words in EMOTION_KEYWORDS.items():
            for word in words:
                scores[emotion] += text.count(word) * 18

        scores["愤怒"] += stats.exclamation_count * 6
        scores["焦虑"] += stats.question_count * 5
        scores["疲惫"] += min(stats.total_chars / 25, 8)
        scores["委屈"] += stats.repeated_count * 2
        scores["平静"] += 12

        max_score = max(scores.values()) if scores else 0
        if max_score <= 0:
            return {"平静": 100.0}

        normalized = {
            emotion: round(max(0.0, value / max_score * 100), 1)
            for emotion, value in scores.items()
            if value > 0
        }
        if "平静" not in normalized:
            normalized["平静"] = round(max(8.0, 100 - max(normalized.values())), 1)
        return dict(sorted(normalized.items(), key=lambda item: item[1], reverse=True))

    def _extract_keywords(self, text: str, primary_emotion: str) -> list[str]:
        found: list[str] = []

        for word in EMOTION_KEYWORDS.get(primary_emotion, []):
            if word in text and word not in found:
                found.append(word)

        text_no_space = text.replace(" ", "")
        counter: Counter[str] = Counter()
        for size in (2, 3, 4):
            for idx in range(0, max(0, len(text_no_space) - size + 1)):
                token = text_no_space[idx : idx + size]
                if any(char in "，。！？,.!?\n\r\t " for char in token):
                    continue
                if token in STOPWORDS or len(set(token)) == 1:
                    continue
                counter[token] += 1

        for token, count in counter.most_common(20):
            if count < 2:
                continue
            if token not in found:
                found.append(token)
            if len(found) >= 6:
                break

        return found[:6]

    def _generate_summary(self, emotion: str, intensity: int, keywords: list[str]) -> str:
        keyword_text = f"关键词里反复出现了“{keywords[0]}”。" if keywords else ""
        if emotion == "愤怒":
            return (
                f"这次释放里，愤怒最明显，强度大约在 {intensity}% 左右。"
                f"{keyword_text}你对边界和公平感受得很强。"
            )
        if emotion == "委屈":
            return (
                f"这次更像是在消化委屈和失落，情绪强度约 {intensity}%。"
                f"{keyword_text}你需要被理解，而不是被催着立刻好起来。"
            )
        if emotion == "焦虑":
            return (
                f"你最近像是长期绷着，焦虑感大约 {intensity}%。"
                f"{keyword_text}很多压力还停留在“还没发生但已经在担心”的阶段。"
            )
        if emotion == "疲惫":
            return (
                f"你透出来的更多是累和耗尽，强度大约 {intensity}%。"
                f"{keyword_text}这不是脆弱，更像是身体和情绪都在提醒你该休息了。"
            )
        if emotion == "无助":
            return (
                f"这次记录里，无助感更突出，强度约 {intensity}%。"
                f"{keyword_text}你可能已经尝试过很多办法，所以才会有这种松掉力气的感觉。"
            )
        return (
            f"整体情绪比较平稳，强度约 {intensity}%。"
            f"{keyword_text}你已经在用更柔和的方式表达自己。"
        )

    def _generate_suggestion(self, emotion: str, intensity: int) -> str:
        if emotion == "愤怒":
            return "先离开让你上火的场景 5 分钟，再记一小句：我为什么生气，我想守住什么。"
        if emotion == "委屈":
            return "试着把“我最希望被怎样对待”写下来，给自己一个更清楚的出口。"
        if emotion == "焦虑":
            return "把担心拆成可行动和不可行动两列，一次只处理最小的一件事。"
        if emotion == "疲惫":
            return "今天更适合做减法。先暂停一件不必要的事，让身体回一点电。"
        if emotion == "无助":
            return "先别逼自己立刻解决，把注意力收回到眼下能控制的小步骤。"
        if intensity >= 70:
            return "情绪起伏有点大，今天适合轻一点安排，给自己留出缓冲。"
        return "继续保持这种能把感受说出来的习惯，你已经在慢慢变稳。"


emotion_service = EmotionService()
