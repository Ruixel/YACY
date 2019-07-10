extends Spatial
onready var EditorGUI = get_node("../GUI")
onready var Cursor = get_node("../3DCursor")

onready var wallGenerator = get_node("ObjGenFunc/Wall")
onready var platGenerator = get_node("ObjGenFunc/Platform")

var selection # Selected object (To be modified)

# WorldInterfaceMock, 2019
# This is a mock of the world interface, in which GDScript can interact with the world
# This will be ported to C++ as the need for an optimised world mesh generation becomes important

# Code Sections:
# Variables
# Selection - Preview while building (mouse down)
# Prototype - Preview before building (mouse hover), is transparent
# Signals 

# Vars
var mode = WorldConstants.Tools.WALL
var level : int = 1
var objects : Array = []

# Geometry
class Wall:
	var start : Vector2
	var end : Vector2
	
	var texture : int = 4
	var level : int
	
	var mesh : MeshInstance
	var meshGenObj
	func _init(meshGen):
		mesh = MeshInstance.new()
		meshGenObj = meshGen
	
	func get_type():
		return "wall"
	
	func change_end_pos(pos : Vector2):
		end = pos
		_genMesh()
		
	func _genMesh():
		mesh.mesh = meshGenObj.buildWall(start, end, level)

class Plat:
	var pos : Vector2
	
	var texture : int = 1
	var level : int
	
	var mesh : MeshInstance
	var meshGenObj
	func _init(meshGen):
		mesh = MeshInstance.new()
		meshGenObj = meshGen
	
	func get_type():
		return "wall"
		
	func _genMesh():
		mesh.mesh = meshGenObj.buildPlatform(pos, level, false)

var default_wall : Wall

# Object functions
func obj_create(pos : Vector2):
	if mode == WorldConstants.Tools.WALL:
		var new_wall = Wall.new(wallGenerator)
		objects.append(new_wall)
		selection = new_wall
		
		# Apply default properties
		new_wall.start = pos
		new_wall.level = level
		
		# Apply 
		add_child(new_wall.mesh)
		new_wall.mesh.set_owner(self)
		
	elif mode == WorldConstants.Tools.PLATFORM:
		var new_plat = Plat.new(platGenerator)
		objects.append(new_plat)
		selection = new_plat
		
		# Apply default properties
		new_plat.pos = pos
		new_plat.level = level
		
		# Apply 
		add_child(new_plat.mesh)
		new_plat.mesh.set_owner(self)
		new_plat._genMesh()

func selection_delete():
	selection.queue_free()
	selection = null

# Prototype functions
func get_prototype(type) -> Array:
	var prototype_size = Vector2()
	
	# Create instance
	var prototype = MeshInstance.new()
	prototype.set_name("Prot")
	add_child(prototype)
	prototype.set_owner(self)
	
	match type:
		WorldConstants.Tools.PLATFORM:
			prototype.mesh = platGenerator.buildPlatform(Vector2(0,0), level, true)
			prototype_size = Vector2(2, 2)
			
		# If it doesn't match anything then free and return nothing
		_:
			prototype.queue_free()
			prototype = null
	
	return [prototype, prototype_size]

# Signals
func _ready(): # Connect signals
	EditorGUI.get_node("MapLevel").connect("s_changeLevel", self, "on_level_change")
	EditorGUI.get_node("ObjectList").connect("s_changeTool", self, "on_tool_change")

func on_tool_change(type) -> void:
	mode = type

func on_level_change(new_level):
	level = new_level
	
func property_end_vector(endVec : Vector2):
	selection.change_end_pos(endVec)