extends Spatial

var gameNumber : int = -1

func set_gameNumber(id : int):
	gameNumber = id

func _on_Area_body_entered(body):
	if body.has_meta("player") and gameNumber != -1 and body.busy == false:
		body.busy = true
		body.pause = true
		var fade = get_node("/root/Main/Fade")
		fade.fade(0.3)
		yield(fade, "s_fade_complete")
		
		get_node("/root/Gameplay/LegacyLevel").clear_level()
		get_node("/root/Gameplay/LegacyLevel").load_level(gameNumber)
