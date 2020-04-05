extends Spatial

var objects : Array = []
var entities : Array = []
var default_objs : Dictionary

var level : int = 1
var levelMeshes : Array 

var spawnLocation = null

func _ready():
	# Initialise level meshes
	for lvl in range(0, 21):
		var n = Spatial.new()
		n.set_name("Level" + str(lvl))
		
		add_child(n)
		levelMeshes.append(n)

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
