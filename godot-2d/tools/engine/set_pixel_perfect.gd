@tool
extends SceneTree
## 工具：一键设置"像素完美"渲染地基（像素风项目的地基设置）
## 对应编辑器菜单 Project → Project Settings → 下的 Rendering/Textures 与 Display/Window
##
## 用法（不传参用下方默认值）：
##   godot --headless --path <工程目录> --script res://tools/engine/set_pixel_perfect.gd
##   godot --headless --path <工程目录> --script res://tools/engine/set_pixel_perfect.gd -- 320 180
##   godot --headless --path <工程目录> --script res://tools/engine/set_pixel_perfect.gd -- 320 180 keep
##
## ⚠️ 枚举取值（引擎权威定义，勿与 CanvasItem 的枚举混淆）：
##   本设置 hint_string = "Nearest,Linear,Linear Mipmap,Nearest Mipmap"，默认 1
##   → 0=Nearest  1=Linear(默认)  2=Linear Mipmap  3=Nearest Mipmap
##   注意 CanvasItem.TEXTURE_FILTER_* 是另一套枚举（0=PARENT_NODE,1=NEAREST,2=LINEAR），
##   两者不能混用比对——这正是容易踩的坑。
##
## 为什么要有这个工具（实测依据）：
##   · 纹理过滤默认是 Linear(1)，像素画会被拉糊；必须改 Nearest(0)
##   · 视口默认 1152x648，像素风需要小的基础画布
##   · **aspect 决定"窗口比例变了会怎样"**（2026-10-12 实测教训）：
##       expand      —— 视口按需扩展短轴填满窗口（实测 800x450→320x320、64x64→320x320）：
##                      **无黑边，但可见区域随窗口比例变化 → 画面穿帮**（能看到设计外的范围）
##       keep        —— 保持基础比例、多余部分补黑边：**逻辑视口恒为 vw x vh**，
##                      任何窗口比例下看到的画面完全一致（像素风游戏的常规选择）
##       keep_height —— 固定高度、宽度随窗口扩展（无黑边；横版跑酷常用，但横向可见范围会变）
##   · integer 缩放保证像素均匀；若某机型黑边过粗，把 scale_mode 改回 fractional 即可

const DEFAULT_VW := 320
const DEFAULT_VH := 180
const DEFAULT_ASPECT := "keep"      # 详见文件头：expand 会让可见区域随窗口比例变化（穿帮）

func _initialize() -> void:
	var vw := DEFAULT_VW
	var vh := DEFAULT_VH
	var aspect := DEFAULT_ASPECT
	var args := OS.get_cmdline_user_args()
	if args.size() >= 2:
		vw = int(args[0])
		vh = int(args[1])
	if args.size() >= 3:
		aspect = String(args[2])

	var before_filter: int = ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter", 1)
	var before_vw: int = ProjectSettings.get_setting("display/window/size/viewport_width", 0)
	var before_vh: int = ProjectSettings.get_setting("display/window/size/viewport_height", 0)
	print("[before] 纹理过滤=", before_filter, "(1=Linear 会糊)  视口=", before_vw, "x", before_vh)

	# 1) 纹理过滤 -> Nearest（0）
	ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", 0)

	# 2) 基础视口尺寸（像素画布）
	ProjectSettings.set_setting("display/window/size/viewport_width", vw)
	ProjectSettings.set_setting("display/window/size/viewport_height", vh)

	# 3) 拉伸：canvas_items + aspect（keep=比例固定、补黑边；expand 会随窗口比例变可见区域）+ integer
	ProjectSettings.set_setting("display/window/stretch/mode", "canvas_items")
	ProjectSettings.set_setting("display/window/stretch/aspect", aspect)
	ProjectSettings.set_setting("display/window/stretch/scale_mode", "integer")

	# 4) 横屏（移动端）
	ProjectSettings.set_setting("display/window/handheld/orientation", 1)  # 1 = landscape

	var err := ProjectSettings.save()
	if err != OK:
		push_error("保存失败：%s" % err)
		quit(1)
		return

	print("[after]  纹理过滤=", ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter", -1),
		"(0=Nearest)  视口=", ProjectSettings.get_setting("display/window/size/viewport_width", 0),
		"x", ProjectSettings.get_setting("display/window/size/viewport_height", 0),
		"  拉伸=", ProjectSettings.get_setting("display/window/stretch/mode", "?"),
		"/", ProjectSettings.get_setting("display/window/stretch/aspect", "?"),
		"/", ProjectSettings.get_setting("display/window/stretch/scale_mode", "?"),
		"  方向=", ProjectSettings.get_setting("display/window/handheld/orientation", -1), "(1=横屏)")
	print("已保存 project.godot")
	quit(0)
