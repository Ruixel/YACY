extends Node

var holes : Array

func _init():
	for lvl in range(0, WorldConstants.MAX_LEVELS+1):
		holes.append([])

func add_hole(hole, level):
	holes[level].append(hole)

func get_holes(level):
	return holes[level]

# Need to still delete via WorldAPI
func remove_hole(hole, level):
	holes[level].erase(hole)
