---
layout: post
title: "Harness Engineering for Self-Improvement / Harness 工程与递归自我改进"
tags: [ai-agents]
---
> 作者：Lilian Weng（前 OpenAI 安全研究负责人，Lil'Log 作者） · 2026-07-04 · [原文](https://lilianweng.github.io/posts/2026-07-04-harness/) · 28 min read · 35 refs

> **TL;DR** — 把 RSI（recursive self-improvement）的近期路径锁定在 **harness** 而非模型权重。优化对象沿 `prompts → structured context → workflow → harness code → optimizer code` 演进；当前的前沿已经走到让 harness **自己改 harness**（Self-Harness / Meta-Harness / Darwin Gödel Machine）。七大未解挑战里最尖锐的是：**evaluator 和 permission control 必须坐在自我改进 loop 的外面**。

---

## 1. RSI 与 Harness 的定位

RSI 概念追溯到 I. J. Good (1965) 的"ultraintelligent machine"，Yudkowsky (2008) 把它明确为反馈循环：AI 用自己当前的智能改进"产生智能的认知机器"。

Lilian 的关键判断：**RSI 的近期路径不会从模型改自己的权重开始**，而是从改进 deployment system（即 harness）开始——Claude Code / Codex 已经证明了 harness 的杠杆。

> A **harness** is the system surrounding a base model that orchestrates execution and decides how the model thinks and plans, calls tools and acts, perceives and manages context, stores artifacts, and evaluates results.

类比操作系统：harness 应该**封装复杂逻辑，保持接口简洁**；configs、tool interfaces、protocols 会逐渐跨厂商标准化。

---

## 2. Harness 的三个设计 Pattern（Lilian 原创 taxonomy）

| Pattern | 核心 | 反例 |
|---|---|---|
| **1. Workflow Automation** | 模型在一个 goal-oriented loop 里 operate / test / iterate（plan → execute → observe → improve） | 把 workflow 全塞进静态 prompt 模板 |
| **2. File System as Persistent Memory** | durable state 落文件，harness 不该把 workflow + logs 全装 context | context window 当无限大用 |
| **3. Sub-agent + Backend Jobs** | 主 agent 当 process manager，并行跑假设/实验；**并行要 explicit + inspectable** | subagent 输出只在 transient chat 里 |

### Coding Agent Harness 工具表（Claude Code / Codex / OpenCode / Cursor 已收敛）

| 分组 | 工具 |
|---|---|
| File system | `glob` `grep` `ls` / `read` `read_many` / `write` `edit` `multi_edit` `apply_patch` |
| Shell | `bash` `PowerShell` |
| IO | `lsp` `git_status` `git_diff` `git_commit` |
| External context | MCP tools, **Skills** |
| Web search | `web_search` `web_fetch` browser tools |
| Artifacts | read docs/images, generate HTML/images |
| Backend processes | `CronCreate` `CronDelete` `CronList` |
| Agent delegation | `spawn_agent` `resume_agent` `wait_agent` `list_agents` `close_agent` `interrupt_agent` |

> 这张表是 Lilian 文章的实证贡献：四家主流 coding agent 的接口已经稳定下来，新工具不会再大幅扩张。

---

## 3. Harness Layer vs Core Intelligence？（核心预测）

Lilian 的中期预测：

1. **Harness 朝 meta-methodology 进化**——优化"得到更好答案的机器"本身，而不是答案本身
2. 成熟的 harness 启动 **auto-research 自我改进循环**；反过来更强的模型防止 harness 过度工程化
3. 长期看很多 harness 改进会**内化进模型核心行为**，但**与外部 context + 工具的接口会保留**
4. 类比 prompt engineering：随着 instruction tuning / reasoning 变强，手动 prompt trick 不再核心；但**指定目标、约束、context、evaluation 这四件事不会消失**

> *Context engineering will and should become a core part of intelligence, rather than staying in the software system layer.* —— 最激进的一句

---

## 4. 优化对象的五层演进（Lilian 文章的骨架）

```
prompts → structured context → workflow → harness code → optimizer code
   ↑             ↑                ↑              ↑                ↑
 静态提示    ACE/MCE           ADAS/AFlow    Meta-Harness    Self-Harness/DGM
```

每层代表工作（重点放 Lilian 文章独有的整理）：

### Context Engineering
- **ACE** (ICLR'26) — context 当 **evolving playbook**，三件套 Generator / Reflector / Curator；增量条目化（避免 context collapse + brevity bias）
- **MCE** (Ye et al. 2026) — 双层：外层演化 **skill**，内层优化 context；skill = (静态 ρ, 动态算子 F)；bi-level optimization
- **Meta-Harness** (Lee et al. 2026) — 优化**优化 harness 的 harness**；proposer 是 coding agent；产出 Pareto frontier；所有历史落文件系统

### Workflow Design
- **AI Scientist** (Lu et al. 2026, Nature) — idea → code → experiment → analyze → paper → peer review 完整 pipeline
- **ScientistOne** (Meng et al. 2026) — **Chain-of-Evidence** 审计每个声明（citation / numerical / methodological / conclusion）
- **Autodata** (Kulikov et al. 2026) — challenger / weak solver / strong solver / verifier，合成"刚刚好难度"的数据；但只能训弱模型，**不算真 RSI**
- **ADAS** (Hu et al. 2025) — meta-agent search，agent 设计本身当搜索问题
- **AFlow** (Zhang et al. 2025) — workflow = 图（节点=LLM 调用，边=逻辑操作）；**MCTS 搜**

### Self-Improving Harness（文章核心）
- **STOP** (Zelikman et al. 2023) — 递归优化 **improver 函数本身** `I_t = I_{t-1}(û, I_{t-1}; M)`
- **Self-Harness** (Zhang et al. 2026) — 三阶段 loop：**weakness mining → bounded proposal → validation**；在 Terminal-Bench-2 上学到 model-specific harness instructions
- **SIA** (Hebbar et al. 2026) — Meta-Agent / Task Agent / Feedback-Agent；feedback 决定下一步改 harness 还是改权重

> ⚠️ **STOP 的警示**：GPT-4 改善、GPT-3.5 / Mixtral 反而退化 → **递归结构本身不够，底层智能必须够强**。Lilian 强调：**harness 改进 enable 模型部署，但智能仍是核心**。

### Evolutionary Search
- **Promptbreeder** (2023) / **GEPA** (2025) / **AlphaEvolve** (2025) — 早期 prompt 进化
- **ShinkaEvolve** (2025) — sample-efficient exploration + code-novelty rejection sampling + meta-scratchpad
- **DGM** (Darwin Gödel Machine, 2025) — coding agent **改自己的 harness codebase**；SWE-bench 20%→50%、Polyglot 14.2%→30.7%
- **Hyperagents** (2026) — meta-agent 控制如何改 task agents

---

## 5. 七大未解挑战（最值得记的部分）

| # | 挑战 | 一句话 |
|---|---|---|
| 1 | **弱/模糊的评估器** | 研究品味、novelty、长期科学价值难量化；当前 self-improvement 只能跑在评估客观的任务上 |
| 2 | **Context + memory 生命周期** | Memory 越长越需要管理；**context engineering 应成为 intelligence 的一部分** |
| 3 | **负面结果** | 文献偏成功，LLM 不擅长承认失败、放弃假设 |
| 4 | **多样性坍缩** | 进化/RL 趋向 exploit 已知高奖励；开放研究里"最优路径"在当前 evaluator 下可能反而显得差 |
| 5 | **Reward hacking** | Evaluator + permission 控制必须**坐在 loop 外**（held-out tests + trace audit + human review） |
| 6 | **长期成功** | RLVR 训练 sandbox 看不到 maintainability / 迁移成本 / 向后兼容 |
| 7 | **人类的位置** | 人类应该往 stack 上走，不能被反过来替代 |

Trehan & Chopra (2026) 实验总结的六大失败模式（与挑战对应）：
1. **Bias toward training-data defaults**（用老库 / stale commands / 默认假设）
2. **Implementation drift**（实现变难时退回到更简单的常见方案）
3. **Memory + context degradation**（长程任务丢关键细节）
4. **Over-optimism**（实验失败/嘈杂却宣布成功 = "p-hacking and eureka-ing"）
5. **Insufficient domain intelligence**（缺 tacit craft）
6. **Weak scientific taste**（实验可跑但答错问题）

---

## 6. 关键金句

> *A harness is the system surrounding a base model that orchestrates execution and decides how the model thinks and plans, calls tools and acts, perceives and manages context, stores artifacts, and evaluates results.*

> *Harness engineering will evolve in the direction of **meta-methodology** (i.e. improving the machinery for getting better answers, not just improving the answer itself).*

> *Once harness design becomes an executable search space, a strong coding agent can exploit the same design space human engineers use.* —— Meta-Harness 结论

> *Recursive structure alone is not enough. The base model must be capable enough to improve the mechanism.* —— STOP 警示

> *Context engineering will and should become a core part of intelligence, rather than staying in the software system layer.*

> *The evaluator and permission control should likely sit outside the loop that evolves harness.*

---

## 7. 我的点评

### 跟 Loop-Engineering 的关系
- Addy 的 Loop Engineering 讲 **怎么写 loop**（具体实践 / 范式）
- Lilian 文章讲 **为什么需要 harness + harness 的设计原理 + 当前研究前沿**
- 两者是同一波浪潮的**应用层 vs 理论层**

### 跟 Fable-Field-Guide 的关系
- Thariq 讲 unknowns → Claude Fable 自己处理
- Lilian 文章直接对应："evaluator + permission control 在 loop 外"是 Fable "Blind Spot Pass" prompt 的理论化

### 跟 vault 里其他笔记的关联
- **rari 30 件事 #22 Skills / #23 Vault Memory**：直接对应 ACE/MCE 的 skill + Pattern 2 (File System as Persistent Memory)
- **`/var/minis/skills/`（Minis skill 系统）**：同构 MCE 的 `skill.md` 双层（meta-skill + context）
- **RedSkill 风险评估**：Lilian 文章给了更系统的理论支撑——"**程序改自己的 OS 抽象边界就破了**"，evaluator 必须 loop 外

### 三个我立刻能用的洞察
1. **写 skill 时参考 ACE 的三件套结构**：Generator（执行轨迹）→ Reflector（成功/失败洞察）→ Curator（增量条目合并）。比"每次重写整段 prompt"更稳。
2. **长程任务把 logs 落文件系统**（Pattern 2）：每天 daily log 已经做了，但要明确这是 MCE 的 `c_{k-1}^*` 角色。
3. **下次写 self-improving skill 时**，要预先设计好"哪些面可改、哪些面被锁"——evaluator 不能跟 loop 一起改，否则 reward hacking 立刻发生。

### 留待观察
- Meta-Harness / Self-Harness / DGM 在 coding 之外（web / research / data）能不能 work？
- Lilian 预测"harness 改进会被内化进模型核心行为"——OpenAI / Anthropic 的下一代模型会不会真把 harness 技巧 internalize？
- "context engineering 是 intelligence 的一部分"——这条最激进，需要下一代模型架构证据

---

## 8. Vault 关联

### 同主题双链
- Loop-Engineering — 同一波浪潮的"应用层"（Addy Osmani 2026-06-07）
- Fable-Field-Guide — 同源思想（"地图不是疆域" + Blind Spot Pass prompt）

### 反向链接
- _index — 个人笔记区入口
- MOC — 全局 Map of Content

### 相关 tags
- `#harness-engineering` — 主标签（与 Loop-Engineering 共享）
- `#context-engineering` — 衍生标签
- `#self-improvement` — RSI 主题
