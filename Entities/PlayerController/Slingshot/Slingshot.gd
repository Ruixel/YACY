extends Spatial

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _unhandled_input(event):
	if event.is_action_pressed("shoot"):
		print("shoot")
		$AnimationPlayer.playback_speed = 0.8
		$AnimationPlayer.play("ArmatureAction")
	if event.is_action_released("shoot"):
		$AnimationPlayer.playback_speed = 5
		$AnimationPlayer.play_backwards("ArmatureAction")
