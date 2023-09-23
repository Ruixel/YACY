extends Control

func _ready():
	get_parent().connect("get_level_info", Callable(self, "set_level_info"))

func showLevel(title: String, author: String):
	$Timer.stop()
	$Tween.stop_all()
	set_modulate(Color(1,1,1,0))
	
	await get_tree().create_timer(1.0).timeout
	
	$Title.text = title
	$Author.text = "By " + author
	
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1), 1, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()
	$Timer.start()


func _on_Timer_timeout():
	$Timer.stop()
	$Tween.stop_all()
	
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), 3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()

func set_level_info(info):
	showLevel(info.title, info.author)
