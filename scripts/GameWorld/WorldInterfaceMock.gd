extends Spatial
onready var EditorGUI = get_node("../GUI")
onready var PropertyGUI = EditorGUI.get_node("ObjProperties")
onready var Cursor = get_node("../3DCursor")

const Wall = preload("res://scripts/GameWorld/LegacyWall.gd")
const Plat = preload("res://scripts/GameWorld/LegacyPlatform.gd")
const Pillar = preload("res://scripts/GameWorld/Pillar.gd")
const Ramp = preload("res://scripts/GameWorld/LegacyRamp.gd")

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
var objects : Array = []
var default_objs : Dictionary

var level : int = 1
var levelMeshes : Array 
var showUpperLevels : bool = true

const toolToObjectDict = {
	WorldConstants.Tools.WALL: Wall,
	WorldConstants.Tools.PLATFORM: Plat,
	WorldConstants.Tools.PILLAR: Pillar,
	WorldConstants.Tools.RAMP: Ramp
}

# Object functions
func obj_create(pos : Vector2):
	var objectType = toolToObjectDict.get(mode)
	var new_obj = objectType.new(levelMeshes[level], pos, level)
	objects.append(new_obj)
	
	# Select
	deselect()
	selection = new_obj
	
	# Give default properties
	new_obj.set_property_dict(default_objs[new_obj.toolType].get_property_dict())
	
	# Apply 
	new_obj._genMesh()
	select_update_mesh()
	
	update_property_gui(new_obj)

func select_obj_from_raycast(ray_origin : Vector3, ray_direction : Vector3):
	var space_state = get_world().direct_space_state
	var result = space_state.intersect_ray(ray_origin, (ray_direction*50) + ray_origin)
	
	if result.empty() == false:
		selection = objects[objects.find(result.collider.get_parent())]
		mode = selection.toolType
		select_update_mesh()
		update_property_gui(selection)
	else:
		mode = WorldConstants.Tools.NOTHING
		PropertyGUI.update_properties({}, mode)

func deselect():
	if (selection != null) and (selection.selection_mesh != null):
		selection.selection_mesh.queue_free()
		selection.selection_mesh = null
	
	selection = null

func create_wall(disp : Vector2, start : Vector2, texColour, height : int, level: int):
	start = start / 5.0
	disp = disp / 5.0
	var end : Vector2 = start + disp
	
	var new_wall = Wall.new(levelMeshes[level], start, level)
	new_wall.end = end
	if typeof(texColour) == TYPE_INT:
		new_wall.texture = WorldTextures.getWallTexture(texColour)
	else:
		new_wall.texture = WorldTextures.TextureID.COLOR
		new_wall.colour = texColour
	new_wall.change_height_value(height)
	objects.append(new_wall)
	
	new_wall._genMesh()

func create_triwall(pos : Vector2, is_bottom : int, texColour, direction : int, level: int):
	pos = pos / 5.0
	
	var new_triwall = Wall.new(levelMeshes[level], pos, level)
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
	objects.append(new_triwall)
	
	new_triwall._genMesh()

func create_plat(pos : Vector2, size : int, texColour, height : int, shape, level: int):
	pos = pos / 5.0
	
	var new_plat = Plat.new(levelMeshes[level], pos, level)
	new_plat.size = size
	new_plat.platShape = shape
	if typeof(texColour) == TYPE_INT:
		new_plat.texture = WorldTextures.getPlatTexture(texColour)
	else:
		new_plat.texture = WorldTextures.TextureID.COLOR
		new_plat.colour = texColour
	new_plat.change_height_value(height)
	objects.append(new_plat)
	
	new_plat._genMesh()

func create_pillar(pos : Vector2, isDiagonal : int, size : int, texColour, height : int, level: int):
	pos = pos / 5.0
	
	var new_pillar = Pillar.new(levelMeshes[level], pos, level)
	new_pillar.size = size
	if typeof(texColour) == TYPE_INT:
		new_pillar.texture = WorldTextures.getWallTexture(texColour)
	else:
		new_pillar.texture = WorldTextures.TextureID.COLOR
		new_pillar.colour = texColour
	new_pillar.change_height_value(height)
	new_pillar.diagonal = bool(isDiagonal - 1)
	objects.append(new_pillar)
	
	new_pillar._genMesh()

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
	
	var new_ramp = Ramp.new(levelMeshes[level], start, level)
	new_ramp.end = end
	if typeof(texColour) == TYPE_INT:
		new_ramp.texture = WorldTextures.getPlatTexture(texColour)
	else:
		new_ramp.texture = WorldTextures.TextureID.COLOR
		new_ramp.colour = texColour
		
	objects.append(new_ramp)
	new_ramp._genMesh()

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
		
		objects.erase(objRef)
		objRef.queue_free()

func selection_set_default():
	if selection != null:
		default_objs[selection.toolType].set_property_dict(selection.get_property_dict())
		
	# If it uses a prototype then update it
	if default_objs[mode].has_method("genPrototypeMesh"):
		emit_signal("update_prototype")


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
			
		# If it doesn't match anything then free and return nothing
		_:
			prototype.queue_free()
			prototype = null
			
	
	return [prototype, prototype_size]

# Signals
func _ready(): 
	# Connect GUI signals
	EditorGUI.get_node("MapLevel").connect("s_changeLevel", self, "on_level_change")
	EditorGUI.get_node("ObjectList").connect("s_changeTool", self, "on_tool_change")
	EditorGUI.get_node("Misc").connect("s_toggleUpperFloors", self, "on_toggle_upper_levels")
	
	# Connect property change signals
	var PropertyGUI = EditorGUI.get_node("ObjProperties")
	PropertyGUI.connect("s_changeTexture", self, "property_texture")
	PropertyGUI.connect("s_changeColour", self, "property_colour")
	PropertyGUI.connect("s_changeSize", self, "property_size")
	PropertyGUI.connect("s_changeWallShape", self, "property_wallShape")
	PropertyGUI.connect("s_changeDiagonal", self, "property_diagonal")
	PropertyGUI.connect("s_changePlatShape", self, "property_platShape")
	
	PropertyGUI.connect("s_deleteObject", self, "selection_delete")
	PropertyGUI.connect("s_setDefault", self, "selection_set_default")
	
	# Initialise level meshes
	for lvl in range(0, 21):
		var n = Spatial.new()
		n.set_name("Level" + str(lvl))
		
		add_child(n)
		levelMeshes.append(n)
	
	# Initialise default objects
	for obj in toolToObjectDict.keys():
		var objectType = toolToObjectDict.get(obj)
		default_objs[obj] = objectType.new(self, Vector2(0,0), 0)

func on_tool_change(type) -> void:
	mode = type
	deselect()
	
	if mode == WorldConstants.Tools.NOTHING:
		PropertyGUI.update_properties({}, mode)
	else:
		update_property_gui(default_objs[mode])

func on_level_change(new_level):
	level = new_level
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
	for lvl in range(0,21):
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

func property_height_value(key : int):
	if selection != null and selection.has_method("change_height_value"):
		selection.change_height_value(key)
		selection._genMesh()
		select_update_mesh()
	else:
		if mode != WorldConstants.Tools.NOTHING and default_objs[mode].has_method("genPrototypeMesh"):
			default_objs[mode].change_height_value(key)
			emit_signal("update_prototype")

func property_texture(index : int):
	if selection != null and selection.has_method("change_texture"):
		selection.change_texture(index)
		selection._genMesh()
		select_update_mesh()
	else:
		if mode != WorldConstants.Tools.NOTHING:
			default_objs[mode].change_texture(index)
			if default_objs[mode].has_method("genPrototypeMesh"):
				emit_signal("update_prototype")

func property_wallShape(shape : int):
	if selection != null and selection.has_method("change_wallShape"):
		selection.change_wallShape(shape)
		selection._genMesh()
		select_update_mesh()
	else:
		if mode != WorldConstants.Tools.NOTHING:
			default_objs[mode].change_wallShape(shape)
			if default_objs[mode].has_method("genPrototypeMesh"):
				emit_signal("update_prototype")

func property_platShape(shape : int):
	if selection != null and selection.has_method("change_platShape"):
		selection.change_platShape(shape)
		selection._genMesh()
		select_update_mesh()
	else:
		if mode != WorldConstants.Tools.NOTHING:
			default_objs[mode].change_platShape(shape)
			if default_objs[mode].has_method("genPrototypeMesh"):
				emit_signal("update_prototype")

func property_size(size : int):
	if selection != null and selection.has_method("change_size"):
		selection.change_size(size)
		selection._genMesh()
		select_update_mesh()
	else:
		if mode != WorldConstants.Tools.NOTHING and default_objs[mode].has_method("change_size"):
			default_objs[mode].change_size(size)
			if default_objs[mode].has_method("genPrototypeMesh"):
				emit_signal("update_prototype")

func property_colour(colour : Color):
	if selection != null and selection.has_method("change_colour"):
		selection.change_colour(colour)
		selection._genMesh()
		select_update_mesh()
	else:
		if mode != WorldConstants.Tools.NOTHING and default_objs[mode].has_method("genPrototypeMesh"):
			default_objs[mode].change_colour(colour)
			emit_signal("update_prototype")

func property_diagonal(isSet : bool):
	if selection != null and selection.has_method("change_diagonal"):
		selection.change_diagonal(isSet)
		selection._genMesh()
		select_update_mesh()
	else:
		if mode != WorldConstants.Tools.NOTHING and default_objs[mode].has_method("genPrototypeMesh"):
			default_objs[mode].change_diagonal(isSet)
			emit_signal("update_prototype")