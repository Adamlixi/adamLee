---
layout: post
title: "Harness Engineering for Self-Improvement — Deep Dive / Harness 工程与递归自我改进 — 深度讲解笔记"
tags: [ai-agents]
---
> **与精简版的关系**：本笔记是 Harness-Engineering-for-Self-Improvement 的深度讲解版本。精简版是文章摘要 + 文章独有的部分；本笔记保留详细机制、原始 abstract 提炼、benchmark 完整数字、3 个 anchor 的 Python 伪例与原始论文 abstract、对话中的类比（马具 / 厨师 / 餐厅）。
>
> 来源：[Lilian Weng 原文](https://lilianweng.github.io/posts/2026-07-04-harness/)（2026-07-04，28 min read，35 refs）

---

## 1. 文章定位 + 核心论点

### 1.1 文章在做什么

Lilian Weng（前 OpenAI 安全研究负责人）把 **RSI（recursive self-improvement，递归自我改进）** 的**近期路径锁定在 harness**，系统梳理 harness engineering 这一波研究浪潮（35 篇 ref）。

### 1.2 核心论点（一句话）

> **改模型权重是 RSI 的远期路径；改 harness 是 RSI 的近期路径。Harness = 让模型能干活的整套配套（loop + tools + memory + permissions + evaluation）。改 harness 比改模型权重见效更快、风险更低、自动化空间更大。**

### 1.3 历史脉络

- **I. J. Good (1965)** —— 提出"ultraintelligent machine"概念：能超越人类所有智力活动的系统，并设计更好的机器改进自己
- **Yudkowsky (2008)** —— 明确"recursive self-improvement"为反馈循环：AI 用当前智能改进"产生智能的认知机器"
- **现代 AI** —— 这个循环可以是模型改自己的权重（远期），或模型改进 training pipeline + deployment system（近期）
- **Anthropic / OpenAI** —— 前沿实验室研究发展速度已经加速

### 1.4 Lilian 自己的定义（原文）

> A **harness** is the system surrounding a base model that orchestrates execution and decides how the model thinks and plans, calls tools and acts, perceives and manages context, stores artifacts, and evaluates results.

---

## 2. Harness 是什么（核心比喻 + 你已经见过的 harness）

### 2.1 马具比喻（最直觉）

```
harness = 马具（英文里 harness 本来就是"套在马身上让它能拉车的装备"）

马       =  base model（GPT-4 / Claude / Gemini 等模型权重）
马具     =  harness（loop + tools + memory + permissions + evaluation）
拉车     =  让模型在真实任务里产生价值
```

光有马（base model 权重）→ 它就是个聊天接口。装上马具 → 它能自己读文件、跑命令、记笔记、验证结果。

### 2.2 你已经见过的 harness（只是当时不知道名字）

| 系统 | 是什么 |
|---|---|
| **Claude Code / Codex / Cursor Agent** | 模型外面包的那整套（循环 + 工具 + sub-agent + 文件 memory） |
| **Karpathy 的 [autoresearch](https://github.com/karpathy/autoresearch)** | 一个超简 harness——一个 Python 循环脚本，让模型自己改自己 |
| **`/var/minis/skills/`** | 一种轻量级 harness（`SKILL.md` 当 ρ，动态触发当 F） |
| **Addy Osmani 的 Loop Engineering** | harness 的一种（带循环的 harness）；Lilian 文章把"harness"作为更上位概念展开 |

### 2.3 agent ≠ base model

```
agent = base model（模型权重）+ harness（让模型能干活的所有配套）

"改 agent" = 改的是 harness 部分，不是模型权重
"训练 agent" = 改的是模型权重（这是另一回事，不是 harness optimization 在讲的事）
```

3 个 anchor（ACE / Meta-Harness / DGM）**全程都不碰模型权重**——base model 固定不动，它们改的是 harness 部分。

---

## 3. 5 层演进对象（harness optimization 的骨架）

### 3.1 五层演进轴

```
Level 1  prompts           →  你手动写一段静态 prompt
Level 2  structured context →  prompt 里开始有结构（playbook / items / bullets）
Level 3  workflow          →  prompt 不够，要循环（plan→execute→observe→improve）
Level 4  harness code      →  循环也不够，要重写整个 harness（prompts+tools+memory+control flow）
Level 5  optimizer code    →  harness code 自己改 harness code
```

### 3.2 两条隐含规律

1. **优化对象越走越动态**：从静态 → playbook → 循环 → 程序 → 程序改程序
2. **人类设计的成分越来越少**：每往右走一步，"人写的部分"减少、"机器写的部分"增多

### 3.3 核心警示

> **递归结构本身不够，base model 必须够强**（来自 STOP 在 GPT-3.5 上退化的实证）

---

## 4. Harness Design Patterns（Lilian 原创 taxonomy）

### 4.1 总框架（原文）

> Compared with early agent frameworks, "agent = LLM + memory + tools + planning + action", harnesses engineering additionally include **workflow design (e.g. loop engineering)**, **evaluation**, **permission controls**, and **persistent state management**. It is no longer only prompt templates, but closer to **runtime and software system design**: how the model observes, acts, memorizes, checks itself, and improves.

**两个关键论断**：
1. **Harness ≠ 早期 agent framework**——多了 4 件事：workflow design / evaluation / permission controls / persistent state management
2. **Harness = runtime + 软件系统设计**——不再是 prompt 模板，是软件工程

### 4.2 两条设计原则（原文）

> - The design should be **deliberately simple and generic** to enable generalization, likely with reference to existing software engineering practices to benefit from pretraining knowledge.
> - There is also a strong analogy between operating systems and harnesses. Similar to an OS, a harness should encapsulate complicated logic while keeping the interface simple. Meanwhile, configs, tool interfaces and other protocols may gradually become standardized across the industry.

——harness = OS 类比：封装复杂逻辑、保持接口简洁。configs / tool interfaces / protocols 会**跨厂商逐渐标准化**。

---

### 4.3 Pattern 1: Workflow Automation

**核心**：定义一个 workflow，让模型在里面 operate / test / iterate。

**通用循环**（原文）：
> A common workflow follows a goal-oriented loop of **plan, execute, observe/test, improve**, and execute again until the goal is achieved.

**干净样板**：[Karpathy/autoresearch](https://github.com/karpathy/autoresearch)——一个 Python 循环脚本，让模型自己改自己。

**关键区别**（原文）：
> The workflow graph also emphasizes the model **analyzing its own trajectories and failure cases** and then iterating on its progress through an "**agent runtime**" rather than a static prompt template.

——区别于静态 prompt template：harness 强调"**agent runtime**"概念。

---

### 4.4 Pattern 2: File System as Persistent Memory

**核心**：harness 不该把所有 workflow + logs 装进 context；该把 durable state 落文件。

**原文**：
> A harness should not carry the entire workflow and all logs in context; instead, it should keep durable state in files. In long-horizon agentic rollout, artifacts such as **experiment logs, code diffs, paper summaries, error traces, and past rollout trajectories** often grow much longer than the context window that the model has trained for.

**关键洞察**（原文）：
> Learning how to read, write, and edit the file system (commonly via bash commands) is a **foundation skill for LLMs**, and thus managing persistent memory in the simple form of files **naturally benefits from improvements in core model capability**.

——file 当 memory **不需要专门优化**，因为 LLM 已经会读/写/编辑文件——所以这个 pattern 自动跟着 LLM 能力变强一起变强。

---

### 4.5 Pattern 3: Sub-agent and Backend Jobs ★ 详细

**核心问题**：为什么要 sub-agent？（原文）
> when the main agent needs to **search multiple hypotheses**, **run experiments concurrently**, or **delegate isolated subtasks** without polluting the main context.

**Parent agent 当 process manager**（4 个职责，原文）：
- launch jobs
- inspect logs
- cancel failed runs
- merge results back into the main agent thread

**架构图**：

```
                  ┌─→ Sub-agent 1 ──→ 写文件/log
                  │
Main Agent  ──────┼─→ Sub-agent 2 ──→ 写文件/log
(Process Manager) │
                  └─→ Sub-agent 3 ──→ 写文件/log
       │
       ├─ spawn_agent()    启动
       ├─ list_agents()    查看状态
       ├─ wait_agent()     同步
       ├─ inspect logs     检查输出
       ├─ interrupt_agent() 中断失败的
       ├─ close_agent()    关闭
       └─ merge results    从文件读回主线程
```

**关键设计选择**（原文）：
> The key design choice is to **make parallelism explicit and inspectable**.

**反例**（原文）：
> If subagent outputs only live in a transient chat context, they **quickly become obsolete and hidden**.

**正例**（原文）：
> If they are stored as **files, logs, and status records**, the model can **recover after interruptions** and **reason over its own execution history**.

——落 files / logs / status records → 两个好处：
1. **Interrupt 之后能恢复**
2. **能 reason over 自己的执行历史**

**Pattern 3 的 4 条硬约束**（基于原文）：
1. **必须能并行**（否则主 agent 串行干所有事）
2. **并行必须 explicit**（否则用户 / 主 agent 都看不见）
3. **并行必须 inspectable**（sub-agent 输出落文件，可查、可恢复）
4. **主 agent 必须能 cancel failed runs**（不是 fire-and-forget）

---

### 4.6 Case Study: Coding Agent Harness（完整工具表）

**关键观察**：Claude Code / Codex / OpenCode / Cursor **4 家厂商的工具集已经收敛**。

| 分组 | 工具 |
|---|---|
| **File system** | `glob` `grep` `ls`（discovery）；`read` `read_many`（read）；`write`（整文件）/ `edit`（精确字符串替换）/ `multi_edit` / `apply_patch`（结构化 patch/diff） |
| **Shell execution** | `bash`, `PowerShell` |
| **IO** | `lsp`, git tools（`git_status` `git_diff` `git_commit`） |
| **External context** | **MCP tools, Skills** |
| **Web search** | `web_search`, `web_fetch`, browser tools |
| **Artifacts** | Read docs, images; generate HTML, images |
| **Backend processes** | `CronCreate`, `CronDelete`, `CronList` |
| **Agent delegation** | `spawn_agent`, `resume_agent`, `wait_agent`, `list_agents`, `close_agent`, `interrupt_agent` |

Lilian 的注释（原文）：**Not a comprehensive list; shown for demonstration. Read this if interested.**

——这张表的实证意义：4 家主流厂商已经共享同一套工具集——支撑 Lilian"configs / tool interfaces / protocols 会跨厂商逐渐标准化"的预测。

---

## 5. Harness Layer vs Core Intelligence?（Lilian 的中期预测）

**问题**：未来 RSI 在多大程度上靠 harness engineering vs 改模型权重？

**Lilian 的判断**（原文）：
> It is hard to forecast how much the future of RSI will rely on harness engineering, but the near-term path of RSI is **unlikely to start as a model directly rewriting its weights**.

**中期预测**（原文，3 步）：

1. Harness 朝 **meta-methodology** 进化——优化"得到更好答案的机器"本身
2. 成熟 harness → 启动 **auto-research 自我改进循环**；更强的模型反过来防止 harness 过度工程化
3. 长期看很多 harness 改进会被**内化进模型核心行为**，但**与外部 context + 工具的接口会保留**

**类比 prompt engineering**（原文）：
> We have seen a softer version of this pattern with prompt engineering: **manual prompt tricks became less central as instruction tuning and model reasoning improved**, but the need to specify **goals, constraints, context, and evaluation** did not disappear.

——prompt engineering 已经被 instruction tuning / 推理能力变强而弱化；但**目标 / 约束 / context / 评估这四件事不会消失**。Harness engineering 会走同样的路。

---

## 6. Harness Optimization 详解（按 5 层展开）

### 6.1 Layer 2 — Context Engineering

#### ACE（Agentic Context Engineering, Zhang et al. 2025, ICLR'26, arXiv:2510.04618, 32 pages）

**Abstract 提炼**：
> Large language model (LLM) applications such as agents and domain-specific reasoning increasingly rely on **context adaptation**: modifying inputs with instructions, strategies, or evidence, rather than weight updates. Prior approaches improve usability but often suffer from **brevity bias**, which drops domain insights for concise summaries, and from **context collapse**, where iterative rewriting erodes details over time. We introduce ACE (Agentic Context Engineering), a framework that treats contexts as **evolving playbooks** that accumulate, refine, and organize strategies through a modular process of generation, reflection, and curation.

**关键数字**：

| Benchmark 类型 | 提升 | 备注 |
|---|---|---|
| **Agent benchmark** | **+10.6%** | "consistently outperforming strong baselines" |
| **Finance benchmark** | **+8.6%** | domain-specific |
| **AppWorld leaderboard** | matches top-ranked production-level agent on overall average；**surpasses it on harder test-challenge split** | 用 **smaller open-source model** |
| Adaptation latency + rollout cost | 显著降低 | "with low overhead" |
| 监督信号 | **不需要 labeled supervision**——用 natural execution feedback | |

**两种 context adaptation**：
- **Offline**（如 system prompts）—— ACE 优化固定的 prompt
- **Online**（如 agent memory）—— ACE 优化运行时的 memory

#### MCE（Meta Context Engineering, Ye et al. 2026）

**比 ACE 往前走一步**：把"怎么管理 context"（**mechanism**）和"context 里放什么"（**artifact**）**解耦**，做**双层 bi-level optimization**：

```
Skill s ∈ S：定义 context 函数 c_s = (ρ_s, F_s)
   ρ_s = {ρ_1,...,ρ_m}  静态组件（prompts, knowledge bases, code libraries）
   F_s = {F_1,...,F_k}  动态算子（search, selection, filtering, formatting）

bi-level optimization:
   内层  c_s* = argmax J_train(c_s; s)         ← 给定 skill s，找最佳 context
   外层  s*   = argmax J_val(c_s*)              ← 找让内层最优的 skill
```

skill database 跟踪历史 `H_{k-1} = {(s_i, c_i, J_i^train, J_i^val)}_i=1^{k-1}`，meta-level agent 用 **agentic crossover** 在历史 skill 上生成新 skill `s_k = crossover(τ, H_{k-1})`。

**实现细节**：一个 context function `c` 实例化成**一个目录里的文件集合**——静态 `skill.md` + 动态 context/rollout。Meta 和 base 两层都在标准 coding agent 环境跑，工具集 `T = {Read, Write, Edit, Bash, Glob, Grep, TodoWrite}`。

**关键洞察**：MCE **不强加 heuristic rule**（不像 ACE 那样规定 bullet 格式）；用 free-form skill 存"对任务最重要的知识"，skill 和 context-conditioned content **一起迭代**。

#### Meta-Harness（Lee et al. 2026, arXiv:2603.28052）

**Abstract 提炼**：
> The performance of large language model (LLM) systems depends not only on model weights, but also on their harness: the code that determines what information to store, retrieve, and present to the model. Yet harnesses are still designed largely by hand, and existing text optimizers are poorly matched to this setting because they **compress feedback too aggressively**. We introduce Meta-Harness, an outer-loop system that searches over harness code for LLM applications. It uses an **agentic proposer** that accesses the source code, scores, and execution traces of all prior candidates through a **filesystem**.

**关键数字**：

| Benchmark | 起点 / Baseline | Meta-Harness 后 |
|---|---|---|
| **Online text classification** | SOTA context management system | **+7.7 points**，用 **4× 更少 context tokens** |
| **Retrieval-augmented math reasoning**（200 IMO-level problems） | baseline | **+4.7 points 平均**，跨 **5 个 held-out models** |
| **Agentic coding（TerminalBench-2）** | best hand-engineered baselines | **surpassed** |

**关键机制**（来自 Lilian 文章）：
- 整个 execution history 在**文件系统**里，agent 用 grep/cat 读
- 每次产出的 harness candidate 是文件系统里的**字典**（含 own source code / scores / rollout trajectories / state updates）
- meta-harness loop 迭代产生新 harness，**只保留合格的**（Pareto frontier）
- proposer 是 coding agent

**Lilian 的结论**：
> Once harness design becomes an executable search space, a strong coding agent can exploit the same design space human engineers use.

#### Meta-Harness 在 TerminalBench-2 上的具体例子

文章明确说：**"The search in the TerminalBench-2 experiment is initialized from Terminus-KIRA and Terminus-2, two very strong harnesses."**

含义：
- **Terminus-KIRA / Terminus-2** = 两个已经很强的 coding agent harness（专门跑 TerminalBench 这类"在 Linux terminal 里完成真实任务"的 benchmark）
- Meta-Harness 不是从零开始搜索，是**把这两个当起点（parent）**
- TerminalBench-2 = 一个 benchmark（测试集）——给 agent 真实运维任务，看完成率
- 即使起点已是 SOTA，搜索依然能进一步提升分数

为什么这件事重要（用类比）：
- 从普通厨师起步 → 教他变厉害 → 当然能变好（废话）
- 从米其林三星厨师起步 → 给他工具自己改菜谱 → **居然还能更好**

含义：
1. harness 设计的天花板还没到
2. 机器自动搜索能超过人类手设
3. harness 是连续可优化的（不是"找到一个最好的就完事"）

---

### 6.2 Layer 3 — Workflow Design

#### AI Scientist（Lu et al. 2026, Nature）

完整 pipeline：**idea → code → experiment → analyze → paper → peer review**。

Lilian 评价：**写论文 ≠ 科学发现**——一个系统能写出 plausible manuscript 但仍可能 fabricated citations / implementation drift / weak experimental results。

#### ScientistOne（Meng et al. 2026）

把 **verifiability 当中心设计约束**：每个 claim（citation / numerical / methodological / conclusion）必须 trace 到 evidence source，由 Chain-of-Evidence checks 审计。

#### Autodata（Kulikov et al. 2026）

设计成 data scientist 角色生成训练 / 评估数据：
- main agent 管理 challenger / weak solver / strong solver / verifier
- 合成"刚刚好难度"的数据（strong solver succeed / weak solver fail）
- challenger prompt 迭代更新

**局限**：合成任务只 fine-tune 弱模型——**不能迭代改进 strong model** → **不算真 RSI**，更像 indirect distillation。

#### ADAS（Automated Design of Agentic Systems, Hu et al. 2025, ICLR'25）

把 agent 设计本身当**搜索问题**：
```
1. 用简单 agent（CoT / self-refine）初始化 archive
2. meta-agent 编程新 agent，全部 in code，受 archive 现有解启发
3. meta-agent 先生 high-level workflow 描述，再实现成 code
4. draft program 走两轮 self-refine（model 给 feedback → 再 refine）
5. 评估新 candidate，成功的加回 archive
6. 重复到 iteration 上限
```

#### AFlow（Zhang et al. 2025, ICLR'25）

把 workflow 当**图**（节点 = LLM 调用，边 = 逻辑操作），用 **MCTS 搜**：

```
1. 初始化 W_0（用模板）
2. Select：soft mixture of score + uniform exploration
3. Expand：LLM 产出 modified workflow（conditioned on 当前 eval performance）
4. Execute + evaluate 新 workflow
5. 加回树里（if shows improvement within budget N rounds）
6. top-k average score plateau 或 hit budget 时停
```

**结果**：在 QA / code / math 任务上，AFlow 比**手动设计 workflow 和 ADAS 都好**。

---

### 6.3 Layer 4 — Self-Improving Harness（核心战场）

#### STOP（Self-Taught Optimizer, Zelikman et al. 2023, COLM'24）

**最早、最纯粹**的"递归优化 improver"原型。

种子 improver `I_0` 在 step `t=0` 接受 (initial solution `s`, utility function `u`, black-box model `M`)，返回 improved solution：

```
s' = I(u, s; M)
```

STOP 的目标**不是直接改进 s**，而是改进 improver `I` 本身。

**Meta-utility** 定义为 improver 在下游 task collection `D` 上的平均 utility：

```
û(I) ≜ (1/|D|) E_{(u,s)~D} [u(I(u, s; M))]
```

**Self-improvement update**：

```
I_t = I_{t-1}(û, I_{t-1}; M)
```

**实验发现的策略**：improver 自主发现了 genetic algorithms / decomposing and improving parts / multi-armed prompt bandits / simulated annealing / varying temperature / beam/tree search。

**⚠️ 关键警示**：
- GPT-4 上**改善** mean downstream performance
- GPT-3.5 / Mixtral 上**退化**
- 结论：**递归结构 alone is not enough**；**base model 必须够强才能 improve the mechanism**

#### Self-Harness（Zhang et al. 2026）

比 STOP 更工程化，用 LLM agent 改自己 harness 的**三阶段 loop**：

```
Weakness mining      →  把 failures cluster 成 verifier-grounded failure patterns
Harness proposal     →  基于失败 pattern 提出 bounded harness edits
Proposal validation  →  验证 edits、merge 合格者到 h_{t+1}
```

**① Weakness mining**
- 当前 harness `h_t` 跑 tasks，收集 execution traces
- **关键警告**：两个 run 在 verifier outcome 上一样（都是 timeout / missing artifact），causal mechanism 可能不同 → failure record 必须含：
  - terminal verifier-level cause
  - causal status of relevant agent behavior
  - abstract agent mechanism exposed by the trace

**② Harness proposal**
- 同一个 model 在 `h_t` 下当 proposer
- 给 bounded proposal context：
  1. 当前 harness 的 **editable surfaces**
  2. 评估系统产生的 **verifier-grounded failure patterns**
  3. **passing behaviors that should be preserved**
  4. **previously attempted edits 的 summaries**
- Harness edits 优先选 **recurrent + addressable + narrow** 的
- Edit candidates 要 **distinct + diverse**

**③ Proposal validation**
- 候选 edits 在两个 split 上跑回归测试：
  - **held-in `D_in`**（测试 weakness 是否被解决）
  - **held-out `D_out`**（测试没引入新问题）
- **两个 split 上都没 regression 才接受**
- 接受的 merge 到 `h_{t+1}`，拒绝的 log 但不改 active harness

**实验**：在 MiniMax M2.5 / Qwen3.5-35B-A3B / GLM-5 上跑 Terminal-Bench-2，Self-Harness 学到 **model-specific harness instructions**。

**Lilian 的安全顾虑**（原文）：
> Self-harness type of work does raise my concerns that if a program is allowed to edit the OS system, abstraction boundaries are broken. The editable surface needs to be properly designed and the permission control and security layers need to live outside this loop.

#### SIA（Self-Improving AI, Hebbar et al. 2026）

联合优化 harness + model weights，三个组件：

```
Meta-Agent        →  提出初始 harness
Task-Specific Agent →  执行 task
Feedback-Agent    →  根据最近 trajectories 决定下一步：改 harness 还是改 weights
```

Lilian 评价：**方向 interesting，但 evidence provisional**——Task agent 比 Meta/Feedback agent 弱（gpt-oss-120b vs Claude Sonnet 4.6），**变量混淆**；baselines 太弱。

---

### 6.4 Layer 5 — Evolutionary Search

#### 早期 prompt 进化
- **Promptbreeder** (Fernando et al. 2023) — mutation operations 进化 task-specific prompts；**mutation prompts 自己也进化**（自指）
- **GEPA** (Agrawal et al. 2025) — reflection-based prompting + evolutionary search；用**自然语言 reflection** over trajectories of trial and error 来 propose prompt updates

#### AlphaEvolve（Novikov et al. 2025）

**Coding-agent evolutionary search system**——Lilian 给的细节很多：
```
Pool of candidate programs + prompts
Frozen LLM 生成 diffs 改进
循环评估 child programs，keep successful ones
```

**几个关键设计**：
1. Prompt 含 **parent programs + results + instructions + sometimes meta information**
2. Coding agent 有 full repo 访问，但**改进区域用 `# EVOLVE-BLOCK-START` / `# EVOLVE-BLOCK-END` 显式标记**
3. **Meta-prompt 跟 instructions + context 一起 co-evolve**（跟 solution programs 同方式）
4. Ablations 证明 evolution procedure / context in prompts / meta-prompts / full-file evolution / 强 LLM 都贡献

#### ShinkaEvolve（Lange et al. 2025）

在 AlphaEvolve 基础上提**sample efficiency**：
1. **Parent sampling**：balance performance rank + offspring count
2. **Code-novelty rejection sampling**：embedding cosine similarity 砍掉太相似的 candidate
3. **Meta-scratchpad**：识别 successful solutions 的好 pattern 引导未来 mutation

#### DGM（Darwin Gödel Machine, Zhang et al. 2025, arXiv:2505.22954）★

**Abstract 提炼**：
> Today's AI systems have human-designed, fixed architectures and cannot autonomously and continuously improve themselves. The advance of AI could itself be automated. If done safely, that would accelerate AI development and allow us to reap its benefits much sooner. Meta-learning can automate the discovery of novel algorithms, but is limited by first-order improvements and the human design of a suitable search space. The Gödel machine proposed a theoretical alternative: a self-improving AI that repeatedly modifies itself in a provably beneficial manner. Unfortunately, **proving that most changes are net beneficial is impossible in practice**. We introduce the **Darwin Gödel Machine (DGM)**, a self-improving system that iteratively modifies its own code (thereby also improving its ability to modify its own codebase) and **empirically validates each change** using coding benchmarks. Inspired by Darwinian evolution and open-endedness research, the DGM maintains an **archive of generated coding agents**. It grows the archive by **sampling an agent from it** and using a foundation model to create a new, interesting, version of the sampled agent. This open-ended exploration forms a **growing tree** of diverse, high-quality agents and allows the parallel exploration of many different paths through the search space.

**5 步算法**（原文）：
1. Start with one coding agent in the pool.
2. In each iteration, pick one parent with a probability proportional to its performance and inversely to the number of children it has, to modify and branch off to produce new agents.
3. The selected parent agent examines its own benchmark evaluation log and then proposes improvements to its own harness codebase to generate a new version of the coding agent. Code editing is implemented with two basic tools: (1) `bash` (args: `<bash_command>`) and (2) `editor` (args: `view/create/edit <file_path>`).
4. New coding agents are evaluated, and only those with sufficiently high performance are added back into the pool.
5. Repeat steps 2-4 until some stop criteria hit.

**关键条件**：DGM = **harness evolution under a fixed model**（模型权重不动）。

**关键数字**：

| Benchmark | 起点 | DGM 后 |
|---|---|---|
| **SWE-bench** | 20.0% | **50.0%** |
| **Polyglot** | 14.2% | **30.7%** |

**DGM 自动改出了什么**（abstract 明确给了）：

> the DGM automatically improves its coding capabilities (e.g., **better code editing tools, long-context window management, peer-review mechanisms**)

具体：
1. **Code editing tools 变好**——可能从 string-based 替换变成更 robust 的多策略编辑
2. **Long-context window management 变好**——可能加入 context summarization、selective retrieval
3. **Peer-review mechanisms 被加入**——agent 之间相互 review 代码（**meta-level 改进**——提升"改自己"的能力）

**跟 Gödel Machine 的关系**：
- **原始 Gödel machine**（Schmidhuber 2003）：theoretical，self-modifying with **provably beneficial** changes
- **问题**：实际上 proving most changes are net beneficial is impossible
- **DGM 的 workaround**：不用 proof，用 **coding benchmarks empirical validation**（跑测试看分）

**Safety precautions**（abstract 明确）：sandboxing + human oversight。

#### Hyperagents（Zhang et al. 2026）

DGM 后续：加 **meta-agent 控制"如何改 task agents"**——把"改 agent 的 agent"也明确化。

#### Evolutionary search 的适用边界

Lilian 总结：

**Work well when**：
- candidate solutions **自动可评估**
- candidate fitness **容易量化**
- 例子：matrix multiplication / GPU kernel / 算法竞赛 / datacenter scheduling

**Struggle when**：
- 评估**慢 / 模糊 / 主要靠 heuristic**
- compute efficiency 和 effectiveness 都成问题

---

### 6.5 Joint Optimization with Model Weights

Lilian 把 SIA 单独标了一节，但**没给具体基准结果**——主要因为 confounding choices 太多。

她的判断：**harness evolution 改 non-parametric system around the model**；**让 full self-improvement → 允许模型同时更新 weights**。weight update 可以走**改进 training pipeline** 或 **test-time continual learning**——后者 "worthy of its own post in the future"。

---

## 7. 3 个 anchor 详解（ACE / Meta-Harness / DGM）

### 7.1 Anchor 1: ACE 三件套的具体例子（Python 函数伪例）

#### 场景
写一个 Python 函数，把 list 里的数字平方并排序。

#### Iteration 1（baseline playbook）

**初始 playbook**：
```
- bullet_use_builtins: "For standard operations, prefer Python built-ins"
- bullet_add_types: "Always include type hints"
```

**Generator 跑任务**（用这个 playbook）：
```python
def square_and_sort(nums):       # ← 没加 type hints
    result = []
    for n in nums:                # ← 自己写循环
        result.append(n * n)
    for i in range(len(result)):  # ← 手动排序
        for j in range(i+1, len(result)):
            if result[i] > result[j]:
                result[i], result[j] = result[j], result[i]
    return result
```
跑测试 → **fail**（超时 + 类型检查报错）

**Reflector 看 trajectory**：
- insight_1: "Generator 用 manual nested loop 排序——浪费。sorted() 一行就够"
- insight_2: "Generator 跳过了 type hints"

**Curator 合并进 playbook**（追加，不重写）：
```
- bullet_use_builtins: "For standard operations, prefer Python built-ins"   ← 保留
- bullet_add_types: "Always include type hints"                              ← 保留
- bullet_builtins_TRIGGER: [NEW] "When about to write manual sorting/loop, 
                               STOP and ask: does Python have a built-in?"   ← 新增
- bullet_types_EXPLICIT: [NEW] "Add type hints to ALL function signatures, 
                              even when problem statement doesn't ask"      ← 新增
```

#### Iteration 2（用更新后的 playbook）

Generator 输出：
```python
def square_and_sort(nums: list[int]) -> list[int]:   # ← 有 type hints
    return sorted(n * n for n in nums)                # ← 一行
```
跑测试 → **pass**

#### 三个反直觉点（Lilian 文章强调）

1. **不重写整段 prompt**——只追加 bullet（避免 context collapse）
2. **bullet 是结构化的 `(identifier, description)`**——不是自由文本，方便检索 / 去重 / 版本化
3. **定期 refine + 去重**——bullet 库不能无限膨胀

---

### 7.2 Anchor 2: Meta-Harness 在 TerminalBench-2 的具体例子

见 §6.1 Meta-Harness 部分（"Meta-Harness 在 TerminalBench-2 上的具体例子"小节）。

---

### 7.3 Anchor 3: DGM 的具体细节

见 §6.4 DGM 部分（5 步算法 + 关键数字 + 自动改了什么）。

---

### 7.4 3 个 anchor 的关系表

| | 改什么 | 改的方式 | 自动化程度 | 关键数字 |
|---|---|---|---|---|
| **ACE** | prompt（playbook bullets） | Generator 跑 → Reflector 提炼 → Curator **追加** bullet | 自动 | +10.6% agents / +8.6% finance / AppWorld 匹配 top-ranked |
| **Meta-Harness** | harness 代码（Python 文件等） | coding agent **改代码 + 评估 + 留好的** | 自动 | text classification +7.7 / math +4.7 across 5 models / TerminalBench-2 surpassed |
| **DGM** | harness 代码 + 进化搜索 | **一池子 harness 互相生变种 + 评估 + 留高分** | 自动 | SWE-bench 20%→50% / Polyglot 14.2%→30.7% |

共同前提：**base model 不变**（不训练 / 不改模型权重）。

---

## 8. Future Challenges（7 大挑战 + 6 大失败模式）

### 8.1 Lilian 总结的 7 大挑战

| # | 挑战（原文） | 一句话（Lilian） |
|---|---|---|
| 1 | **Weak and fuzzy evaluators** | 研究品味、novelty、长期科学价值难量化；当前 self-improvement loop 只在评估客观的任务上 work |
| 2 | **Context and memory lifecycle** | Memory 越长越需要管理；**"context engineering 应该成为 intelligence 的一部分"**（最激进的一句） |
| 3 | **Negative results** | 文献偏成功，LLM 不擅长放弃假设 / 报告失败 / 承认错误 |
| 4 | **Diversity collapse** | 进化/RL 趋向 exploit 已知高奖励；开放研究里"最优路径"在当前 evaluator 下可能显得差 |
| 5 | **Reward hacking** | Evaluator + permission 控制必须**坐在 loop 外**（held-out tests + trace audit + human review） |
| 6 | **Long-term success** | RLVR 训练 sandbox 看不到 maintainability / 迁移成本 / 向后兼容 |
| 7 | **The role of humans** | 人类应该往 stack 上走，不能被反过来替代 |

### 8.2 Trehan & Chopra (2026) 总结的 6 大失败模式

Lilian 引用了这篇同期 arXiv 工作（reference [28]），总结 auto-research 实验中 LLM 的 6 种失败模式：

| # | 失败模式（Lilian 转述） |
|---|---|
| 1 | **Bias toward training-data defaults**（用老库 / stale commands / 默认假设 / 不基于实际 repo/dataset） |
| 2 | **Implementation drift under execution pressure**（实现变难时退回到常见更简单方案） |
| 3 | **Memory and context degradation**（长程任务丢关键细节，除非 logs 写成持久 artifact） |
| 4 | **Over-optimism**（实验失败/嘈杂却宣布成功 = "p-hacking and eureka-ing"——Bubeck et al. 2025 也观察到，LLM 引入 "numerical duct tape" 然后宣布胜利） |
| 5 | **Insufficient domain intelligence**（缺 tacit craft——预测实现复杂度 / 判断实验结果是否 plausible / 哪些 baselines 重要） |
| 6 | **Weak scientific taste**（实验可跑但答错问题） |

### 8.3 最值得记的两条

- **挑战 5（reward hacking）+ evaluator 在 loop 外**——这是 self-improving system 的安全底线
- **挑战 2（context engineering 是 intelligence 一部分）**——这是最激进、最有远见的预测

---

## 9. 6 个 Benchmarks（Appendix）

### 9.1 PaperBench

**原文**：
> Replicate 20 ICML 2024 Spotlight and Oral papers from scratch, including understanding paper contributions, developing a codebase, and successfully executing experiments.
> Each replication task is decomposed into smaller, individually gradable tasks.
> **8,316 rubrics** in total, **co-developed with the paper authors**.
> The best model at the time (**Claude 3.5 Sonnet, ~21%**) **does not outperform ML PhDs**.

**关键洞察**：
- **跟原作者合作写 rubric**（不只是自动生成评测）
- **8,316 个细粒度 rubric**——每个大任务拆成可独立评分的子任务
- **AI 最高 21% < ML PhD**——这是 auto-research 路线的硬天花板证据

包含的子集：PaperBench / PaperBench Code-Dev（轻量版）/ JudgeEval。

### 9.2 CORE-Bench

**原文**：
> Evaluate computational reproducibility of published research.
> **270 tasks** based on **90 scientific papers** across computer science, social science, and medicine.
> Tasks involve reproducing results from provided code and data.
> Includes multiple difficulty levels and both **language-only and vision-language tasks**.
> The best reported agent at the time (**GPT-4o and GPT-4o-mini**) achieved only **21% accuracy on the hardest task**.

**关键洞察**：跨学科（CS / 社科 / 医学）；支持纯文本 + vision-language；最难任务只 21%。

### 9.3 ScienceAgentBench

**原文**：
> Evaluate LLM agents for data-driven scientific discovery.
> **102 tasks** from **44 peer-reviewed publications** in four disciplines (**math, chemistry, biology, geography**).
> Covers basic data-science tasks in these domains: **data processing, model development, data analysis, and information visualization**.

**关键洞察**：不是"复现论文"，是**做数据科学**（data processing / model dev / analysis / viz）。

### 9.4 RE-Bench ★ 跟人类专家直接对比

**原文**：
> Evaluate frontier AI agents on realistic ML research-engineering envs against human experts.
> **7 challenging, open-ended ML research-engineering environments**.
> Each environment = (**scoring function, starting solution, reference solution**); each can be run with **8 or fewer H100 GPUs**.
> Examples: optimize a kernel, run a scaling-law experiment, fix an embedding, fine-tune GPT-2 for QA, etc.
> Includes data from **71 eight-hour attempts by 61 distinct human experts**.
> Human experts achieved non-zero score in **82%** of 8-hour attempts; **24% matched or exceeded strong reference solutions**.
> Best AI agents scored **4× higher than humans at a 2-hour budget**, but humans had better returns to longer budgets and **exceeded agents at 8-hour and 32-hour settings**.

**关键洞察**（最值得记的一条）：
- **2h 预算：AI 4× 强于人类**（AI 起步快）
- **8h / 32h 预算：人类反超**（人类长程更好）
- 含义：**AI 擅长"快速试错"，人类擅长"长期思考"**——这是 harness / RSI 设计的核心 trade-off

**71 个 8 小时人类尝试 / 61 个专家**——**RE-Bench 是少数有真实人类 baseline 的 benchmark**。

### 9.5 MLE-bench

**原文**：
> Evaluate ML engineering agents on offline Kaggle competitions.
> **75 ML-engineering competitions** curated from Kaggle.
> Tests training models, preparing datasets, running experiments, and submitting predictions to grading scripts.
> Uses **Kaggle public leaderboards** as human baselines.
> Best setup in the paper, **o1-preview with AIDE scaffolding**, reached at least **Kaggle bronze-medal level in 16.9% of competitions**.
> Includes resource-scaling and contamination analyses.

**关键洞察**：
- **直接用 Kaggle 比赛**（不是合成任务）——现实 ML 工程问题
- **AIDE scaffolding** 是 best setup 的关键——harness 重要性的实证
- **16.9% 拿铜牌**——意味着 AI 在 1/6 的 Kaggle 比赛里能当 top 选手
- 含 **contamination analyses**——评估"AI 是否在训练时看过这些比赛"

### 9.6 KernelBench

**原文**：
> Evaluate correctness and speed for generated GPU kernels.
> **250 PyTorch tasks** to evaluate whether LLM can write fast and correct kernels.
> The evaluation metric **fast_p** = the percentage of generated kernels that are **correct and faster than baseline**.

**关键洞察**：不是只看"能不能写"，是看"**写得对 + 比 baseline 快**"——速度 + 正确性双指标。

### 9.7 6 个 benchmark 一览表

| Benchmark | 规模 | 测什么 | 最佳成绩 / 关键数字 |
|---|---|---|---|
| **PaperBench** | 20 篇 ICML 2024 spotlight/oral，**8,316 rubrics** | 复现论文（contribution + code + experiments） | Claude 3.5 Sonnet ~21% < ML PhD |
| **CORE-Bench** | 90 篇 paper × 270 tasks（CS / 社科 / 医学） | 复现研究结果（provided code + data） | GPT-4o / 4o-mini 在最难任务只 21% |
| **ScienceAgentBench** | 102 tasks × 44 publications（数 / 化 / 生 / 地） | 数据科学（data processing / model dev / analysis / viz） | （具体数字原文未给） |
| **RE-Bench** | **7 个 ML 研究工程 env**（vs **71 个 8h 人类尝试**） | 跟人类专家对比 | AI 2h 4× 强于人类；人类 8h/32h 反超 |
| **MLE-bench** | **75 个 Kaggle 比赛** | ML 工程（训练 / 数据 / 提交） | o1-preview + AIDE **16.9% 拿铜牌** |
| **KernelBench** | **250 个 PyTorch 任务** | 写 GPU kernel（correct + fast） | metric fast_p |

### 9.8 Lilian 给 benchmark 附录的意图

Lilian 在主文章讲 harness engineering 时引用这些 benchmark，是给**自改进 loop 找评估标准**——回到 Future Challenges 第 1 条"弱/模糊的评估器"。

这些 benchmark 都满足 auto-research / self-improvement 想要的特性：
- **自动可评估**（不是人工打分）
- **可量化**（pass rate / fast_p / medal level）
- **可比人类 baseline**（RE-Bench / MLE-bench）

但也有局限：
- **主要测 ML / engineering**，不测"研究品味""novelty"
- **很多是 closed-form 任务**，跟 open-ended research 不一样

---

## 10. 关键金句

> *A **harness** is the system surrounding a base model that orchestrates execution and decides how the model thinks and plans, calls tools and acts, perceives and manages context, stores artifacts, and evaluates results.*

> *Harness engineering will evolve in the direction of **meta-methodology** (i.e. improving the machinery for getting better answers, not just improving the answer itself).*

> *Once harness design becomes an executable search space, a strong coding agent can exploit the same design space human engineers use.* —— Meta-Harness 结论

> *Recursive structure alone is not enough. The base model must be capable enough to improve the mechanism.* —— STOP 警示

> *Context engineering will and should become a core part of intelligence, rather than staying in the software system layer.*

> *The evaluator and permission control should likely sit outside the loop that evolves harness.*

> *Learning how to read, write, and edit the file system (commonly via bash commands) is a **foundation skill for LLMs**, and thus managing persistent memory in the simple form of files **naturally benefits from improvements in core model capability**.* —— Pattern 2

> *The key design choice is to **make parallelism explicit and inspectable**.* —— Pattern 3

> *If subagent outputs only live in a transient chat context, they **quickly become obsolete and hidden**. If they are stored as **files, logs, and status records**, the model can **recover after interruptions** and **reason over its own execution history**.* —— Pattern 3

---

## 11. 引用与原始 abstract 来源

### 11.1 3 篇原始论文（3 个 anchor 的源头）

| 工作 | arXiv ID | 长度 | 引用 |
|---|---|---|---|
| **ACE** | [2510.04618](https://arxiv.org/abs/2510.04618) | 32 pages | ICLR 2026; Zhang et al., "Agentic Context Engineering: Evolving Contexts for Self-Improving Language Models" |
| **Meta-Harness** | [2603.28052](https://arxiv.org/abs/2603.28052) | arXiv preprint | Lee et al., "Meta-Harness: End-to-End Optimization of Model Harnesses" |
| **DGM** | [2505.22954](https://arxiv.org/abs/2505.22954) | arXiv preprint | Zhang et al., "Darwin Gödel Machine: Open-Ended Evolution of Self-Improving Agents" |

### 11.2 文章未展开但提到的其他工作（reference [N] 对应）

- [7] ACE / [8] MCE / [9] Meta-Harness —— Layer 2 Context Engineering
- [10] AI Scientist / [11] ScientistOne / [12] Autodata —— Layer 3 Workflow Design（人类设计）
- [13] ADAS / [15] AFlow —— Layer 3 Workflow Design（算法搜）
- [16] STOP / [17] Self-Harness / [27] SIA —— Layer 4 Self-Improving Harness
- [18] Promptbreeder / [19] GEPA / [20] AlphaEvolve / [21] ShinkaEvolve / [22] ThetaEvolve / [23] DGM / [24] Hyperagents —— Layer 5 Evolutionary Search
- [28] Trehan & Chopra 6 大失败模式
- [29] Bubeck et al. 2025 Early science acceleration with GPT-5
- [30]-[35] 6 个 benchmark 原始论文

---

## 12. 知识储备前提（这份笔记适用谁）

| 概念 | 假设熟悉度 |
|---|---|
| **Agent / Loop / Skills / Sub-agent** | 熟悉（来自 Loop-Engineering / Fable-Field-Guide / rari 30 件事） |
| **Prompt engineering 基础** | 熟悉（手动写过 prompt evolution） |
| **ML 理论（self-play / RL / continual learning）** | 不熟悉（本笔记解释时尽量避免算法公式） |
| **进化算法（GA / MCTS / simulated annealing）** | 不熟悉（用直觉说，不写算法） |
| **AI 安全 / RSI 哲学（I.J. Good / Yudkowsky）** | 不熟悉（背景带过，不深讲） |

---

## 13. Vault 关联

### 同主题双链
- Harness-Engineering-for-Self-Improvement — 精简版笔记（11KB，文章摘要 + 文章独有部分）
- Loop-Engineering — Addy Osmani 的 Loop Engineering（harness 的一种应用层视角）
- Fable-Field-Guide — Thariq 的"地图不是疆域"+ Blind Spot Pass prompt（evaluator 设计的精神同源）

### 反向链接
- _index — 个人笔记区入口
- MOC — 全局 Map of Content

### 相关 tags
- `#harness-engineering` — 主标签
- `#context-engineering` — 衍生标签
- `#self-improvement` — RSI 主题
- `#agentic-coding` — 与 Loop Engineering 共享
- `#sub-agents` — Pattern 3
- `#evolutionary-search` — Layer 5
- `#benchmarks` — Appendix
