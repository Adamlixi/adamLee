---
layout: post
title: "Obsidian 插件架构 — 给现有产品加扩展的设计课"
tags: [product-research]
---
> "Plugins let you extend Obsidian with your own features to create a custom note-taking experience."
> —— [docs.obsidian.md/Plugins](https://docs.obsidian.md/Plugins/)

Obsidian 跑通了一个 SaaS 产品做扩展最难的事：在不牺牲核心体验、不牺牲安全、不牺牲本地优先哲学的前提下，做出了 4000+ 插件 / 120M+ 下载的生态。这份笔记专门拆它的**插件架构设计模式**，给"想给现有产品加扩展"的人用。

---

## §0 Obsidian 插件规模（2026-07）

| 指标 | 数据 | 出处 |
|---|---|---|
| 社区插件总数 | **4000+** | [Future of Plugins, 2026-05-12](https://obsidian.md/blog/future-of-plugins/) |
| 累计下载 | **120M+** | 同上 |
| 手动审核积压 | **2300+** 待审（2026-05 一次性清完） | 同上 |
| Discord 开发者频道 | #plugin-dev / #theme-dev | [obsidian.md/blog/future-of-plugins](https://obsidian.md/blog/future-of-plugins/) |
| 6 年演化 | 0 → 4000+ 插件 | 2020 API 开放至今 |

> **设计含义**：插件系统是 Obsidian 6 年后才"出大招"（2026-05 上 Community 站 + 自动审核），说明**社区生态需要时间沉淀，先把 API 做对比先把 Marketplace 做对更重要**。

---

## §1 整体架构 — 一图看清

```
┌─────────────────────────────────────────────────────────┐
│                  Obsidian App (Electron)                │
│  ┌──────────────────────────────────────────────────┐   │
│  │   Core Renderer (CSP-locked, no inline JS)       │   │
│  │   - Workspace / Vault / Editor / MetadataCache   │   │
│  └──────────────────────────────────────────────────┘   │
│                         ▲                                │
│   ┌─────────────────────┼─────────────────────┐          │
│   │  Plugin API (manifest.json + main.js)      │          │
│   └─────────────────────┼─────────────────────┘          │
│                         ▼                                │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Plugin Sandbox（同进程 + 白名单模块）           │   │
│  │  - 只能 require 'obsidian' / 'electron'          │   │
│  │  - 没有 Node.js 内置（mobile 上 Node 全无）      │   │
│  │  - 文件 I/O 走 app.vault / loadData / saveData  │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
                         ▲
                         │  发布流程
                         ▼
┌─────────────────────────────────────────────────────────┐
│         GitHub Release (manifest.json + main.js +       │
│             styles.css 三个 binary 附件)                │
└─────────────────────────────────────────────────────────┘
                         ▲
                         │  自动审核
                         ▼
┌─────────────────────────────────────────────────────────┐
│   Community 站 (2026-05 全新) + 自动扫描 + Scorecard   │
│   - 2300 积压 → 几天内清完                              │
│   - 每个版本自动扫描恶意代码 / 代码质量                 │
└─────────────────────────────────────────────────────────┘
```

**关键设计点**：
1. 插件**和核心同 Electron 进程**（不是 out-of-process worker）— 牺牲一些隔离换 API 表达力
2. 沙盒靠**白名单 require + CSP**（不是独立进程）— 简单且安全
3. 发布靠 **GitHub Release 的 3 个 binary 附件**（不用自家 CI）
4. 审核从**手动 → 自动**（2026-05 升级，因为 coding agent 让提交量爆炸）

---

## §2 插件最小骨架（看一眼 API 风格）

```typescript
import { Plugin, Notice } from 'obsidian';

export default class MyPlugin extends Plugin {
  // 必须：插件启用时调用
  async onload() {
    // 1. 注册命令面板命令
    this.addCommand({
      id: 'greet',
      name: 'Greet',
      callback: () => new Notice('Hello!')
    });

    // 2. 加 ribbon 图标
    this.addRibbonIcon('dice', 'Greet', () => {
      new Notice('Hi from ribbon!');
    });

    // 3. 监听事件（自动 onunload 清理）
    this.registerEvent(
      this.app.vault.on('create', (file) => {
        console.log('created', file.path);
      })
    );

    // 4. 注册 timer（自动 onunload 清理）
    this.registerInterval(
      window.setInterval(() => this.tick(), 1000)
    );
  }

  // 必须：插件禁用时调用 — 必须释放所有资源
  async onunload() {
    // registerEvent / registerInterval 注册的会自动清
    // 自己 addEventListener 的要手动 remove
  }
}
```

**设计要点**：
- **入口是 class**（不是函数式）— 状态归属明确
- **`registerEvent` / `registerInterval` 自动管理生命周期** — 插件作者忘清理也不会泄漏
- **`this.app`** 是单例 — workspace / vault / metadataCache 都在它上面

---

## §3 manifest.json — 插件的身份证

```json
{
  "id": "hello-world",            // 必须和文件夹名一致
  "name": "Hello world",
  "version": "1.0.0",
  "minAppVersion": "1.4.0",       // 最低 Obsidian 版本
  "description": "Greets the user",
  "author": "Your Name",
  "isDesktopOnly": false,         // 需要 Node.js/Electron 时设 true
  "fundingUrl": "https://buymeacoffee.com/you"
}
```

**配套 `versions.json`**：每个版本号 → 对应最小 Obsidian 版本，让老版本用户能拿到能跑的旧版。

```json
{
  "1.0.0": "1.4.0",
  "1.1.0": "1.5.0"
}
```

**发布流程**（手动但极简）：
1. 改 `manifest.json` version
2. `npm version patch` 一键同步
3. GitHub Release 创建，**Tag = 纯版本号**（不要 v 前缀）
4. 上传 3 个 binary 附件：`manifest.json` / `main.js` / `styles.css`
5. **manifest.json 要在仓库根和 release 各一份**
6. PR 到 [obsidianmd/obsidian-releases](https://github.com/obsidianmd/obsidian-releases) 申请上架

> **设计含义**：把"上架"做成 PR 而不是 form，**所有审核都走代码评审**，永久可追溯。GitHub 既是源码托管又是 CDN，不需要自建。

---

## §4 扩展点 API — 这是核心设计

Obsidian 给插件**13 个标准扩展点**：

| # | API | 作用 | 何时用 |
|---|-----|------|--------|
| 1 | `addCommand()` | 注册命令面板 | 任何用户手动触发的功能 |
| 2 | `addRibbonIcon()` | 加左侧 ribbon 图标 | 高频功能 |
| 3 | `addStatusBarItem()` | 加底部状态栏 | 持久显示信息（时间、字数）|
| 4 | `registerEvent()` | 监听 vault/workspace 事件 | 响应文件/工作区变化 |
| 5 | `registerInterval()` | 注册 timer | 定时刷新 |
| 6 | `registerDomEvent()` | 监听 DOM 事件 | 全局快捷键、点击 |
| 7 | `addSettingTab()` | 加设置页 | 用户配置 |
| 8 | `registerMarkdownPostProcessor()` | 改 markdown 渲染 | 代码块高亮、mermaid |
| 9 | `registerEditorExtension()` | 扩展 CodeMirror 编辑器 | 语法高亮、自动补全 |
| 10 | `registerView()` | 注册自定义视图类型 | 日历、画布、表格 |
| 11 | `addChild()` | 父子插件 | 组合插件（Dataview 内嵌 JS 引擎）|
| 12 | `loadData()` / `saveData()` | 读写插件 `data.json` | 持久化配置 |
| 13 | `loadManifest()` | 重读 manifest | 动态更新 |

**设计原则**：
- **每个扩展点对应一个用户场景**（不是技术抽象）
- **`register*` 系列都自带生命周期管理**（作者忘清理不会泄漏）
- **`this.app` 提供整个 App 状态**（workspace / vault / metadataCache / fileManager）
- **`this.manifest` 自带自己的 manifest 数据**

**对比 Chrome MV3**：Chrome 的 4 个 context 是技术隔离（service worker / content script / popup），Obsidian 的 13 个扩展点是**用户场景抽象**（命令 / ribbon / 设置）。后者更友好，**插件作者不需要懂进程模型**。

---

## §5 沙盒模型 — "白名单 require" 而非独立进程

这是 Obsidian 最重要的安全设计选择。

### §5.1 能 require 什么

| 平台 | 可用模块 | 禁用模块 |
|------|---------|---------|
| **Desktop** | `obsidian` / `electron` | Node.js 内置（fs/path/child_process 全部） |
| **Mobile** | 仅 `obsidian`（无 Node 无 Electron）| 一切原生 API |

### §5.2 必须用 Obsidian 提供的 API

| 想做的事 | ❌ 不能用 | ✅ 必须用 |
|---------|----------|----------|
| 读 vault 内文件 | `fs.readFileSync` | `app.vault.read(file)` |
| 写文件 | `fs.writeFileSync` | `app.vault.modify(file, content)` |
| 监听文件变化 | `fs.watch` | `app.vault.on('modify', ...)` |
| 存储插件配置 | 写本地文件 | `plugin.loadData()` / `saveData()` |
| 存 API key | 明文写 `data.json` | `app.secretStorage.getSecret(name)`（1.13+）|
| DOM 操作 | `document.createElement` 直接用 | `createEl` / `createDiv`（CSP 友好）|

### §5.3 CSP 限制

```html
<!-- ❌ 不能内联 -->
<script>console.log('hi')</script>

<!-- ✅ 必须外链，且必须在 manifest 列出 -->
<script src="styles.js"></script>
```

> **设计哲学**（来自 [Less is Safer, Licat 2025-09-19](https://obsidian.md/blog/less-is-safer/)）：
> "插件和我们的核心代码运行在同一个 renderer process。我们**故意**不把插件隔离到独立进程，因为那会让 API 表达力大幅下降。我们选择**白名单 require + CSP + 严格 manifest 审核**作为安全层。"

### §5.4 SecretStorage（1.13+ 新）

> 之前：每个插件自己写 `data.json` 明文存 API key
> 现在：Obsidian 提供中央 secret store，**用户给某个 secret 起名 → 多个插件共享**

```typescript
// 插件设置只存 secret "名字"，不存值
new Setting(containerEl)
  .addComponent(el => new SecretComponent(this.app, el)
    .setValue(this.plugin.settings.mySetting)
    .onChange(value => this.plugin.settings.mySetting = value));

// 用时按名查
const apiKey = app.secretStorage.getSecret(this.settings.mySetting);
```

**设计含义**：把"安全管理"上移到宿主而不是每个插件各自实现 → **用户一次设置，跨插件共享**。

---

## §6 启动性能 — 这是个雷区

> "Obsidian loads all plugins before the user can interact with the app."
> —— [Optimize plugin load time](https://docs.obsidian.md/Plugins/Guides/Optimize+plugin+load+time)

**为什么重要**：Obsidian 启动时**同步加载所有启用的插件**才让用户交互。100 个插件 = 100 次 onload() 串行执行。

### §6.1 三大铁律

```typescript
async onload() {
  // ✅ 只做"注册"，不做"加载"
  this.addCommand(...)             // 注册
  this.registerEvent(...)          // 注册
  this.addSettingTab(...)          // 注册
  this.addRibbonIcon(...)          // 注册

  // ❌ 不能做这些
  await fetch('https://api...')    // 网络请求
  await this.app.vault.read(...)   // 文件读取
  heavy_computation()              // 计算
}

async onload() {
  // ✅ 延迟工作：用 onLayoutReady
  this.app.workspace.onLayoutReady(() => {
    this.loadHeavyData()
    this.fetchInitialState()
  })
}
```

### §6.2 经典坑：`vault.on('create')`

> "As a part of Obsidian's vault initialization process, it will call `create` for every file."
> —— 同上

如果插件监听 `vault.on('create')` 且不延迟 → Obsidian 启动时 vault 初始化会触发 1000+ 次 create 事件 → 插件卡死。

**两种解法**：

```typescript
// A. 检查 layoutReady
this.registerEvent(this.app.vault.on('create', () => {
  if (!this.app.workspace.layoutReady) return
  // do work
}))

// B. 延迟注册
this.app.workspace.onLayoutReady(() => {
  this.registerEvent(this.app.vault.on('create', this.onCreate))
})
```

### §6.3 构建优化

- **必须 production build**（不是 dev build）
- **必须 minify**（esbuild / rollup / webpack 都行）
- **不要把测试代码、dev tools 打包进 main.js**

> **设计含义**：Obsidian 选择"插件同步加载"换 API 简单性 → 把性能压力转嫁给插件作者。这是**有意识的 trade-off**，不是 bug。

---

## §7 设置系统演进 — 从命令式到声明式

### §7.1 1.13 之前：命令式 `display()`

```typescript
class MySettingTab extends PluginSettingTab {
  display() {
    const { containerEl } = this
    containerEl.empty()  // 清空再重渲

    new Setting(containerEl)
      .setName('Enable feature')
      .addToggle(toggle => toggle
        .setValue(this.plugin.settings.enabled)
        .onChange(async (v) => {
          this.plugin.settings.enabled = v
          await this.plugin.saveData(this.plugin.settings)
        }))

    new Setting(containerEl)
      .setName('Mode')
      .addDropdown(d => d
        .addOption('fast', 'Fast')
        .addOption('thorough', 'Thorough')
        .setValue(this.plugin.settings.mode ?? 'fast')
        .onChange(async (v) => {
          this.plugin.settings.mode = v as any
          await this.plugin.saveData(this.plugin.settings)
        }))
  }
}
```

### §7.2 1.13+ 之后：声明式 `getSettingDefinitions()`

```typescript
class MySettingTab extends PluginSettingTab {
  getSettingDefinitions() {
    return [
      {
        name: 'Enable feature',
        desc: 'Turns the feature on or off.',
        control: { type: 'toggle', key: 'enabled' },
      },
      {
        name: 'Mode',
        control: {
          type: 'dropdown',
          key: 'mode',
          defaultValue: 'fast',
          options: { fast: 'Fast', thorough: 'Thorough' },
        },
      },
    ]
  }
}
```

**好处**（Obsidian 接管）：
- 自动渲染
- **自动搜索索引**（设置可被全局搜索）
- 自动持久化
- 自动验证（用 `validate` 回调）
- 自动 i18n

> **设计含义**：Obsidian 1.13 的演进揭示了**插件架构不是一蹴而就**。命令式 → 声明式是 6 年后的自然演进，因为：
> 1. 早期 API 必须灵活（不能预言未来需求）
> 2. 6 年后看到 4000 插件的共性，**抽出 schema 是水到渠成**
> 3. 双轨兼容期（旧 `display()` + 新 `getSettingDefinitions()` 同时支持）

---

## §8 审核系统 — 2026-05 的"出大招"

### §8.1 之前的问题

- 手动审核每个 PR
- 6 年积压 2300+ 待审
- **只有首次提交审核，后续版本不审**
- coding agent 爆发让提交量爆炸

### §8.2 新系统（2026-05）

```
┌──────────────────────────────────────────┐
│          Developer Dashboard             │
│   (GitHub OAuth + 仓库管理)              │
└──────────┬───────────────────────────────┘
           │ submit
           ▼
┌──────────────────────────────────────────┐
│     Automated Review System              │
│   - 代码质量扫描                         │
│   - 已知漏洞检测                         │
│   - 恶意代码扫描                         │
│   - Developer Policy 合规                │
└──────────┬───────────────────────────────┘
           │ pass?
           ▼
┌──────────────────────────────────────────┐
│     Community 站 + Scorecard             │
│   - 安全评分卡（对用户可见）             │
│   - Disclosure 标签（网络/文件/剪贴板） │
│   - Verified author 标签                 │
│   - 下载统计、评分、版本历史             │
└──────────────────────────────────────────┘
```

### §8.3 给未来的启示

1. **审核规模化比早做重要** — Obsidian 等了 6 年才出自动化，**先让生态长大**
2. **Scorecard 把安全变成用户可见信号** — 用户有权选择
3. **Disclosure 强制声明插件访问了哪些能力** — 网络、文件系统、剪贴板
4. **手动审核继续保留** — 但只针对热门、Featured、用户举报

---

## §9 给"给现有产品加扩展"的 12 条设计建议

按 ROI 排序：

### 🥇 必须学（5 条）

| # | 建议 | Obsidian 怎么做 |
|---|------|---------------|
| 1 | **用 class 作插件入口** | `class MyPlugin extends Plugin` |
| 2 | **`register*` 系列自动管生命周期** | `registerEvent` / `registerInterval` / `registerDomEvent` |
| 3 | **manifest.json 是身份证** | `id` / `version` / `minAppVersion` / `isDesktopOnly` |
| 4 | **白名单 require + CSP** 而非独立进程 | `obsidian` / `electron` 之外的 require 都禁 |
| 5 | **`onload` 只注册不加载，重的放 `onLayoutReady`** | 启动性能可测 |

### 🥈 应该学（4 条）

| # | 建议 | Obsidian 怎么做 |
|---|------|---------------|
| 6 | **每个扩展点对应一个用户场景**，不是技术抽象 | 13 个 addXxx / registerXxx |
| 7 | **从命令式 API 起手** | 命令式 `display()` 用了 6 年才升级 |
| 8 | **Secret 集中存储，不让每个插件各自实现** | `app.secretStorage`（1.13+）|
| 9 | **发布用 GitHub Release**，不做自家 CI/CD | 3 个 binary 附件 + PR 上架 |

### 🥉 长期演进（3 条）

| # | 建议 | Obsidian 怎么做 |
|---|------|---------------|
| 10 | **从手动审核 → 自动审核 → 双轨** | 2026-05 自动审核上线，手动保留 |
| 11 | **Scorecard + Disclosure 把安全变成用户信号** | 网络/文件/剪贴板访问必须声明 |
| 12 | **6 年后加新 API 时双轨兼容** | 新 `getSettingDefinitions()` 和旧 `display()` 并存 |

---

## §10 如果照搬 Obsidian 范式，给你现有产品做扩展的清单

```markdown
□ 设计扩展点 API（5-10 个 addXxx / registerXxx）
  - 命令面板？Ribbon？Status bar？Setting？Editor 扩展？
  - 每个对应一个用户场景

□ 写 manifest schema
  - id / version / minVersion / author
  - 跨平台标志（isDesktopOnly / isMobileOnly）
  - 权限/能力声明（access network? filesystem? clipboard?）

□ 沙盒模型
  - 白名单 require（只暴露 SDK + 平台 API）
  - CSP（禁止内联 JS/CSS）
  - 文件 I/O 走宿主 API（不允许 fs.*）

□ 生命周期
  - onload / onunload 必须
  - register* 系列自动管（防泄漏）
  - onLayoutReady 延迟重活

□ Secret 管理
  - 中央 SecretStorage（不让每个插件各自存）

□ 启动性能
  - 同步加载所有插件 → onload 只注册
  - 提供 onLayoutReady 给延迟初始化
  - 提供启动时间调试工具

□ 发布流程
  - GitHub Release（3 个 binary 附件）
  - PR 上架（永久可追溯）
  - 不要自建 CDN / CI

□ Marketplace / 审核（先 MVP 后迭代）
  - v1：手动审核 + 简单 web 列表
  - v2：自动扫描 + Scorecard
  - v3：Disclosure + Verified author
```

---

## §11 引用

- [docs.obsidian.md/Plugins](https://docs.obsidian.md/Plugins/) — 完整官方 API 文档
- [obsidianmd/obsidian-sample-plugin](https://github.com/obsidianmd/obsidian-sample-plugin) — 官方模板
- [Anatomy of a plugin](https://docs.obsidian.md/Plugins/Getting+started/Anatomy+of+a+plugin)
- [Build a plugin](https://docs.obsidian.md/Plugins/Getting+started/Build+a+plugin)
- [Mobile development](https://docs.obsidian.md/Plugins/Getting+started/Mobile+development)
- [Optimize plugin load time](https://docs.obsidian.md/Plugins/Guides/Optimize+plugin+load+time)
- [Migrate to declarative settings](https://docs.obsidian.md/Plugins/Guides/Migrate+to+declarative+settings)
- [Store secrets](https://docs.obsidian.md/Plugins/Guides/Store+secrets)
- [Future of Plugins, 2026-05-12](https://obsidian.md/blog/future-of-plugins/) — 审核系统升级
- [Less is Safer, 2025-09-19](https://obsidian.md/blog/less-is-safer/) — Licat 的安全哲学
- Obsidian — 产品整体调研（创始故事 / 哲学 / 商业模式）

---

## §12 待办 / 未挖

- [ ] Obsidian Plugin API 完整 TS 定义（`obsidian.d.ts`）— 几百个类的官方索引
- [ ] Dataview / Templater / Excalidraw 三大明星插件的具体代码架构
- [ ] 移动端插件的具体限制清单（哪些 API 完全不可用）
- [ ] 父子插件（`addChild`）的实际使用案例
- [ ] CodeMirror 6 editor extension 的具体集成方式
- [ ] Obsidian Web Clipper 是怎么用浏览器扩展 + Obsidian API 桥接的
- [ ] 插件签名 / 验证机制（2026 自动审核后是否需要）
- [ ] 与同代 SaaS+扩展产品的对比：Figma Plugins / VS Code Extensions / Sketch Plugins / Notion API
