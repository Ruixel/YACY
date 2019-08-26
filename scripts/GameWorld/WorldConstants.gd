tool
extends Node

const TEXTURE_SIZE = 0.5
const LEVEL_HEIGHT = 2
const LEVEL_SIZE   = Vector2(1, 1)

# Tool names
enum Tools {
	NOTHING, WALL, PLATFORM, SPAWN
}

enum Mode {
	SELECT, MULTISELECT, CREATE, EDIT
}

const ToolToString = {
	Tools.NOTHING: "Nothing",
	Tools.WALL: "Wall",
	Tools.PLATFORM: "Platform",
	Tools.SPAWN: "Spawn Location"
}