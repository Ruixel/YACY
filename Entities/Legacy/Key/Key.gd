extends Spatial

var expiring: bool = false
var key: int = 0

func _ready():
	$AnimationPlayer.play("Spin")
	$AnimationPlayer.seek(randf()*10)

func set_keyNumber(key: int):
	if key < 1 or key > 10:
		$Armature/Bone/KeyDisplay/KeyDisplay.mesh.get_material().uv1_offset = Vector3(0.083*(10)+0.008, 0, 0)
		return
	
	self.key = key
	$Armature/Bone/KeyDisplay/KeyDisplay.mesh.get_material().uv1_offset = Vector3(0.083*(key-1), 0, 0)


func _on_Area_body_entered(body):
	if not expiring and body.get_name() == "Player" and body.busy == false:
		expiring = true
		if body.has_method("pickupKey"):
			pass
		
		$PickupSFX.play()
		yield($PickupSFX, "finished")
		self.queue_free()
