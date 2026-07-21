---
layout: post
title: "🔄 Perplexity Comet 开源替代品：成熟度评估"
tags: [ai-agents, research]
---
> ⏰ 返回 MOC

> **核心结论**：**BrowserOS 是唯一"形态对位 Perplexity Comet"且仍健康活跃的开源 AI 浏览器**。browser-use / Stagehand / Skyvern 是 SDK 级替代品（不是浏览器，是给 AI agent 用的浏览器工具）。**nanobrowser 已经停滞 8 个月**，issue 关闭率 0%，**不要选**。

---

## 🎯 一句话回答

| 如果你是… | 选这个 |
|---|---|
| **终端用户，要桌面 AI 浏览器** | **BrowserOS**（12.3k★, AGPL-3.0, YC S24）|
| **开发者，做 coding agent / web scraping agent** | **browser-use**（105k★, MIT, 1.1 亿下载/月）|
| **前端 / TS 产品方** | **Stagehand**（23.5k★, MIT, Browserbase 团队）|
| **企业级自动化** | **Skyvern**（22.5k★, AGPL-3.0, 500+ 客户）|

---

## 📊 Perplexity Comet 完整功能清单（基准线）

从 [perplexity.ai/comet](https://www.perplexity.ai/comet) 抓取的官方定位（2026-07-19）：

```
Perplexity Comet 核心能力
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
1. AI that understands（搜索 + 信息综合）
2. AI that builds（"暂停你正在做的，我帮你做完"）
3. AI that emails（自动邮件回复）
4. AI that creates（学习计划、内容创作）
5. AI that shops（购物自动化）
6. Personal assistant（邮件 / 日历 / 财务 / 旅行）
7. 跨平台：Mac / Windows / iOS / Android
```

---

## 🏆 成熟度评估 5 维矩阵

| 项目 | Stars | License | 形态 | 活跃度 | PyPI/npm 月下载 | 真实用户基数 | 综合分 |
|---|---|---|---|---|---|---|---|
| **BrowserOS** | 12.3k | AGPL-3.0 | Chromium fork | ✅ 7×24 commit | n/a（dmg） | 中 | ⭐⭐⭐⭐⭐ |
| **browser-use** | 105k | MIT | Python SDK | ✅ 7×24 | **1.1 亿/月** | 极大 | ⭐⭐⭐⭐⭐ |
| **Stagehand** | 23.5k | MIT | TS SDK | ✅ 7×24 | 117 万/月 | 大 | ⭐⭐⭐⭐ |
| **Skyvern** | 22.5k | AGPL-3.0 | SaaS+OSS | ✅ 7×24 | 1.5 万/月 | 中（企业为主） | ⭐⭐⭐⭐ |
| nanobrowser | 13.5k | Apache 2.0 | Chrome ext | ❌ **停滞 8 月** | 0 | 已流失 | ⭐⭐ |
| Steel.dev | 7.3k | Apache 2.0 | Browser API | ✅ | n/a | 小 | ⭐⭐⭐ |
| Notte | 2.0k | Other | Framework | ✅ | n/a | 小 | ⭐⭐⭐ |
| chrome-devtools-mcp | 47.2k | Apache 2.0 | MCP | ✅ 7×24 | n/a（MCP） | 大 | ⭐⭐⭐⭐⭐ |
| BrowserOperator | 491 | BSD-3 | Browser | ✅ | n/a | 小 | ⭐⭐ |
| theredsix/agent-browser-protocol | 477 | BSD-3 | Lib | ⚠️ | n/a | 极小 | ⭐⭐ |
| Magnitude | 33 | Apache 2.0 | CLI | ❓ | n/a | 极小 | ⭐ |
| Preet3627/Comet-AI | 16 | MIT | Electron | ❓ | n/a | 极小 | ⭐ |

**判断标准**：
- ✅ 活跃 = 最近 push < 7 天
- ⚠️ 缓慢 = 最近 push 7-30 天
- ❌ 停滞 = 最近 push > 30 天

---

## ⚠️ 关键警告：nanobrowser 已死

**这是 2026-07-19 调研最重要发现**：

```
nanobrowser 真实状态
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
最近 commit:       2025-11-24（8 个月前）
最近 release:      v0.1.13, 2025-11-22
最近 30 天关闭 issue: 0 个
当前 open issue:    47 个
Issue 关闭率:        0%（行业标准应 > 30%）
Star:                13,478（停滞前增长）
License:             Apache 2.0
仓库状态:            ⚠️ 仍在，用户持续开 issue，但无人维护
```

**结论**：**不要选 nanobrowser 作为生产依赖**。它是 2025 上半年最热的项目，但 2025-11 后团队可能解散 / 转去做 BrowserOS（巧合的是 BrowserOS 的 "BrowserClaw" 模块和 nanobrowser 功能高度重合，怀疑是 fork）。

**替代建议**：如果你想要 Chrome 扩展形态 → 等 BrowserOS 后续会不会出扩展版，或者用 chrome-devtools-mcp（47k★, Google 官方）。

---

## 🥇 BrowserOS 深度剖析（最佳对位替代）

BrowserOS 是 **唯一形态完全对位 Perplexity Comet** 的开源项目（其他都是 SDK/扩展/API 形态）。

### 产品线
```
BrowserOS（Felafax 公司，YC S24）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
BrowserOS       给人类用的 AI 浏览器（Chromium fork）
BrowserClaw     给 AI agent 用的浏览器（被 Claude Code/Codex/Cursor 控制）
```

### BrowserOS vs Perplexity Comet 功能矩阵

| 功能 | BrowserOS | Perplexity Comet |
|---|---|---|
| 浏览器 + AI agent | ✅ | ✅ |
| 自带 LLM API key（BYO LLM） | ✅ 13 家 providers | ❌ 绑 Perplexity |
| Gmail / Calendar / Notion 集成 | ✅ 40+ MCP apps | ✅ |
| 定时任务（Scheduled Tasks） | ✅ | ✅ |
| 跨 session 记忆 | ✅ Agent Memory | ❓ |
| Skills（reusable instructions） | ✅ 12 内置 | ❌ |
| SOUL.md 自定义人格 | ✅ | ❌ |
| Filesystem 沙盒 | ✅ | ❌ |
| 跨平台 | Mac / Win / Linux | Mac / Win / iOS / Android |
| **iOS / Android** | ❌ **缺失** | ✅ |
| 开源 | ✅ AGPL-3.0 | ❌ |
| 本地优先 + 隐私 | ✅ | ❌（强云） |

### BrowserOS 三大差异化亮点

1. **Skills = Markdown 文件**：你可以写一个 `deep-research.md` Skill，让 agent 重复执行
2. **SOUL.md = 定义 agent 人格**（一个 Markdown 文件，类似 Minis 的 SOUL.md）
3. **Scheduled Tasks**：任何 agent 任务可定时（Comet 也有，但 BrowserOS 开源）

### BrowserOS 当前短板
- **iOS / Android 完全缺失**（只有 macOS / Windows / Linux）
- **AGPL-3.0 商业限制**（不能直接 SaaS 化，要买商业 license 或开源你的代码）

---

## 🥈 browser-use 深度剖析（agent 端之王）

**这不是浏览器，是给 AI agent 用的浏览器操控库**。但和 Perplexity Comet 的"agent 在浏览器里"是 **同一类能力** 的不同抽象层。

### 真实使用数据（PyPI 下载量，2026-07-19）

```
browser-use PyPI 下载量（过去 30 天）
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
每日下载:      1,060,364 次
每周下载:      9,374,735 次
每月下载:      109,944,001 次（1.1 亿）
```

**对比**：
- browser-use：1.1 亿/月
- Stagehand：117 万/月 → browser-use 是它的 **94 倍**
- Skyvern：1.5 万/月 → browser-use 是它的 **7,300 倍**

**这是 AI agent 领域下载量最大的 Python 包之一**，仅次于 LangChain / LlamaIndex 级别。

### 适用场景
- coding agent（Claude Code / Codex / Cursor）需要浏览器能力 → 装这个
- web scraping agent → 装这个
- test automation agent → 装这个
- research agent → 装这个

**不适用**：终端用户（这是 SDK，没有 UI）

### browser-use 创始人
- **Magnus Müller**（创始人）
- 同时做了 **chrome-devtools-mcp**（Google Chrome DevTools 团队的 MCP）

---

## 🥉 Stagehand / Skyvern 深度剖析

### Stagehand（Browserbase 公司）
- 23.5k★, MIT, TypeScript SDK
- 适合 JS/TS 产品
- Browserbase 是商业 Browser-as-a-Service 公司，Stagehand 是他们的开源产品
- 缺点：270 open issues, backlog 较大

### Skyvern
- 22.5k★, AGPL-3.0, 590MB 完整 Python 项目
- 适合企业级（保险、汽车、金融、SaaS 后台）
- 500+ 企业客户
- 缺点：AGPL 商业限制，PyPI 下载量仅 1.5 万/月（远低于 browser-use）
- **"Open Source" 不等于 "Open Core"** — Skyvern 的核心模型不开源

---

## 📋 决策树（按场景选）

```
你的角色是什么？
│
├─ 终端用户（要桌面 AI 浏览器，替代 Comet）
│   ├─ 跨平台：Mac + Windows + Linux？
│   │   └─ ✅ BrowserOS
│   ├─ 需要 iOS / Android？
│   │   └─ ❌ 开源没有，等未来 BrowserOS 出移动版
│   └─ 想要 Chrome 扩展？
│       └─ ❌ BrowserOS 是完整浏览器，Chrome 扩展形态当前空白（nanobrowser 已死）
│
├─ 开发者（做 coding agent / data agent）
│   ├─ Python 生态？
│   │   └─ ✅ browser-use（105k★, 1.1 亿/月下载）
│   └─ TypeScript / Node 生态？
│       └─ ✅ Stagehand（23.5k★, 117 万/月下载）
│
├─ 产品经理（给产品加 AI 浏览器能力）
│   ├─ 个人项目 / 开源 OK？
│   │   └─ ✅ browser-use 或 Stagehand
│   ├─ 企业级（500+ 客户、有 SLA 要求）？
│   │   └─ ✅ Skyvern（虽然 AGPL，但企业 license 可买）
│   └─ 云端 headless 浏览器给 AI agent 用？
│       └─ ✅ Steel.dev（API 形式）
│
└─ 极客 / 自己动手
    ├─ 想要 Markdown 控制 agent 行为？
    │   └─ ✅ BrowserOS（Skills + SOUL.md）
    ├─ 想要 deterministic automation？
    │   └─ ⚠️ theredsix/agent-browser-protocol（477★, BSD-3）
    └─ 想用 Google 官方工具？
        └─ ✅ chrome-devtools-mcp（47k★）
```

---

## 🆚 Perplexity Comet vs BrowserOS 真实差距

### Comet 强项（你用 Comet 不可替代的能力）
- ✅ iOS / Android 移动端（BrowserOS 没有）
- ✅ 自带后端 LLM（不用配 API key）
- ✅ Perplexity 的搜索 / 信息综合能力（行业最强之一）
- ✅ 营销 / 品牌 / 用户基数
- ✅ 跨设备无缝（手机 + 电脑）

### BrowserOS 强项（开源独有的能力）
- ✅ 完全控制自己的浏览器（fork Chromium）
- ✅ 自带 LLM API key（OpenAI / Anthropic / Gemini / 本地 Ollama）
- ✅ Skills / SOUL.md / Scheduled Tasks（Comet 没有）
- ✅ 隐私优先 + 本地优先
- ✅ 不会被厂商突然改定价（Comet Pro 涨 3 次了）

### 真实差距评分

| 维度 | Comet | BrowserOS | 差距 |
|---|---|---|---|
| 桌面 AI 浏览器体验 | 9/10 | 7/10 | Comet 略胜 |
| 移动端 | 9/10 | 0/10 | **Comet 完胜** |
| 信息综合（搜索） | 10/10 | 6/10 | Comet 完胜 |
| 自动化（agent 能力） | 7/10 | 8/10 | **BrowserOS 略胜** |
| 隐私 / 数据控制 | 3/10 | 10/10 | **BrowserOS 完胜** |
| 自定义 / 可编程 | 2/10 | 9/10 | **BrowserOS 完胜** |
| 用户基数 / 社区 | 9/10 | 4/10 | Comet 完胜 |
| 开源 | 0/10 | 10/10 | **BrowserOS 完胜** |

**结论**：**如果你的核心需求是"桌面 AI 浏览器 + 隐私 + 可编程"，BrowserOS 是更好选择**。**如果你需要 iOS/Android 移动端 + 信息综合搜索 + 不想配 API key，Comet 仍是首选**（开源生态暂时做不到移动端）。

---

## 🛡️ License 商业指南

| License | 项目 | 商业可用? | 备注 |
|---|---|---|---|
| MIT | browser-use / Stagehand | ✅ 完全自由 | 最安全 |
| Apache 2.0 | nanobrowser / Steel.dev / chrome-devtools-mcp / Magnitude | ✅ 完全自由 | 加专利保护 |
| AGPL-3.0 | BrowserOS / Skyvern | ⚠️ 不能 SaaS 化 | 要么开源你的代码，要么买商业 license |
| Other | Notte / litellm | ❓ 看具体 | 仔细读 |
| BSD-3 | BrowserOperator / theredsix/agent-browser-protocol | ✅ 商业友好 | 类似 Apache |

**SaaS 创始人避坑**：如果要做 SaaS 产品，**避免 AGPL**（BrowserOS / Skyvern），它们会强制你开源整个 SaaS。

---

## 🔮 未来 6-12 个月预测

1. **BrowserOS 会出 iOS / Android 版本**（如果 YC S24 拿够钱）
2. **nanobrowser 会被社区 fork**（OpenAI Operator 续作）
3. **chrome-devtools-mcp 会成为浏览器 automation 事实标准**（Google 官方 + browser-use 创始人）
4. **Skyvern 会从 AGPL 转 BSL**（向 MongoDB / Sentry 学习，保护企业收入）
5. **OpenClaw 会成为"personal AI assistant"赛道新标杆**（🦞 已拿到 OpenAI / GitHub / NVIDIA 赞助）

---

## 📚 引用源

- BrowserOS: github.com/browseros-ai/BrowserOS, browseros.com, YC S24
- browser-use: github.com/browser-use/browser-use, browser-use.com
- Stagehand: github.com/browserbase/stagehand, stagehand.dev
- Skyvern: github.com/Skyvern-AI/Skyvern, skyvern.com
- nanobrowser: github.com/nanobrowser/nanobrowser (停滞)
- Perplexity Comet: perplexity.ai/comet
- HN: `ai browser open source`, `perplexity comet open source`
- PyPI Stats: pypistats.org (2026-07-19 实时查询)

## 🔗 相关

- Perplexity Comet（闭源）
- Comet ML 公司产品矩阵
- Web-Scraping-Agent — 浏览器操控类 agent
- iOS-General-AI-Agent — 移动 AI agent 对比
- 07-Cassette-Futurism — AI 浏览器视觉风格
