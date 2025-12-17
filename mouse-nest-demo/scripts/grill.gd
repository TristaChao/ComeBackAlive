extends Area2D

@onready var hint_label := $HintLabel
@onready var progress_bar := $ProgressBar
@onready var cook_timer := $Timer
@onready var item_sprite := $ItemSprite # Reference to the sprite on the grill

var player_in_area: Player = null
var item_on_grill: ItemData = null

func _ready():
	hint_label.visible = false
	progress_bar.visible = false
	item_sprite.visible = false # Hide item sprite initially
	cook_timer.one_shot = true # Ensure timer is one-shot, as we will restart it.
	
func can_interact() -> bool:
	if player_in_area:
		var player_has_item = player_in_area.has_item()
		var grill_has_item = (item_on_grill != null)
		
		# Can interact if player can place item, or player can take item
		return (player_has_item and not grill_has_item) or (not player_has_item and grill_has_item)
	return false

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_area = body
		update_hint()
		hint_label.visible = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_area = null
		hint_label.visible = false
		# stop_cooking() # Temporarily disabled for debugging

func update_hint():
	if player_in_area:
		var player_has_item = player_in_area.has_item()
		var grill_has_item = (item_on_grill != null)

		if player_has_item and not grill_has_item:
			hint_label.text = "(E) 放下 " + player_in_area.held_item.id
			hint_label.visible = true
		elif not player_has_item and grill_has_item:
			hint_label.text = "(E) 拿取 " + item_on_grill.id
			hint_label.visible = true
		else:
			hint_label.visible = false
	else:
		hint_label.visible = false

func interact(player: Player):
	var player_has_item = player.has_item()
	var grill_has_item = (item_on_grill != null)

	# Scenario 1: Player is empty, Grill has an item -> Player TAKES item
	if not player_has_item and grill_has_item:
		var item_to_take = item_on_grill
		item_on_grill = null
		player.pick_item(item_to_take)
		stop_cooking() # Stop cooking and hide bar after item is taken
		update_item_visual() # Update grill visual (empty)
	
	# Scenario 2: Player has an item, Grill is empty -> Player GIVES item
	elif player_has_item and not grill_has_item:
		var item_to_place = player.drop_item()
		if item_to_place.cook_state != ItemData.CookState.RAW: # Can only cook raw items
			player.pick_item(item_to_place) # Player takes it back
			print("烤台只能放生食！")
			return
		item_on_grill = item_to_place
		start_cooking() # Start cooking
		update_item_visual() # Show item on grill
	
	# Update hint text after the interaction
	update_hint()

func start_cooking():
	cook_timer.wait_time = 3.0 # <-- 確保第一階段的等待時間
	progress_bar.value = 0
	progress_bar.visible = true
	cook_timer.start()
	print("計時器啟動！")
	print("開始烹飪: ", item_on_grill.id, ", 狀態: ", ItemData.CookState.keys()[item_on_grill.cook_state])

func stop_cooking():
	cook_timer.stop()
	progress_bar.visible = false
	print("停止烹飪")

# Called every frame
func _process(delta):
	if item_on_grill != null and cook_timer.wait_time > 0 and cook_timer.is_stopped() == false: # Check if timer is running
		progress_bar.value = (cook_timer.wait_time - cook_timer.time_left) / cook_timer.wait_time
		
		# print("Wait Time: ", cook_timer.wait_time, ", Time Left: ", cook_timer.time_left, ", Progress: ", progress_bar.value) # For debugging

func _on_timer_timeout():
	print("計時結束！") # <-- 加上這行
	if item_on_grill == null:
		return

	if item_on_grill.cook_state == ItemData.CookState.RAW:
		item_on_grill.cook_state = ItemData.CookState.COOKED
		cook_timer.wait_time = 2.0 # <-- 確保第二階段的等待時間
		cook_timer.start() # Start next stage of cooking
		print("物品變成: ", item_on_grill.id, ", 狀態: ", ItemData.CookState.keys()[item_on_grill.cook_state])
	elif item_on_grill.cook_state == ItemData.CookState.COOKED:
		item_on_grill.cook_state = ItemData.CookState.BURNT
		stop_cooking() # Cooking stops after burning
		print("物品燒焦了: ", item_on_grill.id, ", 狀態: ", ItemData.CookState.keys()[item_on_grill.cook_state])
	
	update_item_visual() # Update grill item visual
	update_hint() # Update hint for new state

# New function to update the visual representation of the item on the grill
func update_item_visual():
	if item_on_grill != null:
		item_sprite.visible = true
		match item_on_grill.cook_state:
			ItemData.CookState.RAW:
				item_on_grill.texture = load("res://images/assets/food/16/tile_180.png")
			ItemData.CookState.COOKED:
				item_on_grill.texture = load("res://images/assets/food/16/tile_179.png") # Placeholder for cooked beef
			ItemData.CookState.BURNT:
				item_on_grill.texture = load("res://images/assets/food/16/tile_46.png") # Placeholder for burnt food
		item_sprite.texture = item_on_grill.texture
	else:
		item_sprite.visible = false
