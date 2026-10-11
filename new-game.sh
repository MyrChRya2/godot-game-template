#!/usr/bin/env bash
# ============================================================
# new-game.sh — 从骨架生成一个新游戏项目（仓库根 = 项目根）
#
# 用法：
#   ./new-game.sh <项目名> [--dir <输出目录>] [--renderer gl|forward|mobile]
#
# 生成内容：
#   <输出目录>/<项目名>/
#   ├── PROJECT_INDEX.md   # 从 templates/PROJECT_INDEX.template.md 生成并替换占位符
#   ├── docs/              # GDD / ROADMAP / 文件树模板 / devlog 骨架
#   ├── GAME/              # Godot 工程（assets/scenes/scripts/DEV）
#   ├── SORCE/             # 美术/音频源文件母版
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
mkdir -p "$TARGET"
cp -a "$SKELETON/." "$TARGET/GAME/"
mkdir -p "$TARGET/docs/devlog" "$TARGET/SORCE"
cp -a "$TARGET/GAME/SORCE/." "$TARGET/SORCE/" 2>/dev/null || true
rm -rf "$TARGET/GAME/SORCE" "$TARGET/GAME/docs"
cp "$TARGET/GAME/.gitignore"  "$TARGET/.gitignore"
cp "$TARGET/GAME/.gitattributes" "$TARGET/.gitattributes"
cp "$TARGET/GAME/.editorconfig"  "$TARGET/.editorconfig"

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

- 仓库根=项目根，GAME/ 为 Godot 工程，SORCE/ 为美术源文件母版
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
