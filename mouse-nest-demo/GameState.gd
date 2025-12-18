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
	# 我們在倉庫裡放入一些測試用的食材
	
	if warehouse.is_empty():
		# Add a raw beef to test grilling
		var beef_to_test = ItemDatabase.create_item("beef")
		if beef_to_test:
			warehouse.append(beef_to_test)
			
		# Add a mushroom to test sauce recipe
		var mushroom_to_test = ItemDatabase.create_item("mushroom")
		if mushroom_to_test:
			warehouse.append(mushroom_to_test)

	# --- 臨時測試資料結束 ---