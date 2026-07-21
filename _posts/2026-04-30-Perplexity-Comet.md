---
layout: post
title: "🧠 Perplexity Comet — 完全闭源的 AI 浏览器"
tags: [ai-agents, research]
---
> ⏰ 返回 MOC

> Perplexity Comet 是 Perplexity AI 在 2024-07 发布的旗舰 AI 浏览器，主打"AI 原生搜索 + 浏览器"。**完全闭源**，但系统提示词在 2026-02 被完整泄露。

## 基本信息

| 项 | 值 |
|---|---|
| 公司 | Perplexity AI |
| 首次发布 | 2024-07（macOS 优先，Comet Plus 订阅 $200/月） |
| 当前状态 | Windows 11 / macOS / 移动端 (2025-2026 陆续上线) |
| 商业模式 | Perplexity Max 订阅 / Comet Plus 高级版 |
| 开源状态 | ❌ **完全闭源**，无任何官方代码仓库 |
| GitHub 仓库 | perplexityai org 17 个仓库中**无任何 Comet 相关** |
| 系统提示词 | ⚠️ **已泄露** (2026-02) |

## 核心能力（从泄露的 system prompt 推断）

### 工具列表（来自 tools.json）
```json
[
  "computer",        // 通用 computer use
  "navigate",        // 导航 URL
  "read_page",       // 读取页面内容
  "find",            // 在页面查找元素
  "form_input",      // 填写表单
  "get_page_text",   // 提取纯文本
  "search_web",      // 调用 Perplexity 搜索 API
  "tabs_create",     // 新建标签页
  "todo_write"       // 待办列表
]
```

### 关键设计原则（来自 system prompt 泄露）
1. **永远基于真实信息回答** — 不能编造
2. **优先使用 Perplexity 搜索** — 不用 Google/Bing
3. **辅助而非替代用户决策** — 高风险操作需确认
4. **保持上下文连贯** — 长会话不丢上下文
5. **支持 tab 间通信** — 多 tab 联动

## 商业策略

```
2024-07 ┃ Comet 1.0 发布，仅 macOS
2024-12 ┃ 推 Comet Plus ($200/月) 含 GPT-4/Claude/Gemini
2025-Q2 ┃ Windows 11 版本（邀请制）
2025-Q4 ┃ 全平台开放 + 移动端 beta
2026-Q1 ┃ Samsung / Motorola 预装谈判
2026-Q2 ┃ 与 Verizon 流量捆绑
```

**为什么选 Comet 这个名字？**
- "Comet" = 彗星 = "快速穿越宇宙" = 隐喻搜索速度
- 与浏览器"快速 tab 切换"心智模型契合
- 比 "Perplexity Browser" 更简洁

## 为什么不开源？

| 可能原因 | 推测概率 |
|---|---|
| Perplexity 商业核心，开了就没人付费 | 70% |
| 用了第三方 LLM API（Anthropic/OpenAI），开了有授权风险 | 50% |
| 与 Perplexity 搜索 backend 深度耦合，独立不可运行 | 80% |
| 团队规模小（< 50 人），没精力维护 OSS | 60% |
| 闭源 + 订阅是 Perplexity 核心商业模式 | 90% |

**结论**：Comet 极不可能开源。**关注开源替代品**是更现实的策略。

## 泄露事件分析

### 时间线
- 2026-02-02：x1xhlol/system-prompts-and-models-of-ai-tools 仓库出现 "Comet Assistant" 目录
- 包含 2 个文件：`System Prompt.txt` + `tools.json`
- 是 Perplexity 浏览器内置 AI 助手（不是 Perplexity 搜索）的提示词
- 内容包含完整工具定义 + 角色定位 + 行为准则

### 影响
- 让独立开发者可以 **复刻 Comet 的部分能力**
- 多个开源替代品借鉴了工具集设计
- 但**仅提示词 ≠ 完整产品**：
  - 缺少 browser shell / tab manager / extension system
  - 缺少 Perplexity 搜索 backend
  - 缺少 sync / cloud features

### 类似泄露事件
- x1xhlol/system-prompts-and-models-of-ai-tools 涵盖 30+ AI 产品
- 包括 Cursor / Devin / Claude Code / Augment / Manus / NotionAI 等
- GitHub 142k stars (2026-07)

---

## Perplexity AI 公司全景

| 产品 | 类型 | 开源? |
|---|---|---|
| Perplexity 搜索 | AI 搜索引擎 | ❌ 闭源 |
| Comet 浏览器 | AI 浏览器 | ❌ 闭源 |
| Sonar API | LLM API | ❌ 闭源 |
| pplx-api (官方 SDK) | Python/TS SDK | ✅ 部分开源 |
| modelcontextprotocol | MCP server | ✅ Apache 2.0 (2.4k★) |
| pplx-kernels | GPU Kernels | ✅ (590★) |

**结论**：Perplexity 是**完全闭源公司**，只有少量基础设施开源（MCP server / kernels）。

---

## 📚 引用

- x1xhlol/system-prompts-and-models-of-ai-tools/Comet Assistant/System Prompt.txt + tools.json
- perplexityai org GitHub (17 repos, 无 Comet)
- HN: `perplexity comet`, `comet open source`
- Perplexity 官网产品页 + Sonar API 文档
- comet-plus subscription details ($200/月)

## 🔗 相关

- 开源替代品
- Comet 全家福
- iOS-General-AI-Agent — iOS 全能 Agent（含 Comet iOS 现状）
- Web-Scraping-Agent — 浏览器操控类 agent（与 Comet 能力重叠）
