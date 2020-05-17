extends Spatial

# Called when the cursor is selected
func cursor_ready():
	pass

# Called every frame
func cursor_process(delta: float, mouse_motion : Vector2) -> void:
	pass

# Called when another cursor is selected
func cursor_on_tool_change(newTool):
	pass

func cursor_on_mode_change(newMode):
	pass

func cursor_on_level_change(newLevel):
	pass
