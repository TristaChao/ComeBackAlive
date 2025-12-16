extends Area2D

@onready var hint_label := $Label
var player_near := false

func _ready():
	hint_label.visible = false

func _on_body_entered(body):
	if body.name == "Player":
		player_near = true
		hint_label.visible = true

func _on_body_exited(body):
	if body.name == "Player":
		player_near = false
		hint_label.visible = false

func can_interact() -> bool:
	return player_near
