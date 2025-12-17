extends Resource
class_name ItemData

enum CookState {
	RAW,
	COOKED,
	BURNT
}

@export var id: String = ""
@export var cook_state: CookState = CookState.RAW
@export var texture: Texture2D # New property for the item's texture
