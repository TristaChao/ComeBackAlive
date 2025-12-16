extends Control

@onready var text_label := $Panel/Label
@onready var option_box := $Panel/VBoxContainer
@onready var options := option_box.get_children()

var selected := 0

func open_dialog(text: String, option_texts: Array):
	visible = true
	GameState.state = GameState.State.DIALOG

	text_label.text = text

	for i in range(options.size()):
		if i < option_texts.size():
			options[i].text = option_texts[i]
			options[i].visible = true
		else:
			options[i].visible = false

	selected = 0
	update_selection()

func close_dialog():
	visible = false
	GameState.state = GameState.State.FREE_MOVE

func update_selection():
	for i in range(options.size()):
		options[i].modulate = Color.WHITE
	options[selected].modulate = Color.YELLOW

func _input(event):
	if not visible:
		return

	if event.is_action_pressed("ui_down"):
		selected = (selected + 1) % options.size()
		update_selection()

	elif event.is_action_pressed("ui_up"):
		selected = (selected - 1 + options.size()) % options.size()
		update_selection()

	elif event.is_action_pressed("ui_accept"):
		_on_option_selected(selected)

	elif event.is_action_pressed("ui_cancel"):
		close_dialog()

func _on_option_selected(index):
	match index:
		0:
			text_label.text = "料理可是生存的關鍵喔。"
		1:
			text_label.text = "家裡還能再擴建。"
		2:
			text_label.text = "外面很危險，小心點。"
