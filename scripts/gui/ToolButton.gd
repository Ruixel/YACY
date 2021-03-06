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

func _on_Pillar_pressed():
	$ToolSelected.set_text("Selected: Pillar")
	emit_signal("s_changeTool", WorldConstants.Tools.PILLAR)
	emit_signal("s_changeMode", WorldConstants.Mode.CREATE)

func _on_Ramp_pressed():
	$ToolSelected.set_text("Selected: Ramp")
	emit_signal("s_changeTool", WorldConstants.Tools.RAMP)
	emit_signal("s_changeMode", WorldConstants.Mode.CREATE)

func _on_Ground_pressed():
	$ToolSelected.set_text("Selected: Level Ground")
	emit_signal("s_changeTool", WorldConstants.Tools.GROUND)
	emit_signal("s_changeMode", WorldConstants.Mode.CREATE)

func _on_Hole_pressed():
	$ToolSelected.set_text("Selected: Hole")
	emit_signal("s_changeTool", WorldConstants.Tools.HOLE)
	emit_signal("s_changeMode", WorldConstants.Mode.CREATE)
