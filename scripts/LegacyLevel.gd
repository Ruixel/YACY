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
	# Initialise level meshes
	for lvl in range(0, 21):
		var n = Spatial.new()
		n.set_name("Level" + str(lvl))
		
		add_child(n)
		levelMeshes.append(n)
	
	# Initialise default objects
	for obj in toolToObjectDict.keys():
		var objectType = toolToObjectDict.get(obj)
		if objectType.canPlace == true:
			default_objs[obj] = objectType.new(Vector2(0,0), 0)
		
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
	var player = preload("res://Entities/Player/player.tscn").instance()
	
	add_child(player)
	if (spawnLocation != null):
		player.set_transform(spawnLocation.get_node("Pos").get_global_transform())
	else:
		player.set_translation(Vector3(50, 50, 50))
		
	player.get_node("camera_base/camera_rot/Camera").make_current()

# Level Loader
func add_geometric_object(new_obj, lvl):
	levelMeshes[lvl].add_child(new_obj)
	new_obj._genMesh()
	objects.append(new_obj)

func add_entity(new_ent):
	entities.append(new_ent)
	add_child(new_ent)
	
	if new_ent.get_name() == "SpawnLocation":
		print("hey guys")
		spawnLocation = new_ent

func modify_fixed_object(mode, level, new_obj):
	fixed_objects[mode][level].queue_free()
	
	levelMeshes[level].add_child(new_obj)
	fixed_objects[mode][level] = new_obj
	fixed_objects[mode][level]._genMesh()
