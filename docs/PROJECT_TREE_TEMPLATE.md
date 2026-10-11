# 🗂️ 游戏项目文件树基础模板（v0.1）

> **跨项目复用**的目录规范：说明每一层放什么、为什么这么分、什么时候该拆。
> 每开一个新项目、每踩一次"文件找不到"的坑，就回来改本文件并升版本号。
> 配套可直接复制的骨架：同级的 `GAME/` 目录（由 `templates/new-game.sh` 生成）。
> 创建日期：__DATE__

---

## 1. 顶层设计：仓库根 = 项目根（不是引擎目录）

```
__PROJECT_NAME__/             # ← Git 仓库根 = 项目根
├── PROJECT_INDEX.md          # skill 配置入口 + 空间地图
├── docs/                     # 文档中心（见 §3）
├── GAME/                     # Godot 工程（引擎目录）
├── SORCE/                    # 美术/音频源文件母版（可编辑工程）
└── .gitignore .gitattributes .editorconfig
```

**为什么仓库根不放在 `GAME/`？**

| 方案 | 优点 | 代价 |
|---|---|---|
| **仓库根 = 项目根（本模板）** | 文档、美术源文件、导出配置、构建脚本、发布物全在一个仓库；`.git` 只有一个；换引擎/加工具不用挪窝 | Godot 的 `res://` 只到 `GAME/`，引擎看不到 `docs/`（这是**好事**：文档不该进游戏包） |
| 仓库根 = `GAME/` | 打开即用，路径短 | 文档/源文件/构建脚本只能塞进 Godot 工程内，会被 `res://` 扫描、被导出、污染工程搜索 |

> 唯一注意：Godot 编辑器"重新扫描文件系统"只覆盖 `GAME/` 内部，`docs/` 的变更 Godot 完全不感知——这正是分层的目的。

### `SORCE/`（美术源文件）为什么必须单独存在且必须入库

- **源文件 ≠ 运行时素材**：`.aseprite` / `.psd` / `.kra` / `.blend` 是"母版"，`GAME/assets/` 里的是"导出成品"（`.png` / `.wav`）。
- 母版放 `GAME/assets/` 有三个坏处：被 `res://` 扫描、进导出包、体积膨胀。
- **源文件不入库 = 没有备份**。改坏一次图层就永久损失，这是独立开发者最常见的不可逆事故。
- 目录按"素材类型 → 用途"两级，与 `GAME/assets/` **同名结构**，方便一一对应：

```
SORCE/
├── sprite/{bg,entity,item,tile}/   # 与 GAME/assets/sprite/ 同名
├── audio/                          # 与 GAME/assets/audio/ 同名
└── _ref/                           # 参考图、灵感收集、竞品截图
```

> 注：`SORCE` 是 `SOURCE` 的旧拼写（沿用自本模板初版来源项目）。**若要统一，改名为 `SOURCE/` 并同步 `PROJECT_INDEX.md`。**

---

## 2. Godot 工程内部（`GAME/`）

```
GAME/
├── project.godot            # 工程配置（引擎会改，正常提交）
├── icon.svg(+.import)       # 工程图标
├── assets/                  # 运行时素材（导出成品）
│   ├── sprite/{bg,entity,item,tile}/
│   ├── audio/{bgm,sfx}/
│   ├── font/
│   └── ui/
├── scenes/                  # 正式场景（.tscn）
│   └── ui/
├── scripts/                 # GDScript
│   ├── player/
│   ├── systems/
│   └── ui/
├── tools/                   # 引擎侧工具脚本（如 set_main_scene.gd）
├── shaders/                 # .gdshader（需要时创建）
├── addons/                  # 第三方/自研编辑器插件（需要时创建）
├── DEV/                     # ★ 开发草稿区（见 §2.3）
└── .godot/                  # 引擎生成物（**已在 .gitignore，永不提交**）
```

### 2.1 铁律：Godot 只认 `res://`，不认"约定"

引擎不会因为你把文件放进 `scripts/` 就自动关联，**一切靠场景文件里的路径引用**：

- 目录规范是**给人的**（可读、可找），不是给引擎的。
- 移动文件**必须用 Godot 编辑器拖拽**（它自动改所有引用），或移动后立刻重开编辑器重新导入。
- ⚠️ 在文件系统层面直接 `mv` 场景/脚本会打断所有引用。唯一安全的时刻是：**项目刚建、还没有交叉引用时**。
- 动手前先验证引用数：`grep -rn "res://" GAME --include="*.tscn" --include="*.gd"`——**引用了就别手改**。

### 2.2 命名约定

| 类型 | 约定 | 示例 |
|---|---|---|
| 场景 | `PascalCase.tscn`，与根节点同名 | `Player.tscn` |
| 脚本 | `snake_case.gd` | `player_state_machine.gd` |
| 素材 | `snake_case` + 用途后缀 | `bird_idle_01.png` |
| 目录 | 全小写、单数、英文 | `assets/` `scenes/` `scripts/` |
| 禁止 | 空格、中文、大写混排、拼写错误 | ❌ `Assest` `my scene.tscn` |

> 拼写错误是最常见的第一批技术债（`assest`/`scense`/`script`）。**建目录时慢一次，省后面一万次。**

### 2.3 `DEV/` 开发草稿区

- **放什么**：原型场景、一次性试验脚本、临时手感调试场景、验证 API 的 demo。
- **不放什么**：正式玩法代码、正式场景——那些进 `scenes/`、`scripts/`。
- **为什么需要**：原型阶段允许"脏"，但正式资产必须有唯一规范位置。混在一起的结果是半年后分不清哪个 `test2.tscn` 才是真正在跑的。
- **晋升机制**：草稿验证成功 → 在编辑器里移到 `scenes/`/`scripts/` 并纳入正式引用；验证失败 → 直接删。
- 可选优化：给 `DEV/` 放一个空的 `.gdignore`，Godot 不再扫描它（不参与导入、不进导出包）。**代价**：`DEV/` 里的场景将无法在编辑器里运行——所以只在草稿区稳定后再开。

### 2.4 主场景（`run/main_scene`）—— 起盘必做

**没有主场景的工程，按 F5 必然报 `Error: Can't run project: no main scene defined in the project.`**
本骨架已预置 `scenes/Main.tscn` + `run/main_scene` 来消除它。

设置方式二选一：

- **编辑器**：Project → Project Settings → Application → Run → Main Scene
- **命令行**：`godot --headless --path <GAME 目录> --script res://tools/set_main_scene.gd -- res://scenes/MyScene.tscn`

⚠️ **不要手改 `project.godot` 文本去写 UID**：Godot 的 UID 是 `0-9a-v` 编码，编造的 UID 可能非法。走引擎的 `ProjectSettings.save()`（即上面两种方式）让引擎自己决定格式——它会写成 `run/main_scene="uid://xxxxx"`。

### 2.5 什么时候该拆目录（避免过度设计）

**不要一开始就建 `core/`、`managers/`、`interfaces/` 十层目录**——那是给还不存在的复杂度付租金。

| 阶段 | 特征 | 目录形态 |
|---|---|---|
| **1. 起盘** | < 10 个文件 | `assets/ scenes/ scripts/ DEV/` 四个就够 |
| **2. 有玩法了** | 单文件 > 300 行，或同类文件 ≥ 3 个 | `scripts/` 按**功能**拆：`player/` `enemy/` `systems/` |
| **3. 有系统了** | 出现跨场景通用系统（存档、音频总线、事件总线） | 加 `autoload/`；`scenes/` 与 `scripts/` 按功能对齐 |
| **4. 按功能打包** | 一个功能涉及"场景+脚本+素材"三处 | 改用**功能文件夹**：`features/player/{player.tscn,player.gd,…}` |

**判据：如果一个功能的东西散落在三个顶层目录，且你要来回跳 3 次，就该按功能打包了。**

---

## 3. 文档中心（`docs/`）

```
docs/
├── GDD.md                     # 设计宪法：只留当前生效的设计结论
├── ROADMAP.md                 # 执行计划：里程碑/任务/决策记录/Bug 表
├── PROJECT_TREE_TEMPLATE.md   # 本文件：空间规范
└── devlog/
    ├── TEMPLATE.md            # 日志骨架
    └── YYYY-MM-DD(-x).md      # 流水账（唯一允许写过程的地方）
```

职责不重叠：**GDD 回答"是什么"、ROADMAP 回答"做什么"、devlog 回答"那天发生了什么"、PROJECT_INDEX 回答"东西在哪"**。同一件事只写一处，其余引用。

---

## 4. 从零开新项目（标准流程）

### 方式 A：复制骨架（推荐）

```bash
cd <dummy-bird>/templates
./new-game.sh my-new-game                    # 生成 ./my-new-game
./new-game.sh my-3d-game --renderer forward  # 3D 项目
./new-game.sh my-game --dir ~/projects       # 指定输出目录
```

脚本做的事：复制骨架 → 替换 `project.godot` 工程名与渲染器 → `git init -b main` → 首次提交。
生成后：

1. Godot → Project Manager → **Import** → 选 `<新项目>/GAME/project.godot`
2. 填 `docs/GDD.md` 的核心玩法（**先设计，再写代码**）
3. 按 `PROJECT_INDEX.md` §六 的工作流走

### 方式 B：Godot 官方"新建项目"（结构需手工补）

Godot 官方 Project Manager 的 **New Project** 只有渲染器预设（Forward+ / Mobile / Compatibility），**不支持自定义项目模板**——社区提案仍在开放状态：[proposal #3388](https://github.com/godotengine/godot-proposals/issues/3388)、[discussion #11935](https://github.com/godotengine/godot-proposals/discussions/11935)。

官方路径下只能：新建空工程 → 手工补目录与被忽略的配置 → 再建 `docs/`。**这正是方式 A 要消灭的重复劳动。**

### 方式 C：把"选模板"做进 Godot 界面（未实施）

可以写 EditorPlugin 在编辑器菜单加"生成项目目录结构"。**但有先有鸡还是先有蛋的问题**：插件必须已存在于工程内才能运行，而"新建工程时选模板"发生在工程存在之前——它只能优化"新建完之后的第一次整理"。**结论：暂不做。**

---

## 5. 演化路径（实测参考）

本机同类项目的真实形态：

| 形态 | 目录特征 | 适用阶段 |
|---|---|---|
| 扁平起盘 | `assets/ scenes/ scripts/` | 学习/小项目 |
| 类型分层 | 上述 + `shaders/ ui/ addons/ EXPORTS/` | 中等规模 |
| **功能文件夹** | `player/{player.tscn,scripts/,sprites/,states/,audio/}` + `tools/` | 成熟项目 |

**结论**：`assets/scenes/scripts`（起盘）→ 按功能分包（成熟）。**中间不要跳级。**

---

## 6. 待决策清单

| # | 决策项 | 选项 | 状态 |
|---|---|---|---|
| T1 | `SORCE/` 是否改名 `SOURCE/` | 改名统一 / 保留 | ⬜ |
| T2 | `DEV/` 是否加 `.gdignore` | 加（不被扫描）/ 不加（可运行） | ⬜ |
| T3 | 何时升级到"功能文件夹"形态 | 按 §2.4 阶段 4 判据 / 一开始就用 | ⬜ |
| T4 | 是否抽出独立 git 模板仓 | 独立仓 / 随主项目走 | ⬜ |

## 7. 版本记录

- **v0.1（__DATE__）** 首版，随 `templates/new-game.sh` 生成。
