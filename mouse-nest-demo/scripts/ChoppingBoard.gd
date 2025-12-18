extends Area2D
class_name ChoppingBoard

# --- Node References ---
@onready var hint_label: Label = $HintLabel
@onready var item_sprite: Sprite2D = $ItemSprite
@onready var chop_timer: Timer = $ChopTimer
@onready var progress_bar: ProgressBar = $ProgressBar

# --- State ---
var item_on_board: ItemData = null
var player_in_area: Player = null
var is_chopping: bool = false

func _ready() -> void:
	hint_label.hide()
	progress_bar.hide()
	item_sprite.hide()

func _process(delta: float) -> void:
	# This function can access the class-level variable 'is_chopping'
	if is_chopping:
		progress_bar.value = (1.0 - chop_timer.get_time_left() / chop_timer.wait_time) * 100

func can_interact() -> bool:
	if is_chopping:
		return false
	return player_in_area != null

func interact(player: Player) -> void:
	if not can_interact():
		return

	# Case 1: Board has a finished item, player is empty-handed. -> Player takes item.
	if item_on_board != null and not player.has_item():
		player.pick_item(item_on_board)
		item_on_board = null
		item_sprite.hide()
		update_hint_text()
		
	# Case 2: Board is empty, player is holding a choppable item. -> Player places item and starts chopping.
	elif item_on_board == null and player.has_item():
		var held_item = player.held_item
		# Check both item ID and its cook_state.
		if ItemDatabase.CHOP_RECIPES.has(held_item.id) and held_item.cook_state == ItemData.CookState.RAW:
			item_on_board = player.drop_item()
			item_sprite.texture = item_on_board.texture
			item_sprite.show()
			start_chopping()
		else:
			print("This item '%s' cannot be chopped in its current state." % held_item.id)

func start_chopping() -> void:
	is_chopping = true
	progress_bar.show()
	chop_timer.start()
	update_hint_text()

func _on_chop_timer_timeout() -> void:
	is_chopping = false
	progress_bar.hide()

	if item_on_board == null:
		return

	var original_id = item_on_board.id
	if ItemDatabase.CHOP_RECIPES.has(original_id):
		var new_item_id = ItemDatabase.CHOP_RECIPES[original_id]
		
		var chopped_item = ItemDatabase.create_item(new_item_id)
		
		if chopped_item:
			item_on_board = chopped_item
			item_sprite.texture = chopped_item.texture
			print("Chopping complete! New item: %s" % new_item_id)
	
	update_hint_text()

# --- Body Enter/Exit for Hint Label ---

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = body as Player
		update_hint_text()
		hint_label.show()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = null
		hint_label.hide()

func update_hint_text() -> void:
	if not player_in_area:
		return

	if is_chopping:
		hint_label.text = "切菜中..."
		hint_label.show()
		return
		
	var text_to_show = ""
	if item_on_board == null and player_in_area.has_item():
		var held_item = player_in_area.held_item
		if ItemDatabase.CHOP_RECIPES.has(held_item.id) and held_item.cook_state == ItemData.CookState.RAW:
			text_to_show = "(E) 放置"
		else:
			text_to_show = "(無法切)"
	elif item_on_board != null and not player_in_area.has_item():
		text_to_show = "(E) 拿取"
	else:
		text_to_show = ""

	hint_label.text = text_to_show
	hint_label.visible = (text_to_show != "")
