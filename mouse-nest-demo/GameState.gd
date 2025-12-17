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
	# 請注意：在完成功能並測試後，記得移除或註解掉這段程式碼！
	
	# 如果頰囊是空的，加入測試物品
	if pouch.is_empty():
		for i in range(2): # 加入 2 個物品到頰囊
			var item = ItemData.new()
			item.id = "test_pouch_" + str(i)
			item.cook_state = ItemData.CookState.RAW
			item.texture = preload("res://images/assets/food/16/tile_180.png")
			pouch.append(item)

	# 如果倉庫是空的，加入測試物品
	if warehouse.is_empty():
		for i in range(5): # 加入 5 個物品到倉庫
			var item = ItemData.new()
			item.id = "test_warehouse_" + str(i)
			item.cook_state = ItemData.CookState.COOKED # 不同的狀態方便區分
			item.texture = preload("res://images/assets/food/16/tile_180.png")
			warehouse.append(item)
	# --- 臨時測試資料結束 ---