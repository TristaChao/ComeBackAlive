extends Node

# This is our master item database.
const DATA = {
	# --- Ingredients ---
	"beef": {
		"display_name": "生牛肉", "texture_path": "res://images/assets/food/16/tile_180.png",
		"is_edible": false, "course": "食材", "cuisine": "通用"
	},
	"tomato": {
		"display_name": "番茄", "texture_path": "res://images/assets/food/16/tile_180.png", # 範例路徑
		"is_edible": true, "course": "食材", "cuisine": "通用"
	},
	"onion": {
		"display_name": "洋蔥", "texture_path": "res://images/assets/food/16/tile_179.png", # 範例路徑
		"is_edible": false, "course": "食材", "cuisine": "通用"
	},
	"water": {
		"display_name": "水", "texture_path": "res://images/assets/food/16/tile_50.png",
		"is_edible": false, "course": "食材", "cuisine": "通用"
	},
	"mushroom": {
		"display_name": "蘑菇", "texture_path": "res://images/assets/food/16/tile_177.png", # 範例路徑
		"is_edible": false, "course": "食材", "cuisine": "通用"
	},
	"potato": {
		"display_name": "馬鈴薯", "texture_path": "res://images/assets/food/16/tile_174.png", # 範例路徑
		"is_edible": false, "course": "食材", "cuisine": "通用"
	},
	
	# --- Semi-finished Products ---
	"minced_beef": {
		"display_name": "絞肉", "texture_path": "res://images/assets/food/16/tile_165.png",
		"is_edible": false, "course": "半成品", "cuisine": "通用"
	},
	"tomato_diced": { "display_name": "番茄丁", "texture_path": "res://...", "is_edible": false, "course": "半成品" },
	"onion_diced": { "display_name": "洋蔥丁", "texture_path": "res://...", "is_edible": false, "course": "半成品" },
	"onion_soup": {
		"display_name": "洋蔥湯", "texture_path": "res://images/assets/food/16/tile_178.png", # 範例路徑
		"is_edible": false, "course": "半成品", "cuisine": "義式"
	},
	"mushroom_sauce": {
		"display_name": "蘑菇醬汁", "texture_path": "res://images/assets/food/16/tile_176.png", # 範例路徑
		"is_edible": false, "course": "配料", "cuisine": "義式"
	},
	"tomato_sauce": {
		"display_name": "番茄醬汁", "texture_path": "res://images/assets/food/16/tile_175.png", # 範例路徑
		"is_edible": false, "course": "配料", "cuisine": "義式"
	},
	
	# --- Cooked & Burnt Food ---
	"cooked_beef": {
		"display_name": "烤牛排", "texture_path": "res://images/assets/food/16/tile_181.png", # 範例路徑
		"is_edible": false, "course": "主餐", "cuisine": "義式"
	},
	"burnt_item": {
		"display_name": "燒焦的東西", "texture_path": "res://images/assets/food/16/tile_182.png", # 範例路徑
		"is_edible": false, "course": "垃圾", "cuisine": "通用"
	}
}

# ==============================================================================
# --- RECIPE BOOKS ---
# ==============================================================================

const CHOP_RECIPES = {
	"beef": "minced_beef",
	"tomato": "tomato_diced",
	"onion": "onion_diced",
	"potato": "potato_chunks"
}

const STOVE_RECIPES = {
	"water": {
		"onion": { "result": "onion_soup", "time": 5.0 }
	},
	"onion_soup": {
		"mushroom": { "result": "mushroom_sauce", "time": 5.0 },
		"tomato": { "result": "tomato_sauce", "time": 5.0 }
	}
}

# Defines what can be grilled and what it turns into.
const GRILL_RECIPES = {
	# Input item ID: { "result": Output item ID, "time": float, "burnt_result": Burnt item ID }
	"beef": { "result": "cooked_beef", "time": 3.0, "burnt_result": "burnt_item" }
}

# ==============================================================================
# --- HELPER FUNCTIONS ---
# ==============================================================================

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
