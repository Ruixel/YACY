extends MeshInstance

const TeleportColours = [
	"F2F2F2", "00B5E2", "E10098", "003DA5", "FEDD00", "EE2737", "948794", 
	"8F1A95", "8DB9CA", "9B2743", "FF9425", "005776"
]

var number : int = 1

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
	if body.get_name() == "Player":
		if body.busy == false:
			body.busy = true
			
			# Get correspoding teleport
			var tp = EntityManager.get_teleport(number, self)
			if tp != null:
				body.set_transform(tp.get_node("Pos").get_global_transform())
			
			yield(get_tree().create_timer(1.0), "timeout")
			body.busy = false
