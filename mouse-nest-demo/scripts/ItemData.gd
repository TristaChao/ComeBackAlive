extends Resource
class_name ItemData

enum CookState {
	RAW,
	COOKED,
	BURNT
}

@export var id: String
@export var cook_state := CookState.RAW
