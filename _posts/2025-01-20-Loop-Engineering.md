---
layout: post
title: "Loop Engineering"
tags: [ai-agents]
---
> **TL;DR** — 你不再是给 agent 敲 prompt 的人,而是设计一个**会自己反复驱动 agent 干活的系统**。杠杆点从"写好单条 prompt" 移到"设计持续编排 agent 的控制系统"。

这个概念由 **Peter Steinberger** 起头、**Addy Osmani**(Chrome/Google Cloud AI 工程总监)2026-06-07 在博客正式命名,Boris Cherny(Claude Code @ Anthropic 负责人)用一句话背书:

> "I don't prompt Claude anymore. I have loops running that prompt Claude and figuring out what to do. **My job is to write loops**."

---

## 历史脉络: 为什么是 Loop Engineering

```
2023-24   Prompt Engineering      → 你写一句,模型回一句
2025      Harness Engineering     → 给单个 agent 设计"居住环境"
2026 H1   Context Engineering     → 你管理喂给模型的上下文
2026 H2   Loop Engineering        → 你设计系统,系统反复驱动 agent
```

Addy 原话:

> Loop = "一个递归的 goal。你定义一个目的,AI 反复迭代直到完成。"

Steinberger 把它总结成一句话:"**You shouldn't be prompting coding agents anymore. You should be designing loops that prompt your agents.**"

---

## ⭐ 5 个原语(+ 1 个 memory)

这是社区共识——Addy 把 Codex App 和 Claude Code 对照打表,发现两边原语几乎一一对齐:

| 原语                           | 在 loop 里的作用                   | Codex App                                                    | Claude Code                                                       |
| ---------------------------- | ----------------------------- | ------------------------------------------------------------ | ----------------------------------------------------------------- |
| **Automations / Scheduling** | 心跳:定时触发、自动发现+分诊               | Automations tab:配项目、prompt、频率、env;结果进 Triage 收件箱;`/goal` 跑到停 | Scheduled tasks + cron、`/loop`、`/goal`、hooks、GitHub Actions       |
| **Worktrees**                | 安全并行:多 agent 不撞文件             | 每 thread 内置一个 worktree                                       | `git worktree`、`--worktree` flag、`isolation: worktree` (subagent) |
| **Skills**                   | 持久化项目知识,别每次重说一遍               | Agent Skills(SKILL.md),用 `$name` 或隐式触发                       | 同上(SKILL.md)                                                      |
| **Plugins / Connectors**     | 接入真实工具                        | Connectors(MCP)+ plugins 打包分发                                | MCP servers + plugins                                             |
| **Sub-agents**               | Maker / Checker 分离:一个写,一个审    | 在 `.codex/agents/*.toml` 定义                                  | `.claude/agents/` + agent teams                                   |
| **Memory / State**(第 6 个)    | 在 conversation 之外记住"做了什么、下一步" | Markdown / Linear via connector                              | `AGENTS.md`、progress 文件 / Linear via MCP                          |

> **关键**:Memory 必须在磁盘上,不能在上下文里。**"The agent forgets. The repo doesn't."**

---

## LangChain 的 4 层 Loop 框架(纵深视角)

[Sydney Runkle 6/16 博文](https://www.langchain.com/blog/the-art-of-loop-engineering)给出了一个更抽象的纵深:

| 层                         | 是什么                              | 自动化了什么  | LangChain 原语                 |
| ------------------------- | -------------------------------- | ------- | ---------------------------- |
| L1 **Agent loop**         | LLM 在 loop 里调 tool 直到任务完成        | 执行工作    | `create_agent`               |
| L2 **Verification loop**  | Grader 打分,失败反馈重做                 | 工作质量    | `RubricMiddleware`           |
| L3 **Event-driven loop**  | 事件/cron 触发,不是人手动调                | 规模化运行   | LangSmith Deployment / Fleet |
| L4 **Hill-climbing loop** | 分析过往 traces → **自动改 harness 本身** | 自动化"改进" | LangSmith Engine             |

**L4 是 "loop on the loop"**——让系统改系统。Sydney:"值会复利的地方是 L3 + L4,把 agent 嵌入你的生态让它持续按你的标准变好。"可对开源模型还能直接拿 trace signal 喂 RL 微调。

---

## 一个 loop 长什么样(Addy 的例子)

```
每天早上
  └─ automation 触发
       └─ 调用 triage skill
            ├─ 读昨日 CI 失败
            ├─ 读 open issues
            ├─ 读近期 commits
            └─ 写进 STATE.md 或 Linear
   对每条 worth doing 的发现
       ├─ 开一个 isolated worktree
       ├─ 派 sub-agent A 起草修法
       └─ 派 sub-agent B 用 project skills + tests 审稿
   connectors
       ├─ 开 PR
       ├─ 更新 ticket
       └─ Slack 通知 CI 绿
   STATE.md 是整个循环的脊柱
       记住:今天试过什么、什么通过了、下一步是什么
       → 明天早上的 run 从今天停的地方接上
```

**关键**:你设计一次,这些步骤**没有一步是你手动 prompt 的**。Same loop in Codex or in Claude Code——因为 pieces 是 same pieces。

---

## 🧰 开箱即用工具

```bash
# 1. 一行搭好骨架,马上给 Loop Ready score
npx @cobusgreyling/loop-init . --pattern daily-triage --tool claude

# 2. 审计:你缺哪些原语
npx @cobusgreyling/loop-audit . --suggest

# 3. 估算 token 花费
npx @cobusgreyling/loop-cost --pattern ci-sweeper --cadence 15m

# 4. 自家仓库:loop-sync(检测 STATE.md ↔ LOOP.md drift)
npx @cobusgreyling/loop-sync .
```

Claude Code / Codex 自带的:
- `/loop` — 周期重跑
- `/goal` — 跑到条件成立才停(turn-by-turn 独立评审员)

参考 repo:[cobusgreyling/loop-engineering](https://github.com/cobusgreyling/loop-engineering) — 5.5k stars(7月初更新),7 个生产 patterns 直接 clone。

---

## 7 个生产 patterns(社区共识初稿)

| Pattern | Cadence | Week-1 自治级 | Token cost |
|---|---|---|---|
| Daily Triage | 1d–2h | L1 report | Low |
| PR Babysitter | 5–15m | L1 watch | High |
| CI Sweeper | 5–15m | L2 cautious | **Very high** |
| Dependency Sweeper | 6h–1d | L2 patch-only | Medium |
| Changelog Drafter | 1d 或 tag | L1 draft | Low |
| Post-Merge Cleanup | 1d–6h | L1 off-peak | Low |
| Issue Triage | 2h–1d | L1 propose-only | Low |

每个都配 starter、Cadence、Token 预算、Week-1 自治级。**第一周只能 L1**(只报告、不动代码)→ 验证 L2(辅助修)→ 才到 L3(无人值守)。

---

## ⚠️ 必须知道的坑

作者们反复强调的几个点:

- **"Unattended loops make unattended mistakes"** — Cobus Greyling
- **"Comprehension debt grows faster unless you read what the loop ships"** — 你不读就完蛋
- **"Loop engineering amplifies judgment — both good and bad"** — 你设计错了,放大也更狠
- **Token 消耗可能爆炸** — sub-agents + long-running loop,真实账单吓过人
- **三阶段升级**:L1(报告)→ L2(辅助修)→ L3(无人值守),**第一周只能是 L1**
- Addy 的金句:**"Build the loop. But build it like someone who intends to stay the engineer, not just the person who presses go."**

---

## 🔗 双链

- Loop Engineering ← 这就是本文
- 推文索引
- 2026-07-05
- 2026-07-05 ← 今天 daily note

## 参考资料

- [Addy Osmani — *Loop Engineering* (2026-06-07)](https://addyosmani.com/blog/loop-engineering/) ← 必读,术语原创
- [LangChain — *The Art of Loop Engineering* (2026-06-16)](https://www.langchain.com/blog/the-art-of-loop-engineering) ← 4 层抽象
- [GitHub: cobusgreyling/loop-engineering](https://github.com/cobusgreyling/loop-engineering) ← 5.5k stars,工具齐全
- [eesel.ai — Loop Engineering explained](https://www.eesel.ai/blog/loop-engineering) ← 5 levers 框架
- Addy 同源更早期文:[Agent Harness Engineering](#) · [Orchestration Tax](#) · [Intent Debt](#) · [Long-Running Agents](#)

---

# 📖 以下:Addy Osmani 全文中文翻译

> 原文链接:https://addyosmani.com/blog/loop-engineering/
> 发布日期:2026-06-07
> 作者:Addy Osmani(Google Cloud AI 前 Director,Chrome 团队 14 年)

---

## 引子

Loop engineering = **用你自己设计的系统,替换"你是那个给 agent 发 prompt 的人"这件事**。这里所说的 loop,可以理解成一个递归的 goal——你定义一个目的,AI 反复迭代直到完成。我相信这可能就是未来我们跟 coding agent 协作的方式。但现在还早,我依然持怀疑态度,而且**你绝对要小心 token 成本**(usage pattern 因你是 token-rich 还是 token-poor 而天差地别),所以我想把它拆开讲讲它到底是什么、意味着什么。

Peter Steinberger 最近说过一句话:"**你不需要再给 coding agent 写 prompt 了。你应该设计 loops,让 loops 去 prompt 你的 agent。**"同样,Claude Code @ Anthropic 的负责人 Boris Cherny 也说:"**我已经不再 prompt Claude 了。我有 loops 在跑,它们 prompt Claude,然后自己判断下一步干嘛。我的工作是写 loops。**"

好,这些到底是什么意思?

## 这到底什么意思

过去这两年,你从 coding agent 那里得到点东西的方式都是:写一段好 prompt,塞够上下文。你打一行字,读它回什么,再打下一行。**那个 agent 是个工具,是你一整个拿着它,一轮又一轮**。这个时代基本结束了——或者说,至少有相当一部分人认为要结束了。

现在你造一个小系统,**让它去找活、分活、验收、把做过的事情写下来、再决定下一件事**,然后让这个系统去戳 agent,而不是你。我之前写过一篇跟这个相邻的话题——**agent harness engineering**,就是给那个跑一个单 agent 的环境本身做设计,还有那个 **factory model**——造软件的整个系统。Loop engineering 在 harness 上面再高一层。Harness 是会跑的——它按定时器跑、孵化小助手、自己喂自己。

让我意外的是,**这事儿已经不再是工具层面的事了**。一年前你要搭个 loop,你得写一大坨 bash,一辈子自己维护,这坨 bash 就是你自己的、只属于你自己的。现在这些零件直接装进产品里发货了。Steinberger 列的清单跟 Codex App 几乎一一对应,然后再跟 Claude Code 几乎一对一也对上。一旦你发现两边形状是一样的,你就不会再争论用哪个工具了——你只是设计一个 loop,它在哪个工具里跑都一样能跑。

## 五个零件,加一份笔记

一个 loop 需要五样东西,然后再加一个地方来记住事情。我先列清单,然后做个映射。

- **Automations** — 按周期触发,自己跑发现和分诊
- **Worktrees** — 两个并行 agent 不会互相踩脚
- **Skills** — 把项目知识写下来,不然 agent 只会瞎猜
- **Plugins 和 connectors** — 把 agent 接进你已经在用的工具
- **Sub-agents** — 让其中一个想点子、另一个审点子

然后第六样东西:**memory**。一个 markdown 文件,或者一块 Linear board,任何活在那次 conversation **之外**、装着"做了什么、下一步要做什么"的东西。听起来蠢到不像要紧。但这是每个 long-running agent 都要的同一招——我之前在 *long-running agents* 里写过,**模型每次跑之间会忘掉一切,所以 memory 必须在磁盘上、不能在上下文里**。Agent 忘事,仓库不忘。

两个产品现在都有这五样东西。

| 原语 | 在 loop 中的岗位 | Codex App | Claude Code |
|---|---|---|---|
| Automations | 按周期发现+分诊 | Automations tab:挑项目、prompt、频率、环境;结果进 Triage 收件箱;`/goal` 跑-直到-完成 | Scheduled tasks 和 cron、`/loop`、`/goal`、hooks、GitHub Actions |
| Worktrees | 隔离并行分支 | 每个 thread 内置一个 worktree | `git worktree`、`--worktree`、`isolation: worktree` 给 sub-agent |
| Skills | 把项目知识固化下来 | Agent Skills(SKILL.md),用 `$name` 调或隐式触发 | Agent Skills(SKILL.md) |
| Plugins / connectors | 接你的工具 | Connectors(MCP)+ 用来分发的 plugins | MCP servers + plugins |
| Sub-agents | 出主意 + 验证 | 在 `.codex/agents/` 里定义的 subagents(TOML) | 在 `.claude/agents/` 里的 Task subagents + agent teams |
| State | 跟踪"做了什么" | Markdown 或 经由 connector 接的 Linear | Markdown(`AGENTS.md`、progress 文件)或经由 MCP 接的 Linear |

两边叫法略有不同,但能力是同一件事。我一个一个讲,因为说实话,细节决定一个 loop 是真的立住了,还是在悄悄漏得到处都是。

## Automations:心跳

Automations 是让一个 loop **真的叫 loop、而不是你亲手跑了一次** 的东西。在 Codex App 里你在 Automations tab 里建一个——挑项目、配 prompt、设频率,选它在你的本地 checkout 跑还是在一个后台 worktree 跑。那些**跑出东西来的进 Triage 收件箱**,那些**没跑出东西的自动归档**——这点挺人性的。OpenAI 自己内部用它做一堆无聊的活:每日 issue triage、汇总 CI 失败、写 commit briefing、抓上周谁新加的 bug。一个 automation 还能调一个 skill,所以那种重复的事是 maintainable 的——你调 `$skill-name`,而不是把一大坨指令贴在没人会更新的 schedule 上。

Claude Code 走的路子不同,但到的是同一个地方:scheduling 和 hooks。你可以用 `/loop` 按间隔跑 prompt 或命令,你可以 schedule 一个 cron 任务,你可以用 hooks 在 agent 生命周期的特定时刻触发 shell 命令,或者你把整件事丢给 GitHub Actions——这样你合上笔记本它也在跑。想法一模一样——你定义一个自主任务,给它一个节奏,发现的东西到你这里,你就不用自己到处去查。

还有第二个 in-session 原语值得一提,也是跟今天这篇主题更贴近的那个:

- **`/loop`** 按周期重跑。
- **`/goal`** 会一直跑到你写的那个条件真的成立;每跑完一轮,一个独立的小模型来检查你是否完成,**所以写代码的 agent 不是那个给自己打分的 agent**。你给它一条像 "test/auth 里所有用例都过且 lint 干净" 的条件,然后就可以走开了。

Codex 也有同样的东西,也叫 `/goal`,跨 turn 跑,直到那个**可验证**的停机条件满足,有 pause、resume、clear。同样的原语,两个工具——这也是今天这篇文章的 pattern。

所以这是**暴露出活的部分**。Loop 的其余部分是去**干**这活的部分。

## Worktrees:不让并行变成混乱

你跑超过一个 agent 那一刻,文件就开始撞——这就是失败。两个 agent 写同一个文件,跟两个工程师同时 commit 同一段代码、互相没打过招呼,一模一样的头疼。**Git worktree 解决这个问题**——它是一个独立的 working directory、自己的 branch、共享同一份 repo 历史,所以一个 agent 的编辑**物理上不可能**碰到另一个的 checkout。

Codex 把 worktree 支持内建好了,几个 thread 同时打同一个 repo 也互相不撞。Claude Code 通过 `git worktree` 给同样的隔离,一个 `--worktree` flag 让你在一个独立 checkout 里开 session,以及一个 `isolation: worktree` 设置贴在 sub-agent 上让每个小助手拿到一个新鲜的 checkout、用完自己清理。我在 *orchestration tax* 里写过这一面的人事部分——**worktree 拿走了机械上的撞车,但你还是天花板:你的 review 带宽决定你能跑多少个,不是工具**。

## Skills:每次别再把你的项目解释一遍

一个 skill 就是让你**不用每次都跟一条金鱼重新讲一遍同一份项目上下文**。两个工具用同一种格式——一个文件夹里有个 `SKILL.md`,装着 instructions 和 metadata,然后可选的 scripts、references、assets。Codex 跑 skill 是你用 `$` 或 `/skills` 调它,或者当你的任务匹配 skill 的 description 时它自己触发——这就是为什么**一条无聊但紧的 description 完爆聪明的 description**。Claude Code 这么干的方式一模一样,我在 *agent skills* 里把这个 pattern 写了。

Skills 也是那个"intent 不再反复收费"的地方。我在 *intent debt* 里争辩过:**每次新 session 启动 agent 都是冷的,它会用自信的猜测填你 intent 的任何空缺**。**一个 skill 就是把这份 intent 写在外面的东西**——conventions、build 步骤、"我们不这么干是因为那一次事故"——写一次,agent 每次都读。没有 skills 的 loop 每次都是从零重新推导你的整个项目;有 skills 的 loop 是会复利的。

有一件事要分清:**skill 是 authoring 格式,plugin 是分发格式**。当你想要跨 repo 分享一个 skill 或者打包一组,你把它们打包成 plugin。Codex 适用,Claude Code 也适用。

## Plugins 和 connectors:loop 碰到你的真实工具

一个**只能看见文件系统的 loop 是很小的 loop**。Connectors(底座是 MCP)让 agent 能读你的 issue tracker、查数据库、打 staging API、在 Slack 里发消息。Codex 和 Claude Code 都讲 MCP,所以你给其中一个写的 connector 通常在另一个上也能直接用。Plugins 把 connectors 和 skills 打包在一起,这样你的同事一键就把你的设置装好了,不用自己凭记忆重新搭。

这是"**一个 agent 说'修法是这样的'**"和"**一个 loop 自己开 PR、绑 Linear 工单、CI 一绿就在频道里 ping**"的差别。Connectors 是 loop 能在你的真实环境里做事、而不只是告诉你"如果它能的话它会做什么"的原因。

## Sub-agents:让 maker 离 checker 远点

一个 loop 里**最有用的结构性做法**,远看也是,就是**把写的那个跟审的那个分开**。写下代码的那个模型给自己作业打分,**对自己好得太过分**。一个**有不同 instructions、有时候是不同模型**的第二个 agent,能抓到第一个 agent 自己骗过自己的那部分。

Codex 只有你让它做的时候才孵化 sub-agents,**同时跑它们**然后把结果并回一个答案。你在 `.codex/agents/` 里以 TOML 定义自己的 agent——每个有名字、description、instructions,可选的 model 和 reasoning effort——这样你的安全 reviewer 可以是个高 reasoning effort 的强模型,而你的探索者是个跑得快的只读小角色。Claude Code 同样干,在 `.claude/agents/` 里 sub-agents,再加 agent teams 在它们之间传活。两边的常见分法都是:**一个 agent 探索,一个实现,一个对着规格验**。

这事我吵过两遍,一次是 *the code agent orchestra*,一次是 *adversarial code review*。**它在一个 loop 里特别重要的原因是 loop 在你不在的时候还在跑**——所以**一个你真的信得过的 verifier 是你能走开的唯一理由**。Sub-agents 确实更烧 token,因为每一个都自己做 model + tool 工作,所以把"second opinion 值这个钱"的地方花。这基本上也是 Claude Code 的 `/goal` 在底下做的——一个**新鲜的模型**判断 loop 是否完成,而不是**那个干活的模型**,——maker/checker 拆开,套用在停机条件本身上。

## 一个 loop 长什么样

把这些捏到一起,单个 thread 就变成了一个小小的控制台。下面是我一直用的一个形状。

```
每天早上,一个 automation 在 repo 上跑
  └─ 它的 prompt 调用一个 triage skill
       └─ 该 skill 读昨日 CI 失败 / open issues / 近期 commits
            └─ 把发现写进一个 markdown 文件或 Linear board
   对每条"值得做"的发现
       ├─ thread 开一个 isolated worktree
       ├─ 派 sub-agent A 起草修法
       └─ 派 sub-agent B 用 project skills + 现有 tests 审稿
   connectors 让这个 loop
       ├─ 开 PR
       └─ 更新工单
   loop 处理不了的进我的 triage 收件箱
   state 文件是整件事的脊柱
       └─ 记住试过什么 / 什么过了 / 还开着什么
       └─ 明早的 run 从今天停的地方接上
```

看看你**实际上**干了什么。**你设计了一次。**这些步骤里**没有一步是你 prompt 的**。这就是 Steinberger 整个论点活生生的样子,而且这个 loop 在 Codex 或者在 Claude Code 里一模一样,因为零件是同样的零件。

## Loop 仍然不替你做的事

Loop 改变工作,**它不把你从工作里删掉**。而且**三件事随着 loop 变好反而变尖、不是变钝**:

**验证还在你身上。** 一个无人值守跑着的 loop,也是一个**无人值守犯错的 loop**。你把 verifier sub-agent 跟 maker 拆开,就是为了让 loop 的"做完了"这三个字**真的有点分量**——而就算这样,"做完了"还是个声明、不是个证明。我反复重复 *code review in the age of AI* 里那句:**你的工作是发布你确认能用的代码**。

**你的理解在你放它烂的时候就烂了。** Loop 越快地产出你没写过的代码,**存在的东西和你真正 get 进去的东西之间的缝隙就越大**。这就是 **comprehension debt**,一个顺滑的 loop 让它长得更快,除非你去读 loop 造的东西。

**舒服的姿态就是那个危险的姿态。** 当 loop 自己跑自己的时候,巨大的诱惑就是**你不再有意见、它给啥你接啥**。我管这叫 **cognitive surrender**。**设计 loop,带着判断力去设计它是解药;为了逃掉思考去设计它是助燃剂,同一个动作,反过来**。

## 修好 loop,继续当工程师

我觉得这是我们工作方式演化的一个预演。但话说回来,**如果我自己不复审那代码,或者我完全依赖自动化 loop 去修它,我的产品质量一定会掉**。我大概率会陷在一个下行的螺旋里,持续把自己埋进更深的坑。

不过话虽如此,**去搭你的 loops**——但也别忘了**直接 prompt 你的 agent 也是有效的**。关键是找到对的平衡。

Loops 也会因为操作它的**你**而跑出完全不同的结果。两个人可以建一模一样的 loop,跑出完全相反的结果。**一个**用它在自己真正懂的活上跑得更快;**另一个**用它彻底回避理解那活本身。**Loop 不知道这两个差。你知道。**

**这就是为什么 loop design 比 prompt engineering 难、不是更简单。** Cherny 的点不是说活变简单了。**是杠杆点挪了。**

> **Build the loop. But build it like someone who intends to stay the engineer, not just the person who presses go.**
> (修好 loop。但要像**打算一直当个工程师**的人那样修,而不只是"那个按下 go 的人"。)
