extends Label

signal s_changeTool

# Gets the signals from the Tool buttons pressed
# Then it emits it globally as one

func _on_Wall_pressed():
	set_text("Selected: Wall")
	emit_signal("s_changeTool", WorldConstants.Tools.WALL)

func _on_Platform_pressed():
	set_text("Selected: Platform")
	emit_signal("s_changeTool", WorldConstants.Tools.PLATFORM)

func _on_Start_pressed():
	set_text("Selected: Starting Location")
	emit_signal("s_changeTool", WorldConstants.Tools.SPAWN)
