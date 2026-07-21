---
layout: post
title: "A Field Guide to Fable: Finding Your Unknowns / Fable 实地指南：找到你的 Unknowns"
tags: [ai-agents]
---
> 作者：Thariq（@trq212，Anthropic Claude Code 团队） · 2026-07-03 · [原文](https://x.com/trq212/status/2073100352921215386) · 7,925 ❤️ · 1,003 🔁 · 272 万 👁

---

Working with Claude Fable 5 keeps re-teaching me an old lesson: the map is not the territory.

和 Claude Fable 5 协作，一次又一次地提醒我一句老话：**地图不是疆域**。

The map, a representation of the work to be done, is my prompts and skills and context, it's what I give Claude. The territory is where the work needs to happen, the codebase, the real world, its actual constraints.

地图，是对"待完成工作"的抽象表示——它是我的 prompts、skills、context，也就是我交给 Claude 的那些东西。疆域，是工作真正发生的地方——代码库、真实世界、它实际的约束。

The difference between the map and the territory is what I call unknowns. When Claude runs into an unknown, it needs to make a decision based on its best guess of what I want. The more work being done, the more unknowns Claude might run into.

地图和疆域之间的差距，我把它叫做 **unknowns**。当 Claude 撞到一个 unknown，它只能凭"猜你想要什么"来决策。工作量越大，可能撞到的 unknowns 越多。

Fable is the first model where I find the quality of the work is bottlenecked by my ability to clarify its unknowns.

**Fable 是第一个让我发现：工作质量被"我能不能讲清它的 unknowns"卡住瓶颈的模型。**

Importantly, just planning ahead isn't always enough. You can find unknowns deep in implementation, or your unknowns may point you to the fact that you should actually be solving the problem in a different way altogether.

**关键的是：光靠提前规划并不总是够**。你可能在实现深处才发现 unknowns；或者你的 unknowns 会指向一个事实——你其实应该用完全不同的方式来解决这个问题。

I've found that working with Fable is an iterative process of discovering my unknowns before, during, and after implementation.

我发现：和 Fable 协作，是一个**在实现前、实现中、实现后**持续发现我的 unknowns 的迭代过程。

I've made some example artifacts for finding unknowns here, but be sure to come back to build the intuition for when to use them.

我准备了一份**用来找 unknowns 的示例 artifacts**，但一定要回来看完正文、建立起"什么时候该用哪个"的直觉。

---

## Knowing your unknowns / 认识你的 Unknowns

What are your unknowns? When I come to Claude with a problem I tend to break it down in 4 ways:

你的 unknowns 是什么？每当我带着一个问题去找 Claude，我倾向于把它分成 4 种：

- **Known Knowns**：essentially what's in my prompt. 基本上是 prompt 里写着的——我告诉 agent 我想要什么？
- **Known Unknowns**：what haven't I figured out yet, but I'm aware that I haven't. 还没想清楚、但我知道自己还没想清楚的是什么？
- **Unknown Knowns**：what's so obvious I'd never write it down, but would recognize it if I saw it? 太显然以至于不会写下来，但看到能认出来的？
- **Unknown Unknowns**：what haven't I considered at all? 完全没考虑过的——我的认知盲区里有什么？我知不知道"好"能好到什么程度？

The best agentic coders are good have relatively few unknowns. Watching someone like Boris or Jarred prompt, it is obvious to me that they know what they want in-detail. They are deeply in-sync with both the codebase and the model behaviors.

最好的 agentic coders，他们的 unknowns 相对**很少**。看 [Boris](https://www.linkedin.com/in/bcherny) 或 [Jarred](https://www.linkedin.com/in/jarred-sumner-a8772425) 怎么写 prompt，一眼就能看出：他们清楚自己想要什么、清楚到什么程度。他们和 codebase、和模型行为都**深度对齐**。

But they also assume unknowns. In many ways, reducing and planning for your unknowns is the skill of agentic coding. But luckily, this is a skill you can improve at, by working with Claude.

但他们也**预设** unknowns 的存在。在很多层面上，**减少 unknowns、为 unknowns 做规划，就是 agentic coding 的核心技能**。幸运的是，这是个你能通过和 Claude 协作练出来的技能。

---

## Help Claude help you / 让 Claude 帮到你

Instructing Claude is a delicate balance. If you are too specific, Claude will follow your instructions even when a pivot may be more appropriate. If you are too vague, Claude will often make choices and assumptions based on industry best practices that may not be a fit for your task.

**指挥 Claude 是一个微妙的平衡**。你太具体，Claude 会照你说的做，哪怕其实应该改道；你太模糊，Claude 就会基于"行业最佳实践"做选择和假设，而那些可能并不适合你的任务。

When you don't account for your unknowns you fail both ways. You don't know when the path will be filled with obstacles and you don't know when the path will be clear, but you still want Claude to veer.

**当你不为 unknowns 做安排，两边都会失败**。你不知道什么时候路上满是障碍，也不知道什么时候一片坦途——但你仍然希望 Claude 能在该变道时变道。

Claude can help you discover your unknowns faster. It can search through your codebase and the internet extremely quickly and it knows much more about the average topic than you. It can also iterate from failure faster.

**Claude 能帮你更快发现 unknowns**。它能极快地在 codebase 和互联网上搜索，对一般话题的知识也比你多得多。它也能更快地从失败中迭代。

The most important part of this process is to give Claude context about your starting point. For example, tell it where you are in your thought process; disclose your experience with the problem and codebase; and let it work with you like a thought partner.

**这个过程中最重要的一步，是把你的起点交代给 Claude**。告诉它你当前想到哪一步了；坦白你对这个 problem 和 codebase 的经验；让它像思想伙伴一样和你一起工作。

I've previously written about using HTML with Claude, in almost all of these cases, a HTML artifact is the best way to visualize and represent it.

我之前写过[用 HTML 和 Claude 协作的文章](https://x.com/trq212/status/2052809885763747935)，在几乎所有这些场景里，**HTML artifact 都是最合适的可视化和表达方式**。

In this article I detail some of the patterns I use to uncover these unknowns. I don't use every technique each time, but it's a useful collection of techniques to have.

本文我会详细讲我用来挖掘 unknowns 的一些模式。我不会每次都用上所有技巧，但作为工具集，它值得收藏。

---

# Pre-implementation / 实现前

## Blind Spot Pass / 盲点扫描

When starting work, one of the most useful things you can do is understand your blindspots. For example, if you're writing a feature in a new part of the codebase or using Claude to help you with unfamiliar work like iterating on a design, you're likely to have a lot of unknown unknowns.

开工时，最有用的事之一是**理解你的盲点**。比如，你在一个 codebase 的新部分写 feature，或者让 Claude 帮你在不熟悉的领域（比如反复打磨设计）做事——你大概率有大量 unknown unknowns。

You may not know what questions to ask, what good looks like, what historical work has been done or what potholes to avoid.

你可能不知道该问什么问题、不知道"好"长什么样、不知道前人做过什么、不知道该避开哪些坑。

To do this, you can ask Claude to help you find your unknown unknowns and explain them to you. I like to use the literal words "blindspot pass" and "unknown unknowns". Giving it context on who you are and what you know is usually important for

**做法：让 Claude 帮你找你的 unknown unknowns 并解释给你听**。我喜欢直接用 "blindspot pass" 和 "unknown unknowns" 这两个词。**给它交代你是谁、你知道什么**，通常很关键……

> 💬 **示例 Prompt** · Blind Spot Pass
>
> "I'm working on adding a new auth provider but I know nothing about the auth modules in this codebase. Can you do a blindspot pass to help me figure out my relevant unknown unknowns and help me prompt you better."
>
> "我正在给系统加一个新的 auth provider，但我对这个 codebase 的 auth 模块一无所知。能不能帮我做一次 blindspot pass，帮我找出相关的 unknown unknowns，让我能 prompt 得更好？"

> 💬 **示例 Prompt** · 跨领域学习
>
> "I don't know what color grading is but I need to grade this video. Can you teach me to understand my unknown unknowns about color grading, so that I can prompt better?"
>
> "我不知道 color grading 是什么，但我需要给这个视频做调色。能不能教我理解我在 color grading 上的 unknown unknowns，让我能 prompt 得更好？"

## Brainstorms and prototypes / 头脑风暴和原型

When I'm working in an area with a lot of unknown knowns, involving criteria I only know to define when I see it, I like to ask Claude to brainstorm and prototype with me.

当我在一个充满 unknown knowns 的领域工作——"好"的判断标准只有看到了才能描述——我喜欢让 Claude 跟我一起头脑风暴、做原型。

It's extremely valuable to identify and verbalize unknown knowns early during prototyping, because finding them out during implementation can be (relatively) expensive. Small changes in a feature or spec can cause drastically different implementations in code and it can be more difficult for your agent to revert previous changes.

**在 prototype 阶段就识别并说出 unknown knowns 价值巨大**，因为在实现阶段才发现它们，代价要（相对）高得多。feature 或 spec 的小改动，可能让代码实现大不相同，也更难让 agent 回滚之前的改动。

For example, you may just want to see how a button added to a frame looks without having to wire up a backend route or maintaining additional state in the frontend.

比如，你可能只是想**先看看**在 frame 里加个 button 长什么样，而不用真的去接后端路由、也不用在 frontend 维护额外 state。

Visual design is something that for me is difficult to articulate, but I know what I want when I see it. In these cases, I'll ask for several design approaches to an artifact.

视觉设计对我来说是很难讲清楚的事，但我看到就能认出来。这种时候，我会让 Claude 给我**几个不同方向的设计**放进一个 artifact 里对比。

I also start almost every coding session with an exploration or brainstorming phase. This helps me start with intent to define the project's scope. Claude often finds high-value approaches I would have missed and sometimes misses the forest through the trees. Brainstorming prevents me from setting too narrow or too wide a scope.

**我几乎每次写代码会话都从一个探索 / 头脑风暴阶段开始**。这能帮我带着意图去定义项目 scope。Claude 经常能找到我会漏掉的高价值方向，有时也会"只见树木不见森林"。**头脑风暴让我不会把 scope 设得太窄或太宽。**

> 💬 **示例 Prompt** · 多方向设计
>
> "I want a dashboard for this data but I have no visual taste and don't know what's possible. Make me an HTML page with 4 wildly different design directions so I can react to them."
>
> "我想要这批数据的 dashboard，但我没什么视觉品味、也不知道能做到什么程度。给我一个 HTML 页面，放 4 个**完全不一样**的设计方向，让我看着选。"

> 💬 **示例 Prompt** · 假数据原型
>
> "Before wiring anything up, make a single HTML file mocking the new editor toolbar with fake data. I want to react to the layout before you touch the real app."
>
> "在接任何逻辑之前，先用**假数据**做一个单 HTML 文件，模拟新 editor toolbar 长什么样。我要在你动真 app 之前先看 layout。"

> 💬 **示例 Prompt** · 头脑风暴找切入点
>
> "Here's my rough problem: users churn after onboarding. Search the codebase and brainstorm 10 places we could intervene, from cheapest to most ambitious. I'll tell you which ones resonate."
>
> "问题大致是：用户在 onboarding 之后就流失了。在 codebase 里搜搜、头脑风暴 10 个我们能下手的地方——从最便宜到最有野心的。我会告诉你哪些打动我。"

## Interviews / 采访式提问

Once I've done sufficient brainstorming, I likely still have unknowns.

做完一轮头脑风暴，我大概率还有 unknowns。

In this case, I ask Claude to interview me about any unknowns or ambiguities. When asking Claude to interview you, try and give it context about your problem to guide its questions.

**这时，我就让 Claude 来"采访"我，把 unknowns 和歧义点问出来**。让它采访你的时候，记得把 problem 上下文给它，让它能问到点上。

> 💬 **示例 Prompt** · 采访式提问
>
> "Interview me one question at a time about anything ambiguous, prioritize questions where my answer would change the architecture."
>
> "一次问我一个问题，关于所有有歧义的地方。**优先问那些"我的答案会改变架构"的问题**。"

## References / 参考

Sometimes you can't describe what you want in detail. For example, you might not have the language or it might be so complicated that it would take you quite a while.

**有些东西你讲不清楚**。可能是没那个词，也可能复杂到要讲很久。

In this case, the best answer is a reference. While you can include diagrams, documentation or pictures, the absolute best reference is source code.

**这时，最好的答案是"参考"**。可以放图、放文档、放截图，但**最好的参考永远是源码**。

If you have a library that implements something in a certain way or a design component you really like, just point Fable at the folder and tell it what to look for, even if it's in a different language.

如果你有一个库，正好以某种方式实现了你想要的东西，或者一个你很喜欢的设计组件——**直接把 Fable 指向那个文件夹，告诉它看什么就行，哪怕语言不同**。

This is also the way Claude Design works. You don't have to hand it a file (although you can do that too). You can point it at a module on a website you like, and it reads the underlying code, not just the screenshot. This provides much richer detail around the markup, structure, and how the component is actually built.

**Claude Design 走的就是这条路**。你不用非要喂它一个文件（虽然也行）。你可以把一个你喜欢的网站模块指给它，它读的是底层代码、不是截图——这样 markup、结构和组件怎么搭的细节会丰富得多。

> 💬 **示例 Prompt** · 跨语言源码参考
>
> "This Rust crate in `vendor/rate-limiter` implements the exact backoff behavior I want. Read it and reimplement the same semantics in our TypeScript API client."
>
> "这个 `vendor/rate-limiter` 里的 Rust crate，正好有我想要的 backoff 行为。**读它**，在我们的 TypeScript API client 里照着同样的语义重新实现。"

## Implementation Plans / 实现计划

When I think I'm ready to implement, I tend to ask Claude to put together an implementation plan for me to review that focuses on the parts that might be most likely to change, for example to review data models, type interfaces or UX flows. This allows Claude to surface things I might actually need to alter.

**当我以为可以开工了，我倾向于让 Claude 给我出一份实现计划，让我过一遍，重点放在最可能改的部分**——比如数据模型、type interface、UX 流程。这能让 Claude 把"我可能真要改"的东西浮到表面。

> 💬 **示例 Prompt** · 计划里突出可变部分
>
> "Write an implementation plan in HTML, but **lead with the decisions I'm most likely to tweak with**: data model changes, new type interfaces, and anything user-facing. **Bury the mechanical refactoring at the bottom**, I trust you on that part."
>
> "用 HTML 写一份实现计划，**把"我最可能想调"的决定放在最前面**：数据模型改动、新的 type interface、任何面向用户的东西。**机械重构埋到最底下**——那部分我信你。"

---

# During implementation / 实现中

## Implementation notes / 实现笔记

Once I am satisfied with my plan, I make a new session and pass any artifacts to the prompt. For example, I might pass in a spec file and a prototype and ask an agent to implement it.

**计划满意之后，我开一个新 session，把所有 artifacts 塞进 prompt**。比如，把 spec 文件和 prototype 一起塞进去，让 agent 去实现。

But the truth is that no matter how much planning you do, there are always unknown unknowns lurking. The agent may find during its work that it needs to take a different tack due to an edge case it found in the code.

**真相是：不管你规划多细，总有 unknown unknowns 在暗处等着**。Agent 干着干着，可能因为在代码里踩到一个 edge case，必须换条路走。

I ask Claude Code to keep a temporary `implementation-notes.md` (or .html) file where it keeps track of decisions it makes so we can learn from our next attempt.

**我让 Claude Code 维护一个临时的 `implementation-notes.md`（或 .html）文件**，把它的决策记下来，这样下回我们就能从中学到东西。

> 💬 **示例 Prompt** · 维护实现笔记
>
> "Keep an `implementation-notes.md` file. If you hit an edge case that forces you to deviate from the plan, **pick the conservative option, log it under 'Deviations', and keep going**."
>
> "维护一份 `implementation-notes.md`。如果撞到 edge case 让你不得不偏离原计划——**选最保守的那个，记到 'Deviations' 段，继续往下走**。"

---

# Post implementation / 实现后

## Pitches and explainers / 推销稿和说明稿

One of the most important parts of shipping something is getting buy-in and approvals.

**发布东西时，最重要的一步之一是拿到认同和审批**。

Building pitch and explainer artifacts in the final document helps:

**在最终文档里搭一份 pitch 和 explainer artifact 有两个好处**：

- **Accelerate understanding** when reviewers start with the same unknowns you did
  **让 reviewer 不用从和你一样的 unknowns 起步**，更快理解。
- **Accelerate approvals** when experts want to see you accounted for the unknowns and common failure points they would have anticipated
  **当专家想看"你有没有考虑到他们会预想到的 unknowns 和常见失败点"时**，审批会更快。

> 💬 **示例 Prompt** · 一页式推广
>
> "Package the prototype, the spec, and the implementation notes into a single doc I can drop in Slack to get buy-in. **Lead with the demo GIF.**"
>
> "把 prototype、spec 和 implementation notes 打包成一份文档，我能直接丢到 Slack 去求 buy-in。**开头先放 demo GIF。**"

## Quizzes / 考考你

After a long working session, Claude might have accomplished a lot more than I realized. Reading the code diffs can only give me a light understanding of what happened, since much of the behavior will depend on existing code paths.

**一长段协作下来，Claude 干完的活可能比我自己意识到得多**。看 code diff 只能给我个浅理解，因为很多行为取决于已有 code path。

Asking Claude to quiz me about the change after giving me a bunch of context helps me understand what happens. I only merge after I pass the quiz perfectly.

**让 Claude 在给完我一堆 context 之后"考"我，能帮我真正理解发生了什么**。**我得答对了才 merge。**

> 💬 **示例 Prompt** · 合并前小测验
>
> "I want to make sure I understand everything that's happened in this change. Give me a HTML report on the changes for me to read and understand with context, intuition, what was done, etc. and **a quiz at the bottom on the changes that I must pass.**"
>
> "我想确保自己完全理解这次改动发生了什么。给我一份 HTML 报告，写清 context、intuition、改了啥等等——**最底下放一份关于这次改动的 quiz，我必须答对。**"

---

# How this comes together: launching Fable / 这套方法如何落地：Fable 发布

The launch video for Fable was edited entirely by Claude Code. This was a new domain for me and I'm by no means an expert.

**Fable 的发布视频，全程由 Claude Code 剪辑**。这是我完全没接触过的领域，我也绝不是专家。

So I started with what I did know. I knew that Claude could use code to edit videos and transcribe them, but I wasn't sure if it was accurate enough.

**所以我从"我知道什么"开始**。我知道 Claude 能写代码剪视频、转录音，但我不知道它转录得准不准。

I then asked Claude to explain to me how transcription like Whisper worked, and whether I would be able to accurately cut out things like ums or large pauses using ffmpeg.

**我让 Claude 给我讲 Whisper 之类的转录是怎么工作的**，问它我能不能用 ffmpeg 精准地剪掉 "um" 和大段停顿。

I wanted Claude to create a UI that was timed with the words I was saying, but wasn't sure if it would be able to so I asked Claude to create a prototype video using Remotion and a transcription to see if it would work.

**我想要一个 UI 能跟我说的词同步**，但不确定 Claude 能不能做到——我就让它用 [Remotion](https://www.remotion.dev/) 加转录做个 prototype 视频，看看行不行。

Finally, the video itself looked a bit muted, which I knew was the result of color grading but I didn't really know what color grading was. My first pass attempt was to try and get Claude to do a few variations to pick, but I realized that I didn't know what "good" looked like when it came to color grading. So instead, I asked Claude to teach me about color grading to discover my unknowns.

**最后，视频看起来有点"灰"——我知道那是 color grading 的结果，但我真的不知道 color grading 是什么**。我第一版想让 Claude 做几个变体让我挑，但我意识到**我根本不知道 color grading 里"好"长什么样**。所以我让 Claude **教**我 color grading，让我先发现我的 unknowns。

---

# Matching the Map and Territory / 让地图对齐疆域

The better models get, the more you can achieve with the right approach. When a long-horizon task comes back wrong, it's likely you need to spend more time defining your unknowns or creating an implementation plan that allows for Claude to improvise through them.

**模型越强，方法对了你能做到的就越多**。长周期任务做砸了，大概率是因为你**没花够时间定义你的 unknowns**，或者没做出一份能让 Claude 即兴发挥的实现计划。

> 🌟 Every explainer, brainstorm, interview, prototype, and reference is a cheap way to find out what you didn't know before it gets expensive to fix.
>
> **每一个 explainer、brainstorm、interview、prototype、reference，都是在"修起来贵"之前低成本发现"我不知道什么"的方法。**

So start your next project by asking Claude to help you find your unknowns.

**所以——下一个项目，开局就让 Claude 帮你找 unknowns。**

---

## 配套资源 / Resources

- **示例 Artifacts**：[thariqs.github.io/html-effectiveness/unknowns/](https://thariqs.github.io/html-effectiveness/unknowns/) — 作者为本文准备的实物 demo
- **HTML 与 Claude 协作前文**：[x.com/trq212/status/2052809885763747935](https://x.com/trq212/status/2052809885763747935)
- **Fable 发布视频完整流程**：[x.com/ClaudeDevs/status/2064399512664526853](https://x.com/ClaudeDevs/status/2064399512664526853)
- **视频内详细解说**：[x.com/trq212/status/2064826394589442448](https://x.com/trq212/status/2064826394589442448)

---
