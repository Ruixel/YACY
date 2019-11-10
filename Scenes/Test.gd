extends Button

func _ready():
	print("GDNS Test")
	get_parent().get_parent().get_node("LegacyLevel/ObjectLoader").create_wall(Vector2(-30,-30), Vector2(100,100), 1, 1, 1)

func _on_Button_pressed():
	get_parent().loadLevelFromLocalhost(4023)
	get_parent().get_parent().get_node("LegacyLevel").spawnPlayer()
	set_disabled(true)
	#get_parent().loadLevelFromFilesystem("user://save_game.dat")
