extends Button

var normal_pos

onready var tween = $Tween
onready var spinning_mesh = $ViewportContainer2/Viewport/Mesh

var spinning_mesh_initial_position
var mouse_entered = false

func _ready():
	spinning_mesh_initial_position = spinning_mesh.transform

func _process(delta):
	if (mouse_entered):
		spinning_mesh.rotate_y(3*delta)
	else:
		spinning_mesh.transform = spinning_mesh.transform.interpolate_with(spinning_mesh_initial_position, 10*delta)

func _on_mouse_entered():
	mouse_entered = true
	
func _on_mouse_exited():
	mouse_entered = false
