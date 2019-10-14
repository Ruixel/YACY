tool
extends Node

const LEVEL_HEIGHT = 2.6
const TEXTURE_SIZE = 1.0 / LEVEL_HEIGHT
const LEVEL_SIZE   = Vector2(1, 1)

# Tool names
enum Tools {
	NOTHING, WALL, PLATFORM, PILLAR, SPAWN
}

enum Mode {
	SELECT, MULTISELECT, CREATE, EDIT
}

const ToolToString = {
	Tools.NOTHING: "Nothing",
	Tools.WALL: "Wall",
	Tools.PLATFORM: "Platform",
	Tools.PILLAR: "Pillar",
	Tools.SPAWN: "Spawn Location"
}

enum WallShape {
	FULLWALL, HALFWALLBOTTOM, HALFWALLTOP, QCIRCLEWALL, ARCHWALL
}