class_name PouchScreen
extends Control

@onready var grid: GridContainer = $Panel/GridContainer
var slots: Array = []

var selected_index: int = 0

func _ready():
	hide()
	slots = grid.get_children()

func open_pouch():
	GameState.state = GameState.State.POUCH_OPEN
	selected_index = 0
	refresh()
	show()
	update_selection()

func close_pouch():
	hide()
	GameState.state = GameState.State.FREE_MOVE

func refresh():
	for i in range(slots.size()):
		if i < GameState.pouch.size():
			slots[i].texture = GameState.pouch[i].texture
			slots[i].modulate = Color.WHITE
		else:
			slots[i].texture = null
			slots[i].modulate = Color(1, 1, 1, 0.2)

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

	selected_index = clamp(
		selected_index + dir,
		0,
		GameState.pouch.size() - 1
	)
	update_selection()

func update_selection():
	for i in range(slots.size()):
		if i == selected_index:
			slots[i].modulate = Color(1, 1, 0.6)
		else:
			slots[i].modulate = Color.WHITE

func confirm_selection():
	if GameState.pouch.is_empty():
		return

	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	if player.has_item():
		return

	var item = GameState.pouch[selected_index]
	GameState.pouch.remove_at(selected_index)
	player.pick_item(item)
	close_pouch()
