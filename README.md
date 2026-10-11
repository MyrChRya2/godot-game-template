# godot-game-template — 可复用的 Godot 游戏项目骨架

新游戏项目从这里起盘，**不要手工建目录**。

> 本仓从 `dummy-bird` 项目抽出（用 `git subtree split`，保留了完整提交历史），现在是与具体游戏解耦的**单一事实源**。

## 用法

```bash
cd <本仓目录>
./new-game.sh my-new-game                      # 默认输出到当前目录
./new-game.sh my-game --dir ~/projects         # 指定输出目录
./new-game.sh my-3d-game --renderer forward    # 3D 项目（默认 gl=2D 兼容）
```

生成后：**Godot → Project Manager → Import → 选 `<新项目>/GAME/project.godot`**。

生成脚本做的事：复制骨架 → 替换 `project.godot` 的工程名与渲染器 → `git init -b main` → 首次提交。

### 骨架开箱即可运行

自带默认主场景 `scenes/Main.tscn` 与 `run/main_scene`，**新项目按 F5 直接能跑**，不会撞 `Error: Can't run project: no main scene defined`。

要换成自己的场景（两种方式等价）：

```bash
godot --headless --path <新项目>/GAME --script res://tools/set_main_scene.gd -- res://scenes/MyScene.tscn
```

或在编辑器里 Project → Project Settings → Application → Run → Main Scene。

要换渲染器：

```bash
godot --headless --path <新项目>/GAME --script res://tools/set_renderer.gd -- gl   # gl | forward | mobile
```

## 目录结构

| 路径 | 作用 |
|---|---|
| `new-game.sh` | 生成脚本（复制骨架 → 替换工程名/渲染器 → `git init` → 首次提交） |
| `godot-2d/` | Godot 工程骨架（`assets/ scenes/ scripts/ tools/ DEV/`）。它本身不是一个可玩的游戏，**别直接打开** |
| `godot-2d/tools/engine/` | **工程设置工具**（跨项目可复用）：设置主场景、切渲染器、像素地基、注入输入动作 |
| `godot-2d/tools/debug/` | **玩法调试件**（本作专属）——**发布前整个删掉**。骨架里只有一份 README 说明用途 |
| `docs/` | 文档模板（GDD / ROADMAP / 文件树规范 / devlog），生成时拷进新项目的 `docs/` |
| `PROJECT_INDEX.template.md` | 项目索引模板，生成时替换 `__PROJECT_NAME__` / `__PROJECT_DIR__` / `__DATE__` |

## 设计说明

规范全文见 [`docs/PROJECT_TREE_TEMPLATE.md`](docs/PROJECT_TREE_TEMPLATE.md)。核心约定一句话：

> **仓库根 = 项目根**；`GAME/` 是引擎目录，`SOURCE/` 放美术源文件母版，`docs/` 放文档，`templates`/骨架不进游戏包。

### 关于"像 Photoshop 那样新建时选模板"

Godot 官方 Project Manager 的 New Project **只有 3 个渲染器预设，不支持自定义项目模板**（社区提案仍开放：[proposal #3388](https://github.com/godotengine/godot-proposals/issues/3388)、[discussion #11935](https://github.com/godotengine/godot-proposals/discussions/11935)）。

所以本方案的体验差距只有一点：**需要跑一条命令，而不是弹窗点一下**。

已评估并**决定不做**的方案：

- **EditorPlugin 加"生成目录结构"菜单**：有先有鸡还是先有蛋的问题——插件必须已存在于工程内才能运行，而"新建工程时选模板"发生在工程存在之前。它只能优化"新建之后的第一次整理"，替代不了本仓。
- 若 Godot 官方将来支持本地项目模板（proposal #3388 落地），直接改用它。

## 许可

**MIT License**（见 `LICENSE`），Copyright (c) 2026 MyrChRya2。可自由用于商业项目、可修改、可再分发，只需保留版权声明。

> `godot-2d/icon.svg` 来自 Godot 引擎自带的默认工程图标模板，版权归 Godot Engine 贡献者所有（MIT）。用它做新项目图标时请留意，正式发布前建议替换为原创图标。

## 版本与演进

本模板按"**每开一个新项目、每踩一次坑就回来改**"的方式迭代，改动记在 `docs/PROJECT_TREE_TEMPLATE.md` 的版本记录里。

- v0.3（2026-10-11）：新增 `tools/` 二分（`engine/` 跨项目可复用 / `debug/` 发布前删除）与"功能分组：一组同名目录"约定 —— 均来自 dummy-bird 的实操回流。
- v0.2（2026-10-11）：`SORCE`→`SOURCE`；主场景与渲染器工具化；抽出独立仓。
- v0.1（2026-10-11）：首版，随 dummy-bird 起盘建立。
