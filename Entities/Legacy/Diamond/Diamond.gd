extends Spatial

var expiring: bool = false

func _on_Area_body_entered(body):
	if not expiring and body.get_name() == "Player" and body.busy == false:
		expiring = true
		$Mesh.visible = false
		
		if body.has_method("pickupDiamond"):
			body.pickupDiamond()
		
		$PickupSFX.play()
		yield($PickupSFX, "finished")
		self.queue_free()
