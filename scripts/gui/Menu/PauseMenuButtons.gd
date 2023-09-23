extends Control

var normal_pos

func on_mouse_hover(tween, label, hover_color):
	tween.stop_all()
	
	tween.interpolate_property(label, "position", label.position, 
	 Vector2(15, 0), 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	
	tween.interpolate_property(label, "modulate", label.modulate, 
	 hover_color, 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	
	$Hover.play()

func on_mouse_exit(tween, label):
	tween.stop_all()
	
	tween.interpolate_property(label, "position", label.position, 
	 Vector2(0, 0), 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()
	
	tween.interpolate_property(label, "modulate", label.modulate, 
	 Color(1.0, 1.0, 1.0), 0.2, Tween.TRANS_QUAD, Tween.EASE_OUT)
	tween.start()

func reset():
	_on_Exit_mouse_exited()
	_on_Restart_mouse_exited()
	_on_Continue_mouse_exited()

func _on_Exit_mouse_entered():
	on_mouse_hover($Exit/Tween, $Exit/ButtonLabel, Color(1.0, 0.3, 0.3))
func _on_Exit_mouse_exited():
	on_mouse_exit($Exit/Tween, $Exit/ButtonLabel)
func _on_Exit_button_down():
	on_mouse_hover($Exit/Tween, $Exit/ButtonLabel, Color(0.6, 0.1, 0.1))
	$Click.play()

func _on_Restart_mouse_entered():
	on_mouse_hover($Restart/Tween, $Restart/ButtonLabel, Color(0.65, 0.65, 0.65))
func _on_Restart_mouse_exited():
	on_mouse_exit($Restart/Tween, $Restart/ButtonLabel)
func _on_Restart_button_down():
	on_mouse_hover($Restart/Tween, $Restart/ButtonLabel, Color(0.4, 0.4, 0.4))
	$Click.play()

func _on_Continue_mouse_entered():
	on_mouse_hover($Continue/Tween, $Continue/ButtonLabel, Color(0.65, 0.65, 0.65))
func _on_Continue_mouse_exited():
	on_mouse_exit($Continue/Tween, $Continue/ButtonLabel)
func _on_Continue_button_down():
	on_mouse_hover($Continue/Tween, $Continue/ButtonLabel, Color(0.4, 0.4, 0.4))
