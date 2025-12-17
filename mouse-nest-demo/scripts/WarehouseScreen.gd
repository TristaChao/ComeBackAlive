class_name WarehouseScreen
extends Control

# --- UI References ---
@onready var pouch_grid: GridContainer = $HBoxContainer/PouchPanel/PouchContent/PouchGrid
@onready var warehouse_grid: GridContainer = $HBoxContainer/WarehousePanel/WarehouseContent/WarehouseGrid
@onready var pouch_panel_root: PanelContainer = $HBoxContainer/PouchPanel
@onready var warehouse_panel_root: PanelContainer = $HBoxContainer/WarehousePanel

# --- Resources ---
const POUCH_SLOT_SCENE = preload("res://UI/PouchSlot.tscn")

# --- Internal State ---
var is_pouch_focused: bool = true
var pouch_selected_idx: int = 0
var warehouse_selected_idx: int = 0

func _ready():
	hide()

func open_warehouse():
	GameState.state = GameState.State.WAREHOUSE_OPEN
	is_pouch_focused = true
	pouch_selected_idx = 0
	warehouse_selected_idx = 0
	refresh_grids()
	show()
	update_focus_visuals()
	update_selection_visuals()

func close_warehouse():
	GameState.state = GameState.State.FREE_MOVE
	hide()

func refresh_grids():
	# Clear and populate Pouch Grid
	for child in pouch_grid.get_children():
		child.queue_free()
	for i in range(GameState.POUCH_CAPACITY):
		var slot = POUCH_SLOT_SCENE.instantiate()
		pouch_grid.add_child(slot)
		if i < GameState.pouch.size():
			slot.get_node("ItemIcon").texture = GameState.pouch[i].texture
		else:
			slot.get_node("ItemIcon").modulate = Color(1, 1, 1, 0.2)

	# Clear and populate Warehouse Grid
	for child in warehouse_grid.get_children():
		child.queue_free()
	for i in range(GameState.WAREHOUSE_CAPACITY):
		var slot = POUCH_SLOT_SCENE.instantiate()
		warehouse_grid.add_child(slot)
		if i < GameState.warehouse.size():
			slot.get_node("ItemIcon").texture = GameState.warehouse[i].texture
		else:
			slot.get_node("ItemIcon").modulate = Color(1, 1, 1, 0.2)

# --- NEW: Logic for visuals and input handling ---

func _input(event):
	if GameState.state != GameState.State.WAREHOUSE_OPEN:
		return

	if event.is_action_pressed("ui_cancel"):
		close_warehouse()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("ui_focus_next"): # Default: Tab key
		is_pouch_focused = not is_pouch_focused
		update_focus_visuals()
		update_selection_visuals() # Also update selection when focus changes
		get_viewport().set_input_as_handled()
		return

	var direction := Vector2.ZERO
	if event.is_action_pressed("ui_right"):
		direction.x = 1
	elif event.is_action_pressed("ui_left"):
		direction.x = -1
	elif event.is_action_pressed("ui_down"):
		direction.y = 1
	elif event.is_action_pressed("ui_up"):
		direction.y = -1
	
	if direction != Vector2.ZERO:
		move_selection(direction)
		get_viewport().set_input_as_handled()
		return

func move_selection(direction: Vector2):
	if is_pouch_focused:
		if GameState.pouch.is_empty(): return
		var grid_columns = pouch_grid.columns
		pouch_selected_idx += direction.x + (direction.y * grid_columns)
		pouch_selected_idx = clampi(pouch_selected_idx, 0, GameState.pouch.size() - 1)
	else:
		if GameState.warehouse.is_empty(): return
		var grid_columns = warehouse_grid.columns
		warehouse_selected_idx += direction.x + (direction.y * grid_columns)
		warehouse_selected_idx = clampi(warehouse_selected_idx, 0, GameState.warehouse.size() - 1)
	
	update_selection_visuals()

func update_focus_visuals():
	if is_pouch_focused:
		pouch_panel_root.modulate = Color.WHITE
		warehouse_panel_root.modulate = Color(1, 1, 1, 0.5)
	else:
		pouch_panel_root.modulate = Color(1, 1, 1, 0.5)
		warehouse_panel_root.modulate = Color.WHITE

func update_selection_visuals():
	# Update pouch grid
	for i in range(pouch_grid.get_child_count()):
		var slot: PanelContainer = pouch_grid.get_child(i)
		if is_pouch_focused and i == pouch_selected_idx and i < GameState.pouch.size():
			slot.pivot_offset = slot.size / 2.0
			slot.scale = Vector2(1.2, 1.2)
		else:
			slot.pivot_offset = Vector2.ZERO
			slot.scale = Vector2.ONE
	
	# Update warehouse grid
	for i in range(warehouse_grid.get_child_count()):
		var slot: PanelContainer = warehouse_grid.get_child(i)
		if not is_pouch_focused and i == warehouse_selected_idx and i < GameState.warehouse.size():
			slot.pivot_offset = slot.size / 2.0
			slot.scale = Vector2(1.2, 1.2)
		else:
			slot.pivot_offset = Vector2.ZERO
			slot.scale = Vector2.ONE