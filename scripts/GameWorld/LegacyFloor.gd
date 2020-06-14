extends Spatial
const toolType = WorldConstants.Tools.GROUND

const canPlace = false
const onePerLevel = true
const hasDefaultObject = false

const default_dict = {
	"Visible": false,
	"Points": [Vector2(0, 10), Vector2(10, 10), Vector2(10, 0), Vector2(0, 0)],
	
	"Texture": 1,
	"Colour": Color(1, 1, 1),
	"C_Texture": 1,
	"C_Colour": Color(1, 1, 1)
}

var vertices : PoolVector2Array
var level : int
var isVisible : bool

var floor_texture : int = 1
var floor_colour := Color(1, 1, 1)
var ceil_texture : int = 2
var ceil_colour := Color(1, 1, 1)

var mesh : MeshInstance
var selection_mesh : MeshInstance
var collision_mesh : StaticBody
var collision_shape : CollisionShape

func _init(lvl : int):
	mesh = MeshInstance.new()
	collision_mesh = StaticBody.new()
	collision_shape = CollisionShape.new()
	
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
	dict["Texture"] = floor_texture 
	dict["Colour"] = floor_colour
	
	return dict

const dictToObj = {
	"Texture":"floor_texture", 
	"Colour":"floor_colour",
	"Visible":"isVisible",
}

func set_property_dict(dict : Dictionary):
	for prop in dictToObj:
		set(dictToObj[prop], dict[prop])

func buildFloor() -> Mesh:
	var gen = get_node("/root/Spatial/FloorGenerator")
	return gen.generateFloorMesh(vertices, level, floor_texture, 
		floor_colour, ceil_texture, ceil_colour, HoleManager.get_holes(level))

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
