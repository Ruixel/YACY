extends Spatial

var expiring: bool = false

func collect(body):
	expiring = true
	$Mesh.visible = false
	
	if body.has_method("pickupDiamond"):
		body.pickupDiamond()
	
	$PickupSFX.play()
	yield($PickupSFX, "finished")
	self.queue_free()

func _on_Area_body_entered(body):
	if not expiring and body.get_name() == "Player" and body.busy == false:
		collect(body)
		
	if body.get_name() == "Crumb" and body.has_method("get_p_owner"):
		var player = body.get_p_owner()
		if player != null:
			collect(player)
		
		body.explode(body.global_transform.origin, false)
