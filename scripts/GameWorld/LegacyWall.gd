extends Node

var start : Vector2
var end : Vector2

var texture : int = 4
var level : int

var max_height : float = 1.0
var min_height : float = 0.0
const max_height_list = [4, 3, 2, 1, 2, 3, 4, 4, 4, 3]
const min_height_list = [0, 0, 0, 0, 1, 2, 3, 2, 1, 1]

var mesh : MeshInstance
var selection_mesh : MeshInstance 
var collision_mesh : StaticBody
var collision_shape : CollisionShape

var meshGenObj
func _init(parent, meshGen):
	mesh = MeshInstance.new()
	collision_mesh = StaticBody.new()
	collision_shape = CollisionShape.new()
	
	add_child(mesh)
	add_child(collision_mesh)
	collision_mesh.add_child(collision_shape)
	
	meshGenObj = meshGen
	parent.add_child(self)

func get_type():
	return "wall"

func change_end_pos(pos : Vector2):
	end = pos
	_genMesh()

func change_height_value(h : int):
	max_height = max_height_list[h - 1] / 4.0
	min_height = min_height_list[h - 1] / 4.0

	_genMesh()

func change_texture(index: int):
	texture = index
	_genMesh()

func _genMesh():
	mesh.mesh = meshGenObj.buildWall(start, end, level, min_height, max_height, texture)
	collision_shape.shape = mesh.mesh.create_convex_shape()

func selectObj():
	selection_mesh = MeshInstance.new()
	selection_mesh.mesh = meshGenObj.buildWallSelectionMesh(start, end, level, min_height, max_height, 0.05)
