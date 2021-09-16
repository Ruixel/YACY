extends Control

var debounce := false

func _on_Menu_pressed():
	var pause_menu = get_node_or_null("../../../../PauseMenu")
	if pause_menu != null:
		if not debounce:
			debounce = true
			pause_menu.exit_level()
	else:
		push_error("Cannot find the pause menu node")
