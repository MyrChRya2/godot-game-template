# godot-game-template

**中文** · [English](#english)

可复用的 Godot 游戏项目骨架。新游戏项目从这里起盘，**不要手工建目录**。

> 本仓从 `dummy-bird` 项目抽出（用 `git subtree split`，保留了完整提交历史），现在是与具体游戏解耦的**单一事实源**。
> 目录规范全文见 [`docs/PROJECT_TREE_TEMPLATE.md`](docs/PROJECT_TREE_TEMPLATE.md)。

---

## 快速开始

```bash
cd <本仓目录>
./new-game.sh my-new-game                      # 默认输出到当前目录
./new-game.sh my-game --dir ~/projects         # 指定输出目录
./new-game.sh my-3d-game --renderer forward    # 3D 项目（默认 gl=2D 兼容）
```

生成后：**Godot → Project Manager → Import → 选 `<新项目>/GAME/project.godot`**。

生成脚本做的事：复制骨架 → 替换 `project.godot` 的工程名与渲染器 → 生成双语 `README.md` 与 `PROJECT_INDEX.md` → `git init -b main` → 首次提交。

### 骨架开箱即可运行

自带默认主场景 `scenes/Main.tscn` 与 `run/main_scene`，**新项目按 F5 直接能跑**，不会撞 `Error: Can't run project: no main scene defined`。

要换成自己的场景（两种方式等价）：

```bash
godot --headless --path <新项目>/GAME --script res://tools/engine/set_main_scene.gd -- res://scenes/MyScene.tscn
```

或在编辑器里 Project → Project Settings → Application → Run → Main Scene。

要换渲染器：

```bash
godot --headless --path <新项目>/GAME --script res://tools/engine/set_renderer.gd -- gl   # gl | forward | mobile
```

---

## 生成出来的项目结构

```
my-new-game/                   # ← Git 仓库根 = 项目根（不是 Godot 工程根）
├── README.md                  # 双语结构说明（生成时替换项目名/日期）
├── PROJECT_INDEX.md           # 项目索引（空间地图 + 工作流约定）
├── LICENSE
├── docs/                      # 文档中心（不进游戏包）
│   ├── GDD.md                 #   设计文档
│   ├── ROADMAP.md             #   里程碑与任务
│   ├── PROJECT_TREE_TEMPLATE.md   # 目录规范全文
│   └── devlog/TEMPLATE.md     #   开发日志模板
├── GAME/                      # Godot 工程（res:// 指向这里）
│   ├── project.godot          #   工程配置（渲染器/拉伸/工程名）
│   ├── assets/                #   运行时素材（进游戏包）
│   │   ├── sprite/{bg,entity,item,tile}/
│   │   ├── audio/{bgm,sfx}/
│   │   └── font/  ui/
│   ├── scenes/                #   正式场景
│   │   ├── Main.tscn          #     主场景（开箱可跑）
│   │   └── ui/
│   ├── scripts/               #   正式脚本
│   │   ├── player/  systems/  ui/
│   ├── tools/                 #   工具脚本
│   │   ├── engine/            #     工程设置工具（保留）
│   │   └── debug/             #     玩法调试件（发布前整个删掉）
│   └── DEV/                   #   开发草稿区（原型与试验）
└── SOURCE/                    # 美术/音频源文件母版（不进游戏包，但必须入库）
```

---

## 分组依据：四条原则

### 1. 仓库根 = 项目根，而不是 Godot 工程根

`GAME/` 只是仓库里的一个目录，`docs/`、`SOURCE/` 与它平级。

| 方案 | 优点 | 代价 |
|---|---|---|
| **仓库根 = 项目根（本模板）** | 文档、美术源文件、导出配置、发布物全在一个仓库；只有一个 `.git`；换引擎/加工具不用挪窝 | Godot 的 `res://` 只到 `GAME/`，引擎看不到 `docs/`——**这正是目的**：文档不该进游戏包 |
| 仓库根 = `GAME/` | 打开即用，路径短 | 文档/源文件/构建脚本只能塞进工程内，会被 `res://` 扫描、被导出、污染工程搜索 |

### 2. 文档与代码分离（`docs/` vs `GAME/`）

Godot 会扫描 `res://` 下所有文件；`docs/` 在仓库根，编辑器完全不感知。
文档职责不重叠：**GDD 回答"是什么"、ROADMAP 回答"做什么"、devlog 回答"那天发生了什么"、PROJECT_INDEX 回答"东西在哪"**。

### 3. 运行时素材（`assets/`）与源文件母版（`SOURCE/`）分离

- `GAME/assets/` 放**导出成品**（`.png` / `.wav`），会被打进游戏包。
- `SOURCE/` 放**可编辑母版**（`.resprite` / `.aseprite` / `.psd` / `.blend`），**绝不进游戏包，但必须入库**。

> **为什么母版必须入库**：实测确认导出的 PNG 里**没有内嵌工程数据**（`tEXt/iTXt/zTXt` 块全空），
> 所以 `.resprite` 这类母版是唯一可编辑来源——丢了只能重画。

### 4. 功能分组：一个功能 = 一组同名目录

当某功能的文件散落在 `scripts/` 与 `scenes/` 且数量 ≥ 3，**或已被正式场景引用**，就为它建一组同名目录：

```
scripts/obstacle/          scenes/obstacle/
├── spawner.gd             ├── obstacle.tscn
├── curve.gd               └── half.tscn
└── obstacle.gd
```

> 不要一开始就建 `core/`、`managers/`、`interfaces/` 十层目录——那是在给还不存在的复杂度付租金。
> 起盘阶段 `assets/ scenes/ scripts/ DEV/` 就够，长到需要时再拆。完整演化判据见规范文档 §2.5。

---

## 本仓文件作用

| 路径 | 作用 |
|---|---|
| `new-game.sh` | 生成脚本（复制骨架 → 替换工程名/渲染器 → 生成 README/索引 → `git init` → 首次提交） |
| `godot-2d/` | Godot 工程骨架（`assets/ scenes/ scripts/ tools/ DEV/`）。它本身不是一个可玩的游戏，**别直接打开** |
| `README.template.md` | 新项目 README 模板（双语），生成时替换 `__PROJECT_NAME__` / `__DATE__` |
| `PROJECT_INDEX.template.md` | 项目索引模板，生成时替换 `__PROJECT_NAME__` / `__PROJECT_DIR__` / `__DATE__` |
| `docs/` | 文档模板（GDD / ROADMAP / 文件树规范 / devlog），生成时拷进新项目的 `docs/` |
| `godot-2d/tools/engine/` | **工程设置工具**（跨项目可复用）：主场景、渲染器、像素地基、输入动作 |
| `godot-2d/tools/debug/` | **玩法调试件**（本作专属）——**发布前整个删掉**。骨架里只有一份 README 说明用途 |

---

## 版本控制约定

| 文件 | 是否入库 | 原因 |
|---|---|---|
| `export_presets.cfg` | ✅ 提交 | 记录导出配置，换机能一键复现导出 |
| `*.uid` / `*.import` | ✅ 提交 | Godot 4.4+ 稳定资源标识与导入配置；不提交则改路径易引用错乱 |
| `SOURCE/**` 母版 | ✅ 提交 | 唯一可编辑来源，丢了无法复原 |
| `.godot/` | ❌ 忽略 | 引擎缓存，可重建 |
| `EXPORTS/` `build/` `dist/` | ❌ 忽略 | 可重新生成的构建产物 |
| `*.keystore` `*.jks` | ❌ 忽略 | **签名密钥绝不入库** |

---

## 给 AI / 自动化工具的复刻合约

> 按此实现并与本仓结构一致。**这节可当验收清单用。**

**必须（MUST）**

1. 仓库根 = 项目根；Godot 工程位于 `GAME/`，`project.godot` 在其中。
2. 顶层必须存在 `docs/`、`GAME/`、`SOURCE/`、`README.md`、`PROJECT_INDEX.md`；
   `GAME/` 内必须存在 `assets/`、`scenes/`、`scripts/`、`tools/`、`DEV/`。
3. `tools/` 必须二分：`engine/`（工程设置脚本）与 `debug/`（玩法调试件）。
4. `.gitignore` 必须忽略 `.godot/`、`EXPORTS/`、`build/`、`dist/`、`*.keystore`、`*.jks`。
5. `.gitignore` **不得**忽略 `export_presets.cfg`、`*.uid`、`*.import`、`SOURCE/**`。
6. `SOURCE/README.md` 必须写出「源文件 ↔ 运行时路径 ↔ 尺寸」对应表。
7. 运行时素材放 `GAME/assets/`，可编辑母版放 `SOURCE/`，**不得混放**。
8. 主场景必须写入 `project.godot` 的 `run/main_scene`（否则 F5 必然报错）。

**应当（SHOULD）**

9. 文档按职责拆分（GDD / ROADMAP / devlog / 结构规范），不写重复内容。
10. 功能文件达到 3 个或已被正式场景引用时，建 `scripts/<feature>/` + `scenes/<feature>/` 同名目录。
11. 共享 UI 样式用 Theme 资源，不逐节点 `theme_override_*`。
12. `tools/debug/` 不留任何跨项目内容；发布前整体删除即可。

**验收自检**

```bash
# 用模板生成一个临时工程，逐项检查
./new-game.sh verify-game --dir /tmp/verify && cd /tmp/verify/verify-game
for d in docs GAME GAME/assets GAME/scenes GAME/scripts GAME/tools GAME/tools/engine GAME/tools/debug GAME/DEV SOURCE; do
  [ -d "$d" ] || echo "缺失: $d"
done
[ -f README.md ] && ! grep -q "__PROJECT_NAME__" README.md && echo "ok: README 已生成且占位符已替换"
git check-ignore -q GAME/.godot && echo "ok: .godot 被忽略"
git check-ignore -q GAME/export_presets.cfg || echo "ok: export_presets.cfg 可提交"
godot --headless --path GAME --quit && echo "ok: 工程可运行"
cd - && rm -rf /tmp/verify
```

---

## 设计说明

### 关于"像 Photoshop 那样新建时选模板"

Godot 官方 Project Manager 的 New Project **只有 3 个渲染器预设，不支持自定义项目模板**（社区提案仍开放：
[proposal #3388](https://github.com/godotengine/godot-proposals/issues/3388)、
[discussion #11935](https://github.com/godotengine/godot-proposals/discussions/11935)）。

所以本方案的体验差距只有一点：**需要跑一条命令，而不是弹窗点一下**。

已评估并**决定不做**的方案：

- **EditorPlugin 加"生成目录结构"菜单**：有先有鸡还是先有蛋的问题——插件必须已存在于工程内才能运行，
  而"新建工程时选模板"发生在工程存在之前。它只能优化"新建之后的第一次整理"，替代不了本仓。
- 若 Godot 官方将来支持本地项目模板（proposal #3388 落地），直接改用它。

---

## 版本与演进

本模板按"**每开一个新项目、每踩一次坑就回来改**"的方式迭代，改动记在
[`docs/PROJECT_TREE_TEMPLATE.md`](docs/PROJECT_TREE_TEMPLATE.md) 的版本记录里。

- **v0.5（2026-10-27）** 生成物补齐 + 文档双语化：`new-game.sh` 现在会生成**双语 `README.md`**
  （新增 `README.template.md`，替换项目名与日期）——此前新项目根目录只有 `PROJECT_INDEX.md`，
  与结构规范要求的根 README 不一致；本 README 改为中英双语，并补上「分组依据四条原则」与
  「给 AI 的复刻合约（MUST/SHOULD + 验收自检）」。来源：dummy-bird 2026-10-27 的 README 实践回流。
- **v0.4（2026-10-12）** **文件树本身未变**：修正骨架的像素地基默认值——`set_pixel_perfect.gd` 与
  `godot-2d/project.godot` 的 `stretch/aspect` 由 `expand` 改 **`keep`**（`expand` 会让可见区域随窗口
  比例变化 → 画面穿帮）；工具注释补上三种 aspect 的取舍与实测数据。顺带修掉 `tools/` 二分后残留的旧路径。
- **v0.3（2026-10-11）** 新增 `tools/` 二分（`engine/` 跨项目可复用 / `debug/` 发布前删除）与
  "功能分组：一组同名目录"约定 —— 均来自 dummy-bird 的实操回流。
- **v0.2（2026-10-11）** `SORCE`→`SOURCE`；主场景与渲染器工具化；抽出独立仓。
- **v0.1（2026-10-11）** 首版，随 dummy-bird 起盘建立。

---

## 许可

**MIT License**（见 `LICENSE`），Copyright (c) 2026 MyrChRya2。可自由用于商业项目、可修改、可再分发，只需保留版权声明。

> `godot-2d/icon.svg` 来自 Godot 引擎自带的默认工程图标模板，版权归 Godot Engine 贡献者所有（MIT）。
> 用它做新项目图标时请留意，正式发布前建议替换为原创图标。

<br>

---

# English

[中文](#godot-game-template) · **English**

A reusable Godot game-project skeleton. Start new games from here — **don't hand-build the folder tree**.

> Extracted from the `dummy-bird` project with `git subtree split` (full commit history preserved).
> It is now the decoupled, game-agnostic **single source of truth**.
> The full folder spec (written in Chinese) is at [`docs/PROJECT_TREE_TEMPLATE.md`](docs/PROJECT_TREE_TEMPLATE.md).

---

## Quick start

```bash
cd <this-repo>
./new-game.sh my-new-game                      # output into the current directory
./new-game.sh my-game --dir ~/projects         # output into a specific directory
./new-game.sh my-3d-game --renderer forward    # 3D project (default gl = 2D compatibility)
```

Then: **Godot → Project Manager → Import → pick `<new-project>/GAME/project.godot`**.

What the generator does: copy the skeleton → substitute the project name and renderer in `project.godot`
→ generate a bilingual `README.md` and `PROJECT_INDEX.md` → `git init -b main` → initial commit.

### The skeleton runs out of the box

It ships with a default main scene (`scenes/Main.tscn`) and `run/main_scene`, so a new project **runs on F5
immediately** — you won't hit `Error: Can't run project: no main scene defined`.

To point it at your own scene (two equivalent ways):

```bash
godot --headless --path <new-project>/GAME --script res://tools/engine/set_main_scene.gd -- res://scenes/MyScene.tscn
```

Or in the editor: Project → Project Settings → Application → Run → Main Scene.

To switch renderer:

```bash
godot --headless --path <new-project>/GAME --script res://tools/engine/set_renderer.gd -- gl   # gl | forward | mobile
```

---

## What the generated project looks like

```
my-new-game/                   # ← Git repo root = project root (not the Godot project root)
├── README.md                  # bilingual structure guide (name/date substituted at generation)
├── PROJECT_INDEX.md           # project index (space map + workflow)
├── LICENSE
├── docs/                      # documentation hub (never shipped)
│   ├── GDD.md                 #   design document
│   ├── ROADMAP.md             #   milestones and tasks
│   ├── PROJECT_TREE_TEMPLATE.md   # full folder spec
│   └── devlog/TEMPLATE.md     #   development-log template
├── GAME/                      # Godot project (res:// points here)
│   ├── project.godot          #   project config (renderer / stretch / name)
│   ├── assets/                #   runtime assets (shipped)
│   │   ├── sprite/{bg,entity,item,tile}/
│   │   ├── audio/{bgm,sfx}/
│   │   └── font/  ui/
│   ├── scenes/                #   production scenes
│   │   ├── Main.tscn          #     main scene (runs out of the box)
│   │   └── ui/
│   ├── scripts/               #   production scripts
│   │   ├── player/  systems/  ui/
│   ├── tools/                 #   tool scripts
│   │   ├── engine/            #     project-setting tools (keep)
│   │   └── debug/             #     gameplay debug tools (delete before release)
│   └── DEV/                   #   draft area (prototypes and experiments)
└── SOURCE/                    # art/audio sources (never shipped, always committed)
```

---

## Grouping rationale: four principles

### 1. Repo root = project root, not the Godot project root

`GAME/` is just one directory inside the repo; `docs/` and `SOURCE/` sit next to it.

| Approach | Pros | Costs |
|---|---|---|
| **Repo root = project root (this template)** | Docs, art sources, export config and builds all in one repo; a single `.git`; swapping engines or adding tooling needs no relocation | Godot's `res://` stops at `GAME/`, so the engine can't see `docs/` — **which is the point**: docs must not end up in the build |
| Repo root = `GAME/` | Works immediately, shorter paths | Docs/sources/build scripts must live inside the project, where `res://` scans them, they leak into exports, and they pollute search |

### 2. Docs separate from code (`docs/` vs `GAME/`)

Godot scans everything under `res://`; `docs/` lives at the repo root, where the editor is unaware of it.
The documents have non-overlapping jobs: **GDD answers "what is it", ROADMAP answers "what's next",
devlog answers "what happened that day", PROJECT_INDEX answers "where is everything"**.

### 3. Runtime assets (`assets/`) separate from source masters (`SOURCE/`)

- `GAME/assets/` holds **exported end products** (`.png` / `.wav`), packed into the build.
- `SOURCE/` holds **editable masters** (`.resprite` / `.aseprite` / `.psd` / `.blend`) — **never shipped, always committed**.

> **Why masters must be committed**: it was verified that exported PNGs contain **no embedded project data**
> (the `tEXt`/`iTXt`/`zTXt` chunks are empty), so a `.resprite` master is the only editable source —
> lose it and you can only redraw.

### 4. Feature grouping: one feature = one pair of same-named directories

When a feature's files are scattered across `scripts/` and `scenes/` and number ≥ 3,
**or the feature is already referenced by a production scene**, give it a pair of same-named directories:

```
scripts/obstacle/          scenes/obstacle/
├── spawner.gd             ├── obstacle.tscn
├── curve.gd               └── half.tscn
└── obstacle.gd
```

> Don't pre-create ten levels of `core/`, `managers/`, `interfaces/` on day one — that's paying rent on
> complexity that doesn't exist yet. `assets/ scenes/ scripts/ DEV/` is enough at bootstrap time; split
> when it actually grows. Full evolution criteria: spec doc §2.5.

---

## What's in this repo

| Path | Purpose |
|---|---|
| `new-game.sh` | Generator (copy skeleton → substitute name/renderer → generate README/index → `git init` → initial commit) |
| `godot-2d/` | Godot project skeleton (`assets/ scenes/ scripts/ tools/ DEV/`). Not a playable game — **don't open it directly** |
| `README.template.md` | README template for new projects (bilingual); `__PROJECT_NAME__` / `__DATE__` substituted at generation |
| `PROJECT_INDEX.template.md` | Project-index template; `__PROJECT_NAME__` / `__PROJECT_DIR__` / `__DATE__` substituted |
| `docs/` | Doc templates (GDD / ROADMAP / folder spec / devlog), copied into the new project's `docs/` |
| `godot-2d/tools/engine/` | **Project-setting tools** (reusable across projects): main scene, renderer, pixel-perfect, input actions |
| `godot-2d/tools/debug/` | **Gameplay debug tools** (game-specific) — **delete the whole directory before release**; the skeleton only has a README |

---

## Version-control conventions

| File | Committed? | Why |
|---|---|---|
| `export_presets.cfg` | ✅ commit | Records export settings; lets you reproduce exports after switching machines |
| `*.uid` / `*.import` | ✅ commit | Stable resource IDs and import settings (Godot 4.4+); without them renames break references |
| `SOURCE/**` masters | ✅ commit | The only editable source; unrecoverable if lost |
| `.godot/` | ❌ ignore | Engine cache, rebuildable |
| `EXPORTS/` `build/` `dist/` | ❌ ignore | Reproducible build outputs |
| `*.keystore` `*.jks` | ❌ ignore | **Signing keys must never be committed** |

---

## Replication contract for AI / automation

> Implement this and you'll match this repo's structure. **Use this section as an acceptance checklist.**

**MUST**

1. Repo root = project root; the Godot project lives in `GAME/` and contains `project.godot`.
2. Top level must contain `docs/`, `GAME/`, `SOURCE/`, `README.md`, `PROJECT_INDEX.md`;
   `GAME/` must contain `assets/`, `scenes/`, `scripts/`, `tools/`, `DEV/`.
3. `tools/` must be split into `engine/` (project-setting scripts) and `debug/` (gameplay debug tools).
4. `.gitignore` must ignore `.godot/`, `EXPORTS/`, `build/`, `dist/`, `*.keystore`, `*.jks`.
5. `.gitignore` must **not** ignore `export_presets.cfg`, `*.uid`, `*.import`, or `SOURCE/**`.
6. `SOURCE/README.md` must contain a "source ↔ runtime path ↔ dimensions" mapping table.
7. Runtime assets go in `GAME/assets/`; editable masters go in `SOURCE/`; **never mix them**.
8. The main scene must be set in `project.godot`'s `run/main_scene` (without it, F5 always errors).

**SHOULD**

9. Split documentation by responsibility (GDD / ROADMAP / devlog / folder spec) with no duplicated content.
10. When a feature reaches 3 files or is referenced by a production scene, create same-named
    `scripts/<feature>/` + `scenes/<feature>/` directories.
11. Share UI styling through a Theme resource rather than per-node `theme_override_*`.
12. Keep `tools/debug/` free of anything reusable across projects; deleting the whole directory must suffice at release.

**Acceptance self-check**

```bash
# Generate a throwaway project from the template and verify
./new-game.sh verify-game --dir /tmp/verify && cd /tmp/verify/verify-game
for d in docs GAME GAME/assets GAME/scenes GAME/scripts GAME/tools GAME/tools/engine GAME/tools/debug GAME/DEV SOURCE; do
  [ -d "$d" ] || echo "missing: $d"
done
[ -f README.md ] && ! grep -q "__PROJECT_NAME__" README.md && echo "ok: README generated, placeholders substituted"
git check-ignore -q GAME/.godot && echo "ok: .godot ignored"
git check-ignore -q GAME/export_presets.cfg || echo "ok: export_presets.cfg committable"
godot --headless --path GAME --quit && echo "ok: project runs"
cd - && rm -rf /tmp/verify
```

---

## Design notes

### On "choose a template when creating a project, like Photoshop"

Godot's official Project Manager New Project dialog offers **only 3 renderer presets and does not support
custom project templates** (community proposals still open:
[proposal #3388](https://github.com/godotengine/godot-proposals/issues/3388),
[discussion #11935](https://github.com/godotengine/godot-proposals/discussions/11935)).

So the only experience gap here is: **you run one command instead of clicking a dialog**.

Evaluated and **deliberately not done**:

- **An EditorPlugin menu item to "generate the folder tree"**: chicken-and-egg — the plugin must already
  exist inside a project to run, while "pick a template at creation time" happens before the project exists.
  It could only improve "the first cleanup after creation", not replace this repo.
- If Godot ever supports local project templates (proposal #3388), switch to that instead.

---

## Version history

This template evolves by "**come back and fix it every time you start a new project or hit a new pitfall**";
changes are recorded in [`docs/PROJECT_TREE_TEMPLATE.md`](docs/PROJECT_TREE_TEMPLATE.md).

- **v0.5 (2026-10-27)** Generated output gap closed + docs bilingual: `new-game.sh` now generates a
  **bilingual `README.md`** (new `README.template.md`, with project-name/date substitution) — previously a
  new project had only `PROJECT_INDEX.md` at its root, contradicting the spec's root-README requirement;
  this README became bilingual and gained the "four grouping principles" and the
  "replication contract for AI (MUST/SHOULD + acceptance check)". Source: README work in `dummy-bird`, 2026-10-27.
- **v0.4 (2026-10-12)** **The folder tree itself is unchanged**: fixed the skeleton's pixel-perfect default —
  `stretch/aspect` in `set_pixel_perfect.gd` and `godot-2d/project.godot` changed from `expand` to **`keep`**
  (`expand` extends the viewport's short axis to match the window → visible area changes → visual breakage);
  tool comments now document the three aspect trade-offs with measured data. Also fixed stale paths left by
  the `tools/` split.
- **v0.3 (2026-10-11)** Added the `tools/` split (`engine/` reusable / `debug/` deleted before release) and
  "feature grouping: one pair of same-named directories" — both fed back from real `dummy-bird` work.
- **v0.2 (2026-10-11)** `SORCE`→`SOURCE`; main scene and renderer turned into tools; extracted into a standalone repo.
- **v0.1 (2026-10-11)** First version, bootstrapped alongside `dummy-bird`.

---

## License

**MIT License** (see `LICENSE`), Copyright (c) 2026 MyrChRya2. Free for commercial use, modification and
redistribution, provided the copyright notice is retained.

> `godot-2d/icon.svg` comes from Godot's built-in default project icon template; copyright belongs to the
> Godot Engine contributors (MIT). Keep that in mind when using it as a project icon, and prefer replacing it
> with original art before release.
