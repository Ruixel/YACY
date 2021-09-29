extends Spatial

const Wall = preload("res://scripts/GameWorld/LegacyWall.gd")
const Plat = preload("res://scripts/GameWorld/LegacyPlatform.gd")
const Pillar = preload("res://scripts/GameWorld/Pillar.gd")
const Ramp = preload("res://scripts/GameWorld/LegacyRamp.gd")
const Floor = preload("res://scripts/GameWorld/LegacyFloor.gd")
const Hole = preload("res://scripts/GameWorld/LegacyHole.gd")

var objects : Array = []
var fixed_objects: Dictionary
var entities : Array = []
var default_objs : Dictionary
var collectables: Dictionary
var weather = WorldConstants.Weather.PARTLY_CLOUDY

var level : int = 1
var levelMeshes : Array 
var entityLocation

var gameNumber = null

var player = null
var spawnLocation = null

signal s_levelLoaded

const toolToObjectDict = {
	WorldConstants.Tools.WALL: Wall,
	WorldConstants.Tools.PLATFORM: Plat,
	WorldConstants.Tools.PILLAR: Pillar,
	WorldConstants.Tools.RAMP: Ramp,
	WorldConstants.Tools.GROUND: Floor,
	WorldConstants.Tools.HOLE: Hole
}

func _ready():
	EntityManager._reset()
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	if get_node_or_null("PauseMenu") != null:
		$PauseMenu.connect("change_music_volume", self, "on_music_volume_change")
	
	# Initialise default objects
	for obj in toolToObjectDict.keys():
		var objectType = toolToObjectDict.get(obj)
		if objectType.canPlace == true:
			default_objs[obj] = objectType.new(Vector2(0,0), 0)
	
	setupLevel()

func setupLevel():
	spawnLocation = null
	levelMeshes = []
	objects = []
	fixed_objects = {}
	collectables = {}
	weather = WorldConstants.Weather.PARTLY_CLOUDY
	var level_debris = get_node_or_null("LevelDebris")
	if level_debris != null:
		for item in level_debris.get_children():
			item.queue_free()
	
	# Initialise level meshes
	for lvl in range(0, WorldConstants.MAX_LEVELS + 1):
		var n = Spatial.new()
		n.set_name("Level" + str(lvl))
		
		add_child(n)
		levelMeshes.append(n)
	
	var ent = Spatial.new()
	ent.set_name("Entities")
	add_child(ent)
	entityLocation = ent
	
	# Initialise default objects
	for obj in toolToObjectDict.keys():
		var objectType = toolToObjectDict.get(obj)
		
		# Initialise objects that only have 1 per level
		if objectType.onePerLevel == true:
			fixed_objects[obj] = [];
			for lvl in range(0, WorldConstants.MAX_LEVELS+1):
				fixed_objects[obj].append(objectType.new(lvl))
				levelMeshes[level].add_child(fixed_objects[obj][lvl])
				fixed_objects[obj][lvl]._genMesh()

func level_finished_loading():
	var fade = get_node("/root/Main/Fade")
	fade.unfade(1)
	emit_signal("s_levelLoaded")
	spawnPlayer()
	
	# Add weather effects
	match weather:
		WorldConstants.Weather.FOG:
			add_fog(null, null, 0.40, 0.8, 1, 60) 
		WorldConstants.Weather.HEAVY_FOG:
			add_fog(null, null, 0.27, 0.5, 1, 50) 
		WorldConstants.Weather.RAIN:
			add_fog(null, null, 0.55, 0.6, 5, 150) # Rain
			attach_to_player("res://Entities/Legacy/Weather/RainParticles.tscn")
		WorldConstants.Weather.SNOW:
			add_fog(Color(1.0, 1.0, 1.0, 1.0), Color(0.85, 0.85, 0.85, 1.0), 0.55, 0.9, 5, 200) # Snow
			attach_to_player("res://Entities/Legacy/Weather/SnowParticles.tscn")

func spawnPlayer():
	if player == null:
#		player = preload("res://Entities/Player/player.tscn").instance()
		player = preload("res://Entities/PlayerController/PlayerController.tscn").instance()
		player.set_name("Player")
		add_child(player)
#		player.get_node("camera_base/camera_rot/Camera").make_current()
		player.get_node("EyePoint/FPSCamera").make_current()
	
	if (spawnLocation != null):
		player.set_transform(spawnLocation.get_node("Pos").get_global_transform())
		player.setSpawnPoint(spawnLocation.get_node("Pos").get_global_transform())
	else:
		# Player spawns at [200, 390] in the original CY by default  
		player.set_transform(Transform(Basis(Vector3(0,0,0)), Vector3(40, 1, 76)))
		player.setSpawnPoint(Transform(Basis(Vector3(0,0,0)), Vector3(40, 1, 76)))
	
	player.reset()
	player._setup()
	
	# Setup PlayerUI
	player.get_node("PlayerGUI").setupCollectables(self.collectables)
	
	# Play tunes
	if not $MusicPlayer.playing:
		$MusicPlayer.play()
	
	#player.busy = false
	#player.pause = false

# Level Loader
func add_geometric_object(new_obj, lvl):
	levelMeshes[lvl].add_child(new_obj)
	new_obj._genMesh()
	objects.append(new_obj)

func add_entity(new_ent):
	entities.append(new_ent)
	entityLocation.add_child(new_ent)
	
	if new_ent.get_name() == "SpawnLocation":
		spawnLocation = new_ent

func add_collectable(name: String):
	if self.collectables.has(name):
		self.collectables[name] += 1
	else:
		self.collectables[name] = 1

func modify_fixed_object(mode, level, new_obj):
	if weakref(fixed_objects[mode][level]).get_ref():
		fixed_objects[mode][level].queue_free()
	
	levelMeshes[level].add_child(new_obj)
	fixed_objects[mode][level] = new_obj
	fixed_objects[mode][level]._genMesh()

func object_delete(objRef):
	if objRef != null:
		objects.erase(objRef)
		objRef.queue_free()

func clear_level():
	for lvl in levelMeshes:
		lvl.queue_free()
	
	entityLocation.queue_free()
	
	setupLevel()
	EntityManager._reset()

func get_mazeFile(gameNumber):
	var query = '{"query": "{ getLevel(gameNumber: ' + str(gameNumber) + ') { title, author, mazeFile }}"}'
	var headers : PoolStringArray
	headers.append("Content-Type: application/json")
	
	$HTTPRequest.request(WorldConstants.SERVER + "/graphql", headers, true, HTTPClient.METHOD_POST, query)
	
func load_level(gameNumber):
	get_mazeFile(gameNumber)
	self.gameNumber = gameNumber
	#$HTTPRequest.request("http://localhost:4000/getMaze.php?maze=" + str(gameNumber))

func restart_level():
	if self.gameNumber != null:
		var fade = get_node("/root/Main/Fade")
		fade.fade(0.3)
		yield(fade, "s_fade_complete")
		
		clear_level()
		get_mazeFile(self.gameNumber)

func _on_request_completed(result, response_code, headers, body):
	var response = body.get_string_from_utf8()
	
	var r = JSON.parse(response).result
	
	var obj_loader = get_node("ObjectLoader")
	obj_loader.set_theme(Vector2(0,0), 1, 1)
	obj_loader.set_music(Vector2(0,0), 2, 1)
	
	$GameManager.load_level_info({ 
		"name": r.data.getLevel.title,
		"author": r.data.getLevel.author
	})
	
	var mazeFile = r.data.getLevel.mazeFile
	var loader = get_node("/root/Gameplay/LegacyWorldLoader/Button")
	loader.loadLevel(mazeFile)
	
	var entering_ui = $EnteringUI
	entering_ui.showLevel(r.data.getLevel.title, r.data.getLevel.author)

func set_weather(weather_enum):
	self.weather = weather_enum
	
func add_fog(fog_color, bg_color, fog_depth_curve: float, light_energy: float, fog_start: int, fog_end: int):
	var water = get_parent().get_node_or_null("Environment/Water")
	if water != null:
		water.mesh.surface_get_material(0).flags_unshaded = false
	
	var light = get_parent().get_node_or_null("Environment/DirectionalLight")
	if light != null:
		light.light_energy = min(light_energy, light.light_energy)
	
	var world_env = get_parent().get_node("Environment/WorldEnvironment").environment
	world_env.background_mode = Environment.BG_COLOR_SKY
	world_env.fog_enabled = true
	world_env.fog_depth_begin = fog_start
	world_env.fog_depth_end = fog_end
	world_env.fog_depth_curve = fog_depth_curve
	
	if fog_color == null:
		world_env.fog_color = world_env.background_color
	else:
		if bg_color != null:
			world_env.background_color = bg_color
		world_env.fog_color = fog_color
	
	world_env.fog_color.a = 1.0

func attach_to_player(obj_location):
	if player != null:
		var new_obj = load(obj_location).instance()
		player.get_node("Attachments").add_child(new_obj)
	else:
		push_warning("Tried to attach object to non-existent player: " + obj_location)

func on_music_volume_change(new_volume, allow_play = true):
	if new_volume <= 0:
		$MusicPlayer.stop()
	else:
		if not $MusicPlayer.playing and allow_play:
			$MusicPlayer.play()
		var db_decrease = ((100.0 - new_volume) / 100.0) * 30.0
		$MusicPlayer.volume_db = -5.0 - (db_decrease)
