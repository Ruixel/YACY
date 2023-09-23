extends Node3D

var expiring: bool = false
var crumb_amount: int = 10

func set_crumb_amount(amount: int):
	crumb_amount = amount

func _on_Area_body_entered(body):
	if not expiring and body.has_meta("player") and body.busy == false:
		expiring = true
		if body.has_method("pickupCrumbs"):
			body.pickupCrumbs(crumb_amount)
		
		print("Picked up " + str(crumb_amount) + " crumbs")
		$PickupSFX.play()
		await $PickupSFX.finished
		self.queue_free()
