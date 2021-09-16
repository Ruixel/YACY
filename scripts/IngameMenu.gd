extends Control

onready var menu = get_node("/root/Main")
onready var fade = get_node("/root/Main/Fade")

var busy = false

func exit_level():
	busy = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	fade.fade(0.5)
	yield(fade, "s_fade_complete")
	
	menu.load_menu()
	
	fade.unfade(0.5)
	get_node("..").queue_free()

func _input(event):
	if event.is_action_pressed("exit") and not busy:
		exit_level()
