extends Panel

var level = 1
var level_max = 20

signal s_changeLevel

func _on_Up_pressed():
	level = clamp(level + 1, 0, level_max)
	emit_signal("s_changeLevel", level)
	
	$LevelSelected.set_text("Level " + str(level) + "/" + str(level_max))

func _on_Down_pressed():
	level = clamp(level - 1, 0, level_max)
	emit_signal("s_changeLevel", level)
	
	$LevelSelected.set_text("Level " + str(level) + "/" + str(level_max))
