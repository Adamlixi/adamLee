---
layout: post
title: "🧡 Cassette Futurism · 2026 复古未来主流子流派"
tags: [ui-design]
---
> ⏰ 返回 MOC

## 为什么是 Cassette Futurism？

**Cassette Futurism** = **1970-80s 模拟时代**的视觉美学：
- 厚按钮、机械仪表、CRT 显示器、VHS 噪点
- 1980s 经典科幻电影（Alien / Blade Runner / Star Wars / Tron）
- 2024+ 影视复兴带动审美主流化（Stranger Things / Fallout TV / Severance）

## 视觉元素清单

### 🎨 配色

| 色名 | Hex | 用途 |
|------|-----|------|
| **深黑底** | `#0a0a0a` | 主背景（不是纯黑，略带层次） |
| **经典橙绿 LED** | `#ff6b00` / `#00ff41` | 数据 / 状态 / 警告 |
| **拉丝金属灰** | `#3a3a3a` | 边框 / 按钮外壳 |
| **冷白月光** | `#e0e0e0` | 主文字 |
| **事故红** | `#ff3333` | 严重警告 / 错误状态 |
| **等离子蓝** | `#0099ff` | 主操作 / 焦点 |
| **信号黄** | `#ffcc00` | 提示 / 次要操作 |

### 🔤 字体（全部 Google Fonts 免费）

| 字体 | 风格 | 用途 |
|------|------|------|
| **Orbitron** | 科技几何无衬线 | 主标题 / 品牌 |
| **Audiowide** | 80s 仪表显示感 | 副标题 / 数据 |
| **Michroma** | 21 世纪几何显示器 | 标语 / call-to-action |
| **Oxanium** | 等宽科技 | 数据 / 数字 |
| **VT323** | 终端等宽 | 代码 / 二级标签 |
| **Share Tech Mono** | 等宽稍圆 | 终端 / 数据表格 |
| **Major Mono Display** | 几何 mega 字体 | 全大写标题 |

### 📐 关键元素清单

1. **厚按钮**——有 box-shadow 显示立体感（按下时 translateY 1-2px）
2. **CRT 扫描线**——CSS `linear-gradient` 50% 重复制造横向细线
3. **辉光**——多层 `text-shadow` 给文字加 glow 效果
4. **拉丝金属边框**——CSS `linear-gradient` 制造金属感
5. **CRT 边界曲率**——`border-radius` 0%（早期 CRT 显示器边角是直的，后变曲）
6. **LED 灯**——绿色 / 橙色圆点，搭配微弱 pulse 动画
7. **模拟仪表**——SVG 半圆弧 + 旋转指针
8. **终端文本**——黑底 + 绿色等宽字体 + 闪烁光标
9. **网格背景**——双层 CSS 渐变制造参考栅格
10. **边角锯齿**——45° 切角（chamfered corners），工业感

## ⭐ 标杆开源项目

### [Imetomi/retro-futuristic-ui-design](https://github.com/Imetomi/retro-futuristic-ui-design)

- **作者**：Tamás Imets（匈牙利）
- **性质**：开源 React UI 组件库
- **风格**：80s 科幻内置 UI（Alien / Blade Runner 风）
- **数据**：Reddit r/RetroFuturism 多连发获赞 292 / r/web_design 评论 30+ / Hacker News 推荐
- **技术栈**：React + TypeScript + Tailwind + Framer Motion
- **特色**：
  - 完整组件库（Button / Card / Modal / Form / Table / Chart / Tabs / Slider）
  - 16+ 视觉风格主题一键切换
  - 完整 Figma 配套

→ 详见 Resource-Imetomi

### 其他开源资源

- [@react95](https://react95.io/) — Windows 95 风（可参考）
- [98.css](https://jdan.github.io/98.css/) — CSS 实现 Windows 98 风
- [XP.css](https://botoxparty.github.io/XP.css/) — Windows XP CSS
- [macOS.css](https://cdn.jsdelivr.net/npm/macos-css/) — macOS 风
- [terminal.css](https://terminalcss.xyz/) — 终端风 CSS

## 6 个可复制 CSS 片段

→ 详见 CSS-Retro-Effects：
1. **CRT 扫描线** / 2. **辉光文字** / 3. **厚按钮按下** / 4. **Glitch 文字** / 5. **终端风输入框** / 6. **网格背景**

## ⚠️ Cassette Futurism 适用场景

| ✅ 适合 | ❌ 不适合 |
|---------|----------|
| 开发者工具（IDE / CLI / SDK 文档） | 母婴 / 医疗（会显得冷酷） |
| 游戏（科幻 / 恐怖 / 复古 RPG） | 金融 / 银行（信任问题） |
| 个人作品集（想跳出模板） | 高端时尚（可能显得廉价） |
| 音乐工具 / DAW | 大企业 SaaS（不友好） |
| AI Agent UI（神秘感） | 餐饮 / 旅游 |
| 实验性产品（独立开发者首选） | 严肃的教育 / 严肃的政府 |

## 🔗 相关

- Retrofuturism-Subgenres
- Visual-Fonts
- Visual-Color-Palettes
- Visual-Elements
- CSS-Retro-Effects
- Resource-Imetomi

### Cross-reference
- Strudel-LiveCoding — 终端风编程工具 UI 天然适配
- iOS-General-AI-Agent — AI Agent UI 可以走 Cassette 风
- Obsidian-Plugin-Architecture — Obsidian 复古未来主题可行性
- Web-Scraping-Agent — 开发者工具天然适配 Cassette Futurism
