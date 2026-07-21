---
layout: post
title: "程序化地图在 Web 上的三条路线 / Three Roads to Procedural Maps on the Web"
tags: [gamedev, procgen]
---
> **TL;DR**：在 web 上做程序化地图有三条本质不同的路线——**算法路线**（Hex-Map-WFC）、**生成式 AI 路线**（Isometric-NYC）、**WFC / Wang Tile 路线**（Townscaper / TownBuilder）。它们在「数据源」「生成时机」「美学」「对 AI 工具的态度」上完全不同，但**在工程层面共享一些关键模式**。

---

## 为什么这个对比重要

调研 Hex-Map-WFC 和 Isometric-NYC 时，我意识到它们**不是「两种实现」，是「两个物种」**：

- Hex-Map-WFC 是一个**算法驱动的实时地图生成器**——按按钮 20 秒得到 4,100 个 cell
- Isometric-NYC 是一个**AI 驱动的离线瓦片预渲染系统**——32k 个 quadrant 提前生成好

两者都叫「procedural map」，但技术栈、美学定位、风险模型、社区认知完全不同。

加上之前 build-ai-tour-guide 里调研过的 Townscaper/TownBuilder，我们其实有**三条不同的路线**。本文把它们并排放好，给未来的自己（和你）一张参考地图。

---

## 三条路线总览

| | **路线 A：算法路线** | **路线 B：生成式 AI 路线** | **路线 C：WFC / Wang Tile 路线** |
|---|---|---|---|
| **代表** | Hex-Map-WFC | Isometric-NYC | Townscaper / TownBuilder |
| **核心机制** | Constraint solver + GPU shader | Teacher→Student fine-tune + 预渲染 | WFC + 9-vertex cube module |
| **生成时机** | **实时**（按按钮 20s） | **离线**（提前批量） | **实时**（每帧增量） |
| **数据源** | 纯算法（无外部数据）| NYC OpenData + 3D 渲染 + 教师模型 | 手画的小瓦片集 |
| **美学** | 抽象中世纪风格 | 像素艺术 + 真实地理 | 抽象色彩缤纷风格 |
| **输出** | Three.js 实时场景 | 瓦片金字塔（DZI 格式）| 实时 3D 街区 |
| **AI 工具用在哪** | 不怎么用 | 写代码 + 生成训练数据 + 推理 | 不怎么用 |
| **代码可维护性** | 高（手写） | 低（vibe-engineered，"代码可能很烂"） | 中（Oskar Stålberg 内部代码） |
| **代表作** | Felix Turner 个人项目 | Andy Coenen 个人项目（Google 工程师）| Oskar Stålberg（Bad North / Townscaper）|

---

## 路线 A：算法路线（Hex-Map-WFC 范式）

### 核心理念

**用算法精确控制每一片瓦片的状态，用 GPU shader 做出漂亮效果。** 数据从 0 开始，纯算法生成。

### 关键技术模式

1. **多 grid 拓扑**（19 个 hex grid 排成 hex-of-hexes）
   - 大 grid 容易失败 → 拆成小 grid
   - border 瓦片是固定约束
   - **类比**：地图分块（district）

2. **分层恢复系统**（L1 Unfixing → L2 Local-WFC → L3 Drop-and-hide）
   - 失败 → 降级处理
   - **类比**：Git 的 merge → rebase → reset

3. **「WFC + Noise」分工**
   - WFC 处理地形（局部 edge 匹配）
   - Noise 处理装饰（大尺度聚类）
   - **类比**：compiler + optimizer

4. **「Same Material + BatchedMesh」渲染优化**
   - 单 draw call 渲染 38 个 BatchedMesh
   - **类比**：text rendering（共享 atlas）

5. **Cube coordinates (q, r, s)** 替代 offset coordinates
   - 找邻居变 trivial
   - **类比**：UUID 替代自增 ID

6. **多层 Post-Processing**
   - AO + DoF + Vignette + Grain
   - **类比**：photoshop 滤镜链

### 适用场景

- **需要精确控制**的程序化内容（游戏、关卡、地图编辑器）
- **数据稀缺的抽象风格**（幻想地图、关卡设计）
- **实时交互**场景（编辑器、预览）

### 风险

- **大尺度结构不好**——道路网络、城镇分布需要模板先打底
- **算法复杂度高**——multi-grid recovery、cove problem 这些 hack 难调

### 学习成本

- 中-高（要懂 WFC、约束求解、Three.js、TSL shader）
- **关键资源**：[Maxim Gumin 原版 WFC](https://github.com/mxgmn/WaveFunctionCollapse)、[Boris the Brave](https://www.boristhebrave.com/)、[Red Blob Games Hexagonal Grids](https://www.redblobgames.com/grids/hexagons/)

---

## 路线 B：生成式 AI 路线（Isometric-NYC 范式）

### 核心理念

**用「教师模型合成训练数据」+「开源学生模型专门化」+「serverless 推理」三层分工。** 算法路线做不出来的事（比如「把 3D 卫星图变成 SimCity 2000 风格」），AI 做得很好。

### 关键技术模式

1. **Teacher-Student Fine-tune 流水线**
   - Teacher: Nano Banana (Gemini image gen)
   - Training pair: (ortho 渲染) ↔ (像素艺术)
   - Student: Qwen/Image-Edit + LoRA
   - Inference: Modal serverless GPU
   
   **核心 insight**：不要直接用大模型，要**专门化一个小模型到一个任务**

2. **「Quadrant + Shared Anchor」拼图机制**
   - 4×4 quadrant，每片用「右下角」做 anchor
   - 上一片的 TL = 下一片的 centroid
   - **瓦片天然可拼接，不会 seam**

3. **AGENTS.md / CLAUDE.md 文档基础设施**
   - 写给 AI 而不是人类
   - 约束（如 "Do not use pip"）要给 AI 看
   - **AGENTS.md = 通用 agent 总纲；CLAUDE.md = Claude 专用**

4. **tasks/*.md 任务脚本**
   - 每个 task = 一个 markdown 实施说明书
   - Agent 读它就执行
   - **task 文件可以由 agent 自己改（clarify / add）**

5. **agent_plan.md + agent_log.md 迭代循环**
   - **Generation → Verification → Log → User feedback → Iterate**
   - **IF AND ONLY IF THE USER SAYS IT'S GOOD**：人类只在拍板环节出现
   - **不允许改 model，只允许改 prompt**（硬约束）

6. **Layer 应用独立化**
   - dark_mode / snow / water_shader = 4 个独立 web app
   - 每个 app 独立开发、独立 vibe-engineer、独立部署
   - **不是 monolithic app + toggle**

7. **3 个 fine-tune 模型共享数据 + 不同 add-on**
   - 风格可以切换 → 避免视觉单调
   - A/B 测试模型差异化的工程化做法

### 适用场景

- **真实地理数据的艺术化**（NYC → 像素艺术）
- **需要人类审美但量大**（32k quadrant 手工做不可能）
- **接受「代码不可维护」换取「效果交付」**

### 风险

- **成本高**——serverless GPU 不便宜
- **质量不稳**——`agent_log.md` 显示 6 次迭代才能稳定
- **代码不可维护**——vibe-engineered 仓库 1 年后就成废墟
- **「seam」风险**——infill 模型在边缘处风格可能错

### 学习成本

- **AI 工具**：高（要懂 fine-tune、LoRA、prompt engineering）
- **Web 栈**：中（React + OpenSeaDragon + Three.js + Bun）
- **关键资源**：[Qwen/Image-Edit](https://huggingface.co/Qwen)、[Modal](https://modal.com/)、[Oxen.ai](https://oxen.ai)、[OpenSeaDragon](https://openseadragon.github.io/)

---

## 路线 C：WFC / Wang Tile 路线（Townscaper / TownBuilder 范式）

### 核心理念

**用 WFC 但约束极简，用 9 顶点 cube 模块做实时生成。** 这是商业游戏常用的路线——「实时 + 抽象 + 可玩」。

### 关键技术（来自 build-ai-tour-guide 调研）

> 参考：Oskar Stålberg（[Beyond Townscaper SGC21 演讲](https://www.youtube.com/watch?v=Uxeo9c-PX-w&pp=ygUhdG93bnNjYXBlcg%3D%3D)）

1. **9 顶点 cube 模块**：每个 cube 9 个顶点（8 corner + 1 center），6 种连接类型（Horizontal/Above/Below 各 2）
2. **3 种连接类型**：Horizontal（同级相连）、Above（上一级）、Below（下一级）
3. **简化 WFC 用 6 条规则**：顶底匹配、侧面对称、中心点单选、对称性等
4. **不需要完整 WFC**：纯规则 + 程序化装饰效果就够

### 跟路线 A 的关系

- **路线 A（Hex-Map-WFC）**：用完整 constraint solver + DFS + backtracking，解决大规模 hex grid 问题
- **路线 C（Townscaper）**：用极简规则（6 条）+ cube 模块，实时生成城市街区

**复杂度阶梯**：路线 A > 路线 C（A 解决"任意地形的 hard 约束问题"，C 解决"立方体堆叠的 soft 约束问题"）

### 适用场景

- **商业游戏**（Bad North、Townscaper、Mini Metro）
- **实时交互**（每帧都要重算）
- **抽象 + 风格化**（不追求真实地理）

### 学习成本

- **WFC 基础**：中（要懂约束求解思想，但 6 条规则级别）
- **Three.js / GPU**：中
- **关键资源**：[Oskar Stålberg 博客](https://oskarstalberg.com/)、[TownBuilder GitHub](https://github.com/eliemichel/TownBuilder)

---

## 三条路线的共同工程模式

不管选哪条路线，**以下工程模式是通用的**：

### 模式 1：算法分工（Algorithm Specialization）

> Each tool does what it's good at.

```
WFC    → 局部 edge 匹配、地形连贯
Noise  → 大尺度聚类、装饰分布
LLM    → 语义理解、风格化
Templates → 大尺度结构（道路、城镇）
```

**任何程序化系统都不应该「一个算法干所有事」**。

### 模式 2：分层降级（Layered Degradation）

```
L1: 标准求解（最快，覆盖 80% 场景）
   ↓ 失败
L2: 局部重解（贵一点，覆盖 15% 场景）
   ↓ 失败
L3: 用自然元素掩盖（山脉、绿树、海洋，覆盖 5% 场景）
```

**Hex-Map-WFC 的 Unfixing → Local-WFC → Drop-and-hide 是教科书例子**。

### 模式 3：多 grid 拓扑（Multi-Grid Topology）

```
大 grid → 拆成 N 个小 grid
每个小 grid 独立求解
border 共享约束
```

**适用于**：地图分块、城市分区、瓦片金字塔。

### 模式 4：「同材质 + BatchedMesh」渲染优化

```
所有 mesh 共享一个材质
每个 mesh 独立几何 + transform
GPU per-instance 处理
单 draw call 渲染数千对象
```

**任何「大量相似几何体」渲染场景的标配**。

### 模式 5：动态 Shadow Map

```
shadow frustum 每帧 fit 到相机视野
zoom out → 全图覆盖 + 低分辨率
zoom in → 自动收紧 + 高分辨率
```

**避免 blocky shadow artifacts**。

### 模式 6：Cube / 极简坐标系

```
offset coordinates (x, y) → 边界条件、奇偶行不同
cube coordinates (q, r, s) → 找邻居 trivial、对称性
```

**WFC 不在乎几何**——这是个独立选择。

### 模式 7：Post-Processing 链路

```
GTAO (Ambient Occlusion)
   ↓
Depth of Field (tilt-shift 微型感)
   ↓
Vignette + Film Grain (analog 感)
   ↓
Color Grading (季节/情绪)
```

**让算法输出从「可看」变成「想去」**。

### 模式 8：「Easy Solution is the Correct Solution」

```
Voronoi 4 层 noise → 太重 → caustic texture + simple mask
blur 梯度 → 共线 → CPU surroundedness probe
30 tiles × 6 rotation × 5 elevation = 900 states → 太多了 → 30 tiles × 1 rotation 简化版
```

**复杂解法 = 经常失败；简单解法 = 经常能跑**。

---

## 三条路线的「关键问题」对比

| 问题 | 路线 A（算法）| 路线 B（AI）| 路线 C（WFC 极简）|
|---|---|---|---|
| **大尺度结构怎么保证？** | 模板先打底 | AI 自己学 | 玩家自己放 |
| **质量不稳定怎么办？** | 分层降级 | 6 次 prompt 迭代 | 视觉调试 |
| **成本怎么算？** | GPU 时间 | serverless GPU | 玩家机器 GPU |
| **可维护性？** | 高 | 极低 | 中 |
| **效果可控？** | 高 | 中 | 中 |
| **能复用吗？** | 算法可复用 | 模型需要 re-train | 规则可复用 |

---

## 对 build-ai-tour-guide 的具体指导

### 路线选择矩阵

| 场景 | 推荐路线 | 理由 |
|---|---|---|
| **MVP 1 个月上线** | **路线 A**（用现成 low-poly 库）| 算法可维护、不需要训练 |
| **做「纽约像素地图」类项目** | **路线 B**（AI 风格化）| 量大人少，AI 唯一解 |
| **做「实时城市游戏」** | **路线 C**（Oskar 极简 WFC）| 实时 + 可玩 |
| **做「OSM → 3D 城市」** | **混合**：路线 A 做几何 + 路线 B 做风格化 | 各取所长 |

### 推荐技术栈（混合路线）

```
数据层
  OSM (Overpass API) → 建筑 foot print + height
    ↓
  程序化细节（路线 A 模式）
    ├── building:levels 真实拉高
    ├── 6 种屋顶程序化生成
    ├── Perlin noise 决定窗户密度
    └── 树/装饰用 noise 放
    ↓
AI 风格化（路线 B 模式）
  ├── Teacher: Nano Banana 生成「OSM → 漂亮 3D」pair
  ├── Student: Qwen/Image-Edit + LoRA 专门化
  ├── Inference: Modal serverless
  └── 输出：Tile 预渲染
    ↓
应用层
  ├── 主 viewer: React + OpenSeaDragon（DZI 瓦片）
  ├── Layer 应用: 白天/夜晚/历史模式（独立 app）
  └── Post-processing: GTAO + DoF + Vignette
```

### 第一档改进清单（参考 build-ai-tour-guide）

```
1. 配色规则（5 分钟）
2. building:levels 真实拉高（10 分钟）
3. 6 种屋顶（2 小时）[路线 A 模式]
4. 程序化窗户（3 小时）[路线 A 模式 + Noise]
5. 女儿墙 + 烟囱（1 小时）
```

### 关键工程决策

1. **Quadrant + Shared Anchor**：直接抄 Isometric-NYC 的 4×4 quadrant + 共享 anchor 机制
2. **AGENTS.md 写给 AI**：仓库第一天就建 AGENTS.md / CLAUDE.md
3. **分层降级**：从一开始就把「数据缺失 → 程序化 fallback → 噪声填充」分层写好
4. **BatchedMesh + 单材质**：渲染层一开始就用这套模式

---

## 决策框架

**问自己 3 个问题：**

### Q1：你需要实时还是离线？

- **实时**（每帧生成）→ 路线 A 或 C
- **离线**（提前批量）→ 路线 B

### Q2：你的数据是真实地理还是抽象风格？

- **真实地理**（NYC、东京、你的城市）→ 路线 B（AI 风格化）
- **抽象风格**（中世纪、太空站、幻想地图）→ 路线 A 或 C

### Q3：你能接受 vibe-engineering 吗？

- **接受**（AI 写代码、自己只拍板）→ 路线 B
- **不能接受**（要长期维护）→ 路线 A 或 C

### 决策树

```
需要 AI 风格化真实地理？
├── 是 → 路线 B（接受 vibe-engineering）
└── 否 → 需要实时？
    ├── 是 → 立方体堆叠抽象？
    │   ├── 是 → 路线 C（Townscaper 模式）
    │   └── 否 → 复杂地形？ → 路线 A（Hex-Map-WFC 模式）
    └── 否 → 任何路线都行，看团队
```

---

## 未来值得关注的演进

1. **路线 A + B 混合**：OSM 数据 → 算法精确化 → AI 风格化 → 输出低多边形像素瓦片。这是 build-ai-tour-guide 的方向。
2. **路线 B 工具成熟**：LoRA 训练越来越便宜（[Replicate](https://replicate.com/)、[Modal](https://modal.com/)、[Oxen](https://oxen.ai)），**vibe-engineering 成本会持续下降**。
3. **路线 C 商业化**：Oskar Stålberg 的 Townscaper 已经证明这条路能商业化，国内 [Town Builder 开源](https://github.com/eliemichel/TownBuilder) 也开始有人做。
4. **WebGPU 普及**：TSL 取代 GLSL 是 Three.js 未来。**现在学 TSL 是 2026 年的好投资**。
5. **生成式 AI + 实时**：路线 B 现在的「离线」是 GPU 成本问题，**当推理成本降到 1/100 时，实时 AI 风格化会成为新路线**。

---

## 我的判断

> **当下（2026 年 7 月），最务实的策略是：路线 A 起步，路线 B 增强，路线 C 作为可选。**

- **MVP**：路线 A（Three.js + WFC 简化版 + 程序化细节）——1 个月可上线
- **增强**：路线 B（OSM 数据 → AI 风格化 → 替换或叠加程序化输出）——3-6 个月
- **可选**：路线 C（如果做实时互动编辑器，加这套）

---
