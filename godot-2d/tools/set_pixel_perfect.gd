@tool
extends SceneTree
## 工具：一键设置"像素完美"渲染地基（像素风项目的地基设置）
## 对应编辑器菜单 Project → Project Settings → 下的 Rendering/Textures 与 Display/Window
##
## 用法（不传参用下方默认值）：
##   godot --headless --path <工程目录> --script res://tools/set_pixel_perfect.gd
##   godot --headless --path <工程目录> --script res://tools/set_pixel_perfect.gd -- 320 180
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
##   · expand 模式下视口按需扩展短轴，不会产生黑边（实测 800x450 窗口 → 视口 320x320）
##   · integer 缩放保证像素均匀；若某机型出现黑边，把 scale_mode 改回 fractional 即可

const DEFAULT_VW := 320
const DEFAULT_VH := 180

func _initialize() -> void:
	var vw := DEFAULT_VW
	var vh := DEFAULT_VH
	var args := OS.get_cmdline_user_args()
	if args.size() >= 2:
		vw = int(args[0])
		vh = int(args[1])

	var before_filter: int = ProjectSettings.get_setting("rendering/textures/canvas_textures/default_texture_filter", 1)
	var before_vw: int = ProjectSettings.get_setting("display/window/size/viewport_width", 0)
	var before_vh: int = ProjectSettings.get_setting("display/window/size/viewport_height", 0)
	print("[before] 纹理过滤=", before_filter, "(1=Linear 会糊)  视口=", before_vw, "x", before_vh)

	# 1) 纹理过滤 -> Nearest（0）
	ProjectSettings.set_setting("rendering/textures/canvas_textures/default_texture_filter", 0)

	# 2) 基础视口尺寸（像素画布）
	ProjectSettings.set_setting("display/window/size/viewport_width", vw)
	ProjectSettings.set_setting("display/window/size/viewport_height", vh)

	# 3) 拉伸：canvas_items + expand（按需扩展短轴，无黑边）+ integer 缩放（像素均匀）
	ProjectSettings.set_setting("display/window/stretch/mode", "canvas_items")
	ProjectSettings.set_setting("display/window/stretch/aspect", "expand")
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
