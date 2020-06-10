extends Spatial
const toolType = WorldConstants.Tools.GROUND

const canPlace = false
const onePerLevel = true
const hasDefaultObject = false

var vertices : Array
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

func set_property_dict(dict : Dictionary):
	isVisible = dict["Visible"]
	floor_texture = dict["Texture"]
	floor_colour = dict["Colour"]

func buildFloor() -> Mesh:
	var gen = get_node("/root/Spatial/FloorGenerator")
	return gen.generateFloorMesh(vertices, level, floor_texture, 
		floor_colour, ceil_texture, ceil_colour, HoleManager.get_holes(level))
