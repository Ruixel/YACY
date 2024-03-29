tool
extends Node

const LEVEL_HEIGHT = 2.6
const TEXTURE_SIZE = 1.0 / LEVEL_HEIGHT
const LEVEL_SIZE   = Vector2(1, 1)
const MAX_LEVELS   = 20

const MASTER_KEY = 11

const GEOMETRY_COLLISION_BIT = 0 
const OPAQUE_COLLISION_BIT = 1
const ENTITY_COLLISION_BIT = 2 #4
const PROJECTILE_COLLISION_BIT = 3 #8
const PLAYER_COLLISION_BIT = 4 #16
const ICEMAN_COLLISION_BIT = 15 #32768

const SERVER = "https://yacy.org" #"http://yacy.org"

# Tool names
enum Tools {
	NOTHING, WALL, PLATFORM, PILLAR, RAMP, SPAWN, GROUND, HOLE, ALL
}

enum Mode {
	SELECT, MULTISELECT, CREATE, EDIT
}

enum Objectives {
	DIAMONDS, ICEMEN, FINISH, PORTAL, NONE
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

enum Weather {
	PARTLY_CLOUDY, FOG, HEAVY_FOG, RAIN, SNOW
}
