extends Spatial

export var spin_speed: float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_y(delta*spin_speed)
