extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		print("shoot")
		$AnimationPlayer.play("ArmatureAction")
	if event.is_action_released("shoot"):
		$AnimationPlayer.stop()
