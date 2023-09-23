extends StaticBody3D

const ladderIncline = 10 # Degrees

var debounce: bool = false

func _on_Area_body_entered(body):
	if not debounce and body.has_meta("player"):
		if body.has_method("getOnLadder"):
			debounce = true
			var rotation = self.transform.basis.get_euler().y
			print(rotation)
			
			var ladderNormal = Vector3(0, 1, 0)
			var ladderUpVector = ladderNormal.rotated(Vector3(1, 0, 0), deg_to_rad(-ladderIncline))
			ladderUpVector = ladderUpVector.rotated(Vector3(0, 1, 0), rotation)
			
			ladderNormal = ladderNormal.rotated(Vector3(1, 0, 0), deg_to_rad(-ladderIncline + 90))
			ladderNormal = ladderNormal.rotated(Vector3(0, 1, 0), rotation)
			
			body.getOnLadder(ladderNormal, ladderUpVector)
			
			#yield(get_tree().create_timer(0.5), "timeout")
			debounce = false

func _on_Area_body_exited(body):
	if body.has_meta("player"):
		if body.has_method("getOffLadder"):
			body.getOffLadder()
			print("hi")
