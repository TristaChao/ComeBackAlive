extends Control

@onready var label := $Panel/Label
@onready var option_nodes := $Panel/VBoxContainer.get_children()

var current_callback: Callable = Callable()
var selected_index := 0
var option_count := 0

func _ready():
	hide()
	set_process_unhandled_input(false)

func open_dialog(text: String, option_texts: Array, callback: Callable):
	GameState.state = GameState.State.DIALOG
	label.text = text
	current_callback = callback
	option_count = option_texts.size()
	selected_index = 0

	show()
	set_process_unhandled_input(true)

	for i in range(option_nodes.size()):
		if i < option_texts.size():
			option_nodes[i].text = option_texts[i]
			option_nodes[i].show()
		else:
			option_nodes[i].hide()

	_update_highlight()

func _unhandled_input(event):
	if GameState.state != GameState.State.DIALOG:
		return

	if event.is_action_pressed("ui_down"):
		selected_index = (selected_index + 1) % option_count
		_update_highlight()

	elif event.is_action_pressed("ui_up"):
		selected_index = (selected_index - 1 + option_count) % option_count
		_update_highlight()

	elif event.is_action_pressed("ui_accept"):
		if current_callback.is_valid():
			current_callback.call(selected_index)

	elif event.is_action_pressed("ui_cancel"):
		close_dialog()

func _update_highlight():
	for i in range(option_nodes.size()):
		if i == selected_index:
			option_nodes[i].add_theme_color_override("font_color", Color.YELLOW)
		else:
			option_nodes[i].add_theme_color_override("font_color", Color.WHITE)

func close_dialog():
	hide()
	set_process_unhandled_input(false)
	GameState.state = GameState.State.FREE_MOVE
	current_callback = Callable()
