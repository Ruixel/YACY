extends Spatial

var gameNumber : int = -1

func set_gameNumber(id : int):
	gameNumber = id

func _on_Area_body_entered(body):
	if body.get_name() == "Player" and gameNumber != -1:
		get_node("/root/Spatial/LegacyLevel").clear_level()
		get_node("/root/Spatial/LegacyLevel").load_level(gameNumber)
