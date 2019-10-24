extends Node

func _ready():
	print("GDNS Test")
	#get_parent().get_parent().get_node("WorldInterface").create_wall(Vector2(-30,-30), Vector2(100,100), 1)

func _on_Button_pressed():
	get_parent().loadLevelFromLocalhost(161782)
	#get_parent().loadLevelFromFilesystem("user://save_game.dat")
