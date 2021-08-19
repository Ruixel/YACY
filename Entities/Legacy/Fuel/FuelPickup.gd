extends Spatial

var expiring: bool = false
var fuel_amount: int = 30

func set_fuel_amount(amount: int):
	fuel_amount = amount

func _on_Area_body_entered(body):
	if not expiring and body.get_name() == "Player" and body.busy == false:
		expiring = true
		if body.has_method("pickupFuel"):
			body.pickupFuel()
		
		print("Picked up " + str(fuel_amount) + "s fuel")
		
		$PickupSFX.play()
		yield($PickupSFX, "finished")
		self.queue_free()
