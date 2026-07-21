---
layout: post
title: "Show HN: isometric.nyc – giant isometric pixel art map of NYC / Isometric NYC：巨型 isometric 像素艺术纽约地图"
tags: [gamedev, ai-coding]
---
> 作者：[Andy Coenen](https://github.com/cannoneyed)（[@cannoneyed](https://x.com/cannoneyed)，Google 工程师） · 2026-01-22 · [Show HN](https://news.ycombinator.com/item?id=46721802) · **1,325p / 241c** · [GitHub 90⭐](https://github.com/cannoneyed/isometric-nyc) · [Live](https://isometric.nyc)

> **AI 生成的巨型 isometric 像素艺术 NYC 地图**。整个 codebase 由 Claude Code / Gemini CLI / Cursor 协作完成，作者本人看过的代码 < 1%。

---

## ⚠️ 这是 vibe-engineering 的活样本 ⚠️

> This codebase was built entirely via collaboration with coding agents such as gemini-cli, Claude Code, and Cursor. As such, **the code probably sucks**. Honestly, I've looked at less than 1% of it, and I didn't write any of it by hand. YMMV, but because this was partly an exercise in pushing "vibe-engineering" to its limits I bought fully into the "hands-off" approach and the results speak for themselves.

**本 codebase 完全由 coding agents 协作完成**——`gemini-cli` / [Claude Code](https://code.claude.com/docs/en/overview) / [Cursor](https://cursor.com/)。**代码很可能很烂。说实话，我看过的代码不到 1%，我没手写一行。** 效果因人而异，但既然部分目的是把「vibe-engineering」推到极限，我完全采取了「不插手」态度，结果说明一切。

> After the initial reception to isometric.nyc, I decided to open source the repo, which means cleaning up and organizing a lot of cruft and temporary, long-forgotten tools. **Some of this cruft is still around, and will likely never get around to getting cleaned up.**

收到初次反馈后决定开源，意味着要清理一堆 cruft 和临时工具。**有些 cruft 还在，估计永远不会被清掉。**

> I also used a lot of services to help bring this project to life, some of which are cheap, but aren't cheap to run at scale.

也用了一堆服务来带这个项目活起来——有些便宜，但跑起来不便宜。

**Vault 注解**：作者**明确说代码烂、不维护、看不下去**——但这是这个项目最重要的设计决策。**「人类不读代码，只看效果」**。它不是产品，是**实验**。

---

## The Idea
## 想法源头

> Growing up, I played a lot of video games, and my favorites were world building games like SimCity 2000 and Rollercoaster Tycoon. As a core millennial rapidly approaching middle age, I'm a sucker for the nostalgic vibes of those late 90s / early 2000s games.

> As I stared out at the city, I couldn't help but imagine what it would look like in the style of those childhood memories.

> So here's the idea: **Make a giant isometric pixel-art map of New York City.** And I'm going to use it as an excuse to push hard on the limits of the latest and greatest generative models and coding agents.

**90 后末班车的中年人**，怀念 90s/00s 初的游戏。看着 NYC 的天际线，忍不住想——**用童年游戏的风格重画一遍会是什么样？** 想法落地：**做一张巨型 isometric 像素艺术的 NYC 地图**。顺便把这当成推动最新 generative model + coding agent 极限的借口。

> SimCity 2000、Rollercoaster Tycoon → 童年 → 「重画 NYC」 → vibe-engineering 实验

---

## 技术栈分层
## Stack Breakdown

isometric.nyc 不是单一应用，而是 **4 层架构**：

### 1. 数据层：3D 渲染（卫星图）
### Layer 1: 3D Satellite Renders

- 输入：lat/lng（地标坐标）
- 几何：NYC 建筑 foot print + height（NYC OpenData）
- 渲染：orthographic 3D 视图，固定 azimuth -15° / elevation -45°（isometric 标准角度）
- 输出：1024×1024 px PNG / quadrant（4×4 sub-tile = 256×256 each）
- **目的**：给 fine-tuned image-edit 模型提供「几何结构参考」

### 2. AI 模型层：fine-tuned Qwen/Image-Edit
### Layer 2: Fine-tuned Image-Edit Models

> The model that generated the vast majority of the tile data was a **fine-tuned `Qwen/Image-Edit` model** trained on [oxen.ai](https://oxen.ai).

主生成模型：**在 oxen.ai 上 fine-tune 的 Qwen/Image-Edit**。

> These models were trained on an **"omni" infill task** — essentially they were trained to generate pixel-art-style data in an image with some portion of previously-generate pixel data "masked" with a rectangle of raw, orthographically rendered 3D tiles satellite data.

**核心训练任务：omni infill**——给模型一张「左边已生成的像素艺术 + 右边被 mask 掉的 3D 卫星渲染」，让它生成右边的像素艺术，**无缝衔接左边风格**。

**三个主模型版本**（命名是 Oxen 自动生成的）：

| Model | 数据集 | 用途 |
|---|---|---|
| `cannoneyed-rural-rose-dingo` | omni_v04.csv | Omni infill + 水域瓦片 |
| `cannoneyed-quiet-green-lamprey` | omni_v04.csv | Omni infill + 更多树 |
| `cannoneyed-dark-copper-flea` | omni.csv | v2 + 更多地形（默认模型）|

### 3. 推理层：Modal 上的 LoRA server
### Layer 3: Modal LoRA Inference

> The inference server is a [Modal](https://modal.com/) deployment that serves Qwen/Image-Edit + LoRA adapter.

**推理跑在 Modal**（serverless GPU 云平台），挂载 LoRA adapter。

```bash
# 部署默认模型
uv run modal deploy inference/server.py

# 部署特定 LoRA
LORA_MODEL_ID=another-model-id uv run modal deploy inference/server.py
```

> Both commands print the endpoint URLs.

Endpoint 形如 `https://your-workspace--qwen-image-edit-server-imageeditor-edit-b64.modal.run`

### 4. 应用层：Web 端 + 多个 layer 应用
### Layer 4: Web App + Layers

```
src/
├── app/                       # 主 Web 应用
│   ├── React + OpenSeaDragon  # 瓦片查看器（DZI 格式）
│   └── worker/                # web worker
├── web_render/                # 3D 渲染 viewer（Three.js）
└── layers/                    # 多个风格叠加层
    ├── dark_mode/             # 暗黑模式
    ├── snow/                  # 雪景
    └── water_shader/          # 动态水波 WIP
```

> The web application uses OpenSeaDragon and the DZI tile viewer format.

**主 viewer 用 OpenSeaDragon + DZI 金字塔格式**（业界标准 deep-zoom viewer，跟 Google Maps 瓦片底层原理一致）。**瓦片是预渲染的**——不是实时生成。

> The web application uses OpenSeaDragon and the DZI tile viewer format. This repo ships with a pre-computed DZI image pyramid, but you can reconstruct it at any time by running the `export_dzi` script:

```bash
uv run python src/isometric_nyc/generation/export_dzi.py
```

**生产数据**：~32k 个生成的 tile "quadrants"，存在 [oxen.ai/cannoneyed/isometric-nyc-tiles](https://www.oxen.ai/cannoneyed/isometric-nyc-tiles)

**Layer 应用**（4 个独立 web app）：
- 主 viewer（dark_mode / 默认）
- 雪景 layer（`src/layers/snow/`）
- 动态水波 layer（`src/layers/water_shader/`，WIP）

> The shader uses a **distance mask** approach: black = land, white = deep water, gradient = shoreline (foam)

---

## 数据流：从 NYC 地标到像素瓦片
## Data Pipeline

```
NYC OpenData (building footprints)
    │
    ▼
3D 卫星 ortho 渲染 (1024×1024 PNG)
    │ (lat/lng anchor, quadrant grid)
    ▼
┌─ Generation Tool (web app)
│   - select 4 quadrants
│   - "Generate" → call Modal/Oxen/Nano Banana
│   - rules: 2x2 must not touch existing; 1x2 OK if adjacent
│
├─ Output: quadrant PNG (pixel art)
│
└─ SQLite DB (per generation dir)
    - Quadrants table: Id, Lat, Lng, Render (bytes), Generation (bytes),
                        IsGenerated (bool), Notes
    ▼
DZI tile pyramid (export_dzi.py)
    ▼
isometric.nyc (OpenSeaDragon viewer, R2-hosted)
```

### 关键决策

**1. 为什么用 quadrant (4×4 sub-tile) 而不是整 tile？**

> Rather than storing tiles, we'll be storing "quadrants" — each tile is divided into a 4x4 grid of quadrants. Each quadrant will have an "anchor" lat/lng corresponding to its bottom right corner. In this way, **the top left quadrant of a tile will have the same lat/lng "anchor" as the "centroid" of the tile.**

**每个 tile 拆成 4×4 = 16 个 quadrant，每个 quadrant 用「右下角」lat/lng 作为 anchor**。这样**瓦片可以无缝拼接**——上一片的 top-left quadrant 跟当前 tile 的 centroid 用同一个坐标。**核心工程技巧：共享 anchor 实现无缝**。

**2. 2×2 generation 规则**

> A 2x2 generation is only legal if the 2x2 tile does not touch any previously generated quadrants

```
XXXXXGG  XXXXX
XXSSXGG  XXSSG
XXSSXGG  XXSSG
XXXXXGG  XXXXX
✅ OK    ⛔ NO

X = empty, S = selected, G = generated
```

**2×2 必须悬空**——避免新生成的 2×2 跟现有 quadrant 重叠导致 seam。这是「拼图正确性」的硬约束。

**3. 为什么是 Nano Banana + Qwen/Image-Edit 而不是直接用 Stable Diffusion？**

> These synthetic datasets were assembled from render→generation pairs generated with Nano Banana, using a marimo notebook in `src/notebooks/nano-banana.py`.

**训练数据对**：(3D 卫星渲染) ↔ (Gemini 生成的像素艺术)。用 [Nano Banana](https://gemini.google/overview/image-generation/) 当「教师」，合成训练对。然后 fine-tune Qwen/Image-Edit 到「学生模型」，专门做这个任务。

**这是个聪明的范式**：用「教师模型合成数据」+「开源学生模型专门化」+「serverless 推理」三层分工。

---

## 🧠 Agent 操作系统：vibe-engineering 的工程现场
## The Agent OS: Vibe-Engineering in the Wild

**这是这个项目最值钱的部分。** codebase 里有一套**完整的「给 AI agent 看」的基础设施**：

### 1. AGENTS.md / CLAUDE.md（agent 总纲）

```markdown
# Isometric NYC

This repo contains the code for generating an isometric pixel art view
of New York City using the latest and greatest AI tools available.

## Technology Stack
* Language: Python (version in pyproject.toml)
* Package Manager: uv (Strictly used for all dependency management)
* Testing: pytest
* Linting/Formatting: ruff

## Environment & Dependency Management (uv)
**Crucial: Do not use pip, poetry, or conda.** This project relies
entirely on uv.

## Coding Standards
1. Type Hints: All function signatures must include Python type hints.
2. Imports: Use absolute imports for project modules.
3. Configuration: All project metadata must reside in pyproject.toml.
4. Lockfile: Never ignore uv.lock.
```

> **Crucial: Do not use pip, poetry, or conda.** — 这句是写给 AI 的！人类读者不需要这种强调。

`AGENTS.md` 和 `CLAUDE.md` **内容几乎完全一样**——一份给通用 agent，一份专门给 Claude。**说明这个 codebase 的目标用户是 AI 而不是人类开发者**。

### 2. tasks/ 目录（agent 任务脚本）

```
tasks/
├── 001_initialize_project.md        # 用 uv 起项目
├── 002_simplest_generation.md       # 最简单的生成 pipeline
├── 003_citygml.md                   # 用 CityGML 数据
├── 004_tiles.md                     # tile 系统设计
├── 005_oxen_api.md                  # 接 Oxen API
├── 006_infill_dataset.md            # infill 数据集
└── 007_e2e_generation.md            # 端到端生成
```

**每个 task 是一个 markdown 文件——agent 读它就执行。**

### 3. 完整任务示例：tasks/007_e2e_generation.md

```markdown
# Isometric NYC E2E Generation

OK we have all the pieces needed to generate a massive isometric pixel
art map of NYC! We've fine-tuned a model that can generate pixel art
from a 3D rendered tile, as well as "infill" from a template that has
one or more quadrants from a neighboring tile.

The first step we'll need to decide on is a database of tiles...

A generation is defined with the following config:

generation_config.json:
{
  "name": "...",
  "seed": { "lat": ..., "lng": ... },
  "bounds": { ... },
  "camera_azimuth_degrees": -15,
  "camera_elevation_degrees": -45,
  "width_px": 1024,
  "height_px": 1024,
  ...
}

From this generation config, we'll construct a grid of tiles. Each tile
is an isometric view centered on a centroid...

Rather than storing tiles, we'll be storing "quadrants" — each tile is
divided into a 4x4 grid of quadrants. Each quadrant will have an "anchor"
lat/lng corresponding to its bottom right corner. In this way, the top
left quadrant of a tile will have the same lat/lng "anchor" as the
"centroid" of the tile.
```

**注意语气**：「OK we have all the pieces」「Let's first create a new directory `src/isometric_nyc/generation` and create a new python script called `seed_tiles`」「This process should follow the logic of `src/isometric_nyc/plan_tiles.py`, with the following changes:」

**这是写给 AI agent 的实施说明书**，语气就像你对一个新入职的工程师说话。

### 4. AGENT_LOG.MD：迭代循环的现场记录
### The Generation Loop

**最精彩的现场证据**——`src/isometric_nyc/tile_generation/agent_log.md`：

```
Generation: generate_tile_001.py
Checker: {
  "description": "The right half looks like 3D render instead of pixel art",
  "status": "BAD",
  "issues": [2, 3, 4]
}

Generation: generate_tile_002.py
Checker: { "status": "GOOD", ... } (technical)
User Feedback: "No - it's really bad... whitebox building, pixelated,
fragmented border. Try again"

Generation: generate_tile_003.py
Checker: { "status": "GOOD" }
User Feedback: "It's really pretty good! Let's try to iterate..."

Generation: generate_tile_004.py
Checker: { "status": "GOOD" }
User Feedback: "still quite a few buildings that are blurry/pixelated"

Generation: generate_tile_005.py
Checker: { "status": "BAD", "issue": "Texture translation failure:
blank white geometric blocks" }

Generation: generate_tile_006.py
...
```

**6 次迭代的真实轨迹**：v1 BAD（风格错）→ v2 技术 OK 但 user BAD → v3 user OK（"pretty good"） → v4 user 仍有瑕疵 → v5 BAD（白盒子建筑）→ v6...

### 5. agent_plan.md：循环的元规范
### The Meta-Spec for the Loop

```markdown
# Agent Plan

Your task is to debug an image generation workflow. The goal is to generate
an isometric pixel art image of a small section of New York City...

1. If a generation.png exists and we have > 1 generate_tile script,
   skip to step 3.

2. Run the latest generation script.
   uv run python src/isometric_nyc/tile_generation/generate_tile_<nnn>.py

3. Run the checker script.
   uv run python src/isometric_nyc/tile_generation/check_generation.py

4. Write the results of the run and checker to the agent_log.md file
   in the following format:
   Generation: ... Checker: ...

   IMPORTANT: Append these lines to the agent_log, do not overwrite it!

5. If the generation is good, then prompt the user for manual feedback.
   You may celebrate IF AND ONLY IF THE USER SAYS IT'S GOOD!

6. If the generation has issues, then create a copy of the generation
   script with the version number incremented and update the script
   to address the issues with the checker.

You may update any part of the generate_tile function, including changing
which reference images are used, how they're supplied to the model, and any
optional processing you might want to do on them. However you MAY NOT
change the model (gemini-3-pro-image-preview) or how the output is saved.
```

**这基本上就是 Loop Engineering 的生产实现**：
- Generation（生成）
- Verification（独立 checker 脚本）
- Log append（不覆盖历史）
- User feedback checkpoint（"celebrate IF AND ONLY IF THE USER SAYS IT'S GOOD"）
- Iteration（复制 + 改 prompt）
- 硬约束（不允许改 model，只允许改 prompt）

---

## 三个 fine-tune 模型的差异化策略
## The 3-Model Strategy

| 模型 | 用途 | 数据 |
|---|---|---|
| `rural-rose-dingo` | 通用 + 水域瓦片 | omni_v04.csv |
| `quiet-green-lamprey` | 通用 + 更多树 | omni_v04.csv |
| `dark-copper-flea`（默认）| 通用 + 更多地形 | omni.csv |

**三个模型的训练数据共享 v04（基础）+ 各自 add-on**：水域、树、地形。**这意味着模型的「风格」可以切换**——同一个建筑区用不同模型生成会有不同变体。**可能是为了在生产里随机选模型避免视觉单调**。

---

## 我的点评（Vault 视角）

### 这个项目真正牛在哪

**不是技术牛。是「实验设计」牛。**

1. **「代码烂」不是事故，是设计**——作者把整个项目设计成 **AI 能读、AI 能改、AI 能 debug** 的结构。AGENTS.md / CLAUDE.md / tasks/*.md / agent_log.md / agent_plan.md——这套文档体系**让 codebase 在「人类视角」和「AI 视角」之间无缝切换**。

2. **「Teacher model → student model」流水线**——
   - Teacher: Nano Banana (Gemini image gen)
   - Training data: ortho 卫星渲染 + Nano Banana 像素艺术（pair）
   - Student: Qwen/Image-Edit + LoRA
   - Inference: Modal serverless GPU
   
   **不是「用 LLM 写代码」那么浅**，是**「用 LLM 训练模型专门干这个活」**。

3. **Quadrant + shared anchor** 是**拼图正确性的核心创新**。4×4 = 16 个子瓦片，每个子瓦片用右下角做 anchor → 上一片的 TL 跟下一片的 centroid 坐标重合 → **瓦片天然可拼接，不会 seam**。这比「贴在一起看运气」高到不知道哪里去了。

4. **Layer 应用分多个独立 web app**（dark_mode / snow / water_shader）——每个 layer 是独立的 React + Vite + Bun 应用，**而不是单个 monolithic app 的多个 toggle**。这让每个 layer 可以独立开发、独立部署、独立被 AI 改。**又一次「为 AI 工程优化」**。

5. **3 个 fine-tune 模型共享数据 + 不同 add-on**——这是 **A/B 测试模型差异化的工程化做法**，比「训一个大模型」更有弹性。

### 跟 Hex-Map-WFC 的对照

| | Hex-Map-WFC | Isometric-NYC |
|---|---|---|
| **范式** | Constraint solver + GPU shader | Generative AI + 预渲染瓦片 |
| **生成时机** | 实时（20s/4,100 cells） | 离线（~32k quadrants 预生成） |
| **数据源** | 纯算法（无外部数据）| NYC OpenData + 3D 渲染 + Nano Banana |
| **AI 用法** | 无（手写 solver）| Teacher-student fine-tune + agent 写代码 |
| **美学定位** | 抽象中世纪地图（custom built）| 像素艺术 NYC（地理真实）|
| **对 AI 工具的态度** | 不用 AI | 完全 vibe-engineered |
| **核心创新** | Multi-grid recovery + TSL shader | Quadrant shared anchor + agent 基础设施 |

**两者代表了程序化地图的两条不同路线**：
- **Hex-Map-WFC**：「算法精确 + GPU 实时 + 抽象风格」——给制图师、游戏开发者、AI 生成内容的**素材层**
- **Isometric-NYC**：「AI 风格化 + 离线批量 + 真实地理」——给**消费级 Web 应用**

---

## 这个项目对「AI coding 极限」的实证

| 维度 | 观察 |
|---|---|
| **AI 写代码** | ✅ 整个 codebase AI 写，人类看 < 1% |
| **AI 设计 prompt** | ✅ `agent_plan.md` 提示工程由 agent 自己迭代 |
| **AI 调试** | ✅ `generate_tile_NNN.py` 6 次迭代全是 AI 改 prompt |
| **AI 做评估** | ✅ `check_generation.py` 是独立脚本给生成打分 |
| **AI 写工具** | ✅ Generation tool UI 也是 AI 写的 |
| **人类做什么** | ✅ 最后拍板 "is it good?" + 选 prompt 方向 + 偶尔给方向反馈 |

**结论**：在「生成 + 验证 + 迭代」封闭循环里，AI coding 几乎可以端到端跑通。**人类只在 loop 的「打钩」环节出现**。

---

## 启示（对我 / Adam）

### 对 build-ai-tour-guide 的具体启发

1. **「Quadrant + shared anchor」可以直接迁移**——把 OSM 地图数据按 quadrant 切，每片用「右下角经纬度」做 anchor，预渲染 → 拼起来。这比「实时调用 OSM tile server」**快且可控**。
2. **「Teacher → student fine-tune」是 OSM 数据风格化的解法**——OSM 数据太「干净」（building:levels、roof:shape 大量缺失），可以先生成「OSM 干净版 + LLM 风格的低多边形」pair 数据，再 fine-tune 一个专门模型做「OSM → 漂亮 3D」的转换。
3. **「Layer 应用独立化」适合 AI Tour Guide 的「同一城市不同视角」**——白天 / 夜晚 / 雪景 / 历史模式 都是独立 app，可独立 vibe-engineer。

### 对「vibe-engineering 方法论」的启发

1. **AGENTS.md / CLAUDE.md** 应该是**所有 AI-heavy 项目的标配**——人类开发者也应该按这个模式写仓库。
2. **tasks/ 目录的"任务脚本"** 比 GitHub Issues 更适合 AI 时代——issue 是给人类评论用的，task 是给 agent 执行用的。
3. **agent_log.md** 这种**「迭代历史」文件**让项目的「决策过程」可追溯、可回放。**比 commit log 更高级**——commit log 只记录「做了什么」，agent_log 记录「为什么这样做、尝试过什么、失败过什么」。
4. **独立的 checker 脚本**让 verification 不依赖人类判断——可以批量化跑。
5. **「IF AND ONLY IF THE USER SAYS IT'S GOOD」**——**人类 happy path 是被显式约束的**，避免 AI 自嗨。

---
