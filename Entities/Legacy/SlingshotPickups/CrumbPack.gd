extends Spatial

var expiring: bool = false
var crumb_amount: int = 10

func set_crumb_amount(amount: int):
	crumb_amount = amount

func _on_Area_body_entered(body):
	if not expiring and body.get_name() == "Player" and body.busy == false:
		expiring = true
		if body.has_method("pickupCrumbs"):
			body.pickupCrumbs(crumb_amount)
		
		print("Picked up " + str(crumb_amount) + " crumbs")
		$PickupSFX.play()
		yield($PickupSFX, "finished")
		self.queue_free()
