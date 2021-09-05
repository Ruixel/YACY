extends Spatial

var expiring: bool = false
var t := 0.5

func collect(body):
	expiring = true
	$Mesh.visible = false
	$OmniLight.visible = false
	
	if body.has_method("pickupDiamond"):
		body.pickupDiamond()
	
	$PickupSFX.play()
	yield($PickupSFX, "finished")
	self.queue_free()

func _physics_process(delta):
	t += delta
	$Mesh.translate(Vector3(0, sin(t*1.5)/1000.0, 0))
	$Mesh.rotate_y(delta * 0.5)

func _on_Area_body_entered(body):
	if not expiring and body.get_name() == "Player" and body.busy == false:
		collect(body)
		
	if not expiring and body.get_name() == "Crumb" and body.has_method("get_p_owner"):
		var player = body.get_p_owner()
		if player != null:
			collect(player)
		
		body.explode(body.global_transform.origin, false)
