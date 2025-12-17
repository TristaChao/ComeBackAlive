extends Area2D

@onready var hint_label := $HintLabel
@onready var item_sprite := $ItemSprite # Reference to the sprite on the counter
var player_in_area: Player = null
var item_on_counter: ItemData = null # The item this counter is holding

func _ready():
	hint_label.visible = false
	item_sprite.visible = false # Hide item sprite initially
	
	# Start with one piece of raw beef on the counter.
	var initial_beef := ItemData.new()
	initial_beef.id = "beef"
	initial_beef.cook_state = ItemData.CookState.RAW
	initial_beef.texture = load("res://images/assets/food/16/tile_180.png") # Assign the texture here
	item_on_counter = initial_beef
	update_item_visual() # Show the initial beef

func can_interact() -> bool:
	# We can interact if we can either pick up or put down an item.
	if player_in_area:
		var player_has_item = player_in_area.has_item()
		var counter_has_item = (item_on_counter != null)
		return (player_has_item and not counter_has_item) or (not player_has_item and counter_has_item)
	return false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = body
		update_hint()

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = null
		hint_label.visible = false

func update_hint():
	if player_in_area:
		var player_has_item = player_in_area.has_item()
		var counter_has_item = (item_on_counter != null)

		if player_has_item and not counter_has_item:
			hint_label.text = "(E) 放下"
			hint_label.visible = true
		elif not player_has_item and counter_has_item:
			hint_label.text = "(E) 拿取 " + item_on_counter.id
			hint_label.visible = true
		else:
			# Hide hint if no interaction is possible
			hint_label.visible = false
	else:
		hint_label.visible = false

func interact(player: Player):
	var player_has_item = player.has_item()
	var counter_has_item = (item_on_counter != null)

	# Scenario 1: Player is empty, Counter has an item -> Player TAKES item
	if not player_has_item and counter_has_item:
		var item_to_take = item_on_counter
		item_on_counter = null
		player.pick_item(item_to_take)
	
	# Scenario 2: Player has an item, Counter is empty -> Player GIVES item
	elif player_has_item and not counter_has_item:
		var item_to_drop = player.drop_item()
		item_on_counter = item_to_drop
		print("將 ", item_to_drop.id, " 放在了櫃台上")

	# Update hint text and item visual after the interaction
	update_hint()
	update_item_visual()

func update_item_visual():
	if item_on_counter != null:
		item_sprite.texture = item_on_counter.texture # Beef texture
		item_sprite.visible = true
	else:
		item_sprite.visible = false
