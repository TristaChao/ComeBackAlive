class_name PouchScreen
extends Control

@onready var grid: GridContainer = $Panel/GridContainer
var slots: Array[PanelContainer] = [] # The slots are now PanelContainers

var selected_index: int = 0

func _ready():
	hide()
	# 清空 slots 陣列，確保它是空的
	slots.clear()
	# 遍歷 GridContainer 的所有子節點
	for child in grid.get_children():
		# 檢查每個子節點是否真的是 PanelContainer 類型
		if child is PanelContainer:
			# 如果是，就將它安全地添加到 slots 陣列中
			slots.append(child as PanelContainer)
		else:
			# 如果不是，就發出一個錯誤，表示有意外的節點類型
			push_error("PouchScreen: GridContainer 的子節點不是 PanelContainer 類型！發現了: " + child.name)

func open_pouch():
	if not is_visible():
		GameState.state = GameState.State.POUCH_OPEN
		selected_index = 0
		show()
		refresh() # Refresh first, then update selection
		update_selection()

func close_pouch():
	hide()
	GameState.state = GameState.State.FREE_MOVE

func refresh():
	for i in range(slots.size()):
		var slot_node: PanelContainer = slots[i]
		var icon_node: TextureRect = slot_node.get_node("ItemIcon")
		
		if i < GameState.pouch.size():
			var item_resource = GameState.pouch[i]
			# Assuming ItemData has a 'texture' property which is a Texture2D
			if item_resource and item_resource.texture:
				icon_node.texture = item_resource.texture
			icon_node.modulate = Color.WHITE # Filled slots are white
		else:
			icon_node.texture = null
			icon_node.modulate = Color(1, 1, 1, 0.2) # Empty slots are transparent

func _input(event):
	if GameState.state != GameState.State.POUCH_OPEN:
		return

	if event.is_action_pressed("ui_right"):
		move_selection(1)
	elif event.is_action_pressed("ui_left"):
		move_selection(-1)
	elif event.is_action_pressed("interact"):
		confirm_selection()

func move_selection(dir: int):
	if GameState.pouch.is_empty():
		return

	# We use max() to handle the case where pouch size is 1.
	var last_index = max(0, GameState.pouch.size() - 1)
	selected_index = clampi(selected_index + dir, 0, last_index)
	update_selection()

func update_selection():
	for i in range(slots.size()):
		var slot_node: PanelContainer = slots[i]
		
		# We check if the current slot is the selected one AND it represents a valid item
		if i == selected_index and i < GameState.pouch.size():
			# **THE FIX**: Set pivot to the center of the control right before scaling up.
			# This makes it scale from its center, staying aligned in the GridContainer.
			slot_node.pivot_offset = slot_node.size / 2.0
			slot_node.scale = Vector2(1.2, 1.2)
		else:
			# **THE FIX**: Reset pivot and scale for all other slots.
			# This is important for deselected slots and empty slots.
			slot_node.pivot_offset = Vector2.ZERO
			slot_node.scale = Vector2.ONE


func confirm_selection():
	if GameState.pouch.is_empty():
		return

	var player = get_tree().get_first_node_in_group("player")
	if player == null or player.has_item():
		return

	if selected_index >= GameState.pouch.size():
		return

	var item = GameState.pouch.pop_at(selected_index)
	if item:
		# We need to find the Player node and call its pick_item method
		# This assumes the player script has a pick_item(item_data) function
		player.pick_item(item)

	if GameState.pouch.is_empty():
		close_pouch()
	else:
		# After removing an item, the selection might be out of bounds. Clamp it.
		selected_index = clampi(selected_index, 0, GameState.pouch.size() - 1)
		refresh()
		update_selection()
