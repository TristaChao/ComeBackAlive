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
