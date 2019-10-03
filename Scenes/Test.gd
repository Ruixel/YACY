extends Node

func _ready():
	print("ok", ("Cat".find("ew",  1)))

func _on_Button_pressed():
	#get_parent().loadLevelFromLocalhost(163163)
	get_parent().loadLevelFromFilesystem("user://save_game.dat")
