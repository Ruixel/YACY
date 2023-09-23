extends Node3D
const toolType = WorldConstants.Tools.GROUND

const canPlace = false
const onePerLevel = true
const hasDefaultObject = false

const default_dict = {
	"Visible": false,
	"Points": [Vector2(0, 10), Vector2(10, 10), Vector2(10, 0), Vector2(0, 0)],
	
	"Texture2D": 1,
	"Colour": Color(1, 1, 1),
	"C_Texture": 1,
	"C_Colour": Color(1, 1, 1)
}

var vertices : PackedVector2Array
var level : int
var isVisible : bool

var floor_texture : int = 1
var floor_colour := Color(1, 1, 1)
var ceil_texture : int = 2
var ceil_colour := Color(1, 1, 1)

var mesh : MeshInstance3D
var selection_mesh : MeshInstance3D
var collision_mesh : StaticBody3D
var collision_shape : CollisionShape3D

func _init(lvl : int):
	self.name = "Floor"
	mesh = MeshInstance3D.new()
	collision_mesh = StaticBody3D.new()
	collision_shape = CollisionShape3D.new()
	
	#vertices.insert(0, Vector2(0, 80))
	#vertices.insert(1, Vector2(80, 80))
	#vertices.insert(2, Vector2(80, 0))
	#vertices.insert(3, Vector2(0, 0))
	
	vertices.insert(0, Vector2(0, 10))
	vertices.insert(1, Vector2(10, 10))
	vertices.insert(2, Vector2(10, 0))
	vertices.insert(3, Vector2(0, 0))
	
	level = lvl 
	isVisible = false
	
	add_child(mesh)
	add_child(collision_mesh)
	collision_mesh.add_child(collision_shape)

func get_level():
	return level

func change_texture(index: int):
	floor_texture = index

func change_visible(vis: bool):
	isVisible = vis

func change_colour(newColour : Color):
	floor_colour = newColour

func change_vertex(newVertexInfo : Array):
	vertices[newVertexInfo[1]] = newVertexInfo[0]

func _genMesh():
	if isVisible:
		mesh.mesh = buildFloor()
		collision_shape.shape = mesh.mesh.create_trimesh_shape()
	else:
		mesh.mesh = null
		collision_shape.shape = null

func selectObj():
	pass

func get_property_dict() -> Dictionary:
	var dict : Dictionary = {}
	dict["Visible"] = isVisible
	dict["Texture2D"] = floor_texture 
	dict["Colour"] = floor_colour
	
	return dict

const dictToObj = {
	"Texture2D":"floor_texture", 
	"Colour":"floor_colour",
	"Visible":"isVisible",
}

func set_property_dict(dict : Dictionary):
	for prop in dictToObj:
		set(dictToObj[prop], dict[prop])

func buildFloor() -> Mesh:
	var gen = get_node_or_null("/root/Main/FloorGenerator")
	if gen == null:
		gen = get_node("/root/Node3D/FloorGenerator") # Change for editor, TODO: Fix

	# Set collision layers
	var isOpaque = not WorldTextures.textures[self.floor_texture].isTransparent()
	collision_mesh.set_collision_layer_value(WorldConstants.GEOMETRY_COLLISION_BIT, true)
	collision_mesh.set_collision_layer_value(WorldConstants.OPAQUE_COLLISION_BIT, true)

	var holes = HoleManager.get_holes(level)
	return gen.GenerateFloorMesh(vertices, level, floor_texture, 
		floor_colour, ceil_texture, ceil_colour, holes)


func JSON_serialise() -> Dictionary:
	# Only add values that differ from the default
	var dict = get_property_dict()
	for k in dict.keys():
		if dict[k] == default_dict[k]:
			dict.erase(k)
	
	# Only add vertices to the serialiser if they are different from the default
	var no_change_in_vertices = true
	for vtx in range(0, vertices.size()):
		if vertices[vtx] != default_dict["Points"][vtx]:
			no_change_in_vertices = false
	
	if not no_change_in_vertices:
		dict["Points"] = vertices
	
	# Colours should be serialised into a smaller format
	if dict.has("Colour"):
		dict["Colour"] = dict["Colour"].to_html()
	if dict.has("C_Colour"):
		dict["C_Colour"] = dict["C_Colour"].to_html()
	
	return dict

func JSON_deserialise(dict):
	for k in dict.keys():
		if dictToObj.has(k):
			var property = self.get(dictToObj.get(k)) 
			self.set(dictToObj.get(k), Utils.json2obj(dict[k], property))
	
	if dict.has("Points"):
		vertices = Utils.json2obj(dict["Points"], vertices)
