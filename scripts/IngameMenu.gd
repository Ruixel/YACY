extends Control

onready var menu = get_node("/root/Main")
onready var fade = get_node("/root/Main/Fade")

var busy = false
var paused = false

signal pause
signal unpause

signal change_music_volume

func _ready():
	call_deferred("_on_volume_changed", 75.0, false)

func exit_level():
	busy = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	fade.fade(0.5)
	yield(fade, "s_fade_complete")
	
	menu.load_menu()
	
	fade.unfade(0.5)
	get_node("..").queue_free()

func _input(event):
	if event.is_action_pressed("pause") and not busy:
		paused = not paused
		visible = paused
		get_tree().paused = paused
		
		if paused:
			emit_signal("pause")
		else:
			emit_signal("unpause")
		#exit_level()


func _on_volume_changed(value):
	emit_signal("change_music_volume", value)
