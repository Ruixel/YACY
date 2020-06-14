extends Spatial
onready var EditorGUI = get_node("../GUI")
onready var PropertyGUI = EditorGUI.get_node("ObjProperties")
onready var Cursor = get_node("../3DCursor")

const Wall = preload("res://scripts/GameWorld/LegacyWall.gd")
const Plat = preload("res://scripts/GameWorld/LegacyPlatform.gd")
const Pillar = preload("res://scripts/GameWorld/Pillar.gd")
const Ramp = preload("res://scripts/GameWorld/LegacyRamp.gd")
const Floor = preload("res://scripts/GameWorld/LegacyFloor.gd")
const Hole = preload("res://scripts/GameWorld/LegacyHole.gd")

var selection # Selected object (To be modified)

signal change_selection
signal update_prototype

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

# All Objects
# Each object is stored in its own array as well as "All"
var objects : Array = []

# For objects that have the one per level constraint
var fixed_objects: Dictionary

# Reference to what the "Set to Default" properties were
var default_objs : Dictionary

var level : int = 1
var levelMeshes : Array 
var showUpperLevels : bool = true

const toolToObjectDict = {
	WorldConstants.Tools.WALL: Wall,
	WorldConstants.Tools.PLATFORM: Plat,
	WorldConstants.Tools.PILLAR: Pillar,
	WorldConstants.Tools.RAMP: Ramp,
	WorldConstants.Tools.GROUND: Floor,
	WorldConstants.Tools.HOLE: Hole
}

# Object functions
func obj_create(pos : Vector2, lvl : int = -1):
	if lvl == -1:
		lvl = level
	
	var objectType = toolToObjectDict.get(mode)
	var new_obj = objectType.new(pos, lvl)
	levelMeshes[lvl].add_child(new_obj)
	objects[mode].append(new_obj)
	objects[WorldConstants.Tools.ALL].append(new_obj)
	
	# Check for validity
	# yikes, only for holes
	if new_obj.has_method("is_valid"):
		var valid = new_obj.call("is_valid", fixed_objects[WorldConstants.Tools.GROUND][lvl])
		if valid == false:
			object_delete(new_obj)
			return
		else:
			fixed_objects[WorldConstants.Tools.GROUND][lvl]._genMesh()
	
	# Select
	deselect()
	selection = new_obj
	
	# Give default properties
	new_obj.set_property_dict(default_objs[new_obj.toolType].get_property_dict())
	
	# Apply 
	new_obj._genMesh()
	select_update_mesh()
	
	update_property_gui(new_obj)
	emit_signal("change_selection", selection)
	
	return new_obj

func select_obj_from_raycast(ray_origin : Vector3, ray_direction : Vector3):
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(ray_origin, (ray_direction*50) + ray_origin)
	var allObjects = objects[WorldConstants.Tools.ALL]
	
	if result.empty() == false:
		if allObjects.find(result.collider.get_parent()) != -1:
			selection = allObjects[allObjects.find(result.collider.get_parent())]
			mode = selection.toolType
			select_update_mesh()
			update_property_gui(selection)
			emit_signal("change_selection", selection)
	else:
		mode = WorldConstants.Tools.NOTHING
		PropertyGUI.update_properties({}, mode)

func deselect():
	if (selection != null) and (selection.selection_mesh != null):
		selection.selection_mesh.queue_free()
		selection.selection_mesh = null
	
	selection = null
	emit_signal("change_selection", selection)

func select_update_mesh():
	if selection.selection_mesh != null:
		selection.selection_mesh.queue_free()
		selection.selection_mesh = null
	selection.selectObj()
	add_child(selection.selection_mesh)

func selection_delete():
	if selection != null:
		var objRef = selection
		deselect()
		
		objects[objRef.toolType].erase(objRef)
		objects[WorldConstants.Tools.ALL].erase(objRef)
		objRef.queue_free()

func object_delete(objRef):
	if objRef != null:
		objects[objRef.toolType].erase(objRef)
		objects[WorldConstants.Tools.ALL].erase(objRef)
		objRef.queue_free()

func selection_set_default():
	if selection != null:
		default_objs[selection.toolType].set_property_dict(selection.get_property_dict())
		
	# If it uses a prototype then update it
	if default_objs[mode].has_method("genPrototypeMesh"):
		emit_signal("update_prototype")

func get_selection():
	return selection

# Level Loader
func add_geometric_object(new_obj, level):
	levelMeshes[level].add_child(new_obj)
	new_obj._genMesh()
	objects[new_obj.toolType].append(new_obj)
	objects[WorldConstants.Tools.ALL].append(new_obj)

func modify_fixed_object(mode, level, new_obj):
	fixed_objects[mode][level].queue_free()
	
	levelMeshes[level].add_child(new_obj)
	fixed_objects[mode][level] = new_obj
	fixed_objects[mode][level]._genMesh()

func add_entity(new_entity):
	pass

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
			prototype.mesh = default_objs[WorldConstants.Tools.PLATFORM].genPrototypeMesh(level)
			prototype_size = Vector2(2, 2)
		WorldConstants.Tools.PILLAR:
			prototype.mesh = default_objs[WorldConstants.Tools.PILLAR].genPrototypeMesh(level)
			prototype_size = Vector2(2, 2)
		WorldConstants.Tools.HOLE:
			prototype.mesh = default_objs[WorldConstants.Tools.HOLE].genPrototypeMesh(level)
			prototype_size = Vector2(2, 2)
		
		# If it doesn't match anything then free and return nothing
		_:
			prototype.queue_free()
			prototype = null
			
	
	return [prototype, prototype_size]

func remesh_world():
	for objType in toolToObjectDict.keys():
		if toolToObjectDict.get(objType).onePerLevel == true:
			for lvl in range(0, WorldConstants.MAX_LEVELS + 1):
				fixed_objects[objType][lvl]._genMesh()
		else:
			for obj in objects[objType]:
				obj._genMesh()

# Signals
func _ready(): 
	# Connect GUI signals
	EditorGUI.get_node("MapLevel").connect("s_changeLevel", self, "on_level_change")
	EditorGUI.get_node("ObjectList").connect("s_changeTool", self, "on_tool_change")
	EditorGUI.get_node("Misc").connect("s_toggleUpperFloors", self, "on_toggle_upper_levels")
	EditorGUI.get_node("Misc").connect("s_saveFile", self, "on_save_file_json")
	EditorGUI.get_node("Misc").connect("s_loadFile", self, "on_load_file_json")
	
	# Connect property change signals
	var PropertyGUI = EditorGUI.get_node("ObjProperties")
	PropertyGUI.connect("s_changeTexture", self, "property_texture")
	PropertyGUI.connect("s_changeColour", self, "property_colour")
	PropertyGUI.connect("s_changeSize", self, "property_size")
	PropertyGUI.connect("s_changeWallShape", self, "property_wallShape")
	PropertyGUI.connect("s_changeBoolean", self, "property_boolean")
	PropertyGUI.connect("s_changePlatShape", self, "property_platShape")
	
	PropertyGUI.connect("s_deleteObject", self, "selection_delete")
	PropertyGUI.connect("s_setDefault", self, "selection_set_default")
	
	# Initialise level meshes
	for lvl in range(0, WorldConstants.MAX_LEVELS+1):
		var n = Spatial.new()
		n.set_name("Level" + str(lvl))
		
		add_child(n)
		levelMeshes.append(n)
	
	for objType in WorldConstants.Tools:
		objects.insert(objType, [])
	
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
			
			fixed_objects[obj][1].isVisible = true
			fixed_objects[obj][1]._genMesh()
	
	$JSONSerialiser.load_default_objects(default_objs)

func on_tool_change(type) -> void:
	mode = type
	deselect()
	
	if mode == WorldConstants.Tools.NOTHING:
		PropertyGUI.update_properties({}, mode)
	elif toolToObjectDict.get(mode).onePerLevel == true:
		selection = fixed_objects[mode][level]
		update_property_gui(selection)
		emit_signal("change_selection", selection)
	elif toolToObjectDict.get(mode).canPlace == true:
		update_property_gui(default_objs[mode])

func on_level_change(new_level):
	level = new_level
	if mode != WorldConstants.Tools.NOTHING and toolToObjectDict.get(mode).onePerLevel == true:
		selection = fixed_objects[mode][level]
		update_property_gui(selection)
		emit_signal("change_selection", selection)
	
	if not showUpperLevels:
		hide_upper_levels(new_level)

func on_toggle_upper_levels(toggle : bool):
	showUpperLevels = toggle
	if showUpperLevels:
		for lvl in levelMeshes:
			lvl.set_translation(Vector3(0,0,0))
	else:
		hide_upper_levels(level)

func hide_upper_levels(currentLevel):
	# Hide objects by displacing them, this means that they wont affect the raycast selection
	for lvl in range(0,WorldConstants.MAX_LEVELS+1):
		if lvl <= currentLevel:
			levelMeshes[lvl].set_translation(Vector3(0,0,0))
		else:
			levelMeshes[lvl].set_translation(Vector3(5000000,5000000,5000000))
	
	if selection != null and selection.has_method("get_level"):
		if selection.get_level() > currentLevel:
			deselect()

func update_property_gui(obj):
	if obj != null and obj.has_method("get_property_dict"):
		PropertyGUI.update_properties(obj.get_property_dict(), obj.toolType)

func property_end_vector(endVec : Vector2):
	if selection != null and selection.has_method("change_end_pos"):
		selection.change_end_pos(endVec)
		selection._genMesh()
		select_update_mesh()

func set_property(method_name : String, value):
	if selection != null and selection.has_method(method_name):
		selection.call(method_name, value)
		selection._genMesh()
		select_update_mesh()
	else:
		if mode != WorldConstants.Tools.NOTHING and toolToObjectDict[mode].hasDefaultObject == true:
			if default_objs[mode].has_method("genPrototypeMesh"):
				if default_objs[mode].has_method(method_name):
					default_objs[mode].call(method_name, value)
					emit_signal("update_prototype")

func property_height_value(key : int):
	set_property("change_height_value", key)

func property_texture(index : int):
	set_property("change_texture", index)

func property_wallShape(shape : int):
	set_property("change_wallShape", shape)

func property_platShape(shape : int):
	set_property("change_platShape", shape)

func property_size(size : int):
	set_property("change_size", size)

func property_colour(colour : Color):
	set_property("change_colour", colour)

func property_boolean(propertyName : String, isSet : bool):
	set_property("change_" + propertyName.to_lower(), isSet)

func property_vertex(vertexInfo : Array):
	set_property("change_vertex", vertexInfo)
	
	# Update holes
	# TODO: Is there a more generic/optimised way to do this?
	for hole in objects[WorldConstants.Tools.HOLE]:
		if hole.level == level:
			if not hole.is_valid(fixed_objects[WorldConstants.Tools.GROUND][level]):
				HoleManager.remove_hole(hole, level)
				call_deferred("object_delete", hole)

func on_save_file_json():
	$JSONSerialiser.save_file("testfile.cy", objects, fixed_objects, toolToObjectDict)

func on_load_file_json():
	$JSONSerialiser.load_file("testfile.cy", objects, fixed_objects, toolToObjectDict)
