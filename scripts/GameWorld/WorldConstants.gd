tool
extends Node

const LEVEL_HEIGHT = 2.6
const TEXTURE_SIZE = 1.0 / LEVEL_HEIGHT
const LEVEL_SIZE   = Vector2(1, 1)
const MAX_LEVELS   = 20

# Tool names
enum Tools {
	NOTHING, WALL, PLATFORM, PILLAR, RAMP, SPAWN, GROUND, HOLE, ALL
}

enum Mode {
	SELECT, MULTISELECT, CREATE, EDIT
}

const ToolToString = {
	Tools.NOTHING: "Nothing",
	Tools.WALL: "Wall",
	Tools.PLATFORM: "Platform",
	Tools.PILLAR: "Pillar",
	Tools.RAMP: "Ramp",
	Tools.SPAWN: "Spawn Location",
	Tools.GROUND: "Ground",
	Tools.HOLE: "Hole"
}

enum WallShape {
	FULLWALL, HALFWALLBOTTOM, HALFWALLTOP, QCIRCLEWALL, ARCHWALL
}

enum PlatShape {
	QUAD, DIAMOND, TRI_TR, TRI_BL, TRI_TL, TRI_BR
}
