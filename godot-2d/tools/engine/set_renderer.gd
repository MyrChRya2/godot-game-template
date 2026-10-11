@tool
extends SceneTree
## 工具：切换渲染器并保存 project.godot
## 等价于编辑器菜单 Project → Project Settings → Rendering → Renderer → Rendering Method
##
## 用法：
##   godot --headless --path <工程目录> --script res://tools/set_renderer.gd -- gl
##   （gl = Compatibility 2D/低端友好 | forward = Forward+ 3D 高端 | mobile = Mobile）

const METHODS := {
	"forward": {"method": "forward_plus", "feature": "Forward Plus"},
	"mobile": {"method": "mobile", "feature": "Mobile"},
	"gl": {"method": "gl_compatibility", "feature": "GL Compatibility"},
}

func _initialize() -> void:
	var key := "gl"
	var args := OS.get_cmdline_user_args()
	if args.size() > 0 and args[0] != "":
		key = args[0]
	if not METHODS.has(key):
		push_error("未知渲染器：%s（可用：gl / forward / mobile）" % key)
		quit(1)
		return

	var method: String = METHODS[key]["method"]
	var feature: String = METHODS[key]["feature"]
	var before := str(ProjectSettings.get_setting("rendering/renderer/rendering_method", ""))
	print("[before] rendering_method = ", before if before != "" else "(未设置)")

	ProjectSettings.set_setting("rendering/renderer/rendering_method", method)
	ProjectSettings.set_setting("rendering/renderer/rendering_method.mobile", method)

	# config/features 是引擎在创建工程时写入的，切换渲染器时必须同步，否则引擎会报特性不匹配
	var feats: PackedStringArray = ProjectSettings.get_setting("application/config/features", PackedStringArray())
	var out := PackedStringArray()
	for f in feats:
		if f not in ["Forward Plus", "Mobile", "GL Compatibility"]:
			out.append(f)
	out.append(feature)
	ProjectSettings.set_setting("application/config/features", out)

	# 兼容性渲染器不需要 D3D12/Vulkan 的驱动指定，清掉避免误导
	for k in ["rendering/rendering_device/driver.windows", "rendering/rendering_device/driver"]:
		if ProjectSettings.has_setting(k):
			ProjectSettings.set_setting(k, null)

	var err := ProjectSettings.save()
	if err != OK:
		push_error("保存失败：%s" % err)
		quit(1)
		return
	print("[after]  rendering_method = ", method, "  features = ", out)
	print("已保存 project.godot")
	quit(0)
