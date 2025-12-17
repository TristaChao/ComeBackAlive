extends CharacterBody2D

@export var speed := 120

func _physics_process(delta):
	var dir := Vector2.ZERO
	if GameState.state != GameState.State.FREE_MOVE:
		return
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
		for area in $InteractionArea.get_overlapping_areas():
			if area.has_method("can_interact") and area.can_interact():
				area.interact()
				return
