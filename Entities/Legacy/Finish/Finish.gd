extends Spatial

func _on_Area_body_entered(body):
	if body.has_meta("player") and body.busy == false:
		if body.has_method("finish_level"):
			var picked_up = body.finish_level()
