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
	new_spawn.set_translation(Vector3(pos.x, (level - 1) * WorldConstants.LEVEL_HEIGHT + 0.003, pos.y))
	
	match (direction):
		1: new_spawn.set_rotation_degrees(Vector3(0, 0, 0))
		2: new_spawn.set_rotation_degrees(Vector3(0, 180, 0))
		3: new_spawn.set_rotation_degrees(Vector3(0, 90, 0))
		4: new_spawn.set_rotation_degrees(Vector3(0, 270, 0))
	
	get_parent().call("add_entity", new_spawn)

func create_finish(pos: Vector2, condition: int, level: int):
	var new_finish = preload("res://Entities/Legacy/Finish/Finish.tscn").instance()
	
	pos = pos / 5.0
	new_finish.set_translation(Vector3(pos.x, (level - 1) * WorldConstants.LEVEL_HEIGHT + 0.003, pos.y))
	
	get_parent().call("add_entity", new_finish)

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
	gameNumber = gameNumber.substr(1, gameNumber.length() - 2)
	if gameNumber.is_valid_integer():
		new_portal.set_gameNumber(int(gameNumber))
	
	var t = new_portal.get_node("Viewport").get_texture()
	new_portal.get_node("TextArea").get_surface_material(0).albedo_texture = t
	
	pos = pos / 5.0
	new_portal.set_translation(Vector3(pos.x, (level - 1) * WorldConstants.LEVEL_HEIGHT, pos.y))
	
	get_parent().call("add_entity", new_portal)

func create_teleport(pos : Vector2, number : int, level : int):
	var new_tp = preload("res://Entities/Legacy/Teleport/Teleport.tscn").instance()
	
	new_tp.set_number(number)
	
	pos = pos / 5.0
	new_tp.set_translation(Vector3(pos.x, (level - 1) * WorldConstants.LEVEL_HEIGHT + 0.003, pos.y))
	
	get_parent().call("add_entity", new_tp)

func create_jetpack(pos: Vector2, needs_fuel: int, level: int):
	var new_jp = preload("res://Entities/Legacy/Jetpack/JetpackPickup.tscn").instance()
	
	match needs_fuel:
		1: new_jp.set_unlimited_fuel(true)
		2: new_jp.set_unlimited_fuel(false)
	
	pos = pos / 5.0
	new_jp.set_translation(Vector3(pos.x, (level - 1) * WorldConstants.LEVEL_HEIGHT + 0.8, pos.y))
	
	get_parent().call("add_entity", new_jp)

func create_fuel(pos: Vector2, fuel_amount: int, level: int):
	var new_fuel = preload("res://Entities/Legacy/Fuel/FuelPickup.tscn").instance()
	
	var fuel_sec = 0
	match fuel_amount:
		1: fuel_sec = 30
		2: fuel_sec = 60
		3: fuel_sec = 120
		4: fuel_sec = 240
	
	new_fuel.set_fuel_amount(fuel_sec)
	
	pos = pos / 5.0
	new_fuel.set_translation(Vector3(pos.x, (level - 1) * WorldConstants.LEVEL_HEIGHT + 0.005, pos.y))
	
	get_parent().call("add_entity", new_fuel)

func create_door(pos: Vector2, dir: int, key: int, texColour, level: int):
	var new_door = preload("res://Entities/Legacy/Door/Door.tscn").instance()
	
	pos = pos / 5.0
	if dir == 1:
		new_door.set_translation(Vector3(pos.x + 0.5, (level - 1) * WorldConstants.LEVEL_HEIGHT + 0.003, pos.y))
		new_door.set_scale(Vector3(0.5, WorldConstants.LEVEL_HEIGHT / 2.0, 0.5))
	else:
		new_door.set_translation(Vector3(pos.x, (level - 1) * WorldConstants.LEVEL_HEIGHT + 0.003, pos.y - 0.5))
		new_door.set_scale(Vector3(0.5, WorldConstants.LEVEL_HEIGHT / 2.0, 0.5))
		new_door.set_rotation_degrees(Vector3(0,0,0))
	
	if typeof(texColour) == TYPE_INT:
		new_door.set_texture(texColour)
	else:
		new_door.set_colour(texColour)
	
	new_door.set_keyRequired(key-1)
	
	get_parent().call("add_entity", new_door)

func create_key(pos: Vector2, key_number: int, level: int):
	var new_key = preload("res://Entities/Legacy/Key/Key.tscn").instance()
	
	pos = pos / 5.0
	new_key.set_translation(Vector3(pos.x, (level - 1) * WorldConstants.LEVEL_HEIGHT + 0.8, pos.y))
	new_key.set_keyNumber(key_number-1)
	
	get_parent().call("add_entity", new_key)

func create_ladder(pos: Vector2, direction: int, level: int):
	var new_ladder = preload("res://Entities/Legacy/Ladder/Ladder.tscn").instance()
	
	pos = pos / 5.0
	new_ladder.set_translation(Vector3(pos.x, (level - 1 + 0.5) * WorldConstants.LEVEL_HEIGHT, pos.y))
	new_ladder.set_scale(Vector3(1, WorldConstants.LEVEL_HEIGHT / 2.0, 1))
	
	match (direction):
		1: new_ladder.set_rotation_degrees(Vector3(0, 0, 0))
		2: new_ladder.set_rotation_degrees(Vector3(0, 180, 0))
		3: new_ladder.set_rotation_degrees(Vector3(0, 90, 0))
		4: new_ladder.set_rotation_degrees(Vector3(0, 270, 0))
		5: new_ladder.set_rotation_degrees(Vector3(0, 45, 0))
		6: new_ladder.set_rotation_degrees(Vector3(0, 135, 0))
		7: new_ladder.set_rotation_degrees(Vector3(0, 225, 0))
		8: new_ladder.set_rotation_degrees(Vector3(0, 315, 0))
	
	get_parent().call("add_entity", new_ladder)

func create_diamond(pos: Vector2, time_bonus: int, height: int, level: int):
	var new_dia = preload("res://Entities/Legacy/Diamond/Diamond.tscn").instance()
	
	var lvlheight
	match height:
		1: lvlheight = 0.25
		2: lvlheight = 0.50
		3: lvlheight = 0.75
		4: lvlheight = 1.00
	
	new_dia.set_type(time_bonus)
	
	pos = pos / 5.0
	new_dia.set_translation(Vector3(pos.x, (level - 1 + lvlheight) * WorldConstants.LEVEL_HEIGHT, pos.y))
	new_dia.set_scale(Vector3(1, WorldConstants.LEVEL_HEIGHT / 2.0, 1))
	
	get_parent().call("add_collectable", "diamond")
	get_parent().call("add_entity", new_dia)

func create_iceman(pos: Vector2, speed: int, hits: int, level: int):
	var new_ice = preload("res://Entities/Legacy/Iceman/Iceman.tscn").instance()
	
	match speed:
		1: new_ice.set_speed(50)
		2: new_ice.set_speed(80)
		3: new_ice.set_speed(130)
	
	match hits:
		11: new_ice.set_hits(20)
		12: new_ice.set_hits(100)
		_: new_ice.set_hits(hits)
	
	pos = pos / 5.0
	new_ice.set_translation(Vector3(pos.x, (level - 1) * WorldConstants.LEVEL_HEIGHT, pos.y))
	
	get_parent().call("add_collectable", "iceman")
	get_parent().call("add_entity", new_ice)
	#new_ice.call_deferred("check_valid")

func create_slingshot(pos: Vector2, level: int):
	var new_ss = preload("res://Entities/Legacy/SlingshotPickups/SlingshotPickup.tscn").instance()
	
	pos = pos / 5.0
	new_ss.set_translation(Vector3(pos.x, (level - 1) * WorldConstants.LEVEL_HEIGHT + 0.8, pos.y))
	
	get_parent().call("add_entity", new_ss)

var crumb_amounts = [5, 10, 15, 30]
func create_crumbs(pos: Vector2, amount: int, level: int):
	var new_cr = preload("res://Entities/Legacy/SlingshotPickups/CrumbPack.tscn").instance()
	
	new_cr.set_crumb_amount(crumb_amounts[amount-1])
	pos = pos / 5.0
	new_cr.set_translation(Vector3(pos.x, (level - 1) * WorldConstants.LEVEL_HEIGHT + 0.005, pos.y))
	
	get_parent().call("add_entity", new_cr)

func create_chaser(pos: Vector2, modelID: int, speed: int, level: int):
	var new_ch = preload("res://Entities/Legacy/Chasers/Chaser.tscn").instance()
	
	match speed:
		1: new_ch.set_speed(3.3)
		2: new_ch.set_speed(4.2)
		3: new_ch.set_speed(5.2)
	
	pos = pos / 5.0
	new_ch.set_model(modelID)
	new_ch.set_translation(Vector3(pos.x, (level - 1) * WorldConstants.LEVEL_HEIGHT + 0.5, pos.y))
	
	get_parent().call("add_entity", new_ch)

# Theme IDs: 1 = ???, 2 = Night, 3 = Scary
const Themes = {
	1: "res://Scenes/Env/LegacyEnv.tscn", # Need to check
	2: "res://Scenes/Env/NightEnv.tscn",
	3: "res://Scenes/Env/SpookyEnv.tscn"
}
func set_theme(pos : Vector2, themeID : int, level : int):
	var current_env = get_node_or_null("/root/Gameplay/Environment")
	if current_env != null:
		get_node("/root/Gameplay").remove_child(current_env)
		current_env.queue_free()
	
	var new_env = load(Themes[themeID]).instance()
	get_node("/root/Gameplay").add_child(new_env, true)
	#new_env.name = "Environment"

const Songs = {
	1: "res://res/music/Nothing.ogg",
	2: "res://res/music/Funky.ogg",
	3: "res://res/music/Scary.ogg",
	4: "res://res/music/Asian.ogg",
	5: "res://res/music/Space.ogg",
	6: "res://res/music/Lounge.ogg"
}
func set_music(pos: Vector2, musicID: int, level: int):
	print("Setting music id: ", musicID)
	var song_player = get_parent().get_node_or_null("MusicPlayer")
	if song_player != null:
		song_player.stream = load(Songs[musicID])


func finalise():
	for lvl in range(0, WorldConstants.MAX_LEVELS + 1):
		get_parent().fixed_objects[WorldConstants.Tools.GROUND][lvl]._genMesh()
