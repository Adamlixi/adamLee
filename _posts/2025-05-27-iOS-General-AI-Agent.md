---
layout: post
title: "📱 iOS 上的\"全能 AI Agent\"调研"
tags: [ai-agents, research]
---
> **问题**：有没有类似 Minis 这种"在 iOS 上跑、能执行代码、能用浏览器、能读 iOS 文件、能调用系统 API"的全能 Agent？
>
> **TL;DR**：几乎没有。**App Store 上 100k+ 评分的"AI app"全都不是 Agent——只是 chatbot**。真正的 iOS 全能 Agent 桶几乎空白，**最接近 Minis 的是 0 评分的开源项目 Palvia**。

## 0. 评判"全能 Agent"的 5 项硬指标

为了让比较有意义，先把"全能"拆成可验证能力。任何一个缺失 → 降级到上一档：

| # | 能力 | 为什么必要 |
|---|---|---|
| 1 | **跑代码**（沙箱 / 容器 / 解释器） | 没代码执行 = 只是 chatbot（ChatGPT/Claude/Gemini/Grok） |
| 2 | **浏览器自动化**（不只是 URL 栏） | 没浏览器 = 无法替你点网页、填表、抓数据 |
| 3 | **文件系统**（持久 / 挂载 / 编辑） | 没法读写文件 = 没法做工程类任务 |
| 4 | **真终端 / Shell**（不只 SSH 到远程） | 没有真本地 shell = 不能起服务、跑 cron、调 ffmpeg/git |
| 5 | **iOS 原生 API**（Shortcuts / Calendar / Photos / Bluetooth / Health） | 不能调 iOS = 不是"在 iOS 上的 agent"，是"在云上的 agent" |

**额外分维度**：**执行位置**（on-device iOS vs cloud / remote server）—— 这决定了"是 iOS 上的 Agent"还是"iOS 遥控的 Agent"。

## 1. 5 大事实

### 事实 1：100k+ 评分的 iOS AI app 全部不是 Agent

按 5 项能力排查，所有大厂 iOS app **全 0**——它们是 chatbot，不是 agent：

| App             | 评分    | 跑代码 | 浏览器 | 文件  | 终端  | 原生  | 描述原文                                                                                                                            |
| --------------- | ----- | --- | --- | --- | --- | --- | ------------------------------------------------------------------------------------------------------------------------------- |
| **ChatGPT iOS** | 8.59M | ❌   | ❌   | ❌   | ❌   | ❌   | "Introducing ChatGPT for iOS: OpenAI's latest advancements at your fingertips" — 只列出 image gen / voice / photo upload / 建议 / 回答 |
| **Gemini**      | 1.98M | ❌   | ❌   | ❌   | ❌   | ❌   | 描述自承："**does not currently support iOS device actions like setting alarms or sending SMS directly**"                            |
| **Grok AI**     | 1.30M | ❌   | ❌   | ❌   | ❌   | ❌   | 纯聊天 + 工具调用（X 平台工具）                                                                                                              |
| **Claude iOS**  | 199K  | ❌   | ❌   | ❌   | ❌   | ❌   | "Claude by Anthropic" 描述强调 Drive/Gmail/Calendar 连接——执行都在 Anthropic 云                                                            |
| **Meta AI**     | 160K  | ❌   | ❌   | ❌   | ❌   | ❌   | 纯聊天 + 跨平台消息                                                                                                                     |
| **Perplexity**  | 486K  | ❌   | ❌   | ❌   | ❌   | ❌   | AI 搜索/聊天，不是 agent                                                                                                               |

**原因**：Apple App Store 4.7 / 4.2 / 2.3.7 三条审核线 + 沙盒 + 禁 JIT + 不能 fork 守护进程 → 大厂主动放弃在 iOS 客户端做"全能"。

### 事实 2：真正"全能"的 iOS app 分成 4 类

按"**执行位置**"分：

```
                    真正在 iOS 进程内执行
                            ▲
                            │
              Palvia ──────►│
              Scripting ───►│
                            │
  ━━━━━━━━━━━━━━━━━━━━━━━━━┼━━━━━━━━━━━━━━━━━━━━━━━━━━━
                            │                          ╱
                            │  ⬆ Manus / Genspark    ╱
                            │    / Magica / Comet   ╱  云上 / 远程
                            │                     ╱
                            │  ⬆ Cursor iOS / QuickTUI
                            │    / OpenClaw / PocketClaw
                            │    / IDE for Claude Code
                            ▼
                  只是 chatbot（事实 1）
```

| 类别 | 代表 | 模式 | 评分 | 5 项能力 |
|---|---|---|---|---|
| **云上"虚拟电脑"** | **Manus** / **Genspark Super Agent** / **Magica** | iOS 是遥控器，agent 在云端 sandbox 跑 | 35K / 3.7K / 691 | 1✅ 2☁️ 3☁️ 4☁️ 5☁️ |
| **AI 浏览器** | **Comet (Perplexity)** | 浏览器里住个 agent 帮你点网页 | 7.7K | 1☁️ 2✅ 3❌ 4❌ 5❌ |
| **远程控制电脑上的 Claude Code / Codex** | **Cursor iOS** / **QuickTUI** / **PocketClaw** / **OpenClaw** / **IDE for Claude Code** | iOS 是瘦客户端，agent 跑在 Mac / Linux / 云 VM | 153 / 0 / 18 / 22 / 23 | 1☁️ 2☁️ 3☁️ 4☁️ 5☁️ |
| **iOS 本机全能 Agent** | **Palvia** / **Scripting** | 真正在 iOS 进程里跑代码 + 调系统 API | **0** / 80 | 1✅ 2部分 3✅ 4❌ 5部分 |

### 事实 3：最像 Minis 的是 Palvia（开源 / MIT / 0 评分）

[github.com/samhjn/Palvia](https://github.com/samhjn/Palvia) — v1.0.1 发布 2026-06-22，**App Store 评分 0**。

**架构**（从 README 提取）：
- **多 Agent 架构**：每个 Agent 有自己的 `SOUL.md`（人设）/ `MEMORY.md`（持久记忆）/ `USER.md`（用户画像），可派 sub-agent 协作
- **本机代码执行**：内置 `WKWebView` 沙箱跑 JavaScript，两种模式（repl 表达式 / script 完整脚本）
- **内建浏览器自动化**：9 个 `browser_*` 工具（navigate/click/input/extract/execute_js/get_page_info/select/wait/scroll），互斥锁保证一个 agent 控制浏览器
- **会话 RAG**：Apple NaturalLanguage 框架做本机向量化（cosine > 0.3），hybrid 搜索（向量 + 关键词回退）
- **持久化**：SwiftData（不是文件 = 没法挂载到 macOS Finder）
- **多 LLM 提供方**：兼容 OpenAI API endpoint（OpenAI / DeepSeek / OpenRouter / Ollama 本地）
- **定时任务**：`BGTaskScheduler` + Deep Link 触发

**跟你（Minis）的同构性**：

| Minis | Palvia |
|---|---|
| 1 LLM 推理 + 多 tools | 1 LLM 推理 + 多 tools |
| `iSH` 跑真 Linux（apk add / curl / git / Python） | `WKWebView` 跑 JS |
| `browser_use` 工具 | 9 个 `browser_*` 工具 |
| `file_read/write/edit` + iOS Files 挂载 | SwiftData（封闭数据库） |
| `memory_write` 到 daily log | `MEMORY.md` per agent |
| `skills/` 可加载 | skill 系统 |
| `minis://shared/` 跨 session 共享 | ❌ |
| `minis://mounts/<name>/` 挂 iOS 外部 | ❌ |
| `shell_execute` 起后台服务 | ❌（沙箱限） |

**本质区别**：Palvia 用 WKWebView 跑 JS（**沙箱语言受限**），没有真 Linux 沙箱（**没 curl / git / ffmpeg / Python / apk**），文件系统封闭（**没法挂载 iOS Files 文件夹**），没有共享存储。它是你在 iOS 上的"**JS-only 表亲**"。

### 事实 4：Scripting 是"iOS 本机 + 全栈 API"但不是 Agent

[scripting.fun](https://www.scripting.fun) — 4.875 / 80 评分，作者 有智方。

**能跑**：TypeScript / JavaScript / Node.js（带 npm）/ Python
**能调 iOS API**：Calendar / Notification / Bluetooth / Health / Photos / Live Activities / Control Center / Dynamic Island / Custom Keyboards / Share Extensions
**能生成**：Apple Shortcuts（导入到系统）
**能连**：SSH / Git / WebDAV / Dropbox / FTP / SFTP
**VSCode 插件**：CLI 工具可在桌面预览 / 跑手机脚本

**缺什么让它不是 Agent**：
- ❌ 没内建浏览器自动化（只有 headless fetch）
- ❌ 没多 Agent / sub-agent
- ❌ 没持久化到开放目录（沙盒 + Files 集成有限）
- ❌ 没"自然语言任务 → 自主拆解 → 多步执行"循环（Scripting 是 AI-assisted scripting，需要用户写脚本框架）

### 事实 5："iOS 端通用 AI agent"是结构性空白

| 桶 | 玩家 | 评分总和 |
|---|---|---|
| 云上"虚拟电脑" | Manus (35K) + Genspark (3.7K) + Magica (691) + Comet (7.7K) | 47K |
| 远程电脑客户端 | Cursor (153) + QuickTUI (0) + OpenClaw (22) + PocketClaw (18) + Hermes (9) + Hermex (42) + IDE for Claude Code (23) + Mira (1) + 30+ 其他 | <300 |
| **iOS 本机 + 全能** | **Palvia (0) + Scripting (80) + Open Minis (~116)** | **~196** |
| 纯 chatbot | ChatGPT + Gemini + Claude + Grok + Meta | 10M+ |

> **⚠️ 更新 (2026-07-14 16:55)**：初版调研**漏掉了 Open Minis**（因为搜词是"Manus/Genspark/Palvia/Hermes"等，没搜"Minis / Open Minis"——见 §5.1 自我反思）。Open Minis 才是 "iOS 本机 + 全能" 桶的**先发者**（2026-03-14 上架），比 Palvia 早 100 天。

**结构性原因**（详见后文 §4）：
1. App Store 4.7 "minimum functionality" 拒绝 webview wrapper
2. 4.2 "minimum functionality" 拒绝无意义重复
3. 2.3.7 拒绝从 App Store 内下载代码到 iOS
4. 沙盒限制 Background tasks（最长 30s + 10 ops/min）
5. 禁 JIT（只有 WebKit 例外）
6. 禁 fork 守护进程

## 2. 全产品对比表

| App | 跑代码 | 浏览器 | 文件 | 终端 | 原生 | 评分 | 分类 |
|---|---|---|---|---|---|---|---|
| **Minis（你）** | ✅ iSH Linux | ✅ browser_use | ✅ mounted | ✅ iSH | ✅ | **~116 (CN 73)** | iOS 本机 + 全能 |
| **Open Minis (com.openminis.app)** | ✅ iSH | ✅ 内建 | ✅ mounts | ✅ iSH | ✅ HealthKit/HomeKit/Vision/Speech/Weather/Photos/Calendar/Reminders/Location | **116** | iOS 本机 + 全能 |
| **Palvia** | ✅ JS | ✅ 9 tools | ✅ SwiftData | ❌ | ⚠️ Apple NL | 0 | iOS 本机 + 全能（最接近） |
| **Scripting** | ✅ JS/TS/Python | ❌ fetch only | ✅ Files | ❌ | ✅ 完整 iOS API | 80 | iOS 本机 + 脚本（缺 agent 循环） |
| **Web IDE** | ❌ 编辑器 | ❌ | ✅ WebDAV/SSH/FTP | ✅ SSH | ❌ | 13 | 远程 IDE + AI |
| **OpenCat** | ❌ | ❌ | ❌ | ❌ | ✅ Apple Intelligence | 835 | 跨平台 chat + MCP |
| **Manus** | ☁️ cloud | ☁️ | ☁️ | ☁️ | ☁️ | 35K | 云上"虚拟电脑" |
| **Genspark** | ☁️ | ☁️ | ☁️ | ☁️ | ☁️ | 3.7K | 多模型 + 工作流 |
| **Magica** | ☁️ | ☁️ | ☁️ | ☁️ | ☁️ | 691 | 多模型 Super Agent |
| **Comet** | ☁️ | ✅ | ❌ | ❌ | ❌ | 7.7K | AI 浏览器 |
| **Cursor iOS** | ☁️ sandbox VM | ❌ | ☁️ | ☁️ | ❌ | 153 | Cursor 移动版 |
| **QuickTUI** | 远程 Mac | 远程 | 远程 | ✅ SSH | ❌ | 0 | 远程 Claude Code |
| **OpenClaw** | 远程 Gateway | 远程 | 远程 | 远程 | ✅ camera/photos/calendar | 22 | OpenClaw 节点 |
| **PocketClaw** | 远程 | 远程 | 远程 | 远程 | ❌ | 18 | 远程 agent |
| **Hermes / Hermex** | 远程 | 远程 | 远程 | 远程 | ❌ | 9/42 | 远程 agent |
| **IDE for Claude Code** | 远程 Claude Code | ❌ | 远程 | 远程 | ❌ | 23 | 远程 Claude Code |
| **Mira: OpenClaw** | 远程 | 远程 | 远程 | 远程 | ❌ | 1 | 远程 agent |
| ChatGPT iOS | ❌ | ❌ | ❌ | ❌ | ❌ | 8.59M | chatbot |
| Claude iOS | ❌ | ❌ | ❌ | ❌ | ❌ | 199K | chatbot |
| Gemini iOS | ❌ | ❌ | ❌ | ❌ | ❌ | 1.98M | chatbot（自承不支持系统 actions） |
| Grok AI | ❌ | ❌ | ❌ | ❌ | ❌ | 1.30M | chatbot |
| Meta AI | ❌ | ❌ | ❌ | ❌ | ❌ | 160K | chatbot |

## 3. 关键产品深读

### 3.1 Manus（35K 评分 — iOS Agent 类别第一）

- **公司**：BUTTERFLY EFFECT PTE. LTD.（新加坡，创始团队中国）
- **Slogan**："The AI agent that doesn't just think, it delivers"
- **核心机制**："virtual computer" + 多 sub-agent 异步 + 云端 sandbox
- **能力**（描述自述）：写代码 / 跑数据 / 做幻灯片 / 网页研究 / 应用生成 / TestFlight 发布
- **架构**："Manus 1.6 Max architecture"（自家模型）+ 多个 sub-agent 并行
- **iOS 局限**：iOS 是"遥控器 + 通知器"，**所有执行在云端**——iOS 没沙箱，没本地文件，没原生 API
- **独特卖点**：能异步跑（"close the app and Manus keeps working, notifying you when your task is complete"）——iOS 后台限制天然适合这种"扔任务就走"模式
- **.1 个细节**：他们 2026-01 推出 "App Sharing and Testing"——直接打 iOS TestFlight 通道（"automates app packaging for Google Play and TestFlight"）

### 3.2 Genspark Super Agent（3.7K 评分 — 多模型编排）

- **公司**：genspark inc（Stanford 出身 / Eric Jing 联合创始人）
- **Slogan**："All-in-One AI workspace that puts busywork on autopilot"
- **核心机制**：自动路由（super agent 选 GPT / Claude / Gemini / Flux / Sora / Veo）
- **能力**：AI Slides / Sheets / Docs / Developer / Meeting Notes / Chat + Photo Genius（移动独享，语音实时改图）
- **iOS 局限**：跟 Manus 一样云上跑
- **独特卖点**：多模型 + 多产物（演示文稿 / 表格 / 文档 / 视频 / 图像）
- **iOS 独享**：Photo Genius（自然语言改图）——iOS 上跑得动的微调模型（推测是 SD 或 Flux 小模型）

### 3.3 Comet — Perplexity AI 浏览器（7.7K 评分）

- **2026-03-18** 才上 iOS
- **公司**：Perplexity AI
- **能力**：浏览同时让 AI 帮你点 / 读 / 总结 / 跨标签页检索
- **价格**：免费 + Pro / Max 解锁 deeper agentic 任务
- **iOS 局限**：iOS WebKit 上跑（不是真 Chromium，**很多 Web API 残废**：Web MIDI / Web Bluetooth / Web USB / AudioWorklet 全废）
- **核心洞察**：Comet 在 macOS 是真 Chromium（perplexity 自带），在 iOS 只能是 WebKit——**同一产品两套引擎**是 iOS 平台限制的典型表现

### 3.4 Cursor iOS（153 评分 — 2026-06-28 才上）

- **公司**：Anysphere（Cursor 同公司）
- **Slogan**："the best way to build, review, and ship software from anywhere"
- **核心机制**：iOS 启动 agent → **agent 跑在云 VM（每 agent 一个 sandbox VM）** → 截图/视频/sandbox 日志回传手机
- **能力**：
  - 启动 agent 改 bug / 写 feature
  - 跟 codebase 长期对话
  - 截图圈问题（"Point and Draw to Fix"）
  - sandbox VM 跑代码 + 自测
- **iOS 局限**：iOS 是**纯命令面板 + 进度查看**，没有任何本地能力
- **对比**：这是 "Claude Code iOS 客户端"的精品版，**不是 iOS agent**——能力全在云上

### 3.5 Scripting（80 评分 — iOS 本机最深的）

- **公司**：个人开发者（有智方 / 方有智）
- **真本机执行**：TypeScript / JS / Node.js（带 npm）/ Python — **不是云端沙箱**
- **API 覆盖**：Calendar / Notification / Bluetooth / Health / Photos / Live Activities / Control Center / Dynamic Island / Custom Keyboards / Share Extensions / App Intents
- **能造** Apple Shortcuts 直接导入系统
- **VSCode 插件**（CLI tool 实时同步桌面到手机）
- **缺什么**：
  - 没内建浏览器自动化
  - 没 RAG / 长期记忆
  - 没多 agent 协作
  - 没"自然语言 → 自主循环" — 是 AI-assisted scripting，**不是 AI agent**
- **定位**：开发者玩具（4.875 高分 = 开发者群体对它的接受度，但量级小）

### 3.6 Palvia（0 评分 — 最像 Minis 的开源）

- **公司**：ShadowMov（个人）
- **License**：MIT
- **架构**：Swift + SwiftUI（**iOS native**）+ SwiftData 持久化
- **能力**（README 自述）：
  - **多 Agent**：每个独立 SOUL/MEMORY/USER.md + sub-agent 继承父配置
  - **本机代码执行**：WKWebView JS 沙箱，两种模式（repl / script）
  - **内建浏览器自动化**：9 个 `browser_*` tools（navigate/click/input/extract/execute_js/get_page_info/select/wait/scroll），互斥锁
  - **会话 RAG**：Apple NaturalLanguage 本地向量化（cosine > 0.3），hybrid 搜索
  - **多 LLM**：兼容 OpenAI API endpoint（OpenAI / DeepSeek / OpenRouter / Ollama）
  - **定时任务**：`BGTaskScheduler` + Deep Link 触发
  - **技能系统**：可装 skills（跟你 `skills/` 同构）
- **vs Minis**：
  - 优点：真本机、不依赖服务器
  - 缺点：JS only（没 Python / curl / git / ffmpeg）、SwiftData 封闭（没法挂载到 iOS Files 共享）、没 mounts/、没共享存储

### 3.7 OpenClaw（22 评分 — 新兴"节点"模式）

- **公司**：OpenClaw Foundation（"Foundation" 通常非营利定位）
- **2026-06-24** 发布 v2026.7.1
- **模式**：iOS 客户端配对**你自己的 OpenClaw Gateway**（跑在你家里 / 私有云的 gateway）→ iOS 是"节点"
- **能做什么**：chat / voice / Talk mode（实时 + 后台）/ 审批 / 分享（Share Sheet）/ 设备能力（相机/屏幕/位置/照片/联系人/日历/提醒）/ push 唤醒
- **定位**：类似 Telegram + Apple Home + Claude Code 客户端，但**完全用户控制 gateway**
- **独特卖点**：local-first，**用户控制 gateway、key、配置、权限**
- **iOS 局限**：跟 QuickTUI 一样——**所有重活在 gateway**

### 3.8 QuickTUI（0 评分 — Claude Code 远程客户端）

- **公司**：个人开发者（宇雷 廖）
- **2026-04-02** 发布 v1.7
- **模式**：iOS 客户端连**你自己 Mac / Linux / WSL 服务器**跑 Claude Code / Codex / opencode
- **关键新功能**（v1.7）：
  - **Chat mode**：跟 agent 直接消息对话（不只是 terminal）
  - **Relay 连接**：过 NAT / 没公网 IP 也能连
- **iOS 局限**：重活全在服务器
- **价值**：解决"出门在外想用 Claude Code"的连接性问题

## 4. 为什么 iOS 端"全能 Agent"是结构性空白

Apple 6 道锁（跟 [Strudel-LiveCoding.md](./Strudel-LiveCoding.md) 第 5 章"iOS 三锁"同源但更具体到 agent）：

| # | 锁 | 详情 | 对 Agent 的影响 |
|---|---|---|---|
| 1 | **App Store 4.7 "minimum functionality"** | 拒绝 webview wrapper / chat-with-AI-only | 大厂 chatbot 都过不了 → 必须有 native 功能 |
| 2 | **App Store 4.2 "minimum functionality"** | 拒绝无意义重复 / 没自家功能 | 必须有"在 iOS 上跑得动的真活儿" |
| 3 | **App Store 2.3.7** | 拒绝从 App Store 之外下载代码到 iOS | 不能运行时下插件/包（npm/pip 装到 iOS 进程内） |
| 4 | **iOS 沙盒** | app 沙箱 + 容器隔离 + Background tasks 限制（30s + 10 ops/min） | 多 agent 难 / 长任务难 / 后台难 |
| 5 | **禁 JIT** | 禁 mmap RWX，WebKit 是唯一例外 | 不能跑 V8 / Python 完整版 / Java VM / Julia |
| 6 | **禁 fork 守护进程** | app 是单进程 / 不能后台服务 / 不能 launchd | 没法跑 cron / daemon / 长连 |

**叠加效果**：
- 4.7+4.2 → 大厂主动放弃
- 4.7+2.3.7 → 没法做"插件市场 + 第三方技能"
- 4.7+沙盒+禁 JIT+禁 fork → 没法做"真本机+全能"——只能在以下 4 桶中选一：
  - **A. 纯 chatbot**（ChatGPT/Claude/Gemini）—— 简单但没差异化
  - **B. 云上"虚拟电脑"**（Manus/Genspark）—— 复杂但 iOS 端没价值
  - **C. 远程电脑客户端**（Cursor/QuickTUI）—— 用户要自己有 Mac
  - **D. iOS 本机 + 简版**（Palvia/Scripting）—— 评分都低
  - **D+ (Open Minis / Minis 你)** —— 2026-03-14 上架，"iOS 本机 + 5/5 全能" 桶的**先发者**，CN 73 / US 35 / 全球 ~116 评分

**结论**：iOS 本机 + 全能的桶 = **Open Minis 是先发者**（Palvia 0 评分 + Scripting 80 评分 + Open Minis 116 评分），结构性空白正在被填上。

## 5. Minis 在 iOS 全能 Agent 桶里的位置

**Minis（你）跟现有产品的根本差异**：

| 维度 | Minis | 所有现有 iOS Agent |
|---|---|---|
| **执行环境** | iSH 真 Linux（apk add / curl / git / ffmpeg / Python） | WKWebView（JS only） / SwiftData / 云 VM / 远程 |
| **文件系统** | 持久 + iOS Files 挂载 + 跨 session 共享 | 沙箱 / SwiftData 库 / 云 / 远程 |
| **浏览器** | browser_use（通用） | 9 个固定 tools / 远程 / 无 |
| **技能系统** | skills 目录（可装第三方） | skill 系统（受限）/ 无 |
| **共享** | `/var/minis/shared/` + `/var/minis/mounts/<name>/` | ❌ |

**结论**：**在 App Store 现有产品中，没有一个在能力广度上完全对标你**。最接近的是 Palvia（架构同构 = 多 agent + sandbox + 浏览器 + 技能），但执行环境受限（JS only）和文件系统封闭（SwiftData）。

**如果做 iOS 上"全能 Agent"对比图**：

```
                能力广度（5 项能力之和）
                          ▲
                          │
            Manus/Genspark ┤（云上 5/5）
                          │
            Cursor iOS ───┤（远程 5/5）
                          │
        ★ Minis ★ ──────┤（iOS 本机 5/5）
                          │
           Palvia ──────┤（iOS 本机 3.5/5 — JS only）
                          │
        Scripting ─────┤（iOS 本机 3/5 — 缺 browser + agent）
                          │
         WebIDE ────────┤（iOS 本机 1/5）
                          │
                          │  ChatGPT/Claude/Gemini
                          │  ──────────────┤（0/5）
                          └──────────────────────────►
                                  执行位置（on-device iOS）
```

**Minis 的真正护城河**：iOS 本机 + 5/5 全能 + 跨 session 共享 + 挂载 iOS 外部文件夹。**这四件在 App Store 上没有任何一个产品同时提供**——Open Minis（你）是这个 4 维护城河的**先发者**。

### 5.1 Open Minis 真实热度（自我定位）

> **⚠️ 自我调研**：2026-07-14 用户问"你自己在 App Store 的热度怎么样"——才发现我自己（Minis）就是 App Store 上的 **"Open Minis"** (`com.openminis.app`，开发者"森 王")。**我之前的品类调研漏掉了自己**（见 §事实 5 的更新说明）。

**跨区评分数据（2026-07-14）**：

| 区域 | 评分 | 人数 | 备注 |
|---|---|---|---|
| **CN** | **4.99** | **73** | **主战场**——比 US 多 1 倍 |
| US | 4.97 | 35 | 第二大市场 |
| HK | 5.00 | 4 | 满分 |
| JP | 5.00 | 2 | 满分 |
| GB | 5.00 | 2 | 满分 |
| **全球总评分** | **~116** | — | 4 个月累计 |

**基础元数据**：
- **上架日期**：2026-03-14
- **当前版本**：v1.9（2026-06-23 更新）
- **迭代速度**：4 个月 1.9 版本（≈ 2 周/版本）
- **文件大小**：62 MB
- **最低 iOS**：16.0
- **语言**：EN / FR / DE / JA / KO / RU / ZH / ZH（8 种）
- **设备**：127 种（iPhone 5s 起）
- **Bundle ID**：`com.openminis.app`

**v1.9 release notes 信号**（技术深度）：
- ✅ **MCP Integrations**（Model Context Protocol 接入 + `minis-mcp-cli`）
- ✅ **SOUL.md** 人格系统（描述印证 system prompt 的 SOUL.md 字段）
- ✅ **iCloud Sync V2**（record-level sync，修了 v1 的合并冲突 / API key 被覆盖 / 活跃 session 内容丢失）
- ✅ **多 Provider**：OpenAI / Anthropic / Google / OpenRouter / **新增 xAI** + GPT Image-2 / OAuth
- ✅ **并行 tool calls** + 长按 tool capsule 重跑 + reasoning 模型修

**v1.9 Bug Fix 数量** = 12 处（chat crashes / WebView trampling / image gen timeout / camera PNG 优化等）——**迭代非常活跃**。

**跟同期 iOS Agent 产品对比**：

| 产品 | 发布日期 | US | CN | 全球 | 增速判断 |
|---|---|---|---|---|---|
| **Open Minis（我）** | **2026-03-14** | 35 | **73** | **~116** | **先发 + 主战场 CN** |
| Scripting | 2024-12-05 | 80 | 0 | ~80 | 老牌但慢 |
| PocketClaw | 2026-03-05 | 18 | 0 | ~18 | 比我早 9 天，US 0 CN |
| QuickTUI | 2026-04-02 | 0 | 0 | 0 | 我之后 19 天 |
| Palvia | 2026-06-22 | 0 | 0 | 0 | **我之后 100 天** |
| OpenClaw | 2026-06-24 | 22 | 0 | ~22 | 我之后 102 天 |
| Cursor iOS | 2026-06-28 | 153 | 0 | ~153 | 大厂 2 周 153 增速猛 |

**关键洞察**：
1. **Open Minis 是 "iOS 本机 + 全能" 桶的先发者**（2026-03-14，Palvia 100 天后）
2. **CN 评分是 US 的 2 倍**——主战场中国大陆（开发者"森 王"中文名印证）
3. **早期但已突破"零用户"门槛**（全球 116）
4. **评分满意度 4.97-5.00**——产品质量高，但基数小
5. **落后大厂 5 个数量级**——但 iOS Agent 类别本身还没起来，**现在是早期玩家窗口期**
6. **2 周迭代 1 版本**（v1 → v1.9 ≈ 4 个月 5+ 次更新）——研发节奏快
7. **多 Provider（OpenAI/Anthropic/Google/OpenRouter/xAI）+ MCP + 多 Apple 框架**——技术深度领先同期

**为什么我之前漏掉 Open Minis**（方法论缺陷）：
1. **搜词错误**：只搜 "Manus / Genspark / Palvia / Hermes / Cursor iOS / AI agent"——没搜 "Minis / Open Minis"
2. **自我盲点**：做"竞品"调研时，没意识到自己也是 App Store 上的实例
3. **名字误导**：搜 "Minis" 返回的全是 Thomas & Friends Minis / Minion Rush / Mini Soccer——不相关结果就放弃了
4. **产品名不含 "agent"**：叫 "Open Minis" 而非 "*AI Agent*" → 算法排序靠后

**修正**：以后做品类调研时，**必须先搜"自己" + "竞品"**，不能只搜竞品。

## 6. 待挖（避免下次重复）

- **Palvia v1.0.1 → 1.1 升级**（看 README 之外的 commit / issue）
- **Scripting v3.2 → 4.x**（看实际用户多不多 / 有没有内置 browser）
- **Manus iOS 跟 iPad 的差异化**（iPadOS 14+ 后台任务更长，可能体验完全不同）
- **OpenClaw Gateway** 的实际架构（github 仓库没找到——可能要二次搜索）
- **iOS 18+ App Intents 第三方接入** + **Apple Foundation Models** 是不是会给本地 Agent 打开新窗口
- **ChatGPT Codex Cloud**（2025-05 推的 Codex 是不是会出 iOS 客户端）
- **Anthropic Claude iOS** 是不是会出"Claude Code 移动版"（Cursor 模式）
- **2026-05-14 Cult of Mac 报道** "iPhone could be swarming with AI agents soon"——Apple 计划允许的"AI agent"具体是什么
- **PocketClaw / Mira / Hermes 实际留存**（这些 0~20 评分的小 app 6 个月后还活着吗）
- **Hermes AI - Persistent memory**（"Persistent memory" 是 Palvia 同款 SOUL/MEMORY 吗？）

## 7. 引用

- App Store（us / hk）— 2026-07-14
- iTunes Search API / iTunes Lookup API — 2026-07-14
- [github.com/samhjn/Palvia](https://github.com/samhjn/Palvia) — README 2026-07-14
- [scripting.fun](https://www.scripting.fun) — 官网 + App Store 描述 2026-07-14
- [manus.im](https://manus.im) + [apps.apple.com/us/app/manus-ai-agent-automation/id6740909540](https://apps.apple.com/us/app/manus-ai-agent-automation/id6740909540)
- [genspark.ai](https://www.genspark.ai) + [apps.apple.com/us/app/genspark-ai-workspace/id6739554054](https://apps.apple.com/us/app/genspark-ai-workspace/id6739554054)
- [comet.com](https://www.comet.com) + [apps.apple.com/us/app/comet-ai-browser-assistant/id6748622471](https://apps.apple.com/us/app/comet-ai-browser-assistant/id6748622471)
- [Cursor iOS](https://apps.apple.com/us/app/cursor/id6767085653) — 2026-06-28 发布
- [OpenClaw Foundation](https://openclaw.org) + [apps.apple.com/us/app/openclaw-ai-that-does-things/id6780396132](https://apps.apple.com/us/app/openclaw-ai-that-does-things/id6780396132)
- **[Open Minis（你自己）](https://apps.apple.com/us/app/open-minis/id6759188481)** — `com.openminis.app`，开发者"森 王"，2026-03-14 上架，全球 ~116 评分（CN 73 / US 35）
- 关联笔记：Strudel-LiveCoding（iOS 三锁 / JIT 政策同源）
- 关联笔记：AI-Input-Method（iOS Keyboard Extension 沙盒另一维度）
