extends Area2D
class_name Grill

# --- Node References ---
@onready var hint_label: Label = $HintLabel
@onready var progress_bar: ProgressBar = $ProgressBar
@onready var cook_timer: Timer = $Timer
@onready var item_sprite: Sprite2D = $ItemSprite

# --- State ---
var player_in_area: Player = null
var item_on_grill: ItemData = null
var is_cooking: bool = false
var active_recipe: Dictionary = {}

# --- Configuration ---
const BURN_TIME = 2.0 # Time from cooked to burnt

func _ready():
	hint_label.hide()
	progress_bar.hide()
	item_sprite.hide()
	cook_timer.one_shot = true

func _process(delta: float):
	if is_cooking:
		progress_bar.value = (1.0 - cook_timer.time_left / cook_timer.wait_time) * 100

func can_interact() -> bool:
	# Don't allow taking item while it's transitioning (e.g. from raw to cooked)
	if is_cooking and item_on_grill.cook_state == ItemData.CookState.RAW:
		return false
	return player_in_area != null

func interact(player: Player):
	if not can_interact():
		return

	# Case 1: Player takes item from grill
	if not player.has_item() and item_on_grill != null:
		player.pick_item(item_on_grill)
		item_on_grill = null
		stop_cooking()
		update_item_visual()
	
	# Case 2: Player places a valid grillable item on the grill
	elif player.has_item() and item_on_grill == null:
		var held_item = player.held_item
		if ItemDatabase.GRILL_RECIPES.has(held_item.id):
			active_recipe = ItemDatabase.GRILL_RECIPES[held_item.id]
			item_on_grill = player.drop_item()
			start_cooking()
			update_item_visual()
	
	update_hint()

func start_cooking():
	is_cooking = true
	progress_bar.show()
	cook_timer.wait_time = active_recipe.time
	cook_timer.start()
	update_hint()

func stop_cooking():
	is_cooking = false
	active_recipe = {}
	cook_timer.stop()
	progress_bar.hide()
	update_hint()

func _on_timer_timeout():
	if item_on_grill == null:
		stop_cooking()
		return

	if item_on_grill.cook_state == ItemData.CookState.RAW:
		# RAW -> COOKED transition complete
		var result_id = active_recipe.result
		var new_item = ItemDatabase.create_item(result_id)
		new_item.cook_state = ItemData.CookState.COOKED
		item_on_grill = new_item
		
		print("Grilling complete! Item is now COOKED.")
		
		# Start next timer for burning
		cook_timer.wait_time = BURN_TIME
		cook_timer.start()
		
	elif item_on_grill.cook_state == ItemData.CookState.COOKED:
		# COOKED -> BURNT transition complete
		var burnt_result_id = active_recipe.burnt_result
		var new_item = ItemDatabase.create_item(burnt_result_id)
		new_item.cook_state = ItemData.CookState.BURNT
		item_on_grill = new_item
		
		print("Item is BURNT!")
		stop_cooking()

	update_item_visual()
	update_hint()

# --- Visual and Hint Updates ---

func update_item_visual():
	if item_on_grill != null:
		item_sprite.texture = item_on_grill.texture
		item_sprite.show()
	else:
		item_sprite.hide()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = body
		update_hint()
		hint_label.show()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = null
		hint_label.hide()

func update_hint():
	if not player_in_area:
		hint_label.hide()
		return

	var text_to_show = ""
	if is_cooking and item_on_grill.cook_state == ItemData.CookState.RAW:
		text_to_show = "燒烤中..."
	elif player_in_area.has_item() and item_on_grill == null:
		if ItemDatabase.GRILL_RECIPES.has(player_in_area.held_item.id):
			text_to_show = "(E) 放置"
		else:
			text_to_show = "(無法燒烤)"
	elif not player_in_area.has_item() and item_on_grill != null:
		text_to_show = "(E) 拿取 " + item_on_grill.display_name
	
	hint_label.text = text_to_show
	hint_label.visible = (text_to_show != "")
