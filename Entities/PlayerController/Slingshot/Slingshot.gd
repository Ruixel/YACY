extends Spatial

var debounce := false
var pull_back := false
var ammo := 0

signal s_updateAmmo

# Called when the node enters the scene tree for the first time.
func _ready():
	if ammo <= 0:
		$Crumb.visible = false

func add_connection(player):
	player.connect("s_updateAmmo", self, "update_ammo")

func update_ammo(amount: int):
	ammo = amount
	print(ammo)
	$Crumb.visible = true
	
	if ammo <= 0 and not pull_back:
		$Crumb.visible = false

func _unhandled_input(event):
	if event.is_action_pressed("shoot") and not debounce and ammo > 0:
		debounce = true
		pull_back = true
		
		$AnimationPlayer.playback_speed = 1
		$AnimationPlayer.play("ArmatureAction")
	if event.is_action_released("shoot") and pull_back:
		pull_back = false
		ammo -= 1
		ammo = max(0, ammo)
		emit_signal("s_updateAmmo", ammo)
		
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
	if ammo > 0:
		$Crumb.visible = true
	
	debounce = false
