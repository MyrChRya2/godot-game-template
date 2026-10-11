@tool
extends SceneTree
## 工具：注入本作的标准输入动作（Input Map）
## 对应编辑器菜单 Project → Project Settings → Input Map
##
## 用法：
##   godot --headless --path <工程目录> --script res://tools/setup_input_map.gd
##   godot --headless --path <工程目录> --script res://tools/setup_input_map.gd -- flap jump
##
## 为什么要有这个工具：
##   · 手写 project.godot 里 [input] 段的 InputEvent 序列化格式（Object(...)）极易出错
##   · 只调 InputMap.add_action() 只在运行时生效，【不会写回 project.godot】
##     → 必须同时写 ProjectSettings 的 "input/<动作名>" 再 save()
##   · 走引擎 API 生成的格式与编辑器完全一致，新项目/模板可直接复用
##
## 本作需要：
##   flap —— 桌面：鼠标左键 + 空格 ；移动：屏幕轻触

const DEFAULT_ACTIONS := ["flap"]

func _initialize() -> void:
	var actions := DEFAULT_ACTIONS
	var args := OS.get_cmdline_user_args()
	if args.size() > 0:
		actions = []
		for a in args:
			actions.append(str(a))

	for action_name in actions:
		var events: Array[InputEvent] = []

		# 桌面：鼠标左键
		var mb := InputEventMouseButton.new()
		mb.button_index = MOUSE_BUTTON_LEFT
		events.append(mb)

		# 桌面：空格键（用 physical_keycode，不受键盘布局影响）
		var kb := InputEventKey.new()
		kb.physical_keycode = KEY_SPACE
		events.append(kb)

		# 移动：屏幕轻触（全屏任意处）
		var st := InputEventScreenTouch.new()
		events.append(st)

		# 写入 ProjectSettings（这才是会被保存进 project.godot 的地方），并同步运行时的 InputMap
		ProjectSettings.set_setting("input/" + action_name, {
			"deadzone": 0.5,
			"events": events,
		})
		InputMap.add_action(action_name, 0.5)
		for e in events:
			InputMap.action_add_event(action_name, e)

		print("[OK] 动作 '", action_name, "' 事件数 = ", events.size(),
			"  (鼠标左键 / 空格 / 屏幕轻触)")

	var err := ProjectSettings.save()
	if err != OK:
		push_error("保存失败：%s" % err)
		quit(1)
		return
	print("已保存 project.godot")
	quit(0)
