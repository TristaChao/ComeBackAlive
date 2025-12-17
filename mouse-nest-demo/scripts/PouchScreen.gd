class_name PouchScreen
extends Control

@onready var grid: GridContainer = $Panel/GridContainer
var slots: Array = []

var selected_index: int = 0

func _ready():
	hide()
	slots = grid.get_children()

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
		var slot_node: TextureRect = slots[i]
		slot_node.scale = Vector2.ONE # Reset scale
		# Center the pivot for scaling, assuming slots are TextureRects
		slot_node.pivot_offset = slot_node.size / 2.0
		
		if i < GameState.pouch.size():
			slot_node.texture = GameState.pouch[i].texture
			slot_node.modulate = Color.WHITE # Filled slots are white
		else:
			slot_node.texture = null
			slot_node.modulate = Color(1, 1, 1, 0.2) # Empty slots are transparent

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

	selected_index = clampi(
		selected_index + dir,
		0,
		GameState.pouch.size() - 1
	)
	update_selection()

func update_selection():
	for i in range(slots.size()):
		var slot_node: TextureRect = slots[i]
		if i == selected_index and i < GameState.pouch.size():
			slot_node.scale = Vector2(1.2, 1.2) # Scale up selected
		else:
			slot_node.scale = Vector2.ONE # Normal scale for others
		
		# Also, restore colors in case they were changed
		if i < GameState.pouch.size():
			slot_node.modulate = Color.WHITE
		else:
			slot_node.modulate = Color(1, 1, 1, 0.2)


func confirm_selection():
	if GameState.pouch.is_empty():
		return

	var player = get_tree().get_first_node_in_group("player")
	if player == null or player.has_item():
		return

	# Check if selected_index is valid before trying to access it
	if selected_index >= GameState.pouch.size():
		return

	var item = GameState.pouch.pop_at(selected_index)
	if item:
		player.pick_item(item)

	# After taking an item, re-clamp the index and refresh the UI
	if GameState.pouch.is_empty():
		close_pouch()
	else:
		selected_index = clampi(selected_index, 0, GameState.pouch.size() - 1)
		refresh()
		update_selection()
