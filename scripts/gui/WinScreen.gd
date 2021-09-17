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

func _on_Replay_pressed():
	var level_manager = get_node_or_null("../../../../LegacyLevel")
	if level_manager != null:
		if not debounce:
			debounce = true
			level_manager.restart_level()
	else:
		push_error("Cannot find the level_manager")
