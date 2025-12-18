extends Area2D

@onready var hint_label: Label = $HintLabel
@onready var item_sprite: Sprite2D = $ItemSprite
var player_in_area: Player = null
var item_on_counter: ItemData = null

func _ready():
	hint_label.hide()
	item_sprite.hide()
	# The counter now starts empty. Test items are in the warehouse.
	# var initial_item_id = "beef"
	# item_on_counter = ItemDatabase.create_item(initial_item_id)
	update_item_visual()

# This helper function creates a canonical key from two item IDs.
func _get_combination_key(id1: String, id2: String) -> String:
	var ingredients = [id1, id2]
	ingredients.sort()
	return "|".join(ingredients)

func can_interact() -> bool:
	if not player_in_area:
		return false
	
	# Check for valid combination first
	if player_in_area.held_item and item_on_counter:
		var key = _get_combination_key(player_in_area.held_item.id, item_on_counter.id)
		if ItemDatabase.combination_recipes.has(key):
			return true
		
	# Then check for simple take/place
	return (player_in_area.held_item and not item_on_counter) or \
		   (not player_in_area.held_item and item_on_counter)

func interact(player: Player):
	if not can_interact():
		return

	var player_item = player.held_item
	var counter_item = item_on_counter

	# --- Case 0: Combination ---
	if player_item and counter_item:
		var key = _get_combination_key(player_item.id, counter_item.id)
		if ItemDatabase.combination_recipes.has(key):
			var result_id = ItemDatabase.combination_recipes[key]
			
			player.drop_item() # Consume player's item
			var new_item = ItemDatabase.create_item(result_id)
			item_on_counter = new_item
			
			print("Combination successful! Created: %s" % result_id)
			update_all_visuals()
			return

	# --- Case 1: Player takes item ---
	if not player_item and counter_item:
		player.pick_item(item_on_counter)
		item_on_counter = null
	
	# --- Case 2: Player places item ---
	elif player_item and not counter_item:
		item_on_counter = player.drop_item()

	update_all_visuals()

func update_all_visuals():
	update_item_visual()
	update_hint()

func update_item_visual():
	if item_on_counter != null:
		item_sprite.texture = item_on_counter.texture
		item_sprite.show()
	else:
		item_sprite.hide()

# --- Body Enter/Exit & Hint Updates ---

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = body as Player
		update_hint()
		hint_label.show()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_area = null
		hint_label.hide()

func update_hint() -> void:
	if not player_in_area:
		hint_label.hide()
		return
	
	var text_to_show = ""
	var player_item = player_in_area.held_item
	var counter_item = item_on_counter

	if player_item and counter_item:
		var key = _get_combination_key(player_item.id, counter_item.id)
		if ItemDatabase.combination_recipes.has(key):
			text_to_show = "(E) 組合"
	elif player_item and not counter_item:
		text_to_show = "(E) 放下 " + player_item.display_name
	elif not player_item and counter_item:
		text_to_show = "(E) 拿取 " + counter_item.display_name
	
	hint_label.text = text_to_show
	hint_label.visible = (text_to_show != "")
