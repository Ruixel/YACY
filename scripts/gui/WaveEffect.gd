extends Node3D

@export var wave_speed: float

var p = PI/2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	p = p + (delta*wave_speed)
	translate(Vector3(0, sin(p)*0.0003, 0))
	$Cube.rotate_y(sin(p)*0.004)
