extends Node3D

var expiring: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Spin")

func _on_Area_body_entered(body):
	if not expiring and body.has_meta("player") and body.busy == false:
		expiring = true
		if body.has_method("pickupSlingshot"):
			var picked_up = body.pickupSlingshot()
			
			if picked_up:
				$PickupSFX.play()
				await $PickupSFX.finished
				self.queue_free()
