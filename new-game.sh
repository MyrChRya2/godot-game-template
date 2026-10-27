#!/usr/bin/env bash
# ============================================================
# new-game.sh — 从骨架生成一个新游戏项目（仓库根 = 项目根）
#
# 用法：
#   ./new-game.sh <项目名> [--dir <输出目录>] [--renderer gl|forward|mobile]
#
# 生成内容：
#   <输出目录>/<项目名>/
#   ├── README.md          # 从 README.template.md 生成（双语），替换项目名与日期
#   ├── PROJECT_INDEX.md   # 从 PROJECT_INDEX.template.md 生成并替换占位符
#   ├── docs/              # GDD / ROADMAP / 文件树模板 / devlog 骨架
#   ├── GAME/              # Godot 工程（assets/scenes/scripts/DEV）
#   ├── SOURCE/             # 美术/音频源文件母版
#   ├── .gitignore / .gitattributes / .editorconfig
#   └── .git               # 已 git init + 首次提交
# ============================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKELETON="$SCRIPT_DIR/godot-2d"
INDEX_TEMPLATE="$SCRIPT_DIR/PROJECT_INDEX.template.md"

die() { echo "✗ $*" >&2; exit 1; }

# ---------- 参数 ----------
PROJECT_NAME=""
OUT_DIR="$PWD"
RENDERER="gl"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dir)      OUT_DIR="${2:?--dir 需要一个路径}"; shift 2 ;;
    --renderer) RENDERER="${2:?--renderer 需要 gl|forward|mobile}"; shift 2 ;;
    -h|--help)  sed -n '3,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)         die "未知参数：$1" ;;
    *)          [[ -n "$PROJECT_NAME" ]] && die "只能指定一个项目名"; PROJECT_NAME="$1"; shift ;;
  esac
done

[[ -n "$PROJECT_NAME" ]] || die "用法：./new-game.sh <项目名> [--dir <输出目录>] [--renderer gl|forward|mobile]"
[[ "$PROJECT_NAME" =~ ^[A-Za-z0-9][A-Za-z0-9_-]*$ ]] || die "项目名只能是字母/数字/下划线/连字符，且以字母或数字开头：$PROJECT_NAME"
[[ -d "$SKELETON" ]] || die "找不到骨架目录：$SKELETON"

TARGET="$OUT_DIR/$PROJECT_NAME"
[[ -e "$TARGET" ]] && die "目标已存在，拒绝覆盖：$TARGET"

case "$RENDERER" in
  gl)      RM="gl_compatibility"; FEATURE="GL Compatibility" ;;
  forward) RM="forward_plus";     FEATURE="Forward Plus" ;;
  mobile)  RM="mobile";           FEATURE="Mobile" ;;
  *)       die "--renderer 只能是 gl | forward | mobile" ;;
esac

echo "▶ 生成项目：$TARGET"
echo "  渲染器：$RENDERER ($RM)"

# ---------- 1) 复制骨架 ----------
# 结构：$SKELETON/（GAME 内容）→ $TARGET/GAME/；$SCRIPT_DIR/SOURCE/ → $TARGET/SOURCE/
[[ -d "$SKELETON" ]] || die "找不到骨架目录：$SKELETON"
[[ -d "$SCRIPT_DIR/SOURCE" ]] || die "找不到源文件模板：$SCRIPT_DIR/SOURCE"

mkdir -p "$TARGET/GAME" "$TARGET/docs/devlog" "$TARGET/SOURCE"
cp -a "$SKELETON/." "$TARGET/GAME/"
rm -rf "$TARGET/GAME/docs"                    # 骨架里的空 docs 占位不需要
cp -a "$SCRIPT_DIR/SOURCE/." "$TARGET/SOURCE/"

# 工程级配置：骨架自带的 Godot 专用 .gitignore + 换行/编辑器统一配置
cp "$SKELETON/.gitignore"     "$TARGET/GAME/.gitignore"
cp "$SKELETON/.gitattributes" "$SKELETON/.editorconfig" "$TARGET/GAME/"

# 仓库根配置：比工程级更全（含本机私有目录、导出物、IDE）
cat > "$TARGET/.gitignore" <<'GITIGNORE_EOF'
# ============================================================
# 仓库级忽略规则（仓库根 = 项目根；GAME/ 是 Godot 工程）
# 原则：忽略"机器生成 / 可重新生成 / 本机私有"的东西；
#       源文件（含 .aseprite / .psd）一律入库——没版本控制 = 没备份。
# ============================================================

# ---------- AI 会话 / 记忆数据（本机私有，绝不入库）----------
.dsh-meow/
.dsh/

# ---------- Godot 引擎生成物 ----------
.godot/
/android/
*.translation

# ---------- Godot 导出产物（只忽略产物，不忽略配置）----------
# ⚠️ export_presets.cfg 必须【提交】——它记录 Web/Android 导出配置，
#    官方版本控制文档明确建议入库；忽略它会让换机后无法一键导出。
EXPORTS/
EXPORTS_*/
build/
dist/

# ---------- 签名密钥（绝不入库）----------
*.keystore
*.jks
*.pepk
release.keystore

# ---------- 注：*.uid 必须提交 ----------
# Godot 4.4+ 为脚本/资源生成 .uid（稳定资源标识），官方建议入库。
# 因此这里【有意不忽略】*.uid。

# ---------- 编辑器 / 系统垃圾 ----------
.DS_Store
Thumbs.db
desktop.ini
*~
*.orig
*.rej
*.bak
*.tmp
*.log

# ---------- IDE / 工具 ----------
.vscode/
.idea/
*.swp
*.swo

# ---------- 本机私有配置 ----------
*.local
.env
.env.*
!.env.example
GITIGNORE_EOF
cp "$SKELETON/.gitattributes" "$SKELETON/.editorconfig" "$TARGET/"

# ---------- 2) 替换工程配置占位符 ----------
GODOT_FILE="$TARGET/GAME/project.godot"
[[ -f "$GODOT_FILE" ]] || die "骨架缺少 project.godot"
sed -i "s/__PROJECT_NAME__/$PROJECT_NAME/g" "$GODOT_FILE"
sed -i "s/\"GL Compatibility\"/\"$FEATURE\"/" "$GODOT_FILE"
sed -i "s|renderer/rendering_method=\"gl_compatibility\"|renderer/rendering_method=\"$RM\"|" "$GODOT_FILE"
sed -i "s|renderer/rendering_method.mobile=\"gl_compatibility\"|renderer/rendering_method.mobile=\"$RM\"|" "$GODOT_FILE"

# ---------- 3) 文档骨架 ----------
if [[ -f "$INDEX_TEMPLATE" ]]; then
  sed -e "s/__PROJECT_NAME__/$PROJECT_NAME/g" \
      -e "s|__PROJECT_DIR__|$TARGET|g" \
      -e "s/__DATE__/$(date +%Y-%m-%d)/g" \
      "$INDEX_TEMPLATE" > "$TARGET/PROJECT_INDEX.md"
else
  echo "（提示）未找到 PROJECT_INDEX.template.md，跳过索引生成" >&2
fi

# 根 README（新项目自带结构说明，不用手写）
README_TEMPLATE="$SCRIPT_DIR/README.template.md"
if [[ -f "$README_TEMPLATE" ]]; then
  sed -e "s/__PROJECT_NAME__/$PROJECT_NAME/g" \
      -e "s/__DATE__/$(date +%Y-%m-%d)/g" \
      "$README_TEMPLATE" > "$TARGET/README.md"
else
  echo "（提示）未找到 README.template.md，跳过根 README 生成" >&2
fi

# 从 templates/docs/ 复制文档模板（若存在）
if [[ -d "$SCRIPT_DIR/docs" ]]; then
  cp -a "$SCRIPT_DIR/docs/." "$TARGET/docs/"
fi
[[ -f "$TARGET/docs/GDD.md" ]]     || echo "# $PROJECT_NAME — 游戏设计文档（GDD）" > "$TARGET/docs/GDD.md"
[[ -f "$TARGET/docs/ROADMAP.md" ]] || echo "# $PROJECT_NAME — 路线图（ROADMAP）" > "$TARGET/docs/ROADMAP.md"
mkdir -p "$TARGET/docs/devlog"
[[ -f "$TARGET/docs/devlog/TEMPLATE.md" ]] || cat > "$TARGET/docs/devlog/TEMPLATE.md" <<'DEVLOG_EOF'
# 开发日志 YYYY-MM-DD(-x)

> 状态：<!-- 进行中 / 收尾 / 里程碑达成 / 搁置 -->
> 每天任务结束时说 **"今天任务已结束"**，AI 读取本模板生成当日日志 `docs/devlog/YYYY-MM-DD.md`。

---

## 今日摘要

## 完成内容

## 决策与理由

## 踩坑 / 问题

## 文件变更

## 进度与下一步

## 阻塞 / 待决策

## 其他（素材 / 灵感 / 备忘）
DEVLOG_EOF

# 替换全部文档模板里的占位符（含 GDD / ROADMAP / 文件树模板）
TODAY="$(date +%Y-%m-%d)"
while IFS= read -r -d '' f; do
  sed -i -e "s/__PROJECT_NAME__/$PROJECT_NAME/g" \
         -e "s|__PROJECT_DIR__|$TARGET|g" \
         -e "s/__DATE__/$TODAY/g" "$f"
done < <(find "$TARGET/docs" -type f -name '*.md' -print0)

# ---------- 4) git init + 首次提交 ----------
cd "$TARGET"
if [[ ! -d .git ]]; then
  git init -q -b main
  git config --local core.quotepath false
  git config --local core.autocrlf false
  git config --local core.filemode false
  # 全局身份缺失时兜底，避免首次提交直接失败
  git config user.name  >/dev/null 2>&1 || git config --local user.name  "unknown"
  git config user.email >/dev/null 2>&1 || git config --local user.email "unknown@localhost"
  git add .
  git commit -q -m "chore: scaffold $PROJECT_NAME from godot-2d template

- 仓库根=项目根，GAME/ 为 Godot 工程，SOURCE/ 为美术源文件母版
- 目录骨架：assets/ scenes/ scripts/ DEV/（见 docs/PROJECT_TREE_TEMPLATE.md）"
  COMMITTED="yes"
else
  COMMITTED="no（已存在 .git，未改动）"
fi

# ---------- 5) 汇总 ----------
cat <<EOF

✅ 完成：$TARGET
   首次提交：$COMMITTED

下一步：
   1. Godot → Project Manager → Import → 选 $TARGET/GAME/project.godot
   2. 填 docs/GDD.md 的核心玩法（先设计，再写代码）
   3. 需要远端时：git remote add origin <url> && git push -u origin main
EOF
