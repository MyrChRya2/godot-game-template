@tool
extends SceneTree
## 工具：设置工程主场景并保存 project.godot
## 等价于编辑器菜单 Project → Project Settings → Application → Run → Main Scene
##
## 用法（不传参时用下方 DEFAULT_MAIN_SCENE）：
##   godot --headless --path <工程目录> --script res://tools/set_main_scene.gd -- res://scenes/MyScene.tscn
##
## 为什么要用它：工程没有 run/main_scene 时，编辑器里按 F5 会弹
## 「Error: Can't run project: no main scene defined in the project.」

const DEFAULT_MAIN_SCENE := "res://scenes/Main.tscn"

func _initialize() -> void:
	var target := DEFAULT_MAIN_SCENE
	var user_args := OS.get_cmdline_user_args()
	if user_args.size() > 0 and user_args[0] != "":
		target = user_args[0]

	var before := str(ProjectSettings.get_setting("application/run/main_scene", ""))
	print("[before] application/run/main_scene = ", before if before != "" else "(未设置)")

	if not ResourceLoader.exists(target):
		push_error("找不到场景：%s" % target)
		quit(1)
		return

	# 优先用 UID 引用（Godot 4.4+ 推荐写法，与场景文件头部的 uid 对应）
	var value := target
	var scene_uid := ResourceLoader.get_resource_uid(target)
	if scene_uid != ResourceUID.INVALID_ID:
		value = ResourceUID.id_to_text(scene_uid)
		if not value.begins_with("uid://"):
			value = "uid://" + value

	ProjectSettings.set_setting("application/run/main_scene", value)
	var err := ProjectSettings.save()
	if err != OK:
		push_error("保存 ProjectSettings 失败：%s" % err)
		quit(1)
		return

	print("[after]  application/run/main_scene = ", value)
	print("已保存 project.godot")
	quit(0)
