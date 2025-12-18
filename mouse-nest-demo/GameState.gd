extends Node

enum State {
	FREE_MOVE,
	POUCH_OPEN,
	DIALOG,
	WAREHOUSE_OPEN # New state for when warehouse is open
}

var state := State.FREE_MOVE

# --- Pouch Data ---
var pouch: Array[ItemData] = []
const POUCH_CAPACITY := 5

# --- Warehouse Data ---
var warehouse: Array[ItemData] = []
const WAREHOUSE_CAPACITY := 20

func _ready():
	# --- 臨時測試資料 ---
	# We are adding all necessary base items for combination testing into the warehouse.
	
	if warehouse.is_empty():
		var items_to_add = [
			"cooked_beef",
			"plate",
			"skewer",
			"mushroom",
			"onion" # Adding onion as well for sauce making
		]
		
		for item_id in items_to_add:
			var item = ItemDatabase.create_item(item_id)
			if item:
				warehouse.append(item)

	# We will remove the temporary settings for the counter later.
	# For now, it provides an onion, which is fine.
	# --- 臨時測試資料結束 ---
