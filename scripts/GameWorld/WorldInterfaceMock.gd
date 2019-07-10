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
	
	var min_height : float = 0.0
	var max_height : float = 1.0
	
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
	
	func change_height_value(h : int):
		match(h):
			2:  
				max_height = 3 / 4.0
				min_height = 0 / 4.0
			3:
				max_height = 2 / 4.0
				min_height = 0 / 4.0
			4:  
				max_height = 1 / 4.0
				min_height = 0 / 4.0
			5:  
				max_height = 2 / 4.0
				min_height = 1 / 4.0
			6:  
				max_height = 3/ 4.0
				min_height = 2 / 4.0
			7:  
				max_height = 4 / 4.0
				min_height = 3 / 4.0
			8:  
				max_height = 4 / 4.0
				min_height = 2 / 4.0
			9:  
				max_height = 4 / 4.0
				min_height = 1 / 4.0
			0:  
				max_height = 3 / 4.0
				min_height = 1 / 4.0
			_:  
				max_height = 4 / 4.0
				min_height = 0 / 4.0

		_genMesh()
	
	func _genMesh():
		mesh.mesh = meshGenObj.buildWall(start, end, level, min_height, max_height)

class Plat:
	var pos : Vector2
	
	var texture : int = 1
	var level : int
	
	var height_offset : float = 0.0
	
	var mesh : MeshInstance
	var meshGenObj
	func _init(meshGen):
		mesh = MeshInstance.new()
		meshGenObj = meshGen
	
	func change_height_value(h : int):
		match(h):
			2:  height_offset = 1 / 4.0
			3:  height_offset = 2 / 4.0
			4:  height_offset = 3 / 4.0
			_:  height_offset = 0 / 4.0
		
		_genMesh()
	
	func get_type():
		return "plat"
		
	func _genMesh():
		mesh.mesh = meshGenObj.buildPlatform(pos, level, height_offset, false)

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
			prototype.mesh = platGenerator.buildPlatform(Vector2(0,0), level, 0, true)
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

func property_height_value(key : int):
	selection.change_height_value(key)