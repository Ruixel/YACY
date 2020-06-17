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

var level : int = 1
var levelMeshes : Array 
var entityLocation

var player = null
var spawnLocation = null

const toolToObjectDict = {
	WorldConstants.Tools.WALL: Wall,
	WorldConstants.Tools.PLATFORM: Plat,
	WorldConstants.Tools.PILLAR: Pillar,
	WorldConstants.Tools.RAMP: Ramp,
	WorldConstants.Tools.GROUND: Floor,
	WorldConstants.Tools.HOLE: Hole
}

func _ready():
	$HTTPRequest.connect("request_completed", self, "_on_request_completed")
	
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
	get_parent().get_node("Player")

func spawnPlayer():
	if player == null:
		player = preload("res://Entities/Player/player.tscn").instance()
		player.set_name("Player")
		add_child(player)
		player.get_node("camera_base/camera_rot/Camera").make_current()
	
	if (spawnLocation != null):
		player.set_transform(spawnLocation.get_node("Pos").get_global_transform())
	else:
		# Player spawns at [200, 390] in the original CY by default  
		player.set_translation(Vector3(40, 5, 78))
		

# Level Loader
func add_geometric_object(new_obj, lvl):
	levelMeshes[lvl].add_child(new_obj)
	new_obj._genMesh()
	objects.append(new_obj)

func add_entity(new_ent):
	entities.append(new_ent)
	entityLocation.add_child(new_ent)
	
	if new_ent.get_name() == "SpawnLocation":
		print("hey guys")
		spawnLocation = new_ent

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

func load_level(gameNumber):
	$HTTPRequest.request("http://localhost/getMaze.php?maze=" + str(gameNumber))

func _on_request_completed(result, response_code, headers, body):
	var response = body.get_string_from_utf8()
	var loader = get_node("/root/Spatial/LegacyWorldLoader")
	loader.loadLevelFromString(response)
	spawnPlayer()
