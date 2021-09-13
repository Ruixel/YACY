extends Particles2D

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().get_root().connect("size_changed", self, "resize")
	resize()

func resize():
	var vp_size = get_viewport_rect().size
	self.position = Vector2(vp_size.x / 2, vp_size.y + 30)
	self.process_material.emission_box_extents = Vector3(1, vp_size.x / 2, 1)
