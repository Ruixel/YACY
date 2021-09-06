extends KinematicBody

var speed := 1000
var y_speed := 90
var gravity := 360

var p_owner = null

# Called when the node enters the scene tree for the first time.
func _ready():
	set_meta("type", "projectile")

func set_p_owner(body):
	p_owner = body

func get_p_owner():
	return p_owner

func set_speed(speed: int):
	self.speed = speed

func explode(pos: Vector3, play_blast: bool = true):
	var particle_fx = preload("res://Entities/PlayerController/Slingshot/CrumbExplosion.tscn").instance()
	particle_fx.translation = pos - Vector3(0, 0.1, 0)
	particle_fx.play_sfx = play_blast
	get_parent().add_child(particle_fx)
	self.queue_free()

func _physics_process(delta):
	y_speed -= delta * gravity
	var velocity = -global_transform.basis.z * Vector3(1, 1, 1) * delta * speed + global_transform.basis.y * Vector3(0, 1, 0) * delta * y_speed
	
	var collision_data = move_and_collide(velocity)
	if collision_data != null:
		explode(collision_data.get_position())
		

func _on_DebrisTimer_timeout():
	self.queue_free()
