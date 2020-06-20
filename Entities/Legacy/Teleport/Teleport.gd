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
