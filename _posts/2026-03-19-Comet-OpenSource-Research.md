---
layout: post
title: "🔭 Comet 是否有开源版本 — 全景调研"
tags: [ai-agents, research]
---
> 直接答案：**"Comet"不是一个产品，是 7 个完全不同的产品** —— 看你说的是哪个 Comet。
> 最有名的两个 Comet 都是**闭源**，但都有非常活跃的开源替代品。

## ⚡ 30 秒答案

| 你问的 Comet | 是否开源 | 状态 |
|---|---|---|
| **Perplexity Comet**（AI 浏览器，2024 发布） | ❌ 闭源 | 12+ 开源替代品，最强是 BrowserOS + nanobrowser |
| **Comet ML**（comet.com 实验管理平台） | 🟡 闭源 SaaS + 开源 SDK | Python SDK 开源，可 self-host 但要谈 enterprise 合同 |
| **Comet Opik**（comet-ml/opik，LLM 观测） | ✅ **Apache 2.0 完全开源** | 20,685 stars / Docker & K8s 自部署 |
| **BerriAI/litellm**（被 Comet 收购） | ✅ MIT | 53,972 stars（已合并到 Comet 公司） |
| **dotnet/Comet**（C# MVU UI Toolkit） | ✅ MIT | 1,673 stars，已 archived |
| **rpamis/comet**（agent skill harness） | ✅ MIT | 2,357 stars，TypeScript + Python |
| **CometChat**（聊天 SDK） | ✅ 闭源核心 + 开源 skills | cometchat 公司，不是 Comet 阵营 |

**最常见的误解**：把 Perplexity Comet 当成 Comet ML 或 Opik —— 它们**完全无关**，只是恰好都叫 Comet。

---

## 📂 7 个原子笔记

### 主线（Perplexity Comet）
- 01-Quick-Answer — 6 种 Comet 的快速识别表
- 02-Comet-Family-Overview — Comet 全家福全景图 + 7 个产品 + 命名冲突史
- 03-Perplexity-Comet — Perplexity Comet 是什么 + 泄露的 system prompt + 闭源原因
- 04-Perplexity-Comet-Alternatives — 12 个开源替代品对比（BrowserOS / nanobrowser / Steel / Stagehand / Skyvern / Browser-Use 等）

### 副线（Comet ML 公司产品）
- 05-Comet-ML-Company-Products — Comet ML 公司产品矩阵（Opik + litellm + 71 个 GitHub 仓库）
- 06-Opik-Deep-Dive — Opik 完整深拆（功能 + 部署 + 竞品对比）
- 07-Other-Comet-Projects — 其他 Comet 项目（dotnet/Comet / rpamis/comet / CometChat / getcomet.net 等）
- 08-Insights — 8 条关键洞察 + 用户切入点

---

## 🎯 按你的需求挑选

### 场景 1：我想自己跑一个 "Comet" 浏览器
→ 看 04-Perplexity-Comet-Alternatives
- **要 Chromium fork 完整浏览器**：BrowserOS（最强，YC S24）
- **要 Chrome 扩展**：nanobrowser（最热，13k stars）
- **要 AI agent 操控浏览器**：browser-use（10万 stars）+ Stagehand（23k stars）

### 场景 2：我想做 LLM 观测（替代 LangSmith/Langfuse）
→ 看 06-Opik-Deep-Dive
- **Comet Opik** 是 Apache 2.0 + 20k stars 的成熟产品
- Docker compose 5 分钟跑起来
- 直接对标 Langfuse / LangSmith / Arize Phoenix

### 场景 3：我想统一调用 100+ LLM API
→ 看 05-Comet-ML-Company-Products
- **litellm**（53k stars）已并入 Comet 公司
- 用 OpenAI 格式调用 Bedrock/Azure/Anthropic/OpenAI/Vertex/Cohere...

### 场景 4：我想做传统 ML 实验管理
→ 看 05-Comet-ML-Company-Products §B
- Comet ML 本身**闭源 SaaS**，但 Python SDK 完全开源
- self-host 需要谈 enterprise / 用 terraform-aws-comet-stsaas
- 替代品：MLflow（更成熟开源）/ Weights & Biases / Aim

### 场景 5：我就是想搞清楚 Comet 这个名字
→ 看 01-Quick-Answer
- 6 个 Comet 名字对照表，1 分钟识别

---

## 📊 关键数据（截至 2026-07-19）

```
GitHub stars （同类项目对比）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
105,463 ★ browser-use/browser-use         (MIT)  AI agent 操控浏览器
 53,972 ★ BerriAI/litellm                  (MIT)  LLM API gateway（已并入 Comet）
 47,157 ★ ChromeDevTools/chrome-devtools-mcp (Apache 2.0)  Chrome DevTools MCP
 23,549 ★ browserbase/stagehand            (MIT)  Browser agent SDK
 22,502 ★ Skyvern-AI/Skyvern               (AGPL) AI browser automation
 20,685 ★ comet-ml/opik                    (Apache 2.0)  LLM observability ★
 13,478 ★ nanobrowser/nanobrowser          (Apache 2.0)  Chrome 扩展 AI agent
 12,328 ★ browseros-ai/BrowserOS           (AGPL)  AI browser ★
  7,345 ★ steel-dev/steel                  (Apache 2.0)  Browser API for AI agents
  2,357 ★ rpamis/comet                     (MIT)  Agent skill harness
  1,987 ★ nottelabs/notte                  (Other) Web agent framework
  1,673 ★ dotnet/Comet                     (MIT)  C# MVU UI Toolkit [archived]
   491 ★ BrowserOperator/browser-operator-core (BSD-3)  AI browser
```

★ = 用户最关心的两个 Comet 开源生态

---

## 🇨🇳 国内有同类吗？

| 类型 | 产品 | 公司 | 形态 | AI 深度 |
|---|---|---|---|---|
| 大厂 | **夸克 AI 浏览器** | 阿里 | Chromium 浏览器 | ⭐⭐⭐⭐ AI 侧边栏+搜索+总结 |
| 大厂 | **360 AI 浏览器** | 360 | Chromium 浏览器 | ⭐⭐⭐ AI 工具栏+AI PPT |
| 大厂 | **Edge Copilot (CN)** | 微软（中国特供）| Chromium | ⭐⭐⭐⭐⭐ Copilot 全套 |
| 创业 | **Fellou** | 前字节极客 | Agentic 浏览器 | ⭐⭐⭐⭐⭐ **最对位 Comet** |
| 创业 | **Tabbit** | 国内团队 | AI 浏览器 | ⭐⭐⭐⭐ |
| 助手 | **豆包（手机/网页）** | 字节 | AI 助手（不是浏览器）| ❌ 不是浏览器形态 |
| **开源** | **AIPex** | 北京 AIPexStudio | Chrome 扩展 | ✅ MIT，1.2k★ |
| **开源** | **VibeSurf** | 国内团队 | 浏览器助手 | ⚠️ 5 个月没动 |
| **开源** | **agenticSeek** | Fosowl（欧洲+中国开发者）| 本地 agent | ✅ 26k★ (GPL-3.0) |
| **开源** | **meowus** | MeowAI-HK | 社媒 AI | ⚠️ 2★ 早期 |

详细分析见 [09-China-AI-Browsers](./Comet-OpenSource-Research/09-China-AI-Browsers.md)

---

## 🔗 关联

- iOS-General-AI-Agent — iOS 上 Comet / Manus / Genspark 同一赛道对比
- Web-Scraping-Agent — 爬虫 + 信息获取 agent（Firecrawl / Browser-Use / Skyvern 头部三强）
- Obsidian-Plugin-Architecture — 浏览器插件架构
- 07-Cassette-Futurism — AI 浏览器视觉风格（Cassette Futurism 2026 主流）

## 📚 引用源

- HN Algolia: `comet`, `comet open source`, `perplexity comet`, `comet ml open source`, `ai browser open source`, `notte ai browser`
- GitHub Search: `comet`, `comet browser`, `comet llm`, `comet perplexity`
- x1xhlol/system-prompts-and-models-of-ai-tools/Comet Assistant — Comet system prompt 泄露
- comet.com 官网 + comet-ml org 71 个仓库
- perplexityai org 17 个仓库（无 Comet）
- BrowserOS 官网 + YC S24 page
