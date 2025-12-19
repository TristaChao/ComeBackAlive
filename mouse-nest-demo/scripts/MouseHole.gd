extends Area2D
class_name MouseHole

## This script handles the transition from an outside area back to the mouse nest.

func _ready():
	# We defer the connection to the next frame to ensure the physics engine is stable
	# and doesn't fire the signal incorrectly on the first frame.
	var timer = get_tree().create_timer(0, false) # Timeout after 1 frame
	await timer.timeout
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if the body that entered is the player
	if body.is_in_group("player"):
		print("Player entered mouse hole, returning to nest...")
		
		# Here we would handle transferring the held item back to the nest's inventory
		# For now, we will just simulate this.
		var player = body as Player
		if player.has_item():
			var held_item = player.drop_item()
			# In a real implementation, we would pass this item to the nest scene,
			# but for now, we just add it to the global GameState pouch.
			if GameState.pouch.size() < GameState.POUCH_CAPACITY:
				GameState.pouch.append(held_item)
				print("Item ", held_item.id, " was brought back to the nest.")
			else:
				print("Pouch was full, item ", held_item.id, " was dropped.")

		# Change the scene back to the mouse nest, but deferred to avoid physics errors
		get_tree().call_deferred("change_scene_to_file", "res://mouse_nest.tscn")
