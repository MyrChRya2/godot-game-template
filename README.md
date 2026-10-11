# templates/ — 可复用项目骨架

新游戏项目从这里起盘，不要手工建目录。

## 用法

```bash
cd templates
./new-game.sh my-new-game                      # 默认输出到当前目录
./new-game.sh my-game --dir ~/projects         # 指定输出目录
./new-game.sh my-3d-game --renderer forward    # 3D 项目（默认 gl=2D 兼容）
```

生成后：**Godot → Project Manager → Import → 选 `<新项目>/GAME/project.godot`**。

## 结构

| 路径 | 作用 |
|---|---|
| `new-game.sh` | 生成脚本：复制骨架 → 替换工程名/渲染器 → `git init -b main` → 首次提交 |
| `godot-2d/` | Godot 工程骨架（`assets/ scenes/ scripts/ DEV/` + 被忽略的配置）。**本身不是一个可玩工程，别直接打开** |
| `docs/` | 文档模板（GDD / ROADMAP / 文件树模板 / devlog），生成时拷进新项目的 `docs/` |
| `PROJECT_INDEX.template.md` | 项目索引模板，生成时替换 `__PROJECT_NAME__` / `__PROJECT_DIR__` / `__DATE__` |

## 设计说明与演进方向

规范全文见 `docs/PROJECT_TREE_TEMPLATE.md`（本仓根）。

**关于"像 PS 那样新建时选模板"**：Godot 官方 Project Manager 目前**不支持自定义项目模板**（只有 3 个渲染器预设），社区提案仍开放： [proposal #3388](https://github.com/godotengine/godot-proposals/issues/3388)、[discussion #11935](https://github.com/godotengine/godot-proposals/discussions/11935)。因此本模板用「目录骨架 + 生成脚本」替代——**体验上的差距是：需要跑一条命令，而不是弹窗点一下。**

**未来若要消掉这条命令**（待决策）：

1. 写一个 Godot EditorPlugin，在编辑器菜单加"生成项目目录结构"——只能优化"新建之后的第一次整理"，无法在新建时弹出。
2. 把模板抽成**独立 git 模板仓**，`git clone` 起盘（多项目引用同一份规范）。
3. 若 Godot 官方支持了本地项目模板（proposal #3388 落地），直接改用它。

## 版本

- v0.1（2026-10-11）：首版，随 dummy-bird 起盘建立。
