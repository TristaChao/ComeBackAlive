extends Area2D
class_name Warehouse

@onready var hint_label := $HintLabel
var player_near := false

func _ready():
	if hint_label:
		hint_label.visible = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_near = true
		if hint_label:
			hint_label.text = "(E) 開啟倉庫"
			hint_label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_near = false
		if hint_label:
			hint_label.visible = false

func can_interact() -> bool:
	return player_near

func interact(player: Player):
	if not player_near:
		return

	# 尋找 WarehouseScreen 實例並打開它
	# 我們假設 WarehouseScreen 是當前場景中名為 "UI" 的節點底下的子節點
	var ui_root = get_tree().current_scene.get_node_or_null("UI")
	if ui_root:
		var warehouse_screen = ui_root.get_node_or_null("WarehouseScreen")
		if warehouse_screen and warehouse_screen.has_method("open_warehouse"):
			warehouse_screen.open_warehouse()
		else:
			print("Error: 'WarehouseScreen' 節點未找到，或缺少 'open_warehouse' 方法。")
	else:
		print("Error: 當前場景中未找到 'UI' 根節點。")

	if hint_label:
		hint_label.visible = false # 打開 UI 後隱藏提示文字
