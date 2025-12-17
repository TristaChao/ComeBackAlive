class_name Player
extends CharacterBody2D

@onready var held_item_sprite := $HeldItemSprite # Reference to the sprite above the player
@onready var pouch_screen: PouchScreen = get_node("/root/MouseNest/UI/PouchScreen") # Reference to the PouchScreen UI node
var held_item: ItemData = null

@export var speed := 120

func _ready():
	held_item_sprite.visible = false # Hide the sprite initially
	print("Pouch Screen 參考：", pouch_screen)

func _physics_process(delta):
	var dir := Vector2.ZERO
	# Prevent movement if any UI is open
	if GameState.state != GameState.State.FREE_MOVE:
		return
	if Input.is_action_pressed("move_up"):
		dir.y -= 1
	if Input.is_action_pressed("move_down"):
		dir.y += 1
	if Input.is_action_pressed("move_left"):
		dir.x -= 1
	if Input.is_action_pressed("move_right"):
		dir.x += 1

	velocity = dir.normalized() * speed
	move_and_slide()
	
func _input(event):
	if event.is_action_pressed("interact"):
		if GameState.state != GameState.State.FREE_MOVE: # Only interact in FREE_MOVE state
			return

		for area in $InteractionArea.get_overlapping_areas():
			if area.has_method("can_interact") and area.can_interact():
				area.interact(self)
				return
	elif event.is_action_pressed("pouch"):
		# --- 情況 1：手上有東西 → 先存進頰囊 ---
		if GameState.state == GameState.State.FREE_MOVE and held_item != null:
			if GameState.pouch.size() < GameState.POUCH_CAPACITY:
				GameState.pouch.append(held_item)
				print("將 ", held_item.id, " 放入頰囊")
				drop_item() # 清空手上物品（圖示會消失）
			else:
				print("頰囊已滿！")
			return  # ⭐ 重點：這裡直接結束，不開 UI


		# --- 情況 2：手上沒東西 → 切換 UI ---
		if GameState.state == GameState.State.FREE_MOVE:
			pouch_screen.open_pouch()

		elif GameState.state == GameState.State.POUCH_OPEN:
			pouch_screen.close_pouch()
		
# --- Item Interaction Functions ---

func has_item() -> bool:
	return held_item != null

func pick_item(item: ItemData):
	if item:
		held_item = item
		# Update the held item's visual
		update_held_item_visual()
		print("拿起物品: ", item.id, ", 狀態: ", ItemData.CookState.keys()[item.cook_state])

func drop_item() -> ItemData:
	var item_to_drop = held_item
	held_item = null
	# Hide the held item's visual
	update_held_item_visual()
	print("放下物品")
	return item_to_drop

func update_held_item_visual():
	if held_item != null:
		held_item_sprite.texture = held_item.texture # Use item's texture
		held_item_sprite.visible = true
	else:
		held_item_sprite.visible = false
