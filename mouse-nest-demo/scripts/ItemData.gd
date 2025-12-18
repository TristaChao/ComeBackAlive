extends Resource
class_name ItemData

enum CookState {
	RAW,
	COOKED,
	BURNT
}

# --- Core Properties ---
@export var id: String = ""
@export var display_name: String = ""
@export var description: String = ""
@export var texture: Texture2D

# --- State & Gameplay Tags ---
@export var cook_state: CookState = CookState.RAW
@export var is_edible: bool = false
@export var cuisine: String = "通用"
@export var course: String = "半成品"
