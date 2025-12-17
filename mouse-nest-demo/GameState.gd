extends Node

enum State {
	FREE_MOVE,
	POUCH_OPEN,
	DIALOG
}

var state := State.FREE_MOVE

var pouch := []
const POUCH_CAPACITY := 5

func _ready():
	# --- Temporary for testing Pouch UI ---
	var test_beef_1 := ItemData.new()
	test_beef_1.id = "beef_1"
	test_beef_1.cook_state = ItemData.CookState.RAW
	test_beef_1.texture = load("res://images/assets/food/16/tile_180.png")
	pouch.append(test_beef_1)

	var test_beef_2 := ItemData.new()
	test_beef_2.id = "beef_2"
	test_beef_2.cook_state = ItemData.CookState.RAW
	test_beef_2.texture = load("res://images/assets/food/16/tile_180.png")
	pouch.append(test_beef_2)
	# --- End Temporary ---
