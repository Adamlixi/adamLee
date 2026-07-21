---
layout: post
title: "🕷️ Scraping & Information-Gathering Agent — 抓取 + 信息获取 agent 垂直全貌"
tags: [ai-agents, research]
---
> "Web scraping with GPT-4o is powerful but expensive." — HN Algolia, 2024-09 (377p/167c)
> "One Wikipedia page costs your AI agent 68,000 tokens." — HN, 2026-07-11 (14p/7c)

"专门做爬虫 + 信息获取的 agent" 是 2025-2026 AI agent 圈**最卷的细分赛道**——GitHub 上单项目 10万 stars 的就有 2 个（Firecrawl 151k、Browser-Use 104k），相关主题 HN Algolia 单关键词就能搜出 30+ 个 Show HN 项目。这个垂直**不是** Manus / Cursor / Claude Code 这类"全能 agent"——它的产品定位是"AI agent 的网络访问层 / 数据提取层 / 信息获取入口"，是 infra 层的 agent。

---

## §0 关键问题先说结论

**这个赛道为什么这么卷？** 因为 AI agent 严重依赖"实时 web 数据 + 实时 web 能力"——
- LLM 训练数据 = 静态 → 大模型"outdated"
- LLM 不能访问实时内容 / 私有内容 / 付费墙后 → 没法做"信息获取"任务
- LLM 不能操作浏览器 → 没法做"自动化"任务
- 浏览器 cookie / 验证码 / Cloudflare / 隐私面板 = 普通抓取方式大量失败

**所以 2025-2026 出现一个完整链条**：

```
LLM 推理能力 → 用户想"问 AI 一个问题"
              → 需要"AI 自己去找信息"
              → 需要 search / browse / scrape / interact API
              → 形成"AI agent 的网络层"独立赛道
```

**两条产品路线已经清晰**（vs Minis 调研框架）：
1. **SaaS API 路线**（Firecrawl / Tavily / Exa / Oxylabs / ScrapingBee）— 给 agent 调 HTTP API
2. **Browser agent 路线**（Browser-Use / Stagehand / Skyvern / Hyperbrowser）— 给 agent 一整台"虚拟浏览器"
3. **Marketplace 路线**（Apify / 八爪鱼）— 给 agent 一个"商店"去找现成的 scraper

---

## §1 整体 8 类玩家（一图看清）

```
                    ┌─────────────────────────────────────────────┐
                    │        AI Agent 需要「网络能力」的三大场景     │
                    │  ┌─────┐ ┌─────┐ ┌────────┐                  │
                    │  │search│ │scrape│ │interact│                 │
                    │  └─────┘ └─────┘ └────────┘                  │
                    └────────┬────────┬───────┬───────────────────┘
                             ▼        ▼       ▼
    ┌──────────────────────────────────────────────────────┐
    │  ① Search API (LLM 替身检索)                            │
    │  Tavily ⭐ND · 2M devs · 300M req/mo                  │
    │  Exa · neural search for AI agents                    │
    │  Perplexity Sonar · DeepSeek + Sonar Pro               │
    │  Brave Search API · You.com                            │
    ├──────────────────────────────────────────────────────┤
    │  ② Scrape/Crawl API (网页→结构化数据)                   │
    │  Firecrawl ⭐151k · YC · 150K 公司信任                │
    │  Browser-Use ⭐104k · "make websites accessible"       │
    │  Crawl4AI ⭐72k · open-source LLM friendly crawler    │
    │  ScrapingBee · Zyte · Diffbot · Spider-rs (Rust)      │
    ├──────────────────────────────────────────────────────┤
    │  ③ Browser Agent (整台虚拟浏览器)                       │
    │  Stagehand ⭐23k (Browserbase 出品)                    │
    │  Skyvern ⭐22k · CAPTCHA/2FA 自带 · 500+ 企业客户      │
    │  Hyperbrowser · Browserbase · Lightpanda (Zig)        │
    │  Verceel agent-browser · Tabstack (Mozilla)           │
    ├──────────────────────────────────────────────────────┤
    │  ④ Headless Browser (新出现的底座)                      │
    │  obscura (Rust, V8, 17MB idle)                        │
    │  Lightpanda (Zig, ⭐319)                            │
    │  ChromeDevTools/chrome-devtools-mcp ⭐46k             │
    │  浏览器是 agent 的"网卡"                               │
    ├──────────────────────────────────────────────────────┤
    │  ⑤ Deep Research Agent (LLM 主导的整段研究)            │
    │  Gemini Deep Research (Google, 2024-12, 接 MCP 2026-04)│
    │  OpenAI Deep Research (2025-02)                       │
    │  Tongyi DeepResearch (Alibaba, ⭐19k)                  │
    │  LangChain open_deep_research ⭐12k                   │
    │  SkyworkAI DeepResearchAgent ⭐3k (字节)              │
    ├──────────────────────────────────────────────────────┤
    │  ⑥ Marketplace (iOS-like store for scraping)          │
    │  Apify ⭐24k · 52,856 Actors · revenue-share           │
    │  头部 Actor: Google Maps Scraper ⭐1.6k · 509K runs    │
    ├──────────────────────────────────────────────────────┤
    │  ⑦ 国内大众工具 (SaaS + RPA)                            │
    │  八爪鱼 (深圳数阔) · 450万+ 用户 · 日均 10亿+ 数据     │
    │  影刀 RPA (杭州分叉) · 3万+ 企业                      │
    │  简数 / 后羿 / 火车头                                  │
    ├──────────────────────────────────────────────────────┤
    │  ⑧ AI 浏览器 (含抓取能力)                              │
    │  Perplexity iOS 4.83★/485K r · Comet 4.75★/7696r     │
    │  Manus iOS 4.74★/35K r · Goover 4.54★/13r            │
    │  Obsidian Web Clipper 4.35★/92r                      │
    └──────────────────────────────────────────────────────┘
```

> **设计含义**：玩家这么多但**核心能力只有 4 个**：search / scrape / interact / research。剩下的是这 4 个能力的市场包装（开源 vs SaaS / 浏览器 vs API / 中国 vs 美国 / 个人 vs 企业）。

---

## §2 开源 GitHub Stars Top — 项目正文

按 "公开 stars × 真实性" 排，**4 个 100k 级**、**8 个 10k 级**：

### §2.1 ⭐100k+ 级：Agent + 抓取主战场

| Repo | ⭐ | 增速 | 一句话定位 | 商业模式 | License |
|------|----|------|----------|---------|---------|
| [firecrawl/firecrawl](https://github.com/firecrawl/firecrawl) | **151k** | 414/day | Extract data from the web for AI | YC SaaS + 开源自部署 | AGPL-3.0 |
| [browser-use/browser-use](https://github.com/browser-use/browser-use) | **104k** | 287/day | Make websites accessible for AI agents | 开源 SDK · 商业 Cloud | MIT |

**Firecrawl 的关键决策**（读 firecrawl.dev 主页）：
- "Extraction-ready web data for any LLM, use it anywhere"
- **直接给 AI agent 写 onboarding SKILL.md**——agent 自己按文件 step-by-step 拿 API key，呼应 Minis 的 SKILL/agent 模式
- "Move from Apify to Firecrawl because 50x faster"——直接对抗 Apify
- 性能：P95 latency **3.4 秒**（scrape 50ms / crawl 52ms）—— 这是 trap：scrape 自身 50ms，但 整段提取流程 3.4s
- "Token efficient: 93% fewer input tokens via clean markdown"——直接对应 AI agent 的核心痛点
- 端点：Web Scraping / Web Search / Web Crawling / **Browser Interaction** / Web Monitoring
- 客户：150,000+ companies
- 工作流：WorkOS ID-JAG 协议，是 `注册→提工单拿 key → 一行代码调用`
- "Trust me bro, Firecrawl is what I trust"——Discord 验证体系

**Browser-Use 的关键决策**（读 README）：
- "Make websites accessible for AI agents"
- "Automate tasks online with ease"
- 工作流：agent 用 LLM 把自然语言指令 → 浏览器操作（click/type/scroll）
- 服务三种用户：① Open-source dev（自己跑了 Playwright）② Cloud SDK（拿来即用）③ Enterprise Custom
- AGPL-3.0（**自部署商业必须开源**——商业上"反 SaaS"策略）

### §2.2 ⭐10k-100k 级：5 个重点项目

| Repo | ⭐ | 一句话定位 |
|------|----|----------|
| [unclecode/crawl4ai](https://github.com/unclecode/crawl4ai) | **72k** | Open-source LLM Friendly Web Crawler & Scraper |
| [ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp) | 47k | Chrome DevTools MCP server（让 agent 通过 MCP 控制浏览器） |
| [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser) | 38k | Browser automation CLI for AI agents（Rust 版） |
| [apify/crawlee](https://github.com/apify/crawlee) | 24k | 通用 web scraping / crawling 框架（开源，被 Apify 商业站继承） |
| [browserbase/stagehand](https://github.com/browserbase/stagehand) | 23k | AI Browser Automation Framework（Browserbase 出品） |
| [Skyvern-AI/skyvern](https://github.com/Skyvern-AI/skyvern) | 22k | Automate Browser based workflows（CAPTCHA/2FA 自带） |

### §2.3 关键反差：Browser-Use 500+ GitHub Issue 圈 + Agent-Browser 反向 fresh

- **Browser-Use 的 issue 量**：1.5K+ open issues / 13K+ total issues = "用户踊跃 + 问题极多"。这两个数字同时出现的项目 = 真实需求 vs 文档/稳定性不匹配
- **agent-browser (Vercel, Rust)** 才 38k 但 2026-01 起步 → 大厂下场做"agent 浏览器"

### §2.4 License 反差信号 = 商业策略

| 项目 | License | 含义 |
|------|---------|------|
| firecrawl | AGPL-3.0 | 自部署→必须开源；商业→必须付 SaaS 版 |
| browser-use | AGPL-3.0 | 同上 |
| crawl4ai | AGPL | 同上 |
| stagehand | MIT | 完全开放，Browserbase 走 SaaS |
| skyvern | AGPL-3.0 | 自部署→必须开源 |

**含义**：这些项目选 AGPL 不只是"反封闭"，是因为**赛道就是 SaaS**。选 MIT 的公司（如 Stagehand）赌的是"开发者粘性 + SaaS 订阅服务"。

---

## §3 海外三家 SaaS API 厂商（深度拆解）

### §3.1 Firecrawl（YC） — Agent 的网络数据层

| 指标 | 数据 | 出处 |
|------|------|------|
| 创始 | Y Combinator 2024 (YC W24) | [yc directory] |
| GitHub Stars | 151k | 2026-07 |
| Trust 客户 | 150,000+ companies | firecrawl.dev 主页 |
| 性能 | P95 3.4秒 | 同上 |
| 单搜索 token 节省 | 93% | 同上 |
| 投资 | YC 投资 + Nubank/Pshop/Mercado Libre/Mozilla 等 | 主页底部 |
| 7 个产品 | Scrape / Search / Crawl / Browser Interaction / Monitor / Map / Playground | firecrawl.dev/products |

**为什么 Firecrawl 第一**：
1. **最早定义 "AI-first scraping"** 标准——其余项目大多脱胎于传统爬虫
2. **第一时间给了 agent `SKILL.md`**（2025-2026 关键能力）让 agent auto-onboard
3. **WorkOS ID-JAG 协议**——把"agent 注册→拿 key→调用"做到了极致：
   - agent 发一个 POST：`{agent_id, owner_email}` 
   - 拿到 workos `pending_id`+ 浏览器打开 human 审批页面
   - human 同意后返回 `client_id`+`client_secret`
   - agent 自动后续 OAuth
4. **6 端点覆盖**全场景（搜/抓/爬/交互/监控/侦察）——这种"覆盖范围广"让客户不会叛逃

### §3.2 Tavily — Agent 的搜索 + research layer

| 指标 | 数据 | 出处 |
|------|------|------|
| Series A | $25M | 2024-12 |
| 开发者 | 2M+ | tavily.com |
| 月度请求 | 300M+ | 同上 |
| Uptime SLA | 99.99% | 同上 |
| P50 延迟 | 180ms | 同上 |
| 端点 | search / extract / crawl / **research** | 同上 |
| 客户 | Databricks (MCP Marketplace) · IBM (WatsonX) · JetBrains | 同上 |
| Privacy | 内置 PII 防护（自动屏蔽 email） | 同上 |
| 团队 | "Built by researchers" | 同上 |

**Tavily 的关键决策**：
- **首个 `/research` 端点**（不是 search，是 research）—— 玩家级别 = 整段报告
- **"Web access layer for AI agents"**——他们定义 agent → web 的"访问层"是 infra
- 在 OpenAI / Anthropic / Groq 的 SDK 全集成
- **SimpleQA benchmark SOTA retrieval**——主动做 benchmark 坐实地位
- **即将加入 Nebius**（欧洲数据中心）

**Tavily vs Firecrawl 关键差别**：
- Firecrawl = "scraped data → LLM friendly markdown"（重转换）
- Tavily = "natural research" (搜 + 总结 + 信源追溯)（重搜索）

### §3.3 Apify — Scraping 的"App Store"

| 指标 | 数据 | 出处 |
|------|------|------|
| GitHub Crawlee | ⭐24k | 2026-07 |
| Actors 数量 | **52,856** 个公开 actor | apify.com |
| 头部 Actor | Google Maps Scraper ⭐1.6k · 509K runs | 同上 |
| Discord | 15K+ 开发者 | 同上 |
| 商业模式 | 4 tier：Free $0/$5 · Starter $29 · Scale $199 · Business $999 | apify.com/pricing |
| Creators | 月度净收益分账 + 帮开发票/报税 | 同上 |
| 信任客户 | **Intercom Fin** 28M+ AI chats · **EU Commission** 800+ retailers · Groupon | 同上 |
| MCP | Claude MCP Connectors 完全集成 | 同上 |
| 协议 | x402 live（付费 scraping API） | 同上 |

**Apify 的关键决策**（这是范式洞察）：
1. **"Actors = 移动应用"**：每个 actor 就是一个独立的 scraper
2. **Marketplace + Revenue Share**：开发 actor 上架 → 别人用 → Apify 抽成
3. **52,856 个 actor = iOS App Store for scraping**：长尾覆盖（Google Maps、TikTok、Instagram、Facebook、Twitter、LinkedIn、Amazon、Booking 全部覆盖）
4. **客户用 AI agent 自己去找 actor**——agent 已经在用 Apify Store 当工具市场

**Apify vs Firecrawl 战略差别**：
- Apify = "store + platform"（iOS App Store 模式）
- Firecrawl = "API + SaaS engine"（engine 模式）
- 模式无法互相替代——这是为什么**两个都活**的原因

---

## §4 Deep Research Agent 玩家（新出现的"整段研究"垂直）

### §4.1 大厂官方级

| 产品 | 厂商 | 时间 | 关键能力 |
|------|------|------|---------|
| Gemini Deep Research | Google | 2024-12 首发，2026-04 接 MCP | 接 Gmail / Drive / Docs / Chat / **MCP 私有数据** |
| OpenAI Deep Research | OpenAI | 2025-02 | 大模型驱动 agents 多步骤研究 |
| Perplexity Pro Search / Sonar | Perplexity | 2025-01（Sonar API）| Perplexity + DeepSeek R1 推理 |
| 微信 "元宝" Deep Research | 腾讯 | 2025-12 测试 | 接微信生态 |

### §4.2 开源 deep research 军备竞赛

| Repo | ⭐ | 厂商 |
|------|----|------|
| [Alibaba-NLP/DeepResearch](https://github.com/Alibaba-NLP/DeepResearch) | **19,655** | 阿里通义实验室 |
| [langchain-ai/open_deep_research](https://github.com/langchain-ai/open_deep_research) | 12k | LangChain |
| [nickscamara/open-deep-research](https://github.com/nickscamara/open-deep-research) | 6,271 | 个人 |
| [SkyworkAI/DeepResearchAgent](https://github.com/SkyworkAI/DeepResearchAgent) | 3,491 | 字节 Skywork |
| [btahir/open-deep-research](https://github.com/btahir/open-deep-research) | n/a | Show HN 焦点 |
| [MODSetter/SurfSense](https://github.com/MODSetter/SurfSense) | 15,256 | 个人（NotebookLM for CI） |
| [firecrawl/web-agent](https://github.com/firecrawl/web-agent) | 1,128 | Firecrawl 自己 |

**关键观察**：
- **Alibaba Tongyi DeepResearch 19.7k stars** = 大厂 + 开源 + 2025-09 仍是第一——**国产 deep research agent 的代表**
- **字节 Skywork 3.5k** 跟进——大厂 2025-2026 集体下场
- **LangChain open_deep_research 12k** = 框架派的 framework — 出教程
- **个人项目仍能追平大厂** —— 比 Minis 过去调研里大多数 AI 工具都更"大厂 + 个人"格局混乱

### §4.3 Deep Research 的痛点（重要）

| 痛点 | 数据 | 出处 |
|------|------|------|
| **成本爆炸** | 一段研究 $5-50 | 多方报道 |
| **Token 失控** | 一个 Wikipedia 页 68k tokens | HN 14p/7c, 2026-07-11 |
| **投毒风险** | Deep-Research Agents Can Be Poisoned via User-Generated Content | HN 3p, 2026-06-15 |
| **容易放弃任务** | Building Deep Research Agent That Survives Its Own Failures | HN 2p, 2026-06 |
| **Benchmark 缺失** | BrowseComp-Plus 改 benchmark | HN 2p, 2026-06-05 |

> **设计含义**：这个赛道 2025-09 到 2026-07 飞速发展，**安全 + 成本 + 稳定性都还没收敛**—— 这是为什么 Tavily / Firecrawl 这种"在 LLM 和网络之间的中间层"是核心机会。

---

## §5 海外商业 SaaS 全景表（含未被算法"重赏"的厂商）

### §5.1 头部 LLM 友好厂商

| 厂商 | 产品 | 1 行定位 | 客户 |
|------|------|---------|------|
| **Firecrawl** | Scrape/Search/Crawl/Interact | YC, 150k+ 客户 | nubank/mozilla/mercado |
| **Tavily** | Search/Extract/Crawl/Research | $25M A 轮 · 2M devs · 300M req/mo | Databricks/IBM/JetBrains |
| **Apify** | Marketplace of 52k actors | "iOS App Store for scraping" | Intercom/EU Commission |
| **Exa** | Search API for AI | neural search | YC + AI 圈 |
| **Browserbase** | Headless browser infra | Stagehand 出品 | YC |
| **Hyperbrowser** | Browser infra for AI | SaaS | YC W24 |
| **Tabstack** | Browser infra for AI (Mozilla) | Mozilla 出品 | Mozilla |
| **Skyvern** | AI browser workflow | CAPTCHA/2FA 自带 · 500+ 企业 | CarEdge/Valence/Legion |
| **Bright Data** | Scraping proxy + API | "data on demand" (以色列) | Fortune 500 |
| **Oxylabs** | AI Studio + Next-gen residential proxy | 老牌 + AI Studio | Fortune 500 |
| **ScrapingBee** | Web Scraping API | 起步便宜 | 中小企业 |
| **Zyte** | Scrapinghub + AI Extraction | 老牌 · AI 自动化 | Fortune 500 |
| **Diffbot** | Knowledge Graph + Extract | 早期 NLP scraping | Fortune 500 |

### §5.2 Rust / 自家 headless browser

| 项目 | 语言 | 关键 |
|------|------|------|
| Spider-rs | Rust | Get web data for AI agents |
| Lightpanda | Zig | Headless browser in Zig, 5 stars |
| obscura | Rust | V8 powered, 17MB idle |
| vercel-labs/agent-browser | Rust | Browser automation CLI |

### §5.3 数据量提示：每家都"开源 + 商业"双轨

| 商业 SaaS 开源部分 | License | 是否必须开源自部署 |
|-------------------|---------|-------------------|
| Firecrawl | AGPL-3.0 | ✅ 必须开源修改 |
| Browser-Use | AGPL-3.0 | ✅ |
| Crawl4AI | Apache + 商业 | ❌ |
| Stagehand | MIT | ❌ |
| Skyvern | AGPL-3.0 | ✅ |

**→ 反 SaaS 策略**成为赛道标准。

---

## §6 中国市场全景（按用户量/资本量）

### §6.1 头部两家——To B + 通用 RPA

#### §6.1.1 **八爪鱼 Bazhuayu**（深圳数阔信息技术）

| 指标 | 数据 |
|------|------|
| 用户 | **450 万+ 用户** |
| 客户 | 10K+ 品牌 / 国央企 |
| 服务年份 | 13 年（2013-2026） |
| 云服务器 | 5000 台 · 7×24 |
| 日均采集 | 10 亿+ 条数据 |
| 创始人 | 创始人：江海（音） |
| 公司 | 深圳数阔信息技术有限公司，地址深圳宝安区 |

**4 个核心能力**：
1. 0 代码可视化
2. 300+ 网站模板
3. 智能采集（多种 AI 算法 + 自动化操作）
4. 自定义采集（覆盖 99% 网站）

**关键 AI 进化**：
- **"八爪鱼 MCP 上线"** — 增强了 Agent 采集能力（cursor/claude code 可直连八爪鱼）
- **"八爪鱼 RPA AI 写流程 3.0"** — 动态流程生成 Agent
- "RPA + AI 内容工厂"—— 内容生产范式

**行业应用**：新闻传媒、电商、社交媒体、招投标、产态势、舆情监控、市场研究

**含义**：八爪鱼 = 中国的 "Apify + Skyvern" + 大众 RPA + ChatBot = 一站式 To B 数据 + AI 自动化引擎

#### §6.1.2 **影刀 RPA**（杭州分叉智能）

| 指标 | 数据 |
|------|------|
| 企业 | 3 万+ 家企业员工用 |
| 自动化场景 | 1000+ |
| 高校合作 | 200+（北大、复旦、同济） |
| 员工说明 | "研发费用 1 亿+ 每年 · 300+ 版本迭代" |
| 创始人 | 10 年+ 研发经验（CEO 侯汉锋） |

**关键能力**：
- **"影刀 AI"** — 对话式生成自动化流程（很像 Manus / Claude Code 风格）
- 行业: 电商、医疗、跨境、金融、零售、制造
- 100% 工作 → 20% 人工 / 80% 机器

**含义**：影刀 = "中国版 Skyvern" + 大众 RPA——核心打法是**让没有 coding 能力的企业员工也能自动化**

#### §6.1.3 后羿采集器、简数科技、火车头、老表工具等
- 都是 To B / 工具类，没拿到具体规模
- 火车头最老（2008+），后羿/简数 2015-2018 后
- 这一类"采集工具"在中国 = 8-15 年历史，是大众化的 App / 桌面软件

### §6.2 中国大厂入局（2025-2026 起）

| 大厂 | 产品 | 时间 |
|------|------|------|
| 阿里 | 通义 DeepResearch 开源（⭐19.7k） | 2025-09 |
| 字节 | Skywork DeepResearchAgent（⭐3.5k） | 2025 |
| 百度 | 文心 ERNIE 接入 Internet 检索 | 2025-08 |
| 腾讯 | 微信"元宝"接入 Deep Research | 2025-12 |
| 智谱 | ChatGLM Research | 2025 |

### §6.3 中国 AI 浏览器

| App | iOS 评分/评论 | 公司 |
|-----|------------|------|
| Perplexity | 4.83★/485,895r | Perplexity (US) |
| Manus | 4.74★/35,015r | Butterfly Effect (中国) |
| Comet (Perplexity) | 4.75★/7,696r | Perplexity (US) |
| You.com | 4.75★/4,869r | You.com (US) |
| Goover: AI Research Agent | 4.54★/13r | 新兴 |

**关键观察**：
- **Perplexity 485K 评论是 Comet 7K 评论的 60 倍** —— 大众 AI 搜索仍集中
- **Manus 35K** = 中国一号标杆 AI agent app
- **没有中国版的"专门信息获取 agent" iOS app** —— 中国做 To C 信息 agent 的空间仍是空白

---

## §7 技术架构图——四层能力栈

```
┌───────────────────────────────────────────────────────────────┐
│ Layer 4  · 垂直应用                                            │
│   Deep Research | E-commerce Aggregation | CRM Enrichment     │
│   Spec Mining | Competitive Intelligence | News Monitoring    │
├───────────────────────────────────────────────────────────────┤
│ Layer 3  · 智能中间层                                          │
│   - Tavily /research (deep agent)                             │
│   - Firecrawl/batch & token-saving                            │
│   - Apify Actor store                                         │
│   - WebBridge (record website → MCP tools)                    │
├───────────────────────────────────────────────────────────────┤
│ Layer 2  · 多模态浏览器自动化                                   │
│   - Browser-Use (LLM Playwright)                              │
│   - Stagehand (browserbase)                                   │
│   - Skyvern (LLM + Vision)                                    │
│   - vercel agent-browser (Rust)                               │
│   - Skyvern-Style 通用 Playwright SDK                         │
├───────────────────────────────────────────────────────────────┤
│ Layer 1  · 底层 headless browser / HTTP                        │
│   Playwright · Puppeteer · Selenium · Cycurl                 │
│   Hide My WP · stealth browser fingerprint                     │
│   obscura (17MB idle) · Lightpanda (Zig) · Tabstack          │
│   Chromium · Firefox · WebKit                                 │
│   HTTP / proxies / captcha solver                             │
├───────────────────────────────────────────────────────────────┤
│ Layer 0  · Network / DNS / Captcha Pool                       │
│   Bright Data · Smartproxy · IP Proxy Pool                     │
│   2captcha / anti-captcha services                             │
└───────────────────────────────────────────────────────────────┘
```

**含义**：卖钱的地方在 Layer 3（智能中间层）+ Layer 4（应用层）。Layer 1/2/0 都是要被绕开的"基础设施"。Firecrawl / Tavily 都在 Layer 3。

---

## §8 MCP — 把"网页→MCP tool"是 2026 核心新范式

**MCP 让"网站"成为 agent tool**——而不是"agent 自己用浏览器"。

### §8.1 三个标志性事件

1. **Google Gemini Deep Research 接 MCP（2026-04-22）** — `Google Gemini Deep Research Agents Now Search Both Web and Private Data via MCP`
2. **Apify Actor 全接 Claude MCP Connectors（2025-2026）** — agent 直接调 Apify Store
3. **WebBridge** — Show HN 2026-03-06，**turns any website into MCP tools by recording browser traffic** —— 这个产品最关键，是"LLM 反过来用 browser data"

### §8.2 MCP 模式演示（Firecrawl SKILL.md 风）

```yaml
# agent 调用 Firecrawl 流程
1. 用户 → agent: "调研 Claude 4.5 价格"
2. agent 发现需要 web search tool → 找 SKILL.md（firecrawl 提供了）→ 拿 API key
3. POST https://api.firecrawl.dev/v1/scrape
   {
     "url": "https://anthropic.com/pricing",
     "formats": ["markdown", "summary"],
     "timeout": 10000
   }
4. 返回 clean markdown + summary + meta
5. agent 写报告
```

> **关键反差**：Firecrawl / Tavily 已经把**整套流程标准化**——agent 不需要写 scraper 逻辑，只需要知道"用哪家 API"。这就是为什么 2026 年 Scraping → 标准化服务。

---

## §9 关键痛点（HN Algolia 提取）

### §9.1 性能 / 成本

| 痛点 | 来源 |
|------|------|
| **GPT-4o scraping is powerful but expensive** | HN 377p/167c, 2024-09 |
| **One Wikipedia page costs your AI agent 68,000 tokens** | HN 14p/7c, 2026-07-11 |
| **Deep Research 成本 $5-50 per run** | 多方报道 |

### §9.2 反爬持续升级

| 痛点 | 来源 |
|------|------|
| **Cloudflare rolls out feature for blocking AI companies' web scrapers** | HN 15p/4c |
| **Miasma: 防 scraper 工具** | HN 346p/247c, 2026-03 |
| **Cloud-based agents for web scraping...** | HN 13p/1c, 2019 (即 7 年前已有) |

### §9.3 真实失败模式

| 痛点 | 来源 |
|------|------|
| **Deep-Research Agents Can Be Poisoned via User-Generated Content** | HN 3p, 2026-06-15 |
| **Building Deep Research Agent That Survives Its Own Failures** | HN 2p, 2026-06 |
| **AI browser assistant extensions probably beaming everything to the cloud** | HN 10p/1c, 2025-03-25 |
| **Because Webfetch Sucks** | HN 2p/2c, 2026-04-23 |

### §9.4 Show HN 仍在密集发布

即便 Firecrawl 151k stars，2026-2027 仍有：
- Souko.ai (2025-07) - Web scraping, search and extraction APIs for AI workflows
- Flowqy (2025-03) - AI-Powered Web Scraper, No Coding Needed
- Potarix (2024-12) - AI-Powered Web Scraping and Data Extraction
- Ricci Flow (2026-04-18) - AI Web Scraper
- Spidra (2026-03-03) - AI web scraper that adapts to any website
- AutomatiQ (2026-06-17) - Reverse-Engineering Agent for the Web
- Motie (2025-12-17) - Replit for Web Scraping
- obscura (2026-05) - headless browser for AI agents and web scraping
- Enact (2025-12-30) - A package manager for AI agent tools
- Universal MCP gateway (2025-10) - for AI agents
- Almanac MCP (2026-04-21) - turn Claude Code into a Deep Research agent
- Ember (2026-07-09) - Lightweight headless browser (17MB idle)
- WebBridge (2026-03-06) - record → MCP tools

> **含义**：竞争激烈 + 新概念不断。但**Show HN 头部已被开源 star 收购** —— 长期沉淀的是 Firecrawl / Browser-Use 这种有"完整公司 + 产品"的玩家，不是单次 Show HN 玩具。

---

## §10 5 个关键反直觉洞察（给创业者 / 产品经理）

### §10.1 真正的护城河是"反反爬 + 反投毒"—— 不是 "AI 更聪明"

很多人以为 deep research 赛道=拼 LLM 智能，但其实**真正的护城河是反反爬**：Cloudflare 5 秒盾 / IP 黑名单 / Canvas 指纹识别 / Captcha 解析能力。整个赛道卷到**做普通生意**，先活下来的不是大模型，是 scraper-as-a-service。

### §10.2 WebBridge 类产品是新范式 —— 把"反爬"变成"用户共建"

WebBridge 的关键洞见：**用爬虫 → 卖 MCP tools**——把反爬转成"内容贡献"。这跟 Apify marketplace 思路一致——"用户贡献 actor → 别人用"。

### §10.3 "AGPL 3.0 反 SaaS" 已是赛道默认策略

Firecrawl / Browser-Use / Crawl4AI / Skyvern 都是 AGPL——**自部署→必须开源**。这是个意外但清晰的信号：**SaaS 部分才是钱**。开源是营销模式，商业是 SaaS 订阅。

### §10.4 国产已经有两家年化百亿级样本，但开源革命还没来

八爪鱼 450 万用户 + 影刀 3 万企业——远比海外 SaaS 大客户更"地推"。**但这两家都没开源**——这是为什么国产 deep research agent 开源军备竞赛（阿里 19k / 字节 3.5k）仍是空白。

### §10.5 浏览器 agent 比 scraper 更有"长期"价值

- Firecrawl = "我给你 cleaned data, 让 LLM 处理"
- Browser-Use = "我给你整台 browser, 让 LLM 行动"

后者**是"行动 agent"，而前者是"信息 agent"**。Manus / Devin / Skyvern 都在做"行动 agent"。**这是为什么 2025-2026 真正资本聚焦点是 browser agent 类别，而不是纯 scraper。**

---

## §11 给"想进来"的话 + 待挖

### §11.1 还想挖但没挖的（按 ROI 排）

1. **Apify 头部 50 个 actor 的具体功能分布**（现在只知道头部几个）
2. **Firecrawl / Tavily 真实 ARR / 客户数**（只有"150k+ companies"这种模糊数据）
3. **Skyvern 500+ 企业客户的具体厂商名单**（汽车、保险、SaaS、Hiring 哪些领域）
4. **WebBridge 的 record + 翻译算法**（show HN 没拿到核心技术细节）
5. **国内开源 deep research 军备竞赛**（阿里 vs 字节 vs 智谱 vs 百度）
6. **Perplexity Sonar 实际收入**（仅知 API 2025-01 推出）
7. **AI agent 投毒研究 + benchmark**（BrowseComp-Plus 等）
8. **智能合同 / 财经 / 医疗深垂领域**（垂直 scraper）

### §11.2 还可以深读

| 主题 | 推荐资料 |
|------|---------|
| 入门 | firecrawl.dev / tavily.com / apify.com 首页各 30 分钟 |
| 进阶 | Perplexity Sonar 文档 + Google Deep Research 白皮书 |
| 战略 | "Less is Safer" (Obsidian Licat) 类哲学——思考为何 scraper 都选 AGPL |
| 投毒 | BrowseComp-Plus benchmark |
| 商业 | "Building a Deep Research Agent That Survives Its Own Failures" 等 Show HN 评论 |

---

## §12 引用源

- [firecrawl/firecrawl](https://github.com/firecrawl/firecrawl) — ⭐151k YC SaaS 开源爬虫
- [browser-use/browser-use](https://github.com/browser-use/browser-use) — ⭐104k 开源浏览器 agent
- [unclecode/crawl4ai](https://github.com/unclecode/crawl4ai) — ⭐72k LLM 友好爬虫
- [apify/crawlee](https://github.com/apify/crawlee) — ⭐24k 通用爬虫框架
- [browserbase/stagehand](https://github.com/browserbase/stagehand) — ⭐23k 浏览器自动化
- [Skyvern-AI/skyvern](https://github.com/Skyvern-AI/skyvern) — ⭐22k CAPTCHA/2FA 自动化
- [ChromeDevTools/chrome-devtools-mcp](https://github.com/ChromeDevTools/chrome-devtools-mcp) — ⭐47k
- [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser) — ⭐38k Vercel 浏览器 CLI
- [Alibaba-NLP/DeepResearch](https://github.com/Alibaba-NLP/DeepResearch) — ⭐19.7k 阿里通义
- [langchain-ai/open_deep_research](https://github.com/langchain-ai/open_deep_research) — ⭐12k
- [MODSetter/SurfSense](https://github.com/MODSetter/SurfSense) — ⭐15k 笔记本式 CI
- [Show HN: Souko.ai - Web scraping, search and extraction APIs for AI workflows](https://news.ycombinator.com/item?id=44709329)
- [Show HN: obscura — Rust headless browser for AI agents](https://github.com/H4ckf0r0day/obscura)
- [Show HN: WebBridge — turns any website into MCP tools](https://news.ycombinator.com/item?id=46977258)
- [Google Gemini Deep Research Agents Now Search Both Web and Private Data via MCP](https://news.ycombinator.com/item?id=47194456)
- [One Wikipedia page costs your AI agent 68,000 tokens](https://news.ycombinator.com/item?id=47836500)
- [Building Deep Research Agent That Survives Its Own Failures](https://news.ycombinator.com/item?id=47458923)
- [BrowseComp-Plus](https://news.ycombinator.com/item?id=47398012)
- [apify.com](https://apify.com/) / [apify.com/pricing](https://apify.com/pricing)
- [tavily.com](https://www.tavily.com/)
- [exa.ai](https://exa.ai/)
- [firecrawl.dev](https://firecrawl.dev/)
- [skyvern.com](https://www.skyvern.com/)
- [octoparse.com](https://www.octoparse.com/) / [bazhuayu.com](https://www.bazhuayu.com/)
- [yingdao.com](https://www.yingdao.com/) 影刀 RPA
- [iTunes Search for "AI research assistant"](https://itunes.apple.com/search?term=AI+research+assistant)
- HN Algolia search: `web scraping agent` · `AI research` · `deep research` · `headless browser ai` · `MCP web fetch` · `Perplexity Sonar`
