extends Node

# This is our master item database.
# The key is the item's unique ID.
# The value is a dictionary containing all properties for that item.
const DATA = {
	# Ingredients
	"beef": {
		"display_name": "生牛肉",
		"texture_path": "res://images/assets/food/16/tile_180.png",
		"is_edible": false,
		"course": "食材",
		"cuisine": "通用"
	},
	"tomato": {
		"display_name": "番茄",
		"texture_path": "res://images/assets/food/16/tile_180.png", # 範例路徑，請替換
		"is_edible": true, # 假設番茄可以直接吃
		"course": "食材",
		"cuisine": "通用"
	},
	
	# Semi-finished Products
	"minced_beef": {
		"display_name": "絞肉",
		"texture_path": "res://images/assets/food/16/tile_165.png",
		"is_edible": false,
		"course": "半成品",
		"cuisine": "通用"
	}
	# ... 我們未來會把所有物品都加到這裡
}

# --- RECIPE BOOKS ---

# Defines the result of using the Chopping Board
const CHOP_RECIPES = {
	"beef": "minced_beef"
	# ...
}


# This function creates a new ItemData resource instance based on its ID.
# Other scripts will call this instead of creating ItemData manually.
static func create_item(item_id: String) -> ItemData:
	if not DATA.has(item_id):
		print("ERROR: Item ID '%s' not found in ItemDatabase." % item_id)
		return null

	var item_definition = DATA[item_id]
	var item = ItemData.new()
	
	item.id = item_id
	item.display_name = item_definition.get("display_name", item_id)
	item.texture = load(item_definition.get("texture_path", ""))
	item.is_edible = item_definition.get("is_edible", false)
	item.course = item_definition.get("course", "半成品")
	item.cuisine = item_definition.get("cuisine", "通用")
	
	return item
