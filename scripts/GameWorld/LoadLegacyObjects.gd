extends Node

# Geometric Objects
const Wall = preload("res://scripts/GameWorld/LegacyWall.gd")
const Plat = preload("res://scripts/GameWorld/LegacyPlatform.gd")
const Pillar = preload("res://scripts/GameWorld/Pillar.gd")
const Ramp = preload("res://scripts/GameWorld/LegacyRamp.gd")
const Floor = preload("res://scripts/GameWorld/LegacyFloor.gd")
const Hole = preload("res://scripts/GameWorld/LegacyHole.gd")

func create_wall(disp : Vector2, start : Vector2, texColour, height : int, level: int):
	start = start / 5.0
	disp = disp / 5.0
	var end : Vector2 = start + disp
	
	var new_wall = Wall.new(start, level)
	new_wall.end = end
	if typeof(texColour) == TYPE_INT:
		new_wall.texture = WorldTextures.getWallTexture(texColour)
	else:
		new_wall.texture = WorldTextures.TextureID.COLOR
		new_wall.colour = texColour
	new_wall.change_height_value(height)
	
	get_parent().call("add_geometric_object", new_wall, level)

func create_triwall(pos : Vector2, is_bottom : int, texColour, direction : int, level: int):
	pos = pos / 5.0
	
	var new_triwall = Wall.new(pos, level)
	var disp
	match (direction):
		1: disp = Vector2(0, 4)
		2: disp = Vector2(0, -4)
		3: disp = Vector2(4, 0)
		4: disp = Vector2(-4, 0)
		5: disp = Vector2(3, 3)
		6: disp = Vector2(3, -3)
		7: disp = Vector2(-3, -3)
		8: disp = Vector2(-3, 3)
	if is_bottom == 1:
		new_triwall.wallShape = WorldConstants.WallShape.HALFWALLBOTTOM
		new_triwall.end = pos + disp
	else:
		new_triwall.wallShape = WorldConstants.WallShape.HALFWALLTOP
		new_triwall.end = pos
		new_triwall.start = pos + disp

	if typeof(texColour) == TYPE_INT:
		new_triwall.texture = WorldTextures.getWallTexture(texColour)
	else:
		new_triwall.texture = WorldTextures.TextureID.COLOR
		new_triwall.colour = texColour
	
	get_parent().call("add_geometric_object", new_triwall, level)

func create_floor(pos1 : Vector2, pos2 : Vector2, pos3 : Vector2, pos4 : Vector2, 
				  floor_texColour, isVisible, ceil_texColour, level):
	var new_floor = Floor.new(level)
	new_floor.vertices[0] = pos1 / 5.0
	new_floor.vertices[1] = pos2 / 5.0
	new_floor.vertices[2] = pos3 / 5.0
	new_floor.vertices[3] = pos4 / 5.0
	
	print("Loaded floor: " + str(level))
	
	new_floor.isVisible = !bool(isVisible - 1)
	
	if typeof(floor_texColour) == TYPE_INT:
		new_floor.floor_texture = WorldTextures.getPlatTexture(floor_texColour)
	else:
		new_floor.floor_texture = WorldTextures.TextureID.COLOR
		new_floor.floor_colour = floor_texColour
		
	if typeof(ceil_texColour) == TYPE_INT:
		new_floor.ceil_texture = WorldTextures.getPlatTexture(ceil_texColour)
	else:
		new_floor.ceil_texture = WorldTextures.TextureID.COLOR
		new_floor.ceil_colour = ceil_texColour
	
	get_parent().call("modify_fixed_object", WorldConstants.Tools.GROUND, level, new_floor)

func create_plat(pos : Vector2, size : int, texColour, height : int, shape, level: int):
	pos = pos / 5.0
	
	var new_plat = Plat.new(pos, level)
	new_plat.size = size
	new_plat.platShape = shape
	if typeof(texColour) == TYPE_INT:
		new_plat.texture = WorldTextures.getPlatTexture(texColour)
	else:
		new_plat.texture = WorldTextures.TextureID.COLOR
		new_plat.colour = texColour
	new_plat.change_height_value(height)
	
	get_parent().call("add_geometric_object", new_plat, level)

func create_pillar(pos : Vector2, isDiagonal : int, size : int, texColour, height : int, level: int):
	pos = pos / 5.0
	
	var new_pillar = Pillar.new(pos, level)
	new_pillar.size = size
	if typeof(texColour) == TYPE_INT:
		new_pillar.texture = WorldTextures.getWallTexture(texColour)
	else:
		new_pillar.texture = WorldTextures.TextureID.COLOR
		new_pillar.colour = texColour
	new_pillar.change_height_value(height)
	new_pillar.diagonal = bool(isDiagonal - 1)
	
	get_parent().call("add_geometric_object", new_pillar, level)

func create_ramp(end : Vector2, direction : int, texColour, level: int):
	end = end / 5.0
	var start
	match direction:
		1: start = end + Vector2(0,  4)
		2: start = end + Vector2(0, -4)
		3: start = end + Vector2(4,  0)
		4: start = end + Vector2(-4, 0)
		5: start = end + Vector2(3,  3)
		6: start = end + Vector2(3, -3)
		7: start = end + Vector2(-3,-3)
		8: start = end + Vector2(-3, 3)
		_: return
	
	var new_ramp = Ramp.new(start, level)
	new_ramp.end = end
	if typeof(texColour) == TYPE_INT:
		new_ramp.texture = WorldTextures.getPlatTexture(texColour)
	else:
		new_ramp.texture = WorldTextures.TextureID.COLOR
		new_ramp.colour = texColour
		
	get_parent().call("add_geometric_object", new_ramp, level)

func create_hole(pos : Vector2, size : int, level : int):
	pos = pos / 5.0
	
	var new_hole = Hole.new(pos, level)
	new_hole.size = size

	get_parent().call("add_geometric_object", new_hole, level)
	
#	if (new_hole.is_valid(get_parent().fixed_objects[WorldConstants.Tools.GROUND][level])):
#		print("successfully added hole")
#	else:
#		print("hole issues")

func create_spawn(pos : Vector2, direction : int, level : int):
	var new_spawn = preload("res://Entities/Legacy/Spawn/Spawn.tscn").instance()
	new_spawn.set_name("SpawnLocation")
	
	pos = pos / 5.0
	new_spawn.set_translation(Vector3(pos.x, (level - 1) * WorldConstants.LEVEL_HEIGHT + 0.001, pos.y))
	
	match (direction):
		1: new_spawn.set_rotation_degrees(Vector3(0, 0, 0))
		2: new_spawn.set_rotation_degrees(Vector3(0, 180, 0))
		3: new_spawn.set_rotation_degrees(Vector3(0, 90, 0))
		4: new_spawn.set_rotation_degrees(Vector3(0, 270, 0))
	
	get_parent().call("add_entity", new_spawn)

func create_msgBoard(pos : Vector2, msg : String, direction : int, height: int, level : int):
	var new_board = preload("res://Entities/Legacy/MessageBoard/MsgBoard.tscn").instance()
	new_board.get_node("Viewport/Text").set_text(msg)
	
	var t = new_board.get_node("Viewport").get_texture()
	new_board.get_node("Front").mesh.surface_get_material(0).albedo_texture = t
	
	pos = pos / 5.0
	new_board.set_translation(Vector3(pos.x, (level - 1) * WorldConstants.LEVEL_HEIGHT, pos.y))
	
	match (direction):
		1: new_board.set_rotation_degrees(Vector3(0, 0, 0))
		2: new_board.set_rotation_degrees(Vector3(0, 180, 0))
		3: new_board.set_rotation_degrees(Vector3(0, 90, 0))
		4: new_board.set_rotation_degrees(Vector3(0, 270, 0))
		5: new_board.set_rotation_degrees(Vector3(0, 45, 0))
		6: new_board.set_rotation_degrees(Vector3(0, 135, 0))
		7: new_board.set_rotation_degrees(Vector3(0, 225, 0))
		8: new_board.set_rotation_degrees(Vector3(0, 315, 0))
	
	match (height):
		2: new_board.set_translation(new_board.get_translation() + Vector3(0, WorldConstants.LEVEL_HEIGHT * 1/4.0, 0))
		3: new_board.set_translation(new_board.get_translation() + Vector3(0, WorldConstants.LEVEL_HEIGHT * 1/2.0, 0))
		4: new_board.set_translation(new_board.get_translation() + Vector3(0, WorldConstants.LEVEL_HEIGHT * 3/4.0, 0))
	
	get_parent().call("add_entity", new_board)

func create_portal(pos : Vector2, title : String, condition : int, gameNumber: String, level : int):
	var new_portal = preload("res://Entities/Legacy/Portal/Portal.tscn").instance()
	new_portal.get_node("Viewport/Text").set_text(title)
	print(title)
	
	var t = new_portal.get_node("Viewport").get_texture()
	new_portal.get_node("TextArea").get_surface_material(0).albedo_texture = t
	
	pos = pos / 5.0
	new_portal.set_translation(Vector3(pos.x, (level - 1) * WorldConstants.LEVEL_HEIGHT, pos.y))
	
	get_parent().call("add_entity", new_portal)

func finalise():
	for lvl in range(0, WorldConstants.MAX_LEVELS + 1):
		get_parent().fixed_objects[WorldConstants.Tools.GROUND][lvl]._genMesh()
