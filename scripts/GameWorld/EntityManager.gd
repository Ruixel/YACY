extends Node

var teleports : Array

func _ready():
	_reset()

func _reset():
	teleports = []
	for i in range(0, 13):
		teleports.insert(i, [])

func add_teleport(number, tp_ent):
	teleports[number].append(tp_ent)

# Return a random teleport with a given number that is not 
func get_teleport(number, tp_ent):
	if teleports[number] != null:
		teleports[number].shuffle()
		for tp in teleports[number]:
			if tp != tp_ent:
				return tp
		
	return null

func remove_teleport(number, tp_ent):
	if teleports[number] != null:
		teleports[number].erase(tp_ent)
