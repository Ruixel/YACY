extends Panel

var level = 1

signal s_changeLevel

func _on_Up_pressed():
	level = clamp(level + 1, 0, WorldConstants.MAX_LEVELS)
	emit_signal("s_changeLevel", level)
	
	$LevelSelected.set_text("Level " + str(level) + "/" + str(WorldConstants.MAX_LEVELS))

func _on_Down_pressed():
	level = clamp(level - 1, 0, WorldConstants.MAX_LEVELS)
	emit_signal("s_changeLevel", level)
	
	$LevelSelected.set_text("Level " + str(level) + "/" + str(WorldConstants.MAX_LEVELS))
