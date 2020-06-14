extends Panel

signal s_toggleGrid
signal s_toggleUpperFloors
signal s_saveFile
signal s_loadFile

var gridOn = true
func _on_ToggleGrid_pressed():
	gridOn = not gridOn
	if gridOn:
		$ToggleGrid.set_text("Hide Grid")
	else:
		$ToggleGrid.set_text("Show Grid")
		
	emit_signal("s_toggleGrid", gridOn)

var upperLevelsOn = true
func _on_ToggleUpperLevels_pressed():
	upperLevelsOn = not upperLevelsOn
	if upperLevelsOn:
		$ToggleUpperLevels.set_text("Hide Upper Levels")
	else:
		$ToggleUpperLevels.set_text("Show Upper Levels")
		
	emit_signal("s_toggleUpperFloors", upperLevelsOn)

func _on_Save_pressed():
	emit_signal("s_saveFile")

func _on_Load_pressed():
	emit_signal("s_loadFile")
