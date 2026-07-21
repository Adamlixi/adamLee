---
layout: post
title: "🎙️ AI Input Method · 手机端 AI 输入法品类调研"
tags: [ai-agents, research]
---
> **核心问题**：手机端 AI 输入法是个新爆发品类——Wispr Flow A 轮 $81M，Aqua Voice YC W24 716p 上 HN。
> 但 iOS 沙盒让"在输入法里做 agent"几乎不可能，**真正的空白是"输入法 + App Intents + MCP"组合**。

---

## 1. 品类图谱（按路线分）

| 路线 | 代表产品 | 状态 | 关键特征 |
|---|---|---|---|
| **云端 AI 龙头** | **Wispr Flow** (YC W24) | iOS/Android/Mac/Win，**A 轮 $81M**（2025-12） | 4× 键盘速度，AI Auto-Edit，Snippet 语音触发，100+ 语言 |
| **云端 AI 编辑器** | **Aqua Voice** (YC W24) | Launch HN **716p**（2024-03），Aqua Voice 2 140p（2025-04） | 语音原生文档编辑器，MoE 转写 + LLM 重写，"make this a list" 自然语言命令 |
| **本地离线派** | Superwhisper、Voquill、Whispering、Yap、Purr、Handy、CarelessWhisper、FreeFlow、MacWhisper、Voquill | Show HN 频繁（2024-2026 持续冒） | Whisper.cpp / Parakeet 本地推理，免费开源，隐私卖点 |
| **iOS 平台层** | Apple Intelligence Writing Tools（iOS 18+） | 系统级，已上线 | 选中文本即可 Rewrite/Proofread/Summarize |
| **大厂键盘** | Microsoft SwiftKey + Bing AI（已弃 Samsung）/ Samsung Keyboard AI | 长尾，存在感弱 | 功能碎片化 |
| **Android 自带** | Gboard AI 改写 | 集成进 Pixel / 部分 OEM | 边缘功能 |
| **小工具 AI 键盘** | AI Keyboard (ChatWrite)、I Am Now、Keymate AI、Cerebro | App Store 长尾 | 多数已死 |
| **中国输入法 + AI** | 讯飞输入法、百度输入法、搜狗输入法 | 用户基数大但 AI 化渐进 | 语音识别老牌 + 大模型助手接入 |

> 💡 **市场空白点**：
> 1. **手机 + 真 agent**——所有 Show HN 都是先桌面后手机；iOS API 限制反而保护了壁垒
> 2. **隐私 + 真本地**——2026-04 Wispr 隐私争议后，"local + free + privacy"标签密集爆发
> 3. **中国市场是平行宇宙**——不要直接复刻 Wispr，做中文原生 + 海外华人 + 隐私 + 离线可能更现实

---

## 2. 关键数据点

### Wispr Flow（品类标杆）
- 2024-09-30 Show HN → 2025-12 A 轮 **$81M**（一年翻牌）
- 用户自述 "the best AI product I've used since ChatGPT"（Superhuman CEO Rahul Vohra）
- 现在 iOS / Android / Mac / Windows 四端
- **核心卖点**：Auto-Edit——说你想的，AI 帮你清掉口水话/重复词/语病，**直接出可发邮件的成品**
- 关键指标：**50-70% 输入零修改**（vs Apple/Google <5%）
- 客户：Clay（200 人团队"共享速度优势"）、Superhuman CEO、Reid Hoffman、Steven Bartlett
- 创始人：Tanay Kothari（CEO）+ Sahaj Kothari（CTO），**2008 年看 Iron Man 想要 Jarvis**，2023 圣诞两周做出第一个版本

> ⚠️ **隐私争议**：[2026-04-15 博客调查](https://wensenwu.com/thoughts/wispr-flow-investigation) 指出 Wispr 偷偷截图 + 追踪每条 URL，引发 HN 讨论
> 详见 `AI-Input-Method`

### Aqua Voice
- Launch HN **716p**（HN 史上 voice AI 最高分）
- YC W24 毕业；创始人 Finn 重度 dyslexia → "Dragon Dictation 用了 15 年从没真正好用过"
- 把 "voice-as-input" 做到**编辑器级别**——不是打字替代品，是文本编辑器本身
- **3.2% WER**（Librispeech），vs Google 5.5%（自评）
- Aqua Voice 2 (2025-04) 转型：<50ms 启动，~1s 延迟，**insert into ANY field**（Cursor/Gmail/Slack/terminal）——从独立编辑器变成全平台输入

### Apple Intelligence Writing Tools（iOS 18+）
- 系统级集成在所有文本输入框
- Rewrite / Proofread / Summarize / Tone 调整
- **杀手锏**：用户无须装第三方键盘，原生
- 缺点：不能"语音 → AI 改写"，还是分两步

---

## 3. Agent 能力分层（按"agent 程度"分三档）

### 第一梯队：真正做 agent 的（跨 app / 多步 / 工具调用）

| 产品 | Agent 能力 | 平台 |
|---|---|---|
| **Apple Intelligence + Siri** (iOS 18+) | **最强**：跨 app 操作（"把这张照片发给妈妈"、日历+邮件+提醒事项联动）、App Intents（第三方 app 接入 Siri）、屏幕感知 | iPhone/iPad |
| **Google Gemini Live + Pixel** | 多模态 agent + Google Workspace 深度集成（Calendar/Gmail/Maps） | Android/Pixel |
| **Microsoft Copilot Voice** | Windows 11 系统级，键盘快捷键触发，能控制 Settings/Files/Apps | Windows/Copilot+ PC |
| **ChatGPT Voice Mode (Advanced)** | 多步 reasoning + 工具调用（web search / code / canvas / image） | iOS/Android |
| **Claude（app 内）Voice** | 多步 reasoning + tools（Artifacts/Projects） | iOS/Android |
| **Perplexity Voice** | 多步搜索 + 多模态 | iOS/Android |
| **TalkiTo**（2026，Show HN 5p） | **直接接 Claude Code / Codex CLI**：voice + Slack 让 Claude 干活 | 桌面 |
| **Rowboat / RowboatX**（218p/131p） | Open-source Claude Code for everything，**filesystem-as-state + 监督 agent**，连 ElevenLabs MCP 做每日 arXiv 播客生成 | CLI/桌面 |

> 💡 **关键观察**：第一梯队**其实不是"输入法"**，而是**对话/操作系统层 agent**。他们的"agent + voice"是系统级副产品，不是产品定位。

### 第二梯队：有 agent 雏形（编辑器内自然语言指令）

| 产品 | Agent 能力 | 平台 |
|---|---|---|
| **Aqua Voice** ⭐ | **最像 agent**：用自然语言下编辑指令——"make this a list"、"add inline citation here for page 86 of this book"、"condense this to 3 bullets"。**语音内容 vs 语音指令**自动分流 | 桌面/iOS |
| **Utter**（2026-03-06，3p） | **BYOK + 自定义 prompts**：本地 Whisper + 用户写的 prompt → **任何 transformation**（翻译、改写、调格式、提取实体）。**用户可编程的 agent pipeline** | Mac/iPhone |
| **Wispr Flow** | **Snippet Library**：语音触发 → 自动展开（"我时间表" → 调日历/调 API → 渲染动态文本）。**Auto-Edit**：语音 → 润色 → 干净文本（不是 agent，是 transformer） | iOS/Android/Mac/Win |
| **Monologue** | 简化版 Wispr，没有 snippet/snippet 触发，纯转写+润色 | Mac/iOS |

### 第三梯队：纯输入工具（不是 agent）

Superwhisper、Voquill、Whispering、Typeless、MacWhisper、CarelessWhisper、Handy、VibeFlow（"Aqua Voice + Whisper.cpp, local only"）

---

## 4. iOS / Android 沙盒限制（决定性）

### 4.1 iOS Custom Keyboard Extension 的硬限制

> **核心问题**：Apple 把 keyboard extension 视为**完全不可信的第三方组件**——它能访问你正在输入的任何密码、聊天记录、密码管理器、支付信息。

**沙盒规则：**
- ❌ **不能访问网络**（除非用户开 "Allow Full Access"，且要忍受 WhatsApp/Signal/Gmail 反复弹"不要开启全权限"的警告）
- ❌ **不能访问文件系统**（除 App Group 共享 container）
- ❌ **不能后台运行**——键盘一收，进程**秒被 kill**
- ❌ **不能调用相机/麦克风**（Full Access 后能用，受限）
- ❌ **不能直接打开其他 app**——只能 `openURL`
- ❌ **不能做长任务**（超过几分钟必被杀）
- ❌ **不能跨进程 IPC**（除非用 App Group）
- ❌ **进程内存预算有限**（大约 50MB）
- ❌ **不能调用私有 API**（会被 App Review 拒）

**Full Access 的真实摩擦：**
- iOS 弹窗明确写 "Allow full access" 会允许第三方键盘"transmit keystrokes"
- 主流 app（1Password、Signal、Banking apps）**会检测非 Apple 键盘并弹警告**
- **70-80% 用户根本不开 Full Access**（行业经验值，Wispr Flow 早期流失率印证过）

**Wispr Flow 在 iOS 上的"阉割"：**
- ✅ 语音转文字 + Auto-Edit、Snippet 展开、Personal Dictionary
- ❌ 桌面版 "command mode" 复杂触发、跨 app 自动化、跟外部 MCP / Linear / Notion 集成
- **这就是 iOS 沙盒的硬天花板**

### 4.2 Android InputMethodService 的限制（宽松但仍有约束）

**可以做的：**
- ✅ 网络访问（默认）、文件系统（部分）、后台 Service、调用其他 app、录音 + 上传、推送通知

**不能做的：**
- ❌ 跨 app 数据访问（需要 Accessibility Service / MediaProjection 这种敏感权限）
- ❌ 其他 app 内的 input 直接注入（除非 root）
- ❌ 在非自己输入法激活时执行操作
- ❌ 后台服务在国产 ROM 上被滥杀（MIUI/EMUI/ColorOS 都有自启动白名单）
- ❌ IME 进程死亡时数据丢失

**国产 ROM 的额外限制：**
- MIUI / EMUI / OriginOS / OneUI **对输入法有自启动白名单 + 关联启动限制**
- 不给"自启动"权限 = 后台 agent 跑不起来
- **讯飞/百度/搜狗是预装/白名单，所以不受这个限制**——这是结构性壁垒

### 4.3 真正可行的"输入法 + agent" 路径

| 路径 | 可行度 | 说明 |
|---|---|---|
| **A. Hybrid IME + 配对 app** | ⭐⭐⭐⭐⭐ | IME 只做语音 capture → 主 app / 云端 agent → 结果注入。**Wispr Flow 模式** |
| **B. iOS App Intents（iOS 18+）** | ⭐⭐⭐⭐ | 用户选中文字 → 系统弹 Action menu → 触发你的 App Intent。**绕开 IME 沙盒** |
| **C. 系统级 integration**（Apple Intelligence / Gemini Live / 小爱 / 豆包 路线） | ⭐⭐⭐ | 不做 IME，做**手机系统级 agent** |
| **D. Android IME + Accessibility（灰色）** | ⭐⭐ | Accessibility Service 能跨 app 操作，但 Google Play 政策严限 |

---

## 5. Wispr Flow 实际技术架构（深度拆解）

> 数据来源：[Wensen Wu 法医调查报告](https://wensenwu.com/thoughts/wispr-flow-investigation)（2026-04-15，详细到进程级）+ Tanay Kothari 的 Show HN + [FreeFlow 开源克隆](https://github.com/mrinalwadhwa/freeflow) 源码。

### 5.1 macOS 双进程架构

```
┌─────────────────────────────────────────────────┐
│                  用户输入流                        │
└─────────────────────────────────────────────────┘
                         │
                         ▼
        ┌─────────────────────────────────┐
        │  helper (Mach-O Swift binary)    │  ← 后台常驻
        │  - CGEventTap 截获键盘事件        │
        │  - 录音 (AudioToolbox)           │
        │  - 屏幕/URL 读取                 │
        │  - SQLite 本地存储                │
        └─────────────────────────────────┘
                         │ IPC (XPC / sockets)
                         ▼
        ┌─────────────────────────────────┐
        │  Wispr Flow.app (Electron)        │
        │  - UI (settings, snippets)        │
        │  - 业务逻辑                        │
        └─────────────────────────────────┘
                         │
                         ▼
        ┌─────────────────────────────────┐
        │  *.baseten.co (云端推理)          │
        │  - STT (自研, 非 Whisper)         │
        │  - Auto-Edit LLM pass             │
        │  - Snippet 展开                   │
        └─────────────────────────────────┘
                         │
                         ▼
        注入回当前 app (CGEventPost 模拟键盘输入)
```

### 5.2 关键模块详解

#### (a) 输入拦截层：CGEventTap
```swift
// macOS 给辅助工具的官方 hook
let eventTap = CGEvent.tapCreate(
    tap: .cgSessionEventTap,
    place: .headInsertEventTap,
    options: .defaultTap,
    eventsOfInterest: .keyDown.union(.flagsChanged),
    callback: myCallback,
    userInfo: nil
)
```
- **不是用 keyboard extension**——那是 iOS 的限制
- macOS 允许任何带 Accessibility 权限的进程用 `CGEventTap`
- **这就是 macOS 比 iOS 强的地方**：能"看见"所有 app

#### (b) 屏幕/URL 上下文层
```swift
// 读取前台 app
let frontApp = NSWorkspace.shared.frontmostApplication
// 读取浏览器 URL（需要 SAFARI_AX / CHROME_AX）
let url = ... // 通过 Accessibility API 查 browser DOM
// 读取屏幕文字（OCR 或 accessibility tree）
let screenText = ...
```
- 这些 context 跟音频**一起**发到云端 LLM
- 是 Auto-Edit 质量的**关键**——LLM 知道你在写邮件 vs Slack vs Notion，调风格

#### (c) 云端推理：Baseten Pipeline
- `*.baseten.co` 是 Baseten 的推理托管平台（YC S20，做的是 "deploy ML models in production"）
- Wispr Flow 自己说 "models are not Whisper, custom for natural speech"
- **推测架构**：
  - Pass 1: STT（自研 streaming ASR，类似 Whisper-large-v3 但针对口语优化）
  - Pass 2: LLM Auto-Edit（GPT-4o / Claude / 自研小型模型做文本清理）
  - 串行流式，~200-400ms 端到端

#### (d) 注入层：CGEventPost
```swift
let keyDown = CGEvent(keyboardEventSource: nil, virtualKey: ..., keyDown: true)
keyDown.post(tap: .cghidEventTap)
```
- 模拟键盘输入到当前前台 app
- **用户体验**：说完话松开 [Fn] → 文字立刻"出现"在任何 app

#### (e) 本地存储
- `/Users/<USER>/Library/Application Support/Wispr Flow/`
- SQLite, **未加密**
- 包含：录音缓存（198 MB / 10 天使用）、snippet 配置、personal dictionary

### 5.3 iOS 架构：被阉割的真实样子

```
┌────────────────────────────────────────┐
│   Wispr Flow 主 App (Swift/SwiftUI)    │
│   - 设置界面                            │
│   - Snippet / Personal Dictionary 同步  │
│   - 录音时短暂驻留                       │
└────────────────────────────────────────┘
              │ App Group + URL Scheme
              ▼
┌────────────────────────────────────────┐
│   Keyboard Extension                    │
│   (UIInputViewController)               │
│   - 麦克风按钮                          │
│   - 录音 (AVFoundation)                 │
│   - 通过 Shared App Group 与主 app 通信 │
│   - 注入文本 (textDocumentProxy.insertText)│
└────────────────────────────────────────┘
              │ HTTPS (需 Full Access)
              ▼
        *.baseten.co (同 macOS)
```

**iOS 上失去的能力**：
- ❌ 屏幕/URL 上下文（iOS 没有 CGEventTap，UIInputViewController 不能读其他 app 内容）
- ❌ 跨 app 自动化（必须 openURL + app 必须支持 URL scheme）
- ❌ 复杂 command mode（依赖 URL context 触发）
- ❌ 键盘 hook、后台长任务、跨 app Accessibility

### 5.4 关键技术决策

| 决策 | 为什么 |
|---|---|
| **云端 AI，不是本地** | 本地 Whisper WER 比云端大模型差 2-3pp；本地 LLM 质量不行；移动端推理发热；100+ 语言本地模型难全支持 |
| **用 Baseten 不用 AWS/GCP** | YC 同生态；Baseten 优化 ML serving（auto-scaling, GPU 多租户）；比自建 ML 平台省 10x 工程量 |
| **Mac 优先不在 iOS** | 用户声音场景：Tanay 自己"手抖+讨厌打字"，桌面工作流比手机深；iOS 沙盒做不到完整 agent |
| **Auto-Edit 是付费转化核心** | 50-70% 零修改 vs 行业 <5%，用户说"产品值$1000/月"——付费转化比 STT 准确率高 10x |
| **双进程架构（macOS）** | helper 后台常驻 + 主 app UI，分离核心逻辑与展示层，方便后续跨平台 |

### 5.5 FreeFlow 开源克隆验证的架构选择

- Swift native + AudioToolbox/AVFoundation
- Hold key → record → upload → insert（push-to-talk）
- Mac only（CGEventTap 不在 iOS 上）
- Models: OpenAI Whisper API、Groq Whisper、自带 NLLB 翻译
- 16GB local cache
- **验证了**：纯本地、零隐私争议、能跑 Parakeet/Whisper.cpp 的免费方案**技术完全可行**——Wispr 的护城河只是产品打磨 + 网络效应 + 投资

---

## 6. 中国手机助手 voice agent 现状（待补）

> 用户在调研中提到但没深挖的方向。下次要做的话，重点关注：
> - **豆包**（字节）：与手机 OS 深度整合（豆包手机助手）
> - **小爱**（小米）：MIUI 自带，跨 app 控制能力
> - **小艺**（华为）：HarmonyOS Intents，第三方 app 接入
> - **通义/天猫精灵**（阿里）：钉钉 + 高德 + 淘宝联动
> - **腾讯混元 + 腾讯输入法**：微信生态整合
>
> ⚠️ **结构性差异**：中国版的核心特征——**输入法 + 手机助手是分离产品**。Apple Intelligence 在 iOS 是统一的——这是中美的产品形态差异。

---

## 7. 产品方向 Idea（详情见 build-mobile-ai-keyboard）

### 形态 1：Hybrid IME + 配对 app ⭐⭐⭐⭐⭐（最推荐）
```
[键盘] —— 语音 → [主 App / 云端 Agent] —— 返回文本 → [键盘注入]
                ↑
        跑 shell / 文件 / 网络 / MCP
```
- iOS / Android 都能做
- **差异化点**：不只做"语音 → 文本"，做"语音 → 任意任务 → 结果返回"

### 形态 2：App Intent + 自定义 Action ⭐⭐⭐⭐（iOS 18+ 优势）
- 用户选中任意文本 → "用 XX 处理"
- 不需要 IME，直接做 iOS / macOS / Android Action
- 跟 Apple Intelligence Writing Tools 抢位

### 形态 3：手机系统级 agent ⭐⭐⭐（国内路线）
- 跟小米/华为/字节合作/接入
- 不做 IME，做系统级 voice agent

### 形态 4：Android IME + Accessibility（不推荐，灰色）
- Accessibility Service 能跨 app 操作
- 但 Google Play 政策严限，国内 ROM 滥杀

---

## 8. 关键洞察

### 8.1 品类很热但远未定型
Wispr $81M + Aqua 716p + Apple 系统级集成，**所有大玩家都在抢，但产品形态还在试**。

### 8.2 手机是真正的空白战场
所有 Show HN 都是先桌面后手机；iOS API 限制反而保护了壁垒。

### 8.3 隐私是 Wispr 之外的明显机会
2026-04 争议后，"local + free + privacy"标签密集爆发，**这是结构性反扑**。

### 8.4 真正的 agent voice 不在输入法赛道里
最强大的 voice agent（Siri/Gemini Live/Copilot Voice/ChatGPT Voice）都是**通用 LLM 产品的语音入口**——他们先有 agent 能力，再加 voice，不是反过来。

### 8.5 iOS 上的 agent 入口是 App Intents，不是 IME
Wispr 在 iOS 被沙盒困住。用 App Intents + 主 app 厚 + MCP，能做出他们做不出的 agent。

### 8.6 桌面先行、手机阉割
iOS 上 IME 只能"返回文本到输入框"——不能跨 app 操作。真正的 agent 能力必须走 App Intents 或主 app。

### 8.7 不做输入法，做"输入法背后的 agent 服务"
给 Wispr Flow / Aqua Voice / 讯飞 / 百度提供 agent SDK（MCP 化）——**B2B2C 模式**。

### 8.8 分发壁垒比技术壁垒更重要
iOS / Android 用户切换输入法成本高，80% 用户不会主动切。**纯第三方输入法 → 难做大**（WhatsApp/Gboard/Samsung 三大壁垒）。

---

## 9. 待办 / 后续可深挖

### 用户已表达"在输入法里加 minis 功能"
- 路径已明确：Hybrid IME + 主 app + iOS App Intents
- 待确认：是只做研究，还是真要做产品
- 见 `build-mobile-ai-keyboard`

### 没查的（避免下次重复）
- [ ] Wispr Flow 真实 DAU/MAU 和付费转化率
- [ ] Aqua Voice 用户规模和付费率
- [ ] 中国输入法 AI 化具体进度（讯飞"星火"接入情况、百度"灵医"等）
- [ ] VoiceInk / Handy / Superwhisper 的 App Store 排名
- [ ] 移动端"AI 输入法"在小米 / OPPO / vivo / 鸿蒙原生集成的状态
- [ ] 微信输入法、字节跳动输入法（如果有）状态
- [ ] Aqua Voice 完整命令集（Show HN 没列出）
- [ ] RowboatX 完整工作流架构图（filesystem-as-state 怎么用）
- [ ] 中国 voice agent 详细对比（豆包 / 小爱 / 小艺 / 天猫精灵 / 腾讯）

### 关键未解的问题
- [ ] Wispr Flow 未来 6 个月是否会做"voice → agent 任务"（"Hey Flow, 帮我订明天 3pm 的机票"）
- [ ] Aqua Voice 会不会扩到非文档域
- [ ] Apple 在 WWDC 26/27 会不会把 Siri + ChatGPT/Claude 集成做到第三方输入法层级
- [ ] iOS 26+ App Intents 会不会扩展到"选中任意 app 任意内容触发"

---

## 10. 隐私争议（2026-04 详细）

来自 [Wensen Wu 调查](https://wensenwu.com/thoughts/wispr-flow-investigation)：

**Wispr Flow 实际采集的数据（10 天使用样本）：**
- 198 MB 音频缓存
- 所有访问的 URL
- 屏幕截图（macOS Accessibility API）
- 所有键盘输入（CGEventTap 截获）
- 所有错误日志（Sentry 100% capture）
- 产品分析（Posthog）

**网络端点：**
- `*.baseten.co`（云端 ML inference）
- Sentry 错误监控
- Posthog 产品分析
- **每月 PII 数据流出量未公开**

**Tanay Kothari 后续回应（未确认）：**
- 承认部分问题
- 解释屏幕读取是为了 LLM 上下文
- 承诺改进数据保留策略（**具体未公开**）

**对竞品的启示：**
- ⚠️ **差异化机会**："默认本地 + 端到端加密 + 用户可控上传"是天然的卖点
- ⚠️ **隐私 ≠ 功能少**：本地 Whisper.cpp + 端侧小模型已经能跑出 80% 体验
- ⚠️ **透明数据策略**：列出每条数据流向 + 保留期 + 用户删除入口，是基础门槛

---
