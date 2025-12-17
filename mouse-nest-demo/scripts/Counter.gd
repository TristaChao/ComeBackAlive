extends Area2D

@onready var hint_label := $HintLabel
var player_in_area: Player = null

func _ready():
	hint_label.visible = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = body
		update_hint()
		hint_label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = null
		hint_label.visible = false

func update_hint():
	if player_in_area:
		if player_in_area.has_item():
			hint_label.text = "(E) 放下"
		else:
			hint_label.text = "(E) 拿取(牛肉)"

func interact(player):
	# 先只做 print 來測試
	if player.has_item():
		print("玩家嘗試放下物品")
	else:
		print("玩家嘗試拿取牛肉")
