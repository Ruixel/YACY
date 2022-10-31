extends Spatial

export var spin_speed: float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_x(delta*spin_speed)
