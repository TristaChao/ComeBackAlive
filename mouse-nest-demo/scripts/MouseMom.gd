extends Area2D

@onready var talk_hint := $TalkHint

func _ready():
	talk_hint.visible = false

# --- 提示文字的顯示/隱藏邏輯 ---

# 當有物體進入此區域時 (body_entered Signal 連接此函式)
func _on_body_entered(body):
	print("一個物體進入了鼠媽的範圍")
	# 為了更穩定，建議您到 Player 節點的 Inspector -> Node -> Groups，為 Player 新增一個 "player" 群組
	if body.is_in_group("player"):
		print("而且這個物體是玩家！")
		talk_hint.visible = true

# 當有物體離開此區域時 (body_exited Signal 連接此函式)
func _on_body_exited(body):
	if body.is_in_group("player"):
		talk_hint.visible = false

# --- 互動與對話邏輯 ---

func can_interact() -> bool:
	return true

func interact():
	# 當開始互動(打開對話框)時，隱藏提示文字
	talk_hint.visible = false
	
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
				func(_i): interact() # 返回時重新打開主選單
			)
		2:
			dialog.open_dialog(
				"外面很危險，小心貓咪。",
				["返回"],
				func(_i): interact() # 返回時重新打開主選單
			)

func _on_recipe_choice(index: int):
	var dialog = get_tree().current_scene.get_node("UI/DialogueBox")

	match index:
		0:
			dialog.open_dialog(
				"把牛肉直接拿去烤台上烤熟就好了。",
				["返回"],
				func(_i): interact() # 返回時重新打開主-選單
			)
		1:
			dialog.open_dialog(
				"紅蘿蔔切好後烤一下會更好吃。",
				["返回"],
				func(_i): interact() # 返回時重新打開主選單
			)
		2:
			interact() # 在食譜選單中選 "返回"
