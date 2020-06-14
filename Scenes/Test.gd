extends Button

func _ready():
	print("GDNS Test")
	##get_parent().get_parent().get_node("LegacyLevel/ObjectLoader").create_wall(Vector2(-30,-30), Vector2(100,100), 1, 1, 1)

func _on_Button_pressed():
	#get_parent().loadLevelFromLocalhost(2071)
	get_parent().loadLevelFromFilesystem("user://lol.cy")
	#get_parent().get_parent().get_node("LegacyLevel").call("spawnPlayer")
	set_disabled(true)
	
