extends StaticBody

func _on_Area_body_entered(body):
	if body.get_name() == "Player":
		if body.has_method("getOnLadder"):
			print("on ladder")
			body.getOnLadder()

func _on_Area_body_exited(body):
	if body.get_name() == "Player":
		if body.has_method("getOffLadder"):
			body.getOffLadder()
