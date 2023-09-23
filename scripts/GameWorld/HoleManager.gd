extends Node

var holes : Array
#
#func _init():
#	for lvl in range(0, WorldConstants.MAX_LEVELS+1):
#		holes.append([])
#
#func add_hole(hole, level):
#	holes[level].append(hole)
#
#func get_holes(level):
#	return holes[level]
#
## Need to still delete via WorldAPI
#func remove_hole(hole, level):
#	holes[level].erase(hole)
#
#	# Update floor mesh
#	update_ground_mesh(level)
#
#func get_ground(level):
#	var worldAPI = get_node_or_null("/root/Node3D/WorldInterface")
#	if worldAPI != null:
#		return worldAPI.fixed_objects[WorldConstants.Tools.GROUND][level]
#	else:
#		return null
#
#func update_ground_mesh(level):
#	var ground = get_ground(level)
#	if ground != null:
#		ground._genMesh()
