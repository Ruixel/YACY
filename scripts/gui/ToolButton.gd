extends Control

signal s_changeTool
signal s_changeMode

# Gets the signals from the Tool buttons pressed
# Then it emits it globally as one

func _on_Wall_pressed():
	$ToolSelected.set_text("Selected: Wall")
	emit_signal("s_changeTool", WorldConstants.Tools.WALL)
	emit_signal("s_changeMode", WorldConstants.Mode.CREATE)

func _on_Platform_pressed():
	$ToolSelected.set_text("Selected: Platform")
	emit_signal("s_changeTool", WorldConstants.Tools.PLATFORM)
	emit_signal("s_changeMode", WorldConstants.Mode.CREATE)

func _on_Select_pressed():
	$ToolSelected.set_text("Selecting...")
	emit_signal("s_changeTool", WorldConstants.Tools.NOTHING)
	emit_signal("s_changeMode", WorldConstants.Mode.SELECT)
