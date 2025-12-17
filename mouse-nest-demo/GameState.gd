extends Node

enum State {
	FREE_MOVE,
	POUCH_OPEN,
	DIALOG
}

var state := State.FREE_MOVE

var pouch := []
const POUCH_CAPACITY := 5
