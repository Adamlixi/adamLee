---
layout: post
title: "Building a Procedural Hex Map with Wave Function Collapse / 用 Wave Function Collapse 构建程序化六边形地图"
tags: [gamedev, procgen]
---
> 作者：Felix Turner（[@felixturner](https://twitter.com/felixturner)，Airtight Interactive 创始人）· 2026-03-09 · [原文](https://felixturner.github.io/hex-map-wfc/article/) · [HN 580p / 86c](https://news.ycombinator.com/item?id=47311815) · [源码](https://github.com/felixturner/hex-map-wfc) · [Live Demo](https://felixturner.github.io/hex-map-wfc/)

> 用 4,100 个六边形瓦片构建程序化中世纪岛屿，基于 Three.js WebGPU 和大量 backtracking。

---

## 缘起：童年 D&D 桌游的回响

> I've been obsessed with procedural maps since I was a kid rolling dice on the random dungeon tables in the AD&D Dungeon Master's Guide. There was something magical about it — you didn't design the dungeon, you discovered it, one room at a time, and the dice decided whether you got a treasure chamber or a dead end full of rats.

我从小就对程序化地图着迷——回想起来就是 AD&D《地下城主指南》里随机地下城表的骰子声。那种魔力在于：你不是在「设计」地牢，你是在「发现」它，一个房间一个房间，骰子决定你拿到宝藏室还是满地老鼠的死胡同。

> Years later, I decided to build my own map generator. It creates little medieval island worlds — with roads, rivers, coastlines, cliffs, forests, and villages — entirely procedurally. Built with Three.js WebGPU and TSL shaders, about 4,100 hex cells across 19 grids, generated in ~20 seconds.

许多年后，我决定自己写一个地图生成器。它生成小型中世纪岛屿世界——**道路、河流、海岸、悬崖、森林、村庄**——全程序化。基于 Three.js WebGPU + TSL shader，跨 19 个 hex grid 的 ~4,100 个 cell，生成时间约 20 秒。

---

## Carcassonne, but a Computer Does It
## 让计算机玩 Carcassonne

> If you've ever played Carcassonne, you already understand WFC. You have a stack of tiles and place them so everything lines up. Each tile has edges — grass, road, city. Adjacent tiles must have matching edges. A road edge must connect to another road edge. Grass must meet grass. The only difference is that the computer does it faster, and complains less when it gets stuck.

玩过 Carcassonne（卡卡颂）的人秒懂 WFC：你手里有一摞瓦片，挨个放让边缘对齐。每个瓦片有 edge——草、道路、城市。相邻瓦片的 edge 必须匹配：道路连道路、草连草。唯一的区别是计算机做得更快，而且卡住时不会抱怨（只是默默死循环）。

> The twist: hex tiles have 6 edges instead of 4. That's 50% more constraints per tile, and the combinatorial explosion is real. Square WFC is well-trodden territory. Hex WFC is... less so.

**关键差异**：六边形瓦片有 6 条 edge 而不是 4 条。每片约束多 50%，组合爆炸是真实的。方形 WFC 是人走过的老路，hex WFC 嘛……还相对荒野。

---

## Tile Definitions
## 瓦片定义

> For this map there are 30 different tiles defining grass, water, roads, rivers, coasts and slopes. Each tile in the set has a definition which describes the terrain type of each of its 6 edges, plus a weight used for favoring some tiles over others.

本地图共 **30 种瓦片**，涵盖草地、水域、道路、河流、海岸、斜坡。每种瓦片有一个 definition，描述 6 条 edge 的地形类型，还有一个 weight（用于倾向某些瓦片多出现）。

> 30 tile types, each with 6 rotations and 5 elevation levels. That's **900 possible states per cell**.

**30 种 × 6 种旋转 × 5 种海拔 = 900 states/cell**。

示例瓦片定义：

```js
{
  name: 'ROAD_D',
  mesh: 'hex_road_D',
  edges: { NE: 'road', E: 'grass', SE: 'road',
           SW: 'grass', W: 'road', NW: 'grass' },
  weight: 2
}
```

> Each tile defines 6 edge types. **Matching edges is the only rule.** 唯一的规则：edge 必须匹配。

---

## How WFC Works
## WFC 是怎么工作的

> Start with chaos. Every cell on the grid begins as a superposition of all possible tiles — all 30 types, all 6 rotations, all 5 elevation levels. Pure possibility.

**第一步：混沌起始。** 网格每个 cell 初始状态都是「所有可能瓦片的叠加态」——30 种 × 6 旋转 × 5 海拔，纯纯的可能性。

> Collapse the most constrained cell. Pick the cell with the fewest remaining options (lowest entropy). Randomly choose one of its valid states.

**第二步：坍缩最约束的 cell。** 选剩余选项最少的那个 cell（entropy 最低），从它的合法状态里随机选一个。

> Propagate. That choice constrains its neighbors. Remove any neighbor states whose edges don't match. This cascades outward — one collapse can eliminate hundreds of possibilities across the grid.

**第三步：传播。** 这次坍缩约束了它的邻居。移除邻居里 edge 不匹配的所有状态。一次坍缩能级联干掉几百个可能。

> Repeat until every cell is solved — or you get stuck. **Getting stuck is the interesting part.** 重复直到全部解开——或者你卡住了。**卡住才是有趣的部分**。

---

## The Multi-Grid Problem
## 多 Grid 问题

> WFC is reliable for small grids. But as the grid gets bigger, the chance of painting yourself into a dead end goes up fast. A 217-cell hex grid almost never fails. A 4123-cell grid fails regularly.

WFC 在小 grid 上很可靠。但 grid 越大，把自己逼入死角的概率上升极快。**217 cell 的 hex grid 几乎从不失败；4,123 cell 经常失败。**

> The solution: modular WFC. Instead of one giant solve, the map is split into **19 hexagonal grids arranged in two rings around a center** — about 4,100 cells total. Each grid is solved independently, but it has to match whatever tiles were already placed in neighboring grids. Those border tiles become fixed constraints.

**解法：模块化 WFC。** 不做一次巨型求解，把地图拆成 **19 个 hex grid 围绕中心排成两圈**——约 4,100 cell。每个 grid 独立求解，但必须匹配相邻 grid 已放置的瓦片。那些 border 瓦片成为固定约束。

> And sometimes those constraints are simply incompatible. No amount of backtracking inside the current grid can fix a problem that was baked in by a neighbor.

但有时候这些约束根本不兼容。**当前 grid 里无论怎么 backtracking 都救不回一个被邻居「烤死」的问题**。这是 Felix 投入最多开发时间的地方。

---

## Backtracking
## 回溯

> Here's the dirty secret of WFC: it fails. A lot. You make a series of random choices, propagate constraints, and eventually back yourself into a corner where some cell has zero valid options left. Congratulations, the puzzle is unsolvable.

**WFC 的肮脏秘密**：它经常失败。你做一连串随机选择、传播约束，最后某个 cell 走入死胡同、合法选项归零。恭喜，这个谜题无解。

> The textbook solution is backtracking — undo your last decision and try a different tile. My solver tracks every possibility it removes during propagation (a "trail" of deltas), so it can rewind cheaply without copying the entire grid state. **It'll try up to 500 backtracks before giving up.**

教科书解法是 backtracking——撤销上一个决定换瓦片。Felix 的 solver 在传播期间追踪每个移除（「deltas 的轨迹」），这样可以廉价倒带、不用复制整个 grid 状态。**放弃前最多 500 次回溯。**

> But backtracking alone isn't enough. The real problem is cross-grid boundaries.

**但只有 backtracking 不够。** 真正的问题是 grid 之间的边界。

---

## The Recovery System（关键创新）
## 恢复系统

> After many failed approaches, I landed on a **layered recovery system**:

试过多种失败方案后，Felix 落地了一个**分层恢复系统**——这是文章最值钱的工程经验：

### Layer 1: Unfixing
### 第 1 层：解除固定

> During the initial constraint propagation, if a neighbor cell creates a contradiction, the solver converts it from a fixed constraint back into a solvable cell. Its own neighbors (two cells out — "anchors") become the new constraints. This is cheap and handles easy cases.

在初始约束传播期间，如果邻居 cell 造成矛盾，solver 把那个邻居从「固定约束」转回「可解 cell」。邻居的邻居（隔一格——叫 "anchors"）成为新约束。**便宜，处理大多数简单情况。**

### Layer 2: Local-WFC（关键突破）
### 第 2 层：局部 WFC

> If the main solve fails, the solver runs a mini-WFC on a small radius-2 region around the problem area — re-solving 19 cells in the overlap area to create a more compatible boundary. Up to 5 attempts, each targeting a different problem cell. **Local-WFC was the breakthrough. Instead of trying to solve the impossible, go back and change the problem.**

主求解失败时，solver 在问题区域周围 radius=2 跑 mini-WFC——重解重叠区的 19 个 cell 来制造更兼容的边界。**最多 5 次尝试，每次针对不同问题 cell。**

> **Local-WFC 是真正的突破。不要试着去解不可能的题——回去改变问题本身。**

### Layer 3: Drop and hide（山脉盖缝）
### 第 3 层：丢包+掩埋

> Last resort. Drop the offending neighbor cell entirely and place mountain tiles to cover the seams. Mountains are great — their cliff edges match anything, and they look intentional. **Nobody questions a mountain.**

**最后一招：丢包+掩埋。** 整个扔掉问题邻居 cell，放上山脉瓦片盖缝。山脉好用——悬崖 edge 配什么都行，而且看起来是故意的。**没人会质疑一座山。**

> Before: neighbor conflict blocks the solve → After: Local-WFC patches the boundary
> Debug mode showing the carnage. Purple = neighbor conflict. Red = broken tiles.

---

## The Third Dimension
## 第三维度

> This map isn't flat — it has **5 levels of elevation**. Ocean and Grass start at level 0, but slopes and cliffs can move up or down a level. Low slopes go up 1 level, high slopes go up 2 levels.

地图不是平的——**有 5 级海拔**。海洋和草地从 level 0 起，斜坡和悬崖可以升降。低斜坡升 1 级，高斜坡升 2 级。

> A road tile at level 3 needs to connect to another road tile at level 3, or a slope tile that transitions between levels. Get it wrong and you end up with roads that dead-end into cliff faces or rivers flowing uphill into the sky.

level 3 的道路瓦片必须连另一个 level 3 的道路瓦片，或者连一个跨级斜坡瓦片。搞错的话，你会看到道路断在悬崖壁、或者河水向天流。

> The elevation axis turns a 2D constraint problem into a 3D one, and it's where a lot of the tile variety (and a lot of the solver failures) comes from.

**海拔轴把 2D 约束问题变成 3D。这是大量瓦片多样性（也是大量 solver 失败）的源头。**

### Shader 着色

> Tiles are colored with a node-based PBR material — MeshPhysicalNodeMaterial — with a custom TSL color node. Each tile's elevation is encoded in the instance color, which the shader uses to blend between two palette textures — low ground gets summer colors, high ground gets winter.

瓦片用节点式 PBR 材质（`MeshPhysicalNodeMaterial`）+ 自定义 TSL 颜色节点。每片的海拔编码到 instance color 里，shader 用它在两张调色板纹理之间混合——低地拿夏天色，高地拿冬天色。

---

## Hex Coordinates: Surprisingly Weird
## 六边形坐标：意外地诡异

> Hex math is weird. Since there are 6 directions instead of 4, there's no simple mapping between hex positions and 2D x,y coordinates.

**六边形数学很诡异。** 因为有 6 个方向而不是 4 个，没有简单的方法把 hex 位置映射到 2D x,y 坐标。

> The naive approach is offset coordinates — numbering cells left-to-right, top-to-bottom like a regular grid. This works until you need to find neighbors, compute distances, or do anything involving directions. Then it gets confusing fast, with different formulas for odd and even rows.

**天真做法是 offset 坐标**：从左到右、从上到下编号。看起来 OK 直到你要找邻居、算距离、或者做任何涉及方向的事——然后奇数行偶数行的公式不一样，迅速混乱。

> The better approach: **cube coordinates (q, r, s where s = -q-r)**. It's a 3D coordinate system for the three hex axes. Neighbor finding becomes trivial — just add or subtract 1 from two coordinates.

**正解：cube 坐标 (q, r, s, 其中 s = -q-r)。** 这是一个 3D 坐标系统，对应 hex 的三个轴。**找邻居变成 trivial——对两个坐标各加减 1 就行。**

> The good news is that WFC doesn't really care about geometry. It's concerned with which edges match which — it's essentially a graph problem. The hex coordinates only matter for rendering and for the multi-grid layout, where the 19 grids are themselves arranged as a hex-of-hexes with their own offset positions.

好消息是 WFC 不在乎几何。它只关心哪些 edge 配哪些——**本质上是一个图问题**。hex 坐标只在渲染和多 grid 布局时重要，那 19 个 grid 本身又排成一个 hex-of-hexes。

> If you've ever worked with hex grids, you owe [Amit Patel at Red Blob Games](https://www.redblobgames.com/grids/hexagons/) a debt of gratitude. His hex grid guide is the definitive reference.

搞过 hex grid 的人，都欠 Amit Patel 一份人情。他的 hex grid 指南是终极参考。

---

## Trees, Buildings, and Why Not Everything Should Be WFC
## 树、建筑、以及为什么不是所有东西都该用 WFC

> Early on, I tried using WFC for tree and building placement. **Bad idea.** WFC is great at local edge matching but terrible at large-scale patterns. You'd get trees scattered randomly instead of clustered into forests, or buildings spread evenly instead of gathered into villages.

**早期 Felix 试过用 WFC 放树和建筑。坏主意。** WFC 擅长局部 edge 匹配，但在大尺度模式上很烂。你会得到散乱分布的树、或者均匀撒开的建筑。

> The solution: good old Perlin noise. A global noise field determines tree density and building placement, completely separate from WFC. Areas where the noise is above a threshold get trees; slightly different noise drives buildings. This gives you organic clustering — forests, clearings, villages — that WFC could never produce.

**解法：老朋友 Perlin noise。** 一个全局噪声场决定树的密度和建筑的位置，跟 WFC 完全分开。噪声高于阈值的地方长树；稍微不同的噪声驱动建筑。这给出 WFC 永远做不出的有机聚类——森林、空地、村庄。

> I also used some additional logic to place buildings at the end of roads, ports and windmills on coasts, henges on hilltops etc.

> **WFC handles the terrain. Noise handles the decorations. Each tool does what it's good at.**

**WFC 负责地形，noise 负责装饰。** 每个工具做它擅长的事。

---

## Water: Harder Than It Looks
## 水：比看起来难

> Water effects were the hardest visual problem to solve. The ocean isn't just a blue plane — it has animated caustic sparkles and coastal waves that emanate from shorelines.

**水效果是视觉上最难的问题。** 海洋不是一块蓝平面——它有动画 caustic 闪光和从海岸线发散的浪。

### Sparkles 闪光

> I wanted that 'Zelda: The Wind Waker' cartoon shimmer on the water surface. Originally I tried generating caustics procedurally with four layers of Voronoi noise. **This turned out to be very GPU heavy and did not look great.** The solution was sampling a small scrolling caustic texture with a simple noise mask, which looks way better and is super cheap.

想要《风之杖》那种卡通闪光的海面。原本想用 4 层 Voronoi noise 程序化生成 caustic。**结果 GPU 太重、效果也不好。** 解法是采样一张小的滚动 caustic 纹理 + 简单 noise mask——好看得多、超便宜。

> Sometimes the easy solution is the correct solution.

**有时候简单的解法就是正确解法。**

### Coast Waves 海岸浪

> Waves are sine bands that radiate outward from coastlines, inspired by Bad North's gorgeous shoreline effect. To know "how far from the coast" each pixel is, the system renders a coast mask — a top down orthographic render of the entire map with white for land and black for water — then dilates and blurs it into a gradient.

浪是从海岸线向外辐射的 sine 带，灵感来自 Bad North 的海岸效果。要知道每个像素「离海岸多远」，系统渲染一张 coast mask——地图的俯视正交渲染，陆地白、水黑——然后 dilate+blur 成梯度。

> The wave shader reads this gradient to place animated sine bands at regular distance intervals, with noise to break up the pattern.

浪 shader 读这个梯度，按固定距离间隔放动画 sine 带，叠 noise 打破规律。

### The Cove Problem 海湾问题

> This worked great on straight coastlines. In concave coves and inlets, the wave lines got thick and ugly.

**直海岸很美。但遇到凹陷的海湾和内港，浪线变得又粗又丑。**

> The fundamental issue: **blur encodes "how much land is nearby," not "how far is the nearest coast edge."** These are different questions, and no amount of post-processing the blur can extract true distance.

**根本问题：blur 编码的是「附近有多少陆地」，不是「最近海岸 edge 有多远」。** 这是两个问题，无论怎么后处理 blur 都抽不出真正的距离。

Felix 试过的失败方案：

> - Screen-space derivatives to detect gradient stretching — worked at one zoom level, broke at others.
> - Texture-space gradient magnitude to detect opposing coast edges canceling out — only detected narrow rivers, not actual problem coves.
> - Extra dilation passes — affected straight coasts too.

最终解：

> The solve was to do a CPU-side "surroundedness" probe that checks each water cell's neighbors to detect coves, writing a separate mask texture that thins the waves in enclosed areas. It's kind of a hack but it works.

**最终在 CPU 端跑一个 "surroundedness" 探针**，检查每个水域 cell 的邻居来识别海湾，写一张单独的 mask 纹理来让封闭区域的浪变细。是个 hack，但能用。

> **It's kind of a hack but it works and the wave edges thin out nicely at the edges.**

---

## Making Tiles in Blender
## 在 Blender 里做瓦片

> The 3D tile assets come from [KayKit's fantastic low-poly Medieval Hexagon pack](https://kaylousberg.itch.io/kaykit-medieval-hexagon-pack). But it was missing some key connectors needed for a sub-complete tileset, so I dusted off my Blender skills and built new tiles: sloping rivers, river dead-ends, river-to-coast connectors, and several cliff edge variants.

3D 瓦片来自 KayKit 的 Medieval Hexagon pack。但缺一些关键的连接瓦片来凑成「次完备」瓦片集，Felix 重拾 Blender 做了：斜坡河流、河流断头、河入海、悬崖 edge 变体。

> The key constraint: every tile is exactly 2 world units wide, and edge types must align perfectly at the hex boundaries. **Getting UVs right means the texture atlas maps correctly across tile seams. A misaligned UV by even a few pixels creates a visible seam line that breaks the illusion.**

**关键约束：每片正好 2 单位宽，edge 类型必须在 hex 边界完美对齐。** UV 对齐到几像素，纹理 atlas 跨瓦片接缝就错，破功。

---

## Making It Pretty
## 弄漂亮

> The algorithm gets you a valid map. **Making it look like a place you'd want to visit is a whole separate problem.**

算法给你一张合法地图。**让它看起来「你想去」是完全另一个问题。**

### WebGPU and TSL Shaders

> The renderer is Three.js with WebGPU and TSL (Three.js Shading Language) — the new node-based shader system that replaces raw GLSL. All the custom visual effects are written in TSL, which reads like a slightly alien dialect of JavaScript that runs on your GPU.

渲染器用 Three.js + WebGPU + **TSL**（Three.js Shading Language）——新的节点式 shader 系统，替代裸 GLSL。所有自定义视觉特效都用 TSL 写，读起来像 JavaScript 的一种奇怪方言，在 GPU 上跑。

### Post-Processing 后处理

> The raw render looks... fine. Flat. Like a board game photographed under fluorescent lights. **The post-processing pipeline is what gives it atmosphere:**

裸渲染看起来……还行。扁扁的。像在荧光灯下拍的桌游。**后处理流水线给它气氛：**

| 步骤 | 作用 |
|---|---|
| GTAO Ambient Occlusion | 瓦片/建筑/树之间的缝隙变暗，让一切更有实体感。半分辨率跑 + 去噪 |
| Depth of Field | tilt-shift 模糊，按相机距离变化 → 微型场景感。DOF 焦距随 zoom 缩放 |
| Vignette + Film Grain | 边缘暗化 + 噪点，刚好够 analog |

> AO, depth of field and grain do a lot of heavy lifting.

### Dynamic Shadow Maps 动态阴影

> The shadow map frustum is fitted to the camera view every frame. The visible area is projected into the light's coordinate system to compute the tightest possible bounding box, so no shadow map texels are wasted on off-screen geometry. Zoomed out, shadows cover the whole map at lower resolution. Zoom in, and the shadow map tightens to give you crisp, detailed shadows on individual tiles.

**shadow map frustum 每帧 fit 到相机视野。** 可见区域投影到光源坐标系算出最紧的 bounding box——不在视野里的几何体不浪费一个 shadow map texel。拉远，阴影覆盖全图但低分辨率；拉近，shadow map 自动收紧，单片瓦片阴影清晰。

> This prevents blocky shadow artifacts when you zoom in. Dynamic frustum for crisp detail.

### Optimizations 性能优化

> The complete map has thousands of tiles and decorations. Drawing each one individually would kill the frame rate. The solution is two-fold:

完整地图有几千片瓦片和装饰。一个个画会杀掉帧率。解法两件套：

**BatchedMesh** — 每个 hex grid 拿 2 个 BatchedMesh（瓦片一个、装饰一个）。每个 mesh 可以独立几何 + transform，但都在单次 draw call 里渲染。GPU 处理 per-instance transform 和几何偏移，CPU 成本基本为 0。

> The whole scene renders in a handful of draw calls regardless of map complexity.

**One Shared Material** — 场景里每个 mesh 共享一个材质。Mesh UV 映到一张小调色板纹理，都从同一张图取色，像共享的「按数字上色」图。一个材质意味着 draw call 之间零 shader state 切换，**GPU 飙过 38 个 BatchedMesh 不阻塞**。

> The result: 4,100+ cells, 38 BatchedMeshes, and the whole thing renders at **60fps on desktop and mobile.**

> **Snow day.**（冬季配色演示截图）

---

## Summary
## 总结

> No dice required this time — but the feeling is the same. You hit a button, the map builds itself, and you discover what the algorithm decided to put there. It's super satisfying to see the road and river systems matching up perfectly. Every time it's different, and every time I find myself exploring for a while.

这次不用骰子——但感觉一样。你按个按钮，地图自己构建，你发现算法决定放了什么。看到道路和河流系统完美匹配超级满足。每次都不同，每次我都探索一会儿。

---

## The Numbers
## 关键数字

| 数字 | 含义 |
|---|---|
| **30** | 瓦片类型数 |
| **19** | hex grid 数 |
| **~4,100** | cell 总数 |
| **2** | 每个 grid 的 draw call 数 |
| **500** | 最大回溯次数 |
| **5** | Local-WFC 尝试次数 |
| **~20s** | 全部 grid 构建时间 |
| **100%** | 成功率（500 次实测） |

---

## Tech Stack
## 技术栈

- **Three.js r183** with WebGPU renderer
- **TSL** (Three.js Shading Language) 写所有自定义 shader
- **Web Workers** 跑 off-thread WFC
- **Vite** 构建
- **BatchedMesh** 单 draw call 高效渲染
- **Seeded RNG** 确定性可复现的地图

---

## Credits and References
## 致谢与参考

- [KayKit Medieval Hexagon Pack](https://kaylousberg.itch.io/kaykit-medieval-hexagon-pack) — 启发了瓦片资源
- [Maxim Gumin's WFC](https://github.com/mxgmn/WaveFunctionCollapse) — 原版 Wave Function Collapse 实现
- [Red Blob Games — Hexagonal Grids](https://www.redblobgames.com/grids/hexagons/) — hex grid 圣经
- [Boris the Brave](https://www.boristhebrave.com/) — WFC 块改写的珍贵文章
- Codrops — WebGPU BatchedMesh 入门文章
- **Style inspiration**: Bad North, Dorfromantik

---

## About Me
## 关于作者

> I'm Felix Turner, a creative developer and founder of **Airtight Interactive**. I build interactive visual experiments, WebGL/WebGPU experiences, and generative art.

> Twitter · Bluesky

---

# 我的点评（Vault 视角）

## HN 评论里的关键技术纠正

HN 上讨论质量很高，有几条**必须知道**的纠正：

### 1. 这不是真的 WFC

> **linkdd**: This is not Wave Function Collapse. This is a constraint solver. The goal of the original algorithm (mxgmn/WaveFunctionCollapse) is to **infer the constraints from a sample**, and then run a constraint solver. Hard-coding the constraints skips the whole point of the algorithm (which is also badly named by the way).

> **jcalx**: the tile-placement algorithm here is just a way of solving constraint satisfaction problems with **DFS using a "minimum remaining values" heuristic**. The original use case for generating textures is different in that the constraints are implicit in the input bitmap, but this project is a more straightforward tile placement with explicit constraints.

> **swiftcoder**: Colloquially this is what gamedevs mean when they refer to WaveFunctionCollapse (though the constraints may or may not be inferred from tiles or 3D models, depending on the implementation). It may not match the academic terminology exactly.

**关键事实**：
- **真正的 WFC（mxgmn 版本）**：从样本 bitmap 推断约束 → 然后求解
- **hex-map-wfc 实际做的**：手写约束 → DFS + MRV heuristic 求解
- 学术术语应当叫 "constraint satisfaction problem solver" 或者 "model synthesis"（来自 nextaccountic 的纠正）

### 2. 更高级的求解方法

> **porphyra**: The post glosses over the "backtracking" and says they just limit it to 500 steps but actually constraint programming is an extremely interesting and complicated field... we could solve it with **Knuth's Algorithm X** [1] with dancing links, which is a special kind of backtracking. Algorithm X should, in theory, be able to solve the border region described in the article's "Layer 2" with a higher success rate as opposed to 86%.

> **shoo**: there's also a bunch of dedicated constraint programming solvers / high level modelling languages for these kinds of constraint-y combinatorial optimisation problems e.g. **MiniZinc** offers a high level modelling language that can target a few different solver backends.

> **porphyra** (后续): You can also use **Clingo** which is pretty popular and people have tried it specifically with WFC content generation. You can even run it in the browser easily.

**关键资源**：
- **Knuth's Algorithm X + dancing links** — 更聪明的 backtracking 数据结构
- **MiniZinc** — 高层 CP 建模语言，对接多个 solver backend
- **Clingo** (Potassco) — Answer Set Programming solver，已有人用 WFC content generation 跑过，可在浏览器跑
- **Boris the Brave** 的 WFC "modifying in blocks" 系列文章 — 上面 Credits 里提了

### 3. WFC 的根本局限

> **vintermann**: It's beautiful. But also pretty unsatisfying in a way. Roads don't make sense. Rivers barely make sense. There's no higher-scale structure — the reason why most games with incremental procedural generation usually feel stale after a while, and always static.

> **bhaak**: WFC focuses on local optimization. The algorithm can't take a step back and look at the whole map. That's why you won't get a sensible road network. What you can do... is to **mix in some templates before WFC runs**. Often, a bit of post-processing is needed as well. The templates can be hand-designed, or generated with simpler procgen code. Place a few towns on the map, connect them with roads, and then let WFC fill in the gaps to create a more interesting landscape.

> **caspar** (关于 Noita): Noita uses herringbone wang tiles where each wang tile pixel is 16x16 simulated in-game CA pixels, with tiles selected from a per-biome pool and the ability for biome-specific scripts to override certain areas too.

**核心结论**：WFC 只会做局部 edge 匹配，**大尺度结构（道路网络、河流系统、城镇分布）必须用模板 + 其它算法先打底**。

### 4. Felix 的文章里其实已经回答了这个批评

> **The solution: good old Perlin noise** ——他自己也发现 WFC 不擅长大尺度，转用 Perlin noise 放树和建筑。
> **Local-WFC** ——他自己也设计了"在外部更宏观地重解问题"的机制。

所以 Felix 是「承认 WFC 局限 → 用其他工具补足」的最佳实践案例。

---

## 我的整体评价

**这篇文章是我读过最好的「程序化地图工程实战」之一**，原因是它不是讲算法，而是讲**工程**：把一个玩具算法变成能跑 4,100 cells、60fps 的产品，中间哪些坑、哪些 hack、哪些失败方案。

**对我（Adam）的具体价值**：

1. **AI Tour Guide 项目的瓦片生成器参考** — Townscaper/TownBuilder 是 9 顶点 cube 模块，hex-map-wfc 是 hex grid + WFC。两者原理接近，但规模和应用不同。build-ai-tour-guide 如果要做"程序化生成细节"，hex-map-wfc 的分层恢复机制可以直接借鉴。
2. **「WFC + 噪声」分层架构** — WFC 负责地形、噪声负责装饰。这是一种**「让每个算法做它擅长的事」**的工程哲学，可以套用到任何多组件生成系统。
3. **TSL + WebGPU** — 是 Three.js 未来方向。如果我自己写 three.js 渲染，应该从 GLSL 切到 TSL。
4. **BatchedMesh + 单材质** — 几千个对象跑 60fps 的关键。这是任何"大量相似几何体"渲染场景的标配模式。
5. **「easy solution is the correct solution」** — Felix 多次用简单方案取代复杂方案（Voronoi → caustic texture；blur → CPU probe）。这是个普适工程哲学。

**启发性问题**：

- 如果 AI Tour Guide 输入地名 + 用户偏好 → 是否能用类似 hex-map-wfc 的方式先生成「城市语义结构」（商场、住宅、公园、学校），再用 OSM 真实数据填具体细节？
- Felix 的 19 grid "hex-of-hexes" 拓扑 → 是否能映射到「城市分块」（一个 grid = 一个 district）？
- "Nobody questions a mountain" 这种「用自然元素掩盖算法缺陷」的思路 → 城市规划里同样适用（绿地永远是兜底）

---
