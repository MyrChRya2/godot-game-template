# 📁 __PROJECT_NAME__ 项目管理文件索引

> 整理日期：__DATE__
> 本文件列出项目中与项目管理相关的全部文件及其作用，方便快速定位。
> **本文件也是 project-management skill 的项目配置入口**：路径约定、工作流规则都从这里读取。

## 〇、项目基本信息

| 项 | 值 |
|---|---|
| 项目名 | __PROJECT_NAME__ |
| 仓库根 | `__PROJECT_DIR__` |
| 引擎 | Godot 4.7.x |
| 目标平台 | ⬜ 待定 |
| 渲染器 | ⬜ 由生成时的 `--renderer` 决定 |
| 当前里程碑 | M0 工程基建（进行中） |

## 一、核心管理文档（`docs/`，已纳入 Git 版本控制）

| 路径 | 作用 |
|------|------|
| `docs/GDD.md` | **设计文档** — 项目的"宪法"：概述、核心设计、技术架构、待决策清单。 |
| `docs/ROADMAP.md` | **路线图** — 里程碑、任务清单与完成标准、优先级、决策记录、Bug 跟踪表。 |
| `docs/devlog/` | **开发日志目录** — 命名 `YYYY-MM-DD.md`（同日多篇加 `-b`/`-c` 后缀）。 |
| `docs/devlog/TEMPLATE.md` | **日志模板** — 每日收尾生成日志的骨架与提问清单。 |
| `docs/PROJECT_TREE_TEMPLATE.md` | **游戏文件树基础模板** — 目录分层约定、每层放什么、什么时候该拆。 |

## 二、仓库级管理配置（项目根）

| 路径 | 作用 |
|------|------|
| `.gitignore` | 根级 Git 忽略规则（含本机私有目录保护、`.godot/` 生成物） |
| `.gitattributes` | Git 属性（换行符统一 `eol=lf`） |
| `.editorconfig` | 编辑器统一配置（UTF-8） |
| `PROJECT_INDEX.md` | 本文件 — 索引与 skill 配置入口 |

## 三、工程内配置（`GAME/`）

| 路径 | 作用 |
|------|------|
| `GAME/project.godot` | Godot 工程配置（引擎版本、渲染器、窗口拉伸） |
| `GAME/icon.svg(+.import)` | 工程图标 |
| `GAME/assets/` | 运行时素材（`sprite/{bg,entity,item,tile}`、`audio/{bgm,sfx}`、`font/`、`ui/`） |
| `GAME/scenes/` | 正式场景（`.tscn`） |
| `GAME/scripts/` | GDScript 脚本 |
| `GAME/DEV/` | **开发草稿区**——原型场景/试验脚本；稳定后再移入 `scenes/`、`scripts/` |

## 四、仓库外配合目录

| 路径 | 作用 | 是否入 Git |
|------|------|-----------|
| `SORCE/` | **美术/音频源文件**（`.aseprite` / `.psd` / `.kra`）。母版放这里，导出成品进 `GAME/assets/`。 | 是（**必须入库**，源文件无版本控制=无备份） |

## 五、目录结构速览

```
__PROJECT_NAME__/                  # 项目根（Git 仓库根）
├── PROJECT_INDEX.md               # 本文件（skill 配置入口）
├── .gitignore / .gitattributes / .editorconfig
├── docs/                          # 文档中心
│   ├── GDD.md
│   ├── ROADMAP.md
│   ├── PROJECT_TREE_TEMPLATE.md
│   └── devlog/{TEMPLATE.md, YYYY-MM-DD.md}
├── GAME/                          # Godot 工程（引擎目录）
│   ├── project.godot
│   ├── assets/{sprite,audio,font,ui}/
│   ├── scenes/
│   ├── scripts/
│   └── DEV/                       # 开发草稿区
└── SORCE/                         # 美术/音频源文件母版
```

## 六、文档协作工作流（当前约定）

1. **决策** → 先写进当日 devlog，再同步 ROADMAP / GDD
2. **开发前** → 看 ROADMAP 优先级表
3. **设计疑问** → 查 GDD 待决策清单
4. **每日收尾** → 说"今天任务已结束"，AI 读 `docs/devlog/TEMPLATE.md` 生成日志
5. **路径/结构变更** → 必须同步更新本文件
6. **周期性任务** → 记录在 ROADMAP
7. **提交** → 小步原子提交，`type: subject` 英文前缀 + 中文正文

## 七、更新记录

- __DATE__：由 `godot-2d` 模板生成（索引首版）。
