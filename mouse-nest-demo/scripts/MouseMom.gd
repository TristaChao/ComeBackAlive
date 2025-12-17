extends Area2D

func can_interact() -> bool:
	return true

func interact():
	var dialog = get_tree().current_scene.get_node("UI/DialogueBox")
	dialog.open_dialog(
		"要聊聊什麼嗎？",
		["聊聊料理", "聊聊家裡", "聊聊外面"],
		_on_main_choice
	)

func _on_main_choice(index: int):
	var dialog = get_tree().current_scene.get_node("UI/DialogueBox")

	match index:
		0:
			dialog.open_dialog(
				"想知道哪一道？",
				["牛排", "烤紅蘿蔔", "返回"],
				_on_recipe_choice
			)
		1:
			dialog.open_dialog(
				"現在家裡還很簡陋呢。",
				["返回"],
				func(_i): dialog.close_dialog()
			)
		2:
			dialog.open_dialog(
				"外面很危險，小心貓咪。",
				["返回"],
				func(_i): dialog.close_dialog()
			)

func _on_recipe_choice(index: int):
	var dialog = get_tree().current_scene.get_node("UI/DialogueBox")

	match index:
		0:
			dialog.open_dialog(
				"把牛肉直接拿去烤台上烤熟就好了。",
				["返回"],
				func(_i): dialog.close_dialog()
			)
		1:
			dialog.open_dialog(
				"紅蘿蔔切好後烤一下會更好吃。",
				["返回"],
				func(_i): dialog.close_dialog()
			)
		2:
			interact()