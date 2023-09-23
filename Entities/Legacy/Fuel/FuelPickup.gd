extends Node3D

var expiring: bool = false
var fuel_amount: int = 30

func set_fuel_amount(amount: int):
	fuel_amount = amount

func _on_Area_body_entered(body):
	if not expiring and body.has_meta("player") and body.busy == false:
		expiring = true
		if body.has_method("pickupFuel"):
			var picked_up = body.pickupFuel(fuel_amount)
			
			if picked_up:
				#print("Picked up " + str(fuel_amount) + "s fuel")
				$PickupSFX.play()
				await $PickupSFX.finished
				self.queue_free()
