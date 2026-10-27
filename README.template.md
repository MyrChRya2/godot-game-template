# __PROJECT_NAME__

**中文** · [English](#english)

> 一句话说明这是什么游戏。例：一款 2D 像素单键跳跃小游戏，目标平台 Web + Android。
> （替换本行后照 `docs/GDD.md` 深化设计）

---

## 快速开始

```bash
# 用 Godot 打开工程
#   Godot → Project Manager → Import → 选 GAME/project.godot

# 无头自检（不弹窗口，只验证工程能加载）
godot --headless --path GAME --quit

# 运行
godot --path GAME
```

## 目录结构

```
__PROJECT_NAME__/            # ← Git 仓库根 = 项目根
├── README.md                # 本文件
├── PROJECT_INDEX.md         # 项目索引（空间地图 + 工作流约定）
├── LICENSE
├── docs/                    # 文档中心（不进游戏包）
│   ├── GDD.md               #   设计文档
│   ├── ROADMAP.md           #   里程碑与任务
│   ├── PROJECT_TREE_TEMPLATE.md  # 目录规范全文
│   ├── tech-art-log.md      #   技美实验日志（按需）
│   └── devlog/              #   开发日志
├── GAME/                    # Godot 工程（res:// 指向这里）
│   ├── project.godot
│   ├── assets/              #   运行时素材（进游戏包）
│   ├── scenes/              #   正式场景
│   ├── scripts/             #   正式脚本
│   ├── resources/           #   自定义 Resource 数据（按需）
│   ├── tools/               #   engine/（工程设置，保留）/ debug/（发布前删掉）
│   └── DEV/                 #   开发草稿区（原型与试验）
└── SOURCE/                  # 美术/音频源文件母版（不进游戏包，但必须入库）
```

## 三条硬约定

1. **仓库根 = 项目根**，Godot 工程在 `GAME/`，文档与源文件在仓库根——引擎看不到它们，这是故意的。
2. **运行时素材放 `GAME/assets/`，可编辑母版放 `SOURCE/`**，两者不混放（母版丢了无法复原）。
3. **`tools/` 二分**：`engine/` 是跨项目可复用的工程设置脚本（保留）；`debug/` 是玩法调试件（**发布前整个删掉**）。

版本控制：提交 `export_presets.cfg`、`*.uid`、`*.import`、`SOURCE/**`；忽略 `.godot/`、`EXPORTS/`、`*.keystore`。

## 下一步

1. 填 `docs/GDD.md` 的核心玩法（**先设计，再写代码**）
2. 在 `docs/ROADMAP.md` 排里程碑
3. 每天收尾时说 **"今天任务已结束"**，让 AI 按 `docs/devlog/TEMPLATE.md` 生成当日日志
4. 需要远端时：`git remote add origin <url> && git push -u origin main`

创建日期：__DATE__

---

# English

[中文](#__PROJECT_NAME__) · **English**

> One sentence describing the game. E.g. a 2D pixel-art one-button jump game for web + Android.
> (Replace this line, then flesh it out in `docs/GDD.md`)

## Quick start

```bash
# Open the project
#   Godot → Project Manager → Import → pick GAME/project.godot

# Headless self-check (no window, just verifies the project loads)
godot --headless --path GAME --quit

# Run
godot --path GAME
```

## Structure

```
__PROJECT_NAME__/            # ← Git repo root = project root
├── README.md                # this file
├── PROJECT_INDEX.md         # project index (space map + workflow)
├── LICENSE
├── docs/                    # documentation hub (never shipped)
│   ├── GDD.md               #   design document
│   ├── ROADMAP.md           #   milestones and tasks
│   ├── PROJECT_TREE_TEMPLATE.md  # full folder spec (written in Chinese)
│   ├── tech-art-log.md      #   technical-art experiment log (optional)
│   └── devlog/              #   development log
├── GAME/                    # Godot project (res:// points here)
│   ├── project.godot
│   ├── assets/              #   runtime assets (shipped)
│   ├── scenes/              #   production scenes
│   ├── scripts/             #   production scripts
│   ├── resources/           #   custom Resource data (optional)
│   ├── tools/               #   engine/ (project settings, keep) / debug/ (delete before release)
│   └── DEV/                 #   draft area (prototypes and experiments)
└── SOURCE/                  # art/audio sources (never shipped, always committed)
```

## Three hard rules

1. **Repo root = project root.** The Godot project lives in `GAME/`; docs and sources sit next to it —
   the engine can't see them, and that's deliberate.
2. **Runtime assets go in `GAME/assets/`, editable masters go in `SOURCE/`.** Never mix them
   (a lost master can't be recovered).
3. **`tools/` is split in two**: `engine/` holds reusable project-setting scripts (keep);
   `debug/` holds gameplay debug tools (**delete the whole directory before release**).

Version control: commit `export_presets.cfg`, `*.uid`, `*.import`, `SOURCE/**`;
ignore `.godot/`, `EXPORTS/`, `*.keystore`.

## Next steps

1. Fill in the core gameplay in `docs/GDD.md` (**design first, then code**)
2. Plan milestones in `docs/ROADMAP.md`
3. At the end of each day, say **"今天任务已结束"** and have the AI generate the devlog
   from `docs/devlog/TEMPLATE.md`
4. When you need a remote: `git remote add origin <url> && git push -u origin main`

Created: __DATE__
