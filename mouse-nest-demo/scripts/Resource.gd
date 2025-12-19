extends Area2D
class_name WorldResource

## A script for a resource that can be picked up in the world.

@export var item_id: String = "carrot" # The ID of the item this resource represents
@export var requires_digging: bool = false # Does this resource need to be dug up?
@export var dig_time: float = 2.0 # Time in seconds to dig

@onready var sprite: Sprite2D = $Sprite2D

var item_data: ItemData

func _ready():
	# Get the item data from the database
	item_data = ItemDatabase.create_item(item_id)
	if item_data:
		sprite.texture = item_data.texture
	else:
		print("Error: Could not find item with ID: ", item_id)
		queue_free() # Remove the resource if the item ID is invalid
	
	# Add to a group to be detected by the player
	add_to_group("interactable")

func can_interact() -> bool:
	return true

# This function is called by the Player when they interact with this resource.
func interact(player: Player):
	if requires_digging:
		# TODO: Implement digging minigame/progress bar
		print("This resource needs digging!")
		# For now, we'll just give the item after a delay
		var timer = get_tree().create_timer(dig_time)
		await timer.timeout
		
	# Give the item to the player
	if !player.has_item():
		player.pick_item(item_data)
		# The resource disappears after being picked up
		queue_free()
	else:
		print("Player is already holding an item.")
