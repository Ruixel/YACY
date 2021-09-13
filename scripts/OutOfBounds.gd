extends Area

func _on_OOBArea_body_entered(body):
	if body.has_meta("player"):
		body.busy = true
		body.fallInWater()
		
		$Bubbles.restart()
		$Bubbles.emitting = true
		$Bubbles.visible = true
		yield(get_tree().create_timer(2.5), "timeout")
		$Bubbles.emitting = false
		$Bubbles.visible = false
