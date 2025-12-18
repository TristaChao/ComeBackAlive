extends Area2D
class_name Stove

# --- Node References ---
@onready var hint_label: Label = $HintLabel
@onready var item_sprite: Sprite2D = $ItemSprite
@onready var cook_timer: Timer = $CookTimer
@onready var progress_bar: ProgressBar = $ProgressBar

# --- State ---
var item_in_pot: ItemData = null
var player_in_area: Player = null
var is_cooking: bool = false
var active_recipe_result: String = "" # Stores the ID of the item that will be produced

func _ready() -> void:
	hint_label.hide()
	progress_bar.hide()
	item_sprite.hide()

func _process(delta: float) -> void:
	if is_cooking:
		progress_bar.value = (1.0 - cook_timer.get_time_left() / cook_timer.wait_time) * 100

func can_interact() -> bool:
	if is_cooking:
		return false
	return player_in_area != null

func interact(player: Player) -> void:
	if not can_interact():
		return

	# Case 0 (NEW): Pot is empty, player is empty-handed. -> Give water to player (DEV CHEAT)
	if item_in_pot == null and not player.has_item():
		var water_item = ItemDatabase.create_item("water")
		if water_item:
			player.pick_item(water_item)
			print("DEV CHEAT: Gave 'water' to player.")
		update_hint_text()
		return

	# Case 1: Pot has a finished item, player is empty-handed. -> Player takes finished item.
	if item_in_pot != null and not player.has_item():
		# Only allow taking finished sauces/soups, not just water
		if item_in_pot.id != "water":
			player.pick_item(item_in_pot)
			item_in_pot = null
			item_sprite.hide()
			update_hint_text()
		return

	# Case 2: Player is holding an item. Try to place it in the pot.
	if player.has_item():
		var held_item_id = player.held_item.id
		
		# Sub-case 2.1: Pot is empty, player is holding water. -> Place water in pot.
		if item_in_pot == null and held_item_id == "water":
			item_in_pot = player.drop_item()
			item_sprite.texture = item_in_pot.texture
			item_sprite.show()
			update_hint_text()
			return
			
		# Sub-case 2.2: Pot has 'water', player adds a valid next ingredient. -> Start cooking.
		if item_in_pot != null:
			var base_id = item_in_pot.id
			if ItemDatabase.STOVE_RECIPES.has(base_id) and ItemDatabase.STOVE_RECIPES[base_id].has(held_item_id):
				# Valid recipe found, consume player's item and start cooking
				var recipe = ItemDatabase.STOVE_RECIPES[base_id][held_item_id]
				player.drop_item() # Consume the item from player's hand
				start_cooking(recipe)
				return

func start_cooking(recipe: Dictionary) -> void:
	is_cooking = true
	active_recipe_result = recipe.result # Store the target item ID
	cook_timer.wait_time = recipe.time
	cook_timer.start()
	
	# Hide the old item, show progress
	item_sprite.hide()
	progress_bar.show()
	update_hint_text()

func _on_cook_timer_timeout() -> void:
	is_cooking = false
	progress_bar.hide()

	if active_recipe_result.is_empty():
		return

	# Create the new item based on the stored result ID
	var new_item = ItemDatabase.create_item(active_recipe_result)
	if new_item:
		item_in_pot = new_item
		item_sprite.texture = new_item.texture
		item_sprite.show() # Show the new item
		print("Stove cooking complete! New item: %s" % new_item.id)

	active_recipe_result = "" # Reset for the next cook
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

	if is_cooking:
		hint_label.text = "烹煮中..."
		hint_label.show()
		return

	var text_to_show = ""
	if player_in_area.has_item():
		var held_item_id = player_in_area.held_item.id
		if item_in_pot == null:
			if held_item_id == "water":
				text_to_show = "(E) 加水"
		else: # Pot has something
			var base_id = item_in_pot.id
			if ItemDatabase.STOVE_RECIPES.has(base_id) and ItemDatabase.STOVE_RECIPES[base_id].has(held_item_id):
				text_to_show = "(E) 加入" + player_in_area.held_item.display_name
	else: # player is empty-handed
		if item_in_pot == null: # Pot is empty
			text_to_show = "(E) 取水(測試用)"
		elif item_in_pot.id != "water": # Pot has a finished item
			text_to_show = "(E) 取出 " + item_in_pot.display_name
	
	hint_label.text = text_to_show
	hint_label.visible = (text_to_show != "")
