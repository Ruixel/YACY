extends Spatial

var expiring : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("Spin001")

func _on_Area_body_entered(body):
	if not expiring and body.get_name() == "Player" and body.busy == false:
		expiring = true
		if body.has_method("pickupJetpack"):
			body.pickupJetpack()
		
		$PickupSFX.play()
		yield($PickupSFX, "finished")
		self.queue_free()
