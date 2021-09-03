extends Spatial

var debounce := false
var pull_back := false
var ammo := 50

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _unhandled_input(event):
	if event.is_action_pressed("shoot") and not debounce:
		debounce = true
		pull_back = true
		
		$AnimationPlayer.playback_speed = 1
		$Crumb.visible = true
		$AnimationPlayer.play("ArmatureAction")
	if event.is_action_released("shoot") and pull_back:
		pull_back = false
		
		var projectile = preload("res://Entities/PlayerController/Slingshot/CrumbProjectile.tscn").instance()
		projectile.set_p_owner(get_node("../../.."))
		projectile.set_speed(50 + $AnimationPlayer.current_animation_position * 2050)
		projectile.global_transform = $ProjectileSpawn.global_transform
		get_parent().get_parent().get_parent().get_parent().add_child(projectile)
		
		$AnimationPlayer.playback_speed = 5
		$Crumb.visible = false
		$AnimationPlayer.play_backwards("ArmatureAction")
		$FireSFX.play()
		
		$Debounce.start()


func _on_Debounce_timeout():
	$Crumb.visible = true
	debounce = false
