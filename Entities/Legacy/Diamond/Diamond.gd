extends Spatial

var time_save := 0
var expiring := false
var t := 0.5

# Different diamond types
const albedo = ["#4cb6f6", "#f66c4c", "#f6eb4c", "#eeeeee"]
const emission = ["#16a2e0", "#e93a18", "#e9d718", "#fbfbfb"]
const light = ["#00d0ff", "#e63b19", "#e4e619", "#e7e7e7"]
const time_save_types = [0, 5, 15, 60]

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
	if not expiring and body.has_meta("player") and body.busy == false:
		collect(body)
	
	if body.has_meta("type"):
		if not expiring and body.get_meta("type") == "projectile" and body.has_method("get_p_owner"):
			var player = body.get_p_owner()
			if player != null:
				collect(player)
			
			body.explode(body.global_transform.origin, false)

func set_type(type: int):
	if type < 1 or type > albedo.size():
		return
	
	$Mesh.get_surface_material(0).albedo_color = Color(albedo[type-1])
	$Mesh.get_surface_material(0).emission = Color(emission[type-1])
	$OmniLight.light_color = Color(light[type-1])
	self.time_save = time_save_types[type-1]
