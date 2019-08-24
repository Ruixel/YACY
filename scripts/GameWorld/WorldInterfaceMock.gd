extends Spatial
onready var EditorGUI = get_node("../GUI")
onready var PropertyGUI = EditorGUI.get_node("ObjProperties")
onready var Cursor = get_node("../3DCursor")

onready var wallGenerator = get_node("ObjGenFunc/Wall")
onready var platGenerator = get_node("ObjGenFunc/Platform")

const Wall = preload("res://scripts/GameWorld/LegacyWall.gd")
const Plat = preload("res://scripts/GameWorld/LegacyPlatform.gd")

var selection # Selected object (To be modified)

signal change_selection

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

var default_wall : Wall

const toolToObjectDict = {
	WorldConstants.Tools.WALL: Wall,
	WorldConstants.Tools.PLATFORM: Plat
}

# Object functions
func obj_create(pos : Vector2):
	var objectType = toolToObjectDict.get(mode)
	var new_obj = objectType.new(self, pos, level)
	objects.append(new_obj)
	
	# Select
	deselect()
	selection = new_obj
	
	# Apply 
	new_obj._genMesh()
	select_update_mesh()
	
	update_property_gui(new_obj)

func selection_delete():
	selection.queue_free()
	selection = null

func select_obj_from_raycast(ray_origin : Vector3, ray_direction : Vector3):
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(ray_origin, (ray_direction*50) + ray_origin)
	
	if result.empty() == false:
		selection = objects[objects.find(result.collider.get_parent())]
		select_update_mesh()
		update_property_gui(selection)

func deselect():
	if (selection != null) and (selection.selection_mesh != null):
		selection.selection_mesh.queue_free()
		selection.selection_mesh = null
	
	selection = null

func select_update_mesh():
	if (selection.selection_mesh != null):
		selection.selection_mesh.queue_free()
		selection.selection_mesh = null
	selection.selectObj()
	add_child(selection.selection_mesh)

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
			prototype.mesh = Plat.buildPlatform(Vector2(0,0), level, 0, 0, true)
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
	
	var PropertyGUI = EditorGUI.get_node("ObjProperties")
	PropertyGUI.connect("s_changeTexture", self, "property_texture")

func on_tool_change(type) -> void:
	mode = type

func on_level_change(new_level):
	level = new_level

func update_property_gui(obj):
	if obj != null and obj.has_method("get_property_dict"):
		PropertyGUI.update_properties(obj.get_property_dict(), obj.toolType)

func property_end_vector(endVec : Vector2):
	if selection != null and selection.has_method("change_end_pos"):
		selection.change_end_pos(endVec)
		select_update_mesh()

func property_height_value(key : int):
	if selection != null and selection.has_method("change_height_value"):
		selection.change_height_value(key)
		select_update_mesh()

func property_texture(index : int):
	if selection != null and selection.has_method("change_texture"):
		selection.change_texture(index)
		select_update_mesh()