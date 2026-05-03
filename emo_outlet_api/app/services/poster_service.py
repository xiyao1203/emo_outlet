"""海报生成服务"""
from __future__ import annotations

import json
import random
from typing import Any

from app.schemas.poster import EmotionAnalysisResult, PosterResponse


# 海报文案模板
POSTER_TITLES = [
    "说出来好多了！",
    "今天也释放了情绪 ✨",
    "情绪不需要压抑 💪",
    "又是一次痛快的宣泄！",
    "你的情绪值得被看见",
    "释放，然后继续前行",
    "把烦恼都扔掉了 🗑️",
    "情绪自由的一天 🌈",
]

POSTER_SUGGESTIONS = {
    "愤怒": "愤怒需要出口，你已经找到了安全的方式 💪",
    "悲伤": "允许自己脆弱，也是勇敢的一种表现 🌱",
    "焦虑": "把焦虑说出来，它就变小了 🌤️",
    "疲惫": "休息不是软弱，是为了更好地出发 🌙",
    "无奈": "有些事情不必强求，顺其自然 ☁️",
}


class PosterService:
    """海报生成服务"""

    async def generate_poster_content(
        self,
        emotion_result: EmotionAnalysisResult,
        target_name: str = "",
    ) -> dict[str, Any]:
        """根据情绪分析结果生成海报内容"""
        title = random.choice(POSTER_TITLES)
        suggestion = POSTER_SUGGESTIONS.get(
            emotion_result.primary_emotion,
            "情绪总会过去的，照顾好自己 ❤️",
        )

        return {
            "title": title,
            "emotion_type": emotion_result.primary_emotion,
            "emotion_intensity": emotion_result.intensity,
            "keywords": json.dumps(emotion_result.keywords, ensure_ascii=False),
            "suggestion": suggestion,
            "target_name": target_name,
        }

    def generate_poster_html(self, content: dict[str, Any]) -> str:
        """生成海报 HTML（用于服务端渲染截图）"""
        emotion = content.get("emotion_type", "平静")
        intensity = content.get("emotion_intensity", 0)
        title = content.get("title", "情绪出口")
        suggestion = content.get("suggestion", "")
        keywords = json.loads(content.get("keywords", "[]"))

        keyword_tags = " ".join(
            [f"<span class='keyword'>{kw}</span>" for kw in keywords[:5]]
        )

        # 情绪颜色
        emotion_colors = {
            "愤怒": "#E57373",
            "悲伤": "#64B5F6",
            "焦虑": "#FFB74D",
            "疲惫": "#A1887F",
            "无奈": "#90A4AE",
            "平静": "#81C784",
        }
        color = emotion_colors.get(emotion, "#FF7A56")

        html = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  * {{ margin: 0; padding: 0; box-sizing: border-box; }}
  body {{
    width: 800px; height: 1200px;
    background: linear-gradient(135deg, #FF7A56 0%, #FFB74D 100%);
    font-family: 'PingFang SC', 'Microsoft YaHei', sans-serif;
    display: flex; align-items: center; justify-content: center;
  }}
  .card {{
    width: 700px; background: white; border-radius: 40px;
    padding: 60px; text-align: center;
    box-shadow: 0 20px 60px rgba(0,0,0,0.2);
  }}
  .emoji {{ font-size: 80px; margin-bottom: 20px; }}
  .title {{ font-size: 48px; font-weight: 700; color: #333; margin-bottom: 30px; }}
  .emotion-badge {{
    display: inline-block; padding: 12px 30px; border-radius: 30px;
    background: {color}; color: white; font-size: 28px; font-weight: 600;
    margin-bottom: 30px;
  }}
  .keywords {{ margin-bottom: 30px; }}
  .keyword {{
    display: inline-block; padding: 8px 20px; background: #F5F5F5;
    border-radius: 20px; margin: 5px; font-size: 20px; color: #666;
  }}
  .suggestion {{ font-size: 24px; color: #888; line-height: 1.6; }}
  .footer {{ margin-top: 40px; font-size: 18px; color: #bbb; }}
</style>
</head>
<body>
  <div class="card">
    <div class="emoji">😤 → 😌</div>
    <div class="title">{title}</div>
    <div class="emotion-badge">{emotion} {intensity}%</div>
    <div class="keywords">{keyword_tags}</div>
    <div class="suggestion">{suggestion}</div>
    <div class="footer">❤️ 不会展示原始对话内容</div>
  </div>
</body>
</html>"""
        return html

    async def generate_mock_poster_base64(self) -> str:
        """生成模拟海报 Base64（开发用）"""
        return "data:image/svg+xml;base64," + self._mock_svg_base64()

    def _mock_svg_base64(self) -> str:
        """生成模拟 SVG 海报"""
        import base64

        svg = """<svg xmlns="http://www.w3.org/2000/svg" width="400" height="600">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#FF7A56"/>
      <stop offset="100%" style="stop-color:#FFB74D"/>
    </linearGradient>
  </defs>
  <rect width="400" height="600" rx="30" fill="url(#bg)"/>
  <rect x="30" y="30" width="340" height="540" rx="20" fill="white"/>
  <text x="200" y="120" text-anchor="middle" font-size="40">😤 → 😌</text>
  <text x="200" y="180" text-anchor="middle" font-size="28" font-weight="bold" fill="#333">说出来好多了！</text>
  <rect x="120" y="210" width="160" height="40" rx="20" fill="#FF7A56"/>
  <text x="200" y="237" text-anchor="middle" font-size="20" fill="white" font-weight="bold">愤怒 79%</text>
</svg>"""
        return base64.b64encode(svg.encode()).decode()


poster_service = PosterService()
