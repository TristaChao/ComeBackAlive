extends CharacterBody2D

@export var speed := 120

func _physics_process(delta):
	var dir := Vector2.ZERO

	if Input.is_action_pressed("move_up"):
		dir.y -= 1
	if Input.is_action_pressed("move_down"):
		dir.y += 1
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_right"):
		dir.x += 1

	velocity = dir.normalized() * speed
	move_and_slide()
	
func _input(event):
	if event.is_action_pressed("interact"):
		print("嘗試開啟對話")
		if GameState.state != GameState.State.FREE_MOVE:
			return

		for area in $InteractionArea.get_overlapping_areas():
			if area.has_method("can_interact") and area.can_interact():
				open_mouse_mom_dialog()
				return

func open_mouse_mom_dialog():
	var dialog = get_tree().current_scene.get_node("UI/DialogueBox")
	dialog.open_dialog(
		"要聊聊什麼嗎？",
		["聊聊料理", "聊聊家裡", "聊聊外面"]
	)
