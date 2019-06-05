extends Spatial

onready var wallGenerator = get_node("ObjGenFunc/Wall")
onready var platGenerator = get_node("ObjGenFunc/Platform")

var selection : Node # Selected object (To be modified)

# WorldInterfaceMock, 2019
# This is a mock of the world interface, in which GDScript can interact with the world
# This will be ported to C++ as the need for an optimised world mesh generation becomes important

# Code Sections:
# Selection - Preview while building (mouse down)
# Prototype - Preview before building (mouse hover), is transparent

# Selection functions
func selection_create():
	selection = MeshInstance.new()
	add_child(selection)
	selection.set_owner(self)

func selection_delete():
	selection.queue_free()
	selection = null

func selection_buildWall(start : Vector2, end : Vector2):
	wallGenerator.buildWall(start, end, selection)

func selection_buildPlat(pos : Vector2):
	platGenerator.buildPlatform(pos, selection, false)

# Prototype functions
func get_prototype(type) -> MeshInstance:
	# Create instance
	var prototype = MeshInstance.new()
	prototype.set_name("Prot")
	add_child(prototype)
	prototype.set_owner(self)
	
	match type:
		WorldConstants.Tools.PLATFORM:
			platGenerator.buildPlatform(Vector2(0,0), prototype, true)
			
		# If it doesn't match anything then free and return nothing
		_:
			prototype.queue_free()
			prototype = null
	
	return prototype
	