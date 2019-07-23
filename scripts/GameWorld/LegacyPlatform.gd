extends Node

var pos : Vector2
var texture : int = 1
var level : int

var height_offset : float = 0.0
const h_offset_list = [0, 1, 2, 3]

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

func change_height_value(h : int):
	if h <= 4:
		height_offset = h_offset_list[h-1] / 4.0
	
	_genMesh()

func get_type():
	return "plat"
	
func _genMesh():
	mesh.mesh = meshGenObj.buildPlatform(pos, level, height_offset, false)
	collision_shape.shape = mesh.mesh.create_convex_shape()

func selectObj():
	selection_mesh = MeshInstance.new()
	selection_mesh.mesh = meshGenObj.buildPlatSelectionMesh(pos, level, height_offset, 0.05)