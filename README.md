# 情绪出口 (Emo Outlet)

> **一个"可以安全骂人，但不会伤害任何人的 AI 出气筒"**

一款基于 AI 的安全情绪释放工具，通过虚拟对象、对话互动、方言表达和情绪可视化，帮助用户释放压力、整理情绪。

---

## 📱 项目概览

| 模块 | 技术栈 | 目录 |
|------|--------|------|
| **前端 App** | Flutter (Android + macOS) | [`emo_outlet_app/`](emo_outlet_app) |
| **后端 API** | Python FastAPI + SQLAlchemy + MySQL/SQLite | [`emo_outlet_api/`](emo_outlet_api) |
| **AI 引擎** | OpenAI / DeepSeek / 通义千问 API | `emo_outlet_api/app/services/` |

---

## ✨ 核心功能

- **泄愤对象系统** — 创建虚拟对象（老板/同事/伴侣等），AI 自动生成形象
- **单向 / 双向对话** — 单向纯承接 or 双向 AI 反驳，5 种 AI 人格可选
- **方言支持** — 普通话 / 粤语 / 四川话 / 东北话 / 上海话
- **时间控制** — 1/3/5/10 分钟倒计时，到点自动结束
- **情绪分析** — 关键词识别 + 情绪分布 + 强度评估 + 调节建议
- **海报生成** — 情绪可视化海报，可保存分享（不展示对话原文）
- **情绪报告** — 周 / 月 / 年度情绪趋势统计
- **安全防护** — 敏感词过滤 + 高风险自动中断 + 数据端侧加密

---

## 🚀 快速开始

### 后端 API

```bash
cd emo_outlet_api
pip install -r requirements.txt

# 开发模式启动（无需 MySQL，自动使用 SQLite）
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

访问 http://localhost:8000/docs 查看 Swagger API 文档。

### 前端 App

```bash
cd emo_outlet_app
flutter pub get
flutter run
```

> 首次运行需要先启动后端 API，或修改 `api_service.dart` 中的 `baseUrl`。

---

## 🏗️ 项目架构

```
emo_outlet/
├── emo_outlet_app/               # Flutter 前端
│   ├── lib/
│   │   ├── config/               # 设计系统（颜色/字体/间距）
│   │   ├── models/               # 数据模型
│   │   ├── providers/            # 状态管理（Provider）
│   │   ├── services/             # API 调用 + 认证
│   │   ├── screens/              # 15 个页面
│   │   ├── widgets/              # 通用组件
│   │   └── main.dart             # 入口
│   └── pubspec.yaml
│
├── emo_outlet_api/               # Python 后端
│   ├── app/
│   │   ├── api/                  # 5 个 API 路由模块
│   │   ├── models/               # 5 张数据库模型
│   │   ├── schemas/              # 请求/响应校验
│   │   ├── services/             # AI/情绪/海报服务
│   │   ├── core/                 # JWT 认证 + 依赖注入
│   │   └── utils/                # 敏感词过滤
│   └── requirements.txt
│
└── 需求文档.md                    # 产品需求文档
```

---

## 🔌 API 接口

| 模块 | 方法 | 路径 | 说明 |
|------|------|------|------|
| 认证 | POST | `/api/auth/register` | 注册 |
| 认证 | POST | `/api/auth/login` | 登录 |
| 认证 | POST | `/api/auth/visitor` | 游客登录 |
| 对象 | GET/POST | `/api/targets` | 泄愤对象列表/创建 |
| 对象 | POST | `/api/targets/{id}/generate-avatar` | AI 生成形象 |
| 会话 | POST | `/api/sessions` | 创建会话 |
| 会话 | POST | `/api/sessions/{id}/end` | 结束 + 情绪分析 |
| 消息 | POST | `/api/sessions/{id}/messages` | 发送消息 + AI 回复 |
| 海报 | POST | `/api/posters/generate` | 生成海报 |
| 报告 | GET | `/api/posters/report/overview` | 情绪报告 |

完整接口文档见：http://localhost:8000/docs

---

## 🗄️ 数据库设计

| 表名 | 说明 | 核心字段 |
|------|------|---------|
| `user` | 用户表 | phone/email/游客/每日次数限制 |
| `target` | 泄愤对象表 | 名称/类型/外貌/性格/关系/形象URL |
| `session` | 会话表 | 模式/风格/方言/时长/状态/情绪总结 |
| `message` | 消息表 | 内容/发送方/情绪标记/敏感词标记 |
| `poster` | 海报表 | 情绪类型/强度/关键词/建议/图片 |

---

## 🔐 安全特性

- JWT 令牌认证（7 天有效期）
- bcrypt 密码哈希
- 敏感词过滤（暴力 / 违法 / 高危关键词）
- 高风险自动中断（检测自伤 / 他伤意图时温和引导）
- 软删除机制（用户和对象均为标记删除）
- 对话内容不上云（端侧加密 / 即用即毁）

---

## 🧪 开发模式

无需配置任何 API Key 即可运行：

```
LLM_PROVIDER=mock    # 使用内置模拟回复
DATABASE_URL=        # 留空自动使用 SQLite
```

接入真实 AI 后在 `.env` 中配置：

```
LLM_PROVIDER=openai
OPENAI_API_KEY=sk-xxx
```

---

## 📄 许可证

MIT License © 2026 xiyao1203
