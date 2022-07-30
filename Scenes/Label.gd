extends Label


# Declare member variables here. Examples:
var p = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	p = p + delta * 5
	#rect_global_position = rect_global_position + Vector2(0, sin(p)*0.5)
