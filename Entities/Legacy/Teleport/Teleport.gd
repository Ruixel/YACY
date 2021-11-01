extends MeshInstance

const TeleportColours = [
	"F2F2F2", "00B5E2", "E10098", "003DA5", "FEDD00", "EE2737", "948794", 
	"8F1A95", "8DB9CA", "9B2743", "FF9425", "005776"
]

var number : int = 1
var player = null

func set_number(num : int):
	var text = str(num)
	
	if num == 12:
		number = -1
		text = "R"
	else:
		number = num
	
	$Viewport/Text.set_text(text)
	var t = $Viewport.get_texture()
	$Number.mesh.surface_get_material(0).albedo_texture = t
	self.mesh.surface_get_material(0).emission = Color(TeleportColours[number-1])
	
	EntityManager.add_teleport(number, self)

func _on_Area_body_entered(body):
	if body.has_meta("player"):
		if body.tp_busy == false:
			body.tp_busy = true
			
			self.player = body
			set_process(true)

func _process(delta):
	if player == null:
		set_process(false)
		return
	
	var velocity = Vector3(player.charVelocity.x, 0, player.charVelocity.z).length()
	#print("Velocity: ", velocity)
	if velocity < 0.2:
		var tp = EntityManager.get_teleport(number, self)
		if tp != null:
			player.get_node("AudioNode/Teleport").play()
			player.set_transform(tp.get_node("Pos").get_global_transform().translated(Vector3(0, -0.1, 0)))
			
		set_process(false)
		yield(get_tree().create_timer(1.0), "timeout")
		player.tp_busy = false
