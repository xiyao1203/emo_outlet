from __future__ import annotations

import base64
import html
import json
from typing import Any

from app.schemas.poster import EmotionAnalysisResult

EMOTION_STYLES: dict[str, dict[str, str]] = {
    "愤怒": {
        "title": "把情绪装进瓶子里",
        "subtitle": "然后，轻轻放下",
        "badge": "释放·释放火气",
        "accent": "#FF7B6B",
        "secondary": "#FFC29A",
        "summary": "每一次安全释放，都是在帮情绪找出口。",
    },
    "委屈": {
        "title": "委屈也值得被看见",
        "subtitle": "先承认难受，再慢慢安放它",
        "badge": "释放·接住委屈",
        "accent": "#FF8D9D",
        "secondary": "#FFD2D8",
        "summary": "情绪被接住的时候，人会慢慢松下来。",
    },
    "焦虑": {
        "title": "先把心放慢一点",
        "subtitle": "担心说出来，压迫感会变小",
        "badge": "释放·拆解压力",
        "accent": "#8C7CFF",
        "secondary": "#D8D2FF",
        "summary": "当你开始说清压力，它就不再只有重量。",
    },
    "疲惫": {
        "title": "允许自己缓一缓",
        "subtitle": "累的时候，不必硬撑",
        "badge": "释放·安顿疲惫",
        "accent": "#6CC6A2",
        "secondary": "#D9F5E9",
        "summary": "休息不是退后，而是在帮自己恢复力量。",
    },
    "无奈": {
        "title": "先把没办法说出来",
        "subtitle": "松一点，事情才有空间",
        "badge": "释放·松开执拗",
        "accent": "#F4A85A",
        "secondary": "#FFE3BC",
        "summary": "允许事情先停在这里，也是一种温柔。",
    },
    "平静": {
        "title": "你正在慢慢变稳",
        "subtitle": "把感受说出来，本身就是整理",
        "badge": "释放·轻轻落地",
        "accent": "#6FA8FF",
        "secondary": "#D6E7FF",
        "summary": "稳定不是没有情绪，而是能温柔地对待它。",
    },
}


def _svg_data_url(svg: str) -> str:
    return "data:image/svg+xml;base64," + base64.b64encode(svg.encode("utf-8")).decode("ascii")


class PosterService:
    async def generate_poster_content(
        self,
        emotion_result: EmotionAnalysisResult,
        target_name: str = "",
    ) -> dict[str, Any]:
        style = EMOTION_STYLES.get(emotion_result.primary_emotion, EMOTION_STYLES["平静"])
        keywords = emotion_result.keywords[:5]
        title = style["title"]
        if target_name:
            title = f"{title}"

        return {
            "title": title,
            "subtitle": style["subtitle"],
            "emotion_type": emotion_result.primary_emotion,
            "emotion_intensity": emotion_result.intensity,
            "keywords": json.dumps(keywords, ensure_ascii=False),
            "suggestion": emotion_result.suggestion or style["summary"],
            "summary": emotion_result.summary or style["summary"],
            "tag": style["badge"],
            "target_name": target_name,
            "accent": style["accent"],
            "secondary": style["secondary"],
        }

    def generate_poster_html(self, content: dict[str, Any]) -> str:
        keywords = json.loads(content.get("keywords", "[]"))
        chips = "".join(
            f"<span class='chip'>{html.escape(keyword)}</span>" for keyword in keywords
        )
        return f"""<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="utf-8" />
  <style>
    * {{ box-sizing: border-box; }}
    body {{
      width: 800px;
      height: 1200px;
      margin: 0;
      background: linear-gradient(180deg, {content['secondary']} 0%, #FFF6F2 100%);
      font-family: "PingFang SC", "Microsoft YaHei", sans-serif;
      color: #2A2524;
    }}
    .page {{
      height: 100%;
      padding: 54px;
    }}
    .hero {{
      height: 760px;
      border-radius: 42px;
      padding: 64px;
      background: linear-gradient(180deg, {content['secondary']} 0%, {content['accent']}55 100%);
      position: relative;
      overflow: hidden;
    }}
    .title {{ font-size: 58px; line-height: 1.35; margin: 0; }}
    .subtitle {{ margin-top: 18px; font-size: 30px; color: #6E605A; }}
    .orb {{
      position: absolute;
      right: 78px;
      bottom: 112px;
      width: 220px;
      height: 220px;
      border-radius: 50%;
      background: radial-gradient(circle at 50% 45%, #FFFFFF 0%, {content['accent']} 72%);
      box-shadow: 0 18px 45px rgba(255, 140, 120, 0.35);
    }}
    .meta {{
      margin-top: 24px;
      padding: 26px 32px;
      border-radius: 30px;
      background: rgba(255,255,255,0.82);
      display: flex;
      align-items: center;
      justify-content: space-between;
      gap: 20px;
    }}
    .badge {{
      padding: 10px 20px;
      border-radius: 999px;
      background: rgba(255,255,255,0.9);
      color: {content['accent']};
      font-size: 24px;
      font-weight: 600;
    }}
    .chips {{ margin-top: 26px; display: flex; flex-wrap: wrap; gap: 12px; }}
    .chip {{
      padding: 10px 18px;
      border-radius: 999px;
      background: rgba(255,255,255,0.8);
      color: #695E59;
      font-size: 22px;
    }}
    .footer {{
      margin-top: 28px;
      border-radius: 30px;
      background: rgba(255,255,255,0.86);
      padding: 28px 32px;
    }}
    .footer h3 {{ margin: 0 0 10px 0; font-size: 30px; }}
    .footer p {{ margin: 0; font-size: 24px; line-height: 1.7; color: #635954; }}
  </style>
</head>
<body>
  <div class="page">
    <section class="hero">
      <h1 class="title">{html.escape(content['title'])}</h1>
      <div class="subtitle">{html.escape(content['subtitle'])}</div>
      <div class="chips">{chips}</div>
      <div class="orb"></div>
    </section>
    <section class="meta">
      <div>{html.escape(content['emotion_type'])} · {content['emotion_intensity']}%</div>
      <div class="badge">{html.escape(content['tag'])}</div>
    </section>
    <section class="footer">
      <h3>给此刻的你</h3>
      <p>{html.escape(content['suggestion'])}</p>
    </section>
  </div>
</body>
</html>"""

    async def generate_mock_poster_base64(self, content: dict[str, Any]) -> str:
        keywords = json.loads(content.get("keywords", "[]"))
        chips = " ".join(keywords[:4])
        svg = f"""
<svg xmlns="http://www.w3.org/2000/svg" width="720" height="1280" viewBox="0 0 720 1280">
  <defs>
    <linearGradient id="bg" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="{content['secondary']}"/>
      <stop offset="100%" stop-color="#FFF7F2"/>
    </linearGradient>
    <linearGradient id="orb" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#FFFFFF"/>
      <stop offset="100%" stop-color="{content['accent']}"/>
    </linearGradient>
  </defs>
  <rect width="720" height="1280" fill="url(#bg)"/>
  <rect x="34" y="48" width="652" height="840" rx="42" fill="#FFFFFFAA"/>
  <text x="86" y="170" font-size="54" fill="#6A4D45" font-family="Arial, sans-serif">{html.escape(content['title'])}</text>
  <text x="86" y="244" font-size="34" fill="#8B7068" font-family="Arial, sans-serif">{html.escape(content['subtitle'])}</text>
  <circle cx="530" cy="560" r="126" fill="url(#orb)"/>
  <text x="86" y="960" font-size="30" fill="{content['accent']}" font-family="Arial, sans-serif">{html.escape(content['tag'])}</text>
  <text x="86" y="1020" font-size="26" fill="#5D5551" font-family="Arial, sans-serif">{html.escape(content['emotion_type'])} {content['emotion_intensity']}%</text>
  <text x="86" y="1080" font-size="24" fill="#84756E" font-family="Arial, sans-serif">{html.escape(chips or '释放 情绪 自我照顾')}</text>
  <text x="86" y="1162" font-size="24" fill="#6A625E" font-family="Arial, sans-serif">{html.escape(content['summary'])}</text>
</svg>
""".strip()
        return _svg_data_url(svg)


poster_service = PosterService()
