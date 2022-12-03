extends Panel

signal go_up_level
signal go_down_level

func _on_Up_pressed():
	emit_signal("go_up_level")

func _on_Down_pressed():
	emit_signal("go_down_level")
