# 🗂️ 游戏项目文件树基础模板（v0.3）

> 本文件是**跨项目复用**的目录规范：说明每一层放什么、为什么这么分、什么时候该拆。
> 它随 dummy-bird 一起演进——**每开一个新项目、每踩一次"文件找不到"的坑，就回来改本文件并升版本号。**
> 配套可直接复制的骨架：`templates/godot-2d/`，生成脚本 `templates/new-game.sh`。
> 最后更新：2026-10-11

---

## 1. 顶层设计：仓库根 = 项目根（不是引擎目录）

```
my-game/                      # ← Git 仓库根 = 项目根
├── PROJECT_INDEX.md          # skill 配置入口 + 空间地图
├── docs/                     # 文档中心（见 §3）
├── GAME/                     # Godot 工程（引擎目录）
├── SOURCE/                    # 美术/音频源文件母版（可编辑工程）
├── templates/                # 可复用骨架与本模板
└── .dsh-meow/                # AI 会话记忆库（不入 Git）
```

**为什么仓库根不放在 `GAME/`？**

| 方案 | 优点 | 代价 |
|---|---|---|
| **仓库根 = 项目根（本模板）** | 文档、美术源文件、导出配置、构建脚本、发布物全在一个仓库；`.git` 只有一个；换引擎/加工具不用挪窝 | Godot 的 `res://` 只到 `GAME/`，引擎看不到 `docs/`（这是**好事**：文档不该进游戏包） |
| 仓库根 = `GAME/` | 打开即用，路径短 | 文档/源文件/构建脚本只能塞进 Godot 工程内，会被 `res://` 扫描、被导出、污染工程搜索 |

> 唯一注意：Godot 编辑器里"重新扫描文件系统"只覆盖 `GAME/` 内部，`docs/` 的变更 Godot 完全不感知——这正是分层的目的。

### `SOURCE/`（美术源文件）为什么必须单独存在且必须入库

- **源文件 ≠ 运行时素材**：`.aseprite` / `.psd` / `.kra` / `.blend` 是"母版"，`GAME/assets/` 里的是"导出成品"（`.png` / `.wav`）。
- 母版放 `GAME/assets/` 会有三个坏处：被 `res://` 扫描、进导出包、体积膨胀。
- **源文件不入库 = 没有备份**。改坏一次图层就永久损失，这是独立开发者最常见的不可逆事故。
- 目录按"素材类型 → 用途"两级，与 `GAME/assets/` 保持**同名结构**，方便一一对应：

```
SOURCE/
├── sprite/{bg,entity,item,tile}/   # 与 GAME/assets/sprite/ 同名
├── audio/                          # 与 GAME/assets/audio/ 同名
└── _ref/                           # 参考图、灵感收集、竞品截图（不一定用得上）
```

> 拼写说明：该目录 2026-10-11 前拼作 `SORCE`（对照 `assest`/`scense`/`script` 的同一类问题），已随本轮拼写统一改名为 `SOURCE`。

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
│   ├── Player.tscn
│   ├── playground.tscn
│   └── ui/                  # 界面场景（多了再拆）
├── scripts/                 # GDScript
│   ├── player/
│   ├── systems/
│   └── ui/
├── tools/
│   ├── engine/              # ★ 工程设置工具（跨项目可复用，见 §2.7）
│   └── debug/               # ★ 玩法调试件（本作专属，发布前删除，见 §2.7）
├── shaders/                 # .gdshader（需要时创建）
├── addons/                  # 第三方/自研编辑器插件（需要时创建）
├── DEV/                     # ★ 开发草稿区（原型/试验，见 §2.3）
└── .godot/                  # 引擎生成物（**已在 .gitignore，永不提交**）
```

### 2.1 铁律：**Godot 只认 `res://`，不认"约定"**

引擎不会因为你把文件放进 `scripts/` 就自动关联，**一切靠场景文件里的路径引用**。因此：

- 目录规范是**给人的**（可读、可找），不是给引擎的。
- 移动文件在 Godot 里**必须用编辑器拖拽**（它会自动改所有引用）或移动后立刻重开编辑器重新导入。
- ⚠️ 在文件系统层面直接 `mv` 场景/脚本，**会打断所有引用**。本模板唯一"文件系统级改名"安全的时刻是：**项目刚建、还没有交叉引用时**。

> 实战记录：dummy-bird 的 `assest → assets` 改名之所以零风险，是因为当时两个 `.tscn` 里**零个 `res://` 引用**（用 `grep -rn "res://" GAME/*.tscn` 验证过）。以后改名一律先在编辑器里做。

### 2.2 命名约定

| 类型 | 约定 | 示例 |
|---|---|---|
| 场景 | `PascalCase.tscn`，与根节点同名 | `Player.tscn` |
| 脚本 | `snake_case.gd` | `player_state_machine.gd` |
| 素材 | `snake_case` + 用途后缀 | `bird_idle_01.png` |
| 目录 | 全小写、单数、英文 | `assets/` `scenes/` `scripts/` |
| 禁止 | 空格、中文、大写混排、拼写错误 | ❌ `Assest` `my scene.tscn` |

> 目录名拼写错误是本项目踩过的第一个坑（`assest`/`scense`/`script`）。**建目录时慢一次，省后面一万次。**

### 2.3 `DEV/` 开发草稿区（重要）

- **放什么**：原型场景、一次性试验脚本、临时的手感调试场景、验证某个 API 的 demo。
- **不放什么**：正式玩法代码、正式场景——那些进 `scenes/`、`scripts/`。
- **为什么需要它**：原型阶段允许"脏"，但正式资产必须有唯一规范位置。混在一起的结果是半年后分不清哪个 `test2.tscn` 才是真正在跑的。
- **晋升机制**（约定）：草稿验证成功 → **在编辑器里**移到 `scenes/`/`scripts/` 并纳入正式引用；验证失败 → 直接删。
- 可选优化：给 `DEV/` 放一个空的 `.gdignore` 文件，Godot 就不再扫描它（原型代码不参与导入、不进导出包）。✅ **代价**：`DEV/` 里的场景将无法在编辑器里运行——所以这个开关只在草稿区稳定后开。

### 2.4 主场景（`run/main_scene`）—— 起盘必做

**没有主场景的工程，按 F5 必然报 `Error: Can't run project: no main scene defined in the project.`**
这是新工程最常撞的第一个坑（本模板已通过预置 `scenes/Main.tscn` + `run/main_scene` 消除它）。

设置方式二选一：

- **编辑器**：Project → Project Settings → Application → Run → Main Scene
- **命令行**：`godot --headless --path <GAME 目录> --script res://tools/engine/set_main_scene.gd -- res://scenes/MyScene.tscn`

⚠️ **不要手改 `project.godot` 文本去写 UID**：Godot 的 UID 是 `0-9a-v` 编码，编造的 UID 可能非法。走引擎的 `ProjectSettings.save()`（即上面两种方式）让引擎自己决定格式——它会写成 `run/main_scene="uid://xxxxx"`。

### 2.5 什么时候该拆目录（避免过度设计）

**不要一开始就建 `core/`、`managers/`、`interfaces/` 十层目录**——那是在给还不存在的复杂度付租金。

按这个顺序演化（本项目当前处于阶段 1）：

| 阶段 | 特征 | 目录形态 |
|---|---|---|
| **1. 起盘** | < 10 个文件 | `assets/ scenes/ scripts/ DEV/` 四个就够 |
| **2. 有玩法了** | 单文件 > 300 行，或同类文件 ≥ 3 个 | `scripts/` 按**功能**拆：`player/` `enemy/` `systems/` |
| **2.5. 功能成组** | 某功能的文件散在两处且 ≥ 3 个，或**已被正式场景引用** | 给它一组同名目录：`scripts/<feature>/` + `scenes/<feature>/`（见 §2.7） |
| **3. 有系统了** | 出现跨场景的通用系统（存档、音频总线、事件总线） | 加 `autoload/`；`scenes/` 与 `scripts/` 开始按功能对齐 |
| **4. 按功能打包** | 一个功能涉及"场景+脚本+素材"三处 | 改用**功能文件夹**：`features/player/{player.tscn,player.gd,...}`（见 §5 参考：EndlessRegret 的做法） |

**判据：如果一个功能的东西散落在三个顶层目录里，且你要来回跳 3 次，就该按功能打包了。**

### 2.6 `tools/` 二分：engine 与 debug

> 来源：dummy-bird 实操中发现 `tools/` 混着两类性质完全不同的脚本，用户拍板二分
> （原话：**"我发布游戏时肯定会删掉调试工具"**）。

| 目录 | 放什么 | 特征 | 发布时 |
|---|---|---|---|
| `tools/engine/` | 改工程配置的脚本：设置主场景、切渲染器、像素地基、注入输入动作 | **跨项目可复用**（同一批脚本在模板仓里也有一份） | **保留** |
| `tools/debug/` | 玩法调试件：曲线预览、游戏内调参面板、状态可视化 | **本作专属**，依赖本作的资源与场景 | **整体删除** |

**为什么必须分开**：要让"发布前删掉调试工具"变成一个**可执行的动作**（删一个目录），
而不是"在一堆脚本里挑哪个是调试的"。混放的后果是发布包里混进调试代码，或删错文件。

### 2.7 功能分组：一个功能 = 一组同名目录

> 来源：dummy-bird 的障碍物系统一开始放在 `DEV/` 草稿区，长到 5 个文件后
> **已被主场景引用**——它事实上升级成了正式代码，却还躺在草稿区里。

**信号**：当某个功能的文件散落在 `scripts/` 与 `scenes/` 且数量 ≥ 3，或**它已被正式场景引用**，就该给它一组文件夹。

```
scripts/obstacle/          scenes/obstacle/
├── spawner.gd             ├── obstacle.tscn
├── curve.gd               └── half.tscn
└── obstacle.gd
```

- **按功能分组，不按类型摊平**：`scripts/obstacle/*` 与 `scenes/obstacle/*` **同名对应**，
  找"障碍物相关的一切"只需看两个同名目录。
- **好处在扩展期才显现**：用户明说"以后可能会增加不同种类与属性的 obstacle"——
  按功能分组后，新增一类障碍 = 往 `obstacle/` 里加文件，而不是往一个 20 文件的 `scripts/` 里塞。
- **与 §5 的"功能文件夹"不同**：这里是**同类型内按功能分目录**，不是把脚本和场景混进同一个文件夹。
  前者适合"类型职责清晰、功能会增长"的项目；后者适合功能内聚度极高的成熟项目。

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

### 方式 A：复制骨架（推荐，当前可用）

```bash
cd /mnt/d/Fox_n/!PROJECTS/#software/Projects/games/godot-game-template   # ← 独立模板仓（单一事实源）
./new-game.sh my-new-game            # 生成 ./my-new-game 并完成 git init + 首次提交
```

> 模板已抽出为**独立仓**，不在本仓库内：`../godot-game-template/`（用 `git subtree split` 从本项目带出完整提交历史）。
> 本项目不再保留副本——**双副本必然漂移**（2026-10-11 实际发生过一次）。

脚本做的事：复制骨架 → 替换 `project.godot` 里的工程名 → `git init -b main` → 首次提交。
生成后：

1. 用 Godot 打开 `<新项目>/GAME/`（Project Manager → Import → 选 `GAME/project.godot`）
2. 照 §3 填 `docs/GDD.md`（**先定核心玩法，再写代码**）
3. 照 `PROJECT_INDEX.md` §六 的工作流走

### 方式 B：Godot 官方"新建项目"（结构需手工补）

Godot 官方 Project Manager 的 **New Project** 只有渲染器预设（Forward+ / Mobile / Compatibility），**不支持自定义项目模板**——社区提案仍在开放状态：[proposal #3388](https://github.com/godotengine/godot-proposals/issues/3388)、[discussion #11935](https://github.com/godotengine/godot-proposals/discussions/11935)。

所以官方路径下只能：新建空工程 → 手工补 `assets/ scenes/ scripts/ DEV/` 与被忽略的配置 → 再建 `docs/`。**这正是方式 A 要消灭的重复劳动。**

### 可选：把"选模板"做进 Godot 界面（未实施，待定）

理论上可以写一个 EditorPlugin，在编辑器菜单加一项"生成项目目录结构"，一键补齐 `assets/scenes/scripts/DEV` 并写好 `project.godot` 关键设置。**但有个先有鸡还是先有蛋的问题**：插件必须存在于工程内才能运行，而"新建工程时选模板"发生在工程存在之前——所以它只能优化"新建完之后的第一次整理"，不能替代方式 A。**结论：暂不做，先让方式 A 跑顺。**（待决策见 §6）

---

## 5. 参考：同类真实项目的目录形态（本机实测）

| 项目 | 形态 | 可借鉴之处 |
|---|---|---|
| `learning/games/2d-farm` | `assets/game/` `scenes/{characters,test}/` `scripts/state_machins/` `Tilesets/` | 与模板基本一致（`assets` 拼写正确） |
| `game_jam/BGJAM_14/MINER` | `addons/TileMapDual` `assets/` | 有插件时 `addons/` 独立成层 |
| `teamwork/.../retro-game-jam-2026` | `EXPORTS/` `assets/` `scenes/` `scripts/` `shaders/` `ui/` `item/` `monster/` | **功能文件夹**雏形 + 导出物独立到 `EXPORTS/` |
| `learning/games/EndlessRegret/Game_Build` | `player/{player.tscn,scripts/,sprites/,states/,audio/}` `addons/debug_system` `tools/` | **功能文件夹成熟态**：一个角色一个包，自带场景/脚本/素材/状态机；`tools/` 放一次性脚本 |

**演化路径结论**：`assets/scenes/scripts`（起盘）→ 按功能分包（成熟）。中间不要跳级。

---

## 6. 待决策清单

> 全部 5 项已由用户于 2026-10-11 拍板。**编号保留不改号**（编号是对外接口），新决策往后加。

| # | 决策项 | 选项 | 状态 | 用户结论 |
|---|---|---|---|---|
| T1 | `SORCE/` 是否改名 | 改名统一拼写 / 保留现状 | ✅ | **改名** → `SOURCE/`（已落实） |
| T2 | `DEV/` 是否加 `.gdignore` | 加（不被扫描、不能运行）/ 不加（可运行） | ✅ | **不要加**——草稿区要能在编辑器里直接运行 |
| T3 | 何时升级到"功能文件夹"形态 | 按 §2.5 阶段 4 判据 / 项目一开始就用 | ✅ | **按 §2.5 判据**（不跳级） |
| T4 | 是否把本模板抽出为独立 git 模板仓 | 独立仓（多项目引用）/ 随 dummy-bird 走 | ✅ | **单独抽出** → `../godot-game-template/`（用 `git subtree split` 保留了提交历史） |
| T5 | 是否开发 EditorPlugin 做目录生成 | 做 / 不做（见 §4 方式 C 的局限） | ✅ | **不做**——先让方式 A 跑顺 |
| T6 | `tools/` 是否分 engine / debug | 不分 / 二分 | ✅ | **二分**——让"发布前删调试工具"成为可执行动作（删一个目录） |
| T7 | 功能何时从 DEV 转正 | 攒着 / 一被正式场景引用就转正 | ✅ | **一被正式场景引用就转正**（那时它已不是草稿） |

## 7. 版本记录

- **v0.3（2026-10-11）** 新增 §2.6（tools 二分 engine/debug）与 §2.7（功能分组：一组同名目录）；§2.5 演化表补"功能成组"阶段；待决策补 T6/T7。来源：dummy-bird 障碍物系统从 DEV 转正 + tools 混放的实操。
- **v0.2（2026-10-11）** 全部 5 项待决策落实：`SORCE`→`SOURCE`、`DEV/` 不加 `.gdignore`、按阶段判据演化、模板抽出独立仓、不做 EditorPlugin。
- **v0.1（2026-10-11）** 首版：确立「仓库根=项目根」、`assets/scenes/scripts/DEV` 四层、`SOURCE/` 源文件层、文档中心四文件、四阶段演化判据。来源：dummy-bird 起盘 + 本机 4 个同类项目实测对比。
