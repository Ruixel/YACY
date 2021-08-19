extends Control

func showLevel(title: String, author: String):
	$Timer.stop()
	$Tween.stop_all()
	set_modulate(Color(1,1,1,0))
	
	yield(get_tree().create_timer(1.0), "timeout")
	
	$Title.text = title
	$Author.text = "By " + author
	
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,0), Color(1,1,1,1), 1, Tween.TRANS_CUBIC, Tween.EASE_IN)
	$Tween.start()
	$Timer.start()
	
	#


func _on_Timer_timeout():
	$Timer.stop()
	$Tween.stop_all()
	
	$Tween.interpolate_property(self, "modulate", Color(1,1,1,1), Color(1,1,1,0), 3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()